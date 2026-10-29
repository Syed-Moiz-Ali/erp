import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/access/data/datasources/remote/access_remotes.dart';
import 'package:modular_erp/platform/access/data/repositories/remote_permission_master_repository.dart';
import 'package:modular_erp/platform/access/domain/permission_master_repository.dart';

import 'support/api_test_harness.dart';
import 'support/memory_session_storage.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/permissions/$name').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> _detail() =>
    _fixture('permission_detail.json')['data'] as Map<String, dynamic>;

void main() {
  late FakeDioAdapter adapter;
  late ApiClient client;
  late PermissionMasterRepository repository;

  setUp(() {
    adapter = FakeDioAdapter(
      (_) => jsonResponse(_fixture('permissions_list.json'), 200),
    );
    client = buildClient(adapter: adapter, storage: MemorySessionStorage());
    repository = RemotePermissionMasterRepository(
      DioAccessAdminRemoteDataSource(client),
    );
  });

  tearDown(() => client.close());

  test(
    'list sends paging, search, statusId and sort to GET /api/permissions',
    () async {
      final result = await repository.list(
        search: 'hr.employees',
        statusId: 1,
        sort: 'nameAsc',
        page: 2,
        pageSize: 5,
      );

      expect(result, isA<Success<PermissionMasterPage>>());
      final page = (result as Success<PermissionMasterPage>).value;
      expect(page.items, hasLength(17));
      expect(page.page, 1);
      expect(page.pageSize, 25);
      expect(page.totalItems, 17);
      expect(page.totalPages, 1);

      expect(adapter.last.method, 'GET');
      expect(adapter.last.uri.path, '/api/permissions');
      expect(adapter.last.uri.queryParameters, {
        'page': '2',
        'pageSize': '5',
        'sort': 'nameAsc',
        'search': 'hr.employees',
        'statusId': '1',
      });
    },
  );

  test(
    'list omits empty search and only sends statusId when supplied',
    () async {
      await repository.list();
      expect(adapter.last.uri.queryParameters, {
        'page': '1',
        'pageSize': '100',
        'sort': 'keyAsc',
      });
    },
  );

  test('getById targets GET /api/permissions/{id}', () async {
    adapter.handler = (_) =>
        jsonResponse(_fixture('permission_detail.json'), 200);
    final result = await repository.getById(4);
    expect(result, isA<Success>());
    expect((result as Success).value.key, 'company.access.permissions.manage');
    expect(adapter.last.method, 'GET');
    expect(adapter.last.uri.path, '/api/permissions/4');
  });

  test('getById maps PERMISSION_NOT_FOUND to notFound', () async {
    adapter.handler = (_) =>
        jsonResponse(_fixture('permission_not_found.json'), 404);
    final result = await repository.getById(999999);
    expect(result, isA<Failed>());
    final failure = (result as Failed).failure;
    expect(failure.code, 'PERMISSION_NOT_FOUND');
    expect(failure.kind, FailureKind.notFound);
  });

  test(
    'create posts {permissionKey, permissionName} to /api/permissions',
    () async {
      adapter.handler = (_) => jsonResponse(
        envelope(data: _detail(), message: 'Permission created.'),
        201,
      );
      final result = await repository.create(
        key: 'company.access.permissions.manage',
        name: 'Manage permissions',
      );

      expect(result, isA<Success>());
      expect(adapter.last.method, 'POST');
      expect(adapter.last.uri.path, '/api/permissions');
      expect(jsonDecode(adapter.lastBody!), {
        'permissionKey': 'company.access.permissions.manage',
        'permissionName': 'Manage permissions',
      });
    },
  );

  test('update PUTs only the supplied field', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(data: {..._detail(), 'permissionName': 'Renamed'}),
      200,
    );
    await repository.update(4, name: 'Renamed');

    expect(adapter.last.method, 'PUT');
    expect(adapter.last.uri.path, '/api/permissions/4');
    expect(jsonDecode(adapter.lastBody!), {'permissionName': 'Renamed'});
  });

  test('activate and deactivate select the documented endpoints', () async {
    adapter.handler = (_) => jsonResponse(envelope(data: _detail()), 200);

    await repository.setActive(4, true);
    expect(adapter.last.method, 'POST');
    expect(adapter.last.uri.path, '/api/permissions/4/activate');

    await repository.setActive(4, false);
    expect(adapter.last.method, 'POST');
    expect(adapter.last.uri.path, '/api/permissions/4/deactivate');
  });

  test('PERMISSION_ALREADY_ACTIVE propagates as a conflict', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        success: false,
        message: 'Permission is already active.',
        errors: [errorEntry('PERMISSION_ALREADY_ACTIVE')],
      ),
      409,
    );
    final result = await repository.setActive(4, true);
    final failure = (result as Failed).failure;
    expect(failure.code, 'PERMISSION_ALREADY_ACTIVE');
    expect(failure.kind, FailureKind.conflict);
  });

  test('PERMISSION_ALREADY_INACTIVE propagates as a conflict', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        success: false,
        message: 'Permission is already inactive.',
        errors: [errorEntry('PERMISSION_ALREADY_INACTIVE')],
      ),
      409,
    );
    final result = await repository.setActive(4, false);
    final failure = (result as Failed).failure;
    expect(failure.code, 'PERMISSION_ALREADY_INACTIVE');
    expect(failure.kind, FailureKind.conflict);
  });

  test('PERMISSION_DUPLICATE_KEY becomes a field-aware conflict', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        success: false,
        message: 'Permission key exists.',
        errors: [errorEntry('PERMISSION_DUPLICATE_KEY')],
      ),
      409,
    );
    final result = await repository.create(
      key: 'company.access.permissions.manage',
      name: 'Manage permissions',
    );
    final failure = (result as Failed).failure;
    expect(failure.code, 'PERMISSION_DUPLICATE_KEY');
    expect(failure.kind, FailureKind.conflict);
    expect(failure.field, 'permissionKey');
  });

  test('server VALIDATION_ERROR keeps its field and message', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        success: false,
        message: 'Invalid permission key.',
        errors: [
          errorEntry(
            'VALIDATION_ERROR',
            message: 'Invalid permission key.',
            field: 'permissionKey',
          ),
        ],
      ),
      400,
    );
    final result = await repository.create(key: 'hr.employees.view', name: 'X');
    final failure = (result as Failed).failure;
    expect(failure.code, 'VALIDATION_ERROR');
    expect(failure.kind, FailureKind.validation);
    expect(failure.field, 'permissionKey');
    expect(failure.serverMessage, 'Invalid permission key.');
  });

  test('invalid client keys never reach the transport', () async {
    for (final key in ['', '   ', 'single', 'bad key', 'a' * 101]) {
      final result = await repository.create(key: key, name: 'Name');
      expect(result, isA<Failed>());
      expect((result as Failed).failure.field, 'permissionKey');
    }
    expect(adapter.callCount, 0);
  });
}
