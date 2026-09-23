import 'package:drift/drift.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_scope_resolver.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_history.dart';
import 'attendance_local_data_source.dart';
import 'local_attendance_correction_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/hr/attendance/domain/workforce_attendance.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_repository.dart';

/// A bounded, joined read projection. No per-row employee/event reads.
class WorkforceAttendanceReadRepository {
  WorkforceAttendanceReadRepository(
    this.db,
    this.auth,
    this.scopes, {
    this.clock = const SystemAppClock(),
    this.time = const FixedOffsetCompanyTimeService(),
    this.leave,
  });
  final AppDatabase db;
  final AuthRepository auth;
  final AttendanceScopeResolver scopes;
  final AppClock clock;
  final CompanyTimeService time;
  final LeaveRepository? leave;

  Failed<T> _fail<T>(String code) =>
      Failed(Failure(code: code, kind: FailureKind.invalidData));

  Future<Result<DateTime>> companyToday() async {
    final session = await auth.checkSession();
    if (session is Failed<AuthContext?>) return Failed(session.failure);
    final actor = (session as Success<AuthContext?>).value;
    if (actor == null) return _fail('attendanceUnavailable');
    final wall = time.localWallTime(
      clock.now().toUtc(),
      actor.company.timezone,
    );
    if (wall is Failed<DateTime>) return Failed(wall.failure);
    final value = (wall as Success<DateTime>).value;
    return Success(DateTime.utc(value.year, value.month, value.day));
  }

