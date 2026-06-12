import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/webrtc_config.dart';
import '../../../models/chat_message.dart';
import '../../../services/firestore/chat_repository.dart';
import '../../../services/socket/signaling_service.dart';

part 'agent_chat_state.dart';

/// Drives the agent-side chat page.
///
/// When [_signaling] and [_repo] are provided (real mode), the agent connects
/// to `/signal` as `agent`, waits for the customer's `chat_hello` (carrying the
/// `chatId` created by the customer in Firestore), then sends/receives
/// `chat_message` frames live. With no services it falls back to a scripted mock
/// (no real-time, no Firestore) so the page is demoable in isolation.
class AgentChatCubit extends Cubit<AgentChatState> {
  AgentChatCubit({
    SignalingService? signaling,
    ChatRepository? repo,
    String agentId = 'agent_demo',
  }) : _signaling = signaling,
       _repo = repo,
       _agentId = agentId,
       super(const AgentChatInitial());

  final SignalingService? _signaling;
  final ChatRepository? _repo;
  final String _agentId;
  StreamSubscription<Map<String, dynamic>>? _sigSub;

  bool get _real => _signaling != null && _repo != null;

  /// Open the signaling socket and wait for a customer.
  Future<void> begin() async {
    if (!_real) return _beginMock();
    emit(const AgentChatWaiting());
    _sigSub ??= _signaling!.messages.listen(_onSignal);
    _signaling!.connect(WebRtcConfig.signalingUrl(role: 'agent'));
  }

  Future<void> _onSignal(Map<String, dynamic> msg) async {
    switch (msg['type']) {
      case 'chat_hello':
        final chatId = msg['chatId'] as String? ?? '';
        if (chatId.isEmpty) return;
        if (state is! AgentChatWaiting && state is! AgentChatInitial) return;
        // Attach the agent's id to the customer-created chats doc.
        _repo!.attachAgent(chatId, _agentId).catchError((
          Object e,
          StackTrace st,
        ) {
          debugPrint('AgentChatCubit.attachAgent failed: $e\n$st');
        });
        emit(AgentChatInChat(chatId: chatId));
      case 'chat_message':
        _appendInbound(msg);
      case 'chat_end':
        // Customer should not end the chat (FR-8), but if signaling ever sends
        // it, surface a clean ended state with no resolved flag flipped.
        emit(const AgentChatEnded(resolved: false));
    }
  }

  void _appendInbound(Map<String, dynamic> msg) {
    final s = state;
    if (s is! AgentChatInChat) return;
    final m = ChatMessage(
      sender: msg['sender'] as String? ?? 'customer',
      text: msg['text'] as String? ?? '',
      sentAt: DateTime.tryParse(msg['at'] as String? ?? '') ?? DateTime.now(),
    );
    emit(s.copyWith(messages: List.unmodifiable([...s.messages, m])));
  }

  /// Agent is typing; updates the draft so the composer is state-driven.
  void updateDraft(String text) {
    final s = state;
    if (s is AgentChatInChat) emit(s.copyWith(draft: text));
  }

  /// Agent sends a message — broadcast over signaling and persist to Firestore.
  Future<void> sendMessage(String text) async {
    final s = state;
    if (s is! AgentChatInChat) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final m = ChatMessage(
      sender: 'agent',
      text: trimmed,
      sentAt: DateTime.now().toUtc(),
    );
    emit(
      s.copyWith(messages: List.unmodifiable([...s.messages, m]), draft: ''),
    );
    if (_real) {
      _signaling!.send({
        'type': 'chat_message',
        'sender': 'agent',
        'text': trimmed,
        'at': m.sentAt!.toIso8601String(),
      });
      _persistMessage(s.chatId, m);
    }
  }

  void _persistMessage(String chatId, ChatMessage m) {
    _repo!.appendMessage(chatId, m).catchError((Object e, StackTrace st) {
      debugPrint('AgentChatCubit.appendMessage failed: $e\n$st');
    });
  }

  /// Agent presses End Chat → open the "Problem resolved?" popup.
  void requestEnd() {
    final s = state;
    if (s is AgentChatInChat) {
      emit(
        AgentChatEndingPrompt(
          chatId: s.chatId,
          messages: s.messages,
        ),
      );
    }
  }

  /// User dismissed the popup without confirming — back to the live chat.
  void cancelEnd() {
    final s = state;
    if (s is AgentChatEndingPrompt) {
      emit(
        AgentChatInChat(
          chatId: s.chatId,
          messages: s.messages,
        ),
      );
    }
  }

  /// Agent confirmed the popup. Patches `chats` and signals the customer.
  Future<void> confirmEnd({required bool resolved}) async {
    final s = state;
    final chatId = switch (s) {
      AgentChatEndingPrompt() => s.chatId,
      AgentChatInChat() => s.chatId,
      _ => '',
    };
    if (chatId.isEmpty) {
      emit(AgentChatEnded(resolved: resolved));
      return;
    }
    if (_real) {
      _signaling!.send({'type': 'chat_end', 'resolved': resolved});
      _repo!.endChat(chatId, resolved: resolved).catchError((
        Object e,
        StackTrace st,
      ) {
        debugPrint('AgentChatCubit.endChat failed: $e\n$st');
      });
    }
    emit(AgentChatEnded(resolved: resolved));
  }

  // ── Mock fallback ──────────────────────────────────────────────────────────
  void _beginMock() {
    emit(const AgentChatWaiting());
    Timer(const Duration(seconds: 1), () {
      if (state is AgentChatWaiting) {
        emit(
          const AgentChatInChat(
            chatId: 'mock_chat',
            messages: [],
          ),
        );
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
