import 'package:flutter/material.dart';

/// Fursafy Design System — based on Stitch MCP "Digital Curator" theme.
///
/// Primary: Green (#00694c) — "Growth"
/// Secondary: Amber (#855400) — "Vitality"
/// Surface: Warm paper-like neutrals (#faf9f4)
/// Fonts: Plus Jakarta Sans (headlines) + Manrope (body)
class FursafyTheme {
  FursafyTheme._();

  // ─── Brand Colors ───
  static const Color primary = Color(0xFF00694C);
  static const Color primaryContainer = Color(0xFF008560);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFF5FFF7);

  static const Color secondary = Color(0xFF855400);
  static const Color secondaryContainer = Color(0xFFFCAA33);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF6B4200);

  static const Color tertiary = Color(0xFF993F3A);
  static const Color tertiaryContainer = Color(0xFFB85751);
  static const Color onTertiary = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);

  // ─── Surface Tiers (stacked paper sheets) ───
  static const Color surface = Color(0xFFFAF9F4);
  static const Color surfaceBright = Color(0xFFFAF9F4);
  static const Color surfaceDim = Color(0xFFDBDAD5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F4EE);
  static const Color surfaceContainer = Color(0xFFEFEEE9);
  static const Color surfaceContainerHigh = Color(0xFFE9E8E3);
  static const Color surfaceContainerHighest = Color(0xFFE3E3DD);

  // ─── On-Surface ───
  static const Color onSurface = Color(0xFF1A1C19);
  static const Color onSurfaceVariant = Color(0xFF3D4943);
  static const Color outline = Color(0xFF6D7A73);
  static const Color outlineVariant = Color(0xFFBCCAC1);

  // ─── Inverse ───
  static const Color inverseSurface = Color(0xFF2F312D);
  static const Color inverseOnSurface = Color(0xFFF1F1EB);
  static const Color inversePrimary = Color(0xFF68DBAE);

  // ─── Fixed Colors ───
  static const Color primaryFixed = Color(0xFF86F8C9);
  static const Color primaryFixedDim = Color(0xFF68DBAE);
  static const Color onPrimaryFixed = Color(0xFF002115);
  static const Color secondaryFixed = Color(0xFFFFDDB7);
  static const Color secondaryFixedDim = Color(0xFFFFB95D);
  static const Color onSecondaryFixed = Color(0xFF2A1700);
  static const Color tertiaryFixed = Color(0xFFFFDAD6);
  static const Color tertiaryFixedDim = Color(0xFFFFB3AD);
  static const Color onTertiaryFixed = Color(0xFF410003);

  // ─── Typography ───
  static const String headlineFont = 'PlusJakartaSans';
  static const String bodyFont = 'Manrope';

  static TextStyle get headlineStyle => const TextStyle(fontFamily: headlineFont);
  static TextStyle get bodyStyle => const TextStyle(fontFamily: bodyFont);
  static TextStyle get labelStyle => const TextStyle(fontFamily: bodyFont);

  // ─── Spacing Scale ───
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // ─── Roundness Scale ───
  static const double radiusSm = 4.0; // 0.25rem — checkboxes
  static const double radiusDefault = 8.0; // 0.5rem — standard inputs
  static const double radiusMd = 12.0; // 0.75rem — smaller cards
  static const double radiusLg = 16.0; // 1rem — feature cards, modals
  static const double radiusXl = 24.0; // 1.5rem — bottom sheets, hero
  static const double radiusFull = 100.0; // buttons, chips, search bars

  // ─── Elevation / Shadows ───
  // Per design system: ambient shadows, large blur, ultra-low opacity, tinted
  static List<BoxShadow> get ambientShadow => [
        BoxShadow(
          color: onSurface.withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get floatingShadow => [
        BoxShadow(
          color: onSurface.withValues(alpha: 0.08),
          blurRadius: 40,
          offset: const Offset(0, 8),
        ),
      ];

  // ─── Ghost Border ───
  // Per design system: outline_variant at 15% opacity
  static Border get ghostBorder => Border.all(
        color: outlineVariant.withValues(alpha: 0.15),
        width: 1,
      );

  // ─── Theme Data ───
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      surfaceBright: surfaceBright,
      surfaceDim: surfaceDim,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      fontFamily: bodyFont,

      // ─── App Bar ───
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: headlineFont,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
      ),

      // ─── Bottom Navigation ───
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceContainerLowest.withValues(alpha: 0.85),
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontFamily: bodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: bodyFont,
          fontSize: 12,
        ),
      ),

      // ─── Cards ───
      // Per design system: no borders, surface tier shifts, ambient shadows
      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        margin: const EdgeInsets.symmetric(vertical: spacing8),
      ),

      // ─── Buttons ───
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: const TextStyle(
            fontFamily: headlineFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          side: BorderSide(color: outlineVariant.withValues(alpha: 0.3)),
          textStyle: const TextStyle(
            fontFamily: headlineFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontFamily: headlineFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
      ),

      // ─── Input Fields ───
      // Per design system: filled style, surface-container-highest bg,
      // no border; on focus: surface-container-low bg + 2px primary bottom
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing16,
        ),
        hintStyle: TextStyle(
          fontFamily: bodyFont,
          color: onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          fontFamily: bodyFont,
          color: onSurfaceVariant,
          fontSize: 14,
        ),
      ),

      // ─── Chips ───
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainerLow,
        selectedColor: primaryFixed,
        labelStyle: const TextStyle(
          fontFamily: bodyFont,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing12,
          vertical: spacing4,
        ),
      ),

      // ─── Dialog ───
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),

      // ─── Bottom Sheet ───
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: outlineVariant,
      ),

      // ─── Snack Bar ───
      snackBarTheme: SnackBarThemeData(
        backgroundColor: inverseSurface,
        contentTextStyle: const TextStyle(
          fontFamily: bodyFont,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ─── Divider ───
      // Per design system: NO dividers — but if absolutely needed, use subtle
      dividerTheme: DividerThemeData(
        color: outlineVariant.withValues(alpha: 0.15),
        thickness: 1,
        space: spacing16,
      ),

      // ─── Text Theme ───
      textTheme: const TextTheme(
        // Display — Plus Jakarta Sans, editorial hero
        displayLarge: TextStyle(
          fontFamily: headlineFont,
          fontSize: 57,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: onSurface,
        ),
        displayMedium: TextStyle(
          fontFamily: headlineFont,
          fontSize: 45,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        displaySmall: TextStyle(
          fontFamily: headlineFont,
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),

        // Headline — Plus Jakarta Sans, section headers
        headlineLarge: TextStyle(
          fontFamily: headlineFont,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        headlineMedium: TextStyle(
          fontFamily: headlineFont,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        headlineSmall: TextStyle(
          fontFamily: headlineFont,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),

        // Title — Manrope, functional voice
        titleLarge: TextStyle(
          fontFamily: bodyFont,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        titleMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        titleSmall: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),

        // Body — Manrope, readability
        bodyLarge: TextStyle(
          fontFamily: bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onSurface,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onSurface,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontFamily: bodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
          height: 1.4,
        ),

        // Label — Manrope, metadata
        labelLarge: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        labelMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: onSurfaceVariant,
        ),
        labelSmall: TextStyle(
          fontFamily: bodyFont,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
