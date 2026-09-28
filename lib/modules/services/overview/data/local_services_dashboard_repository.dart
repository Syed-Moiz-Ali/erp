import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection_scope.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment_scope.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request_scope.dart';
import 'package:modular_erp/modules/services/overview/domain/services_dashboard.dart';
import 'package:modular_erp/modules/services/overview/domain/services_dashboard_repository.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution_scope.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Read-only, permission/scope-aware Services dashboard projection.
///
/// The dashboard is assembled from a fixed set of batched, scope-filtered SQL
/// projections. It never loads all-company data to hide it in widgets, never
/// performs per-row Customer/Site/Employee lookups (no N+1) and mutates nothing.
/// Each optional section fails independently so one failure cannot blank the
/// whole dashboard.
class LocalServicesDashboardRepository implements ServicesDashboardRepository {
  LocalServicesDashboardRepository({
    required AppDatabase db,
    required AppClock clock,
    required CompanyTimeService time,
    WorkforceDirectory? workforce,
  }) : _db = db,
       _clock = clock,
       _time = time,
       _workforce = workforce;

  final AppDatabase _db;
  final AppClock _clock;
  final CompanyTimeService _time;
  final WorkforceDirectory? _workforce;

  static const _maxItems = 6;

  Set<ResultSetImplementation> get _reads => {
    _db.serviceEnquiries,
    _db.serviceJobAssignments,
    _db.serviceJobAssignmentLines,
    _db.serviceInspections,
    _db.serviceInspectionMaterialRequirements,
    _db.serviceMaterialRequests,
    _db.serviceWorkExecutions,
    _db.serviceWorkExecutionLines,
    _db.serviceTeams,
    _db.serviceTeamMembers,
    _db.businessActivityEvents,
  };

  bool _enabled(AuthContext c) =>
      c.user.status == AccountStatus.active &&
      c.user.companyId == c.company.id &&
      c.company.enabledModules.contains('services');

  bool _can(AuthContext c, AppPermission p) =>
      _enabled(c) && c.user.permissions.contains(p);

  DateTime _companyDate(AuthContext c) {
    final instant = _clock.now().toUtc();
    final wall = _time.localWallTime(instant, c.company.timezone);
    final value = wall is Success<DateTime> ? wall.value : instant;
    return DateTime.utc(value.year, value.month, value.day);
  }

  ServiceEnquiryPartySnapshot _snapshot(String? raw) {
    if (raw == null) return const ServiceEnquiryPartySnapshot();
    try {
      return ServiceEnquiryPartySnapshot.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const ServiceEnquiryPartySnapshot();
    }
  }

  String _site(ServiceEnquiryPartySnapshot s) {
    final site = [
      s.buildingName,
      s.unitNumber,
    ].whereType<String>().where((v) => v.trim().isNotEmpty).join(' / ');
    return site.isEmpty ? (s.siteName ?? '') : site;
  }

  @override
  Stream<Result<ServicesDashboardSnapshot>> watch(AuthContext context) => _db
      .customSelect('SELECT 1', readsFrom: _reads)
      .watch()
      .asyncMap<Result<ServicesDashboardSnapshot>>((_) async {
        try {
          return Success(await load(context));
        } catch (_) {
          return const Failed(Failure(code: 'servicesStorage'));
        }
      });

