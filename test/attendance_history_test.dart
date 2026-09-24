import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/modules/hr/demo/demo_configuration_seed.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/modules/hr/employees/data/employee_seed.dart';
import 'package:modular_erp/modules/hr/employees/data/employee_dao.dart';
import 'package:modular_erp/modules/hr/employees/data/local_employee_repository.dart';
import 'package:modular_erp/modules/hr/employees/data/account_provisioning_repository.dart';
import 'package:modular_erp/modules/hr/attendance/data/attendance_local_data_source.dart';
import 'package:modular_erp/modules/hr/attendance/data/local_attendance_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_history.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_context_resolver.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_history_bloc.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_day_details_bloc.dart';
import 'attendance_test.dart'
    show FakeClock, MockAuth, fixtureSnapshot, fixtureShift;
import 'employee_test.dart' show employeeContext, unwrap;

AttendanceDay record(
  int day, {
  String company = 'demo-company',
  String employee = 'employee-employee',
  bool late = false,
  bool open = false,
  bool onBreak = false,
  int month = 9,
  int year = 2026,
  bool overnight = false,
}) {
  final date = DateTime.utc(year, month, day),
      start = date.add(Duration(hours: overnight ? 22 : 9)),
      end = date.add(
        Duration(days: overnight ? 1 : 0, hours: overnight ? 7 : 18),
      );
  return AttendanceDay(
    id: '$company-$employee-$year-$month-$day',
    companyId: company,
    employeeId: employee,
    attendanceDate: date,
    snapshot: fixtureSnapshot(
      shift: fixtureShift(night: overnight),
    ).copyWith(scheduledStart: start, scheduledEnd: end),
    state: open
        ? (onBreak
              ? AttendanceWorkdayState.onBreak
              : AttendanceWorkdayState.working)
        : AttendanceWorkdayState.completed,
    punchInAt: start,
    punchOutAt: open ? null : end,
    workMilliseconds: open ? 999999999 : 8 * 3600000,
    breakMilliseconds: open ? 999999999 : 3600000,
    elapsedMilliseconds: open ? 999999999 : 9 * 3600000,
    status: late
        ? AttendanceDayStatus.late
        : (open ? AttendanceDayStatus.working : AttendanceDayStatus.completed),
    syncStatus: AttendanceSyncStatus.pending,
    createdAt: start,
    updatedAt: start,
  );
}

