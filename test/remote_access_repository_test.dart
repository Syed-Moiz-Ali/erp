import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/platform/access/data/dto/permission_dtos.dart';
import 'package:modular_erp/platform/access/data/repositories/remote_access_repository.dart';
import 'package:modular_erp/platform/access/domain/user_permission_grant.dart';

import 'support/access_admin_fake.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/permissions/$name').readAsStringSync())
        as Map<String, dynamic>;

List<UserPermissionDto> _grantRows(String name) {
  final data = _fixture(name)['data'];
  final items = data is Map<String, dynamic>
      ? data['items'] as List
      : data as List;
  return [
    for (final item in items)
      UserPermissionDto.fromJson((item as Map).cast<String, dynamic>()),
  ];
}

List<PermissionDto> _permissions() {
  final data =
      _fixture('permissions_list.json')['data'] as Map<String, dynamic>;
  return [
    for (final item in data['items'] as List)
      PermissionDto.fromJson((item as Map).cast<String, dynamic>()),
  ];
}

UserPermissionDto _row({
  required int id,
  required int userId,
  String? key = 'company.access.users.view',
  int statusId = 1,
}) => UserPermissionDto(
  userPermissionId: id,
  userId: userId,
  permissionId: id,
  permissionStatusId: statusId,
  loginId: 'user$userId@example.test',
  userName: 'User $userId',
  employeeId: userId,
  employeeCode: 'EMP-$userId',
  employeeName: 'Employee $userId',
  permissionKey: key,
  createdBy: 8,
  createdOn: DateTime.utc(2026, 10, 27, 11, 16, 48),
);

