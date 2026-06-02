import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../../models/transcript_line.dart';
import 'transcript_bubble.dart';

/// The live diarized transcript column: a header plus the running bubbles and a
/// typing indicator while the customer is still speaking.
class TranscriptPanel extends StatelessWidget {
  final List<TranscriptLine> lines;
  final bool listening;

  const TranscriptPanel({
    super.key,
    required this.lines,
    this.listening = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          langText(context, 'Live transcript', 'النصّ المباشر').toUpperCase(),
          style: AppTextStyles.ui(
            arabic: isArabic(context),
            size: 12,
            weight: FontWeight.w500,
            color: colors.fgTertiary,
            letterSpacing: 0.08 * 12,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: lines.length + (listening ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              if (i < lines.length) return TranscriptBubble(line: lines[i]);
              return const _ListeningBubble();
            },
          ),
        ),
      ],
    );
  }
}

class _ListeningBubble extends StatefulWidget {
  const _ListeningBubble();

  @override
  State<_ListeningBubble> createState() => _ListeningBubbleState();
}

class _ListeningBubbleState extends State<_ListeningBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.borderSubtle,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) {
                    final v = (math0(_c.value + i * 0.15));
                    return Opacity(
                      opacity: 0.3 + 0.7 * v,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: colors.fgTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  double math0(double t) {
    final x = (t % 1);
    return (x < 0.5 ? x * 2 : (1 - x) * 2);
  }
}
