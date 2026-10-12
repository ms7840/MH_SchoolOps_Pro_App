import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

/// Central ThemeData definitions for Light and Dark modes.
class AppTheme {
  const AppTheme._();

  static ThemeData lightTheme({Color? primaryColor, Color? secondaryColor}) {
    final primary = primaryColor ?? AppColors.primaryNavy;
    final secondary = secondaryColor ?? AppColors.primaryBlue;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: AppColors.lightSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.lightTextPrimary),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.lightTextPrimary),
        headlineLarge: AppTextStyles.headingLarge.copyWith(color: AppColors.lightTextPrimary),
        headlineMedium: AppTextStyles.headingMedium.copyWith(color: AppColors.lightTextPrimary),
        headlineSmall: AppTextStyles.headingSmall.copyWith(color: AppColors.lightTextPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.lightTextPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightTextSecondary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.lightTextMuted),
        labelLarge: AppTextStyles.button.copyWith(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          borderSide: BorderSide(color: secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightTextMuted),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightTextSecondary),
      ),
    );
  }

  static ThemeData darkTheme({Color? primaryColor, Color? secondaryColor}) {
    final primary = primaryColor ?? AppColors.primaryBlue;
    final secondary = secondaryColor ?? AppColors.primaryAccentCyan;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.darkTextPrimary),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.darkTextPrimary),
        headlineLarge: AppTextStyles.headingLarge.copyWith(color: AppColors.darkTextPrimary),
        headlineMedium: AppTextStyles.headingMedium.copyWith(color: AppColors.darkTextPrimary),
        headlineSmall: AppTextStyles.headingSmall.copyWith(color: AppColors.darkTextPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkTextPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.darkTextMuted),
        labelLarge: AppTextStyles.button.copyWith(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          borderSide: BorderSide(color: secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextMuted),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
      ),
    );
  }
}
