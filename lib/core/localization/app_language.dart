import 'package:flutter/widgets.dart';
import '../../l10n/generated/app_localizations.dart';

enum AppLanguage {
  english(Locale('en')),
  arabic(Locale('ar'));

  const AppLanguage(this.locale);
  final Locale locale;

  String displayName(AppLocalizations l10n) => switch (this) {
    english => l10n.english,
    arabic => l10n.arabic,
  };

  String nativeName(AppLocalizations l10n) => switch (this) {
    english => l10n.englishNativeName,
    arabic => l10n.arabicNativeName,
  };

  static AppLanguage? fromCode(String? code) {
    for (final language in values) {
      if (language.locale.languageCode == code) return language;
    }
    return null;
  }

  static AppLanguage resolve(Iterable<Locale> deviceLocales) {
    for (final locale in deviceLocales) {
      final language = fromCode(locale.languageCode);
      if (language != null) return language;
    }
    return english;
  }
}