void main() {
  late FakeAccessAdminRemoteDataSource data;
  late RemoteAccessRepository repository;

  setUp(() {
    data = FakeAccessAdminRemoteDataSource();
    repository = RemoteAccessRepository(data);
  });

  tearDown(() => repository.dispose());

  group('watchUsers (grants-derived)', () {
    test('groups key-bearing grants by user and drops orphan rows', () async {
      data.grantRows = [
        ..._grantRows('user_permissions_user8.json'),
        _row(id: 900, userId: 99, key: null, statusId: 2),
      ];

      final users = await repository.watchUsers(companyId: 'c9').first;

      expect(users, hasLength(1));
      final user = users.single;
      expect(user.userId, '8');
      expect(user.email, 'sanitized@example.com');
      expect(user.displayName, 'Sanitized Name');
      expect(user.employeeId, '1');
      expect(user.employeeCode, 'EMP-1');
      expect(user.hasLogin, isTrue);
      expect(user.accountStatus, 'active');
      expect(user.designationName, isNull);
      expect(user.departmentName, isNull);
    });

    test('follows totalPages and keeps users from later pages', () async {
      data.grantRows = [
        for (var i = 0; i < 120; i++) _row(id: i + 1, userId: 100),
        for (var i = 0; i < 20; i++) _row(id: 1000 + i, userId: 200),
      ];

      final users = await repository.watchUsers(companyId: 'c9').first;

      expect(users.map((u) => u.userId), containsAll(['100', '200']));
      expect(data.userPermissionPages, [1, 2]);
    });

    test('only users with a key-bearing grant are listed', () async {
      data.grantRows = [
        _row(id: 1, userId: 8, key: 'company.access.users.view'),
        _row(id: 2, userId: 9, key: null, statusId: 2),
        _row(id: 3, userId: 10, key: 'hr.departments.view', statusId: 2),
      ];

      final users = await repository.watchUsers(companyId: 'c9').first;

      expect(users.map((u) => u.userId), ['8']);
    });
  });

  group('grants', () {
    test('maps grant fields and drops orphans', () async {
      data.grantRows = _grantRows('user_permissions_user8.json');

      final result = await repository.getGrants(companyId: 'c9', userId: '8');

      expect(result, isA<Success<List<UserPermissionGrant>>>());
      final grants = (result as Success<List<UserPermissionGrant>>).value;
      expect(grants, hasLength(15));
      expect(grants.every((g) => g.permissionKey.isNotEmpty), isTrue);

      final grant = grants.firstWhere(
        (g) => g.permissionKey == 'company.access.permissions.manage',
      );
      expect(grant.id, '4');
      expect(grant.companyId, 'c9');
      expect(grant.userId, '8');
      expect(grant.scope, PermissionScope.all);
      expect(grant.grantedByUserId, '0');
      expect(grant.grantedAt, DateTime.utc(2026, 10, 27, 11, 16, 48));
      expect(grant.updatedAt, grant.grantedAt);
      expect(grant.isActive, isTrue);
      expect(grant.syncStatus, 'synced');
    });

    test('maps self-service keys to self and other keys to all', () async {
      data.grantRows = [
        _row(id: 1, userId: 8, key: 'hr.attendance.self.punch'),
        _row(id: 2, userId: 8, key: 'hr.attendance.self.view'),
        _row(id: 3, userId: 8, key: 'hr.employees.view'),
        _row(id: 4, userId: 8, key: 'company.access.users.view'),
      ];

      final grants =
          (await repository.getGrants(companyId: 'c9', userId: '8')
                  as Success<List<UserPermissionGrant>>)
              .value;

      PermissionScope scopeOf(String key) =>
          grants.firstWhere((g) => g.permissionKey == key).scope;

      expect(scopeOf('hr.attendance.self.punch'), PermissionScope.self);
      expect(scopeOf('hr.attendance.self.view'), PermissionScope.self);
      expect(scopeOf('hr.employees.view'), PermissionScope.all);
      expect(scopeOf('company.access.users.view'), PermissionScope.all);
    });

    test('watchGrants and watchCompanyGrants use the grant source', () async {
      data.grantRows = [
        ..._grantRows('user_permissions_user8.json'),
        ..._grantRows('user_permissions_user.json'),
      ];

      final forUser = await repository
          .watchGrants(companyId: 'c9', userId: '43')
          .first;
      expect(forUser, hasLength(3));

      final company = await repository
          .watchCompanyGrants(companyId: 'c9')
          .first;
      expect(company, hasLength(18));
    });

    test('403 propagates as forbidden', () async {
      data.userPermissionsFailure = const Failure(
        code: 'ACCESS_DENIED',
        kind: FailureKind.forbidden,
      );

      final result = await repository.getGrants(companyId: 'c9', userId: '8');

      expect(result, isA<Failed<List<UserPermissionGrant>>>());
      expect(
        (result as Failed<List<UserPermissionGrant>>).failure.kind,
        FailureKind.forbidden,
      );
    });

    test('watchHistory is always empty', () async {
      final history = await repository
          .watchHistory(companyId: 'c9', userId: '8')
          .first;
      expect(history, isEmpty);
    });
  });

  group('replaceGrants', () {
    setUp(() {
      data.permissionsCatalog = _permissions();
      data.grantRows = _grantRows('user_permissions_user.json');
    });

    test('resolves keys to permissionIds and sends only ids', () async {
      final result = await repository.replaceGrants(
        companyId: 'c9',
        actorUserId: '8',
        targetUserId: '43',
        requestId: 'r1',
        grants: const [
          PermissionGrantInput(
            key: 'hr.employees.view',
            scope: PermissionScope.all,
          ),
          PermissionGrantInput(
            key: 'company.access.users.view',
            scope: PermissionScope.all,
          ),
        ],
      );

      expect(result, isA<Success<void>>());
      expect(data.lastReplaceUserId, 43);
      expect(data.lastReplacePermissionIds, [18, 5]);
      expect(data.permissionPages, [1]);
    });

    test('unknown keys fail without writing', () async {
      final result = await repository.replaceGrants(
        companyId: 'c9',
        actorUserId: '8',
        targetUserId: '43',
        requestId: 'r1',
        grants: const [
          PermissionGrantInput(
            key: 'not.a.real.key',
            scope: PermissionScope.all,
          ),
        ],
      );

      expect(result, isA<Failed<void>>());
      expect((result as Failed<void>).failure.code, 'access.unknownPermission');
      expect(data.lastReplaceUserId, isNull);
    });

    test('bumps the revision so watchers re-read the complete list', () async {
      final values = <List<UserPermissionGrant>>[];
      final first = Completer<void>();
      final second = Completer<void>();
      final subscription = repository
          .watchGrants(companyId: 'c9', userId: '43')
          .listen((grants) {
            values.add(grants);
            if (!first.isCompleted) {
              first.complete();
            } else if (!second.isCompleted) {
              second.complete();
            }
          });

      await first.future.timeout(const Duration(seconds: 2));
      expect(values, hasLength(1));
      expect(values.single, hasLength(3));

      data.grantRows = [
        ..._grantRows('user_permissions_user.json'),
        _row(id: 200, userId: 43, key: 'hr.employees.view'),
      ];

      final result = await repository.replaceGrants(
        companyId: 'c9',
        actorUserId: '8',
        targetUserId: '43',
        requestId: 'r2',
        grants: const [
          PermissionGrantInput(
            key: 'hr.employees.view',
            scope: PermissionScope.all,
          ),
        ],
      );

      expect(result, isA<Success<void>>());
      await second.future.timeout(const Duration(seconds: 2));
      expect(values.last, hasLength(4));
      await subscription.cancel();
    });

    test('a backend rejection propagates and does not bump revision', () async {
      data.replaceFailure = const Failure(
        code: 'ACCESS_DENIED',
        kind: FailureKind.forbidden,
      );

      final result = await repository.replaceGrants(
        companyId: 'c9',
        actorUserId: '8',
        targetUserId: '43',
        requestId: 'r1',
        grants: const [
          PermissionGrantInput(
            key: 'hr.employees.view',
            scope: PermissionScope.all,
          ),
        ],
      );

      expect(result, isA<Failed<void>>());
      expect((result as Failed<void>).failure.kind, FailureKind.forbidden);
    });

    test('non-numeric user ids fail without a request', () async {
      final result = await repository.replaceGrants(
        companyId: 'c9',
        actorUserId: '8',
        targetUserId: 'local-user',
        requestId: 'r1',
        grants: const [],
      );

      expect(result, isA<Failed<void>>());
      expect((result as Failed<void>).failure.code, 'access.invalidUser');
      expect(data.lastReplaceUserId, isNull);
    });
  });

  group('concrete assign/revoke helpers', () {
    setUp(() {
      data.permissionsCatalog = _permissions();
    });

    test('assign posts userId and resolved permissionIds', () async {
      data.assignResult = Success(_grantRows('user_permissions_assign.json'));

      final result = await repository.assignPermissions(
        companyId: 'c9',
        targetUserId: '43',
        grants: const [
          PermissionGrantInput(
            key: 'hr.employees.view',
            scope: PermissionScope.all,
          ),
        ],
      );

      expect(result, isA<Success<List<UserPermissionGrant>>>());
      expect(data.lastAssignUserId, 43);
      expect(data.lastAssignPermissionIds, [18]);
      expect(
        (result as Success<List<UserPermissionGrant>>).value,
        hasLength(1),
      );
    });

    test('assign propagates failures', () async {
      data.assignFailure = const Failure(
        code: 'ACCESS_DENIED',
        kind: FailureKind.forbidden,
      );

      final result = await repository.assignPermissions(
        companyId: 'c9',
        targetUserId: '43',
        grants: const [
          PermissionGrantInput(
            key: 'hr.employees.view',
            scope: PermissionScope.all,
          ),
        ],
      );

      expect(result, isA<Failed<List<UserPermissionGrant>>>());
      expect(
        (result as Failed<List<UserPermissionGrant>>).failure.kind,
        FailureKind.forbidden,
      );
    });

    test('revoke deletes by userPermissionId', () async {
      data.removeResult = Success(
        _row(id: 145, userId: 43, key: 'hr.employees.view'),
      );

      final result = await repository.revokePermission(userPermissionId: '145');

      expect(result, isA<Success<void>>());
      expect(data.lastRemoveUserPermissionId, 145);
    });

    test('revoke propagates not-found and rejects non-numeric ids', () async {
      final notFound = await repository.revokePermission(
        userPermissionId: '145',
      );
      expect(notFound, isA<Failed<void>>());
      expect((notFound as Failed<void>).failure.kind, FailureKind.notFound);

      final invalid = await repository.revokePermission(userPermissionId: 'x');
      expect(invalid, isA<Failed<void>>());
      expect((invalid as Failed<void>).failure.code, 'access.invalidGrant');
    });
  });
}
