import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../../models/analysis_result.dart';
import 'answer_option_tile.dart';
import 'citation_chip.dart';
import 'dont_use_button.dart';

/// The Shadow suggestion column: problem summary, ranked candidate replies
/// (tiered), grounding source citations, and a "Don't use — re-read" action.
class SuggestedAnswerCard extends StatelessWidget {
  final AnalysisResult result;
  final int? selectedIndex;
  final int round;
  final ValueChanged<int> onSelect;
  final VoidCallback onReRead;

  const SuggestedAnswerCard({
    super.key,
    required this.result,
    required this.selectedIndex,
    required this.round,
    required this.onSelect,
    required this.onReRead,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ar = isArabic(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(context, AppStrings.problem.resolve(context)),
        const SizedBox(height: 6),
        Text(
          result.problemSummary,
          style: AppTextStyles.ui(
            arabic: ar,
            size: 14,
            color: colors.fgPrimary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _label(context, AppStrings.suggestedReplies.resolve(context)),
            if (round > 0) ...[const SizedBox(width: 8), _UpdatedPill()],
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemCount: result.options.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) => AnswerOptionTile(
              option: result.options[i],
              selected: selectedIndex == i,
              onTap: () => onSelect(i),
            ),
          ),
        ),
        const SizedBox(height: 12),
        DontUseButton(onTap: onReRead),
        const SizedBox(height: 14),
        _label(context, AppStrings.sources.resolve(context)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in result.citations) CitationChip(citation: c),
          ],
        ),
      ],
    );
  }

  Widget _label(BuildContext context, String text) => Text(
    text,
    style: AppTextStyles.ui(
      arabic: isArabic(context),
      size: 12,
      weight: FontWeight.w600,
      color: context.colors.fgTertiary,
      letterSpacing: 0.08 * 12,
    ),
  );
}

/// "Updated" pill shown beside the header after a re-read (round > 0).
class _UpdatedPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.neon.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.neon.withValues(alpha: 0.4)),
      ),
      child: Text(
        AppStrings.updated.resolve(context).toUpperCase(),
        style: AppTextStyles.ui(
          arabic: isArabic(context),
          size: 10,
          weight: FontWeight.w600,
          color: AppColors.neon,
        ),
      ),
    );
  }
}
