import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../common/grid_overlay.dart';

/// Channel chooser card (Call / Chat) shown after the user picks a role.
/// Mirrors [RoleCard]'s feel: faint grid, hover lift + accent glow.
class ChannelCard extends StatefulWidget {
  final String number; // "01" / "02"
  final String title; // "Call" / "Chat"
  final String subtitle; // one-line description
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const ChannelCard({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  State<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<ChannelCard> {
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
          padding: const EdgeInsets.all(AppSpacing.s6),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.number,
                          style: AppTextStyles.mono(
                            size: 12,
                            color: widget.accent,
                            letterSpacing: 0.1 * 12,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          widget.icon,
                          color: _hover ? widget.accent : colors.fgTertiary,
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    Text(
                      widget.title,
                      style: AppTextStyles.display(
                        arabic: ar,
                        size: 28,
                        weight: FontWeight.w600,
                        color: colors.fgPrimary,
                        height: 1.15,
                        letterSpacing: -0.01 * 28,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      widget.subtitle,
                      style: AppTextStyles.ui(
                        arabic: ar,
                        size: 13,
                        color: colors.fgSecondary,
                        height: 1.5,
                      ),
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
