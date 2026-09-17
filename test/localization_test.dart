import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/errors/failure_localization.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/core/localization/locale_cubit.dart';
import 'package:modular_erp/core/preferences/app_preferences_repository.dart';
import 'package:modular_erp/core/validation/app_validation.dart';
import 'package:modular_erp/design_system/theme/app_typography.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'support/memory_preferences.dart';

class MockPreferences extends Mock implements SharedPreferencesAsync {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeDateFormatting);

  test('English and Arabic delegates load required common resources', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final ar = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(en.save, 'Save');
    expect(ar.save, 'حفظ');
    expect(ar.emailRequired, 'البريد الإلكتروني مطلوب');
    expect(
      AppLocalizations.supportedLocales,
      containsAll([const Locale('en'), const Locale('ar')]),
    );
  });

  test(
    'Arabic resources have complete key parity and genuine translations',
    () {
      final en =
          jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
              as Map<String, dynamic>;
      final ar =
          jsonDecode(File('lib/l10n/app_ar.arb').readAsStringSync())
              as Map<String, dynamic>;
      final keys = en.keys.where((key) => !key.startsWith('@')).toSet();
      expect(ar.keys.where((key) => !key.startsWith('@')).toSet(), keys);
      for (final key in keys) {
        expect(ar[key], isNotEmpty, reason: key);
        if (key != 'englishNativeName') {
          expect(
            RegExp(r'[\u0600-\u06ff]').hasMatch(ar[key] as String),
            isTrue,
            reason: '$key must contain Arabic',
          );
        }
      }
    },
  );

  test('Unsupported device locale falls back to English', () async {
    final cubit = LocaleCubit(
      LocalAppPreferencesRepository(MemoryPreferences()),
    );
    addTearDown(cubit.close);
    await cubit.restore([const Locale('fr', 'FR')]);
    expect(cubit.state.locale, const Locale('en'));
    expect(cubit.supportedLanguages, AppLanguage.values);
  });

  test('Regional/device preferences resolve to Arabic', () async {
    final cubit = LocaleCubit(
      LocalAppPreferencesRepository(MemoryPreferences()),
    );
    addTearDown(cubit.close);
    await cubit.restore([const Locale('fr'), const Locale('ar', 'SA')]);
    expect(cubit.state.language, AppLanguage.arabic);
  });

  test(
    'Saved language overrides device language and survives restart',
    () async {
      final storage = MemoryPreferences();
      final first = LocaleCubit(LocalAppPreferencesRepository(storage));
      await first.restore([const Locale('en')]);
      await first.changeLanguage(AppLanguage.arabic);
      await first.close();
      final restarted = LocaleCubit(LocalAppPreferencesRepository(storage));
      addTearDown(restarted.close);
      await restarted.restore([const Locale('en')]);
      expect(restarted.state.language, AppLanguage.arabic);
      expect(storage.code, 'ar');
    },
  );

  test('Unknown stored language is ignored safely', () async {
    final cubit = LocaleCubit(
      LocalAppPreferencesRepository(MemoryPreferences(code: 'xx')),
    );
    addTearDown(cubit.close);
    await cubit.restore([const Locale('de')]);
    expect(cubit.state.language, AppLanguage.english);
  });

  test(
    'Rapid changes persist in order and match current UI language',
    () async {
      final storage = MemoryPreferences();
      final cubit = LocaleCubit(LocalAppPreferencesRepository(storage));
      addTearDown(cubit.close);
      await Future.wait([
        cubit.changeLanguage(AppLanguage.arabic),
        cubit.changeLanguage(AppLanguage.english),
        cubit.changeLanguage(AppLanguage.arabic),
      ]);
      expect(storage.writes, ['ar', 'en', 'ar']);
      expect(storage.code, cubit.state.locale.languageCode);
    },
  );

  test('Storage failures keep locale usable and support save retry', () async {
    final storage = MemoryPreferences()..failReads = true;
    final cubit = LocaleCubit(LocalAppPreferencesRepository(storage));
    addTearDown(cubit.close);
    await cubit.restore([const Locale('ar')]);
    expect(cubit.state.language, AppLanguage.arabic);
    expect(cubit.state.failure!.kind, FailureKind.preferencesRead);
    storage.failWrites = true;
    await cubit.changeLanguage(AppLanguage.english);
    expect(cubit.state.language, AppLanguage.english);
    expect(cubit.state.failure!.kind, FailureKind.preferencesWrite);
    storage.failWrites = false;
    await cubit.changeLanguage(AppLanguage.english);
    expect(cubit.state.failure, isNull);
    expect(storage.code, 'en');
  });

  test('Device adapter stores only non-sensitive language code', () async {
    final plugin = MockPreferences();
    when(
      () => plugin.getString('app.preferences.language'),
    ).thenAnswer((_) async => 'ar');
    when(
      () => plugin.setString('app.preferences.language', 'en'),
    ).thenAnswer((_) async {});
    final adapter = SharedPreferencesLocalDataSource(plugin);
    expect(await adapter.readLanguageCode(), 'ar');
    await adapter.writeLanguageCode('en');
    verify(() => plugin.setString('app.preferences.language', 'en')).called(1);
  });

  test(
    'Date/time/number/duration/percentage/currency formatting follows locale',
    () async {
      const en = Locale('en');
      const ar = Locale('ar');
      final arResources = await AppLocalizations.delegate.load(ar);
      final date = DateTime(2026, 9, 17, 9, 15);
      expect(const AppDateFormatter(en).date(date), contains('Sep'));
      expect(const AppDateFormatter(ar).date(date), contains('سبتمبر'));
      expect(const AppDateFormatter(ar).month(date), contains('سبتمبر'));
      expect(const AppTimeFormatter(en).time(date), contains('AM'));
      expect(const AppTimeFormatter(ar).time(date), contains('ص'));
      expect(const AppNumberFormatter(ar).integer(12345), '12,345');
      expect(
        const AppNumberFormatter(Locale('ar', 'EG')).integer(12345),
        '١٢٬٣٤٥',
      );
      expect(
        const AppTimeFormatter(
          ar,
        ).duration(const Duration(hours: 8, minutes: 32), arResources),
        '8 س 32 د',
      );
      expect(const AppNumberFormatter(ar).percentage(.25), contains('25'));
      expect(
        const AppNumberFormatter(ar).currency(10, currencyCode: 'USD'),
        contains('10'),
      );
    },
  );

  test(
    'One validation rule and failure kind translate to both languages',
    () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final ar = await AppLocalizations.delegate.load(const Locale('ar'));
      final issue = AppValidation.email('');
      expect(issue!.message(en), 'Email is required');
      expect(issue.message(ar), 'البريد الإلكتروني مطلوب');
      expect(AppValidation.email('person@example.com'), isNull);
      expect(AppValidation.email('invalid'), ValidationIssue.emailInvalid);
      const failure = Failure(code: 'timeout', kind: FailureKind.timeout);
      expect(failure.localizedMessage(en), en.failureTimeout);
      expect(failure.localizedMessage(ar), ar.failureTimeout);
    },
  );

  test('Arabic typography selects bundled family and appropriate spacing', () {
    final en = AppTypography.forLocale(const Locale('en'));
    final ar = AppTypography.forLocale(const Locale('ar'));
    expect(en.body.fontFamily, 'Inter');
    expect(ar.body.fontFamily, 'NotoSansArabic');
    expect(en.body.fontFamilyFallback, contains('NotoSansArabic'));
    expect(ar.pageTitle.letterSpacing, 0);
    expect(ar.body.height, greaterThanOrEqualTo(en.body.height!));
  });

  test('Source has no directly hardcoded UI messages or physical RTL edges', () {
    final visibleLiteral = RegExp(
      r'''\b(?:Text|TextSpan)\s*\(\s*['"]|\b(?:label|title|subtitle|message|tooltip|hint|actionLabel|labelText|hintText|confirmLabel|semanticLabel)\s*[:=]\s*['"]''',
    );
    final physicalEdge = RegExp(
      r'EdgeInsets\.only\([^)]*\b(?:left|right):|Alignment\.(?:centerLeft|centerRight|topLeft|topRight)|Border\(\s*(?:left|right):',
    );
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart') ||
          file.path.contains('generated') ||
          file.path.endsWith('.g.dart') ||
          file.path.endsWith('.freezed.dart')) {
        continue;
      }
      final source = file.readAsStringSync();
      expect(visibleLiteral.hasMatch(source), isFalse, reason: file.path);
      expect(physicalEdge.hasMatch(source), isFalse, reason: file.path);
    }
  });
}
