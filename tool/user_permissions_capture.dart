import 'dart:convert';
import 'dart:io';

/// Read-only capture of the administrator grant list for the orphan fixture.
///
/// Logs in once as the administrator and calls
/// `GET /api/user-permissions?userId=8` only. It prints no credentials or token.
Future<void> main() async {
  final local = _readEnv('.env.local');
  final dev = _readEnv('.env.development');
  final baseUrl = (dev['API_BASE_URL'] ?? '').trim().replaceAll(
    RegExp(r'/$'),
    '',
  );
  final login = local['MASSERP_ADMIN_LOGIN'];
  final password = local['MASSERP_ADMIN_PASSWORD'];
  if (baseUrl.isEmpty || login == null || password == null) {
    stderr.writeln('Missing base URL or administrator credentials.');
    exitCode = 1;
    return;
  }

  final client = _Client(baseUrl);
  try {
    final session = await client.post(
      '/api/auth/login',
      body: {'loginId': login, 'password': password},
      extraHeaders: const {'X-Client-Platform': 'android'},
    );
    final data = session['data'];
    final token = data is Map ? data['accessToken'] : null;
    if (token is! String) throw const _Stop('Login response had no token.');

    final first = await client.get(
      '/api/user-permissions?userId=8&page=1&pageSize=100',
      token: token,
    );
    final firstData = first['data'];
    if (firstData is! Map) throw const _Stop('Missing paged data.');
    final items = <Object?>[
      for (final item in (firstData['items'] as List? ?? const [])) item,
    ];
    final totalPages = (firstData['totalPages'] as num?)?.toInt() ?? 1;
    for (var page = 2; page <= totalPages && page <= 20; page++) {
      final next = await client.get(
        '/api/user-permissions?userId=8&page=$page&pageSize=100',
        token: token,
      );
      final nextData = next['data'];
      if (nextData is! Map) continue;
      items.addAll(nextData['items'] as List? ?? const []);
    }
    firstData['items'] = items;
    firstData['pageSize'] = 100;
    firstData['totalItems'] = items.length;
    final dir = Directory('test/fixtures/permissions');
    _write(
      dir,
      'user_permissions_user8.json',
      _sanitize(first),
    );
    final orphans = items.where((item) {
      if (item is! Map) return false;
      return item['permissionKey'] == null ||
          item['permissionStatusId'] == 2;
    }).length;
    stdout.writeln(
      'Live orphan-grant capture complete. Rows: ${items.length}; '
      'orphan/inactive rows: $orphans.',
    );
  } on _Stop catch (error) {
    stderr.writeln('Capture stopped: ${error.message}');
    exitCode = 1;
  } finally {
    client.close();
  }
}

class _Stop implements Exception {
  const _Stop(this.message);
  final String message;
}

class _Client {
  _Client(this.baseUrl) {
    _http.connectionTimeout = const Duration(seconds: 20);
  }

  final String baseUrl;
  final _http = HttpClient();

  Future<Map<String, dynamic>> get(
    String path, {
    required String token,
  }) => send('GET', path, token: token);

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String> extraHeaders = const {},
  }) => send('POST', path, body: body, extraHeaders: extraHeaders);

  Future<Map<String, dynamic>> send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
    Map<String, String> extraHeaders = const {},
    bool retried = false,
  }) async {
    final request = await _http.openUrl(method, Uri.parse('$baseUrl$path'));
    request.headers.set('ngrok-skip-browser-warning', 'true');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (token != null) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    extraHeaders.forEach(request.headers.set);
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }
    final response = await request.close();
    final text = await response.transform(utf8.decoder).join();
    final mime = response.headers.contentType?.mimeType ?? '';
    if (response.statusCode == 429 && !retried) {
      stdout.writeln('Rate limited; waiting 65 seconds before one retry...');
      await Future<void>.delayed(const Duration(seconds: 65));
      return send(
        method,
        path,
        body: body,
        token: token,
        extraHeaders: extraHeaders,
        retried: true,
      );
    }
    if (response.statusCode == 502 ||
        mime.contains('text/html') ||
        text.trimLeft().startsWith('<')) {
      throw _Stop('$method $path returned HTML/502/offline.');
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } catch (_) {
      throw _Stop('$method $path did not return JSON.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw _Stop('$method $path returned a non-object JSON value.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _Stop('$method $path returned ${response.statusCode}.');
    }
    return decoded;
  }

  void close() => _http.close(force: true);
}

Object? _sanitize(Object? value, {String key = ''}) {
  if (value is Map) {
    final result = <String, dynamic>{};
    for (final entry in value.entries) {
      final childKey = entry.key.toString();
      result[childKey] = _sanitize(entry.value, key: childKey);
    }
    return result;
  }
  if (value is List) {
    return [for (final item in value) _sanitize(item, key: key)];
  }
  if (value is String && value.isNotEmpty) {
    final lower = key.toLowerCase();
    if (lower == 'loginid' || lower.contains('email')) {
      return 'sanitized@example.com';
    }
    if (lower.contains('phone') ||
        lower.contains('mobile') ||
        lower.contains('contact')) {
      return 'SANITIZED_PHONE';
    }
    if (lower.contains('employeename') ||
        lower.contains('username') ||
        lower == 'name') {
      return 'Sanitized Name';
    }
  }
  return value;
}

Map<String, String> _readEnv(String path) {
  final file = File(path);
  if (!file.existsSync()) return {};
  final result = <String, String>{};
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final index = trimmed.indexOf('=');
    if (index <= 0) continue;
    result[trimmed.substring(0, index).trim()] = trimmed
        .substring(index + 1)
        .trim()
        .replaceAll(RegExp(r'''^["']|["']$'''), '');
  }
  return result;
}

void _write(Directory dir, String name, Object? value) {
  final file = File('${dir.path}/$name');
  const encoder = JsonEncoder.withIndent('  ');
  file.writeAsStringSync('${encoder.convert(value)}\n');
  stdout.writeln('Wrote ${file.path}');
}
