import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Round gradient avatar with a person silhouette and optional expanding rings.
class CallAvatar extends StatefulWidget {
  final double size;
  final bool showRings;

  const CallAvatar({super.key, this.size = 120, this.showRings = false});

  @override
  State<CallAvatar> createState() => _CallAvatarState();
}

class _CallAvatarState extends State<CallAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ringField = widget.size * 1.7;
    return SizedBox(
      width: ringField,
      height: ringField,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.showRings)
            for (final delay in [0.0, 0.27, 0.54])
              AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  final v = (_c.value + delay) % 1;
                  return Opacity(
                    opacity: (1 - v) * 0.6,
                    child: Container(
                      width: widget.size + v * widget.size * 0.7,
                      height: widget.size + v * widget.size * 0.7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.neonCyan.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  );
                },
              ),
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.neonCyan, AppColors.neon],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.5),
                  blurRadius: 40,
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              size: widget.size * 0.5,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
