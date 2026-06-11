import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';

/// Cosmetic phone-number input on the customer idle screen, styled to match the
/// dark phone chrome. Mock-only — no validation and not wired to the cubit.
class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const PhoneNumberField({
    super.key,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textAlign: ar ? TextAlign.right : TextAlign.left,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
      ],
      style: AppTextStyles.mono(size: 14, color: Colors.white),
      cursorColor: AppColors.neonCyan,
      decoration: InputDecoration(
        isDense: true,
        prefixIcon: const Icon(
          Icons.phone_outlined,
          size: 18,
          color: Colors.white54,
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
        hintText: hint,
        hintStyle: AppTextStyles.ui(
          arabic: ar,
          size: 13,
          color: Colors.white38,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x1FFFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
        ),
      ),
    );
  }
}
