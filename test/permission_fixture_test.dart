import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/platform/access/data/dto/permission_dtos.dart';

Map<String, dynamic> load(String name) =>
    jsonDecode(File('test/fixtures/permissions/$name').readAsStringSync())
        as Map<String, dynamic>;

List<Map<String, dynamic>> items(String name) {
  final data = load(name)['data'] as Map<String, dynamic>;
  return [
    for (final item in data['items'] as List)
      (item as Map).cast<String, dynamic>(),
  ];
}

void main() {
  test('permission list keeps paging, filters and unknown keys', () {
    final envelope = load('permissions_list.json');
    expect(envelope['message'], 'Permissions retrieved.');
    final data = envelope['data'] as Map<String, dynamic>;
    expect(data['page'], 1);
    expect(data['pageSize'], 25);
    expect(data['totalItems'], 17);
    expect(data['totalPages'], 1);

    final rows = items(
      'permissions_list.json',
    ).map(PermissionDto.fromJson).toList();
    expect(rows, hasLength(17));
    final unknown = rows.firstWhere((row) => row.permissionId == 20);
    expect(unknown.permissionKey, 'bad key with spaces');
    expect(unknown.isActive, isFalse);
    final employeeView = rows.firstWhere(
      (row) => row.permissionKey == 'hr.employees.view',
    );
    expect(employeeView.isActive, isTrue);
    expect(employeeView.description, isNotNull);

    final filtered = load('permissions_list_filtered.json')['data'] as Map;
    expect(filtered['totalItems'], 15);
    expect((filtered['items'] as List), hasLength(5));
  });

  test('permission detail parses creator/modifier fields', () {
    final dto = PermissionDto.fromJson(
      (load('permission_detail.json')['data'] as Map).cast(),
    );
    expect(dto.permissionId, 4);
    expect(dto.permissionKey, 'company.access.permissions.manage');
    expect(dto.statusId, 1);
    expect(dto.createdBy, 0);
    expect(dto.createdOn, isNotNull);
    expect(dto.modifiedBy, isNull);
    expect(dto.modifiedOn, isNull);

    final unknown = PermissionDto.fromJson(
      (load('permission_detail_unknown.json')['data'] as Map).cast(),
    );
    expect(unknown.permissionKey, 'bad key with spaces');
    expect(unknown.isActive, isFalse);
    expect(unknown.modifiedBy, 8);
  });

  test('permission 404 keeps the error envelope', () {
    final envelope = load('permission_not_found.json');
    expect(envelope['success'], isFalse);
    expect(envelope['data'], isNull);
    final error = (envelope['errors'] as List).single as Map;
    expect(error['code'], 'PERMISSION_NOT_FOUND');
  });

  test('user permission rows model orphan and inactive masters', () {
    final envelope = load('user_permissions_all.json');
    final data = envelope['data'] as Map<String, dynamic>;
    expect(data['page'], 1);
    expect(data['totalItems'], 135);
    expect(data['totalPages'], 2);

    final rows = items(
      'user_permissions_all.json',
    ).map(UserPermissionDto.fromJson).toList();
    expect(rows, hasLength(100));
    final orphans = rows.where((row) => row.permissionKey == null).toList();
    expect(orphans, hasLength(8));
    expect(orphans.first.permissionId, 1);
    expect(orphans.first.permissionStatusId, 2);
    expect(orphans.first.isActive, isFalse);
    expect(orphans.first.permissionName, isNull);
  });

  test('user filter fixture returns the employee grant set', () {
    final rows = items(
      'user_permissions_user.json',
    ).map(UserPermissionDto.fromJson).toList();
    expect(rows, hasLength(3));
    expect(rows.every((row) => row.userId == 43), isTrue);
    expect(rows.every((row) => row.employeeId == 27), isTrue);
    expect(
      rows.map((row) => row.permissionKey),
      containsAll([
        'hr.attendance.self.punch',
        'hr.attendance.self.view',
        'hr.employees.edit',
      ]),
    );
  });

  test('assign response is the complete list including orphan grants', () {
    final envelope = load('user_permissions_assign.json');
    final rows = (envelope['data'] as List)
        .map((item) => UserPermissionDto.fromJson(item as Map<String, dynamic>))
        .toList();
    expect(rows, hasLength(4));
    expect(rows.where((row) => row.permissionKey == null), hasLength(3));
    expect(
      rows
          .where((row) => row.permissionKey == null)
          .map((row) => row.permissionId),
      [1, 2, 3],
    );
    expect(rows.first.permissionKey, 'hr.employees.view');
    expect(rows.first.isActive, isTrue);
    expect(rows.skip(1).every((row) => !row.isActive), isTrue);
  });

  test('me permissions fixtures differ by account', () {
    final admin =
        load('me_permissions_admin.json')['data'] as Map<String, dynamic>;
    final employee =
        load('me_permissions_employee.json')['data'] as Map<String, dynamic>;
    expect(admin['userId'], 8);
    expect(admin['permissions'], hasLength(15));
    expect(admin['permissions'], contains('hr.employees.view'));
    expect(employee['userId'], 43);
    expect(employee['permissions'], hasLength(4));
    expect(
      employee['permissions'],
      containsAll(['hr.employees.edit', 'hr.employees.view']),
    );
  });
}
