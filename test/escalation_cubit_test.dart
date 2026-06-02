import 'package:flutter_test/flutter_test.dart';
import 'package:zill_sys/cubits/call_cubits/escalation_cubit/escalation_cubit.dart';
import 'package:zill_sys/models/analysis_result.dart';
import 'package:zill_sys/models/enums.dart';
import 'package:zill_sys/models/supervisor_model.dart';

void main() {
  const supervisor = SupervisorModel(
    supervisorId: 's1',
    name: 'Maha',
    department: 'technical',
  );

  AnalysisResult result({required int anger, bool escalation = false}) =>
      AnalysisResult(
        language: 'en',
        problemSummary: '',
        suggestedAnswer: '',
        citations: const [],
        angerScore: anger,
        escalationRequested: escalation,
        confidence: Confidence.high,
      );

  group('EscalationCubit', () {
    test('fires once when anger crosses the threshold', () {
      final cubit = EscalationCubit();
      cubit.evaluate(result(anger: 8), supervisor);
      expect(cubit.state, isA<EscalationAlert>());
      expect((cubit.state as EscalationAlert).reason,
          EscalationReason.angerThreshold);

      // A second crossing must NOT re-fire (rule #6 — alertFired latch).
      cubit.dismiss();
      cubit.evaluate(result(anger: 9), supervisor);
      expect(cubit.state, isA<EscalationDismissed>());
    });

    test('does not fire below threshold and calm', () {
      final cubit = EscalationCubit();
      cubit.evaluate(result(anger: 3), supervisor);
      expect(cubit.state, isA<EscalationIdle>());
    });

    test('fires on explicit manager request even when calm', () {
      final cubit = EscalationCubit();
      cubit.evaluate(result(anger: 2, escalation: true), supervisor);
      expect(cubit.state, isA<EscalationAlert>());
      expect((cubit.state as EscalationAlert).reason,
          EscalationReason.managerRequest);
    });

    test('confirm transitions to confirmed and marks escalated', () {
      final cubit = EscalationCubit();
      cubit.evaluate(result(anger: 8), supervisor);
      cubit.confirm();
      expect(cubit.state, isA<EscalationConfirmed>());
      expect(cubit.escalated, isTrue);
    });
  });
}
