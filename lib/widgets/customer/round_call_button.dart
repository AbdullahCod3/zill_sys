import 'package:flutter/material.dart';

/// A round phone-call action button (green to start, red to end).
class RoundCallButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const RoundCallButton({
    super.key,
    required this.color,
    required this.icon,
    required this.onTap,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: size * 0.4),
        ),
      ),
    );
  }
}