void main() {
  late AppDatabase db;
  late AttendanceLocalDataSource local;
  late LocalAttendanceRepository repo;
  late MockAuth auth;
  late AuthContext actor;
  late FakeClock clock;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedEmployees(db);
    await seedAttendanceConfiguration(db);
    local = AttendanceLocalDataSource(db);
    actor = employeeContext(DemoScenario.employee);
    auth = MockAuth();
    when(() => auth.checkSession()).thenAnswer((_) async => Success(actor));
    when(() => auth.sessionChanges).thenAnswer((_) => const Stream.empty());
    clock = FakeClock(DateTime.utc(2026, 9, 17, 12));
    repo = LocalAttendanceRepository(
      local,
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
    );
  });
  tearDown(() async => db.close());
  AttendanceHistoryQuery query({
    int month = 9,
    int year = 2026,
    int page = 0,
    int size = 25,
    Set<AttendanceHistoryStatus> statuses = const {},
    AttendanceHistorySort sort = AttendanceHistorySort.newest,
  }) => AttendanceHistoryQuery(
    year: year,
    month: month,
    page: page,
    pageSize: size,
    statuses: statuses,
    sort: sort,
  );
  test('empty month has zero totals and no invented absence', () async {
    final data = unwrap(await repo.getAttendanceHistory(query()));
    expect(data.total, 0);
    expect(data.summary.records, 0);
    expect(data.summary.work, Duration.zero);
  });
  test(
    'month query excludes foreign employee/company and adjacent months',
    () async {
      for (final day in [
        record(1),
        record(2, employee: 'foreign'),
        record(3, company: 'foreign'),
        record(31, month: 8),
        record(1, month: 10),
      ]) {
        await local.putDay(day);
      }
      final data = unwrap(await repo.getAttendanceHistory(query()));
      expect(data.items.map((d) => d.attendanceDate.day), [1]);
      expect(data.summary.records, 1);
    },
  );
  test(
    'pagination is bounded and summary covers all month unfiltered',
    () async {
      for (var i = 1; i <= 30; i++) {
        await local.putDay(record(i, late: i <= 2));
      }
      final data = unwrap(
        await repo.getAttendanceHistory(query(size: 7, page: 1)),
      );
      expect(data.items.length, 7);
      expect(data.items.first.attendanceDate.day, 23);
      expect(data.total, 30);
      expect(data.summary.work, const Duration(hours: 240));
      expect(data.summary.breaks, const Duration(hours: 30));
      expect(data.summary.averageWork, const Duration(hours: 8));
      final filtered = unwrap(
        await repo.getAttendanceHistory(
          query(statuses: {AttendanceHistoryStatus.late}),
        ),
      );
      expect(filtered.total, 2);
      expect(filtered.summary.records, 30);
    },
  );
  test('sort oldest and newest', () async {
    for (final i in [4, 2, 6]) {
      await local.putDay(record(i));
    }
    expect(
      unwrap(
        await repo.getAttendanceHistory(query()),
      ).items.map((d) => d.attendanceDate.day),
      [6, 4, 2],
    );
    expect(
      unwrap(
        await repo.getAttendanceHistory(
          query(sort: AttendanceHistorySort.oldest),
        ),
      ).items.map((d) => d.attendanceDate.day),
      [2, 4, 6],
    );
  });
  test(
    'open record after frozen shift end incomplete and excluded from totals',
    () async {
      await local.putDay(record(16, open: true, onBreak: true));
      final data = unwrap(
        await repo.getAttendanceHistory(
          query(statuses: {AttendanceHistoryStatus.incomplete}),
        ),
      );
      expect(data.total, 1);
      expect(data.summary.work, Duration.zero);
      expect(data.summary.completed, 0);
    },
  );
  test('current working record excluded from completed totals', () async {
    await local.putDay(record(17, open: true));
    final data = unwrap(await repo.getAttendanceHistory(query()));
    expect(data.summary.counts[AttendanceHistoryStatus.working], 1);
    expect(data.summary.work, Duration.zero);
  });
  test('overnight punch out belongs to original workday month', () async {
    final day = record(30, overnight: true);
    await local.putDay(day);
    expect(unwrap(await repo.getAttendanceHistory(query())).total, 1);
    expect(unwrap(await repo.getAttendanceHistory(query(month: 10))).total, 0);
  });
  test('December January boundaries', () async {
    await local.putDay(record(31, month: 12, year: 2025));
    await local.putDay(record(1, month: 1));
    expect(
      unwrap(
        await repo.getAttendanceHistory(query(month: 12, year: 2025)),
      ).total,
      1,
    );
    expect(unwrap(await repo.getAttendanceHistory(query(month: 1))).total, 1);
  });
  test('known foreign IDs return not found', () async {
    final day = record(1, employee: 'foreign');
    await local.putDay(day);
    expect(unwrap(await repo.getAttendanceDayById(day.id)), null);
  });
  test('historical snapshot survives current configuration edits', () async {
    final day = record(1);
    await local.putDay(day);
    await db.customStatement("UPDATE shift_records SET name='New live name'");
    expect(
      unwrap(await repo.getAttendanceDayById(day.id))!.day.snapshot.shift.name,
      'Shift',
    );
  });
  test('viewSelf is mandatory even for wider permissions', () async {
    actor = actor.copyWith(
      user: actor.user.copyWith(
        permissions: PermissionSet({AppPermission.attendanceViewAll}),
      ),
    );
    expect(
      await repo.getAttendanceHistory(query()),
      isA<Failed<AttendanceHistoryPageData>>(),
    );
    expect(
      await repo.getAttendanceDayById('anything'),
      isA<Failed<AttendanceDayDetails?>>(),
    );
  });
  test(
    'company date uses company timezone across UTC month boundary',
    () async {
      clock.time = DateTime.utc(2026, 8, 31, 22);
      expect(
        unwrap(await repo.getCompanyAttendanceDate()),
        DateTime.utc(2026, 9, 1),
      );
    },
  );
  test('invalid queries reject unbounded pages', () {
    expect(() => query(size: 101), throwsArgumentError);
    expect(() => query(month: 13), throwsArgumentError);
  });
  test('history watch reflects local writes', () async {
    final results = <AttendanceHistoryPageData>[];
    final sub = repo.watchAttendanceHistory(query()).listen((r) {
      if (r is Success<AttendanceHistoryPageData>) results.add(r.value);
    });
    await Future<void>.delayed(const Duration(milliseconds: 60));
    await local.putDay(record(2));
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(results.last.total, 1);
    await sub.cancel();
  });
  test(
    'history bloc starts, filters, navigates year and blocks future',
    () async {
      final bloc = AttendanceHistoryBloc(repo);
      final ready = bloc.stream.firstWhere((s) => !s.loading && s.data != null);
      bloc.add(const AttendanceHistoryStarted());
      await ready;
      expect(bloc.state.query!.month, 9);
      var next = bloc.stream.firstWhere(
        (s) => !s.loading && s.query?.month == 12,
      );
      bloc.add(AttendanceHistoryMonthChanged(DateTime.utc(2025, 12)));
      await next;
      expect(bloc.state.query!.year, 2025);
      next = bloc.stream.firstWhere(
        (s) => !s.loading && s.query!.statuses.isNotEmpty,
      );
      bloc.add(AttendanceHistoryFilterChanged({AttendanceHistoryStatus.late}));
      await next;
      bloc.add(AttendanceHistoryMonthChanged(DateTime.utc(2027)));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(bloc.state.query!.year, 2025);
      await bloc.close();
    },
  );
  test('details bloc distinguishes not found', () async {
    final bloc = AttendanceDayDetailsBloc(repo, 'missing');
    final ready = bloc.stream.firstWhere((s) => !s.loading);
    bloc.add(const AttendanceDayDetailsStarted());
    await ready;
    expect(bloc.state.notFound, true);
    await bloc.close();
  });
  test(
    'current day after scheduled end remains working, not a historical issue',
    () async {
      clock.time = DateTime.utc(2026, 9, 17, 23);
      await local.putDay(record(17, open: true));
      final data = unwrap(await repo.getAttendanceHistory(query()));
      expect(data.summary.counts[AttendanceHistoryStatus.working], 1);
      expect(data.items.single.status, AttendanceHistoryStatus.working);
    },
  );
  test(
    'overnight open record remains working until frozen scheduled end',
    () async {
      clock.time = DateTime.utc(2026, 9, 17, 6);
      await local.putDay(record(16, overnight: true, open: true));
      var data = unwrap(await repo.getAttendanceHistory(query()));
      expect(data.summary.counts[AttendanceHistoryStatus.working], 1);
      clock.time = DateTime.utc(2026, 9, 17, 8);
      data = unwrap(await repo.getAttendanceHistory(query()));
      expect(data.summary.counts[AttendanceHistoryStatus.incomplete], 1);
    },
  );
  test('unsupported company timezone has a typed failure', () async {
    actor = actor.copyWith(
      company: actor.company.copyWith(timezone: 'Europe/London'),
    );
    final r = await repo.getCompanyAttendanceDate();
    expect(
      (r as Failed<DateTime>).failure.code,
      AttendanceFailureCode.unsupportedTimezone.name,
    );
  });
  test(
    'permission revoked during read does not expose cached records',
    () async {
      await local.putDay(record(1));
      var checks = 0;
      when(() => auth.checkSession()).thenAnswer(
        (_) async => Success(
          ++checks == 1
              ? actor
              : actor.copyWith(
                  user: actor.user.copyWith(permissions: PermissionSet([])),
                ),
        ),
      );
      expect(
        await repo.getAttendanceHistory(query()),
        isA<Failed<AttendanceHistoryPageData>>(),
      );
    },
  );
  test('month predicate uses the existing composite index', () async {
    final plan = await db
        .customSelect(
          "EXPLAIN QUERY PLAN SELECT * FROM attendance_days WHERE company_id='demo-company' AND employee_id='employee-employee' AND attendance_date>='2026-09-01' AND attendance_date<'2026-10-01' ORDER BY attendance_date DESC LIMIT 25",
        )
        .get();
    expect(
      plan.map((r) => r.read<String>('detail')).join(' '),
      contains('USING INDEX'),
    );
  });
  for (final sync in AttendanceSyncStatus.values) {
    test('details retains original $sync and frozen snapshot', () async {
      final day = record(1).copyWith(syncStatus: sync);
      await local.putDay(day);
      final details = unwrap(await repo.getAttendanceDayById(day.id))!;
      expect(details.day.syncStatus, sync);
      expect(details.day.id, day.id);
      expect(
        details.issues.contains(AttendanceRecordIssue.serverRejected),
        sync == AttendanceSyncStatus.rejected,
      );
      expect(
        details.issues.contains(AttendanceRecordIssue.syncFailed),
        sync == AttendanceSyncStatus.failed,
      );
    });
  }
  test(
    'details exposes missing out and open break without a final summary',
    () async {
      final day = record(16, open: true, onBreak: true);
      await local.putDay(day);
      final details = unwrap(await repo.getAttendanceDayById(day.id))!;
      expect(details.status, AttendanceHistoryStatus.incomplete);
      expect(
        details.issues,
        containsAll([
          AttendanceRecordIssue.missingPunchOut,
          AttendanceRecordIssue.openBreak,
        ]),
      );
      expect(details.day.punchOutAt, null);
    },
  );
}
