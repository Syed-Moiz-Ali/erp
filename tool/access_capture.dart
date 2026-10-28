import 'dart:convert';
import 'dart:io';

/// Read-only MassERP permissions/user-permissions capture.
///
/// Usage: `dart run tool/access_capture.dart`
///
/// Credentials come from untracked `.env.local`; the base URL comes from
/// `.env.development`. Only GET plus the two logins are sent. Tokens and
/// personal identity fields are never written or printed.
Future<void> main() async {
  final local = _readEnv('.env.local');
  final dev = _readEnv('.env.development');
  final baseUrl = (dev['API_BASE_URL'] ?? '').trim().replaceAll(
    RegExp(r'/$'),
    '',
  );
  final adminLogin = local['MASSERP_ADMIN_LOGIN'];
  final adminPassword = local['MASSERP_ADMIN_PASSWORD'];
  final employeeLogin = local['MASSERP_EMPLOYEE_LOGIN'];
  final employeePassword = local['MASSERP_EMPLOYEE_PASSWORD'];
  if (baseUrl.isEmpty ||
      adminLogin == null ||
      adminPassword == null ||
      employeeLogin == null ||
      employeePassword == null) {
    stderr.writeln('Missing base URL or local credentials.');
    exitCode = 1;
    return;
  }

  final client = _CaptureClient(baseUrl);
  try {
    stdout.writeln('Logging in administrator once...');
    final adminLoginBody = await client.post(
      '/api/auth/login',
      body: {'loginId': adminLogin, 'password': adminPassword},
      extraHeaders: const {'X-Client-Platform': 'android'},
    );
    final adminToken = _token(adminLoginBody, 'accessToken');

    stdout.writeln('Logging in employee once...');
    final employeeLoginBody = await client.post(
      '/api/auth/login',
      body: {'loginId': employeeLogin, 'password': employeePassword},
      extraHeaders: const {'X-Client-Platform': 'android'},
    );
    final employeeToken = _token(employeeLoginBody, 'accessToken');
    final employeeUserId = _userId(employeeLoginBody);

    stdout.writeln('Capturing permission list...');
    final list = await client.get(
      '/api/permissions?page=1&pageSize=25&sort=keyAsc',
      token: adminToken,
    );
    final filtered = await client.get(
      '/api/permissions?page=1&pageSize=5&sort=keyAsc&statusId=1',
      token: adminToken,
    );
    final firstPermissionId = _firstPermissionId(list);
    final unknownPermissionId = _unknownPermissionId(list);
    if (firstPermissionId == null) {
      throw const _CaptureStop('Permission list did not contain a valid item.');
    }

    stdout.writeln('Capturing permission detail and 404...');
    final detail = await client.get(
      '/api/permissions/$firstPermissionId',
      token: adminToken,
    );
    final unknownDetail = unknownPermissionId == null
        ? null
        : await client.get(
            '/api/permissions/$unknownPermissionId',
            token: adminToken,
          );
    final notFound = await client.get(
      '/api/permissions/999999',
      token: adminToken,
      expectError: true,
    );

    stdout.writeln('Capturing user permissions...');
    final allGrants = await client.get(
      '/api/user-permissions?page=1&pageSize=100',
      token: adminToken,
    );
    final userGrants = await client.get(
      '/api/user-permissions?page=1&pageSize=100&userId=$employeeUserId',
      token: adminToken,
    );

    stdout.writeln('Capturing current permissions for both accounts...');
    final adminMe = await client.get('/api/me/permissions', token: adminToken);
    final employeeMe = await client.get(
      '/api/me/permissions',
      token: employeeToken,
    );

    final dir = Directory('test/fixtures/permissions');
    dir.createSync(recursive: true);
    _write(dir, 'permissions_list.json', _sanitize(list));
    _write(dir, 'permissions_list_filtered.json', _sanitize(filtered));
    _write(dir, 'permission_detail.json', _sanitize(detail));
    if (unknownDetail != null) {
      _write(dir, 'permission_detail_unknown.json', _sanitize(unknownDetail));
    }
    _write(dir, 'permission_not_found.json', _sanitize(notFound));
    _write(dir, 'user_permissions_all.json', _sanitize(allGrants));
    _write(dir, 'user_permissions_user.json', _sanitize(userGrants));
    _write(dir, 'me_permissions_admin.json', _sanitize(adminMe));
    _write(dir, 'me_permissions_employee.json', _sanitize(employeeMe));

    final orphanCount = _orphanCount(allGrants);
    stdout.writeln('Live access capture complete.');
    stdout.writeln(
      'Permission list items: ${_itemCount(list)}; '
      'user-permission rows: ${_itemCount(allGrants)}; '
      'orphan rows: $orphanCount.',
    );
  } on _CaptureStop catch (error) {
    stderr.writeln('Capture stopped: ${error.message}');
    exitCode = 1;
  } finally {
    client.close();
  }
}

class _CaptureStop implements Exception {
  const _CaptureStop(this.message);
  final String message;
}

