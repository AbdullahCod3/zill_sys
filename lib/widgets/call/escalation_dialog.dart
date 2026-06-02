import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../../models/supervisor_model.dart';

/// One-tap escalation dialog naming the resolved [supervisor] (PRD §5/§13).
/// Returns `true` on Confirm Transfer, `false`/`null` on Dismiss.
class EscalationDialog extends StatelessWidget {
  final SupervisorModel supervisor;

  const EscalationDialog({super.key, required this.supervisor});

  static Future<bool?> show(BuildContext context, SupervisorModel supervisor) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => EscalationDialog(supervisor: supervisor),
    );
  }

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
                const Icon(
                  Icons.escalator_warning_outlined,
                  color: AppColors.neon,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.escalationTitle.resolve(context),
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
              AppStrings.escalationBody.resolve(context),
              style: AppTextStyles.ui(
                arabic: ar,
                size: 14,
                color: colors.fgSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            // Supervisor card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.bgBase,
                borderRadius: BorderRadius.circular(AppRadii.lg),
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
                        supervisor.name,
                        style: AppTextStyles.ui(
                          arabic: ar,
                          size: 16,
                          weight: FontWeight.w600,
                          color: colors.fgPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${AppStrings.supervisor.resolve(context)} · ${supervisor.department}',
                        style: AppTextStyles.mono(
                          size: 11,
                          color: colors.fgTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: AppStrings.dismiss.resolve(context),
                    onTap: () => Navigator.of(context).pop(false),
                    filled: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: AppStrings.confirmTransfer.resolve(context),
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
