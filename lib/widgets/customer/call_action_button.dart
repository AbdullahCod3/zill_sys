import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// In-call control pill (mute / speaker / keypad) on the customer phone screen.
/// White-on-translucent; flips to a solid cyan when [active].
class CallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const CallActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.void_ : Colors.white;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: active
                ? AppColors.neonCyan
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(
              color: active
                  ? AppColors.neonCyan
                  : Colors.white.withValues(alpha: 0.1),
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.5),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.ui(arabic: false, size: 11, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
