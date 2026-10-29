import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/access/data/datasources/remote/access_remotes.dart';
import 'package:modular_erp/platform/access/data/dto/permission_dtos.dart';

import 'support/api_test_harness.dart';
import 'support/memory_session_storage.dart';

Map<String, dynamic> _rowJson({int id = 145, int userId = 8}) => {
  'userPermissionId': id,
  'userId': userId,
  'loginId': 'user@example.test',
  'userName': 'User',
  'employeeId': 1,
  'employeeCode': 'EMP-1',
  'employeeName': 'Employee',
  'permissionId': 18,
  'permissionKey': 'hr.employees.view',
  'permissionName': 'View employees',
  'permissionStatusId': 1,
  'createdBy': 8,
  'createdOn': '2026-10-28T11:16:48Z',
};

void main() {
  late FakeDioAdapter adapter;
  late ApiClient client;
  late DioAccessAdminRemoteDataSource dataSource;

  setUp(() {
    adapter = FakeDioAdapter(
      (_) => jsonResponse(envelope(data: [_rowJson()]), 200),
    );
    client = buildClient(adapter: adapter, storage: MemorySessionStorage());
    dataSource = DioAccessAdminRemoteDataSource(client);
  });

  tearDown(() => client.close());

  test('replace sends only {permissionIds} to the per-user endpoint', () async {
    final result = await dataSource.replaceUserPermissions(8, [18]);

    expect(result, isA<Success<List<UserPermissionDto>>>());
    expect(adapter.last.method, 'PUT');
    expect(adapter.last.path, '/api/user-permissions/users/8');
    expect(jsonDecode(adapter.lastBody!), {
      'permissionIds': [18],
    });
  });

  test(
    'assign posts {userId, permissionIds} to the collection endpoint',
    () async {
      final result = await dataSource.assignUserPermissions(8, [18]);

      expect(result, isA<Success<List<UserPermissionDto>>>());
      expect(adapter.last.method, 'POST');
      expect(adapter.last.path, '/api/user-permissions');
      expect(jsonDecode(adapter.lastBody!), {
        'userId': 8,
        'permissionIds': [18],
      });
    },
  );

  test('revoke deletes by userPermissionId', () async {
    adapter.handler = (_) => jsonResponse(envelope(data: _rowJson()), 200);
    final result = await dataSource.removeUserPermission(145);

    expect(result, isA<Success<UserPermissionDto>>());
    expect(adapter.last.method, 'DELETE');
    expect(adapter.last.path, '/api/user-permissions/145');
  });

  test('user permission queries forward filters and paging', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        data: {
          'items': [_rowJson()],
          'page': 2,
          'pageSize': 50,
          'totalItems': 51,
          'totalPages': 2,
        },
      ),
      200,
    );

    final result = await dataSource.userPermissions(
      userId: 8,
      employeeId: 1,
      permissionId: 18,
      page: 2,
      pageSize: 50,
    );

    expect(result, isA<Success<PagedResult<UserPermissionDto>>>());
    expect(adapter.last.path, '/api/user-permissions');
    expect(adapter.last.uri.queryParameters, {
      'page': '2',
      'pageSize': '50',
      'userId': '8',
      'employeeId': '1',
      'permissionId': '18',
    });
  });

  test('a forbidden list response maps to forbidden', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        success: false,
        message: 'Forbidden',
        errors: [errorEntry('ACCESS_DENIED', message: 'Forbidden')],
      ),
      403,
    );

    final result = await dataSource.userPermissions();

    expect(result, isA<Failed<PagedResult<UserPermissionDto>>>());
    expect(
      (result as Failed<PagedResult<UserPermissionDto>>).failure.kind,
      FailureKind.forbidden,
    );
  });
}
