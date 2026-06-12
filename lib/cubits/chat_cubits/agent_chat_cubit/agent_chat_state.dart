part of 'agent_chat_cubit.dart';

/// Agent-side chat lifecycle: initial → waiting → inChat → endingPrompt → ended.
sealed class AgentChatState extends Equatable {
  const AgentChatState();

  @override
  List<Object?> get props => [];
}

class AgentChatInitial extends AgentChatState {
  const AgentChatInitial();
}

/// Agent is online; no customer has joined the chat yet.
class AgentChatWaiting extends AgentChatState {
  const AgentChatWaiting();
}

/// Live chat. [messages] is append-only and immutable per emit.
class AgentChatInChat extends AgentChatState {
  final String chatId;
  final List<ChatMessage> messages;
  final String draft;

  const AgentChatInChat({
    required this.chatId,
    this.messages = const [],
    this.draft = '',
  });

  AgentChatInChat copyWith({
    String? chatId,
    List<ChatMessage>? messages,
    String? draft,
  }) => AgentChatInChat(
    chatId: chatId ?? this.chatId,
    messages: messages ?? this.messages,
    draft: draft ?? this.draft,
  );

  @override
  List<Object?> get props => [chatId, messages, draft];
}

/// Agent pressed End Chat → "Problem resolved?" popup is open.
class AgentChatEndingPrompt extends AgentChatState {
  final String chatId;
  final List<ChatMessage> messages;

  const AgentChatEndingPrompt({
    required this.chatId,
    required this.messages,
  });

  @override
  List<Object?> get props => [chatId, messages];
}

/// Chat ended; [resolved] captured from the popup.
class AgentChatEnded extends AgentChatState {
  final bool resolved;

  const AgentChatEnded({required this.resolved});

  @override
  List<Object?> get props => [resolved];
}
