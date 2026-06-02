import 'package:flutter/material.dart';

/// Paints a faint square grid (the prototype's `linear-gradient` grid overlay).
class GridOverlay extends StatelessWidget {
  final Color color;
  final double cell;

  const GridOverlay({super.key, required this.color, this.cell = 32});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GridPainter(color, cell),
        size: Size.infinite,
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  final double cell;

  _GridPainter(this.color, this.cell);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) =>
      old.color != color || old.cell != cell;
}
