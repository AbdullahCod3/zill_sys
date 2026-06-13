import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../../cubits/app_cubits/locale_cubit/locale_cubit.dart';
import '../../cubits/app_cubits/theme_cubit/theme_cubit.dart';
import '../common/live_dot.dart';
import '../common/pill_button.dart';
import 'brand_mark.dart';

/// The top app bar shared across every screen: brand on the left; status chunk,
/// role-switch, language + theme toggles on the right.
class ZillAppBar extends StatelessWidget {
  /// Status text shown beside the live dot (null on Home → no chunk).
  final TextPair? statusLabel;
  final VoidCallback onBrandTap;
  final VoidCallback? onSwitchRole;

  const ZillAppBar({
    super.key,
    this.statusLabel,
    required this.onBrandTap,
    this.onSwitchRole,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final localeCubit = context.watch<LocaleCubit>();
    final themeCubit = context.watch<ThemeCubit>();
    final ar = isArabic(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.borderSubtle)),
      ),
      child: Row(
        children: [
          // Brand
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onBrandTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandMark(size: 56),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.amber),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      AppStrings.brandTag,
                      style: AppTextStyles.mono(
                        size: 10,
                        color: AppColors.amber,
                        letterSpacing: 0.24 * 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Meta
          if (statusLabel != null) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LiveDot(color: AppColors.success, size: 7),
                const SizedBox(width: 8),
                Text(
                  statusLabel!.resolve(context).toUpperCase(),
                  style: AppTextStyles.mono(
                    size: 11,
                    color: colors.fgTertiary,
                    letterSpacing: 0.12 * 11,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 18),
            if (onSwitchRole != null) ...[
              PillButton(
                label: '← ${AppStrings.switchRole.resolve(context)}',
                onTap: onSwitchRole!,
              ),
              const SizedBox(width: 18),
            ],
          ],
          PillButton(
            label: ar ? 'AR' : 'EN',
            onTap: () => localeCubit.toggle(),
          ),
          const SizedBox(width: 12),
          PillButton(
            label: themeCubit.isDark ? '◐ DARK' : '◑ LIGHT',
            onTap: () => themeCubit.toggle(),
          ),
        ],
      ),
    );
  }
}
