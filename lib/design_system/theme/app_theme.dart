import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';
import 'app_borders.dart';
import 'app_elevation.dart';
import 'app_dimensions.dart';

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
        labelSmall: typography.labelSmall,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: AppDimensions.iconMd,
      ),
      primaryIconTheme: const IconThemeData(
        color: AppColors.textOnAccent,
        size: AppDimensions.iconMd,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.brandPrimary,
        selectionColor: AppColors.brandPrimary.withValues(alpha: 0.18),
        selectionHandleColor: AppColors.brandPrimary,
      ),
      focusColor: AppColors.brandPrimary.withValues(alpha: 0.10),
      hoverColor: AppColors.surfaceHover,
      splashFactory: InkSparkle.splashFactory,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.brandPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, AppDimensions.buttonHeightMd),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: buttonShape,
          textStyle: typography.button,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.brandPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, AppDimensions.buttonHeightMd),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: buttonShape,
          textStyle: typography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(0, AppDimensions.buttonHeightMd),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: buttonShape,
          side: AppBorders.thin,
          textStyle: typography.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandPrimary,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: buttonShape,
          textStyle: typography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        isDense: true,
        constraints: const BoxConstraints(minHeight: AppDimensions.inputHeight),
        labelStyle: typography.formLabel.copyWith(
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: typography.formLabel.copyWith(
          color: AppColors.brandPrimary,
        ),
        helperStyle: typography.caption.copyWith(color: AppColors.textTertiary),
        hintStyle: typography.body.copyWith(color: AppColors.textDisabled),
        errorStyle: typography.caption.copyWith(color: AppColors.danger),
        prefixIconColor: AppColors.textTertiary,
        suffixIconColor: AppColors.textTertiary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusXs),
        ),
        side: AppBorders.interactive,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: VisualDensity.standard,
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.brandPrimary.withValues(alpha: 0.45);
            }
            return AppColors.surfaceDisabled;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.brandPrimary;
          }
          return AppColors.surface;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return AppColors.brandPrimary.withValues(alpha: 0.14);
          }
          if (states.contains(WidgetState.hovered)) {
            return AppColors.brandPrimary.withValues(alpha: 0.08);
          }
          return Colors.transparent;
        }),
      ),
      radioTheme: RadioThemeData(
        materialTapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: VisualDensity.standard,
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.textDisabled;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.brandPrimary;
          }
          return AppColors.borderInteractive;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return AppColors.brandPrimary.withValues(alpha: 0.14);
          }
          if (states.contains(WidgetState.hovered)) {
            return AppColors.brandPrimary.withValues(alpha: 0.08);
          }
          return Colors.transparent;
        }),
      ),
      // Proper ON/OFF separation: an outlined neutral track with a white thumb
      // when OFF, and a solid brand track with a white thumb when ON. Never a
      // single filled "blob".
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.surface;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.brandPrimary.withValues(alpha: 0.35);
            }
            return AppColors.surfaceDisabled;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.brandPrimary;
          }
          return AppColors.surfaceMuted;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected) ||
              states.contains(WidgetState.disabled)) {
            return Colors.transparent;
          }
          return AppColors.borderInteractive;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return AppColors.brandPrimary.withValues(alpha: 0.14);
          }
          if (states.contains(WidgetState.hovered)) {
            return AppColors.textPrimary.withValues(alpha: 0.06);
          }
          return Colors.transparent;
        }),
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
          primary: AppColors.darkBrand,
          onPrimary: AppColors.darkBrandOn,
          primaryContainer: AppColors.brandPressed,
          onPrimaryContainer: AppColors.brandSubtle,
          secondary: const Color(0xFFC784A7),
          onSecondary: AppColors.darkBrandOn,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          surfaceContainerLowest: AppColors.darkBackground,
          surfaceContainerLow: AppColors.darkSurface,
          surfaceContainer: AppColors.darkSurfaceRaised,
          surfaceContainerHigh: AppColors.darkSurfaceMuted,
          surfaceContainerHighest: AppColors.darkSurfaceHover,
          onSurfaceVariant: AppColors.darkTextSecondary,
          error: AppColors.darkDanger,
          onError: Colors.white,
          errorContainer: const Color(0xFF3B1219),
          onErrorContainer: const Color(0xFFFCA5A5),
          outline: AppColors.darkBorder,
          outlineVariant: AppColors.darkBorderSubtle,
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
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: TextTheme(
        displayLarge: typography.display.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        headlineMedium: typography.pageTitle.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        titleLarge: typography.sectionTitle.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        titleMedium: typography.cardTitle.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        bodyLarge: typography.bodyLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        bodyMedium: typography.body.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        bodySmall: typography.bodySmall.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        labelLarge: typography.labelLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        labelMedium: typography.label.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        labelSmall: typography.labelSmall.copyWith(
          color: AppColors.darkTextTertiary,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.darkTextSecondary,
        size: AppDimensions.iconMd,
      ),
      primaryIconTheme: const IconThemeData(
        color: AppColors.darkBrandOn,
        size: AppDimensions.iconMd,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.darkBrand,
        selectionColor: AppColors.darkBrand.withValues(alpha: 0.22),
        selectionHandleColor: AppColors.darkBrand,
      ),
      focusColor: AppColors.darkBrand.withValues(alpha: 0.14),
      hoverColor: AppColors.darkSurfaceHover,
      splashFactory: InkSparkle.splashFactory,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.darkBrand,
          foregroundColor: AppColors.darkBrandOn,
          minimumSize: const Size(0, AppDimensions.buttonHeightMd),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: buttonShape,
          textStyle: typography.button,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.darkBrand,
          foregroundColor: AppColors.darkBrandOn,
          minimumSize: const Size(0, AppDimensions.buttonHeightMd),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: buttonShape,
          textStyle: typography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: AppColors.darkTextPrimary,
          minimumSize: const Size(0, AppDimensions.buttonHeightMd),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: buttonShape,
          side: const BorderSide(color: AppColors.darkBorder),
          textStyle: typography.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkBrand,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: buttonShape,
          textStyle: typography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceRaised,
        isDense: true,
        constraints: const BoxConstraints(minHeight: AppDimensions.inputHeight),
        labelStyle: typography.formLabel.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        floatingLabelStyle: typography.formLabel.copyWith(
          color: AppColors.darkBrand,
        ),
        helperStyle: typography.caption.copyWith(
          color: AppColors.darkTextTertiary,
        ),
        hintStyle: typography.body.copyWith(color: AppColors.darkTextDisabled),
        errorStyle: typography.caption.copyWith(color: AppColors.darkDanger),
        prefixIconColor: AppColors.darkTextTertiary,
        suffixIconColor: AppColors.darkTextTertiary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.darkBrand, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.darkDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.darkDanger, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.darkBorderSubtle),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.darkSurfaceSelected,
        disabledColor: AppColors.darkSurfaceDisabled,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: typography.labelMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        secondaryLabelStyle: typography.labelMedium.copyWith(
          color: AppColors.darkBrand,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
          side: const BorderSide(color: AppColors.darkBorderSubtle),
        ),
        side: const BorderSide(color: AppColors.darkBorderSubtle),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusXs),
        ),
        side: const BorderSide(color: AppColors.darkBorderStrong),
        materialTapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: VisualDensity.standard,
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.darkBrand.withValues(alpha: 0.4);
            }
            return AppColors.darkSurfaceDisabled;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkBrand;
          }
          return AppColors.darkSurface;
        }),
        checkColor: const WidgetStatePropertyAll(AppColors.darkBrandOn),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return AppColors.darkBrand.withValues(alpha: 0.18);
          }
          if (states.contains(WidgetState.hovered)) {
            return AppColors.darkBrand.withValues(alpha: 0.10);
          }
          return Colors.transparent;
        }),
      ),
      radioTheme: RadioThemeData(
        materialTapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: VisualDensity.standard,
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.darkTextDisabled;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkBrand;
          }
          return AppColors.darkTextSecondary;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return AppColors.darkBrand.withValues(alpha: 0.18);
          }
          if (states.contains(WidgetState.hovered)) {
            return AppColors.darkBrand.withValues(alpha: 0.10);
          }
          return Colors.transparent;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.darkSurface;
          }
          return AppColors.darkBrandOn;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.darkBrand.withValues(alpha: 0.4);
            }
            return AppColors.darkSurfaceDisabled;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkBrand;
          }
          return AppColors.darkSurfaceMuted;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected) ||
              states.contains(WidgetState.disabled)) {
            return Colors.transparent;
          }
          return AppColors.darkBorderStrong;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return AppColors.darkBrand.withValues(alpha: 0.18);
          }
          if (states.contains(WidgetState.hovered)) {
            return AppColors.darkTextPrimary.withValues(alpha: 0.08);
          }
          return Colors.transparent;
        }),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkSurfaceRaised,
        elevation: AppElevation.overlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusMd),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        textStyle: typography.body.copyWith(color: Colors.white),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(
            AppColors.darkSurfaceRaised,
          ),
          elevation: const WidgetStatePropertyAll(8),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMd),
              side: const BorderSide(color: AppColors.darkBorder),
            ),
          ),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(
            AppColors.darkSurfaceRaised,
          ),
          elevation: const WidgetStatePropertyAll(8),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMd),
              side: const BorderSide(color: AppColors.darkBorder),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurfaceRaised,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceHover,
          borderRadius: BorderRadius.circular(AppRadius.radiusXs),
        ),
        textStyle: typography.caption.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkSurfaceHover,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusMd),
        ),
        contentTextStyle: typography.bodySmall.copyWith(color: Colors.white),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.darkBrand,
        linearTrackColor: AppColors.brandPressed,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedIconTheme: const IconThemeData(color: AppColors.darkBrand),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.darkTextSecondary,
        ),
        selectedLabelTextStyle: typography.label.copyWith(
          color: AppColors.darkBrand,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: typography.label.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        indicatorColor: AppColors.brandPressed,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.brandPressed,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkBrand,
        unselectedItemColor: AppColors.darkTextSecondary,
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
          color: AppColors.darkTextSecondary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorderSubtle,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        elevation: AppElevation.overlay,
        backgroundColor: AppColors.darkSurfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.darkSurfaceRaised,
        headerBackgroundColor: AppColors.brandPressed,
        headerForegroundColor: AppColors.darkBrand,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.darkSurfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurfaceRaised,
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
          color: AppColors.darkTextSecondary,
        ),
        dataTextStyle: typography.bodySmall.copyWith(color: Colors.white),
        headingRowColor: const WidgetStatePropertyAll(
          AppColors.darkSurfaceRaised,
        ),
        dividerThickness: 1,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 52,
      ),
    );
  }
}
