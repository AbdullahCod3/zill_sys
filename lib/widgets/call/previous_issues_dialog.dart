import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../../core/utils/time_format.dart';

/// One mocked past issue, shaped like the ERD `previous_issues` collection
/// (issue_summary, category, resolved, source, created_at).
class _MockIssue {
  final String summaryEn;
  final String summaryAr;
  final String category; // 'billing' | 'technical' | 'policy'
  final bool resolved;
  final String source; // 'chat' | 'call'
  final DateTime createdAt;

  const _MockIssue({
    required this.summaryEn,
    required this.summaryAr,
    required this.category,
    required this.resolved,
    required this.source,
    required this.createdAt,
  });

  TextPair get categoryLabel => switch (category) {
    'technical' => AppStrings.categoryTechnical,
    'policy' => AppStrings.categoryPolicy,
    _ => AppStrings.categoryBilling,
  };

  TextPair get sourceLabel =>
      source == 'call' ? AppStrings.sourceCall : AppStrings.sourceChat;
}

/// Compact popup over the agent console showing the customer's last issues —
/// each rendered as labeled rows (the ERD `previous_issues` fields). Mock data.
class PreviousIssuesDialog extends StatelessWidget {
  final String customerName;

  const PreviousIssuesDialog({super.key, required this.customerName});

  static Future<void> show(
    BuildContext context, {
    required String customerName,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => PreviousIssuesDialog(customerName: customerName),
    );
  }

  // Mocked last-3 issues for the demo (most recent first).
  static List<_MockIssue> get _issues => [
    _MockIssue(
      summaryEn: 'Billing dispute over premium plan charge',
      summaryAr: 'اعتراض على رسوم الباقة المميّزة',
      category: 'billing',
      resolved: true,
      source: 'chat',
      createdAt: DateTime(2026, 4, 3),
    ),
    _MockIssue(
      summaryEn: 'Repeated internet outages in the evening',
      summaryAr: 'انقطاعات متكرّرة للإنترنت مساءً',
      category: 'technical',
      resolved: false,
      source: 'call',
      createdAt: DateTime(2026, 5, 9),
    ),
    _MockIssue(
      summaryEn: 'SIM replacement request',
      summaryAr: 'طلب استبدال شريحة',
      category: 'policy',
      resolved: true,
      source: 'chat',
      createdAt: DateTime(2026, 1, 18),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ar = isArabic(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.7;
    final issues = _issues;

    return Dialog(
      backgroundColor: colors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        side: BorderSide(color: AppColors.neon.withValues(alpha: 0.5)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480, maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 16, 16),
              child: Row(
                children: [
                  const Icon(Icons.history, color: AppColors.neonCyan),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.previousIssues.resolve(context),
                          style: AppTextStyles.display(
                            arabic: ar,
                            size: 24,
                            weight: FontWeight.w700,
                            color: colors.fgPrimary,
                          ),
                        ),
                        Text(
                          customerName,
                          style: AppTextStyles.mono(
                            size: 12,
                            color: colors.fgTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.fgSecondary),
                    splashRadius: 20,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.borderDefault),
            // Issue list
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < issues.length; i++) ...[
                      if (i > 0) Divider(height: 1, color: colors.borderSubtle),
                      _IssueBlock(issue: issues[i], arabic: ar),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One issue rendered as labeled rows.
class _IssueBlock extends StatelessWidget {
  final _MockIssue issue;
  final bool arabic;

  const _IssueBlock({required this.issue, required this.arabic});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusColor = issue.resolved ? AppColors.success : AppColors.amber;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field(
            label: AppStrings.issueSummary.resolve(context),
            child: Text(
              arabic ? issue.summaryAr : issue.summaryEn,
              style: AppTextStyles.ui(
                arabic: arabic,
                size: 16,
                weight: FontWeight.w600,
                color: colors.fgPrimary,
                height: 1.4,
              ),
            ),
          ),
          _Field(
            label: AppStrings.category.resolve(context),
            child: _ValueText(issue.categoryLabel.resolve(context), arabic),
          ),
          _Field(
            label: AppStrings.status.resolve(context),
            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  (issue.resolved ? AppStrings.resolved : AppStrings.openStatus)
                      .resolve(context),
                  style: AppTextStyles.ui(
                    arabic: arabic,
                    size: 15,
                    weight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          _Field(
            label: AppStrings.source.resolve(context),
            child: _ValueText(issue.sourceLabel.resolve(context), arabic),
          ),
          _Field(
            label: AppStrings.date.resolve(context),
            child: Text(
              formatShortDate(issue.createdAt),
              style: AppTextStyles.mono(size: 14, color: colors.fgSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// A labeled row: fixed-width uppercase mono label + value.
class _Field extends StatelessWidget {
  final String label;
  final Widget child;

  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label.toUpperCase(),
              style: AppTextStyles.mono(
                size: 11,
                color: context.colors.fgTertiary,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ValueText extends StatelessWidget {
  final String value;
  final bool arabic;

  const _ValueText(this.value, this.arabic);

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: AppTextStyles.ui(
        arabic: arabic,
        size: 15,
        color: context.colors.fgSecondary,
      ),
    );
  }
}
