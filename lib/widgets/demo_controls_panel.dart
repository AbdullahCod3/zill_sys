import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/lang_text.dart';
import '../cubits/app_cubits/demo_cubit/demo_cubit.dart';
import '../models/enums.dart';

/// Floating demo control (the prototype's Tweaks panel): switches the scripted
/// customer mood. Collapsible to stay out of the way during a demo.
class DemoControlsPanel extends StatefulWidget {
  const DemoControlsPanel({super.key});

  @override
  State<DemoControlsPanel> createState() => _DemoControlsPanelState();
}

class _DemoControlsPanelState extends State<DemoControlsPanel> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mood = context.watch<DemoCubit>().state;
    final ar = isArabic(context);

    return Container(
      width: _open ? 220 : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.bgOverlay,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: colors.borderDefault),
        boxShadow: [
          BoxShadow(
            color: AppColors.neon.withValues(alpha: 0.12),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DEMO',
                  style: AppTextStyles.mono(
                    size: 11,
                    color: AppColors.neon,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _open ? Icons.expand_more : Icons.expand_less,
                  size: 16,
                  color: colors.fgTertiary,
                ),
              ],
            ),
          ),
          if (_open) ...[
            const SizedBox(height: 12),
            Text(
              langText(context, 'Customer mood', 'مزاج العميل'),
              style: AppTextStyles.ui(
                arabic: ar,
                size: 12,
                color: colors.fgSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _MoodChip(
                  label: langText(context, 'Calm', 'هادئ'),
                  selected: mood == Mood.calm,
                  onTap: () => context.read<DemoCubit>().setMood(Mood.calm),
                ),
                const SizedBox(width: 8),
                _MoodChip(
                  label: langText(context, 'Frustrated', 'غاضب'),
                  selected: mood == Mood.frustrated,
                  onTap: () =>
                      context.read<DemoCubit>().setMood(Mood.frustrated),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MoodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.neon : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(
              color: selected ? AppColors.neon : colors.borderDefault,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.ui(
              arabic: isArabic(context),
              size: 12,
              weight: FontWeight.w500,
              color: selected ? Colors.white : colors.fgSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
