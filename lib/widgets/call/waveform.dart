import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A live neon waveform (the prototype's 48-bar `.waveform`).
class Waveform extends StatefulWidget {
  final int bars;
  final double height;

  const Waveform({super.key, this.bars = 48, this.height = 60});

  @override
  State<Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<Waveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int i = 0; i < widget.bars; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: _bar(i),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _bar(int i) {
    final base = 0.2 + (i % 7) * 0.1;
    final phase = (i % 12) * 0.08;
    final v =
        0.35 + 0.65 * (0.5 + 0.5 * math.sin((_c.value + phase) * 2 * math.pi));
    return Container(
      height: widget.height * base * v,
      decoration: BoxDecoration(
        color: AppColors.neon.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
