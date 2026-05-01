import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/generated/app_localizations.dart';
import 'router.dart';
import 'theme.dart';

/// Root app widget — uses MaterialApp.router with GoRouter.
class FursafyApp extends StatelessWidget {
  const FursafyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fursafy',
      debugShowCheckedModeBanner: false,
      theme: FursafyTheme.lightTheme,
      routerConfig: appRouter,

      // ─── Localization ───
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('sw'), // Swahili
      ],
    );
  }
}
