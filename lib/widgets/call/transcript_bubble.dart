import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../../models/enums.dart';
import '../../models/transcript_line.dart';

/// One chat bubble in the live transcript. Customer left (cyan label), agent
/// right (neon label, tinted bubble).
class TranscriptBubble extends StatelessWidget {
  final TranscriptLine line;

  const TranscriptBubble({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ar = isArabic(context);
    final isCustomer = line.speaker == Speaker.customer;
    final who = isCustomer
        ? langText(context, 'Customer', 'العميل')
        : langText(context, 'You', 'أنت');

    return Align(
      alignment: isCustomer
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: Column(
        crossAxisAlignment: isCustomer
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            who.toUpperCase(),
            style: AppTextStyles.mono(
              size: 10,
              color: isCustomer ? AppColors.neonCyan : AppColors.neon,
              letterSpacing: 0.16 * 10,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isCustomer
                  ? colors.bgElevated
                  : AppColors.neon.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCustomer
                    ? colors.borderSubtle
                    : AppColors.neon.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              line.text,
              style: AppTextStyles.ui(
                arabic: ar,
                size: 13,
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
