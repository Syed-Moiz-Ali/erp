import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography.forLocale(Locale locale, {Color? color})
    : _isDark = color != null && color != AppColors.textPrimary,
      _base = TextStyle(
        fontFamily: locale.languageCode == 'ar' ? 'NotoSansArabic' : 'Inter',
        fontFamilyFallback: const ['Inter', 'NotoSansArabic'],
        color: color ?? AppColors.textPrimary,
        height: locale.languageCode == 'ar' ? 1.65 : 1.5,
      );
  static AppTypography of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppTypography.forLocale(
      Localizations.localeOf(context),
      color: isDark ? Colors.white : AppColors.textPrimary,
    );
  }

  final bool _isDark;
  final TextStyle _base;
  TextStyle get display => _base.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: _base.fontFamily == 'Inter' ? -1 : 0,
  );
  TextStyle get displaySmall => _base.copyWith(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    letterSpacing: _base.fontFamily == 'Inter' ? -.8 : 0,
  );
  TextStyle get timer => _base.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  TextStyle get pageTitle => _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: _base.fontFamily == 'Inter' ? -.7 : 0,
  );
  TextStyle get sectionTitle => _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: _base.fontFamily == 'Inter' ? -.3 : 0,
  );
  TextStyle get cardTitle =>
      _base.copyWith(fontSize: 15, fontWeight: FontWeight.w600);
  TextStyle get bodyLarge => _base.copyWith(fontSize: 15);
  TextStyle get body => _base.copyWith(fontSize: 14);
  TextStyle get bodySmall => _base.copyWith(fontSize: 13);
  TextStyle get labelLarge =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w600);
  TextStyle get label =>
      _base.copyWith(fontSize: 13, fontWeight: FontWeight.w600);
  TextStyle get labelMedium => label;
  TextStyle get caption => _base.copyWith(
    fontSize: 12,
    color: _isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
  );
  TextStyle get code => _base.copyWith(
    fontSize: 13,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
