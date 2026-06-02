part of 'escalation_cubit.dart';

sealed class EscalationState extends Equatable {
  const EscalationState();

  @override
  List<Object?> get props => [];
}

/// No escalation condition met.
class EscalationIdle extends EscalationState {
  const EscalationIdle();
}

/// Alert fired (anger threshold crossed or manager requested). The dialog can
/// open naming [supervisor]; fires once per call (rule #6).
class EscalationAlert extends EscalationState {
  final SupervisorModel supervisor;
  final EscalationReason reason;

  const EscalationAlert({required this.supervisor, required this.reason});

  @override
  List<Object?> get props => [supervisor, reason];
}

/// Agent confirmed the transfer.
class EscalationConfirmed extends EscalationState {
  final SupervisorModel supervisor;

  const EscalationConfirmed(this.supervisor);

  @override
  List<Object?> get props => [supervisor];
}

/// Agent dismissed the alert; the call continues.
class EscalationDismissed extends EscalationState {
  const EscalationDismissed();
}
