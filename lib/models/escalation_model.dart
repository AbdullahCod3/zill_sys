import 'package:equatable/equatable.dart';

import '../core/utils/json_time.dart';

/// Firestore `escalations/{escalationId}` (PRD §10).
class EscalationModel extends Equatable {
  final String escalationId;
  final String callId;
  final String agentId;
  final String customerId;
  final String supervisorId;
  final String reason; // anger_threshold / manager_request
  final DateTime? triggeredAt;
  final String agentAction; // confirmed / dismissed
  final DateTime? resolvedAt;

  const EscalationModel({
    required this.escalationId,
    required this.callId,
    required this.agentId,
    required this.customerId,
    required this.supervisorId,
    required this.reason,
    this.triggeredAt,
    this.agentAction = '',
    this.resolvedAt,
  });

  factory EscalationModel.fromJson(Map<String, dynamic> json, {String? id}) =>
      EscalationModel(
        escalationId: id ?? json['escalation_id'] as String? ?? '',
        callId: json['call_id'] as String? ?? '',
        agentId: json['agent_id'] as String? ?? '',
        customerId: json['customer_id'] as String? ?? '',
        supervisorId: json['supervisor_id'] as String? ?? '',
        reason: json['reason'] as String? ?? '',
        triggeredAt: parseTimestamp(json['triggered_at']),
        agentAction: json['agent_action'] as String? ?? '',
        resolvedAt: parseTimestamp(json['resolved_at']),
      );

  Map<String, dynamic> toJson() => {
    'call_id': callId,
    'agent_id': agentId,
    'customer_id': customerId,
    'supervisor_id': supervisorId,
    'reason': reason,
    'triggered_at': dateTimeToJson(triggeredAt),
    'agent_action': agentAction,
    'resolved_at': dateTimeToJson(resolvedAt),
  };

  EscalationModel copyWith({
    String? escalationId,
    String? callId,
    String? agentId,
    String? customerId,
    String? supervisorId,
    String? reason,
    DateTime? triggeredAt,
    String? agentAction,
    DateTime? resolvedAt,
  }) => EscalationModel(
    escalationId: escalationId ?? this.escalationId,
    callId: callId ?? this.callId,
    agentId: agentId ?? this.agentId,
    customerId: customerId ?? this.customerId,
    supervisorId: supervisorId ?? this.supervisorId,
    reason: reason ?? this.reason,
    triggeredAt: triggeredAt ?? this.triggeredAt,
    agentAction: agentAction ?? this.agentAction,
    resolvedAt: resolvedAt ?? this.resolvedAt,
  );

  @override
  List<Object?> get props => [
    escalationId,
    callId,
    agentId,
    customerId,
    supervisorId,
    reason,
    triggeredAt,
    agentAction,
    resolvedAt,
  ];
}
