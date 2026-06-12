import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../../core/utils/time_format.dart';
import '../common/audio_bars.dart';
import 'previous_issues_dialog.dart';

/// The agent cockpit header: customer identity + live issue + call timer, with
/// a chip that opens the customer's previous-issues popup (mock data).
class CustomerInfoStrip extends StatelessWidget {
  final String customerName;
  final int seconds;

  const CustomerInfoStrip({
    super.key,
    required this.customerName,
    required this.seconds,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ar = isArabic(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.neon, AppColors.neonCyan],
              ),
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customerName,
                style: AppTextStyles.display(
                  arabic: ar,
                  size: 22,
                  weight: FontWeight.w500,
                  color: colors.fgPrimary,
                ),
              ),
              Text(
                'ZL-447-2210 · ${langText(context, 'Fiber Pro 500', 'فايبر برو 500')}',
                style: AppTextStyles.mono(size: 11, color: colors.fgTertiary),
              ),
            ],
          ),
          const SizedBox(width: 12),
          _PreviousIssuesToggle(
            onTap: () =>
                PreviousIssuesDialog.show(context, customerName: customerName),
          ),
          const Spacer(),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.amber,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.amber, blurRadius: 10),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    langText(
                      context,
                      'Internet outage + disputed charge',
                      'انقطاع إنترنت ',
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.ui(
                      arabic: ar,
                      size: 14,
                      color: colors.fgSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Row(
            children: [
              const AudioBars(color: AppColors.neon),
              const SizedBox(width: 12),
              Text(
                formatMmss(seconds),
                style: AppTextStyles.mono(size: 18, color: colors.fgPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tappable "Previous issues" chip that opens the history popup.
class _PreviousIssuesToggle extends StatelessWidget {
  final VoidCallback onTap;

  const _PreviousIssuesToggle({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.neon.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.neon.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history, size: 16, color: AppColors.neonCyan),
              const SizedBox(width: 6),
              Text(
                AppStrings.previousIssues.resolve(context),
                style: AppTextStyles.ui(
                  arabic: ar,
                  size: 12,
                  weight: FontWeight.w600,
                  color: AppColors.neonCyan,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
