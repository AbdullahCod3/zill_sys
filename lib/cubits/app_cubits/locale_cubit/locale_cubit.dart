import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// App-level language preference (English ⇄ Arabic). Drives `MaterialApp.locale`,
/// which flips text direction (LTR/RTL) and selects locale-appropriate fonts.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en'));

  static const supportedLocales = [Locale('en'), Locale('ar')];

  bool get isArabic => state.languageCode == 'ar';

  void toggle() => emit(isArabic ? const Locale('en') : const Locale('ar'));

  void setLanguage(String code) => emit(Locale(code));
}
