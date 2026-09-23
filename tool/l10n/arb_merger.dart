import 'dart:convert';
import 'dart:io';

/// Central registration of localization source modules and generated output.
///
/// Source ARBs are the single source of truth; the merged ARBs under
/// [l10nGeneratedDir] are generated and must never be edited by hand.
class L10nModule {
  const L10nModule(this.id, this.directory);

  /// Source id, also the file prefix (`<id>_<locale>.arb`).
  final String id;

  /// Repository-relative directory holding the module ARBs.
  final String directory;
}

/// Source order. It only affects generated file readability; duplicate keys
/// still fail regardless of order.
const l10nModules = <L10nModule>[
  L10nModule('common', 'lib/l10n/common'),
  L10nModule('platform', 'lib/platform/l10n'),
  L10nModule('hr', 'lib/modules/hr/l10n'),
  L10nModule('services', 'lib/modules/services/l10n'),
];

const l10nLocales = <String>['en', 'ar'];

const l10nGeneratedDir = 'lib/l10n/generated';

/// Thrown for any validation failure. Messages are actionable and include the
/// offending file(s).
class ArbMergeException implements Exception {
  ArbMergeException(this.message);
  final String message;

  @override
  String toString() => message;
}

String sourceFilePath(L10nModule module, String locale) =>
    '${module.directory}/${module.id}_$locale.arb';

Map<String, dynamic> _readArbFile(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    throw ArbMergeException('Invalid localization source: missing file $path');
  }
  final content = file.readAsStringSync();
  try {
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) {
      throw ArbMergeException('Invalid ARB JSON: $path (expected an object)');
    }
    return decoded;
  } on FormatException catch (error) {
    throw ArbMergeException('Invalid ARB JSON: $path (${error.message})');
  }
}

String _placeholders(String value) {
  final matches = RegExp(r'\{(\w+)[,}]').allMatches(value);
  final names = matches.map((m) => m.group(1)!).toSet().toList()..sort();
  return names.join(',');
}

/// Merges every registered module ARB for [locale] into one ARB map.
///
/// Validates duplicate message keys, metadata pairing and `@@locale`
/// consistency. Throws [ArbMergeException] on any problem.
Map<String, dynamic> mergeLocale(
  String locale, {
  List<L10nModule> modules = l10nModules,
}) {
  final merged = <String, dynamic>{'@@locale': locale};
  final keySource = <String, String>{};
  final messages = <String, dynamic>{};

  for (final module in modules) {
    final path = sourceFilePath(module, locale);
    final arb = _readArbFile(path);
    final declaredLocale = arb['@@locale'];
    if (declaredLocale != null && declaredLocale != locale) {
      throw ArbMergeException(
        'Locale mismatch in $path: declared "$declaredLocale" but expected '
        '"$locale"',
      );
    }
    for (final entry in arb.entries) {
      final key = entry.key;
      if (key == '@@locale') continue;
      final previous = keySource[key];
      if (previous != null) {
        throw ArbMergeException(
          'Duplicate key "$key" in $path; first defined in $previous',
        );
      }
      keySource[key] = path;
      merged[key] = entry.value;
      if (!key.startsWith('@')) {
        messages[key] = entry.value;
      }
    }
  }

  for (final key in keySource.keys) {
    if (key.startsWith('@') && !keySource.containsKey(key.substring(1))) {
      throw ArbMergeException(
        'Orphan metadata "$key" in ${keySource[key]}; no matching message',
      );
    }
  }

  return {'merged': merged, 'messages': messages};
}

/// Validates English/Arabic key parity and placeholder preservation.
void validateParity(
  Map<String, dynamic> en,
  Map<String, dynamic> ar, {
  Map<String, String>? enSources,
  Map<String, String>? arSources,
}) {
  final missingAr = en.keys.where((k) => !ar.containsKey(k)).toList()..sort();
  final missingEn = ar.keys.where((k) => !en.containsKey(k)).toList()..sort();
  final problems = <String>[];
  if (missingAr.isNotEmpty) {
    problems.add('Missing Arabic keys:\n  ${missingAr.join('\n  ')}');
  }
  if (missingEn.isNotEmpty) {
    problems.add('Missing English keys:\n  ${missingEn.join('\n  ')}');
  }
  for (final key in en.keys) {
    if (!ar.containsKey(key)) continue;
    final enValue = en[key];
    final arValue = ar[key];
    if (enValue is! String || arValue is! String) continue;
    final expected = _placeholders(enValue);
    if (expected.isEmpty) continue;
    final actual = _placeholders(arValue);
    final missing = expected
        .split(',')
        .where((p) => p.isNotEmpty && !actual.split(',').contains(p))
        .toList();
    if (missing.isNotEmpty) {
      problems.add(
        'Placeholder mismatch for "$key": Arabic is missing '
        '${missing.map((p) => '{$p}').join(', ')}',
      );
    }
  }
  if (problems.isNotEmpty) {
    throw ArbMergeException(problems.join('\n'));
  }
}

void _writeArb(String path, Map<String, dynamic> merged) {
  final buffer = StringBuffer();
  buffer.writeln('{');
  final entries = merged.entries.toList();
  for (var i = 0; i < entries.length; i++) {
    final entry = entries[i];
    buffer.write('  ${jsonEncode(entry.key)}: ${jsonEncode(entry.value)}');
    buffer.writeln(i == entries.length - 1 ? '' : ',');
  }
  buffer.writeln('}');
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync('${buffer.toString()}\n');
}

/// Merges all locales, validates parity and writes the generated ARBs.
///
/// Returns the generated file paths keyed by locale.
Map<String, String> generateMergedArbs({
  List<L10nModule> modules = l10nModules,
  List<String> locales = l10nLocales,
  String outputDir = l10nGeneratedDir,
}) {
  final messagesByLocale = <String, Map<String, dynamic>>{};
  for (final locale in locales) {
    final result = mergeLocale(locale, modules: modules);
    messagesByLocale[locale] = result['messages'] as Map<String, dynamic>;
  }
  if (locales.contains('en') && locales.contains('ar')) {
    validateParity(messagesByLocale['en']!, messagesByLocale['ar']!);
  }
  final outputs = <String, String>{};
  for (final locale in locales) {
    final result = mergeLocale(locale, modules: modules);
    final path = '$outputDir/app_$locale.arb';
    _writeArb(path, result['merged'] as Map<String, dynamic>);
    outputs[locale] = path;
  }
  return outputs;
}
