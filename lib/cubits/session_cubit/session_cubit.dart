import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/webrtc_config.dart';
import '../../models/calls_model.dart';
import '../../services/socket/signaling_service.dart';
import '../../services/webrtc/peer_call_service.dart';

part 'session_state.dart';

/// Drives the agent console's call lifecycle and in-call controls.
///
/// When [_signaling] and [_peer] are provided (real-call mode), the agent is the
/// **callee**: it waits on signaling, rings on an incoming offer, and answers
/// with a real WebRTC answer. With no services it falls back to the original
/// timer-driven demo. Get Answer / Shadow Assist (transcript + answers) is
/// untouched and stays scripted.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit({SignalingService? signaling, PeerCallService? peer})
    : _signaling = signaling,
      _peer = peer,
      super(const SessionInitial());

  final SignalingService? _signaling;
  final PeerCallService? _peer;
  StreamSubscription<Map<String, dynamic>>? _sigSub;
  bool _signalingConnected = false;
  String? _pendingOfferSdp;

  /// Call language ('ar' | 'en'), chosen by the customer and carried on the
  /// offer. Drives the agent's Deepgram stream so both sides transcribe in the
  /// same language — independent of the agent's UI locale.
  String _callLang = 'en';
  String get callLang => _callLang;

  Timer? _incomingTimer;
  Timer? _tickTimer;

  bool get _real => _signaling != null && _peer != null;

  /// Remote-audio renderer for the page to mount (null in demo mode).
  RTCVideoRenderer? get remoteRenderer => _peer?.remoteRenderer;

  /// Start waiting for a call.
  Future<void> begin() async {
    if (!_real) return _beginMock();

    final peer = _peer!;
    final signaling = _signaling!;
    _pendingOfferSdp = null;
    emit(const SessionWaiting());
    try {
      await peer.hangUp(); // reset any previous call's peer connection
      await peer.init();
      peer.onIceCandidate = (c) =>
          signaling.send({'type': 'ice', 'candidate': c.toMap()});
      peer.onConnected = _onPeerConnected;
      peer.onDisconnected = _onPeerGone;
      if (!_signalingConnected) {
        _sigSub = signaling.messages.listen(_onSignal);
        signaling.connect(WebRtcConfig.signalingUrl(role: 'agent'));
        _signalingConnected = true;
      }
    } catch (_) {
      emit(const SessionWaiting());
    }
  }

  Future<void> _onSignal(Map<String, dynamic> msg) async {
    switch (msg['type']) {
      case 'offer':
        // Customer is calling — ring. Capture the customer-chosen call language.
        _pendingOfferSdp = msg['sdp'] as String;
        _callLang = msg['lang'] as String? ?? _callLang;
        if (state is! SessionConnected) emit(const SessionIncoming());
      case 'ice':
        await _peer!.addRemoteIceCandidate(
          Map<String, dynamic>.from(msg['candidate'] as Map),
        );
      case 'bye':
        _onPeerGone();
    }
  }

  /// Agent accepts the call.
  Future<void> answer() async {
    if (state is! SessionIncoming) return;
    if (!_real) {
      emit(const SessionConnected());
      _startTicking();
      return;
    }
    final offer = _pendingOfferSdp;
    if (offer == null) return;
    final peer = _peer!;
    await peer.setRemoteDescription(offer, 'offer');
    final answer = await peer.createAnswer();
    _signaling!.send({'type': 'answer', 'sdp': answer.sdp});
    emit(const SessionConnected());
    _startTicking();
  }

  /// Agent rejects the call → back to waiting for the next one.
  void reject() {
    if (state is! SessionIncoming) return;
    if (_real) _signaling!.send({'type': 'bye'});
    begin();
  }

  /// Demo shortcut: jump straight into a connected call with no real peer, so
  /// the in-call console can be reached without the customer browser. Works in
  /// both real-call and timer modes (ignores signaling/peer).
  void simulateCall() {
    _incomingTimer?.cancel();
    emit(const SessionConnected());
    _startTicking();
  }

  /// Get Answer pressed — capture starts now (PRD §6).
  void markListening() {
    final s = state;
    if (s is SessionConnected) emit(s.copyWith(listening: true));
  }

  void toggleMute() {
    final s = state;
    if (s is SessionConnected) {
      _peer?.setMicEnabled(
        s.muted,
      ); // currently muted → re-enable, & vice versa
      emit(s.copyWith(muted: !s.muted));
    }
  }

  void toggleSpeaker() {
    final s = state;
    if (s is SessionConnected) emit(s.copyWith(speakerOn: !s.speakerOn));
  }

  /// End the call; [summary] is assembled by the page from the other cubits.
  Future<void> end(CallsModel summary) async {
    _tickTimer?.cancel();
    if (_real) {
      _signaling!.send({'type': 'bye'});
      await _peer!.hangUp();
    }
    emit(SessionEnded(summary));
  }

  /// Current call duration in seconds, or 0 outside a connected call.
  int get elapsedSeconds {
    final s = state;
    return s is SessionConnected ? s.seconds : 0;
  }

  void _onPeerConnected() {
    final s = state;
    if (s is! SessionConnected) {
      emit(const SessionConnected());
      _startTicking();
    }
  }

  /// Remote peer dropped/hung up before the agent answered → back to waiting.
  void _onPeerGone() {
    if (state is SessionIncoming) begin();
  }

  // ── Demo (timer) fallback ──────────────────────────────────────────────────
  void _beginMock() {
    _incomingTimer?.cancel();
    emit(const SessionWaiting());
    _incomingTimer = Timer(AppConfig.incomingCallDelay, () {
      if (state is SessionWaiting) emit(const SessionIncoming());
    });
  }

  void _startTicking() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state;
      if (s is SessionConnected) emit(s.copyWith(seconds: s.seconds + 1));
    });
  }

  @override
  Future<void> close() {
    _incomingTimer?.cancel();
    _tickTimer?.cancel();
    _sigSub?.cancel();
    _peer?.dispose();
    _signaling?.dispose();
    return super.close();
  }
}
