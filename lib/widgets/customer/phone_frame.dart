import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// The phone device chrome — bezel, status notch with dynamic island, screen
/// body with a soft cyan glow, and the home indicator. [child] is the screen.
class PhoneFrame extends StatelessWidget {
  final Widget child;

  const PhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 720,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.void_,
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: const Color(0x3DFFFFFF)),
        boxShadow: [
          const BoxShadow(
            color: Color(0x80000000),
            blurRadius: 80,
            offset: Offset(0, 40),
          ),
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.12),
            blurRadius: 60,
          ),
        ],
      ),
      child: Column(
        children: [
          _StatusNotch(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A1A26), Color(0xFF0E0E16)],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0, -0.4),
                            radius: 0.9,
                            colors: [
                              AppColors.neonCyan.withValues(alpha: 0.18),
                              AppColors.neonCyan.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 28,
                      ),
                      child: child,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 6,
            width: 120,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusNotch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '9:41',
                  style: AppTextStyles.ui(
                    arabic: false,
                    size: 14,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '5G',
                      style: AppTextStyles.mono(size: 9, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '●●●',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 6,
            child: Container(
              width: 80,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
