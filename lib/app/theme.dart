import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/color_palette.dart';

/// Design tokens shared across the app for consistent rhythm and shape.
class AppTokens {
  AppTokens._();

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double space = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  static const double radiusSm = 12;
  static const double radius = 18;
  static const double radiusLg = 24;
  static const double radiusXl = 32;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius fieldRadius = BorderRadius.all(Radius.circular(radius));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(999));

  /// Soft ambient shadow for raised cards in light mode.
  static List<BoxShadow> softShadow(Color base) => [
        BoxShadow(
          color: base.withOpacity(0.10),
          blurRadius: 24,
          offset: const Offset(0, 10),
          spreadRadius: -8,
        ),
      ];
}

class AppTheme {
  const AppTheme._();

  static ColorScheme lightScheme() {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );
    return base.copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFEADFFB),
      onPrimaryContainer: const Color(0xFF2A1656),
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFFFDCE3),
      onSecondaryContainer: const Color(0xFF59101F),
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFBFF1E9),
      onTertiaryContainer: const Color(0xFF00322C),
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: const Color(0xFFFADBDC),
      onErrorContainer: const Color(0xFF410E0B),
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceVariantLight,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.outlineLight,
      outlineVariant: AppColors.outlineLight,
      surfaceTint: AppColors.primary,
      inverseSurface: const Color(0xFF322C42),
      onInverseSurface: const Color(0xFFF2EFFA),
      shadow: AppColors.primary,
    );
  }

  static ColorScheme darkScheme() {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );
    return base.copyWith(
      primary: AppColors.primaryDark,
      onPrimary: const Color(0xFF2A1656),
      primaryContainer: const Color(0xFF4C3585),
      onPrimaryContainer: const Color(0xFFEADFFB),
      secondary: AppColors.secondaryDark,
      onSecondary: const Color(0xFF59101F),
      secondaryContainer: const Color(0xFF7A2A3C),
      onSecondaryContainer: const Color(0xFFFFDCE3),
      tertiary: AppColors.tertiaryDark,
      onTertiary: const Color(0xFF00322C),
      tertiaryContainer: const Color(0xFF115048),
      onTertiaryContainer: const Color(0xFFBFF1E9),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: AppColors.outlineDark,
      outlineVariant: AppColors.outlineDark,
      surfaceTint: AppColors.primaryDark,
      inverseSurface: const Color(0xFFF2EFFA),
      onInverseSurface: const Color(0xFF322C42),
      shadow: Colors.black,
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    final base = Typography.material2021(platform: TargetPlatform.android)
        .black
        .apply(fontFamily: 'Poppins');
    return base
        .copyWith(
          displaySmall: const TextStyle(
            fontFamily: 'LibertinusSans',
            fontWeight: FontWeight.w700,
            fontSize: 34,
            letterSpacing: -0.5,
          ),
          headlineMedium: const TextStyle(
            fontFamily: 'LibertinusSans',
            fontWeight: FontWeight.w700,
            fontSize: 30,
            letterSpacing: -0.5,
          ),
          headlineSmall: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.3,
          ),
          titleLarge: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
          titleMedium: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          titleSmall: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          bodyLarge: const TextStyle(fontSize: 16, height: 1.4),
          bodyMedium: const TextStyle(fontSize: 14, height: 1.4),
          labelLarge: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        )
        .apply(
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        );
  }

  static InputDecorationTheme _inputTheme(ColorScheme scheme) {
    OutlineInputBorder border(Color color, [double width = 1.2]) =>
        OutlineInputBorder(
          borderRadius: AppTokens.fieldRadius,
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withOpacity(0.6),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIconColor: scheme.onSurfaceVariant,
      suffixIconColor: scheme.onSurfaceVariant,
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      floatingLabelStyle: TextStyle(
        color: scheme.primary,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant.withOpacity(0.7)),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(scheme.primary, 1.6),
      errorBorder: border(scheme.error),
      focusedErrorBorder: border(scheme.error, 1.6),
    );
  }

  static ThemeData _build(ColorScheme scheme) {
    final text = _textTheme(scheme);
    final isLight = scheme.brightness == Brightness.light;
    final scaffold =
        isLight ? AppColors.scaffoldLight : AppColors.scaffoldDark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      fontFamily: 'Poppins',
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      inputDecorationTheme: _inputTheme(scheme),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 54),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: text.labelLarge,
          shape: const RoundedRectangleBorder(
            borderRadius: AppTokens.fieldRadius,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(0, 54),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: text.labelLarge,
          shape: const RoundedRectangleBorder(
            borderRadius: AppTokens.fieldRadius,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(0, 54),
          side: BorderSide(color: scheme.outline),
          textStyle: text.labelLarge,
          shape: const RoundedRectangleBorder(
            borderRadius: AppTokens.fieldRadius,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: text.labelLarge,
          shape: const RoundedRectangleBorder(
            borderRadius: AppTokens.pillRadius,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest.withOpacity(0.6),
        selectedColor: scheme.primary,
        side: BorderSide.none,
        labelStyle: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
        secondaryLabelStyle: text.labelLarge?.copyWith(color: scheme.onPrimary),
        shape: const RoundedRectangleBorder(borderRadius: AppTokens.pillRadius),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withOpacity(0.16),
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        highlightElevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: AppTokens.cardRadius,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTokens.radiusXl),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radius),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radius),
        ),
        iconColor: scheme.onSurfaceVariant,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? scheme.primary
                : null),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
      ),
    );
  }

  static ThemeData lightTheme() => _build(lightScheme());

  static ThemeData darkTheme() => _build(darkScheme());
}
