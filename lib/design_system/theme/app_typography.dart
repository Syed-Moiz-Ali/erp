import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized semantic type scale for Bitlogix ERP.
///
/// This is the **only** place font sizes, weights, line heights and tracking
/// are defined. Screens must consume a semantic style
/// (`context`-resolved [AppTypography]) or one of the Material [TextTheme]
/// slots bridged by `AppTheme`, never a raw `TextStyle(fontSize: ...)`.
///
/// Weight discipline: the interface uses 400 / 500 / 600 almost exclusively;
/// 700 is reserved for the page/display tier. Sizes are calibrated to the
/// bundled Manrope (Latin) and IBM Plex Sans Arabic families.
class AppTypography {
  /// Centralized font families. Feature widgets must never hardcode these.
  static const latinFamily = 'Manrope';
  static const arabicFamily = 'IBMPlexSansArabic';

  /// Deliberate, non-arbitrary weight set.
  static const weightRegular = FontWeight.w400;
  static const weightMedium = FontWeight.w500;
  static const weightSemibold = FontWeight.w600;
  static const weightBold = FontWeight.w700;

  AppTypography.forLocale(Locale locale, {Color? color})
    : _isDark = color != null && color != AppColors.textPrimary,
      _isArabic = locale.languageCode == 'ar',
      _base = TextStyle(
        fontFamily: locale.languageCode == 'ar' ? arabicFamily : latinFamily,
        fontFamilyFallback: const [latinFamily, arabicFamily],
        color: color ?? AppColors.textPrimary,
        // Must stay at or above the families' natural line box:
        // Manrope ~1.37em, IBM Plex Sans Arabic ~1.5em. A smaller value
        // squashes and clips ascenders/descenders.
        height: locale.languageCode == 'ar' ? 1.7 : 1.5,
        fontWeight: weightRegular,
      );

