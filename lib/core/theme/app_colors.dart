import 'package:flutter/material.dart';

/// Brand teal palette (الألوان الأساسية + الألوان الثانوية), translated into the
/// semantic-token shape the rest of the app reads through `context.colors.X`.
///
/// [AppColors] holds the semantic tokens that flip between dark and light themes;
/// the raw palette and the theme-independent brand accents live as static members.
/// Read the active set via `Theme.of(context).extension`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  // ── Raw palette (theme-independent) ──────────────────────────────────────
  // Dark-family surfaces (essential palette: الخلفية الرئيسية / الثانوية).
  static const Color void_ = Color(0xFF0B1E1C); // الخلفية الرئيسية
  static const Color ink = Color(0xFF103D38); // الخلفية الثانوية
  static const Color smoke = Color(0xFF1A4F48); // elevated surface (derived)
  // Neutral text/border ramp (teal-tinted greys).
  static const Color mist = Color(0xFF4B6663);
  static const Color fog = Color(0xFF9BB5B1);
  static const Color cloud = Color(0xFFDFEEEC);
  static const Color paper = Color(0xFFF2F8F7);
  static const Color white = Color(0xFFFFFFFF);

  // ── Brand accents (same in both themes) ──────────────────────────────────
  /// `neon` — primary interactive accent (العناصر التفاعلية).
  static const Color neon = Color(0xFF269D91);

  /// `neonCyan` — secondary mint accent (النصوص والحدود highlight).
  static const Color neonCyan = Color(0xFF86D0CB);

  /// Slightly brighter teal used for hover/active states.
  static const Color neonHover = Color(0xFF3FB8AB);

  /// Pale-cyan informational accent (secondary palette).
  static const Color infoSoft = Color(0xFFC5E7E8);

  static const Color amber = Color(0xFFF8CB40);
  static const Color amberLight = Color(0xFFFFD97A);
  static const Color danger = Color(0xFFE85454);
  static const Color success = Color(0xFFB7CD34);

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

  /// Faint grid lines used in card overlays.
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
    bgBase: void_,
    bgSurface: ink,
    bgElevated: smoke,
    bgOverlay: Color(0xE0103D38), // ink at ~0.88
    fgPrimary: white,
    fgSecondary: neonCyan,
    fgTertiary: fog,
    fgDisabled: mist,
    borderSubtle: Color(0x1A86D0CB), // neonCyan 0.10
    borderDefault: Color(0x3386D0CB), // neonCyan 0.20
    borderStrong: Color(0x6686D0CB), // neonCyan 0.40
    accent: neon,
    accentHover: neonHover,
    grid: Color(0x14269D91), // neon ~0.08
  );

  static const AppColors light = AppColors(
    bgBase: paper,
    bgSurface: white,
    bgElevated: cloud,
    bgOverlay: Color(0xE6FFFFFF), // white 0.90
    fgPrimary: void_,
    fgSecondary: ink,
    fgTertiary: mist,
    fgDisabled: fog,
    borderSubtle: cloud,
    borderDefault: infoSoft,
    borderStrong: neonCyan,
    accent: Color(0xFF1F857B), // deeper teal for AA contrast on white
    accentHover: neon,
    grid: Color(0x14103D38), // ink ~0.08
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
