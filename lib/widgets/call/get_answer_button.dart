import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';

/// The primary "Get Answer" trigger — a glowing neon pill (PRD §6).
class GetAnswerButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const GetAnswerButton({super.key, required this.label, required this.onTap});

  @override
  State<GetAnswerButton> createState() => _GetAnswerButtonState();
}

class _GetAnswerButtonState extends State<GetAnswerButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppMotion.base,
          curve: AppMotion.easeOut,
          transform: Matrix4.translationValues(0, _hover ? -1 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.neon,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: [
              BoxShadow(
                color: AppColors.neon.withValues(alpha: _hover ? 0.55 : 0.35),
                blurRadius: _hover ? 24 : 12,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.white, blurRadius: 8)],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: AppTextStyles.ui(
                  arabic: ar,
                  size: 16,
                  weight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                ar ? Icons.arrow_back : Icons.arrow_forward,
                size: 16,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
