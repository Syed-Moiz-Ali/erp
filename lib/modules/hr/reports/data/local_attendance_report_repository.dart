import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/access_scope_resolver.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/hr/attendance/domain/workforce_attendance.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/modules/hr/reports/domain/attendance_report_models.dart';
import 'package:modular_erp/modules/hr/reports/domain/attendance_report_repository.dart';

/// SQL projections use the effective totals cached on AttendanceDays by
/// correction approval. Pending requests affect indicators, never totals.
class LocalAttendanceReportRepository implements AttendanceReportRepository {
  const LocalAttendanceReportRepository(
    this.db,
    this.auth, {
    this.clock = const SystemAppClock(),
    this.time = const FixedOffsetCompanyTimeService(),
  });
  final AppDatabase db;
  final AuthRepository auth;
  final AppClock clock;
  final CompanyTimeService time;

  Failed<T> _fail<T>(String code) =>
      Failed(Failure(code: code, kind: FailureKind.invalidData));

  Future<Result<(AuthContext, AttendanceScope, DateTime)>> _access() async {
    final result = await auth.checkSession();
    if (result is Failed<AuthContext?>) return Failed(result.failure);
    final actor = (result as Success<AuthContext?>).value;
    if (actor == null ||
        actor.user.status != AccountStatus.active ||
        !actor.company.enabledModules.contains('reports') ||
        !actor.company.enabledModules.contains('attendance')) {
      return _fail('reportUnavailable');
    }
    final permissions = actor.user.permissions;
    if (!permissions.contains(AppPermission.attendanceReportView)) {
      return _fail('reportPermissionDenied');
    }
    final scope = switch (const AccessScopeResolver().resolve(
      permissions,
      all: AppPermission.attendanceViewAll,
      team: AppPermission.attendanceViewTeam,
    )) {
      PermissionScope.all => AttendanceScope.company,
      PermissionScope.team => AttendanceScope.team,
      _ => null,
    };
    if (scope == null ||
        (scope == AttendanceScope.team && actor.employeeReference == null)) {
      return _fail('reportPermissionDenied');
    }
    final wall = time.localWallTime(
      clock.now().toUtc(),
      actor.company.timezone,
    );
    if (wall is Failed<DateTime>) return Failed(wall.failure);
    final local = (wall as Success<DateTime>).value;
    return Success((
      actor,
      scope,
      DateTime.utc(local.year, local.month, local.day),
    ));
  }

  @override
  Future<Result<DateTime>> companyToday() async {
    final access = await _access();
    if (access is Failed<(AuthContext, AttendanceScope, DateTime)>) {
      return Failed(access.failure);
    }
    return Success(
      (access as Success<(AuthContext, AttendanceScope, DateTime)>).value.$3,
    );
  }

  @override
  Future<Result<AttendanceReportOptions>> options(
    AttendanceReportFilter filter,
  ) async {
    final access = await _access();
    if (access is Failed<(AuthContext, AttendanceScope, DateTime)>) {
      return Failed(access.failure);
    }
    final (actor, scope, today) =
        (access as Success<(AuthContext, AttendanceScope, DateTime)>).value;
    if (filter.scope != scope || filter.to.isAfter(today)) {
      return _fail('reportInvalidFilter');
    }
    final where = scope == AttendanceScope.team ? ' AND e.manager_id=?' : '';
    final vars = <Variable<Object>>[
      Variable(actor.company.id),
      Variable(_date(filter.from)),
      Variable(_date(filter.to)),
      if (scope == AttendanceScope.team) Variable(actor.employeeReference!.id),
    ];
    final rows = await db
        .customSelect(
          '''
SELECT DISTINCT e.id employee_id,e.employee_code,
 e.first_name||' '||e.last_name employee_name,
 e.department_id,COALESCE(d.name,'') department,
 a.shift_id,COALESCE(json_extract(a.configuration_snapshot,'\$.shift.name'),'') shift_name,
 a.work_location_id,COALESCE(json_extract(a.configuration_snapshot,'\$.workLocation.name'),'') location_name
FROM attendance_days a JOIN workforce_employees e
 ON e.id=a.employee_id AND e.company_id=a.company_id
LEFT JOIN workforce_departments d ON d.id=e.department_id AND d.company_id=e.company_id
WHERE a.company_id=? AND a.attendance_date>=? AND a.attendance_date<=?$where
ORDER BY employee_name COLLATE NOCASE''',
          variables: vars,
          readsFrom: {
            db.attendanceDays,
            db.workforceEmployees,
            db.workforceDepartments,
          },
        )
        .get();
    List<AttendanceReportOption> unique(String id, String name) {
      final map = <String, String>{};
      for (final row in rows) {
        final key = row.readNullable<String>(id);
        if (key != null && key.isNotEmpty) map[key] = row.read<String>(name);
      }
      return map.entries
          .map((e) => AttendanceReportOption(e.key, e.value))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    }

    return Success(
      AttendanceReportOptions(
        employees: unique('employee_id', 'employee_name'),
        departments: unique('department_id', 'department'),
        shifts: unique('shift_id', 'shift_name'),
        locations: unique('work_location_id', 'location_name'),
      ),
    );
  }

