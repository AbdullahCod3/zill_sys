import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/analysis_result.dart';
import '../../../models/enums.dart';
import '../../../services/demo/demo_script_service.dart';
import '../../../services/demo/mock_analysis_service.dart';

part 'answer_state.dart';

/// Produces the grounded suggested answer + candidate replies for the cockpit.
/// One structured call per cycle (rule #3); content comes from the mock service.
class AnswerCubit extends Cubit<AnswerState> {
  AnswerCubit(this._analysis) : super(const AnswerInitial());

  final MockAnalysisService _analysis;

  Future<void> fetch({
    required Mood mood,
    required bool arabic,
    String transcriptText = '',
  }) async {
    emit(const AnswerLoading());
    try {
      final result = await _analysis.analyze(
        mood: mood,
        arabic: arabic,
        transcriptText: transcriptText,
      );
      emit(AnswerLoaded(result, round: 0));
    } catch (e) {
      emit(AnswerError(e.toString()));
    }
  }

  /// "Don't use — re-read the call": Shadow re-analyses and returns a fresh
  /// suggestion set. Rounds cycle so the agent can re-read repeatedly.
  Future<void> reRead({required Mood mood, required bool arabic}) async {
    final current = state;
    final nextRound = current is AnswerLoaded
        ? (current.round + 1) % DemoScriptService.roundCount
        : 0;
    emit(const AnswerLoading());
    try {
      final result = await _analysis.analyze(
        mood: mood,
        arabic: arabic,
        round: nextRound,
      );
      emit(AnswerLoaded(result, round: nextRound));
    } catch (e) {
      emit(AnswerError(e.toString()));
    }
  }

  /// Agent selects one of the suggested replies.
  void select(int index) {
    final s = state;
    if (s is AnswerLoaded) emit(s.copyWith(selectedIndex: index));
  }

  void reset() => emit(const AnswerInitial());
}
