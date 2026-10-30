import 'dart:convert';
import 'dart:io';

import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/modules/hr/attendance/live/domain/attendance_day.dart';
import 'package:modular_erp/modules/hr/branches/data/dto/branch_dtos.dart';
import 'package:modular_erp/modules/hr/departments/data/dto/department_dtos.dart';
import 'package:modular_erp/modules/hr/employee_shifts/data/dto/employee_shift_dtos.dart';
import 'package:modular_erp/modules/hr/employees/live/data/dto/live_employee_dtos.dart';
import 'package:modular_erp/modules/hr/shifts/data/dto/shift_dtos.dart';
import 'package:modular_erp/platform/access/data/dto/my_permissions_dto.dart';
import 'package:modular_erp/platform/access/data/dto/permission_dtos.dart';

/// Read-only live smoke test against the MassERP backend.
///
/// Usage: `dart run tool/live_readonly_smoke.dart`
///
/// Reads `.env.local` first and falls back to `.env.development` for any missing
/// key. It performs only the two authentication logins and GET requests. It
/// never writes fixtures or files, and never prints credentials, tokens,
/// response bodies or personally identifying values. Only the method, path,
/// status, envelope outcome, backend error code and PASS/FAIL are printed.
Future<void> main() async {
  final local = _readEnv('.env.local');
  final development = _readEnv('.env.development');
  final env = <String, String>{...development, ...local};

  final authMode = (env['AUTH_MODE'] ?? '').trim();
  final baseUrl = (env['API_BASE_URL'] ?? '').trim().replaceAll(
    RegExp(r'/+$'),
    '',
  );
  final adminLogin = (env['MASSERP_ADMIN_LOGIN'] ?? '').trim();
  final adminPassword = env['MASSERP_ADMIN_PASSWORD'] ?? '';
  final employeeLogin = (env['MASSERP_EMPLOYEE_LOGIN'] ?? '').trim();
  final employeePassword = env['MASSERP_EMPLOYEE_PASSWORD'] ?? '';

  if (authMode != 'backend') {
    stderr.writeln('AUTH_MODE must be "backend" for the live smoke test.');
    exitCode = 1;
    return;
  }
  if (baseUrl.isEmpty) {
    stderr.writeln('API_BASE_URL is empty.');
    exitCode = 1;
    return;
  }
  if (adminLogin.isEmpty ||
      adminPassword.isEmpty ||
      employeeLogin.isEmpty ||
      employeePassword.isEmpty) {
    stderr.writeln('Missing local Admin or Employee credentials.');
    exitCode = 1;
    return;
  }

  final client = _SmokeClient(baseUrl);
  final runner = _SmokeRunner(client);
  try {
    await runner.runAdmin(login: adminLogin, password: adminPassword);
    await runner.runEmployee(login: employeeLogin, password: employeePassword);
    runner.printSummary();
    if (runner.failures > 0) exitCode = 1;
  } finally {
    client.close();
  }
}

class _SmokeRunner {
  _SmokeRunner(this.client);

  final _SmokeClient client;
  int passes = 0;
  int failures = 0;
  int skips = 0;

