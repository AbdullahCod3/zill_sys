import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../../models/answer_option.dart';
import '../../models/enums.dart';

/// A single suggested reply, tiered Recommended / More likely / Maybe. The
/// recommended option is highlighted with a neon border + filled badge; the
/// selected option shows a "Selected" confirmation bar.
class AnswerOptionTile extends StatefulWidget {
  final AnswerOption option;
  final bool selected;
  final VoidCallback onTap;

  const AnswerOptionTile({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  State<AnswerOptionTile> createState() => _AnswerOptionTileState();
}

class _AnswerOptionTileState extends State<AnswerOptionTile> {
  bool _hover = false;

  // Accent color per tier.
  Color get _tierColor => switch (widget.option.tier) {
    AnswerTier.recommended => AppColors.neon,
    AnswerTier.likely => AppColors.neonCyan,
    AnswerTier.maybe => AppColors.amber,
  };

  String _tierLabel(BuildContext context) => switch (widget.option.tier) {
    AnswerTier.recommended => AppStrings.recommended.resolve(context),
    AnswerTier.likely => AppStrings.moreLikely.resolve(context),
    AnswerTier.maybe => AppStrings.maybe.resolve(context),
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ar = isArabic(context);
    final recommended = widget.option.recommended;
    final highlight = recommended || widget.selected || _hover;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppMotion.base,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: recommended
                ? AppColors.neon.withValues(alpha: 0.08)
                : colors.bgBase,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: highlight ? AppColors.neon : colors.borderDefault,
            ),
            boxShadow: highlight
                ? [
                    BoxShadow(
                      color: AppColors.neon.withValues(
                        alpha: widget.selected ? 0.35 : 0.18,
                      ),
                      blurRadius: 24,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _TierBadge(
                    label: _tierLabel(context),
                    color: _tierColor,
                    filled: recommended,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.option.tag,
                      style: AppTextStyles.ui(
                        arabic: ar,
                        size: 13,
                        weight: FontWeight.w500,
                        color: colors.fgPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.option.text,
                style: AppTextStyles.ui(
                  arabic: ar,
                  size: 13,
                  color: recommended ? colors.fgPrimary : colors.fgSecondary,
                  height: 1.55,
                ),
              ),
              if (widget.selected) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neon,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, size: 14, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        langText(context, 'Selected', 'تم الاختيار'),
                        style: AppTextStyles.ui(
                          arabic: ar,
                          size: 12,
                          weight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Tier pill: filled neon for recommended; tinted outline for likely/maybe.
class _TierBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;

  const _TierBadge({
    required this.label,
    required this.color,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: filled ? null : Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: filled
            ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 12)]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (filled) ...[
            const Icon(Icons.star, size: 10, color: Colors.white),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTextStyles.ui(
              arabic: isArabic(context),
              size: 11,
              weight: FontWeight.w600,
              color: filled ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }
}
