import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/webrtc_config.dart';
import '../../services/socket/signaling_service.dart';
import '../../services/webrtc/peer_call_service.dart';

part 'customer_state.dart';

/// Drives the customer-side phone screen. No Shadow/AI here by design.
///
/// When [_signaling] and [_peer] are provided (real-call mode), the lifecycle is
/// driven by real WebRTC signaling: the customer is the **caller** — it creates
/// and sends the offer, then connects once the agent answers. With no services
/// it falls back to the original timer-driven demo.
class CustomerCubit extends Cubit<CustomerState> {
  CustomerCubit({SignalingService? signaling, PeerCallService? peer})
    : _signaling = signaling,
      _peer = peer,
      super(const CustomerIdle());

  final SignalingService? _signaling;
  final PeerCallService? _peer;
  StreamSubscription<Map<String, dynamic>>? _sigSub;

  Timer? _ringTimer;
  Timer? _tickTimer;

  /// Call language ('ar' | 'en'), chosen by the customer before the call. This
  /// becomes the transcription language for **both** sides (sent to the agent on
  /// the offer) — independent of either browser's UI locale.
  String _callLang = 'ar';
  String get callLang => _callLang;

  bool get _real => _signaling != null && _peer != null;

  /// Remote-audio renderer for the page to mount (null in demo mode).
  RTCVideoRenderer? get remoteRenderer => _peer?.remoteRenderer;

  /// Customer taps "Call". [lang] is the customer-chosen call language.
  Future<void> startCall({String lang = 'ar'}) async {
    _callLang = lang;
    if (!_real) return _startCallMock();

    final peer = _peer!;
    final signaling = _signaling!;
    emit(const CustomerRinging());
    try {
      await peer.init();
      peer.onIceCandidate = (c) =>
          signaling.send({'type': 'ice', 'candidate': c.toMap()});
      peer.onConnected = _onPeerConnected;
      peer.onDisconnected = _onPeerGone;
      _sigSub = signaling.messages.listen(_onSignal);
      signaling.connect(WebRtcConfig.signalingUrl(role: 'customer'));
    } catch (_) {
      // Mic denied / setup failed — drop back to idle.
      await peer.hangUp();
      emit(const CustomerIdle());
    }
  }

  Future<void> _onSignal(Map<String, dynamic> msg) async {
    switch (msg['type']) {
      case 'peer-ready':
        // Agent is present — send the offer, carrying the chosen call language
        // so the agent transcribes in the same language.
        final offer = await _peer!.createOffer();
        _signaling!.send({
          'type': 'offer',
          'sdp': offer.sdp,
          'lang': _callLang,
        });
      case 'answer':
        // Agent answered → connected.
        await _peer!.setRemoteDescription(msg['sdp'] as String, 'answer');
        _onAgentAnswered();
      case 'ice':
        await _peer!.addRemoteIceCandidate(
          Map<String, dynamic>.from(msg['candidate'] as Map),
        );
      case 'bye':
        _onPeerGone();
    }
  }

  void _onAgentAnswered() {
    if (state is CustomerConnected) return;
    emit(const CustomerConnected());
    _startTicking();
  }

  void _onPeerConnected() {
    if (state is! CustomerConnected) _onAgentAnswered();
  }

  void _onPeerGone() {
    if (state is CustomerConnected || state is CustomerRinging) endCall();
  }

  void toggleMute() {
    final s = state;
    if (s is CustomerConnected) {
      _peer?.setMicEnabled(
        s.muted,
      ); // currently muted → re-enable, and vice versa
      emit(s.copyWith(muted: !s.muted));
    }
  }

  void toggleSpeaker() {
    final s = state;
    if (s is CustomerConnected) emit(s.copyWith(speakerOn: !s.speakerOn));
  }

  Future<void> endCall() async {
    _ringTimer?.cancel();
    _tickTimer?.cancel();
    final s = state;
    final seconds = s is CustomerConnected ? s.seconds : 0;
    if (_real) {
      _signaling!.send({'type': 'bye'});
      await _peer!.hangUp();
    }
    emit(CustomerEnded(seconds));
  }

  Future<void> reset() async {
    _ringTimer?.cancel();
    _tickTimer?.cancel();
    emit(const CustomerIdle());
  }

  // ── Demo (timer) fallback ──────────────────────────────────────────────────
  void _startCallMock() {
    _ringTimer?.cancel();
    emit(const CustomerRinging());
    _ringTimer = Timer(AppConfig.customerRingDuration, () {
      if (state is CustomerRinging) {
        emit(const CustomerConnected());
        _startTicking();
      }
    });
  }

  void _startTicking() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state;
      if (s is CustomerConnected) emit(s.copyWith(seconds: s.seconds + 1));
    });
  }

  @override
  Future<void> close() {
    _ringTimer?.cancel();
    _tickTimer?.cancel();
    _sigSub?.cancel();
    _peer?.dispose();
    _signaling?.dispose();
    return super.close();
  }
}