  Future<Result<WorkforceAttendancePage>> read({
    required DateTime date,
    WorkforceAttendanceFilter filter = const WorkforceAttendanceFilter(),
    AttendanceScope? scope,
  }) async {
    final session = await auth.checkSession();
    if (session is Failed<AuthContext?>) return Failed(session.failure);
    final actor = (session as Success<AuthContext?>).value;
    if (actor == null ||
        actor.user.status != AccountStatus.active ||
        !actor.company.enabledModules.contains('attendance')) {
      return _fail('attendanceUnavailable');
    }
    final permissions = PermissionChecker(actor.user.permissions);
    final resolved = scope ?? scopes.resolve(actor);
    if (resolved == AttendanceScope.company &&
        !permissions.can(AppPermission.attendanceViewAll)) {
      return _fail('attendancePermissionDenied');
    }
    if (resolved == AttendanceScope.team &&
        !permissions.canAny({
          AppPermission.attendanceViewTeam,
          AppPermission.attendanceViewAll,
        })) {
      return _fail('attendancePermissionDenied');
    }
    if (resolved == AttendanceScope.self &&
        !permissions.can(AppPermission.attendanceViewSelf)) {
      return _fail('attendancePermissionDenied');
    }
    if ((resolved == AttendanceScope.self ||
            resolved == AttendanceScope.team) &&
        actor.employeeReference == null) {
      return _fail('attendanceNotLinked');
    }
    if (filter.page < 0 || filter.pageSize < 1 || filter.pageSize > 100) {
      return _fail('attendanceInvalidPage');
    }
    final now = clock.now().toUtc();
    final wall = time.localWallTime(now, actor.company.timezone);
    if (wall is Failed<DateTime>) return Failed(wall.failure);
    final local = (wall as Success<DateTime>).value;
    final today = DateTime.utc(local.year, local.month, local.day);
    if (date.isAfter(today)) return _fail('attendanceFutureDate');
    final sameDay =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    final weekdayMask = 1 << (date.weekday - 1);
    const base = '''FROM workforce_employees e
LEFT JOIN workforce_departments d ON d.id=e.department_id AND d.company_id=e.company_id
LEFT JOIN workforce_designations des ON des.id=e.designation_id AND des.company_id=e.company_id
LEFT JOIN shift_records s ON s.id=e.shift_id AND s.company_id=e.company_id
LEFT JOIN work_location_records w ON w.id=e.work_location_id AND w.company_id=e.company_id
LEFT JOIN attendance_days a ON a.company_id=e.company_id AND a.employee_id=e.id AND a.attendance_date=?
LEFT JOIN (SELECT company_id,employee_id,attendance_day_id,COUNT(*) n FROM attendance_correction_requests WHERE status='pending' GROUP BY company_id,employee_id,attendance_day_id) c ON c.company_id=e.company_id AND c.employee_id=e.id AND c.attendance_day_id=a.id''';
    const state = '''CASE WHEN a.id IS NULL THEN
 CASE WHEN s.id IS NULL OR s.status!='active' OR (s.working_day_mask & ?) = 0 THEN 'noSchedule'
      WHEN ?=1 THEN 'notStarted' ELSE 'noRecord' END
 WHEN a.state='completed' THEN 'completed'
 WHEN a.state='onBreak' THEN CASE WHEN ?=1 THEN 'onBreak' ELSE 'incomplete' END
 WHEN a.state='working' THEN CASE WHEN ?=1 THEN 'working' ELSE 'incomplete' END
 ELSE 'noRecord' END''';
    final conditions = <String>['e.company_id=?', "e.status='active'"];
    final conditionsVars = <Variable<Object>>[Variable(actor.company.id)];
    if (resolved == AttendanceScope.self) {
      conditions.add('e.id=?');
      conditionsVars.add(Variable(actor.employeeReference!.id));
    } else if (resolved == AttendanceScope.team) {
      conditions.add('e.manager_id=?');
      conditionsVars.add(Variable(actor.employeeReference!.id));
    }
    if (filter.departmentId != null) {
      conditions.add('e.department_id=?');
      conditionsVars.add(Variable(filter.departmentId));
    }
    if (filter.shiftId != null) {
      conditions.add('e.shift_id=?');
      conditionsVars.add(Variable(filter.shiftId));
    }
    if (filter.workLocationId != null) {
      conditions.add('e.work_location_id=?');
      conditionsVars.add(Variable(filter.workLocationId));
    }
    final search = filter.search.trim();
    if (search.isNotEmpty) {
      conditions.add(
        "(lower(e.first_name||' '||e.last_name) LIKE ? OR lower(e.employee_code) LIKE ?)",
      );
      conditionsVars.addAll([
        Variable('%${search.toLowerCase()}%'),
        Variable('%${search.toLowerCase()}%'),
      ]);
    }
    final projected =
        '''SELECT e.id employee_id,e.employee_code,e.first_name,e.last_name,
 d.name department,des.name designation,s.name shift_name,w.name location_name,
 a.id day_id,a.state raw_state,a.status day_status,a.punch_in_milliseconds,
 a.punch_out_milliseconds,a.work_milliseconds,a.break_milliseconds,a.sync_status,
 COALESCE(c.n,0) pending_count,$state attendance_state $base
 WHERE ${conditions.join(' AND ')}''';
    final vars = <Variable<Object>>[
      Variable(weekdayMask),
      Variable(sameDay ? 1 : 0),
      Variable(sameDay ? 1 : 0),
      Variable(sameDay ? 1 : 0),
      Variable(date.toIso8601String().substring(0, 10)),
      ...conditionsVars,
    ];
    final statusClause = filter.status == null
        ? ''
        : ' WHERE attendance_state=?';
    final filteredVars = <Variable<Object>>[
      ...vars,
      if (filter.status != null) Variable(filter.status!.name),
    ];
    final tables = <ResultSetImplementation<dynamic, dynamic>>{
      db.workforceEmployees,
      db.workforceDepartments,
      db.workforceDesignations,
      db.shiftRecords,
      db.workLocationRecords,
      db.attendanceDays,
      db.attendanceCorrectionRequests,
    };
    final count = await db
        .customSelect(
          'SELECT COUNT(*) n FROM ($projected)$statusClause',
          variables: filteredVars,
          readsFrom: tables,
        )
        .getSingle();
    final groups = await db
        .customSelect(
          'SELECT attendance_state, COUNT(*) n FROM ($projected) GROUP BY attendance_state',
          variables: vars,
          readsFrom: tables,
        )
        .get();
    final lateRow = await db
        .customSelect(
          "SELECT COUNT(*) n FROM ($projected) WHERE day_status='late'",
          variables: vars,
          readsFrom: tables,
        )
        .getSingle();
    final counts = {
      for (final row in groups)
        WorkforceAttendanceState.values.byName(
          row.read<String>('attendance_state'),
        ): row.read<int>(
          'n',
        ),
    };
    final order = switch (filter.sort) {
      WorkforceAttendanceSort.nameAscending =>
        'first_name COLLATE NOCASE, last_name COLLATE NOCASE, employee_id',
      WorkforceAttendanceSort.nameDescending =>
        'first_name COLLATE NOCASE DESC, last_name COLLATE NOCASE DESC, employee_id',
      WorkforceAttendanceSort.code => 'employee_code, employee_id',
      WorkforceAttendanceSort.status =>
        'attendance_state, first_name COLLATE NOCASE, employee_id',
    };
    final rows = await db
        .customSelect(
          'SELECT * FROM ($projected)$statusClause ORDER BY $order LIMIT ? OFFSET ?',
          variables: [
            ...filteredVars,
            Variable(filter.pageSize),
            Variable(filter.page * filter.pageSize),
          ],
          readsFrom: tables,
        )
        .get();
    final latest = await auth.checkSession();
    if (latest is! Success<AuthContext?> ||
        latest.value?.user.id != actor.user.id ||
        latest.value?.company.id != actor.company.id) {
      return _fail('attendanceSessionChanged');
    }
    var leaveIds = <String>{};
    var holiday = false;
    if (sameDay && leave != null) {
      final ids = rows
          .map((r) => r.read<String>('employee_id'))
          .toList(growable: false);
      final leaveResult = await leave!.employeesOnApprovedLeave(
        actor,
        date,
        employeeIds: ids,
      );
      if (leaveResult is Success<Set<String>>) leaveIds = leaveResult.value;
      final holidayResult = await leave!.companyHolidayOn(actor, date);
      if (holidayResult is Success<bool>) holiday = holidayResult.value;
    }
    final items = rows
        .map((r) {
          final employeeId = r.read<String>('employee_id');
          return WorkforceAttendanceItem(
            employeeId: employeeId,
            employeeCode: r.read<String>('employee_code'),
            employeeName:
                '${r.read<String>('first_name')} ${r.read<String>('last_name')}'
                    .trim(),
            department: r.readNullable<String>('department'),
            designation: r.readNullable<String>('designation'),
            shiftName: r.readNullable<String>('shift_name'),
            workLocationName: r.readNullable<String>('location_name'),
            attendanceDayId: r.readNullable<String>('day_id'),
            attendanceState: WorkforceAttendanceState.values.byName(
              r.read<String>('attendance_state'),
            ),
            attendanceStatus: r.readNullable<String>('day_status') == null
                ? null
                : AttendanceDayStatus.values.byName(
                    r.read<String>('day_status'),
                  ),
            punchInAt: _instant(r.readNullable<int>('punch_in_milliseconds')),
            punchOutAt: _instant(r.readNullable<int>('punch_out_milliseconds')),
            workDuration: Duration(
              milliseconds: r.readNullable<int>('work_milliseconds') ?? 0,
            ),
            breakDuration: Duration(
              milliseconds: r.readNullable<int>('break_milliseconds') ?? 0,
            ),
            isLate: r.readNullable<String>('day_status') == 'late',
            hasIssue: r.read<String>('attendance_state') == 'incomplete',
            hasPendingCorrection: r.read<int>('pending_count') > 0,
            syncStatus: r.readNullable<String>('sync_status') == null
                ? null
                : AttendanceSyncStatus.values.byName(
                    r.read<String>('sync_status'),
                  ),
            classification: holiday
                ? WorkdayClassification.holiday
                : leaveIds.contains(employeeId)
                ? WorkdayClassification.approvedLeave
                : null,
          );
        })
        .toList(growable: false);
    return Success(
      WorkforceAttendancePage(
        items: items,
        total: count.read<int>('n'),
        scope: resolved,
        counts: counts,
        lateCount: lateRow.read<int>('n'),
      ),
    );
  }