  /// Reads the whole snapshot once. Public so tests can assert query behaviour
  /// without opening a long-lived stream.
  @override
  Future<ServicesDashboardSnapshot> load(AuthContext context) async {
    if (!_enabled(context)) return ServicesDashboardSnapshot.empty;
    final today = _companyDate(context);
    final company = context.company.id;

    final canEnquiries = _can(context, AppPermission.serviceEnquiryView);
    final assignmentScope = const ServiceJobAssignmentScopeResolver().resolve(
      context,
    );
    final inspectionScope = const ServiceInspectionScopeResolver().resolve(
      context,
    );
    final materialScope = const ServiceMaterialRequestScopeResolver().resolve(
      context,
    );
    final executionScope = const ServiceWorkExecutionScopeResolver().resolve(
      context,
    );
    final canAssignments = assignmentScope != ServiceJobAssignmentScope.none;
    final canInspections = inspectionScope != ServiceInspectionScope.none;
    final canMaterial = materialScope != ServiceMaterialRequestScope.none;
    final canExecutions = executionScope != ServiceWorkExecutionScope.none;

    var openEnquiries = 0;
    var scheduledAssignments = 0;
    var pendingInspections = 0;
    var openMaterial = 0;
    var inProgress = 0;
    var completedToday = 0;
    final attention = <ServicesAttentionItem>[];
    final schedule = <ServicesScheduleItem>[];
    final myWork = <ServicesMyWorkItem>[];
    final teamWorkload = <ServicesTeamWorkloadRow>[];
    final stages = <ServicesWorkflowStageCount>[];
    var activity = <ServicesRecentActivityItem>[];

    if (canEnquiries) {
      openEnquiries = await _count(
        'SELECT COUNT(*) AS c FROM service_enquiries e '
        "WHERE e.company_id=? AND e.status='open'",
        [Variable(company)],
      );
      stages.add(
        ServicesWorkflowStageCount(
          stage: ServiceWorkflowStage.enquiry,
          count: openEnquiries,
        ),
      );
      attention.addAll(
        await _openEnquiriesWithoutAssignment(context, _maxItems),
      );
    }

    if (canAssignments) {
      scheduledAssignments = await _count(
        'SELECT COUNT(*) AS c FROM service_job_assignments a '
        "WHERE ${_assignmentScope(context, 'a').sql} AND a.status='active'",
        [
          ..._assignmentScope(context, 'a').vars,
          Variable(ServiceJobAssignmentStatus.active.wire),
        ],
      );
      stages.add(
        ServicesWorkflowStageCount(
          stage: ServiceWorkflowStage.jobAssignment,
          count: scheduledAssignments,
        ),
      );
      final todayRows = await _assignmentRows(
        context,
        extraSql: "a.status='active' AND a.scheduled_visit_date=?",
        extraVars: [Variable(today)],
        limit: _maxItems,
      );
      schedule.addAll(todayRows);
      attention.addAll(
        await _assignmentsTodayWithoutInspection(context, today),
      );
    }

    if (canInspections) {
      pendingInspections = await _count(
        'SELECT COUNT(*) AS c FROM service_inspections i '
        "WHERE ${_inspectionScope(context, 'i').sql} AND i.status='pending'",
        [
          ..._inspectionScope(context, 'i').vars,
          Variable(ServiceInspectionStatus.pending.wire),
        ],
      );
      stages.add(
        ServicesWorkflowStageCount(
          stage: ServiceWorkflowStage.inspection,
          count: pendingInspections,
        ),
      );
      final todayRows = await _inspectionRows(
        context,
        extraSql: 'i.status<>? AND i.visit_date=?',
        extraVars: [
          Variable(ServiceInspectionStatus.cancelled.wire),
          Variable(today),
        ],
        limit: _maxItems,
      );
      schedule.addAll(todayRows);
      attention.addAll(await _inspectionsToday(context, today));
      attention.addAll(
        await _inspectionsWithWaitingMaterials(context, _maxItems),
      );
    }

    if (canMaterial) {
      openMaterial = await _count(
        'SELECT COUNT(*) AS c FROM service_material_requests r '
        "WHERE ${_materialScope(context, 'r').sql} AND r.status='open'",
        [..._materialScope(context, 'r').vars, Variable('open')],
      );
      stages.add(
        ServicesWorkflowStageCount(
          stage: ServiceWorkflowStage.materialRequest,
          count: openMaterial,
        ),
      );
      attention.addAll(await _openMaterialRequests(context, _maxItems));
    }

    if (canExecutions) {
      final scope = _executionScope(context, 'w');
      inProgress = await _count(
        'SELECT COUNT(*) AS c FROM service_work_executions w '
        "WHERE ${scope.sql} AND w.status='inProgress'",
        [...scope.vars, Variable('inProgress')],
      );
      completedToday = await _count(
        'SELECT COUNT(*) AS c FROM service_work_executions w '
        "WHERE ${scope.sql} AND w.status='completed' AND w.execution_date=?",
        [...scope.vars, Variable('completed'), Variable(today)],
      );
      stages.add(
        ServicesWorkflowStageCount(
          stage: ServiceWorkflowStage.workExecution,
          count: inProgress,
        ),
      );
      attention.addAll(await _activeWorkLines(context, _maxItems));
    }

    myWork.addAll(await _myWork(context, today));
    teamWorkload.addAll(await _teamWorkload(context, today));

    activity = await _recentActivity(context, _maxItems + 2);

    final snapshot = ServicesDashboardSnapshot(
      scope: _scopeLabel(
        context,
        assignmentScope: assignmentScope,
        inspectionScope: inspectionScope,
        materialScope: materialScope,
        executionScope: executionScope,
      ),
      canViewEnquiries: canEnquiries,
      canViewAssignments: canAssignments,
      canViewInspections: canInspections,
      canViewMaterialRequests: canMaterial,
      canViewWorkExecutions: canExecutions,
      canCreateEnquiry: _can(context, AppPermission.serviceEnquiryCreate),
      openEnquiriesCount: openEnquiries,
      scheduledAssignmentsCount: scheduledAssignments,
      pendingInspectionsCount: pendingInspections,
      openMaterialRequestsCount: openMaterial,
      workInProgressCount: inProgress,
      completedTodayCount: completedToday,
      attentionItems: attention,
      todaySchedule: _sortedSchedule(schedule),
      myWork: myWork,
      teamWorkload: teamWorkload,
      workflowStages: stages,
      recentActivity: activity,
      today: today,
    );
    return snapshot;
  }

  ServicesDashboardScope _scopeLabel(
    AuthContext context, {
    required ServiceJobAssignmentScope assignmentScope,
    required ServiceInspectionScope inspectionScope,
    required ServiceMaterialRequestScope materialScope,
    required ServiceWorkExecutionScope executionScope,
  }) {
    final scopes = <String>{
      assignmentScope.name,
      inspectionScope.name,
      materialScope.name,
      executionScope.name,
    };
    if (scopes.contains('all')) return ServicesDashboardScope.all;
    if (scopes.contains('team')) return ServicesDashboardScope.team;
    if (scopes.contains('assigned')) {
      return ServicesDashboardScope.assigned;
    }
    // Enquiry-only (or directory-only) visibility is company-wide.
    return _can(context, AppPermission.serviceEnquiryView)
        ? ServicesDashboardScope.all
        : ServicesDashboardScope.none;
  }

  List<ServicesScheduleItem> _sortedSchedule(List<ServicesScheduleItem> rows) {
    final sorted = [...rows]
      ..sort((a, b) {
        final aAt = a.at;
        final bAt = b.at;
        if (aAt == null && bAt == null) {
          return a.reference.compareTo(b.reference);
        }
        if (aAt == null) return -1;
        if (bAt == null) return 1;
        return aAt.compareTo(bAt);
      });
    return sorted;
  }

  // ------------------------------------------------------------- enquiries

  ({String sql, List<Variable> vars}) _assignmentScope(
    AuthContext c,
    String a,
  ) {
    final company = Variable(c.company.id);
    switch (const ServiceJobAssignmentScopeResolver().resolve(c)) {
      case ServiceJobAssignmentScope.all:
        return (sql: '$a.company_id=?', vars: [company]);
      case ServiceJobAssignmentScope.none:
        return (sql: '0', vars: const []);
      case ServiceJobAssignmentScope.team:
      case ServiceJobAssignmentScope.assigned:
        final e = c.employeeReference?.id;
        if (e == null) return (sql: '0', vars: const []);
        final team =
            "EXISTS (SELECT 1 FROM service_job_assignment_lines l WHERE l.assignment_id=$a.id AND l.company_id=$a.company_id AND l.removed_at IS NULL AND l.assigned_team_id IN (SELECT tm.team_id FROM service_team_members tm WHERE tm.company_id=$a.company_id AND tm.employee_id=? AND tm.status='active'))";
        if (const ServiceJobAssignmentScopeResolver().resolve(c) ==
            ServiceJobAssignmentScope.team) {
          return (
            sql: '$a.company_id=? AND $team',
            vars: [company, Variable(e)],
          );
        }
        final employee =
            "EXISTS (SELECT 1 FROM service_job_assignment_lines l WHERE l.assignment_id=$a.id AND l.company_id=$a.company_id AND l.removed_at IS NULL AND l.assigned_employee_id=?)";
        return (
          sql: '$a.company_id=? AND ($employee OR $team)',
          vars: [company, Variable(e), Variable(e)],
        );
    }
  }

