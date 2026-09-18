import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography.forLocale(Locale locale)
    : _base = TextStyle(
        fontFamily: locale.languageCode == 'ar' ? 'NotoSansArabic' : 'Inter',
        fontFamilyFallback: const ['Inter', 'NotoSansArabic'],
        color: AppColors.textPrimary,
        height: locale.languageCode == 'ar' ? 1.65 : 1.5,
      );
  static AppTypography of(BuildContext context) =>
      AppTypography.forLocale(Localizations.localeOf(context));
  final TextStyle _base;
  TextStyle get display => _base.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: _base.fontFamily == 'Inter' ? -1 : 0,
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
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: _base.fontFamily == 'Inter' ? -.3 : 0,
  );
  TextStyle get cardTitle =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w600);
  TextStyle get bodyLarge => _base.copyWith(fontSize: 16);
  TextStyle get body => _base.copyWith(fontSize: 14);
  TextStyle get bodySmall => _base.copyWith(fontSize: 13);
  TextStyle get label =>
      _base.copyWith(fontSize: 13, fontWeight: FontWeight.w600);
  TextStyle get caption =>
      _base.copyWith(fontSize: 12, color: AppColors.textSecondary);
}
