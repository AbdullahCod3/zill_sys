import 'package:flutter/material.dart';

/// Slate design-system palette, translated 1:1 from `slate-tokens.css`.
///
/// [AppColors] holds the *semantic* tokens that flip between dark and light
/// themes; the raw palette and the theme-independent neon accents live as
/// static members. Read the active set via `Theme.of(context).extension`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  // ── Raw palette (theme-independent) ──────────────────────────────────────
  static const Color void_ = Color(0xFF0A0A0F);
  static const Color ink = Color(0xFF1C1C27);
  static const Color smoke = Color(0xFF2E2E3E);
  static const Color mist = Color(0xFF6B6B82);
  static const Color fog = Color(0xFFAEAEC0);
  static const Color cloud = Color(0xFFE8E8F0);
  static const Color paper = Color(0xFFF7F7FB);
  static const Color white = Color(0xFFFFFFFF);

  static const Color indigo = Color(0xFF7C6FF7);
  static const Color indigoLight = Color(0xFFA69CF9);
  static const Color indigoDark = Color(0xFF5A52D5);

  // ── Neon accents (same in both themes) ───────────────────────────────────
  /// `--neon` — primary indigo accent.
  static const Color neon = indigo;

  /// `--neon-cyan` — secondary cyan accent (#5EEAD4 / rgba 94,234,212).
  static const Color neonCyan = Color(0xFF5EEAD4);

  static const Color amber = Color(0xFFF5A623);
  static const Color amberLight = Color(0xFFFAC55C);
  static const Color danger = Color(0xFFE85454);
  static const Color success = Color(0xFF3DC96A);

  // ── Semantic tokens (flip per theme) ─────────────────────────────────────
  final Color bgBase;
  final Color bgSurface;
  final Color bgElevated;
  final Color bgOverlay;

  final Color fgPrimary;
  final Color fgSecondary;
  final Color fgTertiary;
  final Color fgDisabled;

  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;

  final Color accent;
  final Color accentHover;

  /// Faint grid lines used in card overlays (`--grid-color`).
  final Color grid;

  const AppColors({
    required this.bgBase,
    required this.bgSurface,
    required this.bgElevated,
    required this.bgOverlay,
    required this.fgPrimary,
    required this.fgSecondary,
    required this.fgTertiary,
    required this.fgDisabled,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.accent,
    required this.accentHover,
    required this.grid,
  });

  static const AppColors dark = AppColors(
    bgBase: ink,
    bgSurface: void_,
    bgElevated: smoke,
    bgOverlay: Color(0xE01C1C27), // rgba(28,28,39,0.88)
    fgPrimary: white,
    fgSecondary: fog,
    fgTertiary: mist,
    fgDisabled: Color(0xFF4A4A60),
    borderSubtle: Color(0x12FFFFFF), // white 0.07
    borderDefault: Color(0x1FFFFFFF), // white 0.12
    borderStrong: Color(0x3DFFFFFF), // white 0.24
    accent: indigo,
    accentHover: indigoLight,
    grid: Color(0x0F7C6FF7), // indigo 0.06
  );

  static const AppColors light = AppColors(
    bgBase: paper,
    bgSurface: white,
    bgElevated: cloud,
    bgOverlay: Color(0xE6FFFFFF), // rgba(255,255,255,0.9)
    fgPrimary: void_,
    fgSecondary: Color(0xFF4A4A60),
    fgTertiary: mist,
    fgDisabled: fog,
    borderSubtle: cloud,
    borderDefault: Color(0xFFD8D8E8),
    borderStrong: Color(0xFFB8B8CC),
    accent: indigoDark,
    accentHover: indigo,
    grid: Color(0x0A1C1C27), // ink 0.04
  );

  @override
  AppColors copyWith({
    Color? bgBase,
    Color? bgSurface,
    Color? bgElevated,
    Color? bgOverlay,
    Color? fgPrimary,
    Color? fgSecondary,
    Color? fgTertiary,
    Color? fgDisabled,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? accent,
    Color? accentHover,
    Color? grid,
  }) {
    return AppColors(
      bgBase: bgBase ?? this.bgBase,
      bgSurface: bgSurface ?? this.bgSurface,
      bgElevated: bgElevated ?? this.bgElevated,
      bgOverlay: bgOverlay ?? this.bgOverlay,
      fgPrimary: fgPrimary ?? this.fgPrimary,
      fgSecondary: fgSecondary ?? this.fgSecondary,
      fgTertiary: fgTertiary ?? this.fgTertiary,
      fgDisabled: fgDisabled ?? this.fgDisabled,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      accent: accent ?? this.accent,
      accentHover: accentHover ?? this.accentHover,
      grid: grid ?? this.grid,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bgBase: Color.lerp(bgBase, other.bgBase, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgElevated: Color.lerp(bgElevated, other.bgElevated, t)!,
      bgOverlay: Color.lerp(bgOverlay, other.bgOverlay, t)!,
      fgPrimary: Color.lerp(fgPrimary, other.fgPrimary, t)!,
      fgSecondary: Color.lerp(fgSecondary, other.fgSecondary, t)!,
      fgTertiary: Color.lerp(fgTertiary, other.fgTertiary, t)!,
      fgDisabled: Color.lerp(fgDisabled, other.fgDisabled, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      grid: Color.lerp(grid, other.grid, t)!,
    );
  }

  /// Convenience accessor: `context.colors`.
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? dark;
}

/// Sugar so widgets can write `context.colors.accent`.
extension AppColorsX on BuildContext {
  AppColors get colors => AppColors.of(this);
}
