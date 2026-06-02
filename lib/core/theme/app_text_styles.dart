import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';

/// Slate typography. Three roles — display, ui, mono — each with a Latin family
/// and an Arabic-capable fallback so AR glyphs render cleanly.
///
/// The Zill skin (`styles.css`) overrides Slate's serif with Plus Jakarta Sans
/// for both display and UI text, so we follow the *rendered* prototype here.
/// Latin: Plus Jakarta Sans / JetBrains Mono. Arabic: Tajawal. Mono keeps
/// JetBrains Mono (digits and KB-codes are Latin in both languages).
class AppTextStyles {
  AppTextStyles._();

  static TextStyle display({
    required bool arabic,
    double size = AppFontSizes.xl2,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double height = 1.15,
    double letterSpacing = -0.03 * AppFontSizes.base,
  }) {
    final base = TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
    return arabic
        ? GoogleFonts.tajawal(textStyle: base)
        : GoogleFonts.plusJakartaSans(textStyle: base);
  }

  static TextStyle ui({
    required bool arabic,
    double size = AppFontSizes.base,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.5,
    double letterSpacing = 0,
  }) {
    final base = TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
    return arabic
        ? GoogleFonts.tajawal(textStyle: base)
        : GoogleFonts.plusJakartaSans(textStyle: base);
  }

  static TextStyle mono({
    double size = AppFontSizes.sm,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double letterSpacing = 0.1 * AppFontSizes.sm,
    double height = 1.5,
  }) {
    return GoogleFonts.jetBrainsMono(
      textStyle: TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      ),
    );
  }

  /// Builds the Material [TextTheme] used as the theme default (UI font).
  static TextTheme textTheme({required bool arabic, required Color color}) {
    TextStyle u(double size, FontWeight w, {double h = 1.5, double ls = 0}) =>
        ui(
          arabic: arabic,
          size: size,
          weight: w,
          color: color,
          height: h,
          letterSpacing: ls,
        );
    TextStyle d(
      double size,
      FontWeight w, {
      double h = 1.15,
      double ls = -0.48,
    }) => display(
      arabic: arabic,
      size: size,
      weight: w,
      color: color,
      height: h,
      letterSpacing: ls,
    );

    return TextTheme(
      displayLarge: d(AppFontSizes.xl4, FontWeight.w700),
      displayMedium: d(AppFontSizes.xl3, FontWeight.w500),
      displaySmall: d(AppFontSizes.xl2, FontWeight.w500),
      headlineMedium: d(AppFontSizes.xl, FontWeight.w400, h: 1.3),
      headlineSmall: u(AppFontSizes.lg, FontWeight.w600, h: 1.3),
      titleLarge: u(AppFontSizes.md, FontWeight.w600, h: 1.3),
      bodyLarge: u(AppFontSizes.base, FontWeight.w400, h: 1.7),
      bodyMedium: u(AppFontSizes.sm, FontWeight.w400, h: 1.7),
      labelLarge: u(
        AppFontSizes.sm,
        FontWeight.w500,
        ls: 0.05 * AppFontSizes.sm,
      ),
      labelSmall: u(
        AppFontSizes.xs,
        FontWeight.w600,
        ls: 0.12 * AppFontSizes.xs,
      ),
    );
  }
}
