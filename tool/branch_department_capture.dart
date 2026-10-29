import 'dart:convert';
import 'dart:io';

/// Read-only MassERP branch/department capture.
///
/// Usage: `dart run tool/branch_department_capture.dart`
///
/// Credentials come from untracked `.env.local`, the base URL from
/// `.env.development`. Only GET plus the two logins are sent. Tokens, personal
/// data and business names are sanitized before writing fixtures.
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
    final employee = await client.post(
      '/api/auth/login',
      body: {'loginId': employeeLogin, 'password': employeePassword},
      extraHeaders: const {'X-Client-Platform': 'android'},
    );
    final employeeToken = _token(employee, 'accessToken');

    stdout.writeln('Capturing branches...');
    final branchList = await client.get(
      '/api/branches?page=1&pageSize=25&sort=nameAsc',
      token: adminToken,
    );
    final branchFiltered = await client.get(
      '/api/branches?page=1&pageSize=5&sort=nameAsc&status=Active',
      token: adminToken,
    );
    final branchId = _firstId(branchList, 'branchId');
    if (branchId == null) throw const _CaptureStop('No branch id in list.');
    final branchDetail = await client.get(
      '/api/branches/$branchId',
      token: adminToken,
    );
    final branchNotFound = await client.get(
      '/api/branches/999999',
      token: adminToken,
      expectError: true,
    );
    final branchLookups = await client.get(
      '/api/branches/lookups',
      token: adminToken,
    );
    final branchForbidden = await client.get(
      '/api/branches?page=1&pageSize=5',
      token: employeeToken,
      expectError: true,
    );

    stdout.writeln('Capturing departments...');
    final departmentList = await client.get(
      '/api/departments?page=1&pageSize=25&sort=nameAsc',
      token: adminToken,
    );
    final departmentFiltered = await client.get(
      '/api/departments?page=1&pageSize=5&sort=nameAsc&search=a',
      token: adminToken,
    );
    final departmentId = _firstId(departmentList, 'departmentId');
    if (departmentId == null) {
      throw const _CaptureStop('No department id in list.');
    }
    final departmentDetail = await client.get(
      '/api/departments/$departmentId',
      token: adminToken,
    );
    final departmentNotFound = await client.get(
      '/api/departments/999999',
      token: adminToken,
      expectError: true,
    );
    final departmentForbidden = await client.get(
      '/api/departments?page=1&pageSize=5',
      token: employeeToken,
      expectError: true,
    );

    final branchDir = Directory('test/fixtures/branches');
    branchDir.createSync(recursive: true);
    _write(branchDir, 'branches_list.json', _sanitize(branchList));
    _write(branchDir, 'branches_list_filtered.json', _sanitize(branchFiltered));
    _write(branchDir, 'branch_detail.json', _sanitize(branchDetail));
    _write(branchDir, 'branch_not_found.json', _sanitize(branchNotFound));
    _write(branchDir, 'branch_lookups.json', _sanitize(branchLookups));
    _write(branchDir, 'branches_forbidden.json', _sanitize(branchForbidden));

    final departmentDir = Directory('test/fixtures/departments');
    departmentDir.createSync(recursive: true);
    _write(departmentDir, 'departments_list.json', _sanitize(departmentList));
    _write(
      departmentDir,
      'departments_list_filtered.json',
      _sanitize(departmentFiltered),
    );
    _write(
      departmentDir,
      'department_detail.json',
      _sanitize(departmentDetail),
    );
    _write(
      departmentDir,
      'department_not_found.json',
      _sanitize(departmentNotFound),
    );
    _write(
      departmentDir,
      'departments_forbidden.json',
      _sanitize(departmentForbidden),
    );

    final loginBranchIds = _loginBranchIds(adminLoginBody);
    final listBranchIds = _itemIds(branchList, 'branchId');
    stdout.writeln('Live capture complete.');
    stdout.writeln(
      'Login branches=${loginBranchIds.length}, list branches='
      '${listBranchIds.length}, ids equal='
      '${_sameIds(loginBranchIds, listBranchIds)}.',
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

int? _firstId(Map<String, dynamic> envelope, String key) {
  final data = envelope['data'];
  final items = data is Map ? data['items'] : null;
  if (items is! List) return null;
  for (final item in items) {
    if (item is Map && item[key] is num) return (item[key] as num).toInt();
  }
  return null;
}

Set<int> _itemIds(Map<String, dynamic> envelope, String key) {
  final data = envelope['data'];
  final items = data is Map ? data['items'] : null;
  if (items is! List) return {};
  return {
    for (final item in items)
      if (item is Map && item[key] is num) (item[key] as num).toInt(),
  };
}

Set<int> _loginBranchIds(Map<String, dynamic> login) {
  final data = login['data'];
  final user = data is Map ? data['user'] : null;
  final branches = user is Map ? user['branches'] : null;
  if (branches is! List) return {};
  return {
    for (final branch in branches)
      if (branch is Map && branch['orgId'] is num)
        (branch['orgId'] as num).toInt(),
  };
}

bool _sameIds(Set<int> a, Set<int> b) =>
    a.length == b.length && a.containsAll(b);

Object? _sanitize(Object? value) {
  if (value is Map) {
    final result = <String, dynamic>{};
    for (final entry in value.entries) {
      final key = entry.key.toString();
      final lower = key.toLowerCase();
      if (lower == 'branchname') {
        result[key] = 'Branch ${value['branchId'] ?? ''}'.trim();
      } else if (lower == 'departmentname') {
        result[key] = 'Department ${value['departmentId'] ?? ''}'.trim();
      } else if (lower == 'contactperson' ||
          lower == 'employeename' ||
          lower == 'username') {
        result[key] = 'Sanitized Name';
      } else if (lower == 'loginid') {
        result[key] = 'qa.user';
      } else if (lower == 'email') {
        result[key] = 'sanitized@example.com';
      } else if (lower == 'address') {
        result[key] = 'Sanitized Address';
      } else if (lower.contains('mobile') ||
          lower.contains('phone') ||
          lower == 'landline') {
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
