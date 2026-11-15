import 'package:flutter/material.dart';

/// Spacing & sizing constants used across the app.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double screenPadding = 16;
  static const double cardRadius = 12;
}

/// Brand-ish palette defaults. Actual brand colors come from [BrandProfile].
class AppColors {
  AppColors._();

  /// Navy blue used in the reference poster footer badge.
  static const Color brandNavy = Color(0xFF1B3A6B);

  /// Yellow accent used in the reference poster footer badge.
  static const Color brandYellow = Color(0xFFF2B705);

  /// Poster background (soft blue-grey gradient end color).
  static const Color posterBgEnd = Color(0xFFD9E2EC);

  /// Default slot placeholder fill.
  static const Color slotPlaceholder = Color(0xFFE8EDF2);
}

/// Application theme built around the institutional brand palette.
final class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brandNavy,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        isDense: true,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),
    );
  }
}

