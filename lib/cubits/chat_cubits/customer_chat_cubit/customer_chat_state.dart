part of 'customer_chat_cubit.dart';

/// Customer-side chat lifecycle: idle → connecting → inChat → ended.
sealed class CustomerChatState extends Equatable {
  const CustomerChatState();

  @override
  List<Object?> get props => [];
}

/// Pre-chat screen.
class CustomerChatIdle extends CustomerChatState {
  const CustomerChatIdle();
}

/// Customer pressed Start — waiting for the agent to be present so the
/// signaling relay can forward the `chat_hello`.
class CustomerChatConnecting extends CustomerChatState {
  const CustomerChatConnecting();
}

/// Live chat. [messages] is append-only.
class CustomerChatInChat extends CustomerChatState {
  final String chatId;
  final List<ChatMessage> messages;
  final String draft;

  const CustomerChatInChat({
    required this.chatId,
    this.messages = const [],
    this.draft = '',
  });

  CustomerChatInChat copyWith({
    String? chatId,
    List<ChatMessage>? messages,
    String? draft,
  }) => CustomerChatInChat(
    chatId: chatId ?? this.chatId,
    messages: messages ?? this.messages,
    draft: draft ?? this.draft,
  );

  @override
  List<Object?> get props => [chatId, messages, draft];
}

/// Agent ended the chat; carries the resolved flag so the customer screen can
/// reflect it. The customer never sees a "Problem resolved?" popup.
class CustomerChatEnded extends CustomerChatState {
  final bool resolved;

  const CustomerChatEnded({required this.resolved});

  @override
  List<Object?> get props => [resolved];
}
