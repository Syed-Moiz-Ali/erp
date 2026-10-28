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
    final envelope = load('login_success.json');
    expect(envelope['success'], isTrue);
    expect(envelope['errors'], isEmpty);

    final dto = loginFrom('login_success.json');
    expect(dto.tokenType, 'Bearer');
    expect(dto.accessToken, 'SANITIZED_ACCESS_TOKEN');
    expect(dto.refreshToken, 'SANITIZED_REFRESH_TOKEN');
    expect(dto.expiresIn, 3600);
    expect(dto.user.userId, 8);
    expect(dto.user.loginId, 'qa.admin');
    expect(dto.user.name, 'Sanitized Admin');
    expect(dto.user.empId, 1);
    expect(dto.user.orgId, 1);
    expect(dto.user.branchName, 'Company A');
    expect(dto.user.timeZone, 'Asia/Dubai');
    expect(dto.user.orgCount, 2);
    expect(dto.user.transactionAccess, isTrue);
    expect(dto.user.reportAccess, isTrue);
    expect(dto.user.branches, hasLength(2));

    final session = RemoteAuthMapper.fromLogin(dto);
    expect(session.accessToken, 'SANITIZED_ACCESS_TOKEN');
    expect(session.refreshToken, 'SANITIZED_REFRESH_TOKEN');
    expect(session.context.user.id, '8');
    expect(session.context.user.loginId, 'qa.admin');
    expect(session.context.user.email, isNull);
    expect(session.context.company.id, '1');
    expect(session.context.company.name, 'Company A');
    expect(session.context.company.timezone, 'Asia/Dubai');
    expect(session.context.employeeReference?.id, '1');
    expect(session.context.branches, hasLength(2));
    expect(session.context.branches.first.id, '1');
    expect(session.context.branches.first.name, 'Company A');
    expect(session.context.settings['userType'], 'Director');
    // Login/refresh carry no grants; effective access must come from /me.
    expect(session.context.user.permissions.values, isEmpty);
    expect(session.context.company.enabledModules, isEmpty);
  });

  test('refresh fixture returns a complete rotated login response', () {
    final envelope = load('refresh_success.json');
    expect(envelope['message'], 'Token refreshed.');
    final dto = loginFrom('refresh_success.json');
    expect(dto.accessToken, 'SANITIZED_ROTATED_ACCESS_TOKEN');
    expect(dto.refreshToken, 'SANITIZED_ROTATED_REFRESH_TOKEN');

    final session = RemoteAuthMapper.fromLogin(dto);
    expect(session.context.user.id, '8');
    expect(session.context.user.loginId, 'qa.admin');
    expect(session.context.user.email, isNull);
    expect(session.context.branches, hasLength(2));
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
      (load('me_permissions.json')['data'] as Map).cast(),
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