  Future<void> runAdmin({
    required String login,
    required String password,
  }) async {
    stdout.writeln('== Admin read-only matrix ==');
    final token = await _login(login: login, password: password);
    if (token == null) {
      _skipAllAdmin();
      return;
    }

    final me = await _get(
      '/api/me/permissions',
      token: token,
      dataCheck: _myPermissionsProblem,
    );
    final adminUserId = _intFrom(me.data, 'userId');

    final employees = await _get(
      '/api/employees?page=1&pageSize=5&sort=nameAsc',
      token: token,
      dataCheck: (data) => _pagedProblem(data, _employeeItemProblem),
    );
    final firstEmployeeId = _firstIdFromPaged(employees.data, 'employeeId');

    await _get(
      '/api/employees/lookups',
      token: token,
      dataCheck: (data) {
        if (data is! Map) return 'data is not an object';
        try {
          mapLookups(data.cast<String, dynamic>());
        } catch (error) {
          return 'lookups dto parse failed (${error.runtimeType})';
        }
        return null;
      },
    );

    if (firstEmployeeId == null) {
      _skip('/api/employees/{employeeId}', 'no employee id in the list');
    } else {
      await _get(
        '/api/employees/$firstEmployeeId',
        token: token,
        dataCheck: _objectCheck(_employeeItemProblem),
      );
    }

    final branches = await _get(
      '/api/branches?page=1&pageSize=5&status=Active',
      token: token,
      dataCheck: (data) => _pagedProblem(data, _branchItemProblem),
    );
    final firstBranchId = _firstIdFromPaged(branches.data, 'branchId');

    await _get(
      '/api/branches/lookups',
      token: token,
      dataCheck: (data) {
        if (data is! Map) return 'data is not an object';
        try {
          BranchLookupsDto.fromJson(data.cast<String, dynamic>());
        } catch (error) {
          return 'lookups dto parse failed (${error.runtimeType})';
        }
        return null;
      },
    );

    if (firstBranchId == null) {
      _skip('/api/branches/{branchId}', 'no branch id in the list');
    } else {
      await _get(
        '/api/branches/$firstBranchId',
        token: token,
        dataCheck: _objectCheck(_branchItemProblem),
      );
    }

    final departments = await _get(
      '/api/departments?page=1&pageSize=5&sort=nameAsc',
      token: token,
      dataCheck: (data) => _pagedProblem(data, _departmentItemProblem),
    );
    final firstDepartmentId = _firstIdFromPaged(
      departments.data,
      'departmentId',
    );

    if (firstDepartmentId == null) {
      _skip('/api/departments/{departmentId}', 'no department id in the list');
    } else {
      await _get(
        '/api/departments/$firstDepartmentId',
        token: token,
        dataCheck: _objectCheck(_departmentItemProblem),
      );
    }

    final shifts = await _get(
      '/api/shifts?page=1&pageSize=5&sort=startTime',
      token: token,
      dataCheck: (data) => _pagedProblem(data, _shiftItemProblem),
    );
    final firstShiftId = _firstIdFromPaged(shifts.data, 'shiftId');

    if (firstShiftId == null) {
      _skip('/api/shifts/{shiftId}', 'no shift id in the list');
    } else {
      await _get(
        '/api/shifts/$firstShiftId',
        token: token,
        dataCheck: _objectCheck(_shiftItemProblem),
      );
    }

    if (firstEmployeeId == null) {
      _skip(
        '/api/employee-shifts',
        'no employee id for the 7-day assignment window',
      );
    } else {
      final today = DateTime.now();
      final from = today.subtract(const Duration(days: 3));
      final to = today.add(const Duration(days: 3));
      await _get(
        '/api/employee-shifts?employeeId=$firstEmployeeId'
        '&fromDate=${_isoDate(from)}&toDate=${_isoDate(to)}',
        token: token,
        okStatuses: const {200, 400},
        dataCheck: (data) => _pagedProblem(
          data,
          _employeeShiftItemProblem,
          allowEmptyData: false,
        ),
      );
    }

    await _get(
      '/api/permissions?page=1&pageSize=10&sort=keyAsc',
      token: token,
      dataCheck: (data) => _pagedProblem(data, _permissionItemProblem),
    );

    if (adminUserId == null) {
      _skip('/api/user-permissions', 'no admin userId in /api/me/permissions');
      _skip(
        '/api/user-permissions/{userPermissionId}',
        'no admin userId in /api/me/permissions',
      );
    } else {
      final grants = await _get(
        '/api/user-permissions?userId=$adminUserId&page=1&pageSize=10',
        token: token,
        dataCheck: (data) => _pagedProblem(data, _userPermissionItemProblem),
      );
      final firstGrantId = _firstIdFromPaged(grants.data, 'userPermissionId');
      if (firstGrantId == null) {
        _skip(
          '/api/user-permissions/{userPermissionId}',
          'admin has no grants in the first page',
        );
      } else {
        await _get(
          '/api/user-permissions/$firstGrantId',
          token: token,
          dataCheck: _objectCheck(_userPermissionItemProblem),
        );
      }
    }
  }

  Future<void> runEmployee({
    required String login,
    required String password,
  }) async {
    stdout.writeln('== Employee read-only matrix ==');
    final token = await _login(login: login, password: password);
    if (token == null) {
      _skip('/api/me/permissions', 'employee login failed');
      _skip('/api/attendance/today', 'employee login failed');
      _skip('/api/employees', 'employee login failed');
      return;
    }

    await _get(
      '/api/me/permissions',
      token: token,
      dataCheck: _myPermissionsProblem,
    );

    await _get(
      '/api/attendance/today',
      token: token,
      dataCheck: _attendanceProblem,
    );

    await _get(
      '/api/employees?page=1&pageSize=5&sort=nameAsc',
      token: token,
      okStatuses: const {200, 403},
      dataCheck: (data) => _pagedProblem(data, _employeeItemProblem),
    );
  }

