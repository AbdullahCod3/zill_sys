import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../../models/citation.dart';

/// A source citation pill: the KB document id (mono) + the document title.
class CitationChip extends StatelessWidget {
  final Citation citation;

  const CitationChip({super.key, required this.citation});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ar = isArabic(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.bgElevated,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description_outlined, size: 13, color: AppColors.neonCyan),
          const SizedBox(width: 6),
          Text(
            citation.documentId,
            style: AppTextStyles.mono(
              size: 10,
              color: AppColors.neonCyan,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            citation.title,
            style: AppTextStyles.ui(
              arabic: ar,
              size: 12,
              color: colors.fgSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
