import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/access/data/datasources/remote/access_remotes.dart';
import 'package:modular_erp/platform/access/data/dto/permission_dtos.dart';
import 'package:modular_erp/platform/access/data/repositories/remote_permission_master_repository.dart';

class _FakeAccessAdmin implements AccessAdminRemoteDataSource {
  Result<PagedResult<PermissionDto>> listResult = const Success(
    PagedResult(
      items: [],
      page: 1,
      pageSize: 100,
      totalItems: 0,
      totalPages: 0,
    ),
  );
  Result<PermissionDto> writeResult = const Failed(
    Failure(code: 'unused', kind: FailureKind.unknown),
  );
  Map<String, dynamic>? lastBody;
  int? lastActiveId;
  bool? lastActive;

  @override
  Future<Result<PagedResult<PermissionDto>>> permissions({
    int page = 1,
    int pageSize = 100,
    String search = '',
    int? statusId,
    CancelToken? cancelToken,
  }) async => listResult;

  @override
  Future<Result<PermissionDto>> permissionById(
    int permissionId, {
    CancelToken? cancelToken,
  }) async => writeResult;

  @override
  Future<Result<PermissionDto>> createPermission(
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) async {
    lastBody = body;
    return writeResult;
  }

  @override
  Future<Result<PermissionDto>> updatePermission(
    int permissionId,
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) async {
    lastBody = body;
    return writeResult;
  }

  @override
  Future<Result<PermissionDto>> setPermissionActive(
    int permissionId, {
    required bool active,
    CancelToken? cancelToken,
  }) async {
    lastActiveId = permissionId;
    lastActive = active;
    return writeResult;
  }

  @override
  Future<Result<PagedResult<UserPermissionDto>>> userPermissions({
    int? userId,
    int? employeeId,
    int? permissionId,
    int page = 1,
    int pageSize = 100,
    CancelToken? cancelToken,
  }) async => const Success(
    PagedResult(
      items: [],
      page: 1,
      pageSize: 100,
      totalItems: 0,
      totalPages: 0,
    ),
  );

  @override
  Future<Result<List<UserPermissionDto>>> assignUserPermissions(
    int userId,
    List<int> permissionIds, {
    CancelToken? cancelToken,
  }) async => const Success([]);

  @override
  Future<Result<List<UserPermissionDto>>> replaceUserPermissions(
    int userId,
    List<int> permissionIds, {
    CancelToken? cancelToken,
  }) async => const Success([]);

  @override
  Future<Result<UserPermissionDto>> removeUserPermission(
    int userPermissionId, {
    CancelToken? cancelToken,
  }) async => const Failed(
    Failure(code: 'USER_PERMISSION_NOT_FOUND', kind: FailureKind.notFound),
  );
}

PermissionDto _dto({
  int id = 18,
  String key = 'hr.employees.view',
  String name = 'View employees',
  int statusId = 1,
}) => PermissionDto(
  permissionId: id,
  permissionKey: key,
  permissionName: name,
  statusId: statusId,
  status: statusId == 1 ? 'Active' : 'InActive',
);

void main() {
  late _FakeAccessAdmin data;
  late RemotePermissionMasterRepository repository;

  setUp(() {
    data = _FakeAccessAdmin();
    repository = RemotePermissionMasterRepository(data);
  });

  test('lists and maps permission masters', () async {
    data.listResult = Success(
      PagedResult(
        items: [_dto()],
        page: 1,
        pageSize: 100,
        totalItems: 1,
        totalPages: 1,
      ),
    );
    final result = await repository.list();
    expect(result, isA<Success>());
    final page = (result as Success).value;
    expect(page.items.single.key, 'hr.employees.view');
    expect(page.items.single.isActive, isTrue);
  });

  test('loads the latest permission before editing', () async {
    data.writeResult = Success(_dto(name: 'Latest name'));
    final result = await repository.getById(18);
    expect(result, isA<Success>());
    expect((result as Success).value.name, 'Latest name');
  });

  test('reports a missing permission from getById', () async {
    data.writeResult = const Failed(
      Failure(code: 'PERMISSION_NOT_FOUND', kind: FailureKind.notFound),
    );
    final result = await repository.getById(999999);
    expect(result, isA<Failed>());
    expect((result as Failed).failure.kind, FailureKind.notFound);
  });

  test('creates with key, name and description', () async {
    data.writeResult = Success(_dto());
    final result = await repository.create(
      key: 'hr.employees.view',
      name: 'View employees',
      description: 'See employees.',
    );
    expect(result, isA<Success>());
    expect(data.lastBody, {
      'permissionKey': 'hr.employees.view',
      'permissionName': 'View employees',
      'description': 'See employees.',
    });
  });

  test('update sends only supplied fields', () async {
    data.writeResult = Success(_dto(name: 'Renamed'));
    await repository.update(18, name: 'Renamed');
    expect(data.lastBody, {'permissionName': 'Renamed'});
  });

  test('activate/deactivate target the right endpoint state', () async {
    data.writeResult = Success(_dto(statusId: 2));
    await repository.setActive(18, false);
    expect(data.lastActiveId, 18);
    expect(data.lastActive, isFalse);
  });

  test('maps 409 duplicate key failure', () async {
    data.writeResult = const Failed(
      Failure(
        code: 'PERMISSION_DUPLICATE_KEY',
        kind: FailureKind.conflict,
        field: 'permissionKey',
      ),
    );
    final result = await repository.create(key: 'x.y', name: 'X');
    expect(result, isA<Failed>());
    final failure = (result as Failed).failure;
    expect(failure.code, 'PERMISSION_DUPLICATE_KEY');
    expect(failure.field, 'permissionKey');
  });
}
