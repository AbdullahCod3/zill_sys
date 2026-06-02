import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

/// The home hero image (caricature) framed with neon corner brackets and a
/// soft glow, plus a floating "SHADOW · LIVE" callout.
class HeroFrame extends StatelessWidget {
  final Widget callout;

  const HeroFrame({super.key, required this.callout});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1672 / 941,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: colors.borderDefault),
              boxShadow: [
                const BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 60,
                  offset: Offset(0, 24),
                ),
                BoxShadow(
                  color: AppColors.neon.withValues(alpha: 0.15),
                  blurRadius: 60,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              child: Image.asset(
                'assets/images/caricature.png',
                fit: BoxFit.cover,
                // Degrade gracefully if the asset is unavailable (e.g. tests).
                errorBuilder: (context, error, stack) =>
                    ColoredBox(color: colors.bgElevated),
              ),
            ),
          ),
        ),
        // Corner brackets
        const _Corner(top: 10, left: 10, top_: true, left_: true),
        const _Corner(top: 10, right: 10, top_: true, right_: true),
        const _Corner(bottom: 10, left: 10, bottom_: true, left_: true),
        const _Corner(bottom: 10, right: 10, bottom_: true, right_: true),
        Positioned(top: 24, right: 24, child: callout),
      ],
    );
  }
}

class _Corner extends StatelessWidget {
  final double? top, left, right, bottom;
  final bool top_, left_, right_, bottom_;

  const _Corner({
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.top_ = false,
    this.left_ = false,
    this.right_ = false,
    this.bottom_ = false,
  });

  @override
  Widget build(BuildContext context) {
    const c = AppColors.neon;
    const w = 1.5;
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          border: Border(
            top: top_ ? const BorderSide(color: c, width: w) : BorderSide.none,
            left: left_
                ? const BorderSide(color: c, width: w)
                : BorderSide.none,
            right: right_
                ? const BorderSide(color: c, width: w)
                : BorderSide.none,
            bottom: bottom_
                ? const BorderSide(color: c, width: w)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
