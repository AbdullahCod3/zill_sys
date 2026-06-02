part of 'answer_cubit.dart';

sealed class AnswerState extends Equatable {
  const AnswerState();

  @override
  List<Object?> get props => [];
}

/// Before Get Answer is pressed.
class AnswerInitial extends AnswerState {
  const AnswerInitial();
}

/// Shadow is "thinking" (retrieval + structured call).
class AnswerLoading extends AnswerState {
  const AnswerLoading();
}

/// Suggested answer ready. [selectedIndex] is the reply the agent picked
/// (null until they choose one). [round] is the suggestion set shown (0-based);
/// > 0 means the agent re-read the call for fresh suggestions.
class AnswerLoaded extends AnswerState {
  final AnalysisResult result;
  final int? selectedIndex;
  final int round;

  const AnswerLoaded(this.result, {this.selectedIndex, this.round = 0});

  AnswerLoaded copyWith({int? selectedIndex, int? round}) => AnswerLoaded(
    result,
    selectedIndex: selectedIndex ?? this.selectedIndex,
    round: round ?? this.round,
  );

  @override
  List<Object?> get props => [result, selectedIndex, round];
}

/// Retrieval/analysis failed.
class AnswerError extends AnswerState {
  final String message;

  const AnswerError(this.message);

  @override
  List<Object?> get props => [message];
}