  DateTime? _instant(int? value) => value == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);

  Future<Result<WorkforceFilterOptions>> options(AttendanceScope scope) async {
    final session = await auth.checkSession();
    if (session is Failed<AuthContext?>) return Failed(session.failure);
    final actor = (session as Success<AuthContext?>).value;
    if (actor == null) return _fail('attendanceUnavailable');
    final p = PermissionChecker(actor.user.permissions);
    if (scope == AttendanceScope.company &&
        !p.can(AppPermission.attendanceViewAll)) {
      return _fail('attendancePermissionDenied');
    }
    if (scope == AttendanceScope.team &&
        !p.canAny({
          AppPermission.attendanceViewTeam,
          AppPermission.attendanceViewAll,
        })) {
      return _fail('attendancePermissionDenied');
    }
    if (scope == AttendanceScope.self &&
        !p.can(AppPermission.attendanceViewSelf)) {
      return _fail('attendancePermissionDenied');
    }
    final clause = scope == AttendanceScope.team
        ? ' AND e.manager_id=?'
        : scope == AttendanceScope.self
        ? ' AND e.id=?'
        : '';
    final vars = <Variable<Object>>[
      Variable(actor.company.id),
      if (scope == AttendanceScope.team || scope == AttendanceScope.self)
        Variable(actor.employeeReference?.id ?? ''),
    ];
    Future<List<WorkforceFilterOption>> select(
      String table,
      String column,
    ) async {
      final rows = await db
          .customSelect(
            '''SELECT DISTINCT x.id id,x.name name
        FROM workforce_employees e JOIN $table x ON x.id=e.$column
        AND x.company_id=e.company_id WHERE e.company_id=? $clause
        ORDER BY x.name COLLATE NOCASE''',
            variables: vars,
            readsFrom: {
              db.workforceEmployees,
              db.workforceDepartments,
              db.shiftRecords,
              db.workLocationRecords,
            },
          )
          .get();
      return rows
          .map(
            (r) => WorkforceFilterOption(
              r.read<String>('id'),
              r.read<String>('name'),
            ),
          )
          .toList(growable: false);
    }

    return Success(
      WorkforceFilterOptions(
        departments: await select('workforce_departments', 'department_id'),
        shifts: await select('shift_records', 'shift_id'),
        locations: await select('work_location_records', 'work_location_id'),
      ),
    );
  }

  Stream<Result<WorkforceAttendancePage>> watch({
    required DateTime date,
    WorkforceAttendanceFilter filter = const WorkforceAttendanceFilter(),
    AttendanceScope? scope,
  }) async* {
    await for (final _
        in db
            .customSelect(
              'SELECT COUNT(*) n FROM attendance_days',
              readsFrom: {
                db.attendanceDays,
                db.workforceEmployees,
                db.shiftRecords,
                db.workLocationRecords,
                db.attendanceCorrectionRequests,
              },
            )
            .watch()) {
      yield await read(date: date, filter: filter, scope: scope);
    }
  }

  Future<Result<AttendanceDayDetails?>> readDay({
    required String employeeId,
    required String dayId,
    required AttendanceScope scope,
  }) async {
    final session = await auth.checkSession();
    if (session is Failed<AuthContext?>) return Failed(session.failure);
    final actor = (session as Success<AuthContext?>).value;
    if (actor == null ||
        actor.user.status != AccountStatus.active ||
        !actor.company.enabledModules.contains('attendance')) {
      return _fail('attendanceUnavailable');
    }
    final p = PermissionChecker(actor.user.permissions);
    if (scope == AttendanceScope.company &&
        !p.can(AppPermission.attendanceViewAll)) {
      return _fail('attendancePermissionDenied');
    }
    if (scope == AttendanceScope.team &&
        !p.canAny({
          AppPermission.attendanceViewTeam,
          AppPermission.attendanceViewAll,
        })) {
      return _fail('attendancePermissionDenied');
    }
    if (scope == AttendanceScope.self &&
        (!p.can(AppPermission.attendanceViewSelf) ||
            actor.employeeReference?.id != employeeId)) {
      return _fail('attendancePermissionDenied');
    }
    final employee =
        await (db.select(db.workforceEmployees)..where(
              (t) =>
                  t.companyId.equals(actor.company.id) &
                  t.id.equals(employeeId),
            ))
            .getSingleOrNull();
    if (employee == null) return const Success(null);
    if (scope == AttendanceScope.team &&
        employee.managerId != actor.employeeReference?.id) {
      return _fail('attendancePermissionDenied');
    }
    final local = AttendanceLocalDataSource(db);
    final day = await local.byId(actor.company.id, employeeId, dayId);
    if (day == null) return const Success(null);
    final original = await local.events(actor.company.id, employeeId, dayId);
    final corrections = LocalAttendanceCorrectionRepository(db, auth, clock);
    final effective = await corrections.effectiveEvents(
      actor.company.id,
      employeeId,
      dayId,
    );
    final latest = await auth.checkSession();
    if (latest is! Success<AuthContext?> ||
        latest.value?.user.id != actor.user.id ||
        latest.value?.company.id != actor.company.id) {
      return _fail('attendanceSessionChanged');
    }
    return Success(
      AttendanceDayDetails(
        day,
        effective,
        clock.now().toUtc(),
        originalEvents: original,
        corrections: await corrections.approvedForDay(
          actor.company.id,
          employeeId,
          dayId,
        ),
      ),
    );
  }
}
