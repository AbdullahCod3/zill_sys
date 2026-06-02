import 'package:flutter/animation.dart';

/// Numeric tokens from the Slate design system (`slate-tokens.css`) plus the
/// domain constants from the PRD (anger threshold, debounce window, top-K).

/// Typographic scale — Major Third (×1.25), in logical pixels.
class AppFontSizes {
  AppFontSizes._();
  static const double xs = 10.24;
  static const double sm = 12.8;
  static const double base = 16;
  static const double md = 20;
  static const double lg = 25;
  static const double xl = 31.25;
  static const double xl2 = 39;
  static const double xl3 = 48.8;
  static const double xl4 = 61;
  static const double xl5 = 76.3;
}

/// Spacing scale (px).
class AppSpacing {
  AppSpacing._();
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s12 = 48;
  static const double s16 = 64;
  static const double s24 = 96;
}

/// Corner radii (px).
class AppRadii {
  AppRadii._();
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double pill = 100;
}

/// Motion tokens.
class AppMotion {
  AppMotion._();
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  /// `--ease-out: cubic-bezier(0.16, 1, 0.3, 1)`.
  static const Curve easeOut = Cubic(0.16, 1, 0.3, 1);

  /// `--ease-in: cubic-bezier(0.7, 0, 0.84, 0)`.
  static const Curve easeIn = Cubic(0.7, 0, 0.84, 0);

  /// `--ease-inout: cubic-bezier(0.87, 0, 0.13, 1)`.
  static const Curve easeInOut = Cubic(0.87, 0, 0.13, 1);
}

/// Domain constants (PRD §13, §11, CLAUDE.md load-bearing rules).
class AppConfig {
  AppConfig._();

  /// Anger alert threshold — fires once when the score first reaches this.
  static const int angerThreshold = 7;

  /// Top-K chunks retrieved per analysis cycle (≈5).
  static const int retrievalTopK = 5;

  /// Analysis debounce window (PRD: fire at most once every ~6–8s). For the
  /// scripted demo this doubles as the "Shadow is thinking…" dwell.
  static const Duration analysisDebounce = Duration(milliseconds: 1500);

  /// Delay from "waiting" to the incoming-call overlay (agent console).
  static const Duration incomingCallDelay = Duration(seconds: 2);

  /// Customer phone ring duration before the agent "answers".
  static const Duration customerRingDuration = Duration(milliseconds: 3500);
}
