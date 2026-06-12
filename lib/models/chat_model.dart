import 'package:equatable/equatable.dart';

import '../core/utils/json_time.dart';

/// Firestore `chats/{chatId}` (PRD §10).
class ChatModel extends Equatable {
  final String chatId;
  final String agentId;
  final String customerId;
  final String status; // 'active' | 'ended'
  final bool resolved;
  final DateTime? startedAt;
  final DateTime? endedAt;

  const ChatModel({
    required this.chatId,
    this.agentId = '',
    required this.customerId,
    this.status = 'active',
    this.resolved = false,
    this.startedAt,
    this.endedAt,
  });

  bool get isActive => status == 'active';
  bool get isEnded => status == 'ended';

  factory ChatModel.fromJson(Map<String, dynamic> json, {String? id}) =>
      ChatModel(
        chatId: id ?? json['chat_id'] as String? ?? '',
        agentId: json['agent_id'] as String? ?? '',
        customerId: json['customer_id'] as String? ?? '',
        status: json['status'] as String? ?? 'active',
        resolved: json['resolved'] as bool? ?? false,
        startedAt: parseTimestamp(json['started_at']),
        endedAt: parseTimestamp(json['ended_at']),
      );

  Map<String, dynamic> toJson() => {
    'agent_id': agentId,
    'customer_id': customerId,
    'status': status,
    'resolved': resolved,
    'started_at': dateTimeToJson(startedAt),
    'ended_at': dateTimeToJson(endedAt),
  };

  ChatModel copyWith({
    String? chatId,
    String? agentId,
    String? customerId,
    String? status,
    bool? resolved,
    DateTime? startedAt,
    DateTime? endedAt,
  }) => ChatModel(
    chatId: chatId ?? this.chatId,
    agentId: agentId ?? this.agentId,
    customerId: customerId ?? this.customerId,
    status: status ?? this.status,
    resolved: resolved ?? this.resolved,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
  );

  @override
  List<Object?> get props => [
    chatId,
    agentId,
    customerId,
    status,
    resolved,
    startedAt,
    endedAt,
  ];
}
