import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/attendance/data/workforce_attendance_read_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_scope_resolver.dart';
import 'package:modular_erp/modules/hr/attendance/domain/workforce_attendance.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/modules/hr/employees/data/employee_seed.dart';
import 'package:modular_erp/modules/hr/demo/demo_attendance_seed.dart';
import 'package:modular_erp/modules/hr/demo/demo_configuration_seed.dart';
import 'package:modular_erp/modules/hr/demo/demo_workforce_seed.dart';
import 'attendance_test.dart' show FakeClock, MockAuth;
import 'employee_test.dart' show employeeContext;

void main() {
  late AppDatabase db;
  late MockAuth auth;
  late WorkforceAttendanceReadRepository repo;
  var actor = employeeContext(AppRole.manager);
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedEmployees(db);
    auth = MockAuth();
    when(() => auth.checkSession()).thenAnswer((_) async => Success(actor));
    repo = WorkforceAttendanceReadRepository(
      db,
      auth,
      const AttendanceScopeResolver(),
      clock: FakeClock(DateTime.utc(2026, 9, 18, 12)),
    );
  });
  tearDown(() async => db.close());

  test(
    'manager can read only direct reports, with bounded pagination',
    () async {
      actor = employeeContext(AppRole.manager);
      final result = await repo.read(
        date: DateTime.utc(2026, 9, 18),
        scope: AttendanceScope.team,
        filter: const WorkforceAttendanceFilter(pageSize: 3),
      );
      expect(result, isA<Success<WorkforceAttendancePage>>());
      final page = (result as Success<WorkforceAttendancePage>).value;
      expect(page.total, 10);
      expect(page.items.length, 3);
      expect(
        page.items.every(
          (e) => e.attendanceState == WorkforceAttendanceState.noSchedule,
        ),
        isTrue,
      );
      expect(page.items.any((e) => e.employeeId == 'employee-hr'), isFalse);
    },
  );

  test('team search and company scope are permission bound', () async {
    actor = employeeContext(AppRole.manager);
    final search = await repo.read(
      date: DateTime.utc(2026, 9, 18),
      scope: AttendanceScope.team,
      filter: const WorkforceAttendanceFilter(search: 'Noor'),
    );
    expect(
      (search as Success<WorkforceAttendancePage>).value.items.any(
        (e) => e.employeeId == 'employee-employee',
      ),
      isTrue,
    );
    expect(
      await repo.read(
        date: DateTime.utc(2026, 9, 18),
        scope: AttendanceScope.company,
      ),
      isA<Failed<WorkforceAttendancePage>>(),
    );
    actor = employeeContext(AppRole.hr);
    final company = await repo.read(
      date: DateTime.utc(2026, 9, 18),
      scope: AttendanceScope.company,
    );
    expect(
      (company as Success<WorkforceAttendancePage>).value.total,
      greaterThan(10),
    );
  });
  test(
    'demo workforce presents working, break, completed and not started',
    () async {
      await seedAttendanceConfiguration(db);
      final clock = FakeClock(DateTime.utc(2026, 9, 18, 12));
      await seedDemoAttendance(db, enabled: true, clock: clock);
      await seedDemoWorkforce(db, enabled: true, clock: clock);
      actor = employeeContext(AppRole.manager);
      final result = await repo.read(
        date: DateTime.utc(2026, 9, 18),
        scope: AttendanceScope.team,
      );
      final rows = (result as Success<WorkforceAttendancePage>).value;
      expect(rows.counts[WorkforceAttendanceState.working], greaterThan(0));
      expect(rows.counts[WorkforceAttendanceState.onBreak], greaterThan(0));
      expect(rows.counts[WorkforceAttendanceState.completed], greaterThan(0));
      expect(rows.counts[WorkforceAttendanceState.notStarted], greaterThan(0));
      final past = await repo.read(
        date: DateTime.utc(2026, 9, 16),
        scope: AttendanceScope.team,
      );
      expect(
        (past as Success<WorkforceAttendancePage>).value.items.any(
          (e) => e.attendanceState == WorkforceAttendanceState.noRecord,
        ),
        isTrue,
      );
      await seedDemoWorkforce(db, enabled: true, clock: clock);
      expect(
        (await db.select(db.attendanceDays).get()).length,
        greaterThan(100),
      );
    },
  );
  test(
    'combined filters, sorting and pagination use the same scoped rows',
    () async {
      await seedAttendanceConfiguration(db);
      await seedDemoAttendance(
        db,
        enabled: true,
        clock: FakeClock(DateTime.utc(2026, 9, 18, 12)),
      );
      await seedDemoWorkforce(
        db,
        enabled: true,
        clock: FakeClock(DateTime.utc(2026, 9, 18, 12)),
      );
      actor = employeeContext(AppRole.manager);
      final all =
          (await repo.read(
                    date: DateTime.utc(2026, 9, 18),
                    scope: AttendanceScope.team,
                    filter: const WorkforceAttendanceFilter(pageSize: 100),
                  )
                  as Success<WorkforceAttendancePage>)
              .value;
      final candidate = all.items.firstWhere((item) => item.shiftName != null);
      final employee = await (db.select(
        db.workforceEmployees,
      )..where((e) => e.id.equals(candidate.employeeId))).getSingle();
      final filtered =
          (await repo.read(
                    date: DateTime.utc(2026, 9, 18),
                    scope: AttendanceScope.team,
                    filter: WorkforceAttendanceFilter(
                      search: candidate.employeeCode,
                      departmentId: employee.departmentId,
                      shiftId: employee.shiftId,
                      workLocationId: employee.workLocationId,
                      status: candidate.attendanceState,
                    ),
                  )
                  as Success<WorkforceAttendancePage>)
              .value;
      expect(filtered.total, 1);
      expect(filtered.items.single.employeeId, candidate.employeeId);
      final first =
          (await repo.read(
                    date: DateTime.utc(2026, 9, 18),
                    scope: AttendanceScope.team,
                    filter: const WorkforceAttendanceFilter(
                      pageSize: 1,
                      sort: WorkforceAttendanceSort.nameDescending,
                    ),
                  )
                  as Success<WorkforceAttendancePage>)
              .value;
      final second =
          (await repo.read(
                    date: DateTime.utc(2026, 9, 18),
                    scope: AttendanceScope.team,
                    filter: const WorkforceAttendanceFilter(
                      page: 1,
                      pageSize: 1,
                      sort: WorkforceAttendanceSort.nameDescending,
                    ),
                  )
                  as Success<WorkforceAttendancePage>)
              .value;
      expect(first.total, second.total);
      expect(
        first.items.single.employeeId,
        isNot(second.items.single.employeeId),
      );
    },
  );
}
