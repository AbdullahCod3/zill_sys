import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Assembles [ThemeData] from the Slate tokens. Rebuilt by the app whenever the
/// brightness (ThemeCubit) or language (LocaleCubit) changes, so fonts stay
/// locale-appropriate and colors flip dark/light.
class AppTheme {
  AppTheme._();

  static ThemeData dark({required bool arabic}) => _build(
    colors: AppColors.dark,
    brightness: Brightness.dark,
    arabic: arabic,
  );

  static ThemeData light({required bool arabic}) => _build(
    colors: AppColors.light,
    brightness: Brightness.light,
    arabic: arabic,
  );

  static ThemeData _build({
    required AppColors colors,
    required Brightness brightness,
    required bool arabic,
  }) {
    final textTheme = AppTextStyles.textTheme(
      arabic: arabic,
      color: colors.fgPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.bgBase,
      canvasColor: colors.bgBase,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.neon,
        brightness: brightness,
        primary: colors.accent,
        surface: colors.bgSurface,
        error: AppColors.danger,
      ),
      textTheme: textTheme,
      dividerColor: colors.borderDefault,
      extensions: <ThemeExtension<dynamic>>[colors],
      splashFactory: InkSparkle.splashFactory,
    );
  }
}

/// Reusable neon glow shadows (the `box-shadow: 0 0 Npx rgba(neon, a)` pattern).
class AppShadows {
  AppShadows._();

  static List<BoxShadow> glow(
    Color color, {
    double blur = 28,
    double opacity = 0.25,
  }) => [
    BoxShadow(
      color: color.withValues(alpha: opacity),
      blurRadius: blur,
    ),
  ];

  static List<BoxShadow> neonGlow({double blur = 28, double opacity = 0.25}) =>
      glow(AppColors.neon, blur: blur, opacity: opacity);

  static List<BoxShadow> cyanGlow({double blur = 28, double opacity = 0.22}) =>
      glow(AppColors.neonCyan, blur: blur, opacity: opacity);
}
