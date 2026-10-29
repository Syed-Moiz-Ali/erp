import 'dart:convert';
import 'dart:io';

import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/modules/hr/attendance/live/data/attendance_api.dart';
import 'package:modular_erp/modules/hr/attendance/live/domain/attendance_day.dart'
    as live;
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';

Map<String, dynamic> loadAttendanceFixture(String name) =>
    jsonDecode(File('test/fixtures/attendance/$name').readAsStringSync())
        as Map<String, dynamic>;

live.AttendanceDay attendanceDayFixture(String name) => live.AttendanceDay(
  (loadAttendanceFixture(name)['data'] as Map).cast<String, dynamic>(),
);

live.AttendanceDay attendanceDayFrom(Map<String, dynamic> data) =>
    live.AttendanceDay(data);

AuthContext attendanceAuth({
  String employeeId = '29',
  String companyId = '3',
  String displayName = 'Employee',
  String timezone = 'Asia/Dubai',
  Set<String> enabledModules = const {'attendance'},
}) => AuthContext(
  user: UserAccount(
    id: '5',
    displayName: displayName,
    email: 'login',
    companyId: companyId,
    permissions: PermissionSet(const <AppPermission>[]),
    status: AccountStatus.active,
  ),
  company: CompanyContext(
    id: companyId,
    name: 'Company',
    code: 'ORG-$companyId',
    timezone: timezone,
    defaultLocale: 'en',
    enabledModules: enabledModules,
  ),
  employeeReference: EmployeeReference(
    id: employeeId,
    userAccountId: '5',
    companyId: companyId,
  ),
);

/// In-memory attendance API. No Dio, no network.
class FakeAttendanceApi implements AttendanceApiClient {
  Future<Result<live.AttendanceDay>> Function()? onToday;
  Future<Result<live.AttendanceDay>> Function(
    String action,
    double? latitude,
    double? longitude,
  )?
  onPunch;

  int todayCalls = 0;
  int punchCalls = 0;
  String? lastAction;
  double? lastLatitude, lastLongitude;

  @override
  Future<Result<live.AttendanceDay>> today() async {
    todayCalls++;
    return (onToday ??
        () async => Success(attendanceDayFixture('today_working.json')))();
  }

  @override
  Future<Result<live.AttendanceDay>> punch(
    String action, {
    double? latitude,
    double? longitude,
  }) async {
    punchCalls++;
    lastAction = action;
    lastLatitude = latitude;
    lastLongitude = longitude;
    return (onPunch ??
        (action, latitude, longitude) async => Success(
          attendanceDayFixture('today_working.json'),
        ))(action, latitude, longitude);
  }
}

/// Minimal auth fake; only the session reads the attendance adapter needs.
class FakeAttendanceAuth implements AuthRepository {
  FakeAttendanceAuth(this.context);
  AuthContext? context;
  int checkSessionCalls = 0;

  @override
  Future<Result<AuthContext?>> checkSession() async {
    checkSessionCalls++;
    return Success(context);
  }

  @override
  Future<Result<AuthContext?>> restoreSession() async => Success(context);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
