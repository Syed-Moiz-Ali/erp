import 'dart:convert';
import 'dart:io';

/// Read-only MassERP employee capture with an explicit view-permission gate.
///
/// The first call is `GET /api/employees`. If the administrator receives
/// `403 ACCESS_DENIED`, no employee data is captured: the tool saves the live
/// negative fixtures for both accounts and exits without further calls.
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
  final dir = Directory('test/fixtures/employees');
  dir.createSync(recursive: true);
  try {
    stdout.writeln('Logging in administrator once...');
    final adminSession = await client.post(
      '/api/auth/login',
      body: {'loginId': adminLogin, 'password': adminPassword},
      extraHeaders: const {'X-Client-Platform': 'android'},
    );
    final adminToken = _token(adminSession, 'accessToken');

    stdout.writeln('Checking administrator hr.employees.view...');
    final probe = await client.get(
      '/api/employees?page=1&pageSize=5',
      token: adminToken,
      allowError: true,
    );
    if (!_isSuccess(probe)) {
      final code = _errorCode(probe);
      _write(dir, 'employees_forbidden_admin.json', _sanitize(probe));
      stdout.writeln('Administrator employee list returned $code.');
      if (code == 'ACCESS_DENIED') {
        stdout.writeln('Logging in employee once for the negative fixture...');
        final employeeSession = await client.post(
          '/api/auth/login',
          body: {'loginId': employeeLogin, 'password': employeePassword},
          extraHeaders: const {'X-Client-Platform': 'android'},
        );
        final employeeToken = _token(employeeSession, 'accessToken');
        final employeeProbe = await client.get(
          '/api/employees?page=1&pageSize=5',
          token: employeeToken,
          allowError: true,
        );
        _write(
          dir,
          'employees_forbidden_employee.json',
          _sanitize(employeeProbe),
        );
        stdout.writeln(
          'STOP: live employee capture blocked by ACCESS_DENIED. '
          'Audit fallback required.',
        );
        exitCode = 2;
        return;
      }
      throw _CaptureStop('Precondition failed with $code.');
    }

    stdout.writeln('Precondition passed; capturing employees...');
    final list = await client.get(
      '/api/employees?page=1&pageSize=25&sort=nameAsc',
      token: adminToken,
    );
    final first = _firstEmployee(list);
    final employeeId = first?['employeeId'];
    final departmentId = first?['departmentId'];
    final branchId = first?['branchId'];
    final search = first?['employeeCode'] ?? 'EMP';
    final filteredQuery = <String>[
      'page=1',
      'pageSize=5',
      'sort=nameAsc',
      'search=${Uri.encodeQueryComponent('$search')}',
      if (departmentId is num) 'departmentId=$departmentId',
      if (branchId is num) 'branchId=$branchId',
      if (first?['statusId'] is num) 'statusId=${first!['statusId']}',
    ].join('&');
    final filtered = await client.get(
      '/api/employees?$filteredQuery',
      token: adminToken,
    );
    if (employeeId is! num) {
      throw const _CaptureStop('Employee list did not contain an id.');
    }
    final detail = await client.get(
      '/api/employees/${employeeId.toInt()}',
      token: adminToken,
    );
    final notFound = await client.get(
      '/api/employees/999999',
      token: adminToken,
      allowError: true,
    );
    final lookups = await client.get(
      '/api/employees/lookups',
      token: adminToken,
    );

    stdout.writeln('Logging in employee once for the negative fixture...');
    final employeeSession = await client.post(
      '/api/auth/login',
      body: {'loginId': employeeLogin, 'password': employeePassword},
      extraHeaders: const {'X-Client-Platform': 'android'},
    );
    final employeeToken = _token(employeeSession, 'accessToken');
    final employeeProbe = await client.get(
      '/api/employees?page=1&pageSize=5',
      token: employeeToken,
      allowError: true,
    );

    _write(dir, 'employees_list.json', _sanitize(list));
    _write(dir, 'employees_list_filtered.json', _sanitize(filtered));
    _write(dir, 'employee_detail.json', _sanitize(detail));
    _write(dir, 'employee_not_found.json', _sanitize(notFound));
    _write(dir, 'employee_lookups.json', _sanitize(lookups));
    _write(dir, 'employees_forbidden_employee.json', _sanitize(employeeProbe));
    stdout.writeln('Live employee capture complete.');
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
    bool allowError = false,
  }) => _request('GET', path, token: token, allowError: allowError);

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
    bool allowError = false,
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
        allowError: allowError,
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
    if (!ok && !allowError) {
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

bool _isSuccess(Map<String, dynamic> envelope) => envelope['success'] == true;

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

Map<String, dynamic>? _firstEmployee(Map<String, dynamic> envelope) {
  final data = envelope['data'];
  final items = data is Map ? data['items'] : null;
  if (items is! List || items.isEmpty) return null;
  final first = items.first;
  return first is Map<String, dynamic> ? first : null;
}

Object? _sanitize(Object? value) {
  if (value is Map) {
    final result = <String, dynamic>{};
    for (final entry in value.entries) {
      final key = entry.key.toString();
      final lower = key.toLowerCase();
      if (lower == 'employeename' || lower.endsWith('name')) {
        result[key] = 'Sanitized Name';
      } else if (lower == 'loginid') {
        result[key] = 'qa.user';
      } else if (lower == 'email') {
        result[key] = 'sanitized@example.com';
      } else if (lower.contains('phone') ||
          lower.contains('mobile') ||
          lower.contains('contact')) {
        result[key] = 'SANITIZED_PHONE';
      } else if (lower.contains('passport') ||
          lower.contains('visa') ||
          lower.contains('emirates') ||
          lower.contains('labour') ||
          lower.contains('iban') ||
          lower.contains('bank') ||
          lower.contains('accountnumber') ||
          lower.contains('tax') ||
          lower.contains('trn')) {
        result[key] = 'SANITIZED_ID';
      } else if (lower.contains('address')) {
        result[key] = 'Sanitized Address';
      } else if (lower.contains('photo') || lower.contains('logo')) {
        result[key] = 'SANITIZED_PATH';
      } else if (lower == 'accesstoken') {
        result[key] = 'SANITIZED_ACCESS_TOKEN';
      } else if (lower == 'refreshtoken') {
        result[key] = 'SANITIZED_REFRESH_TOKEN';
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