class _CaptureClient {
  _CaptureClient(this.baseUrl) {
    _client.connectionTimeout = const Duration(seconds: 20);
  }

  final String baseUrl;
  final _client = HttpClient();

  Future<Map<String, dynamic>> get(
    String path, {
    required String token,
    bool expectError = false,
  }) => _request('GET', path, token: token, expectError: expectError);

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String> extraHeaders = const {},
  }) => _request('POST', path, body: body, extraHeaders: extraHeaders);

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
    Map<String, String> extraHeaders = const {},
    bool expectError = false,
    bool retryRateLimit = true,
  }) async {
    final request = await _client.openUrl(method, Uri.parse('$baseUrl$path'));
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
    final contentType = response.headers.contentType?.mimeType ?? '';
    if (response.statusCode == 429 && retryRateLimit) {
      stdout.writeln('Rate limited; waiting 65 seconds before one retry...');
      await Future<void>.delayed(const Duration(seconds: 65));
      return _request(
        method,
        path,
        body: body,
        token: token,
        extraHeaders: extraHeaders,
        expectError: expectError,
        retryRateLimit: false,
      );
    }
    if (response.statusCode == 502 ||
        contentType.contains('text/html') ||
        text.trimLeft().startsWith('<')) {
      throw _CaptureStop(
        '$method $path returned status ${response.statusCode} '
        '(${contentType.isEmpty ? 'unknown content type' : contentType}) '
        'instead of JSON.',
      );
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } catch (_) {
      throw _CaptureStop('$method $path did not return valid JSON.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw _CaptureStop('$method $path returned a non-envelope JSON value.');
    }
    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (!ok && !expectError) {
      final code = _errorCode(decoded);
      throw _CaptureStop(
        '$method $path returned ${response.statusCode}'
        '${code == null ? '' : ' ($code)'}.',
      );
    }
    if (ok && expectError) {
      throw _CaptureStop('$method $path unexpectedly succeeded.');
    }
    return decoded;
  }

  void close() => _client.close(force: true);
}

String? _errorCode(Map<String, dynamic> envelope) {
  final errors = envelope['errors'];
  if (errors is List && errors.isNotEmpty && errors.first is Map) {
    final code = (errors.first as Map)['code'];
    if (code is String) return code;
  }
  return null;
}

String _token(Map<String, dynamic> envelope, String key) {
  final data = envelope['data'];
  if (data is Map && data[key] is String) return data[key] as String;
  throw _CaptureStop('Login envelope is missing $key.');
}

int _userId(Map<String, dynamic> envelope) {
  final data = envelope['data'];
  final user = data is Map ? data['user'] : null;
  final id = user is Map ? user['userId'] : null;
  if (id is num) return id.toInt();
  throw const _CaptureStop('Login envelope is missing user.userId.');
}

int? _firstPermissionId(Map<String, dynamic> envelope) {
  final validKey = RegExp(r'^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+$');
  for (final item in _items(envelope)) {
    final id = item['permissionId'];
    final key = item['permissionKey'];
    final statusId = item['statusId'];
    if (id is num && key is String && validKey.hasMatch(key) && statusId == 1) {
      return id.toInt();
    }
  }
  return null;
}

int? _unknownPermissionId(Map<String, dynamic> envelope) {
  for (final item in _items(envelope)) {
    final id = item['permissionId'];
    final key = item['permissionKey'];
    if (id is num && key is String && key.contains(' ')) return id.toInt();
  }
  return null;
}

List<Map<String, dynamic>> _items(Map<String, dynamic> envelope) {
  final data = envelope['data'];
  final items = data is Map ? data['items'] : null;
  if (items is! List) return const [];
  return [
    for (final item in items)
      if (item is Map<String, dynamic>) item,
  ];
}

int _itemCount(Map<String, dynamic> envelope) => _items(envelope).length;

int _orphanCount(Map<String, dynamic> envelope) =>
    _items(envelope).where((item) => item['permissionKey'] == null).length;

Object? _sanitize(Object? value) {
  if (value is Map) {
    final result = <String, dynamic>{};
    for (final entry in value.entries) {
      final key = entry.key.toString();
      final lower = key.toLowerCase();
      if (lower == 'loginid') {
        result[key] = 'qa.user';
      } else if (lower == 'username') {
        result[key] = 'Sanitized User';
      } else if (lower == 'employeename') {
        result[key] = 'Sanitized Employee';
      } else if (lower == 'employeecode') {
        result[key] = 'EMP-SANITIZED';
      } else if (lower.contains('mobile') || lower.contains('phone')) {
        result[key] = 'SANITIZED_MOBILE';
      } else if (lower == 'accesstoken') {
        result[key] = 'SANITIZED_ACCESS_TOKEN';
      } else if (lower == 'refreshtoken') {
        result[key] = 'SANITIZED_REFRESH_TOKEN';
      } else if (lower == 'password' || lower.contains('secret')) {
        result[key] = 'SANITIZED_SECRET';
      } else {
        result[key] = _sanitize(entry.value);
      }
    }
    return result;
  }
  if (value is List) return [for (final item in value) _sanitize(item)];
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
