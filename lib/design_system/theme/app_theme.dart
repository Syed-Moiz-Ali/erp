import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';
import 'app_borders.dart';
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
          secondary: AppColors.brandSecondary,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.brandSoft,
          onSecondaryContainer: AppColors.brandSecondary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          surfaceContainerLowest: AppColors.surface,
          surfaceContainerLow: AppColors.surfaceSubtle,
          surfaceContainer: AppColors.surfaceSecondary,
          surfaceContainerHigh: AppColors.surfaceMuted,
          surfaceContainerHighest: AppColors.surfaceDisabled,
          onSurfaceVariant: AppColors.textSecondary,
          error: AppColors.danger,
          onError: Colors.white,
          errorContainer: AppColors.dangerSubtle,
          onErrorContainer: AppColors.danger,
          outline: AppColors.borderDefault,
          outlineVariant: AppColors.borderSubtle,
        );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: typography.body.fontFamily,
      fontFamilyFallback: const [
        AppTypography.latinFamily,
        AppTypography.arabicFamily,
      ],
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
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: buttonShape,
          textStyle: typography.label,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.brandPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: buttonShape,
          textStyle: typography.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: buttonShape,
          side: AppBorders.thin,
          textStyle: typography.label,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandPrimary,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: buttonShape,
          textStyle: typography.label,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        labelStyle: typography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: typography.caption.copyWith(color: AppColors.textMuted),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: AppBorders.thin,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: AppBorders.thin,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: AppBorders.focused,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: AppBorders.error,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(
            color: AppColors.borderError,
            width: AppBorders.widthMedium,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: AppElevation.flat,
        margin: EdgeInsets.zero,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: AppBorders.subtle,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.brandSubtle,
        disabledColor: AppColors.surfaceDisabled,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: typography.labelMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        secondaryLabelStyle: typography.labelMedium.copyWith(
          color: AppColors.brandPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
          side: AppBorders.subtle,
        ),
        side: AppBorders.subtle,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: AppBorders.thin,
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.surfaceDisabled;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.brandPrimary;
          }
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.textDisabled;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.brandPrimary;
          }
          return AppColors.borderInteractive;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.brandPrimary;
          }
          return AppColors.borderDefault;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        elevation: 4,
        shadowColor: const Color(0x1A120815),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusMd),
          side: AppBorders.subtle,
        ),
        textStyle: typography.body,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
          elevation: const WidgetStatePropertyAll(4),
          shadowColor: const WidgetStatePropertyAll(Color(0x1A120815)),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMd),
              side: AppBorders.subtle,
            ),
          ),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
          elevation: const WidgetStatePropertyAll(4),
          shadowColor: const WidgetStatePropertyAll(Color(0x1A120815)),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMd),
              side: AppBorders.subtle,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: AppBorders.thin,
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(AppRadius.radiusXs),
        ),
        textStyle: typography.caption.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusMd),
        ),
        contentTextStyle: typography.bodySmall.copyWith(color: Colors.white),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brandPrimary,
        linearTrackColor: AppColors.brandSubtle,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        selectedIconTheme: const IconThemeData(color: AppColors.brandPrimary),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.textSecondary,
        ),
        selectedLabelTextStyle: typography.label.copyWith(
          color: AppColors.brandPrimary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: typography.label.copyWith(
          color: AppColors.textSecondary,
        ),
        indicatorColor: AppColors.brandSubtle,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.brandSubtle,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.brandPrimary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: typography.caption.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: typography.caption,
        type: BottomNavigationBarType.fixed,
      ),
      listTileTheme: ListTileThemeData(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusMd),
        ),
        titleTextStyle: typography.body.copyWith(fontWeight: FontWeight.w500),
        subtitleTextStyle: typography.bodySmall.copyWith(
          color: AppColors.textSecondary,
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
        shadowColor: const Color(0x24120815),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
          side: AppBorders.subtle,
        ),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surface,
        headerBackgroundColor: AppColors.brandPrimary,
        headerForegroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
          side: AppBorders.subtle,
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
          side: AppBorders.subtle,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        elevation: AppElevation.overlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.bottomSheet),
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
        dataRowMinHeight: 44,
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
          primary: const Color(0xFFE5A9CE),
          onPrimary: const Color(0xFF4E1736),
          primaryContainer: const Color(0xFF3B0F28),
          onPrimaryContainer: const Color(0xFFF7EFF5),
          secondary: const Color(0xFFC784A7),
          onSecondary: const Color(0xFF3B0F28),
          surface: const Color(0xFF161219),
          onSurface: const Color(0xFFF2EFF5),
          surfaceContainerLowest: const Color(0xFF100D12),
          surfaceContainerLow: const Color(0xFF161219),
          surfaceContainer: const Color(0xFF1E1922),
          surfaceContainerHigh: const Color(0xFF26202B),
          surfaceContainerHighest: const Color(0xFF2E2734),
          onSurfaceVariant: const Color(0xFFA59EAE),
          error: const Color(0xFFF43F5E),
          onError: Colors.white,
          errorContainer: const Color(0xFF3B1219),
          onErrorContainer: const Color(0xFFFCA5A5),
          outline: const Color(0xFF3A3342),
          outlineVariant: const Color(0xFF28232E),
        );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: typography.body.fontFamily,
      fontFamilyFallback: const [
        AppTypography.latinFamily,
        AppTypography.arabicFamily,
      ],
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF100D12),
      textTheme: TextTheme(
        displayLarge: typography.display.copyWith(color: Colors.white),
        headlineMedium: typography.pageTitle.copyWith(color: Colors.white),
        titleLarge: typography.sectionTitle.copyWith(color: Colors.white),
        titleMedium: typography.cardTitle.copyWith(color: Colors.white),
        bodyLarge: typography.bodyLarge.copyWith(
          color: const Color(0xFFE2DEE8),
        ),
        bodyMedium: typography.body.copyWith(color: const Color(0xFFA59EAE)),
        bodySmall: typography.bodySmall.copyWith(
          color: const Color(0xFFA59EAE),
        ),
        labelLarge: typography.labelLarge.copyWith(color: Colors.white),
        labelMedium: typography.label.copyWith(color: Colors.white),
        labelSmall: typography.caption.copyWith(color: const Color(0xFF7C7688)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFE5A9CE),
          foregroundColor: const Color(0xFF4E1736),
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: buttonShape,
          textStyle: typography.label,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFE5A9CE),
          foregroundColor: const Color(0xFF4E1736),
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: buttonShape,
          textStyle: typography.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: buttonShape,
          side: const BorderSide(color: Color(0xFF3A3342)),
          textStyle: typography.label,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFE5A9CE),
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: buttonShape,
          textStyle: typography.label,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1922),
        isDense: true,
        labelStyle: typography.bodySmall.copyWith(
          color: const Color(0xFFA59EAE),
        ),
        hintStyle: typography.caption.copyWith(color: const Color(0xFF7C7688)),
        prefixIconColor: const Color(0xFFA59EAE),
        suffixIconColor: const Color(0xFFA59EAE),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: Color(0xFF3A3342)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: Color(0xFF3A3342)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: Color(0xFFE5A9CE), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: Color(0xFFF43F5E)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: Color(0xFFF43F5E), width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: const Color(0xFF161219),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: Color(0xFF28232E)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF161219),
        selectedColor: const Color(0xFF3B0F28),
        disabledColor: const Color(0xFF28232E),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: typography.labelMedium.copyWith(color: Colors.white),
        secondaryLabelStyle: typography.labelMedium.copyWith(
          color: const Color(0xFFE5A9CE),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
          side: const BorderSide(color: Color(0xFF28232E)),
        ),
        side: const BorderSide(color: Color(0xFF28232E)),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: Color(0xFF3A3342)),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return const Color(0xFF28232E);
          }
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFE5A9CE);
          }
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Color(0xFF4E1736)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return const Color(0xFF7C7688);
          }
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFE5A9CE);
          }
          return const Color(0xFFA59EAE);
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF4E1736);
          }
          return const Color(0xFFA59EAE);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFE5A9CE);
          }
          return const Color(0xFF28232E);
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xFF1E1922),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusMd),
          side: const BorderSide(color: Color(0xFF3A3342)),
        ),
        textStyle: typography.body.copyWith(color: Colors.white),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(Color(0xFF1E1922)),
          elevation: const WidgetStatePropertyAll(8),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMd),
              side: const BorderSide(color: Color(0xFF3A3342)),
            ),
          ),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(Color(0xFF1E1922)),
          elevation: const WidgetStatePropertyAll(8),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMd),
              side: const BorderSide(color: Color(0xFF3A3342)),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1922),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(color: Color(0xFF3A3342)),
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF2E2734),
          borderRadius: BorderRadius.circular(AppRadius.radiusXs),
        ),
        textStyle: typography.caption.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2E2734),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusMd),
        ),
        contentTextStyle: typography.bodySmall.copyWith(color: Colors.white),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFFE5A9CE),
        linearTrackColor: Color(0xFF3B0F28),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: const Color(0xFF161219),
        selectedIconTheme: const IconThemeData(color: Color(0xFFE5A9CE)),
        unselectedIconTheme: const IconThemeData(color: Color(0xFFA59EAE)),
        selectedLabelTextStyle: typography.label.copyWith(
          color: const Color(0xFFE5A9CE),
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: typography.label.copyWith(
          color: const Color(0xFFA59EAE),
        ),
        indicatorColor: const Color(0xFF3B0F28),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF161219),
        indicatorColor: Color(0xFF3B0F28),
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF161219),
        selectedItemColor: const Color(0xFFE5A9CE),
        unselectedItemColor: const Color(0xFFA59EAE),
        selectedLabelStyle: typography.caption.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: typography.caption,
        type: BottomNavigationBarType.fixed,
      ),
      listTileTheme: ListTileThemeData(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusMd),
        ),
        titleTextStyle: typography.body.copyWith(
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        subtitleTextStyle: typography.bodySmall.copyWith(
          color: const Color(0xFFA59EAE),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF28232E),
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF161219),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        elevation: 16,
        backgroundColor: const Color(0xFF1E1922),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
          side: const BorderSide(color: Color(0xFF3A3342)),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: const Color(0xFF1E1922),
        headerBackgroundColor: const Color(0xFF3B0F28),
        headerForegroundColor: const Color(0xFFE5A9CE),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
          side: const BorderSide(color: Color(0xFF3A3342)),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: const Color(0xFF1E1922),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
          side: const BorderSide(color: Color(0xFF3A3342)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1E1922),
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.bottomSheet),
          ),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: typography.label.copyWith(
          color: const Color(0xFFA59EAE),
        ),
        dataTextStyle: typography.bodySmall.copyWith(color: Colors.white),
        headingRowColor: const WidgetStatePropertyAll(Color(0xFF1E1922)),
        dividerThickness: 1,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 52,
      ),
    );
  }
}
