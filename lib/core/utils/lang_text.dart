import 'package:flutter/widgets.dart';

/// Bilingual text helpers, mirroring the prototype's inline `t(en, ar)` pattern.
/// The active language is read from the ambient [Localizations] locale, which the
/// `LocaleCubit` drives through `MaterialApp.locale`.

/// True when the active locale is Arabic.
bool isArabic(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar';

/// Returns [ar] in Arabic locale, otherwise [en].
String langText(BuildContext context, String en, String ar) =>
    isArabic(context) ? ar : en;

/// A language-independent string pair; resolve with [resolve].
@immutable
class TextPair {
  final String en;
  final String ar;
  const TextPair(this.en, this.ar);

  String resolve(BuildContext context) => isArabic(context) ? ar : en;
}
