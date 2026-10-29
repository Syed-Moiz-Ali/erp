import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/utils/local_time.dart';
import 'package:modular_erp/modules/hr/shifts/data/repositories/remote_shift_repository.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';

import 'support/department_test_doubles.dart' show departmentAuthContext;
import 'support/shift_test_doubles.dart';

const _draft = ShiftDraft(
  name: 'Morning',
  startTime: LocalTime(hour: 9, minute: 0),
  endTime: LocalTime(hour: 12, minute: 0),
  earlyPunchInMinutes: 15,
  gracePeriodMinutes: 10,
);

void main() {
  late FakeShiftRemoteDataSource dataSource;
  late RemoteShiftRepository repository;
  final context = departmentAuthContext();

  setUp(() {
    dataSource = FakeShiftRemoteDataSource();
    repository = RemoteShiftRepository(dataSource);
  });

  tearDown(() => repository.dispose());

  test('list maps the page and the app page to the server page', () async {
    dataSource.onList = (page, pageSize, search, statusId) async =>
        Success(shiftPage([shiftDto(1, 'Morning', activeAssignments: 3)]));
    final result = await repository.watchList(context, page: 0).first;
    final page = (result as Success).value;
    expect(page.items.single.record.id, '1');
    expect(page.items.single.record.companyId, '3');
    expect(page.items.single.assignedEmployees, 3);
    expect(dataSource.lastPage, 1);
  });

  test('status filter maps to the documented statusId', () async {
    await repository
        .watchList(context, status: ConfigurationStatus.active)
        .first;
    expect(dataSource.lastStatusId, 1);
    await repository
        .watchList(context, status: ConfigurationStatus.inactive)
        .first;
    expect(dataSource.lastStatusId, 2);
    await repository.watchList(context).first;
    expect(dataSource.lastStatusId, isNull);
  });

  test('create returns the server record without optimistic success', () async {
    dataSource.onCreate = (request) async =>
        Success(shiftDto(9, request.shiftName));
    final result = await repository.save(context, _draft);
    expect((result as Success).value.id, '9');
    expect(dataSource.lastCreate!.shiftName, 'Morning');
    expect(dataSource.lastCreate!.lateGraceMinutes, 10);
  });

  test('a failed create propagates the failure', () async {
    dataSource.onCreate = (_) async =>
        const Failed(Failure(code: 'offline', kind: FailureKind.offline));
    expect(
      ((await repository.save(context, _draft) as Failed).failure.kind),
      FailureKind.offline,
    );
  });

  test(
    'client validation rejects an empty name and out-of-range early punch',
    () async {
      expect(
        (await repository.save(context, _draft.copyWith(name: '  ')) as Failed)
            .failure
            .code,
        'required',
      );
      expect(
        (await repository.save(
                  context,
                  _draft.copyWith(earlyPunchInMinutes: 200),
                )
                as Failed)
            .failure
            .code,
        'invalidEarlyPunch',
      );
      expect(dataSource.createCalls, 0);
    },
  );

  test('update maps the duplicate backend code to the form code', () async {
    dataSource.onUpdate = (id, request) async => const Failed(
      Failure(code: 'SHIFT_DUPLICATE_NAME', kind: FailureKind.conflict),
    );
    final result = await repository.save(context, _draft, id: '4');
    final failure = (result as Failed).failure;
    expect(failure.code, 'duplicateName');
    expect(failure.field, 'shiftName');
    expect(dataSource.lastUpdateId, 4);
  });

  test('setActive uses activate or deactivate accordingly', () async {
    await repository.setActive(context, '6', true);
    expect(dataSource.activateCalls, 1);
    expect(dataSource.lastActivateId, 6);
    await repository.setActive(context, '6', false);
    expect(dataSource.deactivateCalls, 1);
  });

  test('deactivate maps SHIFT_IN_USE', () async {
    dataSource.onDeactivate = (id) async =>
        const Failed(Failure(code: 'SHIFT_IN_USE', kind: FailureKind.conflict));
    expect(
      ((await repository.setActive(context, '6', false) as Failed)
          .failure
          .code),
      'inUse',
    );
  });

  test('getById returns null on not found and the count on success', () async {
    dataSource.onGet = (_) async => const Failed(
      Failure(code: 'SHIFT_NOT_FOUND', kind: FailureKind.notFound),
    );
    expect((await repository.getById(context, '9') as Success).value, isNull);

    dataSource.onGet = (id) async =>
        Success(shiftDto(id, 'Ops', activeAssignments: 5));
    expect(
      (await repository.assignedEmployeeCount(context, '9') as Success).value,
      5,
    );
  });
}