  static AppTypography of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppTypography.forLocale(
      Localizations.localeOf(context),
      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
    );
  }

  final bool _isDark;
  final bool _isArabic;
  final TextStyle _base;

  // Latin tracking only; Arabic keeps its natural metrics.
  double _tracking(double latin) => _isArabic ? 0 : latin;

  // Arabic glyphs need more vertical space than Manrope. All values stay above
  // the families' natural line box so text never looks vertically squashed.
  double get _titleHeight => _isArabic ? 1.62 : 1.35;
  double get _bodyHeight => _isArabic ? 1.68 : 1.45;
  double get _compactHeight => _isArabic ? 1.55 : 1.35;

  Color get _secondaryColor =>
      _isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get _tertiaryColor =>
      _isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

  // ── Display / hero ───────────────────────────────────────────────────────
  TextStyle get display => _base.copyWith(
    fontSize: 32,
    fontWeight: weightBold,
    letterSpacing: _tracking(-0.8),
    height: _titleHeight,
  );
  TextStyle get displaySmall => _base.copyWith(
    fontSize: 26,
    fontWeight: weightBold,
    letterSpacing: _tracking(-0.6),
    height: _titleHeight,
  );
  TextStyle get timer => _base.copyWith(
    fontSize: 32,
    fontWeight: weightBold,
    height: _isArabic ? 1.6 : 1.35,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  // ── Page / section / card titles ─────────────────────────────────────────
  TextStyle get pageTitle => _base.copyWith(
    fontSize: 26,
    fontWeight: weightBold,
    letterSpacing: _tracking(-0.6),
    height: _titleHeight,
  );

  /// Authentication headings (login, reset, change password).
  TextStyle get authTitle => _base.copyWith(
    fontSize: 28,
    fontWeight: weightBold,
    letterSpacing: _tracking(-0.6),
    height: _titleHeight,
  );
  TextStyle get sectionTitle => _base.copyWith(
    fontSize: 19,
    fontWeight: weightSemibold,
    letterSpacing: _tracking(-0.2),
    height: _titleHeight,
  );
  TextStyle get cardTitle => _base.copyWith(
    fontSize: 16,
    fontWeight: weightSemibold,
    letterSpacing: _tracking(-0.1),
    height: _compactHeight,
  );

  // ── Body ─────────────────────────────────────────────────────────────────
  TextStyle get bodyLarge => _base.copyWith(
    fontSize: 15,
    fontWeight: weightMedium,
    height: _bodyHeight,
  );
  TextStyle get body => _base.copyWith(
    fontSize: 14,
    fontWeight: weightMedium,
    height: _bodyHeight,
  );
  TextStyle get bodyPrimary => body;
  TextStyle get bodySecondary =>
      body.copyWith(color: _secondaryColor, fontWeight: weightRegular);
  TextStyle get bodySmall => _base.copyWith(
    fontSize: 13,
    fontWeight: weightRegular,
    height: _bodyHeight,
  );

  // ── Labels / form ────────────────────────────────────────────────────────
  TextStyle get labelLarge => _base.copyWith(
    fontSize: 14,
    fontWeight: weightSemibold,
    height: _compactHeight,
  );
  TextStyle get label => _base.copyWith(
    fontSize: 13,
    fontWeight: weightSemibold,
    height: _compactHeight,
  );
  TextStyle get labelMedium => _base.copyWith(
    fontSize: 13,
    fontWeight: weightMedium,
    height: _compactHeight,
  );
  TextStyle get labelSmall => _base.copyWith(
    fontSize: 12,
    fontWeight: weightMedium,
    height: _compactHeight,
  );

  /// External form-field label (persistent, above the input).
  TextStyle get formLabel => _base.copyWith(
    fontSize: 12.5,
    fontWeight: weightSemibold,
    letterSpacing: _tracking(0.1),
    color: _secondaryColor,
    height: _compactHeight,
  );

  /// Value text rendered inside a control.
  TextStyle get inputValue => _base.copyWith(
    fontSize: 14,
    fontWeight: weightMedium,
    height: _bodyHeight,
  );

  TextStyle get button => _base.copyWith(
    fontSize: 14,
    fontWeight: weightSemibold,
    letterSpacing: _tracking(-0.1),
    height: _compactHeight,
  );

  // ── Metadata / tables / status ───────────────────────────────────────────
  TextStyle get caption => _base.copyWith(
    fontSize: 12,
    fontWeight: weightRegular,
    color: _secondaryColor,
    height: _bodyHeight,
  );
  TextStyle get metadata => _base.copyWith(
    fontSize: 12,
    fontWeight: weightMedium,
    color: _tertiaryColor,
    height: _bodyHeight,
  );
  TextStyle get code => _base.copyWith(
    fontSize: 13,
    fontWeight: weightMedium,
    height: _bodyHeight,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Enterprise table header cell.
  TextStyle get tableHeader => _base.copyWith(
    fontSize: 12.5,
    fontWeight: weightSemibold,
    letterSpacing: _tracking(0.3),
    color: _secondaryColor,
    height: _compactHeight,
  );

  /// Enterprise table body cell.
  TextStyle get tableCell => _base.copyWith(
    fontSize: 13.5,
    fontWeight: weightMedium,
    height: _bodyHeight,
  );

  /// Status chip / badge label.
  TextStyle get status =>
      _base.copyWith(fontSize: 12, fontWeight: weightSemibold, height: 1.2);

  /// Uppercase eyebrow / overline label.
  TextStyle get overline => _base.copyWith(
    fontSize: 11,
    fontWeight: weightSemibold,
    letterSpacing: _tracking(0.8),
    color: _tertiaryColor,
    height: _compactHeight,
  );

  /// Dashboard/report metric value with tabular figures for stable digits.
  TextStyle get metricValue => _base.copyWith(
    fontSize: 22,
    fontWeight: weightBold,
    height: _isArabic ? 1.5 : 1.15,
    letterSpacing: _tracking(-0.5),
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Uppercase metric label / eyebrow text.
  TextStyle get metricLabel => _base.copyWith(
    fontSize: 11,
    fontWeight: weightSemibold,
    letterSpacing: _tracking(0.6),
    color: _tertiaryColor,
    height: _compactHeight,
  );

  /// Secondary supporting line under a metric value.
  TextStyle get metricSupporting => _base.copyWith(
    fontSize: 11.5,
    fontWeight: weightMedium,
    color: _tertiaryColor,
    height: _bodyHeight,
  );
}
