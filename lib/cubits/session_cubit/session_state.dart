part of 'session_cubit.dart';

/// Agent-side call lifecycle: waiting → incoming → connected → ended.
sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

/// Before a call exists.
class SessionInitial extends SessionState {
  const SessionInitial();
}

/// Idle, waiting for the next call to arrive.
class SessionWaiting extends SessionState {
  const SessionWaiting();
}

/// An incoming call is ringing; the agent can answer or reject.
class SessionIncoming extends SessionState {
  const SessionIncoming();
}

/// Call is live. [listening] flips true when capture starts at connect —
/// transcription is automatic from call connect (PRD §6).
class SessionConnected extends SessionState {
  final int seconds;
  final bool muted;
  final bool speakerOn;
  final bool listening;

  const SessionConnected({
    this.seconds = 0,
    this.muted = false,
    this.speakerOn = true,
    this.listening = false,
  });

  SessionConnected copyWith({
    int? seconds,
    bool? muted,
    bool? speakerOn,
    bool? listening,
  }) => SessionConnected(
    seconds: seconds ?? this.seconds,
    muted: muted ?? this.muted,
    speakerOn: speakerOn ?? this.speakerOn,
    listening: listening ?? this.listening,
  );

  @override
  List<Object?> get props => [seconds, muted, speakerOn, listening];
}

/// Call finished; carries the assembled summary for the recap view.
class SessionEnded extends SessionState {
  final CallsModel summary;

  const SessionEnded(this.summary);

  @override
  List<Object?> get props => [summary];
}
