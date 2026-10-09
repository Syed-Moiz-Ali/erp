import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/departments/data/datasources/dio_department_remote_data_source.dart';
import 'package:modular_erp/modules/hr/departments/data/dto/department_dtos.dart';

import 'support/api_test_harness.dart';
import 'support/memory_session_storage.dart';

void main() {
  late FakeDioAdapter adapter;
  late DioDepartmentRemoteDataSource dataSource;

  setUp(() {
    adapter = FakeDioAdapter(
      (_) => jsonResponse(envelope(data: {'departmentId': 1}), 200),
    );
    final client = ApiClient(
      baseUrl: 'https://api.example.com',
      storage: MemorySessionStorage(),
      dio: Dio()..httpClientAdapter = adapter,
    );
    dataSource = DioDepartmentRemoteDataSource(client);
  });

  test(
    'list uses GET, documented query params and decodes a paged result',
    () async {
      adapter.handler = (_) => jsonResponse(
        envelope(
          data: {
            'items': [
              {
                'departmentId': 2,
                'departmentName': 'accounts',
                'employeeCount': 1,
              },
            ],
            'page': 1,
            'pageSize': 25,
            'totalItems': 1,
            'totalPages': 1,
          },
        ),
        200,
      );
      final result = await dataSource.list(
        page: 1,
        pageSize: 25,
        search: 'acc',
      );

      expect(adapter.last.method, 'GET');
      expect(adapter.last.uri.path, '/api/departments');
      expect(adapter.last.uri.queryParameters['page'], '1');
      expect(adapter.last.uri.queryParameters['pageSize'], '25');
      expect(adapter.last.uri.queryParameters['search'], 'acc');
      expect(adapter.last.uri.queryParameters['sort'], 'nameAsc');
      expect(result, isA<Success<PagedResult<DepartmentDto>>>());
      expect((result as Success).value.items.single.departmentName, 'accounts');
    },
  );

  test('list omits search when blank', () async {
    await dataSource.list(page: 1, pageSize: 25);
    expect(adapter.last.uri.queryParameters.containsKey('search'), isFalse);
  });

  test('create POSTs departmentName to the collection path', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        data: {
          'departmentId': 9,
          'departmentName': 'Finance',
          'employeeCount': 0,
        },
      ),
      201,
    );
    final result = await dataSource.create(
      const DepartmentUpsertDto(departmentName: 'Finance'),
    );
    expect(adapter.last.method, 'POST');
    expect(adapter.last.uri.path, '/api/departments');
    expect(jsonDecode(adapter.lastBody!), {'departmentName': 'Finance'});
    expect((result as Success).value.departmentId, 9);
  });

  test('rename PUTs to the id path', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        data: {
          'departmentId': 4,
          'departmentName': 'Renamed',
          'employeeCount': 0,
        },
      ),
      200,
    );
    await dataSource.rename(
      4,
      const DepartmentUpsertDto(departmentName: 'Renamed'),
    );
    expect(adapter.last.method, 'PUT');
    expect(adapter.last.uri.path, '/api/departments/4');
  });

  test('getById GETs the id path', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        data: {'departmentId': 6, 'departmentName': 'Ops', 'employeeCount': 2},
      ),
      200,
    );
    final result = await dataSource.getById(6);
    expect(adapter.last.uri.path, '/api/departments/6');
    expect((result as Success).value.employeeCount, 2);
  });

  test('deactivate POSTs to the deactivate path', () async {
    adapter.handler = (_) => jsonResponse(envelope(data: null), 200);
    final result = await dataSource.deactivate(6);
    expect(adapter.last.method, 'POST');
    expect(adapter.last.uri.path, '/api/departments/6/deactivate');
    expect(result, isA<Success<void>>());
  });

  test('preserves the backend error code and field', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        success: false,
        errors: [
          errorEntry('DEPARTMENT_DUPLICATE_NAME', field: 'departmentName'),
        ],
      ),
      409,
    );
    final result = await dataSource.create(
      const DepartmentUpsertDto(departmentName: 'dup'),
    );
    final failure = (result as Failed).failure;
    expect(failure.code, 'DEPARTMENT_DUPLICATE_NAME');
    expect(failure.field, 'departmentName');
    expect(failure.kind, FailureKind.conflict);
  });

  test('maps forbidden, not found, server and offline failures', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(success: false, errors: [errorEntry('ACCESS_DENIED')]),
      403,
    );
    expect(
      (await dataSource.list(page: 1, pageSize: 25) as Failed).failure.kind,
      FailureKind.forbidden,
    );

    adapter.handler = (_) => jsonResponse(
      envelope(success: false, errors: [errorEntry('DEPARTMENT_NOT_FOUND')]),
      404,
    );
    expect(
      (await dataSource.getById(1) as Failed).failure.kind,
      FailureKind.notFound,
    );

    adapter.handler = (_) => jsonResponse(
      envelope(success: false, errors: [errorEntry('SERVER_ERROR')]),
      500,
    );
    expect((await dataSource.getById(1) as Failed).failure.retryable, isTrue);

    adapter.handler = (_) => throw DioException(
      requestOptions: RequestOptions(path: '/api/departments'),
      type: DioExceptionType.connectionError,
    );
    expect(
      (await dataSource.list(page: 1, pageSize: 25) as Failed).failure.kind,
      FailureKind.offline,
    );
  });

  test('forwards cancellation', () async {
    final token = CancelToken()..cancel();
    final result = await dataSource.getById(1, cancelToken: token);
    expect((result as Failed).failure.kind, FailureKind.cancelled);
  });
}
