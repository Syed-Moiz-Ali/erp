import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/backend_access_policy.dart';
import 'package:modular_erp/platform/access/data/dto/my_permissions_dto.dart';
import 'package:modular_erp/platform/auth/data/dto/auth_remote_dtos.dart';
import 'package:modular_erp/platform/auth/data/mappers/remote_auth_mapper.dart';

Map<String, dynamic> load(String name) =>
    jsonDecode(File('test/fixtures/auth/$name').readAsStringSync())
        as Map<String, dynamic>;

LoginResponseDto loginFrom(String name) =>
    LoginResponseDto.fromJson((load(name)['data'] as Map).cast());

void main() {
  test('login fixture matches the audit envelope and maps identity', () {
    final envelope = load('login_admin_success.json');
    expect(envelope['success'], isTrue);
    expect(envelope['errors'], isEmpty);

    final dto = loginFrom('login_admin_success.json');
    expect(dto.tokenType, 'Bearer');
    expect(dto.accessToken, 'SANITIZED_ADMIN_ACCESS_TOKEN');
    expect(dto.refreshToken, 'SANITIZED_ADMIN_REFRESH_TOKEN');
    expect(dto.expiresIn, 3600);
    expect(dto.user.userId, 8);
    expect(dto.user.loginId, 'qa.operator');
    expect(dto.user.name, 'Sanitized Operator');
    expect(dto.user.empId, 1);
    expect(dto.user.orgId, 1);
    expect(dto.user.branchName, 'Branch 1');
    expect(dto.user.timeZone, 'Asia/Dubai');
    expect(dto.user.orgCount, 9);
    expect(dto.user.transactionAccess, isTrue);
    expect(dto.user.reportAccess, isTrue);
    expect(dto.user.branches, hasLength(6));

    final session = RemoteAuthMapper.fromLogin(dto);
    expect(session.accessToken, 'SANITIZED_ADMIN_ACCESS_TOKEN');
    expect(session.refreshToken, 'SANITIZED_ADMIN_REFRESH_TOKEN');
    expect(session.context.user.id, '8');
    expect(session.context.user.loginId, 'qa.operator');
    expect(session.context.user.email, isNull);
    expect(session.context.company.id, '1');
    expect(session.context.company.name, 'Branch 1');
    expect(session.context.company.timezone, 'Asia/Dubai');
    expect(session.context.employeeReference?.id, '1');
    expect(session.context.branches, hasLength(6));
    expect(session.context.branches.first.id, '2');
    expect(session.context.branches.first.name, 'Branch 2');
    expect(session.context.settings['userType'], 'Director');
    // Login/refresh carry no grants; effective access must come from /me.
    expect(session.context.user.permissions.values, isEmpty);
    expect(session.context.company.enabledModules, isEmpty);
  });

  test('employee login fixture maps the restricted account', () {
    final dto = loginFrom('login_employee_success.json');
    expect(dto.accessToken, 'SANITIZED_EMPLOYEE_ACCESS_TOKEN');
    expect(dto.refreshToken, 'SANITIZED_EMPLOYEE_REFRESH_TOKEN');
    expect(dto.user.userId, 43);
    expect(dto.user.loginId, 'qa.employee');
    expect(dto.user.name, 'Sanitized Employee');
    expect(dto.user.userType, 'Sales');
    expect(dto.user.empId, 27);
    expect(dto.user.orgId, 3);
    expect(dto.user.branchName, 'Branch 3');
    expect(dto.user.timeZone, 'America/Chicago');
    expect(dto.user.orgCount, 1);
    expect(dto.user.transactionAccess, isFalse);
    expect(dto.user.reportAccess, isFalse);
    expect(dto.user.branches, hasLength(1));

    final session = RemoteAuthMapper.fromLogin(dto);
    expect(session.context.user.id, '43');
    expect(session.context.user.loginId, 'qa.employee');
    expect(session.context.user.email, isNull);
    expect(session.context.employeeReference?.id, '27');
    expect(session.context.branches.single.id, '3');
    expect(session.context.branches.single.name, 'Branch 3');
  });

  test('refresh fixture returns a complete rotated login response', () {
    final envelope = load('refresh_success.json');
    expect(envelope['message'], 'Token refreshed.');
    final dto = loginFrom('refresh_success.json');
    expect(dto.accessToken, 'SANITIZED_ROTATED_ACCESS_TOKEN');
    expect(dto.refreshToken, 'SANITIZED_ROTATED_REFRESH_TOKEN');

    final session = RemoteAuthMapper.fromLogin(dto);
    expect(session.context.user.id, '8');
    expect(session.context.user.loginId, 'qa.operator');
    expect(session.context.user.email, isNull);
    expect(session.context.branches, hasLength(6));
    expect(session.expiresAt.isAfter(DateTime.utc(2026, 10, 28, 6)), isTrue);
  });

  test('error fixtures expose codes and field names', () {
    final invalid = load('login_invalid_credentials.json');
    expect(invalid['success'], isFalse);
    expect(invalid['data'], isNull);
    expect(
      (invalid['errors'] as List).single['code'],
      'AUTH_INVALID_CREDENTIALS',
    );

    final validation = load('login_validation_error.json');
    expect((validation['errors'] as List).single['field'], 'loginId');
    expect((validation['errors'] as List).single['code'], 'VALIDATION_ERROR');
  });

  test('me/permissions fixture maps through the backend access policy', () {
    final dto = MyPermissionsDto.fromJson(
      (load('me_permissions_admin.json')['data'] as Map).cast(),
    );
    expect(dto.userId, 8);
    expect(dto.employeeId, 1);
    expect(dto.permissions, hasLength(14));
    expect(dto.permissions, contains('company.branches.view'));
    expect(dto.permissions, isNot(contains('hr.employees.view')));

    final access = BackendAccessPolicy.resolve(dto.permissions);
    expect(access.unknownKeys, isEmpty);
    expect(
      access.permissions.contains(AppPermission.companyBranchView),
      isTrue,
    );
    expect(
      access.permissions.contains(AppPermission.accessPermissionsManage),
      isTrue,
    );
    expect(access.permissions.contains(AppPermission.employeeViewAll), isFalse);
    expect(
      access.enabledModules,
      containsAll(['employees', 'attendance', 'settings']),
    );
  });

  test('employee me/permissions fixture maps the restricted grant set', () {
    final dto = MyPermissionsDto.fromJson(
      (load('me_permissions_employee.json')['data'] as Map).cast(),
    );
    expect(dto.userId, 43);
    expect(dto.employeeId, 27);
    expect(dto.permissions, [
      'hr.attendance.self.punch',
      'hr.attendance.self.view',
      'hr.employees.edit',
    ]);

    final access = BackendAccessPolicy.resolve(dto.permissions);
    expect(access.unknownKeys, isEmpty);
    expect(
      access.permissions.contains(AppPermission.attendanceViewSelf),
      isTrue,
    );
    expect(access.permissions.contains(AppPermission.employeeUpdate), isTrue);
    expect(access.permissions.contains(AppPermission.employeeViewAll), isFalse);
    expect(access.enabledModules, containsAll(['employees', 'attendance']));
  });

  test('logout fixture keeps the documented empty envelope', () {
    final envelope = load('logout_success.json');
    expect(envelope['success'], isTrue);
    expect(envelope['message'], 'Logged out.');
    expect(envelope['data'], isNull);
    expect(envelope['errors'], isEmpty);
  });

  test('unknown fixture keys fail closed and are reported separately', () {
    final dto = MyPermissionsDto.fromJson(
      (load('me_permissions_unknown.json')['data'] as Map).cast(),
    );
    final access = BackendAccessPolicy.resolve(dto.permissions);
    expect(access.unknownKeys, ['legacy.unknown.key']);
    expect(
      access.permissions.contains(AppPermission.companyBranchView),
      isTrue,
    );
    expect(access.permissions.contains(AppPermission.employeeViewAll), isTrue);
  });
}
