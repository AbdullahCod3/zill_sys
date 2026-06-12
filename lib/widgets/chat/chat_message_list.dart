import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../../models/chat_message.dart';
import 'chat_bubble.dart';

/// Scrollable list of chat bubbles. Auto-scrolls to the newest message
/// whenever the list grows. Shows an empty hint when the chat just started.
class ChatMessageList extends StatefulWidget {
  final List<ChatMessage> messages;
  final bool viewerIsAgent;
  final String emptyHint;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.viewerIsAgent,
    required this.emptyHint,
  });

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final _controller = ScrollController();

  @override
  void didUpdateWidget(covariant ChatMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_controller.hasClients) return;
        _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: AppMotion.base,
          curve: AppMotion.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s6),
          child: Text(
            widget.emptyHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.ui(
              arabic: isArabic(context),
              size: 14,
              color: context.colors.fgTertiary,
              height: 1.6,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      controller: _controller,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s4,
        vertical: AppSpacing.s4,
      ),
      itemCount: widget.messages.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s3),
      itemBuilder: (_, i) => ChatBubble(
        message: widget.messages[i],
        viewerIsAgent: widget.viewerIsAgent,
      ),
    );
  }
}
