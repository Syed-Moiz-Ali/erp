import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  /// Centralized font families. Feature widgets must never hardcode these.
  static const latinFamily = 'Manrope';
  static const arabicFamily = 'IBMPlexSansArabic';

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
      );

  static AppTypography of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppTypography.forLocale(
      Localizations.localeOf(context),
      color: isDark ? Colors.white : AppColors.textPrimary,
    );
  }

  final bool _isDark;
  final bool _isArabic;
  final TextStyle _base;

  // Latin tracking only; Arabic keeps its natural metrics.
  double _tracking(double latin) => _isArabic ? 0 : latin;

  // Arabic glyphs need more vertical space than Manrope. Both values stay
  // above the natural line box so headlines never look vertically squashed.
  double get _titleHeight => _isArabic ? 1.62 : 1.34;

  TextStyle get display => _base.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: _tracking(-1.2),
    height: _titleHeight,
  );
  TextStyle get displaySmall => _base.copyWith(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: _tracking(-1),
    height: _titleHeight,
  );
  TextStyle get timer => _base.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: _isArabic ? 1.6 : 1.4,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  TextStyle get pageTitle => _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: _tracking(-0.8),
    height: _titleHeight,
  );

  /// Authentication headings (login, reset, change password).
  TextStyle get authTitle => _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: _tracking(-0.8),
    height: _titleHeight,
  );
  TextStyle get sectionTitle => _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: _tracking(-0.3),
  );
  TextStyle get cardTitle => _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: _tracking(-0.1),
  );
  TextStyle get bodyLarge =>
      _base.copyWith(fontSize: 15, fontWeight: FontWeight.w600);
  TextStyle get body =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w600);
  TextStyle get bodyPrimary => body;
  TextStyle get bodySecondary => body.copyWith(color: AppColors.textSecondary);
  TextStyle get bodySmall =>
      _base.copyWith(fontSize: 13, fontWeight: FontWeight.w600);
  TextStyle get labelLarge =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w700);
  TextStyle get label =>
      _base.copyWith(fontSize: 13, fontWeight: FontWeight.w700);
  TextStyle get labelMedium => label;
  TextStyle get button => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: _tracking(-0.1),
  );
  TextStyle get caption => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: _isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
  );
  TextStyle get metadata => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: _isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
  );
  TextStyle get code => _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Dashboard/report metric value with tabular figures for stable digits.
  TextStyle get metricValue => _base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: _isArabic ? 1.5 : 1.1,
    letterSpacing: _tracking(-0.6),
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Uppercase metric label / eyebrow text.
  TextStyle get metricLabel => _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: _tracking(0.6),
    color: _isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
  );

  /// Secondary supporting line under a metric value.
  TextStyle get metricSupporting => _base.copyWith(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    color: _isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
  );

  /// Enterprise table header cell.
  TextStyle get tableHeader => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: _tracking(0.5),
    color: _isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
  );
}
