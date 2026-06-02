import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../models/calls_model.dart';

part 'session_state.dart';

/// Drives the agent console's call lifecycle and in-call controls. Coordinates
/// nothing else directly — the page wires Get Answer to the transcript/answer
/// cubits — keeping this focused on session state (CLAUDE.md).
class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(const SessionInitial());

  Timer? _incomingTimer;
  Timer? _tickTimer;

  /// Start the demo loop: wait briefly, then an incoming call rings.
  void begin() {
    _incomingTimer?.cancel();
    emit(const SessionWaiting());
    _incomingTimer = Timer(AppConfig.incomingCallDelay, () {
      if (state is SessionWaiting) emit(const SessionIncoming());
    });
  }

  /// Agent accepts the call.
  void answer() {
    if (state is! SessionIncoming) return;
    emit(const SessionConnected());
    _startTicking();
  }

  /// Agent rejects the call → back to waiting for the next one.
  void reject() {
    if (state is! SessionIncoming) return;
    begin();
  }

  /// Get Answer pressed — capture starts now (PRD §6).
  void markListening() {
    final s = state;
    if (s is SessionConnected) emit(s.copyWith(listening: true));
  }

  void toggleMute() {
    final s = state;
    if (s is SessionConnected) emit(s.copyWith(muted: !s.muted));
  }

  void toggleSpeaker() {
    final s = state;
    if (s is SessionConnected) emit(s.copyWith(speakerOn: !s.speakerOn));
  }

  /// End the call; [summary] is assembled by the page from the other cubits.
  void end(CallsModel summary) {
    _tickTimer?.cancel();
    emit(SessionEnded(summary));
  }

  /// Current call duration in seconds, or 0 outside a connected call.
  int get elapsedSeconds {
    final s = state;
    return s is SessionConnected ? s.seconds : 0;
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
    return super.close();
  }
}
