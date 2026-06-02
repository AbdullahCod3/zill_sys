part of 'transcript_cubit.dart';

sealed class TranscriptState extends Equatable {
  const TranscriptState();

  @override
  List<Object?> get props => [];
}

/// No transcript yet (call not started / not listening).
class TranscriptInitial extends TranscriptState {
  const TranscriptInitial();
}

/// Diarized lines accumulated so far, in arrival order.
class TranscriptUpdated extends TranscriptState {
  final List<TranscriptLine> lines;

  const TranscriptUpdated(this.lines);

  @override
  List<Object?> get props => [lines];
}
