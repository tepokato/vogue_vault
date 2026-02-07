import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../screens/auth_page.dart';
import '../services/settings_service.dart';
import 'theme.dart';

class VogueVaultApp extends StatelessWidget {
  const VogueVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = context.watch<SettingsService>();

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: settingsService.locale,
      home: const AuthPage(),
      themeMode: settingsService.themeMode,
    );
  }
}
