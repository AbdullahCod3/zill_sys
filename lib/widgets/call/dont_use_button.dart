import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';

/// Dashed "Don't use — re-read the call" button (prototype's `.dont-use-btn`).
/// Danger-tinted on hover; tells Shadow to re-analyse for a fresh suggestion set.
class DontUseButton extends StatefulWidget {
  final VoidCallback onTap;

  const DontUseButton({super.key, required this.onTap});

  @override
  State<DontUseButton> createState() => _DontUseButtonState();
}

class _DontUseButtonState extends State<DontUseButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final danger = _hover;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: danger ? AppColors.danger.withValues(alpha: 0.12) : null,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: danger ? AppColors.danger : colors.borderStrong,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.refresh,
                size: 16,
                color: danger ? AppColors.danger : colors.fgSecondary,
              ),
              const SizedBox(width: 10),
              Text(
                AppStrings.dontUseReRead.resolve(context),
                style: AppTextStyles.ui(
                  arabic: isArabic(context),
                  size: 13,
                  weight: FontWeight.w600,
                  color: danger ? AppColors.danger : colors.fgSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
