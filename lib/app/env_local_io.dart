import 'dart:io';

/// Reads an untracked `.env.local` overlay for development runs.
///
/// The file is never bundled as an asset and is ignored by git. Secrets and
/// machine-specific endpoints belong here, not in committed `.env.*` files.
/// Parsing is intentionally minimal (KEY=VALUE, `#` comments, optional quotes)
/// and never throws.
Future<Map<String, String>> readEnvLocalOverrides() async {
  const fileName = '.env.local';
  try {
    final file = File(fileName);
    if (!await file.exists()) return const <String, String>{};
    final values = <String, String>{};
    for (final line in await file.readAsLines()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final separator = trimmed.indexOf('=');
      if (separator <= 0) continue;
      final key = trimmed.substring(0, separator).trim();
      if (key.isEmpty) continue;
      var value = trimmed.substring(separator + 1).trim();
      if (value.length >= 2 &&
          ((value.startsWith('"') && value.endsWith('"')) ||
              (value.startsWith("'") && value.endsWith("'")))) {
        value = value.substring(1, value.length - 1);
      }
      values[key] = value;
    }
    return values;
  } catch (_) {
    return const <String, String>{};
  }
}
