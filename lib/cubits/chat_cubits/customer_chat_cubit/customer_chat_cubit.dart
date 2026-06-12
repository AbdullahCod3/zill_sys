import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/webrtc_config.dart';
import '../../../models/chat_message.dart';
import '../../../models/chat_model.dart';
import '../../../services/firestore/chat_repository.dart';
import '../../../services/socket/signaling_service.dart';

part 'customer_chat_state.dart';

/// Drives the customer-side chat page.
///
/// Real mode: opens `/signal` as `customer`; once both peers are in the room the
/// backend sends `peer-ready` to both — at that point the customer creates the
/// `chats/{chatId}` doc in Firestore and broadcasts `chat_hello` so the agent
/// can attach. Messages are then exchanged via `chat_message` frames and also
/// persisted to the `messages` subcollection. End-of-chat is agent-only
/// (FR-8); the customer transitions to `Ended` when it receives `chat_end`.
class CustomerChatCubit extends Cubit<CustomerChatState> {
  CustomerChatCubit({
    SignalingService? signaling,
    ChatRepository? repo,
    String customerId = 'customer_demo',
  }) : _signaling = signaling,
       _repo = repo,
       _customerId = customerId,
       super(const CustomerChatIdle());

  final SignalingService? _signaling;
  final ChatRepository? _repo;
  final String _customerId;
  StreamSubscription<Map<String, dynamic>>? _sigSub;

  bool get _real => _signaling != null && _repo != null;

  /// Customer presses Start.
  Future<void> start() async {
    if (!_real) return _startMock();

    emit(const CustomerChatConnecting());
    _sigSub ??= _signaling!.messages.listen(_onSignal);
    _signaling!.connect(WebRtcConfig.signalingUrl(role: 'customer'));
  }

  Future<void> _onSignal(Map<String, dynamic> msg) async {
    switch (msg['type']) {
      case 'peer-ready':
        // Agent is in the room — create the chats doc and announce ourselves.
        final s = state;
        if (s is! CustomerChatConnecting) return;
        try {
          final ChatModel chat = await _repo!.createChat(
            customerId: _customerId,
          );
          _signaling!.send({
            'type': 'chat_hello',
            'chatId': chat.chatId,
          });
          emit(CustomerChatInChat(chatId: chat.chatId));
        } catch (e, st) {
          // Surface the actual Firestore error in the dev console so config
          // issues (rules / missing database) are diagnosable. Then fall back
          // to a local-only chat so the demo doesn't dead-end.
          debugPrint('CustomerChatCubit.createChat failed: $e\n$st');
          final fallbackId = 'local_${DateTime.now().millisecondsSinceEpoch}';
          _signaling!.send({
            'type': 'chat_hello',
            'chatId': fallbackId,
          });
          emit(CustomerChatInChat(chatId: fallbackId));
        }
      case 'chat_message':
        _appendInbound(msg);
      case 'chat_end':
        emit(
          CustomerChatEnded(resolved: msg['resolved'] as bool? ?? false),
        );
      case 'bye':
        emit(const CustomerChatEnded(resolved: false));
    }
  }

  void _appendInbound(Map<String, dynamic> msg) {
    final s = state;
    if (s is! CustomerChatInChat) return;
    final m = ChatMessage(
      sender: msg['sender'] as String? ?? 'agent',
      text: msg['text'] as String? ?? '',
      sentAt: DateTime.tryParse(msg['at'] as String? ?? '') ?? DateTime.now(),
    );
    emit(s.copyWith(messages: List.unmodifiable([...s.messages, m])));
  }

  void updateDraft(String text) {
    final s = state;
    if (s is CustomerChatInChat) emit(s.copyWith(draft: text));
  }

  Future<void> sendMessage(String text) async {
    final s = state;
    if (s is! CustomerChatInChat) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final m = ChatMessage(
      sender: 'customer',
      text: trimmed,
      sentAt: DateTime.now().toUtc(),
    );
    emit(
      s.copyWith(messages: List.unmodifiable([...s.messages, m]), draft: ''),
    );
    if (_real) {
      _signaling!.send({
        'type': 'chat_message',
        'sender': 'customer',
        'text': trimmed,
        'at': m.sentAt!.toIso8601String(),
      });
      _persistMessage(s.chatId, m);
    }
  }

  void _persistMessage(String chatId, ChatMessage m) {
    _repo!.appendMessage(chatId, m).catchError((Object e, StackTrace st) {
      debugPrint('CustomerChatCubit.appendMessage failed: $e\n$st');
    });
  }

  // ── Mock fallback ──────────────────────────────────────────────────────────
  void _startMock() {
    emit(const CustomerChatConnecting());
    Timer(const Duration(seconds: 1), () {
      if (state is CustomerChatConnecting) {
        emit(const CustomerChatInChat(chatId: 'mock_chat'));
      }
    });
  }

  @override
  Future<void> close() {
    _sigSub?.cancel();
    _signaling?.dispose();
    return super.close();
  }
}
