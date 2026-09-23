import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/l10n/arb_merger.dart';

void main() {
  group('ARB merge validation', () {
    late Directory root;

    setUp(() {
      root = Directory.systemTemp.createTempSync('l10n_merge_test');
    });

    tearDown(() {
      if (root.existsSync()) root.deleteSync(recursive: true);
    });

    void writeSource(String module, String locale, Map<String, Object?> arb) {
      final dir = Directory('${root.path}/$module')..createSync();
      File(
        '${dir.path}/${module}_$locale.arb',
      ).writeAsStringSync(jsonEncode(arb));
    }

    List<L10nModule> modulesFor(List<String> ids) => [
      for (final id in ids) L10nModule(id, '${root.path}/$id'),
    ];

    test('duplicate keys across modules fail with both source files', () {
      writeSource('common', 'en', {'@@locale': 'en', 'save': 'Save'});
      writeSource('hr', 'en', {'@@locale': 'en', 'save': 'Save'});
      expect(
        () => mergeLocale('en', modules: modulesFor(['common', 'hr'])),
        throwsA(
          isA<ArbMergeException>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('Duplicate key "save"'),
              contains('common_en.arb'),
              contains('hr_en.arb'),
            ),
          ),
        ),
      );
    });

    test('missing Arabic translation fails validation', () {
      writeSource('common', 'en', {'@@locale': 'en', 'foo': 'Foo'});
      writeSource('common', 'ar', {'@@locale': 'ar'});
      final en =
          mergeLocale('en', modules: modulesFor(['common']))['messages']
              as Map<String, dynamic>;
      final ar =
          mergeLocale('ar', modules: modulesFor(['common']))['messages']
              as Map<String, dynamic>;
      expect(
        () => validateParity(en, ar),
        throwsA(
          isA<ArbMergeException>().having(
            (e) => e.message,
            'message',
            contains('Missing Arabic keys:\n  foo'),
          ),
        ),
      );
    });

    test('orphan Arabic translation fails validation', () {
      writeSource('common', 'en', {'@@locale': 'en'});
      writeSource('common', 'ar', {'@@locale': 'ar', 'bar': 'Bar'});
      final en =
          mergeLocale('en', modules: modulesFor(['common']))['messages']
              as Map<String, dynamic>;
      final ar =
          mergeLocale('ar', modules: modulesFor(['common']))['messages']
              as Map<String, dynamic>;
      expect(
        () => validateParity(en, ar),
        throwsA(
          isA<ArbMergeException>().having(
            (e) => e.message,
            'message',
            contains('Missing English keys:\n  bar'),
          ),
        ),
      );
    });

    test('placeholder drift fails validation', () {
      writeSource('common', 'en', {'@@locale': 'en', 'hello': 'Hello {name}'});
      writeSource('common', 'ar', {'@@locale': 'ar', 'hello': 'مرحبا'});
      final en =
          mergeLocale('en', modules: modulesFor(['common']))['messages']
              as Map<String, dynamic>;
      final ar =
          mergeLocale('ar', modules: modulesFor(['common']))['messages']
              as Map<String, dynamic>;
      expect(
        () => validateParity(en, ar),
        throwsA(
          isA<ArbMergeException>().having(
            (e) => e.message,
            'message',
            contains('Placeholder mismatch for "hello"'),
          ),
        ),
      );
    });

    test('orphan metadata fails merge', () {
      writeSource('common', 'en', {
        '@@locale': 'en',
        '@save': {'description': 'orphan'},
      });
      expect(
        () => mergeLocale('en', modules: modulesFor(['common'])),
        throwsA(
          isA<ArbMergeException>().having(
            (e) => e.message,
            'message',
            contains('Orphan metadata'),
          ),
        ),
      );
    });

    test('malformed JSON reports the offending file', () {
      final dir = Directory('${root.path}/common')..createSync();
      File('${dir.path}/common_en.arb').writeAsStringSync('{ not json');
      expect(
        () => mergeLocale('en', modules: modulesFor(['common'])),
        throwsA(
          isA<ArbMergeException>().having(
            (e) => e.message,
            'message',
            contains('Invalid ARB JSON: ${dir.path}/common_en.arb'),
          ),
        ),
      );
    });

    test('successful merge keeps every message exactly once', () {
      writeSource('common', 'en', {'@@locale': 'en', 'save': 'Save'});
      writeSource('platform', 'en', {'@@locale': 'en', 'login': 'Login'});
      writeSource('hr', 'en', {'@@locale': 'en', 'employee': 'Employee'});
      writeSource('common', 'ar', {'@@locale': 'ar', 'save': 'حفظ'});
      writeSource('platform', 'ar', {'@@locale': 'ar', 'login': 'دخول'});
      writeSource('hr', 'ar', {'@@locale': 'ar', 'employee': 'موظف'});
      final ids = ['common', 'platform', 'hr'];
      final outputs = generateMergedArbs(
        modules: modulesFor(ids),
        outputDir: '${root.path}/generated',
      );
      final en =
          jsonDecode(File(outputs['en']!).readAsStringSync())
              as Map<String, dynamic>;
      final ar =
          jsonDecode(File(outputs['ar']!).readAsStringSync())
              as Map<String, dynamic>;
      expect(en.keys.where((k) => !k.startsWith('@')).toSet(), {
        'save',
        'login',
        'employee',
      });
      expect(ar.keys.where((k) => !k.startsWith('@')).toSet(), {
        'save',
        'login',
        'employee',
      });
      expect(en['@@locale'], 'en');
      expect(ar['@@locale'], 'ar');
    });
  });

  test('committed generated ARBs match the module sources', () {
    final temp = Directory.systemTemp.createTempSync('l10n_sync_test');
    addTearDown(() => temp.deleteSync(recursive: true));
    final outputs = generateMergedArbs(outputDir: temp.path);
    for (final locale in l10nLocales) {
      final expected =
          jsonDecode(
                File('lib/l10n/generated/app_$locale.arb').readAsStringSync(),
              )
              as Map<String, dynamic>;
      final actual =
          jsonDecode(File(outputs[locale]!).readAsStringSync())
              as Map<String, dynamic>;
      expect(
        actual,
        expected,
        reason:
            'lib/l10n/generated/app_$locale.arb is stale; run '
            '`dart run tool/l10n/generate.dart`.',
      );
    }
  });
}
