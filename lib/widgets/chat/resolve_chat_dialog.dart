import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';

/// "Problem resolved?" popup shown when the agent presses End Chat (FR-8).
/// Returns `true` on **Yes, resolved**, `false` on **No, unresolved**, and
/// `null` if dismissed (treated as cancel by the caller).
class ResolveChatDialog extends StatelessWidget {
  const ResolveChatDialog({super.key});

  static Future<bool?> show(BuildContext context) => showDialog<bool>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => const ResolveChatDialog(),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ar = isArabic(context);

    return Dialog(
      backgroundColor: colors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        side: BorderSide(color: AppColors.neon.withValues(alpha: 0.5)),
      ),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.task_alt_outlined, color: AppColors.neon),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.resolveTitle.resolve(context),
                    style: AppTextStyles.display(
                      arabic: ar,
                      size: 24,
                      weight: FontWeight.w700,
                      color: colors.fgPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.resolveBody.resolve(context),
              style: AppTextStyles.ui(
                arabic: ar,
                size: 14,
                color: colors.fgSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: AppStrings.noUnresolved.resolve(context),
                    onTap: () => Navigator.of(context).pop(false),
                    filled: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: AppStrings.yesResolved.resolve(context),
                    onTap: () => Navigator.of(context).pop(true),
                    filled: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _DialogButton({
    required this.label,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? AppColors.neon : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: filled ? AppColors.neon : colors.borderDefault,
            ),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: AppColors.neon.withValues(alpha: 0.35),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTextStyles.ui(
              arabic: isArabic(context),
              size: 14,
              weight: FontWeight.w500,
              color: filled ? Colors.white : colors.fgPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