  Future<List<ServicesAttentionItem>> _openEnquiriesWithoutAssignment(
    AuthContext c,
    int limit,
  ) async {
    try {
      final rows = await _db
          .customSelect(
            'SELECT e.id, e.enquiry_number, e.party_snapshot, '
            'pr.name AS priority_name, pr.rank AS priority_rank '
            'FROM service_enquiries e '
            'LEFT JOIN service_priorities pr ON pr.id=e.priority_id AND pr.company_id=e.company_id '
            "WHERE e.company_id=? AND e.status='open' "
            'AND NOT EXISTS (SELECT 1 FROM service_job_assignments a WHERE a.company_id=e.company_id AND a.source_enquiry_id=e.id AND a.status=\'active\') '
            'ORDER BY COALESCE(pr.rank,0) DESC, e.created_at DESC LIMIT ?',
            variables: [Variable(c.company.id), Variable(limit)],
          )
          .get();
      return [
        for (final row in rows)
          _enquiryAttention(row, ServicesAttentionKind.openEnquiryUnassigned),
      ];
    } catch (_) {
      return const [];
    }
  }

  ServicesAttentionItem _enquiryAttention(
    QueryRow row,
    ServicesAttentionKind kind,
  ) {
    final snapshot = _snapshot(row.readNullable<String>('party_snapshot'));
    return ServicesAttentionItem(
      kind: kind,
      entityId: row.read<String>('id'),
      reference: row.read<String>('enquiry_number'),
      customerName: snapshot.customerName ?? '',
      siteSummary: _site(snapshot),
      priorityName: row.readNullable<String>('priority_name') ?? '',
      priorityRank: row.readNullable<int>('priority_rank') ?? 0,
    );
  }

  // ---------------------------------------------------------- assignments

  Future<List<ServicesScheduleItem>> _assignmentRows(
    AuthContext c, {
    required String extraSql,
    required List<Variable> extraVars,
    required int limit,
  }) async {
    try {
      final scope = _assignmentScope(c, 'a');
      final rows = await _db
          .customSelect(
            'SELECT a.id, a.assignment_number, a.scheduled_visit_date, '
            'e.enquiry_number, e.party_snapshot, '
            'pr.name AS priority_name, pr.rank AS priority_rank '
            'FROM service_job_assignments a '
            'LEFT JOIN service_enquiries e ON e.id=a.source_enquiry_id AND e.company_id=a.company_id '
            'LEFT JOIN service_priorities pr ON pr.id=e.priority_id AND pr.company_id=e.company_id '
            'WHERE ${scope.sql} AND $extraSql '
            'ORDER BY a.scheduled_visit_date, a.created_at LIMIT ?',
            variables: [...scope.vars, ...extraVars, Variable(limit)],
          )
          .get();
      final ids = [for (final row in rows) row.read<String>('id')];
      final summaries = await _assignmentSummaries(c, ids);
      return [
        for (final row in rows)
          _assignmentSchedule(row, summaries[row.read<String>('id')] ?? ''),
      ];
    } catch (_) {
      return const [];
    }
  }

  ServicesScheduleItem _assignmentSchedule(QueryRow row, String assigned) {
    final snapshot = _snapshot(row.readNullable<String>('party_snapshot'));
    return ServicesScheduleItem(
      kind: ServicesScheduleKind.assignment,
      entityId: row.read<String>('id'),
      reference: row.read<String>('assignment_number'),
      customerName: snapshot.customerName ?? '',
      siteSummary: _site(snapshot),
      assignedSummary: assigned,
      complaint: row.readNullable<String>('enquiry_number') ?? '',
      visitDate: row.read<DateTime>('scheduled_visit_date').toUtc(),
      statusKey: 'active',
      priorityName: row.readNullable<String>('priority_name') ?? '',
      priorityRank: row.readNullable<int>('priority_rank') ?? 0,
    );
  }

  Future<Map<String, String>> _assignmentSummaries(
    AuthContext c,
    List<String> ids,
  ) async {
    if (ids.isEmpty) return const {};
    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await _db
        .customSelect(
          'SELECT assignment_id, assigned_employee_id, assigned_team_id '
          'FROM service_job_assignment_lines '
          'WHERE company_id=? AND removed_at IS NULL AND assignment_id IN ($placeholders)',
          variables: [Variable(c.company.id), ...ids.map(Variable.new)],
        )
        .get();
    final employeeIds = <String>{};
    final teamIds = <String>{};
    final byAssignment =
        <String, ({List<String> employees, Set<String> teams})>{};
    for (final row in rows) {
      final assignmentId = row.read<String>('assignment_id');
      final employeeId = row.readNullable<String>('assigned_employee_id');
      final teamId = row.readNullable<String>('assigned_team_id');
      if (employeeId != null) employeeIds.add(employeeId);
      if (teamId != null) teamIds.add(teamId);
      final entry = byAssignment.putIfAbsent(
        assignmentId,
        () => (employees: <String>[], teams: <String>{}),
      );
      if (employeeId != null && !entry.employees.contains(employeeId)) {
        entry.employees.add(employeeId);
      }
      if (teamId != null) entry.teams.add(teamId);
    }
    final employeeNames = await _employeeNames(employeeIds);
    final teamNames = await _teamNames(c.company.id, teamIds);
    return {
      for (final entry in byAssignment.entries)
        entry.key: _assignedSummary(
          entry.value.employees,
          entry.value.teams,
          employeeNames,
          teamNames,
        ),
    };
  }

  String _assignedSummary(
    List<String> employees,
    Set<String> teams,
    Map<String, String> employeeNames,
    Map<String, String> teamNames,
  ) {
    final labels = <String>[];
    for (final id in employees) {
      final name = employeeNames[id];
      if (name != null && !labels.contains(name)) labels.add(name);
    }
    for (final id in teams) {
      final name = teamNames[id];
      if (name != null && !labels.contains(name)) labels.add(name);
    }
    if (labels.isEmpty) return '';
    if (labels.length <= 2) return labels.join(' + ');
    return '${labels.take(2).join(' + ')} +${labels.length - 2}';
  }

