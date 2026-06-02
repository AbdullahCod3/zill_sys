import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Small monospace pill button used in the app bar (lang/theme/role-back).
/// Borders/text shift to neon on hover, matching the prototype.
class PillButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Widget? leading;

  const PillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.leading,
  });

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = _hover ? AppColors.neon : colors.fgSecondary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: colors.bgSurface,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: _hover ? AppColors.neon : colors.borderDefault,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: AppTextStyles.mono(size: 12, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