  void _skipAllAdmin() {
    for (final path in const [
      '/api/me/permissions',
      '/api/employees',
      '/api/employees/lookups',
      '/api/employees/{employeeId}',
      '/api/branches',
      '/api/branches/lookups',
      '/api/branches/{branchId}',
      '/api/departments',
      '/api/departments/{departmentId}',
      '/api/shifts',
      '/api/shifts/{shiftId}',
      '/api/employee-shifts',
      '/api/permissions',
      '/api/user-permissions',
      '/api/user-permissions/{userPermissionId}',
    ]) {
      _skip(path, 'admin login failed');
    }
  }

  Future<String?> _login({
    required String login,
    required String password,
  }) async {
    const path = '/api/auth/login';
    final response = await _send(
      'POST',
      path,
      body: {'loginId': login, 'password': password},
    );
    final envelope = _envelope(response);
    final problem = response == null
        ? 'transport failure'
        : _envelopeProblem(envelope);
    final success = envelope?['success'];
    final code = envelope == null ? null : _errorCode(envelope);
    if (response == null ||
        problem != null ||
        response.statusCode != 200 ||
        success != true) {
      _record(
        'POST',
        path,
        response,
        envelope,
        problem ?? (success == false ? 'login failed ($code)' : null),
        pass: false,
      );
      failures++;
      return null;
    }
    final data = envelope!['data'];
    final token = data is Map ? data['accessToken'] : null;
    if (token is! String || token.isEmpty) {
      _record(
        'POST',
        path,
        response,
        envelope,
        'data.accessToken missing or not a string',
        pass: false,
      );
      failures++;
      return null;
    }
    _record('POST', path, response, envelope, null, pass: true);
    passes++;
    return token;
  }

  Future<_Outcome> _get(
    String path, {
    required String token,
    Set<int> okStatuses = const {200},
    String? Function(Object? data)? dataCheck,
  }) async {
    final response = await _send('GET', path, token: token);
    final envelope = _envelope(response);
    String? problem;
    bool pass = false;
    Object? data;

    if (response == null) {
      problem = 'transport failure';
    } else {
      problem = _envelopeProblem(envelope);
      if (problem == null) {
        final success = envelope!['success'];
        final code = _errorCode(envelope);
        if (!okStatuses.contains(response.statusCode)) {
          problem =
              'unexpected status ${response.statusCode}'
              '${code == null ? '' : ' ($code)'}';
        } else if (response.statusCode >= 400) {
          if (success != false) {
            problem =
                'expected a failed envelope for '
                '${response.statusCode}';
          } else {
            pass = true;
            data = envelope['data'];
            problem =
                'documented ${response.statusCode}'
                '${code == null ? '' : ' ($code)'}';
          }
        } else if (success != true) {
          problem =
              'envelope.success is false'
              '${code == null ? '' : ' ($code)'}';
        } else {
          data = envelope['data'];
          if (dataCheck != null) {
            try {
              problem = dataCheck(data);
            } catch (error) {
              problem = 'payload parse failed (${error.runtimeType})';
            }
          }
          pass = problem == null;
        }
      }
    }

    _record('GET', path, response, envelope, problem, pass: pass);
    if (pass) {
      passes++;
    } else {
      failures++;
    }
    return _Outcome(pass: pass, data: pass ? data : null);
  }

  Future<_Response?> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      return await client.send(method, path, body: body, token: token);
    } catch (_) {
      return null;
    }
  }

  void _record(
    String method,
    String path,
    _Response? response,
    Map<String, dynamic>? envelope,
    String? note, {
    required bool pass,
  }) {
    final status = response?.statusCode.toString() ?? '-';
    final envelopeState = response == null
        ? 'missing'
        : envelope == null
        ? 'invalid'
        : _envelopeProblem(envelope) == null
        ? 'ok'
        : 'invalid';
    final code = envelope == null ? '-' : (_errorCode(envelope) ?? '-');
    final outcome = pass ? 'PASS' : 'FAIL';
    final detail = note == null ? '' : ' | $note';
    stdout.writeln(
      '$method $path status=$status envelope=$envelopeState '
      'error=$code $outcome$detail',
    );
  }

  void _skip(String path, String reason) {
    skips++;
    stdout.writeln('GET $path SKIP | $reason');
  }

  void printSummary() {
    stdout.writeln(
      '== Summary: $passes passed, $failures failed, $skips skipped ==',
    );
  }
}

