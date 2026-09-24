import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment_repository.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment_scope.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/notifications/domain/app_notification.dart';
import 'package:modular_erp/platform/notifications/domain/notification_repository.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';
import 'package:modular_erp/shared/transactions/domain/attachment_repository.dart';
import 'package:modular_erp/shared/transactions/domain/document_number.dart';
import 'package:modular_erp/shared/transactions/domain/document_number_service.dart';

/// Local (Drift) implementation of the Job Assignment & Scheduling transaction.
///
/// Create/update/cancel run in one database transaction: sequence allocation +
/// header + work lines + the Enquiry OPEN→ASSIGNED transition + activity +
/// outbox (+ assignment notifications). A failure leaves no partial state.
class LocalServiceJobAssignmentRepository
    implements ServiceJobAssignmentRepository {
  LocalServiceJobAssignmentRepository(
    this.db,
    this.clock,
    this.numbers,
    this.activity,
    this.attachments,
    this.workforce,
    this.time, {
    NotificationRepository? notifications,
    ServiceJobAssignmentScopeResolver scopeResolver =
        const ServiceJobAssignmentScopeResolver(),
    Uuid? uuid,
  }) : _notifications = notifications,
       _scopeResolver = scopeResolver,
       _uuid = uuid ?? const Uuid();

  final AppDatabase db;
  final AppClock clock;
  final DocumentNumberService numbers;
  final ActivityRepository activity;
  final AttachmentRepository attachments;
  final WorkforceDirectory workforce;
  final CompanyTimeService time;
  final NotificationRepository? _notifications;
  final ServiceJobAssignmentScopeResolver _scopeResolver;
  final Uuid _uuid;

  static const _table = 'service_job_assignments';
  static const _lineTable = 'service_job_assignment_lines';
  static const _detailOwnerType = 'serviceEnquiryDetail';
  static const _maxWork = 500;
  static const _maxDescription = 2000;

  // ---------------------------------------------------------------- access

  Failure? _denied() => const Failure(code: 'servicesJobAssignmentDenied');

  bool _enabled(AuthContext context) =>
      context.user.status == AccountStatus.active &&
      context.user.companyId == context.company.id &&
      context.company.enabledModules.contains('services');

  bool _can(AuthContext context, AppPermission permission) =>
      context.user.permissions.contains(permission);

  ServiceJobAssignmentScope _scope(AuthContext context) =>
      _scopeResolver.resolve(context);

  Failure? _viewAccess(AuthContext context) =>
      _enabled(context) && _scope(context) != ServiceJobAssignmentScope.none
      ? null
      : _denied();

  Failure? _actionAccess(AuthContext context, AppPermission permission) =>
      _enabled(context) && _can(context, permission) ? null : _denied();

  Failure? _referenceAccess(AuthContext context) =>
      _enabled(context) &&
          (_can(context, AppPermission.serviceJobAssignmentCreate) ||
              _can(context, AppPermission.serviceJobAssignmentEdit))
      ? null
      : _denied();

  // ------------------------------------------------------------- read model

  static const _listColumns =
      'a.*, e.enquiry_number, e.party_snapshot, '
      'pr.name AS priority_name, pr.rank AS priority_rank';

  static const _listJoins =
      'LEFT JOIN service_enquiries e ON e.id=a.source_enquiry_id AND e.company_id=a.company_id '
      'LEFT JOIN service_priorities pr ON pr.id=e.priority_id AND pr.company_id=e.company_id';

  Set<ResultSetImplementation> get _reads => {
    db.serviceJobAssignments,
    db.serviceJobAssignmentLines,
    db.serviceEnquiries,
    db.servicePriorities,
  };

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

  ({String sql, List<Variable> variables}) _scopeClause(AuthContext context) {
    switch (_scope(context)) {
      case ServiceJobAssignmentScope.all:
        return (
          sql: 'a.company_id=?',
          variables: [Variable(context.company.id)],
        );
      case ServiceJobAssignmentScope.team:
      case ServiceJobAssignmentScope.assigned:
        final employeeId = context.employeeReference?.id;
        if (employeeId == null) return (sql: '0', variables: const []);
        const teamExists =
            "EXISTS (SELECT 1 FROM service_job_assignment_lines l WHERE l.assignment_id=a.id AND l.company_id=a.company_id AND l.removed_at IS NULL AND l.assigned_team_id IN (SELECT tm.team_id FROM service_team_members tm WHERE tm.company_id=a.company_id AND tm.employee_id=? AND tm.status='active'))";
        if (_scope(context) == ServiceJobAssignmentScope.team) {
          return (
            sql: 'a.company_id=? AND $teamExists',
            variables: [Variable(context.company.id), Variable(employeeId)],
          );
        }
        const employeeExists =
            "EXISTS (SELECT 1 FROM service_job_assignment_lines l WHERE l.assignment_id=a.id AND l.company_id=a.company_id AND l.removed_at IS NULL AND l.assigned_employee_id=?)";
        return (
          sql: 'a.company_id=? AND ($employeeExists OR $teamExists)',
          variables: [
            Variable(context.company.id),
            Variable(employeeId),
            Variable(employeeId),
          ],
        );
      case ServiceJobAssignmentScope.none:
        return (sql: '0', variables: const []);
    }
  }

  ({String sql, List<Variable> variables}) _where(
    AuthContext context, {
    String query = '',
    ServiceJobAssignmentStatus? status,
    String? priorityId,
    String? teamId,
    String? employeeId,
    DateTime? visitFrom,
    DateTime? visitTo,
  }) {
    final scope = _scopeClause(context);
    final parts = <String>[scope.sql];
    final variables = <Variable>[...scope.variables];
    if (status != null) {
      parts.add('a.status=?');
      variables.add(Variable(status.wire));
    }
    if (priorityId != null) {
      parts.add('e.priority_id=?');
      variables.add(Variable(priorityId));
    }
    if (visitFrom != null) {
      parts.add('a.scheduled_visit_date>=?');
      variables.add(Variable(visitFrom));
    }
    if (visitTo != null) {
      parts.add('a.scheduled_visit_date<=?');
      variables.add(Variable(visitTo));
    }
    if (teamId != null) {
      parts.add(
        "EXISTS (SELECT 1 FROM service_job_assignment_lines l WHERE l.assignment_id=a.id AND l.company_id=a.company_id AND l.removed_at IS NULL AND l.assigned_team_id=?)",
      );
      variables.add(Variable(teamId));
    }
    if (employeeId != null) {
      parts.add(
        "EXISTS (SELECT 1 FROM service_job_assignment_lines l WHERE l.assignment_id=a.id AND l.company_id=a.company_id AND l.removed_at IS NULL AND l.assigned_employee_id=?)",
      );
      variables.add(Variable(employeeId));
    }
    if (query.trim().isNotEmpty) {
      final escaped = query
          .trim()
          .toLowerCase()
          .replaceAll('\\', '\\\\')
          .replaceAll('%', '\\%')
          .replaceAll('_', '\\_');
      parts.add(
        "(lower(a.assignment_number) LIKE ? ESCAPE '\\' OR a.search_text LIKE ? ESCAPE '\\' OR lower(COALESCE(e.enquiry_number,'')) LIKE ? ESCAPE '\\')",
      );
      variables.addAll([
        Variable('%$escaped%'),
        Variable('%$escaped%'),
        Variable('%$escaped%'),
      ]);
    }
    return (sql: parts.join(' AND '), variables: variables);
  }

  Future<int> _count(
    AuthContext context,
    ({String sql, List<Variable> variables}) where,
  ) async {
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM $_table a $_listJoins WHERE ${where.sql}',
          variables: where.variables,
        )
        .getSingle();
    return row.read<int>('c');
  }

  ServiceJobAssignment _record(
    QueryRow row, {
    List<ServiceJobAssignmentLine> lines = const [],
  }) => ServiceJobAssignment(
    id: row.read<String>('id'),
    companyId: row.read<String>('company_id'),
    assignmentNumber: row.read<String>('assignment_number'),
    assignmentDate: row.read<DateTime>('assignment_date').toUtc(),
    sourceEnquiryId: row.read<String>('source_enquiry_id'),
    scheduledVisitDate: row.read<DateTime>('scheduled_visit_date').toUtc(),
    status: ServiceJobAssignmentStatusX.fromWire(row.read<String>('status')),
    lines: lines,
    version: row.read<int>('version'),
    createdAt: row.read<DateTime>('created_at').toUtc(),
    updatedAt: row.read<DateTime>('updated_at').toUtc(),
    createdByUserId: row.read<String>('created_by_user_id'),
    updatedByUserId: row.read<String>('updated_by_user_id'),
    requestId: row.readNullable<String>('request_id'),
    syncStatus: RecordSyncStatus.values.byName(row.read<String>('sync_status')),
  );

  ServiceJobAssignmentLine _line(QueryRow row) => ServiceJobAssignmentLine(
    id: row.read<String>('id'),
    companyId: row.read<String>('company_id'),
    assignmentId: row.read<String>('assignment_id'),
    lineNumber: row.read<int>('line_number'),
    work: row.read<String>('work'),
    assignedEmployeeId: row.readNullable<String>('assigned_employee_id'),
    assignedTeamId: row.readNullable<String>('assigned_team_id'),
    status: ServiceJobAssignmentLineStatusX.fromWire(
      row.read<String>('status'),
    ),
    descriptionForWork: row.read<String>('description_for_work'),
    createdAt: row.read<DateTime>('created_at').toUtc(),
    updatedAt: row.read<DateTime>('updated_at').toUtc(),
    createdByUserId: row.read<String>('created_by_user_id'),
    updatedByUserId: row.read<String>('updated_by_user_id'),
    syncStatus: RecordSyncStatus.values.byName(row.read<String>('sync_status')),
  );

  Future<List<ServiceJobAssignmentLine>> _loadLines(
    String companyId,
    String assignmentId,
  ) async {
    final rows = await db
        .customSelect(
          'SELECT * FROM $_lineTable WHERE company_id=? AND assignment_id=? '
          'AND removed_at IS NULL ORDER BY line_number, id',
          variables: [Variable(companyId), Variable(assignmentId)],
        )
        .get();
    return [for (final row in rows) _line(row)];
  }

  Future<Map<String, List<ServiceJobAssignmentLine>>> _linesByAssignment(
    String companyId,
    List<String> assignmentIds,
  ) async {
    if (assignmentIds.isEmpty) return const {};
    final placeholders = List.filled(assignmentIds.length, '?').join(',');
    final rows = await db
        .customSelect(
          'SELECT * FROM $_lineTable WHERE company_id=? AND assignment_id IN ($placeholders) '
          'AND removed_at IS NULL ORDER BY line_number, id',
          variables: [
            Variable(companyId),
            ...assignmentIds.map((id) => Variable(id)),
          ],
        )
        .get();
    final map = <String, List<ServiceJobAssignmentLine>>{};
    for (final row in rows) {
      map
          .putIfAbsent(row.read<String>('assignment_id'), () => [])
          .add(_line(row));
    }
    return map;
  }

  Future<Map<String, String>> _employeeNames(
    Iterable<String> employeeIds,
  ) async {
    final ids = {
      for (final id in employeeIds)
        if (id.isNotEmpty) id,
    };
    if (ids.isEmpty) return const {};
    final refs = await workforce.getEmployees(ids);
    return {for (final ref in refs) ref.id: ref.name};
  }

  Future<Map<String, String>> _teamNames(
    String companyId,
    Iterable<String> teamIds,
  ) async {
    final ids = {
      for (final id in teamIds)
        if (id.isNotEmpty) id,
    };
    if (ids.isEmpty) return const {};
    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await db
        .customSelect(
          'SELECT id, name FROM service_teams WHERE company_id=? AND id IN ($placeholders)',
          variables: [Variable(companyId), ...ids.map((id) => Variable(id))],
        )
        .get();
    return {
      for (final row in rows) row.read<String>('id'): row.read<String>('name'),
    };
  }

  String _assignedSummary(
    List<ServiceJobAssignmentLine> lines,
    Map<String, String> employeeNames,
    Map<String, String> teamNames,
  ) {
    final labels = <String>[];
    for (final line in lines) {
      final employee = line.assignedEmployeeId == null
          ? null
          : employeeNames[line.assignedEmployeeId!];
      final team = line.assignedTeamId == null
          ? null
          : teamNames[line.assignedTeamId!];
      if (employee != null && !labels.contains(employee)) labels.add(employee);
      if (team != null && !labels.contains(team)) labels.add(team);
    }
    if (labels.isEmpty) return '';
    if (labels.length <= 2) return labels.join(' + ');
    return '${labels.take(2).join(' + ')} +${labels.length - 2}';
  }

  ServiceJobAssignmentListItem _listItem(
    QueryRow row,
    List<ServiceJobAssignmentLine> lines,
    Map<String, String> employeeNames,
    Map<String, String> teamNames,
  ) {
    final snapshot = _snapshot(row.readNullable<String>('party_snapshot'));
    final site = [
      snapshot.buildingName,
      snapshot.unitNumber,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' / ');
    return ServiceJobAssignmentListItem(
      id: row.read<String>('id'),
      assignmentNumber: row.read<String>('assignment_number'),
      createdAt: row.read<DateTime>('created_at').toUtc(),
      scheduledVisitDate: row.read<DateTime>('scheduled_visit_date').toUtc(),
      status: ServiceJobAssignmentStatusX.fromWire(row.read<String>('status')),
      enquiryNumber: row.readNullable<String>('enquiry_number') ?? '',
      customerName: snapshot.customerName ?? '',
      customerMobile: snapshot.customerMobile,
      siteSummary: site.isEmpty ? (snapshot.siteName ?? '') : site,
      priorityName: row.readNullable<String>('priority_name') ?? '',
      priorityRank: row.readNullable<int>('priority_rank') ?? 0,
      assignedSummary: _assignedSummary(lines, employeeNames, teamNames),
    );
  }

  Stream<Result<ServiceJobAssignmentPage>> _watchPage(
    AuthContext context, {
    required ({String sql, List<Variable> variables}) where,
    required int page,
    required int limit,
  }) {
    final sql =
        'SELECT $_listColumns FROM $_table a $_listJoins '
        'WHERE ${where.sql} '
        'ORDER BY a.scheduled_visit_date DESC, a.created_at DESC, a.id DESC '
        'LIMIT ? OFFSET ?';
    return db
        .customSelect(
          sql,
          variables: [
            ...where.variables,
            Variable(limit.clamp(1, 200)),
            Variable(page.clamp(0, 1000000) * limit.clamp(1, 200)),
          ],
          readsFrom: _reads,
        )
        .watch()
        .asyncMap<Result<ServiceJobAssignmentPage>>((rows) async {
          final total = await _count(context, (
            sql: _scopeClause(context).sql,
            variables: _scopeClause(context).variables,
          ));
          final filtered = await _count(context, where);
          final ids = [for (final row in rows) row.read<String>('id')];
          final linesByAssignment = await _linesByAssignment(
            context.company.id,
            ids,
          );
          final allLines = [
            for (final list in linesByAssignment.values) ...list,
          ];
          final employeeNames = await _employeeNames(
            allLines.map((l) => l.assignedEmployeeId ?? ''),
          );
          final teamNames = await _teamNames(
            context.company.id,
            allLines.map((l) => l.assignedTeamId ?? ''),
          );
          return Success(
            ServiceJobAssignmentPage(
              [
                for (final row in rows)
                  _listItem(
                    row,
                    linesByAssignment[row.read<String>('id')] ?? const [],
                    employeeNames,
                    teamNames,
                  ),
              ],
              total,
              filtered,
            ),
          );
        })
        .transform(
          StreamTransformer<
            Result<ServiceJobAssignmentPage>,
            Result<ServiceJobAssignmentPage>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceJobAssignmentPage>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  @override
  Stream<Result<ServiceJobAssignmentPage>> watchAssignments(
    AuthContext context, {
    String query = '',
    ServiceJobAssignmentStatus? status,
    String? priorityId,
    String? teamId,
    String? employeeId,
    DateTime? visitFrom,
    DateTime? visitTo,
    int page = 0,
    int pageSize = 10,
  }) {
    final failure = _viewAccess(context);
    if (failure != null) return Stream.value(Failed(failure));
    return _watchPage(
      context,
      where: _where(
        context,
        query: query,
        status: status,
        priorityId: priorityId,
        teamId: teamId,
        employeeId: employeeId,
        visitFrom: visitFrom,
        visitTo: visitTo,
      ),
      page: page,
      limit: pageSize,
    );
  }

  Future<QueryRow?> _rawRow(AuthContext context, String id) {
    final scope = _scopeClause(context);
    return db
        .customSelect(
          'SELECT $_listColumns FROM $_table a $_listJoins '
          'WHERE a.id=? AND ${scope.sql}',
          variables: [Variable(id), ...scope.variables],
        )
        .getSingleOrNull();
  }

  Future<ServiceJobAssignmentView> _view(
    AuthContext context,
    QueryRow row,
  ) async {
    final assignmentId = row.read<String>('id');
    final sourceEnquiryId = row.read<String>('source_enquiry_id');
    final lines = await _loadLines(context.company.id, assignmentId);
    final employeeNames = await _employeeNames(
      lines.map((l) => l.assignedEmployeeId ?? ''),
    );
    final employeeRefs = await workforce.getEmployees(
      lines.map((l) => l.assignedEmployeeId ?? '').where((id) => id.isNotEmpty),
    );
    final employeeCodes = {
      for (final ref in employeeRefs) ref.id: ref.employeeCode,
    };
    final teamNames = await _teamNames(
      context.company.id,
      lines.map((l) => l.assignedTeamId ?? ''),
    );
    final lineViews = [
      for (final line in lines)
        ServiceJobAssignmentLineView(
          line: line,
          employeeName: line.assignedEmployeeId == null
              ? null
              : employeeNames[line.assignedEmployeeId!],
          employeeCode: line.assignedEmployeeId == null
              ? null
              : employeeCodes[line.assignedEmployeeId!],
          teamName: line.assignedTeamId == null
              ? null
              : teamNames[line.assignedTeamId!],
        ),
    ];

    final enquiryContext = await _enquiryContext(
      context.company.id,
      sourceEnquiryId,
    );

    return ServiceJobAssignmentView(
      assignment: _record(row, lines: lines),
      lines: lineViews,
      enquiryNumber: row.readNullable<String>('enquiry_number') ?? '',
      customerName: enquiryContext?.customerName ?? '',
      customerMobile: enquiryContext?.customerMobile,
      priorityName: row.readNullable<String>('priority_name') ?? '',
      priorityRank: row.readNullable<int>('priority_rank') ?? 0,
      complaintTypeName: enquiryContext?.complaintTypeName ?? '',
      materialReceived: enquiryContext?.materialReceived ?? MaterialReceived.no,
      partySnapshot:
          enquiryContext?.partySnapshot ?? const ServiceEnquiryPartySnapshot(),
      enquiryDetails: enquiryContext?.details ?? const [],
    );
  }

  Future<ServiceAssignableEnquiryContext?> _enquiryContext(
    String companyId,
    String enquiryId,
  ) async {
    final enquiry = await db
        .customSelect(
          'SELECT enquiry_number, party_snapshot, material_received, complaint_type_id, priority_id '
          'FROM service_enquiries WHERE company_id=? AND id=?',
          variables: [Variable(companyId), Variable(enquiryId)],
        )
        .getSingleOrNull();
    if (enquiry == null) return null;
    final snapshot = _snapshot(enquiry.readNullable<String>('party_snapshot'));

    final detailRows = await db
        .customSelect(
          'SELECT * FROM service_enquiry_details WHERE company_id=? AND enquiry_id=? '
          'AND removed_at IS NULL ORDER BY line_number, id',
          variables: [Variable(companyId), Variable(enquiryId)],
        )
        .get();
    final detailIds = [
      for (final detail in detailRows) detail.read<String>('id'),
    ];
    final attachmentsByOwner = await _attachmentsByOwner(companyId, detailIds);
    final details = [
      for (final detail in detailRows)
        ServiceEnquiryDetailLine(
          id: detail.read<String>('id'),
          companyId: detail.read<String>('company_id'),
          enquiryId: detail.read<String>('enquiry_id'),
          lineNumber: detail.read<int>('line_number'),
          description: detail.read<String>('description'),
          status: ServiceEnquiryDetailStatusX.fromWire(
            detail.read<String>('status'),
          ),
          attachments:
              attachmentsByOwner[detail.read<String>('id')] ?? const [],
          createdAt: detail.read<DateTime>('created_at').toUtc(),
          updatedAt: detail.read<DateTime>('updated_at').toUtc(),
          createdByUserId: detail.read<String>('created_by_user_id'),
          updatedByUserId: detail.read<String>('updated_by_user_id'),
          syncStatus: RecordSyncStatus.values.byName(
            detail.read<String>('sync_status'),
          ),
        ),
    ];

    final priority = await _masterName(
      'service_priorities',
      companyId,
      enquiry.readNullable<String>('priority_id'),
    );
    final priorityRank = await _masterRank(
      companyId,
      enquiry.readNullable<String>('priority_id'),
    );

    return ServiceAssignableEnquiryContext(
      enquiryId: enquiryId,
      enquiryNumber: enquiry.read<String>('enquiry_number'),
      customerName: snapshot.customerName ?? '',
      customerMobile: snapshot.customerMobile,
      priorityName: priority,
      priorityRank: priorityRank,
      complaintTypeName: await _complaintTypeName(
        companyId,
        enquiry.readNullable<String>('complaint_type_id'),
      ),
      materialReceived: MaterialReceivedX.fromWire(
        enquiry.readNullable<String>('material_received') ?? 'no',
      ),
      partySnapshot: snapshot,
      details: details,
    );
  }

  Future<String> _masterName(String table, String companyId, String? id) async {
    if (id == null) return '';
    final row = await db
        .customSelect(
          'SELECT name FROM $table WHERE company_id=? AND id=?',
          variables: [Variable(companyId), Variable(id)],
        )
        .getSingleOrNull();
    return row?.read<String>('name') ?? '';
  }

  Future<int> _masterRank(String companyId, String? id) async {
    if (id == null) return 0;
    final row = await db
        .customSelect(
          'SELECT rank FROM service_priorities WHERE company_id=? AND id=?',
          variables: [Variable(companyId), Variable(id)],
        )
        .getSingleOrNull();
    return row?.read<int>('rank') ?? 0;
  }

  @override
  Future<Result<ServiceAssignableEnquiryContext?>> getAssignableEnquiryContext(
    AuthContext context,
    String enquiryId,
  ) async {
    final failure = _referenceAccess(context);
    if (failure != null) return Failed(failure);
    try {
      return Success(await _enquiryContext(context.company.id, enquiryId));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  Future<Map<String, List<AttachmentRef>>> _attachmentsByOwner(
    String companyId,
    List<String> ownerIds,
  ) async {
    if (ownerIds.isEmpty) return const {};
    final result = await attachments.getForOwners(
      companyId: companyId,
      ownerType: _detailOwnerType,
      ownerIds: ownerIds,
    );
    final refs = result is Success<List<AttachmentRef>>
        ? result.value
        : const <AttachmentRef>[];
    final map = <String, List<AttachmentRef>>{};
    for (final ref in refs) {
      map.putIfAbsent(ref.ownerId, () => []).add(ref);
    }
    return map;
  }

  Future<String> _complaintTypeName(String companyId, String? id) async {
    if (id == null) return '';
    final row = await db
        .customSelect(
          'SELECT name FROM complaint_types WHERE company_id=? AND id=?',
          variables: [Variable(companyId), Variable(id)],
        )
        .getSingleOrNull();
    return row?.read<String>('name') ?? '';
  }

  @override
  Stream<Result<ServiceJobAssignmentView?>> watchAssignment(
    AuthContext context,
    String id,
  ) {
    final failure = _viewAccess(context);
    if (failure != null) return Stream.value(Failed(failure));
    final scope = _scopeClause(context);
    return db
        .customSelect(
          'SELECT $_listColumns FROM $_table a $_listJoins '
          'WHERE a.id=? AND ${scope.sql}',
          variables: [Variable(id), ...scope.variables],
          readsFrom: {..._reads, db.serviceEnquiryDetails},
        )
        .watchSingleOrNull()
        .asyncMap<Result<ServiceJobAssignmentView?>>((row) async {
          if (row == null) {
            return const Success<ServiceJobAssignmentView?>(null);
          }
          return Success<ServiceJobAssignmentView?>(await _view(context, row));
        })
        .transform(
          StreamTransformer<
            Result<ServiceJobAssignmentView?>,
            Result<ServiceJobAssignmentView?>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceJobAssignmentView?>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  @override
  Future<Result<ServiceJobAssignmentView?>> getAssignment(
    AuthContext context,
    String id,
  ) async {
    final failure = _viewAccess(context);
    if (failure != null) return Failed(failure);
    try {
      final row = await _rawRow(context, id);
      if (row == null) return const Success(null);
      return Success(await _view(context, row));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  // ------------------------------------------------------------- mutations

  Failure? _validateDraft(ServiceJobAssignmentDraft draft) {
    if (draft.sourceEnquiryId == null) {
      return const Failure(code: 'servicesJobAssignmentEnquiryRequired');
    }
    if (draft.scheduledVisitDate == null) {
      return const Failure(code: 'servicesJobAssignmentVisitDateRequired');
    }
    if (draft.lines.isEmpty) {
      return const Failure(code: 'servicesJobAssignmentLinesRequired');
    }
    for (final line in draft.lines) {
      if (line.work.trim().isEmpty) {
        return const Failure(code: 'servicesJobAssignmentWorkRequired');
      }
      if (line.work.trim().length > _maxWork) {
        return const Failure(code: 'servicesJobAssignmentWorkTooLong');
      }
      if (line.descriptionForWork.trim().length > _maxDescription) {
        return const Failure(code: 'servicesJobAssignmentDescriptionTooLong');
      }
      if (line.assignedEmployeeId == null && line.assignedTeamId == null) {
        return const Failure(code: 'servicesJobAssignmentTargetRequired');
      }
    }
    return null;
  }

  Future<QueryRow?> _enquiryRow(String companyId, String id) => db
      .customSelect(
        'SELECT id, status FROM service_enquiries WHERE company_id=? AND id=?',
        variables: [Variable(companyId), Variable(id)],
      )
      .getSingleOrNull();

  Future<QueryRow?> _teamRow(String companyId, String id) => db
      .customSelect(
        'SELECT id, name, status, lead_employee_id FROM service_teams '
        'WHERE company_id=? AND id=?',
        variables: [Variable(companyId), Variable(id)],
      )
      .getSingleOrNull();

  Future<bool> _isTeamMember(
    String companyId,
    String teamId,
    String employeeId,
  ) async {
    final rows = await db
        .customSelect(
          "SELECT 1 FROM service_team_members WHERE company_id=? AND team_id=? "
          "AND employee_id=? AND status='active' LIMIT 1",
          variables: [
            Variable(companyId),
            Variable(teamId),
            Variable(employeeId),
          ],
        )
        .get();
    return rows.isNotEmpty;
  }

  /// Validates references and returns the resolved names for search text.
  Future<({List<String> employeeNames, List<String> teamNames})>
  _validateReferences(
    AuthContext context,
    ServiceJobAssignmentDraft draft,
  ) async {
    final companyId = context.company.id;
    final employeeNames = <String>[];
    final teamNames = <String>[];
    for (final line in draft.lines) {
      final employeeId = line.assignedEmployeeId;
      final teamId = line.assignedTeamId;
      if (employeeId != null) {
        final ref = await workforce.getEmployeeReference(employeeId);
        if (ref == null) {
          throw const _AssignmentException(
            'servicesJobAssignmentEmployeeInvalid',
          );
        }
        employeeNames.add(ref.name);
      }
      if (teamId != null) {
        final team = await _teamRow(companyId, teamId);
        if (team == null ||
            team.read<String>('status') != ConfigurationStatus.active.name) {
          throw const _AssignmentException('servicesJobAssignmentTeamInvalid');
        }
        teamNames.add(team.read<String>('name'));
      }
      if (employeeId != null && teamId != null) {
        if (!await _isTeamMember(companyId, teamId, employeeId)) {
          throw const _AssignmentException(
            'servicesJobAssignmentEmployeeNotInTeam',
          );
        }
      }
    }
    return (employeeNames: employeeNames, teamNames: teamNames);
  }

  DateTime _companyDate(AuthContext context) {
    final local = time.localWallTime(clock.now(), context.company.timezone);
    final wall = local is Success<DateTime> ? local.value : clock.now().toUtc();
    return DateTime.utc(wall.year, wall.month, wall.day);
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime.utc(value.year, value.month, value.day);

  String _searchText(
    String assignmentNumber,
    String enquiryNumber,
    ServiceEnquiryPartySnapshot snapshot,
    List<String> employeeNames,
    List<String> teamNames,
  ) =>
      [
            assignmentNumber,
            enquiryNumber,
            snapshot.customerName,
            snapshot.customerMobile,
            snapshot.siteName,
            snapshot.buildingName,
            snapshot.unitNumber,
            ...employeeNames,
            ...teamNames,
          ]
          .whereType<String>()
          .where((v) => v.trim().isNotEmpty)
          .join(' ')
          .toLowerCase();

  Future<String?> _requestEntity(String companyId, String requestId) async {
    final row =
        await (db.select(db.syncOutbox)
              ..where(
                (t) =>
                    t.requestId.equals(requestId) &
                    t.companyId.equals(companyId),
              )
              ..limit(1))
            .getSingleOrNull();
    return row?.entityId;
  }

  @override
  Future<Result<ServiceJobAssignment>> createAssignment(
    AuthContext context,
    ServiceJobAssignmentDraft draft, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceJobAssignmentCreate,
    );
    if (failure != null) return Failed(failure);
    final invalid = _validateDraft(draft);
    if (invalid != null) return Failed(invalid);
    final effectiveRequest = requestId ?? _uuid.v4();
    try {
      return Success(
        await db.transaction(() async {
          final existingId = await _requestEntity(
            context.company.id,
            effectiveRequest,
          );
          if (existingId != null) {
            final row = await _rawRow(context, existingId);
            if (row != null) {
              return _record(
                row,
                lines: await _loadLines(context.company.id, existingId),
              );
            }
          }
          final enquiry = await _enquiryRow(
            context.company.id,
            draft.sourceEnquiryId!,
          );
          if (enquiry == null) {
            throw const _AssignmentException(
              'servicesJobAssignmentEnquiryNotFound',
            );
          }
          if (enquiry.read<String>('status') !=
              ServiceEnquiryStatus.open.wire) {
            final active = await db
                .customSelect(
                  "SELECT 1 FROM $_table WHERE company_id=? AND source_enquiry_id=? AND status='active' LIMIT 1",
                  variables: [
                    Variable(context.company.id),
                    Variable(draft.sourceEnquiryId!),
                  ],
                )
                .get();
            if (active.isNotEmpty) {
              throw const _AssignmentException(
                'servicesJobAssignmentAlreadyActive',
              );
            }
            throw const _AssignmentException(
              'servicesJobAssignmentEnquiryNotOpen',
            );
          }
          final active = await db
              .customSelect(
                "SELECT 1 FROM $_table WHERE company_id=? AND source_enquiry_id=? AND status='active' LIMIT 1",
                variables: [
                  Variable(context.company.id),
                  Variable(draft.sourceEnquiryId!),
                ],
              )
              .get();
          if (active.isNotEmpty) {
            throw const _AssignmentException(
              'servicesJobAssignmentAlreadyActive',
            );
          }
          final names = await _validateReferences(context, draft);
          final now = clock.now();
          final numberResult = await numbers.nextNumber(
            companyId: context.company.id,
            type: DocumentSequenceType.serviceJobAssignment,
          );
          final number = switch (numberResult) {
            Success<String>(:final value) => value,
            Failed<String>() => throw const _AssignmentException(
              'servicesJobAssignmentSequenceFailed',
            ),
          };
          final enquiryRow = await db
              .customSelect(
                'SELECT enquiry_number, party_snapshot FROM service_enquiries WHERE company_id=? AND id=?',
                variables: [
                  Variable(context.company.id),
                  Variable(draft.sourceEnquiryId!),
                ],
              )
              .getSingle();
          final enquiryNumber = enquiryRow.read<String>('enquiry_number');
          final snapshot = _snapshot(
            enquiryRow.readNullable<String>('party_snapshot'),
          );
          final assignmentId = _uuid.v4();
          final assignment = ServiceJobAssignment(
            id: assignmentId,
            companyId: context.company.id,
            assignmentNumber: number,
            assignmentDate: _companyDate(context),
            sourceEnquiryId: draft.sourceEnquiryId!,
            scheduledVisitDate: _dateOnly(draft.scheduledVisitDate!),
            status: ServiceJobAssignmentStatus.active,
            version: 1,
            createdAt: now,
            updatedAt: now,
            createdByUserId: context.user.id,
            updatedByUserId: context.user.id,
            requestId: effectiveRequest,
            syncStatus: RecordSyncStatus.pending,
          );
          await _insertHeader(
            assignment,
            searchText: _searchText(
              number,
              enquiryNumber,
              snapshot,
              names.employeeNames,
              names.teamNames,
            ),
          );
          final lines = await _insertLines(
            context,
            assignmentId,
            draft.lines,
            now,
          );
          await _assignEnquiry(context, draft.sourceEnquiryId!, now);
          final created = ServiceJobAssignment(
            id: assignment.id,
            companyId: assignment.companyId,
            assignmentNumber: assignment.assignmentNumber,
            assignmentDate: assignment.assignmentDate,
            sourceEnquiryId: assignment.sourceEnquiryId,
            scheduledVisitDate: assignment.scheduledVisitDate,
            status: assignment.status,
            lines: lines,
            version: assignment.version,
            createdAt: assignment.createdAt,
            updatedAt: assignment.updatedAt,
            createdByUserId: assignment.createdByUserId,
            updatedByUserId: assignment.updatedByUserId,
            requestId: assignment.requestId,
            syncStatus: assignment.syncStatus,
          );
          await _activity(context, created, 'services.jobAssignment.created');
          await _enqueue(
            context,
            created,
            'SERVICES_JOB_ASSIGNMENT_CREATE',
            effectiveRequest,
          );
          await _notifyTargets(context, created);
          return created;
        }),
      );
    } on _AssignmentException catch (e) {
      return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  Future<List<ServiceJobAssignmentLine>> _insertLines(
    AuthContext context,
    String assignmentId,
    List<ServiceJobAssignmentLineDraft> drafts,
    DateTime now,
  ) async {
    final lines = <ServiceJobAssignmentLine>[];
    var order = 0;
    for (final draft in drafts) {
      order++;
      final line = ServiceJobAssignmentLine(
        id: draft.id,
        companyId: context.company.id,
        assignmentId: assignmentId,
        lineNumber: order,
        work: draft.work.trim(),
        assignedEmployeeId: draft.assignedEmployeeId,
        assignedTeamId: draft.assignedTeamId,
        status: draft.status,
        descriptionForWork: draft.descriptionForWork.trim(),
        createdAt: now,
        updatedAt: now,
        createdByUserId: context.user.id,
        updatedByUserId: context.user.id,
        syncStatus: RecordSyncStatus.pending,
      );
      await db
          .into(db.serviceJobAssignmentLines)
          .insert(
            ServiceJobAssignmentLinesCompanion.insert(
              id: line.id,
              companyId: line.companyId,
              assignmentId: line.assignmentId,
              lineNumber: line.lineNumber,
              work: line.work,
              assignedEmployeeId: Value(line.assignedEmployeeId),
              assignedTeamId: Value(line.assignedTeamId),
              status: line.status.wire,
              descriptionForWork: Value(line.descriptionForWork),
              createdAt: line.createdAt,
              updatedAt: line.updatedAt,
              createdByUserId: line.createdByUserId,
              updatedByUserId: line.updatedByUserId,
              syncStatus: line.syncStatus.name,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      lines.add(line);
    }
    return lines;
  }

  Future<void> _assignEnquiry(
    AuthContext context,
    String enquiryId,
    DateTime now,
  ) async {
    await db.customUpdate(
      "UPDATE service_enquiries SET status='assigned', version=version+1, "
      'updated_at=?, updated_by_user_id=?, sync_status=? '
      "WHERE company_id=? AND id=? AND status='open'",
      variables: [
        Variable(now),
        Variable(context.user.id),
        Variable('pending'),
        Variable(context.company.id),
        Variable(enquiryId),
      ],
    );
    await activity.append(
      BusinessActivityEvent(
        id: _uuid.v4(),
        companyId: context.company.id,
        moduleKey: 'services',
        entityType: 'serviceEnquiry',
        entityId: enquiryId,
        eventType: 'services.enquiry.assigned',
        occurredAt: now,
        actorUserId: context.user.id,
        actorEmployeeId: context.employeeReference?.id,
        syncStatus: 'pending',
        metadata: {'status': ServiceEnquiryStatus.assigned.wire},
      ),
    );
  }

  @override
  Future<Result<ServiceJobAssignment>> updateAssignment(
    AuthContext context,
    String id,
    ServiceJobAssignmentDraft draft, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceJobAssignmentEdit,
    );
    if (failure != null) return Failed(failure);
    final invalid = _validateDraft(draft);
    if (invalid != null) return Failed(invalid);
    try {
      return Success(
        await db.transaction(() async {
          final row = await _rawRow(context, id);
          if (row == null) {
            throw const _AssignmentException('servicesJobAssignmentNotFound');
          }
          final previous = _record(row);
          if (!previous.isActive) {
            throw const _AssignmentException(
              'servicesJobAssignmentNotEditable',
            );
          }
          final effectiveRequest = requestId ?? _uuid.v4();
          final existingId = await _requestEntity(
            context.company.id,
            effectiveRequest,
          );
          if (existingId != null) {
            return _record(
              row,
              lines: await _loadLines(context.company.id, id),
            );
          }
          final names = await _validateReferences(context, draft);
          final now = clock.now();
          final existingLines = await db
              .customSelect(
                'SELECT id FROM $_lineTable WHERE company_id=? AND assignment_id=? AND removed_at IS NULL',
                variables: [Variable(context.company.id), Variable(id)],
              )
              .get();
          final existingIds = {
            for (final line in existingLines) line.read<String>('id'),
          };
          final draftIds = {for (final line in draft.lines) line.id};
          final removed = existingIds.difference(draftIds).toList();
          if (removed.isNotEmpty) {
            await (db.update(db.serviceJobAssignmentLines)..where(
                  (t) =>
                      t.companyId.equals(context.company.id) &
                      t.assignmentId.equals(id) &
                      t.id.isIn(removed),
                ))
                .write(
                  ServiceJobAssignmentLinesCompanion(
                    removedAt: Value(now),
                    updatedAt: Value(now),
                    updatedByUserId: Value(context.user.id),
                    syncStatus: const Value('pending'),
                  ),
                );
          }
          var order = 0;
          for (final line in draft.lines) {
            order++;
            if (existingIds.contains(line.id)) {
              await (db.update(db.serviceJobAssignmentLines)..where(
                    (t) =>
                        t.id.equals(line.id) &
                        t.companyId.equals(context.company.id) &
                        t.assignmentId.equals(id),
                  ))
                  .write(
                    ServiceJobAssignmentLinesCompanion(
                      lineNumber: Value(order),
                      work: Value(line.work.trim()),
                      assignedEmployeeId: Value(line.assignedEmployeeId),
                      assignedTeamId: Value(line.assignedTeamId),
                      status: Value(line.status.wire),
                      descriptionForWork: Value(line.descriptionForWork.trim()),
                      removedAt: const Value(null),
                      updatedAt: Value(now),
                      updatedByUserId: Value(context.user.id),
                      syncStatus: const Value('pending'),
                    ),
                  );
            } else {
              await _insertLines(context, id, [line], now);
            }
          }
          final visitChanged =
              _dateOnly(draft.scheduledVisitDate!) !=
              previous.scheduledVisitDate;
          final enquiryRow = await db
              .customSelect(
                'SELECT enquiry_number, party_snapshot FROM service_enquiries WHERE company_id=? AND id=?',
                variables: [
                  Variable(context.company.id),
                  Variable(previous.sourceEnquiryId),
                ],
              )
              .getSingleOrNull();
          final enquiryNumber =
              enquiryRow?.read<String>('enquiry_number') ?? '';
          final snapshot = _snapshot(
            enquiryRow?.readNullable<String>('party_snapshot'),
          );
          await (db.update(db.serviceJobAssignments)..where(
                (t) => t.id.equals(id) & t.companyId.equals(context.company.id),
              ))
              .write(
                ServiceJobAssignmentsCompanion(
                  scheduledVisitDate: Value(
                    _dateOnly(draft.scheduledVisitDate!),
                  ),
                  searchText: Value(
                    _searchText(
                      previous.assignmentNumber,
                      enquiryNumber,
                      snapshot,
                      names.employeeNames,
                      names.teamNames,
                    ),
                  ),
                  version: Value(previous.version + 1),
                  updatedAt: Value(now),
                  updatedByUserId: Value(context.user.id),
                  syncStatus: const Value('pending'),
                ),
              );
          final lines = await _loadLines(context.company.id, id);
          final updated = ServiceJobAssignment(
            id: previous.id,
            companyId: previous.companyId,
            assignmentNumber: previous.assignmentNumber,
            assignmentDate: previous.assignmentDate,
            sourceEnquiryId: previous.sourceEnquiryId,
            scheduledVisitDate: _dateOnly(draft.scheduledVisitDate!),
            status: ServiceJobAssignmentStatus.active,
            lines: lines,
            version: previous.version + 1,
            createdAt: previous.createdAt,
            updatedAt: now,
            createdByUserId: previous.createdByUserId,
            updatedByUserId: context.user.id,
            requestId: previous.requestId,
            syncStatus: RecordSyncStatus.pending,
          );
          await _activity(context, updated, 'services.jobAssignment.updated');
          if (visitChanged) {
            await _activity(
              context,
              updated,
              'services.jobAssignment.visitDateChanged',
            );
          }
          await _activity(
            context,
            updated,
            'services.jobAssignment.assignmentChanged',
          );
          await _enqueue(
            context,
            updated,
            'SERVICES_JOB_ASSIGNMENT_UPDATE',
            effectiveRequest,
          );
          await _notifyTargets(context, updated);
          return updated;
        }),
      );
    } on _AssignmentException catch (e) {
      return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<void>> cancelAssignment(
    AuthContext context,
    String id, {
    String? requestId,
    String? reason,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceJobAssignmentCancel,
    );
    if (failure != null) return Failed(failure);
    try {
      await db.transaction(() async {
        final row = await _rawRow(context, id);
        if (row == null) {
          throw const _AssignmentException('servicesJobAssignmentNotFound');
        }
        final previous = _record(row);
        if (!previous.isActive) {
          throw const _AssignmentException(
            'servicesJobAssignmentAlreadyCancelled',
          );
        }
        final effectiveRequest = requestId ?? _uuid.v4();
        final existingId = await _requestEntity(
          context.company.id,
          effectiveRequest,
        );
        if (existingId != null) return;
        final now = clock.now();
        await (db.update(db.serviceJobAssignments)..where(
              (t) => t.id.equals(id) & t.companyId.equals(context.company.id),
            ))
            .write(
              ServiceJobAssignmentsCompanion(
                status: Value(ServiceJobAssignmentStatus.cancelled.wire),
                version: Value(previous.version + 1),
                updatedAt: Value(now),
                updatedByUserId: Value(context.user.id),
                syncStatus: const Value('pending'),
              ),
            );
        // Return the enquiry to OPEN when no other active assignment remains.
        final others = await db
            .customSelect(
              "SELECT 1 FROM $_table WHERE company_id=? AND source_enquiry_id=? AND status='active' AND id<>? LIMIT 1",
              variables: [
                Variable(context.company.id),
                Variable(previous.sourceEnquiryId),
                Variable(id),
              ],
            )
            .get();
        if (others.isEmpty) {
          await db.customUpdate(
            "UPDATE service_enquiries SET status='open', version=version+1, "
            'updated_at=?, updated_by_user_id=?, sync_status=? '
            "WHERE company_id=? AND id=? AND status='assigned'",
            variables: [
              Variable(now),
              Variable(context.user.id),
              Variable('pending'),
              Variable(context.company.id),
              Variable(previous.sourceEnquiryId),
            ],
          );
          await activity.append(
            BusinessActivityEvent(
              id: _uuid.v4(),
              companyId: context.company.id,
              moduleKey: 'services',
              entityType: 'serviceEnquiry',
              entityId: previous.sourceEnquiryId,
              eventType: 'services.enquiry.reopened',
              occurredAt: now,
              actorUserId: context.user.id,
              actorEmployeeId: context.employeeReference?.id,
              syncStatus: 'pending',
              metadata: {'status': ServiceEnquiryStatus.open.wire},
            ),
          );
        }
        final cancelled = ServiceJobAssignment(
          id: previous.id,
          companyId: previous.companyId,
          assignmentNumber: previous.assignmentNumber,
          assignmentDate: previous.assignmentDate,
          sourceEnquiryId: previous.sourceEnquiryId,
          scheduledVisitDate: previous.scheduledVisitDate,
          status: ServiceJobAssignmentStatus.cancelled,
          version: previous.version + 1,
          createdAt: previous.createdAt,
          updatedAt: now,
          createdByUserId: previous.createdByUserId,
          updatedByUserId: context.user.id,
          requestId: previous.requestId,
          syncStatus: RecordSyncStatus.pending,
        );
        await _activity(context, cancelled, 'services.jobAssignment.cancelled');
        await _enqueue(
          context,
          cancelled,
          'SERVICES_JOB_ASSIGNMENT_CANCEL',
          effectiveRequest,
        );
      });
      return const Success(null);
    } on _AssignmentException catch (e) {
      return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  // --------------------------------------------------- restricted references

  @override
  Future<Result<List<ServiceAssignableEnquiryRef>>> searchAssignableEnquiries(
    AuthContext context, {
    String query = '',
    int limit = 30,
  }) async {
    final failure = _referenceAccess(context);
    if (failure != null) return Failed(failure);
    try {
      final escaped = query
          .trim()
          .toLowerCase()
          .replaceAll('\\', '\\\\')
          .replaceAll('%', '\\%')
          .replaceAll('_', '\\_');
      final rows = await db
          .customSelect(
            "SELECT e.id, e.enquiry_number, e.party_snapshot, "
            "ct.name AS complaint_type_name, pr.name AS priority_name, pr.rank AS priority_rank "
            "FROM service_enquiries e "
            "LEFT JOIN complaint_types ct ON ct.id=e.complaint_type_id AND ct.company_id=e.company_id "
            "LEFT JOIN service_priorities pr ON pr.id=e.priority_id AND pr.company_id=e.company_id "
            "WHERE e.company_id=? AND e.status='open' "
            "AND NOT EXISTS (SELECT 1 FROM $_table a WHERE a.company_id=e.company_id AND a.source_enquiry_id=e.id AND a.status='active') "
            "AND (lower(e.enquiry_number) LIKE ? ESCAPE '\\' OR e.search_text LIKE ? ESCAPE '\\') "
            "ORDER BY e.created_at DESC LIMIT ?",
            variables: [
              Variable(context.company.id),
              Variable('%$escaped%'),
              Variable('%$escaped%'),
              Variable(limit.clamp(1, 50)),
            ],
          )
          .get();
      return Success([for (final row in rows) _assignableRef(row)]);
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  ServiceAssignableEnquiryRef _assignableRef(QueryRow row) {
    final snapshot = _snapshot(row.readNullable<String>('party_snapshot'));
    final site = [
      snapshot.buildingName,
      snapshot.unitNumber,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' / ');
    return ServiceAssignableEnquiryRef(
      id: row.read<String>('id'),
      enquiryNumber: row.read<String>('enquiry_number'),
      customerName: snapshot.customerName ?? '',
      customerMobile: snapshot.customerMobile,
      siteSummary: site.isEmpty ? (snapshot.siteName ?? '') : site,
      complaintTypeName: row.readNullable<String>('complaint_type_name') ?? '',
      priorityName: row.readNullable<String>('priority_name') ?? '',
      priorityRank: row.readNullable<int>('priority_rank') ?? 0,
    );
  }

  Future<ServiceJobAssignmentRef?> _assignmentRefForEnquiry(
    AuthContext context,
    String enquiryId,
  ) async {
    final scope = _scopeClause(context);
    final row = await db
        .customSelect(
          'SELECT $_listColumns FROM $_table a $_listJoins '
          "WHERE a.company_id=? AND a.source_enquiry_id=? AND a.status='active' "
          'AND ${scope.sql} LIMIT 1',
          variables: [
            Variable(context.company.id),
            Variable(enquiryId),
            ...scope.variables,
          ],
        )
        .getSingleOrNull();
    if (row == null) return null;
    final lines = await _loadLines(context.company.id, row.read<String>('id'));
    final employeeNames = await _employeeNames(
      lines.map((l) => l.assignedEmployeeId ?? ''),
    );
    final teamNames = await _teamNames(
      context.company.id,
      lines.map((l) => l.assignedTeamId ?? ''),
    );
    final snapshot = _snapshot(row.readNullable<String>('party_snapshot'));
    final site = [
      snapshot.buildingName,
      snapshot.unitNumber,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' / ');
    return ServiceJobAssignmentRef(
      id: row.read<String>('id'),
      assignmentNumber: row.read<String>('assignment_number'),
      sourceEnquiryId: enquiryId,
      customerName: snapshot.customerName ?? '',
      siteSummary: site.isEmpty ? (snapshot.siteName ?? '') : site,
      scheduledVisitDate: row.read<DateTime>('scheduled_visit_date').toUtc(),
      assignedSummary: _assignedSummary(lines, employeeNames, teamNames),
      priorityName: row.readNullable<String>('priority_name') ?? '',
    );
  }

  @override
  Future<Result<ServiceJobAssignmentRef?>> getAssignmentForEnquiry(
    AuthContext context,
    String enquiryId,
  ) async {
    final failure = _viewAccess(context);
    if (failure != null) return Failed(failure);
    try {
      return Success(await _assignmentRefForEnquiry(context, enquiryId));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Stream<Result<ServiceJobAssignmentRef?>> watchAssignmentForEnquiry(
    AuthContext context,
    String enquiryId,
  ) {
    final failure = _viewAccess(context);
    if (failure != null) return Stream.value(Failed(failure));
    return db
        .customSelect(
          'SELECT 1 FROM $_table WHERE company_id=?',
          variables: [Variable(context.company.id)],
          readsFrom: {db.serviceJobAssignments, db.serviceJobAssignmentLines},
        )
        .watch()
        .asyncMap<Result<ServiceJobAssignmentRef?>>(
          (_) async =>
              Success(await _assignmentRefForEnquiry(context, enquiryId)),
        )
        .transform(
          StreamTransformer<
            Result<ServiceJobAssignmentRef?>,
            Result<ServiceJobAssignmentRef?>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceJobAssignmentRef?>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  // ------------------------------------------------------------- summary

  @override
  Future<Result<ServiceJobAssignmentSummary>> summary(
    AuthContext context,
  ) async {
    final failure = _viewAccess(context);
    if (failure != null) return Failed(failure);
    try {
      final scope = _scopeClause(context);
      final today = _companyDate(context);
      final row = await db
          .customSelect(
            'SELECT '
            'COUNT(*) AS total, '
            "SUM(CASE WHEN a.status='active' THEN 1 ELSE 0 END) AS active_count, "
            "SUM(CASE WHEN a.status='active' AND a.scheduled_visit_date=? THEN 1 ELSE 0 END) AS today_count, "
            "SUM(CASE WHEN a.status='active' AND a.scheduled_visit_date>? THEN 1 ELSE 0 END) AS upcoming_count "
            'FROM $_table a WHERE ${scope.sql}',
            variables: [Variable(today), Variable(today), ...scope.variables],
          )
          .getSingle();
      return Success(
        ServiceJobAssignmentSummary(
          activeCount: row.readNullable<int>('active_count') ?? 0,
          todayCount: row.readNullable<int>('today_count') ?? 0,
          upcomingCount: row.readNullable<int>('upcoming_count') ?? 0,
          totalCount: row.read<int>('total'),
        ),
      );
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Stream<Result<List<ServiceJobAssignmentListItem>>> watchUpcomingAssignments(
    AuthContext context, {
    int limit = 5,
  }) {
    final failure = _viewAccess(context);
    if (failure != null) return Stream.value(Failed(failure));
    final scope = _scopeClause(context);
    final today = _companyDate(context);
    return db
        .customSelect(
          'SELECT $_listColumns FROM $_table a $_listJoins '
          "WHERE a.status='active' AND a.scheduled_visit_date>=? AND ${scope.sql} "
          'ORDER BY a.scheduled_visit_date, a.created_at LIMIT ?',
          variables: [
            Variable(today),
            ...scope.variables,
            Variable(limit.clamp(1, 50)),
          ],
          readsFrom: _reads,
        )
        .watch()
        .asyncMap<Result<List<ServiceJobAssignmentListItem>>>((rows) async {
          final ids = [for (final row in rows) row.read<String>('id')];
          final linesByAssignment = await _linesByAssignment(
            context.company.id,
            ids,
          );
          final allLines = [
            for (final list in linesByAssignment.values) ...list,
          ];
          final employeeNames = await _employeeNames(
            allLines.map((l) => l.assignedEmployeeId ?? ''),
          );
          final teamNames = await _teamNames(
            context.company.id,
            allLines.map((l) => l.assignedTeamId ?? ''),
          );
          return Success([
            for (final row in rows)
              _listItem(
                row,
                linesByAssignment[row.read<String>('id')] ?? const [],
                employeeNames,
                teamNames,
              ),
          ]);
        })
        .transform(
          StreamTransformer<
            Result<List<ServiceJobAssignmentListItem>>,
            Result<List<ServiceJobAssignmentListItem>>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<List<ServiceJobAssignmentListItem>>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  // ------------------------------------------------------------ persistence

  Future<void> _insertHeader(
    ServiceJobAssignment a, {
    required String searchText,
  }) => db
      .into(db.serviceJobAssignments)
      .insert(
        ServiceJobAssignmentsCompanion.insert(
          id: a.id,
          companyId: a.companyId,
          assignmentNumber: a.assignmentNumber,
          assignmentDate: a.assignmentDate,
          sourceEnquiryId: a.sourceEnquiryId,
          scheduledVisitDate: a.scheduledVisitDate,
          status: a.status.wire,
          version: Value(a.version),
          searchText: Value(searchText),
          createdAt: a.createdAt,
          updatedAt: a.updatedAt,
          createdByUserId: a.createdByUserId,
          updatedByUserId: a.updatedByUserId,
          requestId: Value(a.requestId),
          syncStatus: a.syncStatus.name,
        ),
      );

  Future<void> _activity(
    AuthContext context,
    ServiceJobAssignment a,
    String eventType,
  ) => activity.append(
    BusinessActivityEvent(
      id: _uuid.v4(),
      companyId: context.company.id,
      moduleKey: 'services',
      entityType: 'serviceJobAssignment',
      entityId: a.id,
      eventType: eventType,
      occurredAt: clock.now(),
      actorUserId: context.user.id,
      actorEmployeeId: context.employeeReference?.id,
      syncStatus: 'pending',
      metadata: {
        'assignmentNumber': a.assignmentNumber,
        'sourceEnquiryId': a.sourceEnquiryId,
        'status': a.status.wire,
        'scheduledVisitDate': a.scheduledVisitDate.toIso8601String(),
        'lineCount': a.lineCount,
      },
    ),
  );

  Future<void> _enqueue(
    AuthContext context,
    ServiceJobAssignment a,
    String operation,
    String requestId,
  ) => db
      .into(db.syncOutbox)
      .insert(
        SyncOutboxCompanion.insert(
          id: _uuid.v4(),
          moduleId: 'services',
          entityId: a.id,
          entityType: const Value('serviceJobAssignment'),
          operation: operation,
          payload: jsonEncode({
            'id': a.id,
            'assignmentNumber': a.assignmentNumber,
            'assignmentDate': a.assignmentDate.toIso8601String(),
            'sourceEnquiryId': a.sourceEnquiryId,
            'scheduledVisitDate': a.scheduledVisitDate.toIso8601String(),
            'status': a.status.wire,
            'version': a.version,
            'lines': [
              for (final line in a.lines)
                {
                  'id': line.id,
                  'lineNumber': line.lineNumber,
                  'work': line.work,
                  'assignedEmployeeId': line.assignedEmployeeId,
                  'assignedTeamId': line.assignedTeamId,
                  'status': line.status.wire,
                  'descriptionForWork': line.descriptionForWork,
                },
            ],
          }),
          createdAt: a.updatedAt,
          companyId: Value(context.company.id),
          requestId: Value(requestId),
        ),
        mode: InsertMode.insertOrIgnore,
      );

  // ---------------------------------------------------------- notifications

  Future<void> _notifyTargets(
    AuthContext context,
    ServiceJobAssignment assignment,
  ) async {
    final repository = _notifications;
    if (repository == null) return;
    final userIds = <String>{};

    final employeeIds = {
      for (final line in assignment.lines)
        if (line.assignedEmployeeId != null) line.assignedEmployeeId!,
    };
    if (employeeIds.isNotEmpty) {
      final refs = await workforce.getEmployees(employeeIds);
      for (final ref in refs) {
        if (ref.linkedUserId != null) userIds.add(ref.linkedUserId!);
      }
    }

    final teamIds = {
      for (final line in assignment.lines)
        if (line.assignedTeamId != null) line.assignedTeamId!,
    };
    for (final teamId in teamIds) {
      final team = await _teamRow(context.company.id, teamId);
      if (team == null) continue;
      final memberRows = await db
          .customSelect(
            "SELECT employee_id FROM service_team_members WHERE company_id=? "
            "AND team_id=? AND status='active'",
            variables: [Variable(context.company.id), Variable(teamId)],
          )
          .get();
      final targets = <String>{
        if (team.readNullable<String>('lead_employee_id') != null)
          team.readNullable<String>('lead_employee_id')!,
        for (final row in memberRows) row.read<String>('employee_id'),
      };
      if (targets.isEmpty) continue;
      final refs = await workforce.getEmployees(targets);
      for (final ref in refs) {
        if (ref.linkedUserId != null) userIds.add(ref.linkedUserId!);
      }
    }

    for (final userId in userIds) {
      await repository.createLocal(
        AppNotification(
          id: _uuid.v4(),
          companyId: context.company.id,
          userId: userId,
          type: AppNotificationType.serviceWorkAssigned,
          priority: AppNotificationPriority.normal,
          dedupeKey: 'jobAssignment:${assignment.id}:$userId',
          route: ServicesRoutes.assignment(assignment.id),
          payload: {'assignmentId': assignment.id},
          createdAt: clock.now().toUtc(),
        ),
      );
    }
  }
}

class _AssignmentException implements Exception {
  const _AssignmentException(this.code);
  final String code;
}
