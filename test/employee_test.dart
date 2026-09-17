import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/features/employees/domain/employee_repository.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/features/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/features/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/features/auth/data/repositories/demo_auth_repository.dart';
import 'package:modular_erp/features/employees/data/employee_dao.dart';
import 'package:modular_erp/features/employees/data/employee_seed.dart';
import 'package:modular_erp/features/employees/data/account_provisioning_repository.dart';
import 'package:modular_erp/features/employees/data/local_account_access_guard.dart';
import 'package:modular_erp/features/employees/data/local_employee_repository.dart';
import 'package:modular_erp/features/employees/domain/employee.dart';
import 'package:modular_erp/features/employees/domain/employee_access.dart';
import 'package:modular_erp/features/employees/presentation/bloc/employee_list_bloc.dart';
import 'package:modular_erp/features/employees/presentation/bloc/employee_details_bloc.dart';
import 'package:modular_erp/features/employees/presentation/bloc/employee_form_bloc.dart';
import 'support/memory_session_storage.dart';

AuthContext employeeContext(AppRole role) => DemoAuthSource().accounts
    .firstWhere((a) => a.context.user.role == role)
    .context;
EmployeeDraft validDraft({
  String email = 'new@erp.demo',
  String phone = '+15558881111',
}) => EmployeeDraft(
  firstName: 'New',
  lastName: 'Colleague',
  email: email,
  phone: phone,
  departmentId: 'dept-0',
  designationId: 'designation-0',
  joiningDate: DateTime(2025),
);
EmployeeDraft draftFrom(Employee e) => EmployeeDraft(
  firstName: e.firstName,
  middleName: e.middleName,
  lastName: e.lastName,
  email: e.email,
  phone: e.phone,
  departmentId: e.departmentId,
  designationId: e.designationId,
  managerId: e.managerId,
  joiningDate: e.joiningDate,
  employmentType: e.employmentType,
  status: e.status,
  loginEnabled: e.loginEnabled,
);
T unwrap<T>(Result<T> result) {
  expect(result, isA<Success<T>>());
  return (result as Success<T>).value;
}

