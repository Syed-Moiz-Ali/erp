import 'dart:convert';
import 'dart:io';

/// Read-only MassERP auth capture for local fixture generation.
///
/// Usage: `dart run tool/auth_capture.dart`
///
/// Reads credentials from the untracked `.env.local`, the base URL from
/// `.env.development`, and writes sanitized envelopes to `test/fixtures/auth`.
/// It never prints credentials, tokens or response bodies.
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
    stdout.writeln('Capturing admin login...');
    final adminLoginBody = await client.post(
      '/api/auth/login',
      body: {'loginId': adminLogin, 'password': adminPassword},
      extraHeaders: const {'X-Client-Platform': 'android'},
    );
    final adminAccess = _token(adminLoginBody, 'accessToken');
    final adminRefresh = _token(adminLoginBody, 'refreshToken');

    stdout.writeln('Capturing admin permissions...');
    final adminPermissions = await client.get(
      '/api/me/permissions',
      token: adminAccess,
    );

    stdout.writeln('Capturing admin refresh...');
    final refreshed = await client.post(
      '/api/auth/refresh',
      body: {'refreshToken': adminRefresh},
      extraHeaders: const {'X-Client-Platform': 'android'},
    );
    final rotatedRefresh = _token(refreshed, 'refreshToken');

    stdout.writeln('Capturing employee login...');
    final employeeLoginBody = await client.post(
      '/api/auth/login',
      body: {'loginId': employeeLogin, 'password': employeePassword},
      extraHeaders: const {'X-Client-Platform': 'android'},
    );
    final employeeAccess = _token(employeeLoginBody, 'accessToken');

    stdout.writeln('Capturing employee permissions...');
    final employeePermissions = await client.get(
      '/api/me/permissions',
      token: employeeAccess,
    );

    stdout.writeln('Capturing logout contract...');
    final logout = await client.post(
      '/api/auth/logout',
      body: {'refreshToken': rotatedRefresh},
    );

    final fixtureDir = Directory('test/fixtures/auth');
    fixtureDir.createSync(recursive: true);
    _write(
      fixtureDir,
      'login_admin_success.json',
      _sanitizeLogin(
        adminLoginBody,
        access: 'SANITIZED_ADMIN_ACCESS_TOKEN',
        refresh: 'SANITIZED_ADMIN_REFRESH_TOKEN',
        login: 'qa.operator',
        name: 'Sanitized Operator',
      ),
    );
    _write(
      fixtureDir,
      'login_employee_success.json',
      _sanitizeLogin(
        employeeLoginBody,
        access: 'SANITIZED_EMPLOYEE_ACCESS_TOKEN',
        refresh: 'SANITIZED_EMPLOYEE_REFRESH_TOKEN',
        login: 'qa.employee',
        name: 'Sanitized Employee',
      ),
    );
    _write(
      fixtureDir,
      'refresh_success.json',
      _sanitizeLogin(
        refreshed,
        access: 'SANITIZED_ROTATED_ACCESS_TOKEN',
        refresh: 'SANITIZED_ROTATED_REFRESH_TOKEN',
        login: 'qa.operator',
        name: 'Sanitized Operator',
      ),
    );
    _write(
      fixtureDir,
      'me_permissions_admin.json',
      _sanitizeGeneric(adminPermissions),
    );
    _write(
      fixtureDir,
      'me_permissions_employee.json',
      _sanitizeGeneric(employeePermissions),
    );
    _write(fixtureDir, 'logout_success.json', _sanitizeGeneric(logout));

    stdout.writeln('Live capture complete. Sanitized fixtures written.');
    stdout.writeln(
      'administrator permission count: ${_permissionCount(adminPermissions)}; '
      'employee permission count: ${_permissionCount(employeePermissions)}.',
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

  Future<Map<String, dynamic>> get(String path, {required String token}) =>
      _request('GET', path, token: token);

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    String? token,
    Map<String, String> extraHeaders = const {},
  }) => _request(
    'POST',
    path,
    body: body,
    token: token,
    extraHeaders: extraHeaders,
  );

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
    Map<String, String> extraHeaders = const {},
    bool retryRateLimit = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _client.openUrl(method, uri);
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
        retryRateLimit: false,
      );
    }
    if (response.statusCode == 502 ||
        contentType.contains('text/html') ||
        text.trimLeft().startsWith('<')) {
      throw _CaptureStop(
        '$method $path returned status ${response.statusCode} '
        '(${contentType.isEmpty ? 'unknown content type' : contentType}) '
        'instead of a JSON envelope.',
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
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final code = _errorCode(decoded);
      throw _CaptureStop(
        '$method $path returned ${response.statusCode}'
        '${code == null ? '' : ' ($code)'}.',
      );
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
  throw _CaptureStop('Login/refresh envelope is missing $key.');
}

int _permissionCount(Map<String, dynamic> envelope) {
  final data = envelope['data'];
  final permissions = data is Map ? data['permissions'] : null;
  return permissions is List ? permissions.length : 0;
}

Map<String, dynamic> _sanitizeLogin(
  Map<String, dynamic> envelope, {
  required String access,
  required String refresh,
  required String login,
  required String name,
}) {
  final copy = _sanitizeGeneric(_deepCopy(envelope)) as Map<String, dynamic>;
  final data = copy['data'];
  if (data is Map<String, dynamic>) {
    data['accessToken'] = access;
    data['refreshToken'] = refresh;
    final user = data['user'];
    if (user is Map<String, dynamic>) {
      final orgId = user['orgId'];
      user['loginId'] = login;
      user['name'] = name;
      if (user.containsKey('branchName')) {
        user['branchName'] = 'Branch $orgId';
      }
      final branches = user['branches'];
      if (branches is List) {
        for (final branch in branches) {
          if (branch is Map<String, dynamic>) {
            branch['branchName'] = 'Branch ${branch['orgId']}';
          }
        }
      }
    }
  }
  return copy;
}

Object? _sanitizeGeneric(Object? value) {
  if (value is Map) {
    final result = <String, dynamic>{};
    for (final entry in value.entries) {
      final key = entry.key.toString();
      final lower = key.toLowerCase();
      if (lower.contains('mobile') || lower.contains('phone')) {
        result[key] = 'SANITIZED_MOBILE';
      } else if (lower == 'accesstoken') {
        result[key] = 'SANITIZED_ACCESS_TOKEN';
      } else if (lower == 'refreshtoken') {
        result[key] = 'SANITIZED_REFRESH_TOKEN';
      } else if (lower == 'password' || lower.contains('secret')) {
        result[key] = 'SANITIZED_SECRET';
      } else {
        result[key] = _sanitizeGeneric(entry.value);
      }
    }
    return result;
  }
  if (value is List) return [for (final item in value) _sanitizeGeneric(item)];
  return value;
}

Object? _deepCopy(Object? value) =>
    value == null ? null : jsonDecode(jsonEncode(value));

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
