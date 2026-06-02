import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';

/// Agent in-call controls: mute, speaker, hold, and end.
class CallControls extends StatelessWidget {
  final bool muted;
  final bool speakerOn;
  final VoidCallback onMute;
  final VoidCallback onSpeaker;
  final VoidCallback onEnd;

  const CallControls({
    super.key,
    required this.muted,
    required this.speakerOn,
    required this.onMute,
    required this.onSpeaker,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Ctl(
          icon: muted ? Icons.mic_off : Icons.mic_none,
          label: muted
              ? AppStrings.unmute.resolve(context)
              : AppStrings.mute.resolve(context),
          active: muted,
          onTap: onMute,
        ),
        const SizedBox(width: 10),
        _Ctl(
          icon: Icons.volume_up_outlined,
          label: AppStrings.speaker.resolve(context),
          active: speakerOn,
          onTap: onSpeaker,
        ),
        const SizedBox(width: 10),
        _Ctl(
          icon: Icons.pause,
          label: langText(context, 'Hold', 'انتظار'),
          active: false,
          onTap: () {},
        ),
        const SizedBox(width: 10),
        _Ctl(
          icon: Icons.call_end,
          label: langText(context, 'End', 'إنهاء'),
          active: false,
          danger: true,
          onTap: onEnd,
        ),
      ],
    );
  }
}

class _Ctl extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool danger;
  final VoidCallback onTap;

  const _Ctl({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final Color bg;
    final Color fg;
    final Color border;
    if (danger) {
      bg = AppColors.danger;
      fg = Colors.white;
      border = AppColors.danger;
    } else if (active) {
      bg = AppColors.neon;
      fg = Colors.white;
      border = AppColors.neon;
    } else {
      bg = colors.bgElevated;
      fg = colors.fgPrimary;
      border = colors.borderSubtle;
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.ui(
                  arabic: isArabic(context),
                  size: 11,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
