import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../../models/chat_message.dart';

/// One chat bubble. The viewer's own messages align end (right in LTR) with a
/// neon tint; the other party aligns start with a cyan label. Mirrors the
/// transcript bubble so chat feels like a sibling of the call surface.
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  /// True if the viewer of this bubble is the agent. Determines which side is
  /// "you" (neon, end-aligned) vs "them" (cyan, start-aligned).
  final bool viewerIsAgent;

  const ChatBubble({
    super.key,
    required this.message,
    required this.viewerIsAgent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ar = isArabic(context);
    final isSelf = viewerIsAgent ? message.isAgent : message.isCustomer;

    final selfLabel = langText(context, 'You', 'أنت');
    final otherLabel = viewerIsAgent
        ? langText(context, 'Customer', 'العميل')
        : langText(context, 'Agent', 'الموظف');

    return Align(
      alignment: isSelf
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Column(
        crossAxisAlignment: isSelf
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            (isSelf ? selfLabel : otherLabel).toUpperCase(),
            style: AppTextStyles.mono(
              size: 10,
              color: isSelf ? AppColors.neon : AppColors.neonCyan,
              letterSpacing: 0.16 * 10,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelf
                  ? AppColors.neon.withValues(alpha: 0.12)
                  : colors.bgElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelf
                    ? AppColors.neon.withValues(alpha: 0.25)
                    : colors.borderSubtle,
              ),
            ),
            child: Text(
              message.text,
              style: AppTextStyles.ui(
                arabic: ar,
                size: 14,
                color: colors.fgPrimary,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
