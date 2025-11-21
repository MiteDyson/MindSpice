import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  /// Helper to load a TextTheme dynamically by font name.
  static TextTheme _getTextTheme(String font, TextTheme base) {
    // GoogleFonts.asMap() allows looking up the font function by string name.
    // Each entry is a TextStyle generator (accepts `textStyle`), so apply it to
    // every TextStyle in the base TextTheme to produce a themed TextTheme.
    final fontGenerator = GoogleFonts.asMap()[font];

    if (fontGenerator != null) {
      TextStyle? applyStyle(TextStyle? style) =>
          style == null ? null : fontGenerator(textStyle: style);

      return base.copyWith(
        displayLarge: applyStyle(base.displayLarge),
        displayMedium: applyStyle(base.displayMedium),
        displaySmall: applyStyle(base.displaySmall),
        headlineLarge: applyStyle(base.headlineLarge),
        headlineMedium: applyStyle(base.headlineMedium),
        headlineSmall: applyStyle(base.headlineSmall),
        titleLarge: applyStyle(base.titleLarge),
        titleMedium: applyStyle(base.titleMedium),
        titleSmall: applyStyle(base.titleSmall),
        bodyLarge: applyStyle(base.bodyLarge),
        bodyMedium: applyStyle(base.bodyMedium),
        bodySmall: applyStyle(base.bodySmall),
        labelLarge: applyStyle(base.labelLarge),
        labelMedium: applyStyle(base.labelMedium),
        labelSmall: applyStyle(base.labelSmall),
      );
    }

    // Fallback if the font name is invalid
    return GoogleFonts.robotoTextTheme(base);
  }

  static ThemeData light(String font) {
    final base = ThemeData.light();
    final textTheme = _getTextTheme(
      font,
      base.textTheme,
    ).apply(bodyColor: AppColors.lightText, displayColor: AppColors.lightText);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.lightPrimary,
        primary: AppColors.lightPrimary,
        secondary: AppColors.lightSecondary,
        surface: AppColors.lightSurface,
        surfaceContainerHighest: AppColors.lightBg,
        onSurface: AppColors.lightText,
        outline: AppColors.lightBorder,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBg,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.lightText),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.lightText,
        ),
        // GitHub apps often have a subtle border under the header
        shape: const Border(bottom: BorderSide(color: AppColors.lightBorder)),
      ),
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        elevation: 0, // Flat look
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightSecondary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      textTheme: textTheme,
    );
  }

  static ThemeData dark(String font) {
    final base = ThemeData.dark();
    final textTheme = _getTextTheme(
      font,
      base.textTheme,
    ).apply(bodyColor: AppColors.darkText, displayColor: AppColors.darkText);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkPrimary,
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        surface: AppColors.darkSurface,
        surfaceContainerHighest: AppColors.darkContainer,
        onSurface: AppColors.darkText,
        outline: AppColors.darkBorder,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
        shape: const Border(bottom: BorderSide(color: AppColors.darkBorder)),
      ),
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkSecondary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      textTheme: textTheme,
    );
  }
}
