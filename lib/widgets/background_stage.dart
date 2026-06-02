import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// The ambient background glow (`.bg-stage`): two soft radial gradients in the
/// neon indigo and cyan, top-left and bottom-right.
class BackgroundStage extends StatelessWidget {
  const BackgroundStage({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.6, -0.8),
                radius: 1.1,
                colors: [
                  AppColors.neon.withValues(alpha: 0.12),
                  AppColors.neon.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.7, 0.8),
                radius: 1.0,
                colors: [
                  AppColors.neonCyan.withValues(alpha: 0.10),
                  AppColors.neonCyan.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
