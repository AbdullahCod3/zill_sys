import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../core/constants/webrtc_config.dart';

/// Wraps a single [RTCPeerConnection] for the **real voice call** between the
/// customer and the agent.
///
/// This is deliberately separate from the `AudioSource`/transcript abstraction
/// (rule #1): that path stays the scripted `SimulatedWebRtcSource` for the demo
/// Shadow Assist panel. This service only carries live human audio both ways.
class PeerCallService {
  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _rendererReady = false;

  // Remote ICE candidates that arrive before the remote description is set are
  // queued and flushed once it lands (avoids a race that drops candidates).
  bool _remoteDescriptionSet = false;
  final List<RTCIceCandidate> _pendingRemoteCandidates = [];

  /// Emits each locally-gathered ICE candidate to forward over signaling.
  void Function(RTCIceCandidate candidate)? onIceCandidate;

  /// Fires when the peer connection reaches the connected state.
  void Function()? onConnected;

  /// Fires when the connection drops/fails/closes.
  void Function()? onDisconnected;

  /// Renders the remote audio (a hidden [RTCVideoView] plays it on web).
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  /// Acquire the mic and build the peer connection + local track.
  Future<void> init() async {
    _remoteDescriptionSet = false;
    _pendingRemoteCandidates.clear();

    if (!_rendererReady) {
      await _remoteRenderer.initialize();
      _rendererReady = true;
    }

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });

    final pc = await createPeerConnection(WebRtcConfig.iceServers);
    _pc = pc;

    for (final track in _localStream!.getTracks()) {
      await pc.addTrack(track, _localStream!);
    }

    pc.onIceCandidate = (candidate) {
      if (candidate.candidate != null) onIceCandidate?.call(candidate);
    };
    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams.first;
      }
    };
    pc.onConnectionState = (state) {
      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          onConnected?.call();
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
          onDisconnected?.call();
        default:
          break;
      }
    };
  }

  /// Caller path: create + set the local offer.
  Future<RTCSessionDescription> createOffer() async {
    final offer = await _pc!.createOffer({'offerToReceiveAudio': true});
    await _pc!.setLocalDescription(offer);
    return offer;
  }

  /// Callee path: create + set the local answer.
  Future<RTCSessionDescription> createAnswer() async {
    final answer = await _pc!.createAnswer();
    await _pc!.setLocalDescription(answer);
    return answer;
  }

  /// Apply the remote SDP ([type] is `offer` or `answer`) and flush any queued
  /// ICE candidates.
  Future<void> setRemoteDescription(String sdp, String type) async {
    await _pc!.setRemoteDescription(RTCSessionDescription(sdp, type));
    _remoteDescriptionSet = true;
    for (final candidate in _pendingRemoteCandidates) {
      await _pc!.addCandidate(candidate);
    }
    _pendingRemoteCandidates.clear();
  }

  /// Add a remote ICE candidate (queued until the remote description is set).
  Future<void> addRemoteIceCandidate(Map<String, dynamic> data) async {
    final candidate = RTCIceCandidate(
      data['candidate'] as String?,
      data['sdpMid'] as String?,
      (data['sdpMLineIndex'] as num?)?.toInt(),
    );
    if (_remoteDescriptionSet) {
      await _pc!.addCandidate(candidate);
    } else {
      _pendingRemoteCandidates.add(candidate);
    }
  }

  /// Mute/unmute the local mic by toggling the audio track.
  void setMicEnabled(bool enabled) {
    for (final track in _localStream?.getAudioTracks() ?? const []) {
      track.enabled = enabled;
    }
  }

  /// Tear down the peer connection and stop the mic (renderer kept for reuse).
  Future<void> hangUp() async {
    await _pc?.close();
    _pc = null;
    for (final track in _localStream?.getTracks() ?? const []) {
      await track.stop();
    }
    await _localStream?.dispose();
    _localStream = null;
    _remoteRenderer.srcObject = null;
    _remoteDescriptionSet = false;
    _pendingRemoteCandidates.clear();
  }

  /// Release everything, including the renderer.
  Future<void> dispose() async {
    await hangUp();
    if (_rendererReady) {
      await _remoteRenderer.dispose();
      _rendererReady = false;
    }
  }
}
