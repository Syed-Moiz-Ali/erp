import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/shifts/data/datasources/dio_shift_remote_data_source.dart';
import 'package:modular_erp/modules/hr/shifts/data/dto/shift_dtos.dart';

import 'support/api_test_harness.dart';
import 'support/memory_session_storage.dart';

Map<String, dynamic> _shiftJson(int id, String name) => {
  'shiftId': id,
  'shiftName': name,
  'startTime': '09:00:00',
  'endTime': '12:00:00',
  'earlyPunchInMinutes': 15,
  'lateGraceMinutes': 10,
  'statusId': 1,
  'activeAssignments': 2,
};

void main() {
  late FakeDioAdapter adapter;
  late DioShiftRemoteDataSource dataSource;

  setUp(() {
    adapter = FakeDioAdapter(
      (_) => jsonResponse(envelope(data: _shiftJson(1, 'Morning')), 200),
    );
    final client = ApiClient(
      baseUrl: 'https://api.example.com',
      storage: MemorySessionStorage(),
      dio: Dio()..httpClientAdapter = adapter,
    );
    dataSource = DioShiftRemoteDataSource(client);
  });

  test(
    'list uses GET with documented query params and decodes a page',
    () async {
      adapter.handler = (_) => jsonResponse(
        envelope(
          data: {
            'items': [_shiftJson(1, 'Morning'), _shiftJson(6, 'Night')],
            'page': 1,
            'pageSize': 25,
            'totalItems': 2,
            'totalPages': 1,
          },
        ),
        200,
      );
      final result = await dataSource.list(
        page: 1,
        pageSize: 25,
        search: 'mor',
        statusId: 1,
      );

      expect(adapter.last.method, 'GET');
      expect(adapter.last.uri.path, '/api/shifts');
      expect(adapter.last.uri.queryParameters['page'], '1');
      expect(adapter.last.uri.queryParameters['pageSize'], '25');
      expect(adapter.last.uri.queryParameters['search'], 'mor');
      expect(adapter.last.uri.queryParameters['statusId'], '1');
      expect(adapter.last.uri.queryParameters['sort'], 'startTime');
      expect(result, isA<Success<PagedResult<ShiftDto>>>());
      expect((result as Success).value.items.length, 2);
    },
  );

  test('list omits search and statusId when not supplied', () async {
    await dataSource.list(page: 1, pageSize: 10);
    expect(adapter.last.uri.queryParameters.containsKey('search'), isFalse);
    expect(adapter.last.uri.queryParameters.containsKey('statusId'), isFalse);
  });

  test('create POSTs the documented body to the collection path', () async {
    final result = await dataSource.create(
      const ShiftUpsertDto(
        shiftName: 'Evening',
        startTime: '14:00',
        endTime: '19:00',
        earlyPunchInMinutes: 15,
        lateGraceMinutes: 15,
      ),
    );
    expect(adapter.last.method, 'POST');
    expect(adapter.last.uri.path, '/api/shifts');
    expect(jsonDecode(adapter.lastBody!), {
      'shiftName': 'Evening',
      'startTime': '14:00',
      'endTime': '19:00',
      'earlyPunchInMinutes': 15,
      'lateGraceMinutes': 15,
    });
    expect(result, isA<Success<ShiftDto>>());
  });

  test('update PUTs to the id path', () async {
    await dataSource.update(
      6,
      const ShiftUpsertDto(
        shiftName: 'Night',
        startTime: '19:00',
        endTime: '02:00',
        earlyPunchInMinutes: 15,
        lateGraceMinutes: 15,
      ),
    );
    expect(adapter.last.method, 'PUT');
    expect(adapter.last.uri.path, '/api/shifts/6');
  });

  test('deactivate and activate POST to their sub-paths', () async {
    adapter.handler = (_) => jsonResponse(envelope(data: null), 200);
    await dataSource.deactivate(6);
    expect(adapter.last.uri.path, '/api/shifts/6/deactivate');
    await dataSource.activate(6);
    expect(adapter.last.uri.path, '/api/shifts/6/activate');
  });

  test('preserves the backend error code and field', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        success: false,
        errors: [errorEntry('SHIFT_DUPLICATE_NAME', field: 'shiftName')],
      ),
      409,
    );
    final result = await dataSource.create(
      const ShiftUpsertDto(
        shiftName: 'dup',
        startTime: '09:00',
        endTime: '12:00',
        earlyPunchInMinutes: 15,
        lateGraceMinutes: 15,
      ),
    );
    final failure = (result as Failed).failure;
    expect(failure.code, 'SHIFT_DUPLICATE_NAME');
    expect(failure.field, 'shiftName');
  });

  test('maps server failure and forwards cancellation', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(success: false, errors: [errorEntry('SERVICE_UNAVAILABLE')]),
      503,
    );
    expect(
      (await dataSource.list(page: 1, pageSize: 10) as Failed)
          .failure
          .retryable,
      isTrue,
    );

    final token = CancelToken()..cancel();
    final cancelled = await dataSource.getById(1, cancelToken: token);
    expect((cancelled as Failed).failure.kind, FailureKind.cancelled);
  });
}
