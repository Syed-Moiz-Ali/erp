import 'dart:convert';
import 'dart:io';

/// Fails when a presentation, route, navigation, design-system or l10n file
/// differs from the frozen UI baseline without an approval entry.
///
/// Baseline: ac2ec6f (tip of services_module, 2026-10-08).
/// Only the paths listed in docs/ui-approved-changes.md may differ.
const baseline = 'ac2ec6f';
const approvedFile = 'docs/ui-approved-changes.md';

const guardedPrefixes = <String>[
  'lib/app/router/',
  'lib/app/shell/',
  'lib/app/module_registry/',
  'lib/design_system/',
  'lib/l10n/',
  'lib/platform/l10n/',
  'lib/modules/hr/l10n/',
  'lib/modules/services/l10n/',
  'lib/shared/presentation/',
];

/// Navigation/registration files that live outside the prefixes above.
/// Their sibling *_dependencies.dart files are DI and stay unguarded.
const guardedFiles = <String>{
  'lib/modules/hr/module/hr_routes.dart',
  'lib/modules/hr/module/hr_module_registration.dart',
  'lib/modules/services/module/services_routes.dart',
  'lib/modules/services/module/services_module_registration.dart',
  'lib/platform/module/platform_registration.dart',
};

bool guarded(String path) =>
    guardedPrefixes.any(path.startsWith) ||
    guardedFiles.contains(path) ||
    path.contains('/presentation/');

Set<String> approved() {
  final file = File(approvedFile);
  if (!file.existsSync()) return {};
  final result = <String>{};
  for (final line in file.readAsLinesSync()) {
    final match = RegExp(r'^\s*-\s*`([^`]+)`').firstMatch(line);
    if (match != null) result.add(match.group(1)!);
  }
  return result;
}

void main() {
  final tracked = Process.runSync('git', [
    'diff',
    '--name-only',
    baseline,
  ], runInShell: true);
  final untracked = Process.runSync('git', [
    'ls-files',
    '--others',
    '--exclude-standard',
  ], runInShell: true);
  if (tracked.exitCode != 0 || untracked.exitCode != 0) {
    stderr.writeln('Unable to compare against $baseline.');
    exitCode = 2;
    return;
  }
  final changed = <String>{
    ...LineSplitter.split(tracked.stdout as String),
    ...LineSplitter.split(untracked.stdout as String),
  }.where((line) => line.trim().isNotEmpty).map((line) => line.trim());
  final allowed = approved();
  final violations =
      changed.where(guarded).where((path) => !allowed.contains(path)).toList()
        ..sort();
  if (violations.isEmpty) {
    stdout.writeln('UI freeze check passed against $baseline.');
    return;
  }
  stderr.writeln('UI freeze violations (not in $approvedFile):');
  for (final path in violations) {
    stderr.writeln('  $path');
  }
  exitCode = 1;
}
