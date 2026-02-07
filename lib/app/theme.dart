import 'package:flutter/material.dart';

import '../utils/color_palette.dart';

class AppTheme {
  const AppTheme._();

  static const TextTheme textTheme = TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(
      fontFamily: 'LibertinusSans',
      fontSize: 32,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(fontSize: 16),
  );

  static InputDecorationTheme buildInputDecorationTheme(ColorScheme scheme) {
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

  static ColorScheme lightScheme() {
    return ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
      primary: AppColors.primary,
      surface: AppColors.background,
      background: AppColors.background,
      onSurface: AppColors.textDark,
      onBackground: AppColors.textDark,
      surfaceVariant: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.textDark.withOpacity(0.8),
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
    );
  }

  static ColorScheme darkScheme() {
    return ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      surface: AppColors.darkBackground,
      background: AppColors.darkBackground,
      onSurface: AppColors.textLight,
      onBackground: AppColors.textLight,
      surfaceVariant: AppColors.darkSurfaceVariant,
      onSurfaceVariant: AppColors.textLight.withOpacity(0.8),
    );
  }

  static ThemeData lightTheme() {
    final scheme = lightScheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Poppins',
      inputDecorationTheme: buildInputDecorationTheme(scheme),
      textTheme: textTheme,
    );
  }

  static ThemeData darkTheme() {
    final scheme = darkScheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: 'Poppins',
      inputDecorationTheme: buildInputDecorationTheme(scheme),
      textTheme: textTheme,
    );
  }
}
