import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/bootstrap/demo_attendance_seed.dart';
import 'package:modular_erp/bootstrap/demo_configuration_seed.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/features/employees/data/employee_seed.dart';
import 'package:modular_erp/features/attendance/data/attendance_local_data_source.dart';
import 'package:modular_erp/features/attendance/domain/attendance_history.dart';
import 'package:modular_erp/features/attendance/domain/attendance_models.dart';
import 'package:modular_erp/features/attendance/domain/attendance_summary_calculator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/features/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/features/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/features/employees/data/employee_dao.dart';
import 'package:modular_erp/features/employees/data/local_employee_repository.dart';
import 'package:modular_erp/features/employees/data/account_provisioning_repository.dart';
import 'package:modular_erp/features/attendance/data/local_attendance_repository.dart';
import 'package:modular_erp/features/attendance/domain/attendance_context_resolver.dart';
import 'package:modular_erp/features/attendance/domain/attendance_repository.dart';
import 'package:modular_erp/features/attendance/domain/attendance_engine.dart';
import 'package:modular_erp/features/attendance/domain/shift_workday_resolver.dart';
import 'attendance_test.dart' show FakeClock, MockAuth;

void main() {
  late AppDatabase db;
  final clock = FakeClock(DateTime.utc(2026, 9, 18, 12));
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedEmployees(db);
    await seedAttendanceConfiguration(db);
  });
  tearDown(() async => db.close());
  test(
    'demo assignments and two months are ready without GPS or API',
    () async {
      await seedDemoAttendance(db, enabled: true, clock: clock);
      final employee = await (db.select(
        db.workforceEmployees,
      )..where((t) => t.id.equals('employee-employee'))).getSingle();
      expect(employee.shiftId, 'shift-attendance-demo');
      expect(employee.attendancePolicyId, 'policy-attendance-demo');
      final policy = await (db.select(
        db.attendancePolicyRecords,
      )..where((t) => t.id.equals(employee.attendancePolicyId!))).getSingle();
      expect(policy.requireLocation, false);
      final local = AttendanceLocalDataSource(db);
      for (final month in [8, 9]) {
        final data = await local.history(
          'demo-company',
          'employee-employee',
          AttendanceHistoryQuery(year: 2026, month: month, pageSize: 100),
          clock.now(),
        );
        expect(data.total, greaterThan(10));
        expect(data.summary.work, greaterThan(Duration.zero));
        expect(
          data.summary.counts[AttendanceHistoryStatus.late],
          greaterThan(0),
        );
        for (final item in data.items) {
          final day = (await local.byId(
            'demo-company',
            'employee-employee',
            item.id,
          ))!;
          final events = await local.events(
            'demo-company',
            'employee-employee',
            item.id,
          );
          final summary =
              (const AttendanceSummaryCalculator().calculate(
                        events,
                        clock.now(),
                      )
                      as Success<AttendanceSummary>)
                  .value;
          expect(day.totalWorkDuration, summary.workDuration);
          expect(day.totalBreakDuration, summary.breakDuration);
          expect(day.syncStatus, AttendanceSyncStatus.synced);
        }
      }
      expect(
        await local.forDate(
          'demo-company',
          'employee-employee',
          DateTime.utc(2026, 9, 18),
        ),
        null,
      );
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    },
  );
  test(
    'seeded employee can punch and take breaks without GPS or API',
    () async {
      await seedDemoAttendance(db, enabled: true, clock: clock);
      final self = DemoAuthSource().accounts
          .firstWhere((a) => a.context.user.role == AppRole.employee)
          .context;
      final auth = MockAuth();
      when(() => auth.checkSession()).thenAnswer((_) async => Success(self));
      final repo = LocalAttendanceRepository(
        AttendanceLocalDataSource(db),
        auth,
        AttendanceContextResolver(
          LocalEmployeeRepository(
            EmployeeDao(db),
            LocalAccountProvisioningRepository(db),
          ),
          const ShiftWorkdayResolver(FixedOffsetCompanyTimeService()),
        ),
        clock,
        const UnconfiguredAttendanceRemote(),
        authority: AttendanceAuthority.demoLocal,
      );
      expect(
        await repo.getCurrentAttendance(),
        isA<Success<AttendanceContext>>(),
      );
      for (final type in [
        AttendanceEventType.punchIn,
        AttendanceEventType.breakStart,
        AttendanceEventType.breakEnd,
        AttendanceEventType.punchOut,
      ]) {
        final result = await repo.execute(
          AttendanceCommand(
            type: type,
            requestId: const Uuid().v4(),
            expectedUserId: self.user.id,
            deviceTimestamp: clock.now(),
            source: AttendanceEventSource.web,
          ),
        );
        expect(result, isA<Success<AttendanceMutationResult>>());
        clock.time = clock.time.add(const Duration(minutes: 1));
      }
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    },
  );
  test('restarting preserves edits and does not duplicate records', () async {
    await seedDemoAttendance(db, enabled: true, clock: clock);
    final before = await db.select(db.attendanceEvents).get();
    await db.customStatement(
      "UPDATE workforce_employees SET shift_id='shift-night',attendance_policy_id='policy-office' WHERE id='employee-employee'",
    );
    await seedDemoAttendance(db, enabled: true, clock: clock);
    expect((await db.select(db.attendanceEvents).get()).length, before.length);
    final employee = await (db.select(
      db.workforceEmployees,
    )..where((t) => t.id.equals('employee-employee'))).getSingle();
    expect(employee.shiftId, 'shift-night');
    expect(employee.attendancePolicyId, 'policy-office');
  });
  test('disabled demo mode creates no assignments or attendance', () async {
    await seedDemoAttendance(db, enabled: false, clock: clock);
    expect(await db.select(db.attendanceDays).get(), isEmpty);
    final employee = await (db.select(
      db.workforceEmployees,
    )..where((t) => t.id.equals('employee-employee'))).getSingle();
    expect(employee.shiftId, null);
  });
}