  Future<List<ServicesAttentionItem>> _assignmentsTodayWithoutInspection(
    AuthContext c,
    DateTime today,
  ) async {
    try {
      final scope = _assignmentScope(c, 'a');
      final rows = await _db
          .customSelect(
            'SELECT a.id, a.assignment_number, a.scheduled_visit_date, '
            'e.enquiry_number, e.party_snapshot, '
            'pr.name AS priority_name, pr.rank AS priority_rank '
            'FROM service_job_assignments a '
            'LEFT JOIN service_enquiries e ON e.id=a.source_enquiry_id AND e.company_id=a.company_id '
            'LEFT JOIN service_priorities pr ON pr.id=e.priority_id AND pr.company_id=e.company_id '
            "WHERE ${scope.sql} AND a.status='active' AND a.scheduled_visit_date=? "
            'AND NOT EXISTS (SELECT 1 FROM service_inspections i WHERE i.company_id=a.company_id AND i.source_job_assignment_id=a.id AND i.status<>\'cancelled\') '
            'ORDER BY a.created_at LIMIT ?',
            variables: [...scope.vars, Variable(today), Variable(_maxItems)],
          )
          .get();
      return [
        for (final row in rows)
          _scheduleAttention(
            row,
            ServicesAttentionKind.visitTodayWithoutInspection,
          ),
      ];
    } catch (_) {
      return const [];
    }
  }

  ServicesAttentionItem _scheduleAttention(
    QueryRow row,
    ServicesAttentionKind kind,
  ) {
    final snapshot = _snapshot(row.readNullable<String>('party_snapshot'));
    return ServicesAttentionItem(
      kind: kind,
      entityId: row.read<String>('id'),
      reference: row.read<String>('assignment_number'),
      customerName: snapshot.customerName ?? '',
      siteSummary: _site(snapshot),
      dueAt: row.read<DateTime>('scheduled_visit_date').toUtc(),
      priorityName: row.readNullable<String>('priority_name') ?? '',
      priorityRank: row.readNullable<int>('priority_rank') ?? 0,
    );
  }

  // ------------------------------------------------------------ inspections

  ({String sql, List<Variable> vars}) _inspectionScope(
    AuthContext c,
    String i,
  ) {
    final company = Variable(c.company.id);
    switch (const ServiceInspectionScopeResolver().resolve(c)) {
      case ServiceInspectionScope.all:
        return (sql: '$i.company_id=?', vars: [company]);
      case ServiceInspectionScope.none:
        return (sql: '0', vars: const []);
      case ServiceInspectionScope.team:
      case ServiceInspectionScope.assigned:
        final e = c.employeeReference?.id;
        if (e == null) return (sql: '0', vars: const []);
        final team =
            "EXISTS (SELECT 1 FROM service_job_assignment_lines l WHERE l.company_id=$i.company_id AND l.assignment_id=$i.source_job_assignment_id AND l.removed_at IS NULL AND l.assigned_team_id IN (SELECT tm.team_id FROM service_team_members tm WHERE tm.company_id=$i.company_id AND tm.employee_id=? AND tm.status='active'))";
        if (const ServiceInspectionScopeResolver().resolve(c) ==
            ServiceInspectionScope.team) {
          return (
            sql: '$i.company_id=? AND $team',
            vars: [company, Variable(e)],
          );
        }
        final employee =
            "EXISTS (SELECT 1 FROM service_job_assignment_lines l WHERE l.company_id=$i.company_id AND l.assignment_id=$i.source_job_assignment_id AND l.removed_at IS NULL AND l.assigned_employee_id=?)";
        return (
          sql:
              '$i.company_id=? AND ($i.technician_employee_id=? OR $employee OR $team)',
          vars: [company, Variable(e), Variable(e), Variable(e)],
        );
    }
  }

  Future<List<ServicesScheduleItem>> _inspectionRows(
    AuthContext c, {
    required String extraSql,
    required List<Variable> extraVars,
    required int limit,
  }) async {
    try {
      final scope = _inspectionScope(c, 'i');
      final rows = await _db
          .customSelect(
            'SELECT i.id, i.inspection_number, i.visit_date, i.visit_minutes, i.status, '
            'i.technician_employee_id, a.assignment_number, e.enquiry_number, e.party_snapshot, '
            'pr.name AS priority_name, pr.rank AS priority_rank '
            'FROM service_inspections i '
            'LEFT JOIN service_job_assignments a ON a.id=i.source_job_assignment_id AND a.company_id=i.company_id '
            'LEFT JOIN service_enquiries e ON e.id=i.source_enquiry_id AND e.company_id=i.company_id '
            'LEFT JOIN service_priorities pr ON pr.id=e.priority_id AND pr.company_id=e.company_id '
            'WHERE ${scope.sql} AND $extraSql '
            'ORDER BY i.visit_date, i.visit_minutes LIMIT ?',
            variables: [...scope.vars, ...extraVars, Variable(limit)],
          )
          .get();
      // One batched employee lookup for every row (no per-row query).
      final names = await _employeeNames([
        for (final row in rows)
          row.readNullable<String>('technician_employee_id') ?? '',
      ]);
      return [for (final row in rows) _inspectionSchedule(row, names)];
    } catch (_) {
      return const [];
    }
  }

  ServicesScheduleItem _inspectionSchedule(
    QueryRow row,
    Map<String, String> names,
  ) {
    final snapshot = _snapshot(row.readNullable<String>('party_snapshot'));
    final technicianId = row.readNullable<String>('technician_employee_id');
    return ServicesScheduleItem(
      kind: ServicesScheduleKind.inspection,
      entityId: row.read<String>('id'),
      reference: row.read<String>('inspection_number'),
      customerName: snapshot.customerName ?? '',
      siteSummary: _site(snapshot),
      assignedSummary: technicianId == null ? '' : (names[technicianId] ?? ''),
      complaint: row.readNullable<String>('enquiry_number') ?? '',
      visitDate: row.read<DateTime>('visit_date').toUtc(),
      minutes: row.readNullable<int>('visit_minutes'),
      statusKey: row.read<String>('status'),
      priorityName: row.readNullable<String>('priority_name') ?? '',
      priorityRank: row.readNullable<int>('priority_rank') ?? 0,
    );
  }