class _Outcome {
  const _Outcome({required this.pass, this.data});

  final bool pass;
  final Object? data;
}

class _Response {
  const _Response(this.statusCode, this.body, this.isJson);

  final int statusCode;
  final Object? body;
  final bool isJson;
}

class _SmokeClient {
  _SmokeClient(this.baseUrl) {
    _client.connectionTimeout = const Duration(seconds: 20);
  }

  final String baseUrl;
  final HttpClient _client = HttpClient();

  Future<_Response> send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    var request = await _client.openUrl(method, uri);
    request.headers.set('ngrok-skip-browser-warning', 'true');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (token != null) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }
    var response = await request.close();
    var text = await response.transform(utf8.decoder).join();
    if (response.statusCode == 429) {
      stdout.writeln(
        '[429] $method $path rate limited; waiting 61 seconds for one retry',
      );
      await Future<void>.delayed(const Duration(seconds: 61));
      request = await _client.openUrl(method, uri);
      request.headers.set('ngrok-skip-browser-warning', 'true');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (token != null) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode(body));
      }
      response = await request.close();
      text = await response.transform(utf8.decoder).join();
    }
    Object? decoded;
    var isJson = false;
    try {
      decoded = jsonDecode(text);
      isJson = true;
    } catch (_) {
      isJson = false;
    }
    return _Response(response.statusCode, decoded, isJson);
  }

  void close() => _client.close(force: true);
}

Map<String, dynamic>? _envelope(_Response? response) {
  final body = response?.body;
  if (body is! Map) return null;
  try {
    return body.cast<String, dynamic>();
  } catch (_) {
    return null;
  }
}

String? _envelopeProblem(Map<String, dynamic>? envelope) {
  if (envelope == null) return 'response body is not a JSON object';
  for (final key in const ['success', 'message', 'data', 'errors']) {
    if (!envelope.containsKey(key)) return 'envelope missing $key';
  }
  if (envelope['success'] is! bool) return 'envelope.success is not a bool';
  if (envelope['errors'] is! List) return 'envelope.errors is not a list';
  return null;
}

String? _errorCode(Map<String, dynamic> envelope) {
  final errors = envelope['errors'];
  if (errors is List) {
    for (final item in errors) {
      if (item is Map) {
        final code = item['code'];
        if (code is String && code.isNotEmpty) return code;
      }
    }
  }
  return null;
}

String? _pagedProblem(
  Object? data,
  String? Function(Map<String, dynamic> item) itemProblem, {
  bool allowEmptyData = false,
}) {
  if (allowEmptyData && data == null) return null;
  if (data is! Map) return 'data is not an object';
  final map = data.cast<String, dynamic>();
  for (final key in const [
    'items',
    'page',
    'pageSize',
    'totalItems',
    'totalPages',
  ]) {
    if (!map.containsKey(key)) return 'paged missing $key';
  }
  if (map['items'] is! List) return 'paged.items is not a list';
  for (final key in const ['page', 'pageSize', 'totalItems', 'totalPages']) {
    if (map[key] is! num) return 'paged.$key is not numeric';
  }
  if ((map['page'] as num).toInt() < 1) return 'paged.page is not 1-based';
  final items = map['items'] as List;
  for (var index = 0; index < items.length; index++) {
    final item = items[index];
    if (item is! Map) return 'paged.items[$index] is not an object';
    final problem = itemProblem(item.cast<String, dynamic>());
    if (problem != null) return 'paged.items[$index].$problem';
  }
  try {
    PagedResult<Map<String, dynamic>>.fromJson(
      map,
      (json) => (json as Map).cast<String, dynamic>(),
    );
  } catch (error) {
    return 'paged dto parse failed (${error.runtimeType})';
  }
  return null;
}

String? _myPermissionsProblem(Object? data) {
  if (data is! Map) return 'data is not an object';
  final map = data.cast<String, dynamic>();
  if (map['userId'] is! num) return 'userId is not numeric';
  if (map['permissions'] is! List) return 'permissions is not a list';
  try {
    MyPermissionsDto.fromJson(map);
  } catch (error) {
    return 'dto parse failed (${error.runtimeType})';
  }
  return null;
}

String? _employeeItemProblem(Map<String, dynamic> json) {
  final id = _numeric(json, 'employeeId');
  if (id != null) return id;
  try {
    LiveEmployeeDto.fromJson(json).toDomain();
  } catch (error) {
    return 'dto parse failed (${error.runtimeType})';
  }
  return null;
}

