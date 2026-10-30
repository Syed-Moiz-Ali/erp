import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift.dart';
import 'package:modular_erp/modules/hr/employee_shifts/presentation/bloc/employee_shift_list_bloc.dart';
import 'package:modular_erp/modules/hr/employee_shifts/presentation/employee_shift_configuration_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

import 'support/department_test_doubles.dart';
import 'support/employee_shift_test_doubles.dart';

EmployeeShift employeeShift({
  int id = 1,
  int employeeId = 2,
  String employeeCode = 'EMP-2',
  String employeeName = 'Sanitized Employee',
  int shiftId = 3,
  String shiftName = 'Morning',
  String fromDate = '2026-09-01',
  String toDate = '2026-10-31',
  int statusId = 1,
  String status = 'Active',
}) => EmployeeShift(
  employeeShiftId: id,
  employeeId: employeeId,
  employeeCode: employeeCode,
  employeeName: employeeName,
  shiftId: shiftId,
  shiftName: shiftName,
  fromDate: fromDate,
  toDate: toDate,
  startTime: '09:00:00',
  endTime: '17:00:00',
  earlyPunchInMinutes: 20,
  lateGraceMinutes: 10,
  statusId: statusId,
  status: status,
  timeZoneId: 'Asia/Dubai',
  punchInOpensAt: '08:40:00',
);

AuthContext context() => departmentAuthContext(
  permissions: const <AppPermission>{
    AppPermission.shiftView,
    AppPermission.shiftManage,
  },
);

void main() {
  test('list maps paging and status to includeInactive', () async {
    final repository = InMemoryEmployeeShiftRepository(
      shifts: [
        employeeShift(id: 1),
        employeeShift(id: 2, statusId: 2, status: 'InActive'),
      ],
    );
    final adapter = EmployeeShiftConfigurationRepository(repository);
    addTearDown(adapter.dispose);

    final active = await adapter
        .watchList(
          context(),
          query: 'ignored',
          status: ConfigurationStatus.active,
          pageSize: 25,
        )
        .first;

    final page =
        (active as Success<ConfigurationPageData<EmployeeShiftRecord>>).value;
    expect(page.items, hasLength(1));
    expect(page.items.single.assignedEmployees, 0);
    expect(page.items.single.record.id, '1');
    expect(
      page.items.single.record.name,
      'Sanitized Employee (EMP-2) – Morning',
    );
    expect(page.items.single.record.status, ConfigurationStatus.active);
    expect(repository.lastIncludeInactive, isFalse);
    expect(repository.lastPage, 1);
    expect(repository.lastPageSize, 25);

    await adapter
        .watchList(context(), status: ConfigurationStatus.inactive)
        .first;
    expect(repository.lastIncludeInactive, isTrue);

    await adapter.watchList(context()).first;
    expect(repository.lastIncludeInactive, isTrue);
  });

  test('detail returns null when the assignment is not found', () async {
    final adapter = EmployeeShiftConfigurationRepository(
      InMemoryEmployeeShiftRepository(),
    );
    addTearDown(adapter.dispose);

    final result = await adapter.watchDetails(context(), '999').first;
    expect(result, isA<Success<ConfigurationItem<EmployeeShiftRecord>?>>());
    expect(
      (result as Success<ConfigurationItem<EmployeeShiftRecord>?>).value,
      isNull,
    );
  });

  test('create validates and forwards the draft', () async {
    final repository = InMemoryEmployeeShiftRepository();
    final adapter = EmployeeShiftConfigurationRepository(repository);
    addTearDown(adapter.dispose);

    final invalid = await adapter.save(
      context(),
      const EmployeeShiftDraft(fromDate: '2026-09-01', toDate: '2026-10-31'),
    );
    expect((invalid as Failed<EmployeeShiftRecord>).failure.code, 'required');
    expect(repository.createCalls, 0);

    final result = await adapter.save(
      context(),
      const EmployeeShiftDraft(
        employeeId: 2,
        shiftId: 3,
        fromDate: ' 2026-09-01 ',
        toDate: '2026-10-31',
        timeZoneId: ' Asia/Dubai ',
      ),
    );
    expect(result, isA<Success<EmployeeShiftRecord>>());
    expect(repository.createCalls, 1);
    expect(repository.lastCreate!.employeeId, 2);
    expect(repository.lastCreate!.shiftId, 3);
    expect(repository.lastCreate!.fromDate, '2026-09-01');
    expect(repository.lastCreate!.toDate, '2026-10-31');
    expect(repository.lastCreate!.timeZoneId, 'Asia/Dubai');
  });

  test(
    'update forwards an existing assignment without requiring employee',
    () async {
      final repository = InMemoryEmployeeShiftRepository(
        shifts: [employeeShift(id: 5)],
      );
      final adapter = EmployeeShiftConfigurationRepository(repository);
      addTearDown(adapter.dispose);

      final result = await adapter.save(
        context(),
        const EmployeeShiftDraft(
          shiftId: 4,
          fromDate: '2026-11-01',
          toDate: '2026-11-30',
          timeZoneId: 'Asia/Kolkata',
        ),
        id: '5',
      );

      expect(result, isA<Success<EmployeeShiftRecord>>());
      expect(repository.updateCalls, 1);
      expect(repository.lastUpdateId, 5);
      expect(repository.lastUpdate!.employeeId, isNull);
      expect(repository.lastUpdate!.shiftId, 4);
      expect(repository.lastUpdate!.fromDate, '2026-11-01');
      expect(repository.lastUpdate!.toDate, '2026-11-30');
      expect(repository.lastUpdate!.timeZoneId, 'Asia/Kolkata');
      expect((result as Success<EmployeeShiftRecord>).value.id, '5');
    },
  );

  test('setActive supports deactivate only', () async {
    final repository = InMemoryEmployeeShiftRepository(
      shifts: [employeeShift(id: 8)],
    );
    final adapter = EmployeeShiftConfigurationRepository(repository);
    addTearDown(adapter.dispose);

    final activate = await adapter.setActive(context(), '8', true);
    final failure = (activate as Failed<void>).failure;
    expect(failure.code, 'unsupported');
    expect(failure.kind, FailureKind.notConfigured);
    expect(repository.deactivateCalls, 0);

    final deactivate = await adapter.setActive(context(), '8', false);
    expect(deactivate, isA<Success<void>>());
    expect(repository.deactivateCalls, 1);
    expect(repository.lastDeactivateId, 8);
  });

  test('list bloc exposes the adapter records', () async {
    final adapter = EmployeeShiftConfigurationRepository(
      InMemoryEmployeeShiftRepository(shifts: [employeeShift()]),
    );
    addTearDown(adapter.dispose);
    final bloc = EmployeeShiftListBloc(adapter, context());
    addTearDown(bloc.close);

    bloc.add(const RecordListStarted());
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(bloc.state.data!.items, hasLength(1));
    expect(bloc.state.data!.items.single.record.shiftName, 'Morning');
    expect(bloc.state.loading, isFalse);
  });
}
