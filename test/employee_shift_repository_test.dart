import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/employee_shifts/data/repositories/remote_employee_shift_repository.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift.dart';

import 'support/employee_shift_test_doubles.dart';

const _draft = EmployeeShiftDraft(
  employeeId: 2,
  shiftId: 1,
  fromDate: '2026-09-01',
  toDate: '2026-10-31',
  timeZoneId: 'Asia/Dubai',
);

void main() {
  late FakeEmployeeShiftRemoteDataSource dataSource;
  late RemoteEmployeeShiftRepository repository;

  setUp(() {
    dataSource = FakeEmployeeShiftRemoteDataSource();
    repository = RemoteEmployeeShiftRepository(dataSource);
  });

  group('list', () {
    test('forwards filters, paging and keeps the returned paging', () async {
      dataSource.onList = (_, _, _, _, _, _, _) async => Success(
        employeeShiftPage(
          [employeeShiftDto(), employeeShiftDto(employeeShiftId: 2)],
          page: 2,
          pageSize: 5,
          totalItems: 12,
          totalPages: 3,
        ),
      );

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
      expect(page.items, hasLength(2));
      expect(page.items.first.employeeShiftId, 1);
      expect(page.page, 2);
      expect(page.pageSize, 5);
      expect(page.totalItems, 12);
      expect(page.totalPages, 3);
      expect(page.hasMore, isTrue);

      expect(dataSource.lastEmployeeId, 2);
      expect(dataSource.lastShiftId, 1);
      expect(dataSource.lastFromDate, '2026-09-01');
      expect(dataSource.lastToDate, '2026-10-31');
      expect(dataSource.lastIncludeInactive, isTrue);
      expect(dataSource.lastPage, 2);
      expect(dataSource.lastPageSize, 5);
    });

    test('maps a list failure', () async {
      dataSource.onList = (_, _, _, _, _, _, _) async =>
          const Failed(Failure(code: 'offline', kind: FailureKind.offline));
      final result = await repository.list();
      expect((result as Failed).failure.kind, FailureKind.offline);
    });
  });

  group('getById', () {
    test('maps a successful detail', () async {
      dataSource.onGet = (id) async =>
          Success(employeeShiftDto(employeeShiftId: id, shiftName: 'Night'));
      final result = await repository.getById(7);
      expect(result, isA<Success<EmployeeShift>>());
      expect((result as Success<EmployeeShift>).value.shiftName, 'Night');
      expect(dataSource.lastGetId, 7);
    });

    test('maps EMPLOYEE_SHIFT_NOT_FOUND to notFound', () async {
      dataSource.onGet = (_) async => const Failed(
        Failure(
          code: 'EMPLOYEE_SHIFT_NOT_FOUND',
          kind: FailureKind.unknown,
          serverMessage: 'Shift assignment not found.',
        ),
      );
      final result = await repository.getById(999999);
      final failure = (result as Failed).failure;
      expect(failure.code, 'EMPLOYEE_SHIFT_NOT_FOUND');
      expect(failure.kind, FailureKind.notFound);
      expect(failure.serverMessage, 'Shift assignment not found.');
    });
  });

  group('create', () {
    test('sends only the documented create fields', () async {
      final result = await repository.create(_draft);
      expect(result, isA<Success<EmployeeShift>>());
      expect(dataSource.createCalls, 1);
      expect(dataSource.lastCreate!.toJson(), {
        'employeeId': 2,
        'shiftId': 1,
        'fromDate': '2026-09-01',
        'toDate': '2026-10-31',
        'timeZoneId': 'Asia/Dubai',
      });
    });

    test('omits a null and a blank timeZoneId', () async {
      await repository.create(
        const EmployeeShiftDraft(
          employeeId: 2,
          shiftId: 1,
          fromDate: '2026-09-01',
          toDate: '2026-10-31',
        ),
      );
      expect(
        dataSource.lastCreate!.toJson().containsKey('timeZoneId'),
        isFalse,
      );

      await repository.create(
        const EmployeeShiftDraft(
          employeeId: 2,
          shiftId: 1,
          fromDate: '2026-09-01',
          toDate: '2026-10-31',
          timeZoneId: '   ',
        ),
      );
      expect(
        dataSource.lastCreate!.toJson().containsKey('timeZoneId'),
        isFalse,
      );
    });
  });

  group('update', () {
    test('never sends employeeId and omits an empty timeZoneId', () async {
      await repository.update(
        5,
        const EmployeeShiftDraft(
          employeeId: 2,
          shiftId: 3,
          fromDate: '2026-11-01',
          toDate: '2026-11-30',
          timeZoneId: '',
        ),
      );
      expect(dataSource.lastUpdateId, 5);
      expect(dataSource.lastUpdate!.toJson(), {
        'shiftId': 3,
        'fromDate': '2026-11-01',
        'toDate': '2026-11-30',
      });
    });

    test('sends a supplied timeZoneId', () async {
      await repository.update(
        5,
        const EmployeeShiftDraft(
          shiftId: 3,
          fromDate: '2026-11-01',
          toDate: '2026-11-30',
          timeZoneId: 'Asia/Kolkata',
        ),
      );
      expect(dataSource.lastUpdate!.toJson()['timeZoneId'], 'Asia/Kolkata');
    });
  });

  group('deactivate', () {
    test('posts the id and does not invent success', () async {
      final result = await repository.deactivate(8);
      expect(result, isA<Success<void>>());
      expect(dataSource.deactivateCalls, 1);
      expect(dataSource.lastDeactivateId, 8);
    });

    test('maps EMPLOYEE_SHIFT_ALREADY_REMOVED to conflict', () async {
      dataSource.onDeactivate = (_) async => const Failed(
        Failure(
          code: 'EMPLOYEE_SHIFT_ALREADY_REMOVED',
          kind: FailureKind.unknown,
          serverMessage: 'Shift assignment has already been removed.',
        ),
      );
      final result = await repository.deactivate(8);
      final failure = (result as Failed).failure;
      expect(failure.code, 'EMPLOYEE_SHIFT_ALREADY_REMOVED');
      expect(failure.kind, FailureKind.conflict);
      expect(
        failure.serverMessage,
        'Shift assignment has already been removed.',
      );
    });
  });

  group('documented error mapping', () {
    final cases = <String, FailureKind>{
      'EMPLOYEE_SHIFT_OVERLAP': FailureKind.conflict,
      'EMPLOYEE_SHIFT_LIMIT': FailureKind.conflict,
      'EMPLOYEE_SHIFT_TIMEZONE_MISMATCH': FailureKind.validation,
      'EMPLOYEE_SHIFT_BRANCH_TIMEZONE_MISSING': FailureKind.validation,
      'EMPLOYEE_SHIFT_HAS_PUNCHES': FailureKind.conflict,
      'EMPLOYEE_SHIFT_ALREADY_REMOVED': FailureKind.conflict,
    };

    for (final entry in cases.entries) {
      test('${entry.key} -> ${entry.value.name}', () async {
        dataSource.onUpdate = (_, _) async => Failed(
          Failure(
            code: entry.key,
            kind: FailureKind.unknown,
            serverMessage: 'Safe server message.',
          ),
        );
        final result = await repository.update(5, _draft);
        final failure = (result as Failed).failure;
        expect(failure.code, entry.key);
        expect(failure.kind, entry.value);
        expect(failure.serverMessage, 'Safe server message.');
      });
    }

    test('EMPLOYEE_SHIFT_NOT_FOUND -> notFound', () async {
      dataSource.onGet = (_) async => const Failed(
        Failure(code: 'EMPLOYEE_SHIFT_NOT_FOUND', kind: FailureKind.unknown),
      );
      final result = await repository.getById(5);
      expect((result as Failed).failure.kind, FailureKind.notFound);
    });
  });

  group('client validation', () {
    test('create rejects a missing employeeId without a request', () async {
      final result = await repository.create(_draft.copyWithEmployee(null));
      final failure = (result as Failed).failure;
      expect(failure.kind, FailureKind.validation);
      expect(failure.field, 'employeeId');
      expect(dataSource.createCalls, 0);
    });

    test('create rejects a missing shiftId without a request', () async {
      const draft = EmployeeShiftDraft(
        employeeId: 2,
        fromDate: '2026-09-01',
        toDate: '2026-10-31',
      );
      final result = await repository.create(draft);
      final failure = (result as Failed).failure;
      expect(failure.kind, FailureKind.validation);
      expect(failure.field, 'shiftId');
      expect(dataSource.createCalls, 0);
    });

    test('create and update reject fromDate after toDate', () async {
      const draft = EmployeeShiftDraft(
        employeeId: 2,
        shiftId: 1,
        fromDate: '2026-10-31',
        toDate: '2026-09-01',
      );
      final created = await repository.create(draft);
      final createFailure = (created as Failed).failure;
      expect(createFailure.kind, FailureKind.validation);
      expect(createFailure.code, 'invalidDateRange');
      expect(createFailure.field, 'toDate');

      final updated = await repository.update(5, draft);
      final updateFailure = (updated as Failed).failure;
      expect(updateFailure.kind, FailureKind.validation);
      expect(updateFailure.code, 'invalidDateRange');
      expect(dataSource.createCalls, 0);
      expect(dataSource.updateCalls, 0);
    });

    test('update rejects missing dates without a request', () async {
      const draft = EmployeeShiftDraft(shiftId: 1);
      final result = await repository.update(5, draft);
      final failure = (result as Failed).failure;
      expect(failure.kind, FailureKind.validation);
      expect(failure.field, 'fromDate');
      expect(dataSource.updateCalls, 0);
    });
  });
}

extension on EmployeeShiftDraft {
  EmployeeShiftDraft copyWithEmployee(int? employeeId) => EmployeeShiftDraft(
    employeeId: employeeId,
    shiftId: shiftId,
    fromDate: fromDate,
    toDate: toDate,
    timeZoneId: timeZoneId,
  );
}
