import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../common/grid_overlay.dart';

/// A home-screen role choice (Employee / Customer). Hover lifts the card and
/// glows in [accent]; a faint grid sits behind the content.
class RoleCard extends StatefulWidget {
  final String number; // "01" / "02"
  final String title;
  final Color accent;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.number,
    required this.title,
    required this.accent,
    required this.onTap,
  });

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ar = isArabic(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppMotion.base,
          curve: AppMotion.easeOut,
          transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
          decoration: BoxDecoration(
            color: colors.bgSurface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: _hover ? widget.accent : colors.borderDefault,
            ),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: widget.accent.withValues(alpha: 0.25),
                      blurRadius: 28,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: Stack(
              children: [
                Positioned.fill(child: GridOverlay(color: colors.grid)),
                Row(
                  children: [
                    Text(
                      widget.number,
                      style: AppTextStyles.mono(
                        size: 14,
                        color: widget.accent,
                        letterSpacing: 0.1 * 14,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppTextStyles.display(
                          arabic: ar,
                          size: 24,
                          weight: FontWeight.w600,
                          color: colors.fgPrimary,
                          height: 1.2,
                          letterSpacing: -0.01 * 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Icon(
                      ar ? Icons.arrow_back : Icons.arrow_forward,
                      size: 22,
                      color: _hover ? widget.accent : colors.fgTertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
