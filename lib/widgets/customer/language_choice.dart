import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// A two-option segmented toggle for the customer to pick the call language
/// **before** placing the call. The choice ('ar' | 'en') becomes the
/// transcription language for both sides, so each option shows its own endonym
/// (العربية / English) — unambiguous regardless of the UI locale.
class LanguageChoice extends StatelessWidget {
  /// Selected language code: 'ar' or 'en'.
  final String value;
  final ValueChanged<String> onChanged;

  const LanguageChoice({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: 'العربية',
            arabic: true,
            selected: value == 'ar',
            onTap: () => onChanged('ar'),
          ),
          const SizedBox(width: 4),
          _Segment(
            label: 'English',
            arabic: false,
            selected: value == 'en',
            onTap: () => onChanged('en'),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool arabic;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.arabic,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.neonCyan.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? AppColors.neonCyan : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.ui(
            arabic: arabic,
            size: 14,
            weight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }
}
