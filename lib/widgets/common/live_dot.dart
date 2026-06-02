import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A small pulsing dot with a neon glow (the prototype's `.dot` / `.dot-live`).
class LiveDot extends StatefulWidget {
  final Color? color;
  final double size;

  const LiveDot({super.key, this.color, this.size = 8});

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.neon;
    return FadeTransition(
      opacity: Tween<double>(
        begin: 1,
        end: 0.4,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color, blurRadius: 10)],
        ),
      ),
    );
  }
}
