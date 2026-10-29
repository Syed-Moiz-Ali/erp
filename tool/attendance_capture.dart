import 'dart:convert';
import 'dart:io';

/// Read-only MassERP attendance-today capture. Never sends a punch.
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
  final client = _Client(baseUrl);
  try {
    stdout.writeln('Logging in administrator once...');
    final adminToken = _token(
      await client.post('/api/auth/login', {
        'loginId': adminLogin,
        'password': adminPassword,
      }),
    );
    final adminToday = await client.get(
      '/api/attendance/today',
      adminToken,
      allowError: true,
    );

    stdout.writeln('Logging in employee once...');
    final employeeToken = _token(
      await client.post('/api/auth/login', {
        'loginId': employeeLogin,
        'password': employeePassword,
      }),
    );
    final employeeToday = await client.get(
      '/api/attendance/today',
      employeeToken,
      allowError: true,
    );

    final dir = Directory('test/fixtures/attendance');
    dir.createSync(recursive: true);
    _write(
      dir,
      adminToday['success'] == true
          ? 'today_admin.json'
          : 'today_admin_error.json',
      _sanitize(adminToday),
    );
    _write(
      dir,
      employeeToday['success'] == true
          ? 'today_employee.json'
          : 'today_employee_error.json',
      _sanitize(employeeToday),
    );
    stdout.writeln('Attendance capture complete.');
    stdout.writeln(
      'Admin success=${adminToday['success'] == true}, '
      'employee success=${employeeToday['success'] == true}.',
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
    _client.connectionTimeout = const Duration(seconds: 20);
  }
  final String baseUrl;
  final _client = HttpClient();

  Future<Map<String, dynamic>> get(
    String path,
    String token, {
    bool allowError = false,
  }) => _request('GET', path, token: token, allowError: allowError);

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) =>
      _request('POST', path, body: body);

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
    bool allowError = false,
    bool retry429 = true,
  }) async {
    final request = await _client.openUrl(method, Uri.parse('$baseUrl$path'));
    request.headers.set('ngrok-skip-browser-warning', 'true');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (token != null) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }
    final response = await request.close();
    final text = await response.transform(utf8.decoder).join();
    final type = response.headers.contentType?.mimeType ?? '';
    if (response.statusCode == 429 && retry429) {
      stdout.writeln('Rate limited; waiting 65 seconds...');
      await Future<void>.delayed(const Duration(seconds: 65));
      return _request(
        method,
        path,
        body: body,
        token: token,
        allowError: allowError,
        retry429: false,
      );
    }
    if (response.statusCode == 502 ||
        type.contains('text/html') ||
        text.trimLeft().startsWith('<')) {
      throw _Stop('$method $path returned non-JSON (${response.statusCode}).');
    }
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      throw _Stop('$method $path returned non-envelope JSON.');
    }
    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (!ok && !allowError) {
      throw _Stop(
        '$method $path returned ${response.statusCode} '
        '(${_errorCode(decoded) ?? 'unknown'}).',
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

String _token(Map<String, dynamic> envelope) {
  final data = envelope['data'];
  if (data is Map && data['accessToken'] is String) {
    return data['accessToken'] as String;
  }
  throw const _Stop('Login envelope missing accessToken.');
}

Object? _sanitize(Object? value) {
  if (value is Map) {
    final result = <String, dynamic>{};
    for (final entry in value.entries) {
      final key = entry.key.toString();
      final lower = key.toLowerCase();
      if (lower == 'employeename' || lower == 'name') {
        result[key] = 'Sanitized Employee';
      } else if (lower == 'employeecode') {
        result[key] = 'EMP-SANITIZED';
      } else if (lower == 'loginid') {
        result[key] = 'qa.user';
      } else if (lower == 'email') {
        result[key] = 'sanitized@example.com';
      } else if (lower.contains('phone') || lower.contains('mobile')) {
        result[key] = 'SANITIZED_PHONE';
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
