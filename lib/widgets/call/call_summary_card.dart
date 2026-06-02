import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../../core/utils/time_format.dart';
import '../../models/calls_model.dart';
import 'citation_chip.dart';

/// Post-call recap (PRD §5.7): duration, issue, outcome, citations used, and a
/// New-call CTA.
class CallSummaryCard extends StatelessWidget {
  final CallsModel call;
  final VoidCallback onNewCall;

  const CallSummaryCard({
    super.key,
    required this.call,
    required this.onNewCall,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ar = isArabic(context);
    final outcomeLabel = call.escalated
        ? AppStrings.escalated.resolve(context)
        : AppStrings.resolved.resolve(context);

    return Center(
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: colors.borderDefault),
          boxShadow: [
            BoxShadow(
              color: AppColors.neon.withValues(alpha: 0.12),
              blurRadius: 40,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.callSummary.resolve(context),
              style: AppTextStyles.mono(
                size: 11,
                color: AppColors.neon,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            _row(
              context,
              AppStrings.duration.resolve(context),
              formatMmss(call.durationSec),
            ),
            _row(
              context,
              AppStrings.issue.resolve(context),
              call.issueCategory,
            ),
            _row(
              context,
              AppStrings.outcome.resolve(context),
              outcomeLabel,
              highlight: call.escalated,
            ),
            if (call.escalated && call.supervisorId != null)
              _row(
                context,
                AppStrings.supervisor.resolve(context),
                call.supervisorId!,
              ),
            if (call.citations.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                AppStrings.sources.resolve(context),
                style: AppTextStyles.ui(
                  arabic: ar,
                  size: 12,
                  weight: FontWeight.w600,
                  color: colors.fgTertiary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in call.citations) CitationChip(citation: c),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onNewCall,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.neon,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neon.withValues(alpha: 0.35),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Text(
                      AppStrings.newCall.resolve(context),
                      style: AppTextStyles.ui(
                        arabic: ar,
                        size: 15,
                        weight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    bool highlight = false,
  }) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.ui(
              arabic: isArabic(context),
              size: 14,
              color: colors.fgSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.ui(
              arabic: isArabic(context),
              size: 14,
              weight: FontWeight.w600,
              color: highlight ? AppColors.danger : colors.fgPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
