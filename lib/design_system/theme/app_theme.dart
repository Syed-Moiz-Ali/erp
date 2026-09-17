import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';
import 'app_elevation.dart';

abstract final class AppTheme {
  static ThemeData light({required Locale locale}) {
    final typography = AppTypography.forLocale(locale);
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.brand).copyWith(
      primary: AppColors.brand,
      surface: AppColors.surface,
      error: AppColors.danger,
      onSurface: AppColors.textPrimary,
      outline: AppColors.border,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.control),
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: typography.body.fontFamily,
      fontFamilyFallback: const ['Inter', 'NotoSansArabic'],
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: TextTheme(
        displayLarge: typography.display,
        headlineMedium: typography.pageTitle,
        titleLarge: typography.sectionTitle,
        titleMedium: typography.cardTitle,
        bodyLarge: typography.bodyLarge,
        bodyMedium: typography.body,
        bodySmall: typography.bodySmall,
        labelLarge: typography.label,
        labelSmall: typography.caption,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: shape,
          textStyle: typography.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          shape: shape,
          side: const BorderSide(color: AppColors.border),
          textStyle: typography.label,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 44),
          shape: shape,
          textStyle: typography.label,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        labelStyle: typography.bodySmall,
        hintStyle: typography.caption,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.brand, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: AppElevation.flat,
        margin: EdgeInsets.zero,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.panel),
        ),
        backgroundColor: AppColors.surface,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        showDragHandle: true,
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: typography.label,
        dataTextStyle: typography.bodySmall,
        headingRowColor: const WidgetStatePropertyAll(AppColors.background),
        dividerThickness: 1,
      ),
    );
  }
}