  Future<List<ServicesAttentionItem>> _inspectionsToday(
    AuthContext c,
    DateTime today,
  ) async {
    try {
      final scope = _inspectionScope(c, 'i');
      final rows = await _db
          .customSelect(
            'SELECT i.id, i.inspection_number, i.visit_date, i.visit_minutes, '
            'e.party_snapshot, pr.name AS priority_name, pr.rank AS priority_rank '
            'FROM service_inspections i '
            'LEFT JOIN service_enquiries e ON e.id=i.source_enquiry_id AND e.company_id=i.company_id '
            'LEFT JOIN service_priorities pr ON pr.id=e.priority_id AND pr.company_id=e.company_id '
            "WHERE ${scope.sql} AND i.status='pending' AND i.visit_date=? "
            'ORDER BY i.visit_minutes LIMIT ?',
            variables: [...scope.vars, Variable(today), Variable(_maxItems)],
          )
          .get();
      return [
        for (final row in rows)
          _inspectionAttention(
            row,
            ServicesAttentionKind.pendingInspectionToday,
          ),
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<List<ServicesAttentionItem>> _inspectionsWithWaitingMaterials(
    AuthContext c,
    int limit,
  ) async {
    try {
      final scope = _inspectionScope(c, 'i');
      final rows = await _db
          .customSelect(
            'SELECT i.id, i.inspection_number, i.visit_date, i.visit_minutes, '
            'e.party_snapshot, pr.name AS priority_name, pr.rank AS priority_rank '
            'FROM service_inspections i '
            'LEFT JOIN service_enquiries e ON e.id=i.source_enquiry_id AND e.company_id=i.company_id '
            'LEFT JOIN service_priorities pr ON pr.id=e.priority_id AND pr.company_id=e.company_id '
            "WHERE ${scope.sql} AND i.status<>'cancelled' "
            'AND EXISTS (SELECT 1 FROM service_inspection_material_requirements m WHERE m.company_id=i.company_id AND m.inspection_id=i.id AND m.removed_at IS NULL AND m.status=\'waiting\') '
            'ORDER BY i.visit_date DESC LIMIT ?',
            variables: [...scope.vars, Variable(limit)],
          )
          .get();
      return [
        for (final row in rows)
          _inspectionAttention(
            row,
            ServicesAttentionKind.inspectionWaitingMaterials,
          ),
      ];
    } catch (_) {
      return const [];
    }
  }

  ServicesAttentionItem _inspectionAttention(
    QueryRow row,
    ServicesAttentionKind kind,
  ) {
    final snapshot = _snapshot(row.readNullable<String>('party_snapshot'));
    final visitDate = row.read<DateTime>('visit_date').toUtc();
    final minutes = row.readNullable<int>('visit_minutes');
    return ServicesAttentionItem(
      kind: kind,
      entityId: row.read<String>('id'),
      reference: row.read<String>('inspection_number'),
      customerName: snapshot.customerName ?? '',
      siteSummary: _site(snapshot),
      dueAt: minutes == null
          ? visitDate
          : visitDate.add(Duration(minutes: minutes)),
      priorityName: row.readNullable<String>('priority_name') ?? '',
      priorityRank: row.readNullable<int>('priority_rank') ?? 0,
    );
  }

  // ------------------------------------------------------- material requests

  ({String sql, List<Variable> vars}) _materialScope(AuthContext c, String r) {
    final company = Variable(c.company.id);
    switch (const ServiceMaterialRequestScopeResolver().resolve(c)) {
      case ServiceMaterialRequestScope.all:
        return (sql: '$r.company_id=?', vars: [company]);
      case ServiceMaterialRequestScope.none:
        return (sql: '0', vars: const []);
      case ServiceMaterialRequestScope.team:
      case ServiceMaterialRequestScope.assigned:
        final e = c.employeeReference?.id;
        if (e == null) return (sql: '0', vars: const []);
        final team =
            "EXISTS (SELECT 1 FROM service_job_assignment_lines l WHERE l.company_id=$r.company_id AND l.assignment_id IN (SELECT i2.source_job_assignment_id FROM service_inspections i2 WHERE i2.company_id=$r.company_id AND i2.id=$r.source_inspection_id) AND l.removed_at IS NULL AND l.assigned_team_id IN (SELECT tm.team_id FROM service_team_members tm WHERE tm.company_id=$r.company_id AND tm.employee_id=? AND tm.status='active'))";
        if (const ServiceMaterialRequestScopeResolver().resolve(c) ==
            ServiceMaterialRequestScope.team) {
          return (
            sql: '$r.company_id=? AND $team',
            vars: [company, Variable(e)],
          );
        }
        final employee =
            "EXISTS (SELECT 1 FROM service_job_assignment_lines l WHERE l.company_id=$r.company_id AND l.assignment_id IN (SELECT i2.source_job_assignment_id FROM service_inspections i2 WHERE i2.company_id=$r.company_id AND i2.id=$r.source_inspection_id) AND l.removed_at IS NULL AND l.assigned_employee_id=?)";
        final technician =
            "EXISTS (SELECT 1 FROM service_inspections i2 WHERE i2.company_id=$r.company_id AND i2.id=$r.source_inspection_id AND i2.technician_employee_id=?)";
        return (
          sql: '$r.company_id=? AND ($technician OR $employee OR $team)',
          vars: [company, Variable(e), Variable(e), Variable(e)],
        );
    }
  }

  Future<List<ServicesAttentionItem>> _openMaterialRequests(
    AuthContext c,
    int limit,
  ) async {
    try {
      final scope = _materialScope(c, 'r');
      final rows = await _db
          .customSelect(
            'SELECT r.id, r.request_number, e.party_snapshot '
            'FROM service_material_requests r '
            'LEFT JOIN service_enquiries e ON e.id=r.source_enquiry_id AND e.company_id=r.company_id '
            "WHERE ${scope.sql} AND r.status='open' "
            'ORDER BY r.request_date DESC LIMIT ?',
            variables: [...scope.vars, Variable(limit)],
          )
          .get();
      return [
        for (final row in rows)
          _simpleAttention(row, ServicesAttentionKind.openMaterialRequest),
      ];
    } catch (_) {
      return const [];
    }
  }

  ServicesAttentionItem _simpleAttention(
    QueryRow row,
    ServicesAttentionKind kind,
  ) {
    final snapshot = _snapshot(row.readNullable<String>('party_snapshot'));
    return ServicesAttentionItem(
      kind: kind,
      entityId: row.read<String>('id'),
      reference: row.read<String>('request_number'),
      customerName: snapshot.customerName ?? '',
      siteSummary: _site(snapshot),
    );
  }

  // --------------------------------------------------------- work executions

  ({String sql, List<Variable> vars}) _executionScope(AuthContext c, String w) {
    final company = Variable(c.company.id);
    switch (const ServiceWorkExecutionScopeResolver().resolve(c)) {
      case ServiceWorkExecutionScope.all:
        return (sql: '$w.company_id=?', vars: [company]);
      case ServiceWorkExecutionScope.none:
        return (sql: '0', vars: const []);
      case ServiceWorkExecutionScope.team:
      case ServiceWorkExecutionScope.assigned:
        final e = c.employeeReference?.id;
        if (e == null) return (sql: '0', vars: const []);
        final members =
            '(SELECT tm.team_id FROM service_team_members tm WHERE tm.company_id=$w.company_id AND tm.employee_id=? AND tm.status=\'active\')';
        final lineTeam =
            "EXISTS (SELECT 1 FROM service_work_execution_lines l WHERE l.company_id=$w.company_id AND l.work_execution_id=$w.id AND l.service_team_id IN $members)";
        final assignmentTeam =
            "EXISTS (SELECT 1 FROM service_job_assignment_lines al WHERE al.company_id=$w.company_id AND al.assignment_id=$w.source_job_assignment_id AND al.removed_at IS NULL AND al.assigned_team_id IN $members)";
        if (const ServiceWorkExecutionScopeResolver().resolve(c) ==
            ServiceWorkExecutionScope.team) {
          return (
            sql: '$w.company_id=? AND ($lineTeam OR $assignmentTeam)',
            vars: [company, Variable(e), Variable(e)],
          );
        }
        final lineEmployee =
            "EXISTS (SELECT 1 FROM service_work_execution_lines l WHERE l.company_id=$w.company_id AND l.work_execution_id=$w.id AND l.employee_id=?)";
        final assignmentEmployee =
            "EXISTS (SELECT 1 FROM service_job_assignment_lines al WHERE al.company_id=$w.company_id AND al.assignment_id=$w.source_job_assignment_id AND al.removed_at IS NULL AND al.assigned_employee_id=?)";
        final technician =
            "EXISTS (SELECT 1 FROM service_inspections ii WHERE ii.company_id=$w.company_id AND ii.id=$w.source_inspection_id AND ii.technician_employee_id=?)";
        return (
          sql:
              '$w.company_id=? AND ($lineEmployee OR $assignmentEmployee OR $technician OR $lineTeam OR $assignmentTeam)',
          vars: [
            company,
            Variable(e),
            Variable(e),
            Variable(e),
            Variable(e),
            Variable(e),
          ],
        );
    }
  }

  Future<List<ServicesAttentionItem>> _activeWorkLines(
    AuthContext c,
    int limit,
  ) async {
    try {
      final scope = _executionScope(c, 'w');
      final rows = await _db
          .customSelect(
            'SELECT w.id, w.execution_number, e.party_snapshot '
            'FROM service_work_executions w '
            'LEFT JOIN service_enquiries e ON e.id=w.source_enquiry_id AND e.company_id=w.company_id '
            "WHERE ${scope.sql} AND w.status='inProgress' "
            'ORDER BY w.execution_date DESC LIMIT ?',
            variables: [...scope.vars, Variable(limit)],
          )
          .get();
      return [
        for (final row in rows)
          _simpleAttention(row, ServicesAttentionKind.activeWorkLine),
      ];
    } catch (_) {
      return const [];
    }
  }

  // ------------------------------------------------------------- my work

  Future<List<ServicesMyWorkItem>> _myWork(
    AuthContext c,
    DateTime today,
  ) async {
    final employeeId = c.employeeReference?.id;
    if (employeeId == null) return const [];
    final items = <ServicesMyWorkItem>[];
    final canPerform = _can(c, AppPermission.serviceWorkExecutionPerform);
    final canViewExecution =
        const ServiceWorkExecutionScopeResolver().resolve(c) !=
        ServiceWorkExecutionScope.none;
    final canViewInspection =
        const ServiceInspectionScopeResolver().resolve(c) !=
        ServiceInspectionScope.none;
    final canViewAssignment =
        const ServiceJobAssignmentScopeResolver().resolve(c) !=
        ServiceJobAssignmentScope.none;

    if (canViewInspection) {
      try {
        final scope = _inspectionScope(c, 'i');
        final rows = await _db
            .customSelect(
              'SELECT i.id, i.inspection_number, i.visit_date, i.visit_minutes, i.status, '
              'e.party_snapshot FROM service_inspections i '
              'LEFT JOIN service_enquiries e ON e.id=i.source_enquiry_id AND e.company_id=i.company_id '
              "WHERE ${scope.sql} AND i.status='pending' "
              'AND (i.technician_employee_id=? OR EXISTS (SELECT 1 FROM service_job_assignment_lines l WHERE l.company_id=i.company_id AND l.assignment_id=i.source_job_assignment_id AND l.removed_at IS NULL AND (l.assigned_employee_id=? OR l.assigned_team_id IN (SELECT tm.team_id FROM service_team_members tm WHERE tm.company_id=i.company_id AND tm.employee_id=? AND tm.status=\'active\')))) '
              'ORDER BY i.visit_date LIMIT ?',
              variables: [
                ...scope.vars,
                Variable(employeeId),
                Variable(employeeId),
                Variable(employeeId),
                Variable(_maxItems),
              ],
            )
            .get();
        for (final row in rows) {
          final snapshot = _snapshot(
            row.readNullable<String>('party_snapshot'),
          );
          items.add(
            ServicesMyWorkItem(
              kind: ServicesMyWorkKind.inspection,
              entityId: row.read<String>('id'),
              reference: row.read<String>('inspection_number'),
              customerName: snapshot.customerName ?? '',
              siteSummary: _site(snapshot),
              summary: '',
              statusKey: row.read<String>('status'),
              date: row.read<DateTime>('visit_date').toUtc(),
              action: ServicesMyWorkAction.openInspection,
            ),
          );
        }
      } catch (_) {}
    }

    if (canViewExecution) {
      try {
        final scope = _executionScope(c, 'w');
        final rows = await _db
            .customSelect(
              'SELECT w.id, w.execution_number, w.execution_date, w.status, w.created_at, '
              'e.party_snapshot FROM service_work_executions w '
              'LEFT JOIN service_enquiries e ON e.id=w.source_enquiry_id AND e.company_id=w.company_id '
              "WHERE ${scope.sql} AND w.status='inProgress' "
              'AND EXISTS (SELECT 1 FROM service_work_execution_lines l WHERE l.company_id=w.company_id AND l.work_execution_id=w.id AND (l.employee_id=? OR l.service_team_id IN (SELECT tm.team_id FROM service_team_members tm WHERE tm.company_id=w.company_id AND tm.employee_id=? AND tm.status=\'active\'))) '
              'ORDER BY w.execution_date DESC LIMIT ?',
              variables: [
                ...scope.vars,
                Variable(employeeId),
                Variable(employeeId),
                Variable(_maxItems),
              ],
            )
            .get();
        for (final row in rows) {
          final snapshot = _snapshot(
            row.readNullable<String>('party_snapshot'),
          );
          items.add(
            ServicesMyWorkItem(
              kind: ServicesMyWorkKind.execution,
              entityId: row.read<String>('id'),
              reference: row.read<String>('execution_number'),
              customerName: snapshot.customerName ?? '',
              siteSummary: _site(snapshot),
              summary: '',
              statusKey: row.read<String>('status'),
              date: row.read<DateTime>('execution_date').toUtc(),
              action: canPerform
                  ? ServicesMyWorkAction.continueWork
                  : ServicesMyWorkAction.viewExecution,
            ),
          );
        }
      } catch (_) {}
    }

    if (canViewAssignment) {
      try {
        final scope = _assignmentScope(c, 'a');
        final rows = await _db
            .customSelect(
              'SELECT a.id, a.assignment_number, a.scheduled_visit_date, '
              'e.enquiry_number, e.party_snapshot FROM service_job_assignments a '
              'LEFT JOIN service_enquiries e ON e.id=a.source_enquiry_id AND e.company_id=a.company_id '
              "WHERE ${scope.sql} AND a.status='active' "
              'AND EXISTS (SELECT 1 FROM service_job_assignment_lines l WHERE l.assignment_id=a.id AND l.company_id=a.company_id AND l.removed_at IS NULL AND (l.assigned_employee_id=? OR l.assigned_team_id IN (SELECT tm.team_id FROM service_team_members tm WHERE tm.company_id=a.company_id AND tm.employee_id=? AND tm.status=\'active\'))) '
              'ORDER BY a.scheduled_visit_date LIMIT ?',
              variables: [
                ...scope.vars,
                Variable(employeeId),
                Variable(employeeId),
                Variable(_maxItems),
              ],
            )
            .get();
        for (final row in rows) {
          final snapshot = _snapshot(
            row.readNullable<String>('party_snapshot'),
          );
          items.add(
            ServicesMyWorkItem(
              kind: ServicesMyWorkKind.assignment,
              entityId: row.read<String>('id'),
              reference: row.read<String>('assignment_number'),
              customerName: snapshot.customerName ?? '',
              siteSummary: _site(snapshot),
              summary: row.readNullable<String>('enquiry_number') ?? '',
              statusKey: 'active',
              date: row.read<DateTime>('scheduled_visit_date').toUtc(),
              action: ServicesMyWorkAction.viewAssignment,
            ),
          );
        }
      } catch (_) {}
    }

    items.sort((a, b) {
      final ad = a.date;
      final bd = b.date;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return ad.compareTo(bd);
    });
    return items;
  }

  // ---------------------------------------------------------- team workload

  Future<List<ServicesTeamWorkloadRow>> _teamWorkload(
    AuthContext c,
    DateTime today,
  ) async {
    final scope = const ServiceJobAssignmentScopeResolver().resolve(c);
    if (scope != ServiceJobAssignmentScope.team &&
        scope != ServiceJobAssignmentScope.all) {
      return const [];
    }
    try {
      final employeeId = c.employeeReference?.id;
      final teamFilter = scope == ServiceJobAssignmentScope.team
          ? 'AND id IN (SELECT team_id FROM service_team_members WHERE company_id=? AND employee_id=? AND status=\'active\')'
          : '';
      final teamVars = <Variable>[
        Variable(c.company.id),
        if (scope == ServiceJobAssignmentScope.team) ...[
          Variable(c.company.id),
          Variable(employeeId ?? ''),
        ],
      ];
      if (scope == ServiceJobAssignmentScope.team && employeeId == null) {
        return const [];
      }
      final teamRows = await _db
          .customSelect(
            "SELECT id, name FROM service_teams WHERE company_id=? AND status='active' $teamFilter ORDER BY name",
            variables: teamVars,
          )
          .get();
      if (teamRows.isEmpty) return const [];
      final teamIds = [for (final row in teamRows) row.read<String>('id')];
      final placeholders = List.filled(teamIds.length, '?').join(',');
      final assignmentRows = await _db
          .customSelect(
            'SELECT l.assigned_team_id AS team_id, '
            'COUNT(DISTINCT a.id) AS active_count, '
            'COUNT(DISTINCT CASE WHEN a.scheduled_visit_date=? THEN a.id END) AS today_count '
            'FROM service_job_assignment_lines l '
            'JOIN service_job_assignments a ON a.id=l.assignment_id AND a.company_id=l.company_id '
            "WHERE l.company_id=? AND l.removed_at IS NULL AND a.status='active' "
            'AND l.assigned_team_id IN ($placeholders) GROUP BY l.assigned_team_id',
            variables: [
              Variable(today),
              Variable(c.company.id),
              ...teamIds.map(Variable.new),
            ],
          )
          .get();
      final executionRows = await _db
          .customSelect(
            'SELECT l.service_team_id AS team_id, COUNT(DISTINCT w.id) AS in_progress '
            'FROM service_work_execution_lines l '
            'JOIN service_work_executions w ON w.id=l.work_execution_id AND w.company_id=l.company_id '
            "WHERE l.company_id=? AND w.status='inProgress' "
            'AND l.service_team_id IN ($placeholders) GROUP BY l.service_team_id',
            variables: [Variable(c.company.id), ...teamIds.map(Variable.new)],
          )
          .get();
      final active = <String, int>{};
      final visits = <String, int>{};
      for (final row in assignmentRows) {
        final id = row.read<String>('team_id');
        active[id] = row.read<int>('active_count');
        visits[id] = row.read<int>('today_count');
      }
      final progress = <String, int>{};
      for (final row in executionRows) {
        progress[row.read<String>('team_id')] = row.read<int>('in_progress');
      }
      final rows =
          <ServicesTeamWorkloadRow>[
            for (final row in teamRows)
              ServicesTeamWorkloadRow(
                teamId: row.read<String>('id'),
                teamName: row.read<String>('name'),
                activeAssignments: active[row.read<String>('id')] ?? 0,
                todayVisits: visits[row.read<String>('id')] ?? 0,
                inProgress: progress[row.read<String>('id')] ?? 0,
              ),
          ].where((row) => !row.isEmpty).toList()..sort((a, b) {
            final byActive = b.activeAssignments.compareTo(a.activeAssignments);
            return byActive != 0
                ? byActive
                : a.teamName.toLowerCase().compareTo(b.teamName.toLowerCase());
          });
      return rows.take(_maxItems).toList();
    } catch (_) {
      return const [];
    }
  }

  // --------------------------------------------------------- recent activity

  Future<List<ServicesRecentActivityItem>> _recentActivity(
    AuthContext c,
    int limit,
  ) async {
    final queries = <({String entityType, String sql, List<Variable> vars})>[];
    if (_can(c, AppPermission.serviceEnquiryView)) {
      queries.add((
        entityType: 'serviceEnquiry',
        sql:
            'SELECT e.id AS ref_id, e.enquiry_number AS ref '
            'FROM service_enquiries e WHERE e.company_id=?',
        vars: [Variable(c.company.id)],
      ));
    }
    final assignmentScope = const ServiceJobAssignmentScopeResolver().resolve(
      c,
    );
    if (assignmentScope != ServiceJobAssignmentScope.none) {
      final scope = _assignmentScope(c, 'a');
      queries.add((
        entityType: 'serviceJobAssignment',
        sql:
            'SELECT a.id AS ref_id, a.assignment_number AS ref FROM service_job_assignments a WHERE ${scope.sql}',
        vars: scope.vars,
      ));
    }
    final inspectionScope = const ServiceInspectionScopeResolver().resolve(c);
    if (inspectionScope != ServiceInspectionScope.none) {
      final scope = _inspectionScope(c, 'i');
      queries.add((
        entityType: 'serviceInspection',
        sql:
            'SELECT i.id AS ref_id, i.inspection_number AS ref FROM service_inspections i WHERE ${scope.sql}',
        vars: scope.vars,
      ));
    }
    final materialScope = const ServiceMaterialRequestScopeResolver().resolve(
      c,
    );
    if (materialScope != ServiceMaterialRequestScope.none) {
      final scope = _materialScope(c, 'r');
      queries.add((
        entityType: 'serviceMaterialRequest',
        sql:
            'SELECT r.id AS ref_id, r.request_number AS ref FROM service_material_requests r WHERE ${scope.sql}',
        vars: scope.vars,
      ));
    }
    final executionScope = const ServiceWorkExecutionScopeResolver().resolve(c);
    if (executionScope != ServiceWorkExecutionScope.none) {
      final scope = _executionScope(c, 'w');
      queries.add((
        entityType: 'serviceWorkExecution',
        sql:
            'SELECT w.id AS ref_id, w.execution_number AS ref FROM service_work_executions w WHERE ${scope.sql}',
        vars: scope.vars,
      ));
    }
    if (queries.isEmpty) return const [];

    try {
      final events = <ServicesRecentActivityItem>[];
      for (final query in queries) {
        final rows = await _db
            .customSelect(
              'SELECT ev.entity_type, ev.entity_id, ev.event_type, ev.occurred_at, v.ref '
              'FROM business_activity_events ev '
              'JOIN (${query.sql}) v ON v.ref_id=ev.entity_id '
              "WHERE ev.company_id=? AND ev.entity_type=? AND ev.module_key='services' "
              'ORDER BY ev.occurred_at DESC LIMIT ?',
              variables: [
                ...query.vars,
                Variable(c.company.id),
                Variable(query.entityType),
                Variable(limit),
              ],
            )
            .get();
        for (final row in rows) {
          events.add(
            ServicesRecentActivityItem(
              entityType: row.read<String>('entity_type'),
              entityId: row.read<String>('entity_id'),
              eventType: row.read<String>('event_type'),
              reference: row.readNullable<String>('ref') ?? '',
              occurredAt: row.read<DateTime>('occurred_at').toUtc(),
            ),
          );
        }
      }
      events.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
      return events.take(limit).toList();
    } catch (_) {
      return const [];
    }
  }

  // ---------------------------------------------------------------- helpers

  Future<int> _count(String sql, List<Variable> vars) async {
    try {
      final row = await _db.customSelect(sql, variables: vars).getSingle();
      return row.read<int>('c');
    } catch (_) {
      return 0;
    }
  }

  Future<Map<String, String>> _employeeNames(Iterable<String> ids) async {
    final wanted = {
      for (final id in ids)
        if (id.isNotEmpty) id,
    };
    final directory = _workforce;
    if (wanted.isEmpty || directory == null) return const {};
    try {
      final refs = await directory.getEmployees(wanted);
      return {for (final ref in refs) ref.id: ref.name};
    } catch (_) {
      return const {};
    }
  }

  Future<Map<String, String>> _teamNames(
    String companyId,
    Iterable<String> ids,
  ) async {
    final wanted = {
      for (final id in ids)
        if (id.isNotEmpty) id,
    };
    if (wanted.isEmpty) return const {};
    final placeholders = List.filled(wanted.length, '?').join(',');
    final rows = await _db
        .customSelect(
          'SELECT id, name FROM service_teams WHERE company_id=? AND id IN ($placeholders)',
          variables: [Variable(companyId), ...wanted.map(Variable.new)],
        )
        .get();
    return {
      for (final row in rows) row.read<String>('id'): row.read<String>('name'),
    };
  }
}
