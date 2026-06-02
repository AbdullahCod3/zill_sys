import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../models/analysis_result.dart';
import '../../../models/enums.dart';
import '../../../models/supervisor_model.dart';

part 'escalation_state.dart';

/// Watches each analysis result and fires a one-time anger/escalation alert
/// (PRD §13, rule #6). There is no persistent meter; [_alertFired] suppresses
/// repeat fires within a call.
class EscalationCubit extends Cubit<EscalationState> {
  EscalationCubit() : super(const EscalationIdle());

  bool _alertFired = false;

  /// True once the alert has fired this call.
  bool get alertFired => _alertFired;

  /// Evaluate a fresh result. Fires once if anger ≥ threshold OR the customer
  /// explicitly requested a manager.
  void evaluate(AnalysisResult result, SupervisorModel supervisor) {
    if (_alertFired) return;
    final angerCrossed = result.angerScore >= AppConfig.angerThreshold;
    if (!angerCrossed && !result.escalationRequested) return;

    _alertFired = true;
    emit(
      EscalationAlert(
        supervisor: supervisor,
        reason: result.escalationRequested
            ? EscalationReason.managerRequest
            : EscalationReason.angerThreshold,
      ),
    );
  }

  void confirm() {
    final s = state;
    if (s is EscalationAlert) emit(EscalationConfirmed(s.supervisor));
  }

  void dismiss() {
    if (state is EscalationAlert) emit(const EscalationDismissed());
  }

  /// Whether this call ended up escalated (Confirm Transfer pressed).
  bool get escalated => state is EscalationConfirmed;

  void reset() {
    _alertFired = false;
    emit(const EscalationIdle());
  }
}
