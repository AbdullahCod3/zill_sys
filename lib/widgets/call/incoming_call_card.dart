import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../customer/call_avatar.dart';

/// The agent's incoming-call card with answer / reject actions.
class IncomingCallCard extends StatelessWidget {
  final String customerName;
  final String meta;
  final VoidCallback onAnswer;
  final VoidCallback onReject;

  const IncomingCallCard({
    super.key,
    required this.customerName,
    required this.meta,
    required this.onAnswer,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ar = isArabic(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 380),
      padding: const EdgeInsets.fromLTRB(48, 36, 48, 32),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neon),
        boxShadow: [
          BoxShadow(
            color: AppColors.neon.withValues(alpha: 0.25),
            blurRadius: 48,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neon,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              langText(context, 'Incoming call', 'مكالمة واردة').toUpperCase(),
              style: AppTextStyles.ui(
                arabic: ar,
                size: 12,
                weight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const CallAvatar(size: 110, showRings: true),
          const SizedBox(height: 16),
          Text(
            customerName,
            style: AppTextStyles.display(
              arabic: ar,
              size: 32,
              weight: FontWeight.w700,
              color: colors.fgPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            meta,
            style: AppTextStyles.ui(
              arabic: ar,
              size: 13,
              color: colors.fgTertiary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionPill(
                label: langText(context, 'Reject', 'رفض'),
                icon: Icons.call_end,
                color: AppColors.danger,
                onTap: onReject,
              ),
              const SizedBox(width: 16),
              _ActionPill(
                label: langText(context, 'Answer', 'ردّ'),
                icon: Icons.call,
                color: AppColors.success,
                onTap: onAnswer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppTextStyles.ui(
                  arabic: isArabic(context),
                  size: 15,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
