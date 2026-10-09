import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/hr/departments/data/repositories/local_department_repository.dart';
import 'package:modular_erp/modules/hr/departments/data/repositories/remote_department_repository.dart';
import 'package:modular_erp/modules/hr/departments/domain/department.dart';

import 'support/department_test_doubles.dart';

void main() {
  group('RemoteDepartmentRepository', () {
    late FakeDepartmentRemoteDataSource dataSource;
    late RemoteDepartmentRepository repository;
    final context = departmentAuthContext();

    setUp(() {
      dataSource = FakeDepartmentRemoteDataSource();
      repository = RemoteDepartmentRepository(dataSource);
    });

    tearDown(() => repository.dispose());

    test('list maps the page, counts and company scope', () async {
      dataSource.onList = (page, pageSize, search) async => Success(
        departmentPage([
          departmentDto(2, 'accounts', employeeCount: 5),
          departmentDto(3, 'Developer'),
        ], totalItems: 2),
      );
      final result = await repository
          .watchList(context, query: 'a', page: 0, pageSize: 10)
          .first;

      expect(result, isA<Success<ConfigurationPageData<Department>>>());
      final page = (result as Success).value;
      expect(page.items.length, 2);
      expect(page.items.first.record.id, '2');
      expect(page.items.first.record.companyId, '3');
      expect(page.items.first.assignedEmployees, 5);
      expect(page.total, 2);
      expect(dataSource.lastPage, 1); // app page 0 -> server page 1
      expect(dataSource.lastSearch, 'a');
    });

    test(
      'the inactive filter is an accurate empty result (no backend source)',
      () async {
        final result = await repository
            .watchList(context, status: ConfigurationStatus.inactive)
            .first;
        expect((result as Success).value.items, isEmpty);
        expect(dataSource.listCalls, 0);
      },
    );

    test(
      'create returns the server record and never fabricates success',
      () async {
        dataSource.onCreate = (request) async => Success(
          departmentDto(10, request.departmentName, employeeCount: 0),
        );
        final result = await repository.save(
          context,
          const DepartmentDraft(name: 'Finance'),
        );
        expect((result as Success).value.id, '10');
        expect(dataSource.lastCreate!.departmentName, 'Finance');
      },
    );

    test(
      'a failed create propagates the failure (no optimistic success)',
      () async {
        dataSource.onCreate = (_) async =>
            const Failed(Failure(code: 'offline', kind: FailureKind.offline));
        final result = await repository.save(
          context,
          const DepartmentDraft(name: 'Finance'),
        );
        expect(result, isA<Failed<Department>>());
        expect((result as Failed).failure.kind, FailureKind.offline);
      },
    );

    test('client-side validation rejects blank and over-long names', () async {
      expect(
        (await repository.save(context, const DepartmentDraft(name: '   '))
                as Failed)
            .failure
            .code,
        'required',
      );
      expect(
        (await repository.save(context, DepartmentDraft(name: 'x' * 51))
                as Failed)
            .failure
            .code,
        'tooLong',
      );
      expect(dataSource.createCalls, 0);
    });

    test('rename maps the duplicate backend code to the form code', () async {
      dataSource.onRename = (id, request) async => const Failed(
        Failure(code: 'DEPARTMENT_DUPLICATE_NAME', kind: FailureKind.conflict),
      );
      final result = await repository.save(
        context,
        const DepartmentDraft(name: 'dup'),
        id: '4',
      );
      final failure = (result as Failed).failure;
      expect(failure.code, 'duplicateName');
      expect(failure.field, 'departmentName');
    });

    test('deactivate maps DEPARTMENT_IN_USE', () async {
      dataSource.onDeactivate = (id) async => const Failed(
        Failure(code: 'DEPARTMENT_IN_USE', kind: FailureKind.conflict),
      );
      final result = await repository.setActive(context, '6', false);
      expect((result as Failed).failure.code, 'inUse');
    });

    test('activate is reported unsupported without a server call', () async {
      final result = await repository.setActive(context, '6', true);
      expect((result as Failed).failure.code, 'unsupported');
      expect(dataSource.deactivateCalls, 0);
    });

    test('getById returns null on not found', () async {
      dataSource.onGet = (_) async => const Failed(
        Failure(code: 'DEPARTMENT_NOT_FOUND', kind: FailureKind.notFound),
      );
      expect((await repository.getById(context, '9') as Success).value, isNull);
    });

    test('assignedEmployeeCount reads the server count', () async {
      dataSource.onGet = (id) async =>
          Success(departmentDto(id, 'Ops', employeeCount: 7));
      expect(
        (await repository.assignedEmployeeCount(context, '9') as Success).value,
        7,
      );
    });
  });

  group('LocalDepartmentRepository', () {
    late AppDatabase db;
    late LocalDepartmentRepository repository;
    final context = departmentAuthContext();

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repository = LocalDepartmentRepository(db);
      await db
          .into(db.workforceDepartments)
          .insert(
            WorkforceDepartmentsCompanion.insert(
              id: 'dept-0',
              companyId: '3',
              name: 'Sales',
            ),
          );
    });

    tearDown(() => db.close());

    test('list returns seeded departments scoped to the company', () async {
      final result = await repository.watchList(context).first;
      final page = (result as Success).value;
      expect(page.items.single.record.id, 'dept-0');
      expect(page.items.single.record.name, 'Sales');
      expect(page.total, 1);
    });

    test('create adds a department and rejects an active duplicate', () async {
      final created = await repository.save(
        context,
        const DepartmentDraft(name: 'Finance'),
      );
      expect(created, isA<Success<Department>>());

      final duplicate = await repository.save(
        context,
        const DepartmentDraft(name: 'sales'),
      );
      expect((duplicate as Failed).failure.code, 'duplicateName');
    });

    test('deactivate is refused while employees are assigned', () async {
      await db
          .into(db.workforceDesignations)
          .insert(
            WorkforceDesignationsCompanion.insert(
              id: 'desig-0',
              companyId: '3',
              name: 'Technician',
            ),
          );
      await db
          .into(db.workforceEmployees)
          .insert(
            WorkforceEmployeesCompanion.insert(
              id: 'emp-0',
              companyId: '3',
              employeeCode: 'EMP-0',
              firstName: 'A',
              email: 'a@x.com',
              phone: '123',
              departmentId: 'dept-0',
              designationId: 'desig-0',
              joiningDate: DateTime.utc(2026),
              employmentType: 'Revenue',
              status: 'active',
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
              syncStatus: 'synced',
            ),
          );

      final blocked = await repository.setActive(context, 'dept-0', false);
      expect((blocked as Failed).failure.code, 'inUse');

      expect(
        (await repository.assignedEmployeeCount(context, 'dept-0') as Success)
            .value,
        1,
      );
    });

    test('deactivate succeeds when no employees are assigned', () async {
      expect(
        await repository.setActive(context, 'dept-0', false),
        isA<Success<void>>(),
      );
      final result = await repository.watchList(context).first;
      expect(
        (result as Success).value.items.single.record.status,
        ConfigurationStatus.inactive,
      );
    });

    test('access is denied without the view permission', () async {
      final denied = await repository
          .watchList(departmentAuthContext(permissions: const {}))
          .first;
      expect((denied as Failed).failure.code, 'denied');
    });
  });
}
