import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import 'utils/color_palette.dart';

import 'screens/auth_page.dart';
import 'services/appointment_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'services/backup_service.dart';

InputDecorationTheme _buildInputDecorationTheme(ColorScheme scheme) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide.none,
  );
  return InputDecorationTheme(
    filled: true,
    fillColor: scheme.surface,
    prefixIconColor: scheme.onSurface,
    suffixIconColor: scheme.onSurface,
    border: border,
    enabledBorder: border,
    focusedBorder: border,
    labelStyle: TextStyle(color: scheme.onSurface),
    floatingLabelStyle: TextStyle(color: scheme.onSurface),
    hintStyle: TextStyle(color: scheme.onSurface.withOpacity(0.6)),
  );
}

const TextTheme _textTheme = TextTheme(
  headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  headlineMedium: TextStyle(
    fontFamily: 'LibertinusSans',
    fontSize: 32,
    fontWeight: FontWeight.w400,
  ),
  bodyMedium: TextStyle(fontSize: 16),
);

// Entry point that prepares storage-backed services before rendering the app.
// Keeping initialization here makes it easy to inject mocks in tests or add
// additional services without touching UI code.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final notificationService = NotificationService();
  await notificationService.init();
  final appointmentService = AppointmentService(
    notificationService: notificationService,
  );
  await appointmentService.init();
  final authService = AuthService();
  await authService.init();
  final settingsService = SettingsService();
  await settingsService.init();
  final backupService = BackupService(appointmentService);

  runApp(
    ChangeNotifierProvider<SettingsService>.value(
      value: settingsService,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<AppointmentService>.value(
            value: appointmentService,
          ),
          ChangeNotifierProvider<AuthService>.value(value: authService),
          ChangeNotifierProvider<BackupService>.value(value: backupService),
          Provider<NotificationService>.value(value: notificationService),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = context.watch<SettingsService>();
    final lightScheme =
        ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
      primary: AppColors.primary,
      surface: AppColors.background,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      surface: AppColors.darkBackground,
    );

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Poppins',
        inputDecorationTheme: _buildInputDecorationTheme(lightScheme),
        textTheme: _textTheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.darkBackground,
        fontFamily: 'Poppins',
        inputDecorationTheme: _buildInputDecorationTheme(darkScheme),
        textTheme: _textTheme,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: settingsService.locale,
      // Start the app with authentication.
      home: const AuthPage(),
      themeMode: settingsService.themeMode,
    );
  }
}
