import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/employee_shifts/data/datasources/dio_employee_shift_remote_data_source.dart';
import 'package:modular_erp/modules/hr/employee_shifts/data/repositories/remote_employee_shift_repository.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift.dart';

import 'support/api_test_harness.dart';
import 'support/memory_session_storage.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/employee_shifts/$name').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> _detail() =>
    _fixture('employee_shift_detail.json')['data'] as Map<String, dynamic>;

void main() {
  late FakeDioAdapter adapter;
  late ApiClient client;
  late RemoteEmployeeShiftRepository repository;

  setUp(() {
    adapter = FakeDioAdapter(
      (_) => jsonResponse(_fixture('employee_shifts_list.json'), 200),
    );
    client = buildClient(adapter: adapter, storage: MemorySessionStorage());
    repository = RemoteEmployeeShiftRepository(
      DioEmployeeShiftRemoteDataSource(client),
    );
  });

  tearDown(() => client.close());

  test(
    'list sends every filter and paging to GET /api/employee-shifts',
    () async {
      final result = await repository.list(
        employeeId: 2,
        shiftId: 1,
        fromDate: '2026-09-01',
        toDate: '2026-10-31',
        includeInactive: true,
        page: 2,
        pageSize: 5,
      );

      expect(result, isA<Success<EmployeeShiftPage>>());
      final page = (result as Success<EmployeeShiftPage>).value;
      expect(page.items, hasLength(25));
      expect(page.page, 1);
      expect(page.pageSize, 25);
      expect(page.totalItems, 25);
      expect(page.totalPages, 1);

      expect(adapter.last.method, 'GET');
      expect(adapter.last.uri.path, '/api/employee-shifts');
      expect(adapter.last.uri.queryParameters, {
        'page': '2',
        'pageSize': '5',
        'employeeId': '2',
        'shiftId': '1',
        'fromDate': '2026-09-01',
        'toDate': '2026-10-31',
        'includeInactive': 'true',
      });
    },
  );

  test('list omits empty filters and sends only paging', () async {
    await repository.list();
    expect(adapter.last.uri.queryParameters, {'page': '1', 'pageSize': '25'});
  });

  test('getById targets GET /api/employee-shifts/{id}', () async {
    adapter.handler = (_) =>
        jsonResponse(_fixture('employee_shift_detail.json'), 200);
    final result = await repository.getById(1);
    expect(result, isA<Success<EmployeeShift>>());
    expect((result as Success<EmployeeShift>).value.employeeShiftId, 1);
    expect(adapter.last.method, 'GET');
    expect(adapter.last.uri.path, '/api/employee-shifts/1');
  });

  test('getById maps EMPLOYEE_SHIFT_NOT_FOUND to notFound', () async {
    adapter.handler = (_) =>
        jsonResponse(_fixture('employee_shift_not_found.json'), 404);
    final result = await repository.getById(999999);
    final failure = (result as Failed).failure;
    expect(failure.code, 'EMPLOYEE_SHIFT_NOT_FOUND');
    expect(failure.kind, FailureKind.notFound);
    expect(failure.serverMessage, 'Shift assignment not found.');
  });

  test('create posts the documented body to /api/employee-shifts', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(data: _detail(), message: 'Shift assignment created.'),
      201,
    );
    final result = await repository.create(
      const EmployeeShiftDraft(
        employeeId: 2,
        shiftId: 1,
        fromDate: '2026-09-01',
        toDate: '2026-10-31',
        timeZoneId: 'Asia/Dubai',
      ),
    );

    expect(result, isA<Success<EmployeeShift>>());
    expect(adapter.last.method, 'POST');
    expect(adapter.last.uri.path, '/api/employee-shifts');
    expect(jsonDecode(adapter.lastBody!), {
      'employeeId': 2,
      'shiftId': 1,
      'fromDate': '2026-09-01',
      'toDate': '2026-10-31',
      'timeZoneId': 'Asia/Dubai',
    });
  });

  test('update PUTs without employeeId and omits a blank timeZoneId', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(data: _detail(), message: 'Shift assignment updated.'),
      200,
    );
    await repository.update(
      1,
      const EmployeeShiftDraft(
        employeeId: 2,
        shiftId: 1,
        fromDate: '2026-09-01',
        toDate: '2026-10-31',
        timeZoneId: '  ',
      ),
    );

    expect(adapter.last.method, 'PUT');
    expect(adapter.last.uri.path, '/api/employee-shifts/1');
    expect(jsonDecode(adapter.lastBody!), {
      'shiftId': 1,
      'fromDate': '2026-09-01',
      'toDate': '2026-10-31',
    });
  });

  test('deactivate POSTs the documented endpoint with no body', () async {
    adapter.handler = (_) =>
        jsonResponse(envelope(data: null, message: 'Removed.'), 200);
    final result = await repository.deactivate(1);
    expect(result, isA<Success<void>>());
    expect(adapter.last.method, 'POST');
    expect(adapter.last.uri.path, '/api/employee-shifts/1/deactivate');
    expect(adapter.lastBody, isNull);
  });

  test('time zone error keeps the code, message and validation kind', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        success: false,
        message: 'Shift time zone does not match the branch.',
        errors: [
          errorEntry(
            'EMPLOYEE_SHIFT_TIMEZONE_MISMATCH',
            message: 'Shift time zone does not match the branch.',
          ),
        ],
      ),
      409,
    );
    final result = await repository.create(
      const EmployeeShiftDraft(
        employeeId: 2,
        shiftId: 1,
        fromDate: '2026-09-01',
        toDate: '2026-10-31',
        timeZoneId: 'Asia/Kolkata',
      ),
    );
    final failure = (result as Failed).failure;
    expect(failure.code, 'EMPLOYEE_SHIFT_TIMEZONE_MISMATCH');
    expect(failure.kind, FailureKind.validation);
    expect(failure.serverMessage, 'Shift time zone does not match the branch.');
  });

  test('invalid client drafts never reach the transport', () async {
    final result = await repository.create(
      const EmployeeShiftDraft(
        shiftId: 1,
        fromDate: '2026-09-01',
        toDate: '2026-10-31',
      ),
    );
    expect(result, isA<Failed<EmployeeShift>>());
    expect(adapter.callCount, 0);
  });
}