Future<void> until(bool Function() ready) async {
  for (var n = 0; n < 150 && !ready(); n++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(ready(), isTrue);
}

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

void main() {
  late AppDatabase db;
  late EmployeeDao dao;
  late LocalEmployeeRepository repo;
  final hr = employeeContext(AppRole.hr),
      manager = employeeContext(AppRole.manager),
      self = employeeContext(AppRole.employee);
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedEmployees(db);
    dao = EmployeeDao(db);
    repo = LocalEmployeeRepository(dao, LocalAccountProvisioningRepository(db));
  });
  tearDown(() async {
    await db.close();
  });
  test(
    'account identifier conflicts return duplicate validation and roll back',
    () async {
      final result = await repo.saveEmployee(
        hr,
        validDraft(email: 'admin@erp.demo').copyWith(loginEnabled: true),
      );
      expect(result, isA<Failed<Employee>>());
      expect((result as Failed<Employee>).failure.code, 'duplicateEmail');
      expect((await dao.page(hr)).total, 25);
      expect((await db.select(db.workforceAccounts).get()).length, 5);
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    },
  );
  test('SQL sorts names and joining dates correctly', () async {
    final asc = await dao.page(hr, pageSize: 100),
        desc = await dao.page(
          hr,
          pageSize: 100,
          sort: EmployeeSort.nameDescending,
        );
    expect(
      asc.employees.map((e) => e.id).toList(),
      desc.employees.reversed.map((e) => e.id).toList(),
    );
    for (final sort in [EmployeeSort.newestJoined, EmployeeSort.oldestJoined]) {
      final p = await dao.page(hr, pageSize: 100, sort: sort);
      for (var i = 1; i < p.employees.length; i++) {
        final comparison = p.employees[i - 1].joiningDate.compareTo(
          p.employees[i].joiningDate,
        );
        expect(
          comparison,
          sort == EmployeeSort.newestJoined
              ? greaterThanOrEqualTo(0)
              : lessThanOrEqualTo(0),
        );
      }
    }
  });
  test('role options respect the full explicit permission ceiling', () {
    final limited = hr.copyWith(
      user: hr.user.copyWith(
        permissions: PermissionSet([AppPermission.employeeCreate]),
      ),
    );
    expect(const AccountRolePolicy().available(limited), isEmpty);
    expect(
      const AccountRolePolicy().available(
        employeeContext(AppRole.companyAdmin),
      ),
      containsAll([
        AppRole.employee,
        AppRole.manager,
        AppRole.hr,
        AppRole.companyAdmin,
      ]),
    );
    expect(
      const AccountRolePolicy().available(employeeContext(AppRole.superAdmin)),
      isNot(contains(AppRole.superAdmin)),
    );
  });
  test(
    'list Bloc exposes failure and supports sorting and status writes',
    () async {
      final mock = MockEmployeeRepository();
      when(
        () => mock.getReferences(hr),
      ).thenAnswer((_) async => const Failed(Failure(code: 'storage')));
      when(
        () => mock.watchEmployees(
          hr,
          query: '',
          filter: const EmployeeFilter(),
          sort: EmployeeSort.nameAscending,
          page: 0,
        ),
      ).thenAnswer((_) => Stream.value(const Failed(Failure(code: 'storage'))));
      final failed = EmployeeListBloc(mock, hr)
        ..add(const EmployeeListStarted());
      await until(() => failed.state.failure != null);
      expect(failed.state.loading, isFalse);
      await failed.close();
      final b = EmployeeListBloc(repo, hr)..add(const EmployeeListStarted());
      await until(() => !b.state.loading);
      b.add(const EmployeeSortChanged(EmployeeSort.code));
      await until(() => !b.state.loading && b.state.sort == EmployeeSort.code);
      expect(b.state.data!.employees.first.employeeCode, 'EMP-0001');
      b.add(const EmployeeStatusRequested('employee-employee', false));
      await until(
        () =>
            !b.state.busy &&
            b.state.data?.employees
                    .where((e) => e.id == 'employee-employee')
                    .firstOrNull
                    ?.status ==
                EmploymentStatus.inactive,
      );
      expect(
        unwrap(await repo.getEmployeeById(hr, 'employee-employee'))!.status,
        EmploymentStatus.inactive,
      );
      b.add(const EmployeeStatusRequested('employee-employee', true));
      await until(
        () =>
            !b.state.busy &&
            b.state.data?.employees
                    .where((e) => e.id == 'employee-employee')
                    .firstOrNull
                    ?.status ==
                EmploymentStatus.active,
      );
      await b.close();
    },
  );
  test('details Bloc represents not found without storage failure', () async {
    final b = EmployeeDetailsBloc(repo, hr, 'missing')
      ..add(const EmployeeDetailsStarted());
    await until(() => !b.state.loading);
    expect(b.state.employee, isNull);
    expect(b.state.failure, isNull);
    await b.close();
  });
  test(
    'edit form preloads role and duplicate failure retains the draft',
    () async {
      final b = EmployeeFormBloc(repo, hr, id: 'employee-employee')
        ..add(const EmployeeFormInitialized());
      await until(() => !b.state.loading);
      expect(b.state.draft.firstName, 'Noor');
      expect(b.state.draft.accountRole, AppRole.employee);
      expect(b.state.dirty, isFalse);
      expect(
        b.state.references!.managers.any((m) => m.id == 'employee-employee'),
        isFalse,
      );
      b.add(EmployeeDraftChanged((d) => d.copyWith(email: 'hr@erp.demo')));
      b.add(const EmployeeSubmitted());
      await until(() => b.state.failure != null);
      expect(b.state.fieldErrors['email'], 'duplicateEmail');
      expect(b.state.draft.email, 'hr@erp.demo');
      expect(b.state.dirty, isTrue);
      await b.close();
    },
  );

  test(
    'outbox failure rolls back employee and linked account together',
    () async {
      await db.customStatement(
        "CREATE TRIGGER reject_test_outbox BEFORE INSERT ON sync_outbox BEGIN SELECT RAISE(ABORT, 'test storage failure'); END",
      );
      expect(
        await repo.saveEmployee(hr, validDraft().copyWith(loginEnabled: true)),
        isA<Failed<Employee>>(),
      );
      expect((await dao.page(hr)).total, 25);
      expect((await db.select(db.workforceAccounts).get()).length, 5);
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    },
  );
  test('concurrent writes allocate unique stable employee codes', () async {
    final results = await Future.wait([
      repo.saveEmployee(hr, validDraft()),
      repo.saveEmployee(
        hr,
        validDraft(email: 'second@erp.demo', phone: '+15558882222'),
      ),
    ]);
    expect(results.map((r) => unwrap(r).employeeCode).toSet(), {
      'EMP-0026',
      'EMP-0027',
    });
    expect((await db.select(db.syncOutbox).get()).length, 2);
  });
  test(
    'file database retains edits and seed does not replace them after restart',
    () async {
      await db.close();
      final directory = await Directory.systemTemp.createTemp(
        'erp_employee_test_',
      );
      final file = File('${directory.path}/employees.sqlite');
      var persistent = AppDatabase(NativeDatabase(file));
      await seedEmployees(persistent);
      var repository = LocalEmployeeRepository(
        EmployeeDao(persistent),
        LocalAccountProvisioningRepository(persistent),
      );
      final e = unwrap(await repository.saveEmployee(hr, validDraft()));
      await persistent.close();
      persistent = AppDatabase(NativeDatabase(file));
      await seedEmployees(persistent);
      repository = LocalEmployeeRepository(
        EmployeeDao(persistent),
        LocalAccountProvisioningRepository(persistent),
      );
      expect(
        unwrap(await repository.getEmployeeById(hr, e.id))!.email,
        e.email,
      );
      expect((await EmployeeDao(persistent).page(hr)).total, 26);
      expect((await persistent.select(persistent.syncOutbox).get()).length, 1);
      await persistent.close();
      for (final entity in directory.listSync()) {
        if (entity is File) {
          await entity.delete();
        }
      }
      await directory.delete();
    },
  );
  test(
    'local role changes update active auth permissions and survive restore',
    () async {
      final storage = MemorySessionStorage();
      final auth = DemoAuthRepository(
        storage,
        source: DemoAuthSource(),
        accountGuard: LocalAccountAccessGuard(db),
      );
      expect(
        await auth.login(
          AuthIdentifier.parse('employee@erp.demo')!,
          'Employee@123',
        ),
        isA<Success<AuthContext>>(),
      );
      final changed = auth.sessionChanges.firstWhere(
        (c) => c?.user.role == AppRole.manager,
      );
      final e = unwrap(await repo.getEmployeeById(hr, 'employee-employee'))!;
      unwrap(
        await repo.saveEmployee(
          hr,
          draftFrom(e).copyWith(accountRole: AppRole.manager),
          id: e.id,
        ),
      );
      final context = await changed.timeout(const Duration(seconds: 3));
      expect(
        context!.user.permissions.contains(AppPermission.employeeViewTeam),
        isTrue,
      );
      await auth.dispose();
      final restored = DemoAuthRepository(
        storage,
        source: DemoAuthSource(),
        accountGuard: LocalAccountAccessGuard(db),
      );
      expect(
        unwrap(await restored.restoreSession())!.user.role,
        AppRole.manager,
      );
      await restored.dispose();
    },
  );
  test(
    'seed is stable, typed, bilingual and contains separate identities',
    () async {
      await seedEmployees(db);
      final page = await dao.page(hr, pageSize: 100);
      expect(page.total, 25);
      expect(page.employees.length, 25);
      expect(page.employees.map((e) => e.employeeCode).toSet().length, 25);
      expect(
        page.employees.any(
          (e) => RegExp('[\u0600-\u06ff]').hasMatch(e.displayName),
        ),
        isTrue,
      );
      final e = unwrap(await repo.getEmployeeById(self, 'employee-employee'))!;
      expect(e.id, isNot(e.linkedUserId));
      expect(e.linkedUserId, 'demo-employee');
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    },
  );
  test(
    'SQL scopes all, direct team, self and no permission with accurate counts',
    () async {
      expect((await dao.page(hr)).total, 25);
      expect((await dao.page(manager)).total, 10);
      expect((await dao.page(self)).total, 1);
      final none = self.copyWith(
        user: self.user.copyWith(permissions: PermissionSet([])),
      );
      expect((await dao.page(none)).total, 0);
      expect(
        await repo.getEmployeeById(manager, 'employee-hr'),
        isA<Failed<Employee?>>(),
      );
      expect(unwrap(await repo.getEmployeeById(hr, 'missing')), isNull);
      expect(
        unwrap(await repo.getEmployeeById(manager, 'employee-manager'))!.id,
        'employee-manager',
      );
      final foreign = hr.copyWith(company: hr.company.copyWith(id: 'other'));
      expect((await dao.page(foreign)).total, 0);
    },
  );
  test('SQL pagination has stable order and no duplicates', () async {
    final ids = <String>[];
    for (var p = 0; p < 3; p++) {
      final page = await dao.page(hr, page: p, sort: EmployeeSort.code);
      ids.addAll(page.employees.map((e) => e.id));
      expect(page.filtered, 25);
    }
    expect(ids.length, 25);
    expect(ids.toSet().length, 25);
  });
  for (final query in [
    'EMP-0003',
    'employee@erp.demo',
    '+15550001005',
    'Noor Ali',
  ]) {
    test('search is composed in SQL for $query', () async {
      final p = await dao.page(hr, query: query);
      expect(p.filtered, 1);
      expect(p.employees.single.id, 'employee-employee');
    });
  }
  test(
    'literal SQL wildcards and injection input do not widen results',
    () async {
      for (final q in ['%', '_', "' OR 1=1 --"]) {
        expect((await dao.page(hr, query: q)).filtered, 0);
      }
    },
  );
  test('five filters compose and stay within scope', () async {
    final e = unwrap(await repo.getEmployeeById(hr, 'employee-employee'))!;
    final p = await dao.page(
      manager,
      filter: EmployeeFilter(
        status: e.status,
        departmentId: e.departmentId,
        designationId: e.designationId,
        managerId: e.managerId,
        employmentType: e.employmentType,
      ),
    );
    expect(p.filtered, greaterThan(0));
    expect(
      p.employees.every(
        (v) =>
            v.managerId == manager.employeeReference!.id &&
            v.departmentId == e.departmentId &&
            v.employmentType == e.employmentType,
      ),
      isTrue,
    );
  });
  test(
    'create trims and normalizes data and atomically queues a pending mutation',
    () async {
      final e = unwrap(
        await repo.saveEmployee(
          hr,
          validDraft(
            email: ' NEW@ERP.DEMO ',
          ).copyWith(firstName: ' New ', phone: '(555) 888-1111', lastName: ''),
        ),
      );
      expect(e.employeeCode, 'EMP-0026');
      expect(e.email, 'new@erp.demo');
      expect(e.phone, '+5558881111');
      expect(e.displayName, 'New');
      expect(e.syncStatus, EmployeeSyncStatus.pending);
      final outbox = await db.select(db.syncOutbox).get();
      expect(outbox.length, 1);
      expect(outbox.single.entityId, e.id);
      expect(outbox.single.payload, contains('EMP-0026'));
      expect(outbox.single.attempts, 0);
    },
  );
  test(
    'edit preserves identity, code, created date and employment history',
    () async {
      final old = unwrap(await repo.getEmployeeById(hr, 'employee-4'))!;
      final e = unwrap(
        await repo.saveEmployee(
          hr,
          draftFrom(old).copyWith(firstName: 'Changed'),
          id: old.id,
        ),
      );
      expect(e.id, old.id);
      expect(e.employeeCode, old.employeeCode);
      expect(e.createdAt, old.createdAt);
      expect(e.firstName, 'Changed');
      expect((await dao.page(hr)).total, 25);
    },
  );
  test('duplicates are rejected but an unchanged edit is allowed', () async {
    final old = unwrap(await repo.getEmployeeById(hr, 'employee-4'))!;
    expect(
      await repo.saveEmployee(hr, validDraft(email: old.email)),
      isA<Failed<Employee>>(),
    );
    expect(
      await repo.saveEmployee(hr, validDraft(phone: old.phone)),
      isA<Failed<Employee>>(),
    );
    expect(
      await repo.saveEmployee(hr, draftFrom(old), id: old.id),
      isA<Success<Employee>>(),
    );
    expect(
      unwrap(
        await repo.checkEmailAvailability(hr, old.email, excludingId: old.id),
      ),
      isTrue,
    );
  });
  for (final item in [
    validDraft().copyWith(firstName: ''),
    validDraft().copyWith(email: 'bad'),
    validDraft().copyWith(phone: '1'),
    validDraft().copyWith(joiningDate: DateTime(2099)),
    validDraft().copyWith(departmentId: 'missing'),
    validDraft().copyWith(designationId: 'missing'),
    validDraft().copyWith(managerId: 'missing'),
  ]) {
    test(
      'invalid draft is rejected before any mutation: ${item.toString()}',
      () async {
        expect(await repo.saveEmployee(hr, item), isA<Failed<Employee>>());
        expect((await dao.page(hr)).total, 25);
        expect(await db.select(db.syncOutbox).get(), isEmpty);
      },
    );
  }
  test('self and multi-hop reporting cycles are rejected', () async {
    final m = unwrap(await repo.getEmployeeById(hr, 'employee-manager'))!;
    expect(
      await repo.saveEmployee(
        hr,
        draftFrom(m).copyWith(managerId: m.id),
        id: m.id,
      ),
      isA<Failed<Employee>>(),
    );
    expect(
      await repo.saveEmployee(
        hr,
        draftFrom(m).copyWith(managerId: 'employee-employee'),
        id: m.id,
      ),
      isA<Failed<Employee>>(),
    );
  });
  test('write authorization is enforced inside repository', () async {
    expect(
      await repo.saveEmployee(self, validDraft()),
      isA<Failed<Employee>>(),
    );
    expect(
      await repo.setActive(manager, 'employee-employee', false),
      isA<Failed<void>>(),
    );
    expect(await db.select(db.syncOutbox).get(), isEmpty);
  });
  test(
    'deactivation preserves records, disables linked account and queues change',
    () async {
      expect(
        await repo.setActive(hr, 'employee-employee', false),
        isA<Success<void>>(),
      );
      expect((await dao.page(hr)).total, 25);
      expect(
        unwrap(await repo.getEmployeeById(hr, 'employee-employee'))!.status,
        EmploymentStatus.inactive,
      );
      expect(
        unwrap(
          await repo.getLinkedAccount(hr, 'employee-employee'),
        )!.user.status,
        AccountStatus.inactive,
      );
      expect(
        await LocalAccountAccessGuard(db).enabled('demo-employee'),
        isFalse,
      );
      await repo.setActive(hr, 'employee-employee', true);
      expect(
        await LocalAccountAccessGuard(db).enabled('demo-employee'),
        isTrue,
      );
      expect((await db.select(db.syncOutbox).get()).length, 2);
    },
  );
  test(
    'account provisioning is separate, pending and without stored secrets',
    () async {
      final e = unwrap(
        await repo.saveEmployee(hr, validDraft().copyWith(loginEnabled: true)),
      );
      expect(e.linkedUserId, isNotNull);
      final a = unwrap(await repo.getLinkedAccount(hr, e.id))!;
      expect(a.credentialPending, isTrue);
      expect(a.user.role, AppRole.employee);
      expect(await LocalAccountAccessGuard(db).enabled(a.user.id), isFalse);
      final cols = await db
          .customSelect('PRAGMA table_info(workforce_accounts)')
          .get();
      expect(
        cols.any((r) => r.read<String>('name').contains('password')),
        isFalse,
      );
    },
  );
  test(
    'role ceiling rejects privilege escalation and rolls back provisioning',
    () async {
      expect(
        await repo.saveEmployee(
          hr,
          validDraft().copyWith(
            loginEnabled: true,
            accountRole: AppRole.superAdmin,
          ),
        ),
        isA<Failed<Employee>>(),
      );
      expect((await dao.page(hr)).total, 25);
      expect((await db.select(db.workforceAccounts).get()).length, 5);
      expect(await db.select(db.syncOutbox).get(), isEmpty);
      expect(
        const AccountRolePolicy().available(hr),
        contains(AppRole.manager),
      );
    },
  );
  test(
    'reactive employee detail updates on edits despite unchanged row count',
    () async {
      final changes = <String>[];
      final sub = repo.watchEmployee(hr, 'employee-4').listen((r) {
        if (r is Success<Employee?>) changes.add(r.value!.firstName);
      });
      await until(() => changes.isNotEmpty);
      final e = unwrap(await repo.getEmployeeById(hr, 'employee-4'))!;
      await repo.saveEmployee(
        hr,
        draftFrom(e).copyWith(firstName: 'Reactive'),
        id: e.id,
      );
      await until(() => changes.contains('Reactive'));
      await sub.cancel();
    },
  );
  test(
    'list Bloc debounces search and resets pagination for filters',
    () async {
      final b = EmployeeListBloc(repo, hr);
      b.add(const EmployeeListStarted());
      await until(() => !b.state.loading);
      b.add(const EmployeePageChanged(1));
      await until(() => !b.state.loading && b.state.page == 1);
      b.add(const EmployeeSearchChanged('No'));
      b.add(const EmployeeSearchChanged('Noor Ali'));
      await until(() => !b.state.loading && b.state.query == 'Noor Ali');
      expect(b.state.page, 0);
      expect(b.state.data!.filtered, 1);
      b.add(
        const EmployeeFilterChanged(
          EmployeeFilter(status: EmploymentStatus.inactive),
        ),
      );
      await until(() => !b.state.loading && b.state.filter.status != null);
      expect(b.state.data!.filtered, 0);
      await b.close();
    },
  );
  test('details Bloc exposes scoped denial and reactive status', () async {
    final b = EmployeeDetailsBloc(repo, manager, 'employee-hr');
    b.add(const EmployeeDetailsStarted());
    await until(() => !b.state.loading);
    expect(b.state.failure!.code, 'denied');
    await b.close();
    final c = EmployeeDetailsBloc(repo, hr, 'employee-employee');
    c.add(const EmployeeDetailsStarted());
    await until(() => !c.state.loading);
    c.add(const EmployeeDetailsStatusRequested(false));
    await until(
      () =>
          c.state.employee?.status == EmploymentStatus.inactive &&
          !c.state.busy,
    );
    await c.close();
  });
  test(
    'form Bloc retains failed draft, tracks dirty and prevents duplicate saves',
    () async {
      final b = EmployeeFormBloc(repo, hr);
      b.add(const EmployeeFormInitialized());
      await until(() => !b.state.loading);
      b.add(EmployeeDraftChanged((d) => d.copyWith(firstName: 'Retained')));
      b.add(const EmployeeSubmitted());
      await until(() => b.state.failure != null);
      expect(b.state.dirty, isTrue);
      expect(b.state.draft.firstName, 'Retained');
      b.add(EmployeeDraftChanged((_) => validDraft()));
      b.add(const EmployeeSubmitted());
      b.add(const EmployeeSubmitted());
      await until(() => b.state.savedId != null);
      expect(b.state.dirty, isFalse);
      expect((await dao.page(hr)).total, 26);
      expect((await db.select(db.syncOutbox).get()).length, 1);
      await b.close();
    },
  );
  test(
    'account deactivation revokes active auth and prevents later login',
    () async {
      final auth = DemoAuthRepository(
        MemorySessionStorage(),
        source: DemoAuthSource(),
        accountGuard: LocalAccountAccessGuard(db),
      );
      expect(
        await auth.login(
          AuthIdentifier.parse('employee@erp.demo')!,
          'Employee@123',
        ),
        isA<Success<AuthContext>>(),
      );
      final revoked = auth.sessionChanges.firstWhere((c) => c == null);
      await repo.setActive(hr, 'employee-employee', false);
      await revoked.timeout(const Duration(seconds: 3));
      expect(
        await auth.login(
          AuthIdentifier.parse('employee@erp.demo')!,
          'Employee@123',
        ),
        isA<Failed<AuthContext>>(),
      );
      await auth.dispose();
    },
  );
  test('v1 migration retains pending outbox and adds workforce tables', () async {
    await db.close();
    final old = NativeDatabase.memory(
      setup: (sqlite) {
        sqlite.execute(
          'CREATE TABLE sync_outbox(id TEXT NOT NULL PRIMARY KEY,module_id TEXT NOT NULL,entity_id TEXT NOT NULL,operation TEXT NOT NULL,payload TEXT NOT NULL,created_at INTEGER NOT NULL,attempts INTEGER NOT NULL DEFAULT 0)',
        );
        sqlite.execute(
          "INSERT INTO sync_outbox VALUES('retained','old','entity','update','{}',1700000000,2)",
        );
        sqlite.execute('PRAGMA user_version=1');
      },
    );
    final migrated = AppDatabase(old);
    final rows = await migrated.select(migrated.syncOutbox).get();
    expect(rows.single.id, 'retained');
    expect(rows.single.attempts, 2);
    expect(await migrated.select(migrated.workforceEmployees).get(), isEmpty);
    expect(
      (await migrated.customSelect('PRAGMA user_version').getSingle())
          .read<int>('user_version'),
      3,
    );
    await migrated.close();
  });
}
