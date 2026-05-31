import 'package:flutter/material.dart';

/// Vogue Vault — a fresh, modern palette built for an "editorial beauty" feel.
///
/// The brand leads with a refined orchid/violet, paired with a warm coral
/// accent and a calm teal. Neutrals carry a subtle lavender tint so large
/// surfaces feel premium rather than clinical. Dark mode uses a deep
/// plum-charcoal with luminous accents tuned for long evening sessions.
class AppColors {
  AppColors._();

  // --- Brand ---
  /// Primary brand colour — deep orchid/violet.
  static const Color primary = Color(0xFF6C4AB6);

  /// Lighter brand tone used for gradients and highlights.
  static const Color primaryBright = Color(0xFF8E6FE0);

  /// Warm coral accent for energetic, friendly moments.
  static const Color secondary = Color(0xFFFF6F91);

  /// Calm teal for supporting accents and success-adjacent states.
  static const Color tertiary = Color(0xFF1FB5A3);

  // --- Light neutrals ---
  /// App background behind cards — soft lavender-tinted gray.
  static const Color scaffoldLight = Color(0xFFF6F4FB);

  /// Cards, sheets, nav surfaces.
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Inputs, chips, subtle raised areas.
  static const Color surfaceVariantLight = Color(0xFFEDEAF6);

  /// Primary body text.
  static const Color textPrimary = Color(0xFF1E1A2B);

  /// Secondary labels and captions.
  static const Color textSecondary = Color(0xFF6B6580);

  /// Hairline borders and dividers.
  static const Color outlineLight = Color(0xFFDED9EC);

  // --- Dark neutrals ---
  static const Color scaffoldDark = Color(0xFF131019);
  static const Color surfaceDark = Color(0xFF1C1827);
  static const Color surfaceVariantDark = Color(0xFF2A2438);
  static const Color textPrimaryDark = Color(0xFFF2EFFA);
  static const Color textSecondaryDark = Color(0xFFB6AFCB);
  static const Color outlineDark = Color(0xFF3C354F);

  // --- Dark accents ---
  static const Color primaryDark = Color(0xFFC7B0FF);
  static const Color primaryBrightDark = Color(0xFFB59BF6);
  static const Color secondaryDark = Color(0xFFFFB1C1);
  static const Color tertiaryDark = Color(0xFF7DDDD0);

  // --- Service-type accents ---
  static const Color serviceBarber = Color(0xFF6C4AB6);
  static const Color serviceHairdresser = Color(0xFFEF7A5A);
  static const Color serviceNails = Color(0xFFE0589B);
  static const Color serviceTattoo = Color(0xFF2E6FB0);

  // --- Status ---
  static const Color success = Color(0xFF2BB673);
  static const Color warning = Color(0xFFE0A33E);
  static const Color danger = Color(0xFFE5484D);

  // --- Gradients ---
  /// Hero gradient used on dashboard headers and feature surfaces.
  static const List<Color> brandGradient = [
    Color(0xFF6C4AB6),
    Color(0xFF8E6FE0),
  ];

  static const List<Color> brandGradientDark = [
    Color(0xFF4C3585),
    Color(0xFF6C4AB6),
  ];

  // --- Backwards-compatible aliases (older call sites) ---
  static const Color background = scaffoldLight;
  static const Color surfaceVariant = surfaceVariantLight;
  static const Color textDark = textPrimary;
  static const Color darkBackground = scaffoldDark;
  static const Color darkSurfaceVariant = surfaceVariantDark;
  static const Color textLight = textPrimaryDark;
  static const Color highlight = Color(0xFFEDEAF6);
}
