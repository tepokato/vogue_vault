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
import 'services/role_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final appointmentService = AppointmentService();
  await appointmentService.init();
  final authService = AuthService();
  await authService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppointmentService>.value(
          value: appointmentService,
        ),
        ChangeNotifierProvider<AuthService>.value(
          value: authService,
        ),
        ChangeNotifierProvider<RoleProvider>(
          create: (_) => RoleProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
    ).copyWith(
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
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: lightScheme.onSurface),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: lightScheme.onSurface),
          ),
          labelStyle: TextStyle(color: lightScheme.onSurface),
          floatingLabelStyle: TextStyle(color: lightScheme.onSurface),
          hintStyle:
              TextStyle(color: lightScheme.onSurface.withOpacity(0.6)),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.darkBackground,
        fontFamily: 'Poppins',
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: darkScheme.onSurface),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: darkScheme.onSurface),
          ),
          labelStyle: TextStyle(color: darkScheme.onSurface),
          floatingLabelStyle: TextStyle(color: darkScheme.onSurface),
          hintStyle:
              TextStyle(color: darkScheme.onSurface.withOpacity(0.6)),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Start the app with authentication.
      home: const AuthPage(),
    );
  }
}
