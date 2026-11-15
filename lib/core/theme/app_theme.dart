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
  static const double buttonRadius = 28;
}

/// "Pengayoman" institutional palette.
///
/// Base: white. Primary: dark blue #1B2C5D. Accent: golden yellow #FFCB05.
class AppColors {
  AppColors._();

  // --- Core brand ---
  /// Dark blue — primary (HEX #1B2C5D, CMYK 100-90-30-30).
  static const Color primary = Color(0xFF1B2C5D);

  /// Golden yellow — accent (HEX #FFCB05, CMYK 0-20-100-0).
  static const Color accent = Color(0xFFFFCB05);

  /// White base — backgrounds.
  static const Color base = Color(0xFFFFFFFF);

  // --- Derived ---
  /// Text/icons on top of primary.
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Text/icons on top of accent (navy reads better than black).
  static const Color onAccent = Color(0xFF1B2C5D);

  /// Primary at ~10% — selected chips, highlighted cards.
  static const Color primaryContainer = Color(0xFFE4E8F1);

  /// Soft blue-grey — input fill, cards, wireframe background.
  static const Color surfaceVariant = Color(0xFFF4F6FA);

  /// Borders, dividers, disabled outlines.
  static const Color outline = Color(0xFFC5CDD9);

  /// Body text.
  static const Color onSurface = Color(0xFF1F2430);

  /// Secondary/caption text.
  static const Color onSurfaceMuted = Color(0xFF5B6472);

  /// Success states (e.g. "caption tersalin").
  static const Color success = Color(0xFF1E8E3E);

  /// Poster background gradient end (soft blue-grey).
  static const Color posterBgEnd = Color(0xFFD9E2EC);

  /// Default slot placeholder fill.
  static const Color slotPlaceholder = Color(0xFFE8EDF2);
}

/// Application theme — white base, navy primary, golden accent.
final class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const navy = AppColors.primary;
    const yellow = AppColors.accent;
    final scheme = ColorScheme.light(
      primary: navy,
      onPrimary: AppColors.onPrimary,
      secondary: navy,
      onSecondary: AppColors.onPrimary,
      tertiary: yellow,
      onTertiary: AppColors.onAccent,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: navy,
      surface: AppColors.base,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.onSurfaceMuted,
      outline: AppColors.outline,
      error: const Color(0xFFB3261E),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.base,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.base,
        foregroundColor: navy,
        surfaceTintColor: AppColors.base,
        titleTextStyle: TextStyle(
          color: navy,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.base,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: const BorderSide(color: AppColors.outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          borderSide: const BorderSide(color: navy, width: 1.6),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
        side: const BorderSide(color: AppColors.outline),
        selectedColor: navy,
        backgroundColor: AppColors.base,
        labelStyle: const TextStyle(color: AppColors.onSurface),
        secondaryLabelStyle: const TextStyle(color: AppColors.onPrimary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navy,
          side: const BorderSide(color: navy, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: yellow,
        foregroundColor: AppColors.onAccent,
        shape: CircleBorder(),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppColors.outline),
          ),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.onPrimary;
            }
            return AppColors.onSurface;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.base;
          }),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: navy,
        contentTextStyle: const TextStyle(color: AppColors.onPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.outline),
    );
  }
}


