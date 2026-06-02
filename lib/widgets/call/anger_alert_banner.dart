import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';

/// The one-time anger alert (PRD §13). Amber-toned banner with an Escalate CTA.
class AngerAlertBanner extends StatelessWidget {
  final VoidCallback onEscalate;

  const AngerAlertBanner({super.key, required this.onEscalate});

  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.danger,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.angerHigh.resolve(context),
              style: AppTextStyles.ui(
                arabic: ar,
                size: 13,
                color: context.colors.fgPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _EscalateButton(
            label: AppStrings.escalateToSupervisor.resolve(context),
            onTap: onEscalate,
          ),
        ],
      ),
    );
  }
}

class _EscalateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _EscalateButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Text(
            '⚠ $label',
            style: AppTextStyles.ui(
              arabic: false,
              size: 12,
              weight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