  @override
  Future<Result<AttendanceReportData>> load(
    AttendanceReportFilter filter,
    AttendanceReportType type, {
    AttendanceReportSort sort = AttendanceReportSort.newest,
    int page = 0,
    int pageSize = 25,
  }) => _read(filter, type, sort, page, pageSize, false);

  @override
  Future<Result<AttendanceReportData>> exportData(
    AttendanceReportFilter filter,
    AttendanceReportType type, {
    AttendanceReportSort sort = AttendanceReportSort.newest,
  }) => _read(filter, type, sort, 0, -1, true);

  Future<Result<AttendanceReportData>> _read(
    AttendanceReportFilter filter,
    AttendanceReportType type,
    AttendanceReportSort sort,
    int page,
    int pageSize,
    bool all,
  ) async {
    final access = await _access();
    if (access is Failed<(AuthContext, AttendanceScope, DateTime)>) {
      return Failed(access.failure);
    }
    final (actor, scope, today) =
        (access as Success<(AuthContext, AttendanceScope, DateTime)>).value;
    if (filter.scope != scope ||
        page < 0 ||
        (!all && (pageSize < 1 || pageSize > 100)) ||
        filter.from.isAfter(filter.to) ||
        filter.to.isAfter(today) ||
        filter.to.difference(filter.from).inDays > 366) {
      return _fail('reportInvalidFilter');
    }
    final clauses = <String>[
      'a.company_id=?',
      'a.attendance_date>=?',
      'a.attendance_date<=?',
    ];
    final params = <Variable<Object>>[
      Variable(actor.company.id),
      Variable(_date(filter.from)),
      Variable(_date(filter.to)),
    ];
    if (scope == AttendanceScope.team) {
      clauses.add('e.manager_id=?');
      params.add(Variable(actor.employeeReference!.id));
    }
    void selected(Set<String> ids, String column) {
      if (ids.isEmpty) return;
      clauses.add('$column IN (${List.filled(ids.length, '?').join(',')})');
      params.addAll(ids.map(Variable.new));
    }

    selected(filter.employeeIds, 'e.id');
    selected(filter.departmentIds, 'e.department_id');
    selected(filter.shiftIds, 'a.shift_id');
    selected(filter.locationIds, 'a.work_location_id');
    selected(filter.statuses, 'a.status');
    final base =
        '''WITH records AS (
SELECT a.id day_id,a.attendance_date report_date,a.state,a.status,
 a.sync_status,a.punch_in_milliseconds,a.punch_out_milliseconds,
 a.work_milliseconds work_ms,a.break_milliseconds break_ms,
 a.configuration_snapshot,e.id employee_id,e.employee_code,e.first_name,
 e.last_name,COALESCE(d.name,'') department,
 COALESCE(c.pending_count,0) pending_count,
 COALESCE(c.approved_count,0) approved_count,
 CASE WHEN (a.state!='completed' AND a.attendance_date<?)
    OR a.sync_status IN ('failed','rejected')
    OR COALESCE(c.pending_count,0)>0 THEN 1 ELSE 0 END issue_flag,
 CASE WHEN a.state!='completed' AND a.attendance_date<? THEN 1 ELSE 0 END incomplete_flag
FROM attendance_days a
JOIN workforce_employees e ON e.id=a.employee_id AND e.company_id=a.company_id
LEFT JOIN workforce_departments d ON d.id=e.department_id AND d.company_id=e.company_id
LEFT JOIN (SELECT company_id,attendance_day_id,
 SUM(CASE WHEN status='pending' THEN 1 ELSE 0 END) pending_count,
 SUM(CASE WHEN status='approved' THEN 1 ELSE 0 END) approved_count
 FROM attendance_correction_requests GROUP BY company_id,attendance_day_id) c
 ON c.company_id=a.company_id AND c.attendance_day_id=a.id
WHERE ${clauses.join(' AND ')}), scoped AS (
SELECT * FROM records WHERE 1=1
${filter.hasIssues == null ? '' : 'AND issue_flag=${filter.hasIssues! ? 1 : 0}'}
${filter.hasCorrections == null ? '' : 'AND (pending_count+approved_count)${filter.hasCorrections! ? '>' : '='}0'}
${switch (type) {
          AttendanceReportType.lateAttendance => "AND status='late'",
          AttendanceReportType.breakAnalysis => 'AND break_ms>0',
          AttendanceReportType.issues => 'AND issue_flag=1',
          _ => '',
        }}
)''';
    final vars = <Variable<Object>>[
      Variable(_date(today)),
      Variable(_date(today)),
      ...params,
    ];
    final reads = <ResultSetImplementation<dynamic, dynamic>>{
      db.attendanceDays,
      db.workforceEmployees,
      db.workforceDepartments,
      db.attendanceCorrectionRequests,
    };
    final grouped =
        type == AttendanceReportType.workHours ||
        type == AttendanceReportType.breakAnalysis ||
        type == AttendanceReportType.employeeSummary;
    final result = await db.transaction(() async {
      final summaryRow = await db
          .customSelect(
            '''$base
SELECT COUNT(*) recorded,COUNT(DISTINCT employee_id) employees,
 COALESCE(SUM(CASE WHEN state='completed' THEN 1 ELSE 0 END),0) completed,
 COALESCE(SUM(CASE WHEN status='late' THEN 1 ELSE 0 END),0) late,
 COALESCE(SUM(incomplete_flag),0) incomplete,
 COALESCE(SUM(work_ms),0) work_ms,
 COALESCE(SUM(break_ms),0) break_ms,
 COALESCE(SUM(pending_count),0) pending,
 COALESCE(SUM(issue_flag),0) issues FROM scoped''',
            variables: vars,
            readsFrom: reads,
          )
          .getSingle();
      int number(String name) => summaryRow.read<int>(name);
      final summary = AttendanceReportSummary(
        recordedDays: number('recorded'),
        completedDays: number('completed'),
        lateDays: number('late'),
        incompleteDays: number('incomplete'),
        employees: number('employees'),
        workMilliseconds: number('work_ms'),
        breakMilliseconds: number('break_ms'),
        pendingCorrections: number('pending'),
        issueDays: number('issues'),
      );
      final total = grouped ? summary.employees : summary.recordedDays;
      final trendRows = await db
          .customSelect(
            '''$base
SELECT report_date,COUNT(*) recorded,COALESCE(SUM(work_ms),0) work_ms,
 COALESCE(SUM(CASE WHEN state='completed' THEN 1 ELSE 0 END),0) completed,
 COALESCE(SUM(CASE WHEN status='late' THEN 1 ELSE 0 END),0) late,
 COALESCE(SUM(break_ms),0) break_ms,
 COALESCE(SUM(issue_flag),0) issues
FROM scoped GROUP BY report_date ORDER BY report_date''',
            variables: vars,
            readsFrom: reads,
          )
          .get();
      final distributionRow = await db
          .customSelect(
            '''$base
SELECT
 COALESCE(SUM(CASE WHEN issue_flag=1 THEN 1 ELSE 0 END),0) issues,
 COALESCE(SUM(CASE WHEN issue_flag=0 AND status='late' THEN 1 ELSE 0 END),0) late,
 COALESCE(SUM(CASE WHEN issue_flag=0 AND status!='late' AND state='completed' THEN 1 ELSE 0 END),0) completed,
 COALESCE(SUM(CASE WHEN issue_flag=0 AND status!='late' AND state!='completed' THEN 1 ELSE 0 END),0) working
FROM scoped''',
            variables: vars,
            readsFrom: reads,
          )
          .getSingle();
      final issueRow = await db
          .customSelect(
            '''$base
SELECT
 COALESCE(SUM(CASE WHEN sync_status='rejected' THEN 1 ELSE 0 END),0) rejected,
 COALESCE(SUM(CASE WHEN sync_status='failed' THEN 1 ELSE 0 END),0) sync_failure,
 COALESCE(SUM(CASE WHEN pending_count>0 THEN 1 ELSE 0 END),0) pending_correction,
 COALESCE(SUM(CASE WHEN incomplete_flag=1 AND sync_status NOT IN ('failed','rejected') AND pending_count=0 THEN 1 ELSE 0 END),0) missing_punch_out
FROM scoped''',
            variables: vars,
            readsFrom: reads,
          )
          .getSingle();
      final groupColumn = switch (filter.group) {
        AttendanceReportGroup.department => 'department',
        AttendanceReportGroup.shift =>
          "COALESCE(json_extract(configuration_snapshot,'\$.shift.name'),'')",
        AttendanceReportGroup.location =>
          "COALESCE(json_extract(configuration_snapshot,'\$.workLocation.name'),'')",
      };
      final groupRows = await db
          .customSelect(
            '''$base
SELECT $groupColumn group_name,COUNT(*) recorded,
 COALESCE(SUM(work_ms),0) work_ms FROM scoped
GROUP BY $groupColumn ORDER BY group_name COLLATE NOCASE''',
            variables: vars,
            readsFrom: reads,
          )
          .get();
      final order = grouped
          ? switch (sort) {
              AttendanceReportSort.workedMost => 'work_ms DESC,employee_name',
              AttendanceReportSort.breaksMost => 'break_ms DESC,employee_name',
              _ => 'employee_name COLLATE NOCASE,employee_id',
            }
          : switch (sort) {
              AttendanceReportSort.oldest => 'report_date,employee_name',
              AttendanceReportSort.employee =>
                'employee_name COLLATE NOCASE,report_date DESC',
              AttendanceReportSort.workedMost =>
                'work_ms DESC,report_date DESC',
              AttendanceReportSort.breaksMost =>
                'break_ms DESC,report_date DESC',
              _ => 'report_date DESC,employee_name COLLATE NOCASE',
            };
      final projection = grouped
          ? '''SELECT employee_id,employee_code,first_name||' '||last_name employee_name,
 department,COUNT(*) recorded,COALESCE(SUM(CASE WHEN state='completed' THEN 1 ELSE 0 END),0) completed,
 COALESCE(SUM(CASE WHEN status='late' THEN 1 ELSE 0 END),0) late,
 COALESCE(SUM(issue_flag),0) issues,COALESCE(SUM(work_ms),0) work_ms,
 COALESCE(SUM(break_ms),0) break_ms,COALESCE(SUM(pending_count),0) pending
 FROM scoped GROUP BY employee_id'''
          : '''SELECT employee_id,employee_code,first_name||' '||last_name employee_name,
 department,1 recorded,CASE WHEN state='completed' THEN 1 ELSE 0 END completed,
 CASE WHEN status='late' THEN 1 ELSE 0 END late,issue_flag issues,
 work_ms,break_ms,pending_count pending,day_id,report_date,status,sync_status,
 punch_in_milliseconds,punch_out_milliseconds,configuration_snapshot
 FROM scoped''';
      final limits = all ? '' : ' LIMIT ? OFFSET ?';
      final rows = await db
          .customSelect(
            '$base SELECT * FROM ($projection) ORDER BY $order$limits',
            variables: [
              ...vars,
              if (!all) ...[Variable(pageSize), Variable(page * pageSize)],
            ],
            readsFrom: reads,
          )
          .get();
      AttendanceReportRow map(QueryRow row) {
        AttendanceConfigurationSnapshot? snapshot;
        if (!grouped) {
          snapshot = AttendanceConfigurationSnapshot.fromJson(
            jsonDecode(row.read<String>('configuration_snapshot'))
                as Map<String, dynamic>,
          );
        }
        DateTime? instant(String column) {
          final ms = row.readNullable<int>(column);
          return ms == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
        }

        return AttendanceReportRow(
          employeeId: row.read<String>('employee_id'),
          employeeCode: row.read<String>('employee_code'),
          employeeName: row.read<String>('employee_name').trim(),
          department: row.read<String>('department'),
          recordedDays: row.read<int>('recorded'),
          completedDays: row.read<int>('completed'),
          lateDays: row.read<int>('late'),
          issueDays: row.read<int>('issues'),
          workMilliseconds: row.read<int>('work_ms'),
          breakMilliseconds: row.read<int>('break_ms'),
          pendingCorrections: row.read<int>('pending'),
          dayId: grouped ? null : row.read<String>('day_id'),
          date: grouped
              ? null
              : DateTime.parse(row.read<String>('report_date')),
          status: grouped ? null : row.read<String>('status'),
          syncStatus: grouped ? null : row.read<String>('sync_status'),
          punchIn: grouped ? null : instant('punch_in_milliseconds'),
          punchOut: grouped ? null : instant('punch_out_milliseconds'),
          scheduledStart: snapshot?.scheduledStart,
          graceMinutes: snapshot?.shift.gracePeriodMinutes ?? 0,
          shift: snapshot?.shift.name,
          location: snapshot?.workLocation?.name,
        );
      }

      return AttendanceReportData(
        type: type,
        filter: filter,
        summary: summary,
        totalRows: total,
        page: page,
        pageSize: all ? total : pageSize,
        rows: rows.map(map).toList(),
        trend: trendRows
            .map(
              (r) => AttendanceTrendPoint(
                DateTime.parse(r.read<String>('report_date')),
                r.read<int>('recorded'),
                r.read<int>('work_ms'),
                completedDays: r.read<int>('completed'),
                lateDays: r.read<int>('late'),
                breakMilliseconds: r.read<int>('break_ms'),
                issueDays: r.read<int>('issues'),
              ),
            )
            .toList(),
        statusDistribution: [
          for (final (status, column) in const [
            (AttendanceReportStatus.completed, 'completed'),
            (AttendanceReportStatus.late, 'late'),
            (AttendanceReportStatus.working, 'working'),
            (AttendanceReportStatus.issues, 'issues'),
          ])
            if (distributionRow.read<int>(column) > 0)
              AttendanceStatusSlice(status, distributionRow.read<int>(column)),
        ],
        issueBreakdown: [
          for (final (code, column) in const [
            ('rejected', 'rejected'),
            ('syncFailure', 'sync_failure'),
            ('pendingCorrection', 'pending_correction'),
            ('missingPunchOut', 'missing_punch_out'),
          ])
            if (issueRow.read<int>(column) > 0)
              AttendanceIssueCategory(code, issueRow.read<int>(column)),
        ],
        groups: groupRows
            .map(
              (r) => AttendanceGroupSummary(
                r.read<String>('group_name'),
                r.read<int>('recorded'),
                r.read<int>('work_ms'),
              ),
            )
            .toList(),
      );
    });
    final latest = await auth.checkSession();
    if (latest is! Success<AuthContext?> ||
        latest.value?.user.id != actor.user.id ||
        latest.value?.company.id != actor.company.id) {
      return _fail('reportSessionChanged');
    }
    return Success(result);
  }

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