String? _branchItemProblem(Map<String, dynamic> json) {
  final id = _numeric(json, 'branchId');
  if (id != null) return id;
  final name = _string(json, 'branchName');
  if (name != null) return name;
  try {
    BranchDto.fromJson(json);
  } catch (error) {
    return 'dto parse failed (${error.runtimeType})';
  }
  return null;
}

String? _departmentItemProblem(Map<String, dynamic> json) {
  final id = _numeric(json, 'departmentId');
  if (id != null) return id;
  final name = _string(json, 'departmentName');
  if (name != null) return name;
  try {
    DepartmentDto.fromJson(json);
  } catch (error) {
    return 'dto parse failed (${error.runtimeType})';
  }
  return null;
}

String? _shiftItemProblem(Map<String, dynamic> json) {
  final id = _numeric(json, 'shiftId');
  if (id != null) return id;
  for (final key in const ['shiftName', 'startTime', 'endTime']) {
    final problem = _string(json, key);
    if (problem != null) return problem;
  }
  try {
    ShiftDto.fromJson(json);
  } catch (error) {
    return 'dto parse failed (${error.runtimeType})';
  }
  return null;
}

String? _employeeShiftItemProblem(Map<String, dynamic> json) {
  for (final key in const ['employeeShiftId', 'employeeId', 'shiftId']) {
    final problem = _numeric(json, key);
    if (problem != null) return problem;
  }
  for (final key in const ['fromDate', 'toDate', 'startTime', 'endTime']) {
    final problem = _string(json, key);
    if (problem != null) return problem;
  }
  try {
    EmployeeShiftDto.fromJson(json);
  } catch (error) {
    return 'dto parse failed (${error.runtimeType})';
  }
  return null;
}

String? _permissionItemProblem(Map<String, dynamic> json) {
  final id = _numeric(json, 'permissionId');
  if (id != null) return id;
  for (final key in const ['permissionKey', 'permissionName']) {
    final problem = _string(json, key);
    if (problem != null) return problem;
  }
  try {
    PermissionDto.fromJson(json);
  } catch (error) {
    return 'dto parse failed (${error.runtimeType})';
  }
  return null;
}

String? _userPermissionItemProblem(Map<String, dynamic> json) {
  for (final key in const ['userPermissionId', 'userId', 'permissionId']) {
    final problem = _numeric(json, key);
    if (problem != null) return problem;
  }
  try {
    UserPermissionDto.fromJson(json);
  } catch (error) {
    return 'dto parse failed (${error.runtimeType})';
  }
  return null;
}

String? _attendanceProblem(Object? data) {
  if (data is! Map) return 'data is not an object';
  final map = data.cast<String, dynamic>();
  for (final key in const ['employeeId', 'workedMinutes', 'breakMinutes']) {
    final problem = _numeric(map, key);
    if (problem != null) return problem;
  }
  for (final key in const ['date', 'timeZone', 'state', 'serverTime']) {
    final problem = _string(map, key);
    if (problem != null) return problem;
  }
  for (final key in const ['allowedActions', 'shifts']) {
    if (map[key] is! List) return '$key is not a list';
  }
  try {
    final day = AttendanceDay(map);
    if (day.employeeId <= 0) return 'employeeId is not positive';
    for (final shift in day.shifts) {
      if (shift.shiftNo <= 0) return 'shifts[].shiftNo is not positive';
    }
  } catch (error) {
    return 'dto parse failed (${error.runtimeType})';
  }
  return null;
}

String? Function(Object?) _objectCheck(
  String? Function(Map<String, dynamic>) check,
) => (data) {
  if (data is! Map) return 'data is not an object';
  return check(data.cast<String, dynamic>());
};

String? _numeric(Map<String, dynamic> json, String key) =>
    json[key] is num ? null : '$key is not numeric';

String? _string(Map<String, dynamic> json, String key) =>
    json[key] is String ? null : '$key is not a string';

int? _intFrom(Object? data, String key) {
  if (data is! Map) return null;
  final value = data[key];
  return value is num ? value.toInt() : null;
}

int? _firstIdFromPaged(Object? data, String key) {
  if (data is! Map) return null;
  final items = data['items'];
  if (items is! List) return null;
  for (final item in items) {
    if (item is Map) {
      final value = item[key];
      if (value is num) return value.toInt();
    }
  }
  return null;
}

String _isoDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

Map<String, String> _readEnv(String path) {
  final file = File(path);
  if (!file.existsSync()) return const {};
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
