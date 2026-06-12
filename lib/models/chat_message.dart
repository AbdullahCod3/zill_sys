import 'package:equatable/equatable.dart';

import '../core/utils/json_time.dart';

/// Firestore `chats/{chatId}/messages/{messageId}` (PRD §10).
class ChatMessage extends Equatable {
  final String messageId;
  final String sender; // 'agent' | 'customer'
  final String text;
  final DateTime? sentAt;

  const ChatMessage({
    this.messageId = '',
    required this.sender,
    required this.text,
    this.sentAt,
  });

  bool get isAgent => sender == 'agent';
  bool get isCustomer => sender == 'customer';

  factory ChatMessage.fromJson(Map<String, dynamic> json, {String? id}) =>
      ChatMessage(
        messageId: id ?? json['message_id'] as String? ?? '',
        sender: json['sender'] as String? ?? 'customer',
        text: json['text'] as String? ?? '',
        sentAt: parseTimestamp(json['sent_at']),
      );

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'text': text,
    'sent_at': dateTimeToJson(sentAt),
  };

  ChatMessage copyWith({
    String? messageId,
    String? sender,
    String? text,
    DateTime? sentAt,
  }) => ChatMessage(
    messageId: messageId ?? this.messageId,
    sender: sender ?? this.sender,
    text: text ?? this.text,
    sentAt: sentAt ?? this.sentAt,
  );

  @override
  List<Object?> get props => [messageId, sender, text, sentAt];
}
