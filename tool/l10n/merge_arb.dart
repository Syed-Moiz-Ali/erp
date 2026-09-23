import 'dart:io';

import 'arb_merger.dart';

/// Merges the per-module localization sources into the generated app ARBs.
///
/// Run from the repository root:
///
/// ```sh
/// dart run tool/l10n/merge_arb.dart
/// flutter gen-l10n
/// ```
void main() {
  try {
    final outputs = generateMergedArbs();
    for (final entry in outputs.entries) {
      final count = _messageCount(entry.value);
      stdout.writeln('Generated ${entry.value} ($count messages)');
    }
  } on ArbMergeException catch (error) {
    stderr.writeln('Localization merge failed:');
    stderr.writeln(error.message);
    exitCode = 1;
  }
}

int _messageCount(String path) {
  final content = File(path).readAsStringSync();
  final matches = RegExp(
    r'^\s*"([^@][^"]*)"\s*:',
    multiLine: true,
  ).allMatches(content);
  return matches.length;
}
