import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/chat_message.dart';
import '../../models/chat_model.dart';

/// The only Firestore touch point for the chat feature. Cubits call this; they
/// never touch [FirebaseFirestore.instance] directly. Future M12 work
/// (end-of-chat Gemini summary → `previous_issues`) extends this class.
class ChatRepository {
  ChatRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _db.collection('chats');

  CollectionReference<Map<String, dynamic>> _messagesOf(String chatId) =>
      _chats.doc(chatId).collection('messages');

  /// Creates a new active `chats/{chatId}` doc.
  ///
  /// Only the customer side calls this on Connect (see PRD §6 chat flow);
  /// the chat id is then broadcast to the agent over the signaling relay.
  Future<ChatModel> createChat({
    required String customerId,
    String agentId = '',
  }) async {
    final now = DateTime.now().toUtc();
    final ref = _chats.doc();
    final chat = ChatModel(
      chatId: ref.id,
      agentId: agentId,
      customerId: customerId,
      status: 'active',
      resolved: false,
      startedAt: now,
    );
    await ref.set(chat.toJson(), SetOptions(merge: true));
    return chat;
  }

  /// Appends a message to the chat's `messages` subcollection.
  /// Stamps `sentAt` with server time if the caller did not.
  Future<void> appendMessage(String chatId, ChatMessage message) async {
    final ref = _messagesOf(chatId).doc();
    final payload = message
        .copyWith(sentAt: message.sentAt ?? DateTime.now().toUtc())
        .toJson();
    await ref.set(payload, SetOptions(merge: true));
  }

  /// Agent-only end: patches the chat doc with `ended_at` + `resolved` + status.
  /// The Gemini summary → `previous_issues` write is M12.
  Future<void> endChat(String chatId, {required bool resolved}) async {
    await _chats.doc(chatId).set({
      'status': 'ended',
      'resolved': resolved,
      'ended_at': DateTime.now().toUtc().toIso8601String(),
    }, SetOptions(merge: true));
  }

  /// Patches `agent_id` once the agent attaches to a customer-created chat.
  Future<void> attachAgent(String chatId, String agentId) async {
    await _chats.doc(chatId).set({'agent_id': agentId}, SetOptions(merge: true));
  }
}
