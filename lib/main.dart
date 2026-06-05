import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'cubits/app_cubits/demo_cubit/demo_cubit.dart';
import 'cubits/app_cubits/locale_cubit/locale_cubit.dart';
import 'cubits/app_cubits/theme_cubit/theme_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Firebase must be initialized before the app reads/writes Firestore.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ZillApp());
}

/// App root: registers the global app-level cubits (theme, locale, demo) and
/// wires the Slate themes, localization, and routes.
class ZillApp extends StatelessWidget {
  const ZillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (_) => DemoCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              final arabic = locale.languageCode == 'ar';
              return MaterialApp(
                title: 'Ẓill · Shadow',
                debugShowCheckedModeBanner: false,
                themeMode: themeMode,
                theme: AppTheme.light(arabic: arabic),
                darkTheme: AppTheme.dark(arabic: arabic),
                locale: locale,
                supportedLocales: LocaleCubit.supportedLocales,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                initialRoute: AppRoutes.home,
                onGenerateRoute: AppRoutes.onGenerateRoute,
              );
            },
          );
        },
      ),
    );
  }
}
