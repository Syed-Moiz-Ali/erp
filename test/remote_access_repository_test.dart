import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/access/erp_access_catalog.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/platform/access/data/datasources/remote/access_remotes.dart';
import 'package:modular_erp/platform/access/data/dto/permission_dtos.dart';
import 'package:modular_erp/platform/access/data/repositories/remote_access_repository.dart';
import 'package:modular_erp/platform/access/domain/user_permission_grant.dart';

class _FakeAccessAdmin implements AccessAdminRemoteDataSource {
  List<PermissionDto> permissionRows = const [];
  List<UserPermissionDto> rows = const [];
  List<int>? replacedIds;

  PagedResult<T> _page<T>(List<T> items) => PagedResult(
    items: items,
    page: 1,
    pageSize: 100,
    totalItems: items.length,
    totalPages: 1,
  );

  @override
  Future<Result<PagedResult<PermissionDto>>> permissions({
    int page = 1,
    int pageSize = 100,
    String search = '',
    int? statusId,
    CancelToken? cancelToken,
  }) async => Success(_page(permissionRows));

  @override
  Future<Result<PagedResult<UserPermissionDto>>> userPermissions({
    int? userId,
    int? employeeId,
    int? permissionId,
    int page = 1,
    int pageSize = 100,
    CancelToken? cancelToken,
  }) async => Success(
    _page(
      rows
          .where((row) => userId == null || row.userId == userId)
          .where(
            (row) => permissionId == null || row.permissionId == permissionId,
          )
          .toList(),
    ),
  );

  @override
  Future<Result<List<UserPermissionDto>>> replaceUserPermissions(
    int userId,
    List<int> permissionIds, {
    CancelToken? cancelToken,
  }) async {
    replacedIds = permissionIds;
    return const Success([]);
  }

  @override
  Future<Result<UserPermissionDto>> removeUserPermission(
    int userPermissionId, {
    CancelToken? cancelToken,
  }) async => const Failed(
    Failure(code: 'user_permission_not_found', kind: FailureKind.notFound),
  );
}

PermissionDto _permission(int id, String key) => PermissionDto(
  permissionId: id,
  permissionKey: key,
  permissionName: key,
  statusId: 1,
);

UserPermissionDto _row(int id, int userId, int permissionId, String key) =>
    UserPermissionDto(
      userPermissionId: id,
      userId: userId,
      permissionId: permissionId,
      permissionStatusId: 1,
      loginId: 'user$userId',
      userName: 'User $userId',
      employeeId: 29,
      employeeCode: 'EMP-29',
      permissionKey: key,
      permissionName: key,
      createdBy: 8,
      createdOn: DateTime.utc(2026, 10, 28),
    );

void main() {
  late _FakeAccessAdmin data;
  late RemoteAccessRepository repository;

  setUp(() {
    data = _FakeAccessAdmin()
      ..permissionRows = [
        _permission(18, 'hr.employees.view'),
        _permission(15, 'hr.employees.create'),
      ]
      ..rows = [
        _row(1, 44, 18, 'hr.employees.view'),
        _row(2, 44, 15, 'hr.employees.create'),
        _row(3, 45, 18, 'hr.employees.view'),
      ];
    repository = RemoteAccessRepository(data, erpAccessCatalog);
  });

  tearDown(() => repository.dispose());

  test('lists users derived from grant rows', () async {
    final users = await repository.watchUsers(companyId: '1').first;
    expect(users.map((u) => u.userId), containsAll(['44', '45']));
    expect(users.first.email, 'user44');
  });

  test('maps grants with the broadest supported scope', () async {
    final grants = await repository
        .watchGrants(companyId: '1', userId: '44')
        .first;
    expect(grants, hasLength(2));
    expect(
      grants
          .firstWhere((g) => g.permissionKey == 'hr.employees.view')
          .scope
          .name,
      'all',
    );
    expect(
      grants.every(
        (g) => g.companyId == '1' && g.userId == '44' && g.isActive,
      ),
      isTrue,
    );
  });

  test('replaces grants using server permission ids', () async {
    final result = await repository.replaceGrants(
      companyId: '1',
      actorUserId: '8',
      targetUserId: '44',
      requestId: 'request',
      grants: const [
        PermissionGrantInput(key: 'hr.employees.view', scope: PermissionScope.all),
      ],
    );
    expect(result, isA<Success>());
    expect(data.replacedIds, [18]);
  });

  test('rejects unknown permission keys without calling the server', () async {
    final result = await repository.replaceGrants(
      companyId: '1',
      actorUserId: '8',
      targetUserId: '44',
      requestId: 'request',
      grants: const [
        PermissionGrantInput(
          key: 'not.a.real.key',
          scope: PermissionScope.none,
        ),
      ],
    );
    expect(result, isA<Failed>());
    expect((result as Failed).failure.code, 'access.unknownPermission');
    expect(data.replacedIds, isNull);
  });

  test('history is an empty stream (no backend endpoint)', () async {
    final history = await repository
        .watchHistory(companyId: '1', userId: '44')
        .first;
    expect(history, isEmpty);
  });
}



