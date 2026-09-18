import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';
import 'app_elevation.dart';

abstract final class AppTheme {
  static ThemeData light({required Locale locale}) {
    final typography = AppTypography.forLocale(locale);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.brandPrimary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.brandPrimary,
          onPrimary: Colors.white,
          primaryContainer: AppColors.brandSubtle,
          onPrimaryContainer: AppColors.brandPrimary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          onSurfaceVariant: AppColors.textSecondary,
          error: AppColors.danger,
          onError: Colors.white,
          errorContainer: AppColors.dangerSubtle,
          onErrorContainer: AppColors.danger,
          outline: AppColors.borderDefault,
          outlineVariant: AppColors.borderSubtle,
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
        labelLarge: typography.labelLarge,
        labelMedium: typography.label,
        labelSmall: typography.caption,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.brandPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: shape,
          textStyle: typography.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(0, 46),
          shape: shape,
          side: const BorderSide(color: AppColors.borderDefault),
          textStyle: typography.label,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          minimumSize: const Size(0, 44),
          shape: shape,
          textStyle: typography.label,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        labelStyle: typography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: typography.caption.copyWith(color: AppColors.textMuted),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(
            color: AppColors.brandPrimary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: AppElevation.flat,
        margin: EdgeInsets.zero,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.borderDefault),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        elevation: AppElevation.overlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.panel),
          side: const BorderSide(color: AppColors.borderDefault),
        ),
        backgroundColor: AppColors.surface,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        showDragHandle: true,
        elevation: AppElevation.overlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.panel),
          ),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: typography.label.copyWith(
          color: AppColors.textSecondary,
        ),
        dataTextStyle: typography.bodySmall,
        headingRowColor: const WidgetStatePropertyAll(AppColors.surfaceSubtle),
        dividerThickness: 1,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 52,
      ),
    );
  }

  static ThemeData dark({required Locale locale}) {
    final typography = AppTypography.forLocale(locale);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.brandPrimary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF38BDF8),
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFF1E293B),
          onPrimaryContainer: const Color(0xFF38BDF8),
          surface: const Color(0xFF0F1420),
          onSurface: Colors.white,
          onSurfaceVariant: const Color(0xFF94A3B8),
          error: const Color(0xFFF43F5E),
          onError: Colors.white,
          errorContainer: const Color(0xFF3B1219),
          onErrorContainer: const Color(0xFFFCA5A5),
          outline: const Color(0x33475569),
          outlineVariant: const Color(0x1FFFFFFF),
        );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.control),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: typography.body.fontFamily,
      fontFamilyFallback: const ['Inter', 'NotoSansArabic'],
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF080B11),
      textTheme: TextTheme(
        displayLarge: typography.display.copyWith(color: Colors.white),
        headlineMedium: typography.pageTitle.copyWith(color: Colors.white),
        titleLarge: typography.sectionTitle.copyWith(color: Colors.white),
        titleMedium: typography.cardTitle.copyWith(color: Colors.white),
        bodyLarge: typography.bodyLarge.copyWith(
          color: const Color(0xFFCBD5E1),
        ),
        bodyMedium: typography.body.copyWith(color: const Color(0xFF94A3B8)),
        bodySmall: typography.bodySmall.copyWith(
          color: const Color(0xFF94A3B8),
        ),
        labelLarge: typography.labelLarge.copyWith(color: Colors.white),
        labelMedium: typography.label.copyWith(color: Colors.white),
        labelSmall: typography.caption.copyWith(color: const Color(0xFF64748B)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.brandPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: shape,
          textStyle: typography.label,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF121724),
        labelStyle: typography.bodySmall.copyWith(
          color: const Color(0xFF94A3B8),
        ),
        hintStyle: typography.caption.copyWith(color: const Color(0xFF64748B)),
        prefixIconColor: const Color(0xFF94A3B8),
        suffixIconColor: const Color(0xFF94A3B8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: Color(0x33475569)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: Color(0x33475569)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: Color(0xFFF43F5E)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: Color(0xFFF43F5E), width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: const Color(0xFF0F1420),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: Color(0x26FFFFFF)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x1FFFFFFF),
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        elevation: 16,
        backgroundColor: const Color(0xFF0F1420),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.panel),
          side: const BorderSide(color: Color(0x26FFFFFF)),
        ),
      ),
    );
  }
}
