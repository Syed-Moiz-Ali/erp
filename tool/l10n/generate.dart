import 'dart:io';

import 'arb_merger.dart';

/// Canonical localization generation workflow.
///
/// 1. Merges and validates the per-module source ARBs.
/// 2. Runs `flutter gen-l10n` to regenerate `AppLocalizations`.
///
/// Run from the repository root:
///
/// ```sh
/// dart run tool/l10n/generate.dart
/// ```
Future<void> main() async {
  try {
    final outputs = generateMergedArbs();
    for (final entry in outputs.entries) {
      stdout.writeln('Merged ${entry.value}');
    }
  } on ArbMergeException catch (error) {
    stderr.writeln('Localization merge failed:');
    stderr.writeln(error.message);
    exitCode = 1;
    return;
  }

  final process = await Process.start(
    'flutter',
    const ['gen-l10n'],
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );
  exitCode = await process.exitCode;
}
