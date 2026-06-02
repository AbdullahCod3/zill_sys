import 'package:flutter/material.dart';

/// The animated five-bar audio equalizer (`.bars`). Uses [currentColor]-style
/// tinting via [color]; pauses when [active] is false.
class AudioBars extends StatefulWidget {
  final Color color;
  final double height;
  final bool active;

  const AudioBars({
    super.key,
    required this.color,
    this.height = 16,
    this.active = true,
  });

  @override
  State<AudioBars> createState() => _AudioBarsState();
}

class _AudioBarsState extends State<AudioBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);

  // Per-bar base heights (fractions) and phase offsets, from the prototype.
  static const _bars = [
    (0.30, 0.0),
    (0.70, 0.1),
    (0.50, 0.2),
    (0.90, 0.3),
    (0.40, 0.15),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (base, phase) in _bars) ...[
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final v = widget.active
                    ? (0.4 +
                          0.6 *
                              (0.5 +
                                  0.5 *
                                      (1 -
                                          (2 *
                                                      ((_controller.value +
                                                              phase) %
                                                          1) -
                                                  1)
                                              .abs())))
                    : 0.4;
                return Container(
                  width: 3,
                  height: widget.height * base * v,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
            const SizedBox(width: 3),
          ],
        ],
      ),
    );
  }
}
