import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized border definitions for the Bitlogix ERP design system.
///
/// Follows 2026 enterprise SaaS aesthetic standards: clean, structured,
/// subtle borders that create visible content containers without visual noise.
abstract final class AppBorders {
  // Border widths
  static const double widthThin = 1.0;
  static const double widthMedium = 1.5;
  static const double widthThick = 2.0;

  // Standard BorderSides
  static const BorderSide none = BorderSide.none;

  /// Subtle border for low-emphasis dividers, secondary cards, and table rows.
  static const BorderSide subtle = BorderSide(
    color: AppColors.borderSubtle,
    width: widthThin,
  );

  /// Default border for inputs, standard cards, buttons, and panels.
  static const BorderSide thin = BorderSide(
    color: AppColors.borderDefault,
    width: widthThin,
  );

  /// Strong border for hovered states or emphasized content dividers.
  static const BorderSide strong = BorderSide(
    color: AppColors.borderStrong,
    width: widthThin,
  );

  /// Interactive border for clickable controls, chips, and unselected states.
  static const BorderSide interactive = BorderSide(
    color: AppColors.borderInteractive,
    width: widthThin,
  );

  /// Brand-accented border for highlighted cards, badges, and primary outlines.
  static const BorderSide brand = BorderSide(
    color: AppColors.brandBorder,
    width: widthThin,
  );

  /// Focused state border with increased stroke width.
  static const BorderSide focused = BorderSide(
    color: AppColors.borderFocus,
    width: widthMedium,
  );

  /// Error state border for validation failures.
  static const BorderSide error = BorderSide(
    color: AppColors.borderError,
    width: widthThin,
  );

  /// Success state border.
  static const BorderSide success = BorderSide(
    color: AppColors.borderSuccess,
    width: widthThin,
  );

  /// Warning state border.
  static const BorderSide warning = BorderSide(
    color: AppColors.borderWarning,
    width: widthThin,
  );

  // Reusable BoxBorder helpers
  static const Border allSubtle = Border.fromBorderSide(subtle);
  static const Border allThin = Border.fromBorderSide(thin);
  static const Border allInteractive = Border.fromBorderSide(interactive);
  static const Border allBrand = Border.fromBorderSide(brand);

  static const Border bottomSubtle = Border(bottom: subtle);
  static const Border bottomThin = Border(bottom: thin);
  static const Border topSubtle = Border(top: subtle);
  static const Border topThin = Border(top: thin);
}
