import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/app/router/app_router.dart';
import 'package:modular_erp/bootstrap/demo_configuration_seed.dart';
import 'package:modular_erp/bootstrap/demo_workforce_seed.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/features/attendance/data/workforce_attendance_read_repository.dart';
import 'package:modular_erp/features/attendance/domain/attendance_scope_resolver.dart';
import 'package:modular_erp/features/attendance/domain/workforce_attendance.dart';
import 'package:modular_erp/features/auth/data/repositories/demo_auth_repository.dart';
import 'package:modular_erp/features/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/features/employees/data/employee_seed.dart';
import 'package:modular_erp/features/leave/data/leave_configuration_repositories.dart';
import 'package:modular_erp/features/leave/data/local_leave_repository.dart';
import 'package:modular_erp/features/leave/domain/leave_models.dart';
import 'package:modular_erp/features/leave/domain/leave_repository.dart';
import 'support/memory_session_storage.dart';
import 'attendance_test.dart' show FakeClock, MockAuth;
import 'employee_test.dart' show employeeContext;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late MockAuth auth;
  late LocalLeaveRepository repo;
  late AuthContext manager;
  late AuthContext hr;
  late DateTime today;

  AuthContext asEmployee(AuthContext base, String employeeId) => base.copyWith(
    employeeReference: EmployeeReference(
      id: employeeId,
      userAccountId: base.user.id,
      companyId: base.company.id,
    ),
  );

  setUp(() async {
    manager = employeeContext(AppRole.manager);
    hr = employeeContext(AppRole.hr);
    today = DateTime.utc(2026, 9, 22);
    db = AppDatabase(NativeDatabase.memory());
    await seedEmployees(db);
    await seedAttendanceConfiguration(db);
    final clock = FakeClock(DateTime.utc(2026, 9, 22, 12));
    await seedDemoWorkforce(db, enabled: true, clock: clock);
    auth = MockAuth();
    when(() => auth.checkSession()).thenAnswer((_) async => Success(manager));
    repo = LocalLeaveRepository(db, auth, clock, demoEnabled: true);
  });
  tearDown(() async => db.close());

  Future<LeaveRequest> approvedLeaveFor(String employeeId) async {
    final submitted = await repo.submitRequest(
      asEmployee(manager, employeeId),
      LeaveRequestDraft(
        leaveTypeId: 'leave-type-annual',
        startDate: today,
        endDate: today,
      ),
    );
    final request = (submitted as Success<LeaveRequest>).value;
    final approved = await repo.approveRequest(hr, request.id);
    return (approved as Success<LeaveRequest>).value;
  }

  test(
    'manager team scope sees reports only, not unrelated employees',
    () async {
      await approvedLeaveFor('employee-4');
      await approvedLeaveFor('employee-13');

      final team = await repo
          .watchOperations(manager, scope: LeaveRequestScope.team)
          .first;
      final data = (team as Success<LeaveOperationsData>).value;
      final employees = data.requests.map((r) => r.request.employeeId).toSet();
      expect(employees, contains('employee-4'));
      expect(employees, isNot(contains('employee-13')));
      expect(data.summary.onLeaveToday, 1);
      expect(data.summary.teamMembers, greaterThan(0));
    },
  );

  test('HR company scope sees all company leave', () async {
    await approvedLeaveFor('employee-4');
    await approvedLeaveFor('employee-13');

    final company = await repo
        .watchOperations(hr, scope: LeaveRequestScope.company)
        .first;
    final data = (company as Success<LeaveOperationsData>).value;
    final employees = data.requests.map((r) => r.request.employeeId).toSet();
    expect(employees, containsAll(['employee-4', 'employee-13']));
    expect(data.summary.onLeaveToday, 2);
  });

  test(
    'unlinked admin can use company scope but cannot request leave',
    () async {
      final admin = employeeContext(AppRole.companyAdmin);
      expect(admin.employeeReference, isNull);
      final result = await repo
          .watchOperations(admin, scope: LeaveRequestScope.company)
          .first;
      expect(result, isA<Success<LeaveOperationsData>>());
      final submit = await repo.submitRequest(
        admin,
        LeaveRequestDraft(
          leaveTypeId: 'leave-type-annual',
          startDate: today,
          endDate: today,
        ),
      );
      expect(
        (submit as Failed<LeaveRequest>).failure.code,
        'leavePermissionDenied',
      );
    },
  );

  test('approval queue is pending-only and enriched with balances', () async {
    final submitted = await repo.submitRequest(
      asEmployee(manager, 'employee-4'),
      LeaveRequestDraft(
        leaveTypeId: 'leave-type-annual',
        startDate: today.add(const Duration(days: 3)),
        endDate: today.add(const Duration(days: 4)),
      ),
    );
    await repo.approveRequest(
      hr,
      (submitted as Success<LeaveRequest>).value.id,
    );
    final pending = await repo.submitRequest(
      asEmployee(manager, 'employee-5'),
      LeaveRequestDraft(
        leaveTypeId: 'leave-type-annual',
        startDate: today.add(const Duration(days: 6)),
        endDate: today.add(const Duration(days: 7)),
      ),
    );
    expect(pending, isA<Success<LeaveRequest>>());

    final queue = await repo.watchApprovalQueue(hr).first;
    final items = (queue as Success<List<LeaveApprovalItem>>).value;
    expect(items.length, 1);
    expect(items.single.row.request.employeeId, 'employee-5');
    expect(items.single.available, 28);
    expect(items.single.afterApproval, 26);
  });

  test(
    'employee leave profile exposes balances, upcoming and recent',
    () async {
      final future = await repo.submitRequest(
        asEmployee(manager, 'employee-4'),
        LeaveRequestDraft(
          leaveTypeId: 'leave-type-annual',
          startDate: today.add(const Duration(days: 5)),
          endDate: today.add(const Duration(days: 6)),
        ),
      );
      await repo.approveRequest(hr, (future as Success<LeaveRequest>).value.id);

      final result = await repo.watchEmployeeLeave(hr, 'employee-4').first;
      final summary = (result as Success<EmployeeLeaveSummary?>).value!;
      expect(summary.employeeName.isNotEmpty, isTrue);
      expect(summary.department, isNotEmpty);
      expect(summary.balances, isNotEmpty);
      expect(summary.upcoming, isNotEmpty);
      expect(summary.recent, isNotEmpty);
    },
  );

  test('balance adjustment updates the employee leave summary', () async {
    final before = await repo.watchEmployeeLeave(hr, 'employee-4').first;
    final beforeAnnual = (before as Success<EmployeeLeaveSummary?>)
        .value!
        .balances
        .firstWhere((b) => b.leaveTypeId == 'leave-type-annual');
    expect(beforeAnnual.available, 30);

    final adjusted = await repo.adjustBalance(
      hr,
      LeaveBalanceAdjustment(
        employeeId: 'employee-4',
        leaveTypeId: 'leave-type-annual',
        add: true,
        quantityDays: 5,
        effectiveDate: today,
        reason: 'Bonus days',
      ),
    );
    expect(adjusted, isA<Success<void>>());

    final after = await repo.watchEmployeeLeave(hr, 'employee-4').first;
    final afterAnnual = (after as Success<EmployeeLeaveSummary?>)
        .value!
        .balances
        .firstWhere((b) => b.leaveTypeId == 'leave-type-annual');
    expect(afterAnnual.available, 35);
  });

  test('balance table lists scoped employees with ledger values', () async {
    final table = await repo.watchBalanceTable(hr).first;
    final rows = (table as Success<List<LeaveBalanceRow>>).value;
    expect(rows, isNotEmpty);
    final annual = rows.firstWhere(
      (r) =>
          r.employeeId == 'employee-4' && r.leaveTypeId == 'leave-type-annual',
    );
    expect(annual.entitlement, 30);
    expect(annual.available, 30);
  });

  test(
    'team attendance classifies approved leave instead of not started',
    () async {
      await approvedLeaveFor('employee-4');
      when(() => auth.checkSession()).thenAnswer((_) async => Success(manager));
      final read = WorkforceAttendanceReadRepository(
        db,
        auth,
        const AttendanceScopeResolver(),
        clock: FakeClock(DateTime.utc(2026, 9, 22, 12)),
        leave: repo,
      );
      final result = await read.read(date: today, scope: AttendanceScope.team);
      final page = (result as Success<WorkforceAttendancePage>).value;
      final report = page.items.firstWhere((i) => i.employeeId == 'employee-4');
      expect(report.classification, WorkdayClassification.approvedLeave);
    },
  );

  test('leave module registers non-parameterized branch defaults', () {
    final registry = createErpRegistry(
      DemoAuthRepository(MemorySessionStorage()),
      leaveRepository: repo,
      leaveTypeRepository: leaveTypeConfiguration(repo),
      leavePolicyRepository: leavePolicyConfiguration(repo),
      holidayRepository: holidayConfiguration(repo),
    );
    String? firstPath(List<RouteBase> routes) {
      for (final route in routes) {
        if (route is GoRoute) return route.path;
        if (route is ShellRouteBase) {
          final nested = firstPath(route.routes);
          if (nested != null) return nested;
        }
      }
      return null;
    }

    for (final destination in registry.registrations) {
      final path = firstPath(destination.routes);
      expect(path, isNotNull, reason: destination.navigation.id);
      expect(
        path!.contains(':'),
        isFalse,
        reason: '${destination.navigation.id} -> $path',
      );
    }

    // Constructing the router mirrors the runtime assertion that a branch
    // default location is not a parameterized route.
    final router = createAppRouter(
      authBloc: AuthBloc(DemoAuthRepository(MemorySessionStorage())),
      authRepository: DemoAuthRepository(MemorySessionStorage()),
      refresh: ValueNotifier(0),
      registry: registry,
    );
    expect(router, isNotNull);
    router.dispose();
  });

  test('team attendance classifies a company holiday', () async {
    when(() => auth.checkSession()).thenAnswer((_) async => Success(manager));
    final read = WorkforceAttendanceReadRepository(
      db,
      auth,
      const AttendanceScopeResolver(),
      clock: FakeClock(DateTime.utc(2026, 12, 25, 12)),
      leave: repo,
    );
    final result = await read.read(
      date: DateTime.utc(2026, 12, 25),
      scope: AttendanceScope.team,
    );
    final page = (result as Success<WorkforceAttendancePage>).value;
    expect(page.items, isNotEmpty);
    expect(
      page.items.every(
        (i) => i.classification == WorkdayClassification.holiday,
      ),
      isTrue,
    );
  });
}
