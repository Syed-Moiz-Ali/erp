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
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution_repository.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution_scope.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';
import 'package:modular_erp/shared/transactions/domain/attachment_repository.dart';
import 'package:modular_erp/shared/transactions/domain/document_number.dart';
import 'package:modular_erp/shared/transactions/domain/document_number_service.dart';

/// Local (Drift) implementation of the Service Work Execution transaction.
class LocalServiceWorkExecutionRepository
    implements ServiceWorkExecutionRepository {
  LocalServiceWorkExecutionRepository(
    this.db,
    this.clock,
    this.numbers,
    this.activity,
    this.attachments,
    this.workforce,
    this.time, {
    ServiceWorkExecutionScopeResolver scopeResolver =
        const ServiceWorkExecutionScopeResolver(),
    Uuid? uuid,
  }) : _scopeResolver = scopeResolver,
       _uuid = uuid ?? const Uuid();

  final AppDatabase db;
  final AppClock clock;
  final DocumentNumberService numbers;
  final ActivityRepository activity;
  final AttachmentRepository attachments;
  final WorkforceDirectory workforce;
  final CompanyTimeService time;
  final ServiceWorkExecutionScopeResolver _scopeResolver;
  final Uuid _uuid;

  static const _table = 'service_work_executions';
  static const _lineTable = 'service_work_execution_lines';
  static const _materialTable = 'service_work_execution_materials_used';
  static const _photoTable = 'service_work_execution_photo_entries';
  static const _photoOwnerType = 'serviceWorkExecutionPhotoEntry';
  static const _inspectionTable = 'service_inspections';
  static const _assignmentTable = 'service_job_assignments';
  static const _assignmentLineTable = 'service_job_assignment_lines';
  static const _checklistTable = 'service_inspection_checklist_items';
  static const _checklistOwnerType = 'serviceInspectionChecklistItem';
  static const _materialRequestTable = 'service_material_requests';
  static const _materialRequestLineTable = 'service_material_request_lines';

  Failure? _denied() => const Failure(code: 'servicesWorkExecutionDenied');

  bool _enabled(AuthContext c) =>
      c.user.status == AccountStatus.active &&
      c.user.companyId == c.company.id &&
      c.company.enabledModules.contains('services');

  bool _can(AuthContext c, AppPermission p) => c.user.permissions.contains(p);

  ServiceWorkExecutionScope _scope(AuthContext c) => _scopeResolver.resolve(c);

  Failure? _viewAccess(AuthContext c) =>
      _enabled(c) && _scope(c) != ServiceWorkExecutionScope.none
      ? null
      : _denied();

  Failure? _actionAccess(AuthContext c, AppPermission p) =>
      _enabled(c) && _can(c, p) ? null : _denied();

  Failure? _referenceAccess(AuthContext c) =>
      _enabled(c) && _can(c, AppPermission.serviceWorkExecutionCreate)
      ? null
      : _denied();

  static const _listColumns =
      'w.*, i.inspection_number, a.assignment_number, e.enquiry_number, '
      'e.party_snapshot';

  static const _listJoins =
      'LEFT JOIN $_inspectionTable i ON i.id=w.source_inspection_id AND i.company_id=w.company_id '
      'LEFT JOIN $_assignmentTable a ON a.id=w.source_job_assignment_id AND a.company_id=w.company_id '
      'LEFT JOIN service_enquiries e ON e.id=w.source_enquiry_id AND e.company_id=w.company_id';

  Set<ResultSetImplementation> get _reads => {
    db.serviceWorkExecutions,
    db.serviceWorkExecutionLines,
    db.serviceWorkExecutionMaterialsUsed,
    db.serviceWorkExecutionPhotoEntries,
    db.serviceInspections,
    db.serviceJobAssignments,
    db.serviceEnquiries,
    db.serviceJobAssignmentLines,
    db.serviceInspectionChecklistItems,
    db.serviceInspectionPoints,
    db.serviceInspectionMaterialRequirements,
    db.serviceMaterialRequests,
    db.serviceMaterialRequestLines,
    db.serviceTeamMembers,
    db.serviceTeams,
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

  String _site(ServiceEnquiryPartySnapshot snapshot) {
    final site = [
      snapshot.buildingName,
      snapshot.unitNumber,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' / ');
    return site.isEmpty ? (snapshot.siteName ?? '') : site;
  }

  // ------------------------------------------------------------ scope

  static const _teamMembers =
      'SELECT tm.team_id FROM service_team_members tm '
      "WHERE tm.company_id=w.company_id AND tm.employee_id=? AND tm.status='active'";

  static const _lineTeamExists =
      'EXISTS (SELECT 1 FROM $_lineTable l WHERE l.company_id=w.company_id '
      'AND l.work_execution_id=w.id AND l.service_team_id IN ($_teamMembers))';

  static const _assignmentTeamExists =
      'EXISTS (SELECT 1 FROM $_assignmentLineTable al WHERE al.company_id=w.company_id '
      'AND al.assignment_id=w.source_job_assignment_id AND al.removed_at IS NULL '
      'AND al.assigned_team_id IN ($_teamMembers))';

  static const _lineEmployeeExists =
      'EXISTS (SELECT 1 FROM $_lineTable l WHERE l.company_id=w.company_id '
      'AND l.work_execution_id=w.id AND l.employee_id=?)';

  static const _assignmentEmployeeExists =
      'EXISTS (SELECT 1 FROM $_assignmentLineTable al WHERE al.company_id=w.company_id '
      'AND al.assignment_id=w.source_job_assignment_id AND al.removed_at IS NULL '
      'AND al.assigned_employee_id=?)';

  static const _technicianExists =
      'EXISTS (SELECT 1 FROM $_inspectionTable ii WHERE ii.company_id=w.company_id '
      'AND ii.id=w.source_inspection_id AND ii.technician_employee_id=?)';

  static const _teamScope = "($_lineTeamExists OR $_assignmentTeamExists)";
  static const _assignedScope =
      "($_lineEmployeeExists OR $_assignmentEmployeeExists OR $_technicianExists OR $_lineTeamExists OR $_assignmentTeamExists)";

  ({String sql, List<Variable> variables}) _scopeClause(AuthContext context) {
    final company = Variable(context.company.id);
    switch (_scope(context)) {
      case ServiceWorkExecutionScope.all:
        return (sql: 'w.company_id=?', variables: [company]);
      case ServiceWorkExecutionScope.team:
        final employeeId = context.employeeReference?.id;
        if (employeeId == null) return (sql: '0', variables: const []);
        return (
          sql: 'w.company_id=? AND $_teamScope',
          variables: [company, Variable(employeeId), Variable(employeeId)],
        );
      case ServiceWorkExecutionScope.assigned:
        final employeeId = context.employeeReference?.id;
        if (employeeId == null) return (sql: '0', variables: const []);
        return (
          sql: 'w.company_id=? AND $_assignedScope',
          variables: [
            company,
            Variable(employeeId),
            Variable(employeeId),
            Variable(employeeId),
            Variable(employeeId),
            Variable(employeeId),
          ],
        );
      case ServiceWorkExecutionScope.none:
        return (sql: '0', variables: const []);
    }
  }

  ({String sql, List<Variable> variables}) _where(
    AuthContext context, {
    String query = '',
    ServiceWorkExecutionStatus? status,
    String? employeeId,
    String? teamId,
    String? inspectionId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    final scope = _scopeClause(context);
    final parts = <String>[scope.sql];
    final variables = <Variable>[...scope.variables];
    if (status != null) {
      parts.add('w.status=?');
      variables.add(Variable(status.wire));
    }
    if (employeeId != null) {
      parts.add(
        'EXISTS (SELECT 1 FROM $_lineTable fl WHERE fl.company_id=w.company_id AND fl.work_execution_id=w.id AND fl.employee_id=?)',
      );
      variables.add(Variable(employeeId));
    }
    if (teamId != null) {
      parts.add(
        'EXISTS (SELECT 1 FROM $_lineTable ft WHERE ft.company_id=w.company_id AND ft.work_execution_id=w.id AND ft.service_team_id=?)',
      );
      variables.add(Variable(teamId));
    }
    if (inspectionId != null) {
      parts.add('w.source_inspection_id=?');
      variables.add(Variable(inspectionId));
    }
    if (dateFrom != null) {
      parts.add('w.execution_date>=?');
      variables.add(Variable(dateFrom));
    }
    if (dateTo != null) {
      parts.add('w.execution_date<=?');
      variables.add(Variable(dateTo));
    }
    if (query.trim().isNotEmpty) {
      final escaped = query
          .trim()
          .toLowerCase()
          .replaceAll('\\', '\\\\')
          .replaceAll('%', '\\%')
          .replaceAll('_', '\\_');
      parts.add("w.search_text LIKE ? ESCAPE '\\'");
      variables.add(Variable('%$escaped%'));
    }
    return (sql: parts.join(' AND '), variables: variables);
  }

  Future<int> _count(
    AuthContext context,
    ({String sql, List<Variable> variables}) where,
  ) async {
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM $_table w WHERE ${where.sql}',
          variables: where.variables,
        )
        .getSingle();
    return row.read<int>('c');
  }

  // ------------------------------------------------------------ records

  ServiceWorkExecution _record(
    QueryRow row, {
    List<ServiceWorkExecutionLine> workLines = const [],
    List<ServiceWorkExecutionMaterialUsed> materialsUsed = const [],
    List<ServiceWorkExecutionPhotoEntry> photoEntries = const [],
  }) => ServiceWorkExecution(
    id: row.read<String>('id'),
    companyId: row.read<String>('company_id'),
    executionNumber: row.read<String>('execution_number'),
    executionDate: row.read<DateTime>('execution_date').toUtc(),
    sourceInspectionId: row.read<String>('source_inspection_id'),
    sourceJobAssignmentId: row.read<String>('source_job_assignment_id'),
    sourceEnquiryId: row.read<String>('source_enquiry_id'),
    jobOrderReference: row.readNullable<String>('job_order_reference'),
    quotationReference: row.readNullable<String>('quotation_reference'),
    status: ServiceWorkExecutionStatusX.fromWire(row.read<String>('status')),
    version: row.read<int>('version'),
    createdAt: row.read<DateTime>('created_at').toUtc(),
    updatedAt: row.read<DateTime>('updated_at').toUtc(),
    createdByUserId: row.read<String>('created_by_user_id'),
    updatedByUserId: row.read<String>('updated_by_user_id'),
    requestId: row.readNullable<String>('request_id'),
    syncStatus: RecordSyncStatus.values.byName(row.read<String>('sync_status')),
    workLines: workLines,
    materialsUsed: materialsUsed,
    afterWorkPhotoEntries: photoEntries,
  );

  Future<List<ServiceWorkExecutionLine>> _loadLines(
    String companyId,
    String executionId,
  ) async {
    final rows = await db
        .customSelect(
          'SELECT * FROM $_lineTable WHERE company_id=? AND work_execution_id=? ORDER BY line_number, id',
          variables: [Variable(companyId), Variable(executionId)],
        )
        .get();
    return [
      for (final row in rows)
        ServiceWorkExecutionLine(
          id: row.read<String>('id'),
          companyId: row.read<String>('company_id'),
          workExecutionId: row.read<String>('work_execution_id'),
          sourceJobAssignmentLineId: row.readNullable<String>(
            'source_job_assignment_line_id',
          ),
          lineNumber: row.read<int>('line_number'),
          work: row.read<String>('work'),
          description: row.read<String>('description'),
          serviceTeamId: row.readNullable<String>('service_team_id'),
          employeeId: row.readNullable<String>('employee_id'),
          startedAtUtc: row.readNullable<DateTime>('started_at_utc')?.toUtc(),
          endedAtUtc: row.readNullable<DateTime>('ended_at_utc')?.toUtc(),
          createdAt: row.read<DateTime>('created_at').toUtc(),
          updatedAt: row.read<DateTime>('updated_at').toUtc(),
        ),
    ];
  }

  Future<List<ServiceWorkExecutionMaterialUsed>> _loadMaterials(
    String companyId,
    String executionId,
  ) async {
    final rows = await db
        .customSelect(
          'SELECT * FROM $_materialTable WHERE company_id=? AND work_execution_id=? ORDER BY line_number, id',
          variables: [Variable(companyId), Variable(executionId)],
        )
        .get();
    return [
      for (final row in rows)
        ServiceWorkExecutionMaterialUsed(
          id: row.read<String>('id'),
          companyId: row.read<String>('company_id'),
          workExecutionId: row.read<String>('work_execution_id'),
          sourceMaterialRequestLineId: row.readNullable<String>(
            'source_material_request_line_id',
          ),
          lineNumber: row.read<int>('line_number'),
          code: row.read<String>('code'),
          description: row.read<String>('description'),
          createdAt: row.read<DateTime>('created_at').toUtc(),
          updatedAt: row.read<DateTime>('updated_at').toUtc(),
        ),
    ];
  }

  Future<Map<String, List<AttachmentRef>>> _attachmentsByOwner(
    String companyId,
    List<String> ownerIds,
  ) async {
    if (ownerIds.isEmpty) return const {};
    final result = await attachments.getForOwners(
      companyId: companyId,
      ownerType: _photoOwnerType,
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

  Future<List<ServiceWorkExecutionPhotoEntry>> _loadPhotos(
    String companyId,
    String executionId,
  ) async {
    final rows = await db
        .customSelect(
          'SELECT * FROM $_photoTable WHERE company_id=? AND work_execution_id=? ORDER BY line_number, id',
          variables: [Variable(companyId), Variable(executionId)],
        )
        .get();
    final byOwner = await _attachmentsByOwner(companyId, [
      for (final row in rows) row.read<String>('id'),
    ]);
    return [
      for (final row in rows)
        ServiceWorkExecutionPhotoEntry(
          id: row.read<String>('id'),
          companyId: row.read<String>('company_id'),
          workExecutionId: row.read<String>('work_execution_id'),
          lineNumber: row.read<int>('line_number'),
          description: row.read<String>('description'),
          attachments: byOwner[row.read<String>('id')] ?? const [],
          createdAt: row.read<DateTime>('created_at').toUtc(),
          updatedAt: row.read<DateTime>('updated_at').toUtc(),
        ),
    ];
  }

  Future<ServiceWorkExecution> _aggregate(
    AuthContext context,
    QueryRow row,
  ) async {
    final id = row.read<String>('id');
    return _record(
      row,
      workLines: await _loadLines(context.company.id, id),
      materialsUsed: await _loadMaterials(context.company.id, id),
      photoEntries: await _loadPhotos(context.company.id, id),
    );
  }

  // ------------------------------------------------------------ reads

  Future<Map<String, String>> _employeeNames(Iterable<String> ids) async {
    final wanted = {
      for (final id in ids)
        if (id.isNotEmpty) id,
    };
    if (wanted.isEmpty) return const {};
    final refs = await workforce.getEmployees(wanted);
    return {for (final ref in refs) ref.id: ref.name};
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
    final rows = await db
        .customSelect(
          'SELECT id, name FROM service_teams WHERE company_id=? AND id IN ($placeholders)',
          variables: [Variable(companyId), ...wanted.map(Variable.new)],
        )
        .get();
    return {
      for (final row in rows) row.read<String>('id'): row.read<String>('name'),
    };
  }

  String _assignedSummary(
    List<ServiceWorkExecutionLine> lines,
    Map<String, String> employeeNames,
    Map<String, String> teamNames,
  ) {
    final labels = <String>[];
    for (final line in lines) {
      final employee = line.employeeId == null
          ? null
          : employeeNames[line.employeeId!];
      final team = line.serviceTeamId == null
          ? null
          : teamNames[line.serviceTeamId!];
      if (employee != null && !labels.contains(employee)) labels.add(employee);
      if (team != null && !labels.contains(team)) labels.add(team);
    }
    if (labels.isEmpty) return '';
    if (labels.length <= 2) return labels.join(' + ');
    return '${labels.take(2).join(' + ')} +${labels.length - 2}';
  }

  Future<List<ServiceWorkExecutionListItem>> _listItems(
    AuthContext context,
    List<QueryRow> rows,
  ) async {
    if (rows.isEmpty) return const [];
    final ids = [for (final row in rows) row.read<String>('id')];
    final placeholders = List.filled(ids.length, '?').join(',');
    final lineRows = await db
        .customSelect(
          'SELECT * FROM $_lineTable WHERE company_id=? AND work_execution_id IN ($placeholders) ORDER BY line_number, id',
          variables: [Variable(context.company.id), ...ids.map(Variable.new)],
        )
        .get();
    final byExecution = <String, List<ServiceWorkExecutionLine>>{};
    for (final row in lineRows) {
      final line = ServiceWorkExecutionLine(
        id: row.read<String>('id'),
        companyId: row.read<String>('company_id'),
        workExecutionId: row.read<String>('work_execution_id'),
        sourceJobAssignmentLineId: row.readNullable<String>(
          'source_job_assignment_line_id',
        ),
        lineNumber: row.read<int>('line_number'),
        work: row.read<String>('work'),
        description: row.read<String>('description'),
        serviceTeamId: row.readNullable<String>('service_team_id'),
        employeeId: row.readNullable<String>('employee_id'),
        startedAtUtc: row.readNullable<DateTime>('started_at_utc')?.toUtc(),
        endedAtUtc: row.readNullable<DateTime>('ended_at_utc')?.toUtc(),
        createdAt: row.read<DateTime>('created_at').toUtc(),
        updatedAt: row.read<DateTime>('updated_at').toUtc(),
      );
      byExecution.putIfAbsent(line.workExecutionId, () => []).add(line);
    }
    final employeeNames = await _employeeNames([
      for (final lines in byExecution.values)
        for (final line in lines) line.employeeId ?? '',
    ]);
    final teamNames = await _teamNames(context.company.id, [
      for (final lines in byExecution.values)
        for (final line in lines) line.serviceTeamId ?? '',
    ]);
    return [
      for (final row in rows)
        _listItem(
          row,
          byExecution[row.read<String>('id')] ?? const [],
          employeeNames,
          teamNames,
        ),
    ];
  }

  ServiceWorkExecutionListItem _listItem(
    QueryRow row,
    List<ServiceWorkExecutionLine> lines,
    Map<String, String> employeeNames,
    Map<String, String> teamNames,
  ) {
    final snapshot = _snapshot(row.readNullable<String>('party_snapshot'));
    DateTime? started;
    DateTime? ended;
    for (final line in lines) {
      final s = line.startedAtUtc;
      if (s != null && (started == null || s.isBefore(started))) started = s;
      final e = line.endedAtUtc;
      if (e != null && (ended == null || e.isAfter(ended))) ended = e;
    }
    return ServiceWorkExecutionListItem(
      id: row.read<String>('id'),
      executionNumber: row.read<String>('execution_number'),
      executionDate: row.read<DateTime>('execution_date').toUtc(),
      createdAt: row.read<DateTime>('created_at').toUtc(),
      status: ServiceWorkExecutionStatusX.fromWire(row.read<String>('status')),
      inspectionNumber: row.readNullable<String>('inspection_number') ?? '',
      assignmentNumber: row.readNullable<String>('assignment_number') ?? '',
      enquiryNumber: row.readNullable<String>('enquiry_number') ?? '',
      customerName: snapshot.customerName ?? '',
      siteSummary: _site(snapshot),
      assignedSummary: _assignedSummary(lines, employeeNames, teamNames),
      startedAtUtc: started,
      endedAtUtc: ended,
    );
  }

  Stream<Result<ServiceWorkExecutionPage>> _watchPage(
    AuthContext context, {
    required ({String sql, List<Variable> variables}) where,
    required int page,
    required int limit,
  }) {
    final sql =
        'SELECT $_listColumns FROM $_table w $_listJoins '
        'WHERE ${where.sql} '
        'ORDER BY w.execution_date DESC, w.created_at DESC, w.id DESC LIMIT ? OFFSET ?';
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
        .asyncMap<Result<ServiceWorkExecutionPage>>((rows) async {
          final scope = _scopeClause(context);
          final total = await _count(context, (
            sql: scope.sql,
            variables: scope.variables,
          ));
          final filtered = await _count(context, where);
          return Success(
            ServiceWorkExecutionPage(
              await _listItems(context, rows),
              total,
              filtered,
            ),
          );
        })
        .transform(
          StreamTransformer<
            Result<ServiceWorkExecutionPage>,
            Result<ServiceWorkExecutionPage>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceWorkExecutionPage>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  @override
  Stream<Result<ServiceWorkExecutionPage>> watchExecutions(
    AuthContext context, {
    String query = '',
    ServiceWorkExecutionStatus? status,
    String? employeeId,
    String? teamId,
    String? inspectionId,
    DateTime? dateFrom,
    DateTime? dateTo,
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
        employeeId: employeeId,
        teamId: teamId,
        inspectionId: inspectionId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      ),
      page: page,
      limit: pageSize,
    );
  }

  Future<QueryRow?> _rawRow(AuthContext context, String id) {
    final scope = _scopeClause(context);
    return db
        .customSelect(
          'SELECT $_listColumns FROM $_table w $_listJoins '
          'WHERE w.id=? AND ${scope.sql}',
          variables: [Variable(id), ...scope.variables],
        )
        .getSingleOrNull();
  }

  /// Company-scoped read used only by the create path to return the record the
  /// caller just inserted (or an idempotent replay of it). Creating a record
  /// does not require—and must never widen—any View scope; the record is the
  /// caller's own new artifact.
  Future<QueryRow?> _rawRowForCreate(AuthContext context, String id) => db
      .customSelect(
        'SELECT $_listColumns FROM $_table w $_listJoins '
        'WHERE w.id=? AND w.company_id=?',
        variables: [Variable(id), Variable(context.company.id)],
      )
      .getSingleOrNull();

  Future<ServiceWorkExecutionView> _view(
    AuthContext context,
    QueryRow row,
  ) async {
    final execution = await _aggregate(context, row);
    final source = await _sourceContext(context, execution.sourceInspectionId);
    final snapshot =
        source?.partySnapshot ??
        _snapshot(row.readNullable<String>('party_snapshot'));
    return ServiceWorkExecutionView(
      execution: execution,
      inspectionNumber:
          source?.inspectionNumber ??
          row.readNullable<String>('inspection_number') ??
          '',
      assignmentNumber:
          source?.assignmentNumber ??
          row.readNullable<String>('assignment_number') ??
          '',
      enquiryNumber:
          source?.enquiryNumber ??
          row.readNullable<String>('enquiry_number') ??
          '',
      customerName: source?.customerName ?? snapshot.customerName ?? '',
      customerMobile: source?.customerMobile ?? snapshot.customerMobile,
      complaintTypeName: source?.complaintTypeName ?? '',
      priorityName: source?.priorityName ?? '',
      materialReceived: source?.materialReceived ?? MaterialReceived.no,
      partySnapshot: snapshot,
      rootCauseName: source?.rootCauseName,
      chargeResponsibilityName: source?.chargeResponsibilityName,
      technicianName: source?.technicianName,
      checklistItems: source?.checklistItems ?? const [],
      inspectedPoints: source?.inspectedPoints ?? const [],
      materialRequirements: source?.materialRequirements ?? const [],
      linkedMaterialRequests: source?.linkedMaterialRequests ?? const [],
    );
  }

  @override
  Stream<Result<ServiceWorkExecutionView?>> watchExecution(
    AuthContext context,
    String id,
  ) {
    final failure = _viewAccess(context);
    if (failure != null) return Stream.value(Failed(failure));
    final scope = _scopeClause(context);
    return db
        .customSelect(
          'SELECT $_listColumns FROM $_table w $_listJoins '
          'WHERE w.id=? AND ${scope.sql}',
          variables: [Variable(id), ...scope.variables],
          readsFrom: _reads,
        )
        .watchSingleOrNull()
        .asyncMap<Result<ServiceWorkExecutionView?>>((row) async {
          if (row == null) {
            return const Success<ServiceWorkExecutionView?>(null);
          }
          return Success<ServiceWorkExecutionView?>(await _view(context, row));
        })
        .transform(
          StreamTransformer<
            Result<ServiceWorkExecutionView?>,
            Result<ServiceWorkExecutionView?>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceWorkExecutionView?>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  @override
  Future<Result<ServiceWorkExecutionView?>> getExecution(
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

  // --------------------------------------------------- source context/refs

  Future<QueryRow?> _inspectionRow(String companyId, String id) => db
      .customSelect(
        'SELECT id, inspection_number, status, source_job_assignment_id, source_enquiry_id, '
        'technician_employee_id, root_cause_id, charge_responsibility_id '
        'FROM $_inspectionTable WHERE company_id=? AND id=?',
        variables: [Variable(companyId), Variable(id)],
      )
      .getSingleOrNull();

  Future<List<ServiceJobAssignmentLine>> _assignmentLines(
    String companyId,
    String assignmentId,
  ) async {
    final rows = await db
        .customSelect(
          'SELECT * FROM $_assignmentLineTable WHERE company_id=? AND assignment_id=? AND removed_at IS NULL ORDER BY line_number, id',
          variables: [Variable(companyId), Variable(assignmentId)],
        )
        .get();
    return [
      for (final row in rows)
        ServiceJobAssignmentLine(
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
          syncStatus: RecordSyncStatus.values.byName(
            row.read<String>('sync_status'),
          ),
        ),
    ];
  }

  Future<List<ServiceInspectionChecklistItem>> _checklistWithAttachments(
    String companyId,
    String inspectionId,
  ) async {
    final rows = await db
        .customSelect(
          'SELECT * FROM $_checklistTable WHERE company_id=? AND inspection_id=? AND removed_at IS NULL ORDER BY line_number, id',
          variables: [Variable(companyId), Variable(inspectionId)],
        )
        .get();
    final ownerIds = [for (final row in rows) row.read<String>('id')];
    final byOwner = <String, List<AttachmentRef>>{};
    if (ownerIds.isNotEmpty) {
      final result = await attachments.getForOwners(
        companyId: companyId,
        ownerType: _checklistOwnerType,
        ownerIds: ownerIds,
      );
      final refs = result is Success<List<AttachmentRef>>
          ? result.value
          : const <AttachmentRef>[];
      for (final ref in refs) {
        byOwner.putIfAbsent(ref.ownerId, () => []).add(ref);
      }
    }
    return [
      for (final row in rows)
        ServiceInspectionChecklistItem(
          id: row.read<String>('id'),
          companyId: row.read<String>('company_id'),
          inspectionId: row.read<String>('inspection_id'),
          sourceJobAssignmentLineId: row.readNullable<String>(
            'source_job_assignment_line_id',
          ),
          lineNumber: row.read<int>('line_number'),
          workType: row.read<String>('work_type'),
          descriptionForWork: row.read<String>('description_for_work'),
          status: ServiceInspectionChecklistStatusX.fromWire(
            row.read<String>('status'),
          ),
          attachments: byOwner[row.read<String>('id')] ?? const [],
          createdAt: row.read<DateTime>('created_at').toUtc(),
          updatedAt: row.read<DateTime>('updated_at').toUtc(),
        ),
    ];
  }

  Future<List<ServiceInspectionPoint>> _points(
    String companyId,
    String inspectionId,
  ) async {
    final rows = await db
        .customSelect(
          'SELECT * FROM service_inspection_points WHERE company_id=? AND inspection_id=? AND removed_at IS NULL ORDER BY line_number, id',
          variables: [Variable(companyId), Variable(inspectionId)],
        )
        .get();
    return [
      for (final row in rows)
        ServiceInspectionPoint(
          id: row.read<String>('id'),
          companyId: row.read<String>('company_id'),
          inspectionId: row.read<String>('inspection_id'),
          lineNumber: row.read<int>('line_number'),
          description: row.read<String>('description'),
          createdAt: row.read<DateTime>('created_at').toUtc(),
          updatedAt: row.read<DateTime>('updated_at').toUtc(),
        ),
    ];
  }

  Future<List<ServiceInspectionMaterialRequirement>> _requirements(
    String companyId,
    String inspectionId,
  ) async {
    final rows = await db
        .customSelect(
          'SELECT * FROM service_inspection_material_requirements WHERE company_id=? AND inspection_id=? AND removed_at IS NULL ORDER BY line_number, id',
          variables: [Variable(companyId), Variable(inspectionId)],
        )
        .get();
    return [
      for (final row in rows)
        ServiceInspectionMaterialRequirement(
          id: row.read<String>('id'),
          companyId: row.read<String>('company_id'),
          inspectionId: row.read<String>('inspection_id'),
          lineNumber: row.read<int>('line_number'),
          code: row.read<String>('code'),
          description: row.read<String>('description'),
          status: ServiceInspectionMaterialStatusX.fromWire(
            row.read<String>('status'),
          ),
          createdAt: row.read<DateTime>('created_at').toUtc(),
          updatedAt: row.read<DateTime>('updated_at').toUtc(),
        ),
    ];
  }

  Future<
    ({
      List<ServiceWorkMaterialRequestRef> requests,
      List<ServiceWorkMaterialRequestLineRef> lines,
    })
  >
  _linkedMaterialRequests(String companyId, String inspectionId) async {
    final requestRows = await db
        .customSelect(
          'SELECT id, request_number, status FROM $_materialRequestTable '
          'WHERE company_id=? AND source_inspection_id=? AND status<>\'cancelled\' '
          'ORDER BY request_date DESC, created_at DESC',
          variables: [Variable(companyId), Variable(inspectionId)],
        )
        .get();
    final requests = <ServiceWorkMaterialRequestRef>[];
    final lines = <ServiceWorkMaterialRequestLineRef>[];
    for (final row in requestRows) {
      final requestId = row.read<String>('id');
      final requestNumber = row.read<String>('request_number');
      final lineRows = await db
          .customSelect(
            'SELECT id, code, description FROM $_materialRequestLineTable '
            'WHERE company_id=? AND material_request_id=? ORDER BY line_number, id',
            variables: [Variable(companyId), Variable(requestId)],
          )
          .get();
      requests.add(
        ServiceWorkMaterialRequestRef(
          id: requestId,
          requestNumber: requestNumber,
          status: row.read<String>('status'),
          itemCount: lineRows.length,
        ),
      );
      for (final lineRow in lineRows) {
        lines.add(
          ServiceWorkMaterialRequestLineRef(
            id: lineRow.read<String>('id'),
            requestNumber: requestNumber,
            code: lineRow.read<String>('code'),
            description: lineRow.read<String>('description'),
          ),
        );
      }
    }
    return (requests: requests, lines: lines);
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

  Future<ServiceWorkExecutionSourceContext?> _sourceContext(
    AuthContext context,
    String inspectionId, {
    bool viewOnly = false,
  }) async {
    final companyId = context.company.id;
    final inspection = await _inspectionRow(companyId, inspectionId);
    if (inspection == null) return null;
    final status = ServiceInspectionStatusX.fromWire(
      inspection.read<String>('status'),
    );
    if (viewOnly && status.isCancelled) return null;
    final assignmentId = inspection.read<String>('source_job_assignment_id');
    final enquiryId = inspection.read<String>('source_enquiry_id');
    final assignment = await db
        .customSelect(
          'SELECT assignment_number FROM $_assignmentTable WHERE company_id=? AND id=?',
          variables: [Variable(companyId), Variable(assignmentId)],
        )
        .getSingleOrNull();
    final enquiry = await db
        .customSelect(
          'SELECT enquiry_number, party_snapshot, material_received, complaint_type_id, priority_id '
          'FROM service_enquiries WHERE company_id=? AND id=?',
          variables: [Variable(companyId), Variable(enquiryId)],
        )
        .getSingleOrNull();
    if (enquiry == null) return null;
    final snapshot = _snapshot(enquiry.readNullable<String>('party_snapshot'));
    final technicianId = inspection.readNullable<String>(
      'technician_employee_id',
    );
    final technicianName = technicianId == null
        ? null
        : (await _employeeNames([technicianId]))[technicianId];
    final linked = await _linkedMaterialRequests(companyId, inspectionId);
    return ServiceWorkExecutionSourceContext(
      inspectionId: inspectionId,
      inspectionNumber: inspection.read<String>('inspection_number'),
      inspectionStatus: status,
      jobAssignmentId: assignmentId,
      assignmentNumber: assignment?.read<String>('assignment_number') ?? '',
      enquiryId: enquiryId,
      enquiryNumber: enquiry.read<String>('enquiry_number'),
      customerName: snapshot.customerName ?? '',
      customerMobile: snapshot.customerMobile,
      complaintTypeName: await _masterName(
        'complaint_types',
        companyId,
        enquiry.readNullable<String>('complaint_type_id'),
      ),
      priorityName: await _masterName(
        'service_priorities',
        companyId,
        enquiry.readNullable<String>('priority_id'),
      ),
      materialReceived: MaterialReceivedX.fromWire(
        enquiry.readNullable<String>('material_received') ?? 'no',
      ),
      partySnapshot: snapshot,
      rootCauseName: await _masterName(
        'service_root_causes',
        companyId,
        inspection.readNullable<String>('root_cause_id'),
      ),
      chargeResponsibilityName: await _masterName(
        'service_charge_responsibilities',
        companyId,
        inspection.readNullable<String>('charge_responsibility_id'),
      ),
      technicianName: technicianName,
      jobAssignmentLines: await _assignmentLines(companyId, assignmentId),
      checklistItems: await _checklistWithAttachments(companyId, inspectionId),
      inspectedPoints: await _points(companyId, inspectionId),
      materialRequirements: await _requirements(companyId, inspectionId),
      linkedMaterialRequests: linked.requests,
      materialRequestLines: linked.lines,
    );
  }

  @override
  Future<Result<ServiceWorkExecutionSourceContext?>> getSourceContext(
    AuthContext context,
    String inspectionId,
  ) async {
    final failure = _referenceAccess(context);
    if (failure != null) return Failed(failure);
    try {
      return Success(await _sourceContext(context, inspectionId));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<List<ServiceWorkEligibleInspectionRef>>>
  searchEligibleInspections(
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
            "SELECT i.id, i.inspection_number, i.visit_date, i.technician_employee_id, "
            "a.assignment_number, e.enquiry_number, e.party_snapshot "
            "FROM $_inspectionTable i "
            "LEFT JOIN $_assignmentTable a ON a.id=i.source_job_assignment_id AND a.company_id=i.company_id "
            "LEFT JOIN service_enquiries e ON e.id=i.source_enquiry_id AND e.company_id=i.company_id "
            "WHERE i.company_id=? AND i.status='completed' "
            "AND NOT EXISTS (SELECT 1 FROM $_table w WHERE w.company_id=i.company_id AND w.source_inspection_id=i.id AND w.status<>'cancelled') "
            "AND (lower(i.inspection_number) LIKE ? ESCAPE '\\' OR i.search_text LIKE ? ESCAPE '\\' "
            "OR lower(COALESCE(a.assignment_number,'')) LIKE ? ESCAPE '\\' "
            "OR lower(COALESCE(e.enquiry_number,'')) LIKE ? ESCAPE '\\') "
            "ORDER BY i.visit_date DESC, i.created_at DESC LIMIT ?",
            variables: [
              Variable(context.company.id),
              Variable('%$escaped%'),
              Variable('%$escaped%'),
              Variable('%$escaped%'),
              Variable('%$escaped%'),
              Variable(limit.clamp(1, 50)),
            ],
          )
          .get();
      return Success([for (final row in rows) await _eligibleRef(row)]);
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  Future<ServiceWorkEligibleInspectionRef> _eligibleRef(QueryRow row) async {
    final snapshot = _snapshot(row.readNullable<String>('party_snapshot'));
    final technicianId = row.readNullable<String>('technician_employee_id');
    return ServiceWorkEligibleInspectionRef(
      id: row.read<String>('id'),
      inspectionNumber: row.read<String>('inspection_number'),
      assignmentNumber: row.readNullable<String>('assignment_number') ?? '',
      enquiryNumber: row.readNullable<String>('enquiry_number') ?? '',
      customerName: snapshot.customerName ?? '',
      siteSummary: _site(snapshot),
      visitDate: row.read<DateTime>('visit_date').toUtc(),
      technicianName: technicianId == null
          ? null
          : (await _employeeNames([technicianId]))[technicianId],
    );
  }

  Future<ServiceWorkExecutionRef?> _refForInspection(
    AuthContext context,
    String inspectionId,
  ) async {
    final scope = _scopeClause(context);
    final row = await db
        .customSelect(
          'SELECT w.* FROM $_table w '
          "WHERE w.company_id=? AND w.source_inspection_id=? AND w.status<>'cancelled' "
          'AND ${scope.sql} LIMIT 1',
          variables: [
            Variable(context.company.id),
            Variable(inspectionId),
            ...scope.variables,
          ],
        )
        .getSingleOrNull();
    if (row == null) return null;
    final id = row.read<String>('id');
    final lines = await _loadLines(context.company.id, id);
    return _buildRef(row, lines);
  }

  Future<ServiceWorkExecutionRef?> _refForAssignment(
    AuthContext context,
    String assignmentId,
  ) async {
    final scope = _scopeClause(context);
    final row = await db
        .customSelect(
          'SELECT w.* FROM $_table w '
          "WHERE w.company_id=? AND w.source_job_assignment_id=? AND w.status<>'cancelled' "
          'AND ${scope.sql} LIMIT 1',
          variables: [
            Variable(context.company.id),
            Variable(assignmentId),
            ...scope.variables,
          ],
        )
        .getSingleOrNull();
    if (row == null) return null;
    final id = row.read<String>('id');
    final lines = await _loadLines(context.company.id, id);
    return _buildRef(row, lines);
  }

  ServiceWorkExecutionRef _buildRef(
    QueryRow row,
    List<ServiceWorkExecutionLine> lines,
  ) {
    DateTime? started;
    DateTime? ended;
    for (final line in lines) {
      final s = line.startedAtUtc;
      if (s != null && (started == null || s.isBefore(started))) started = s;
      final e = line.endedAtUtc;
      if (e != null && (ended == null || e.isAfter(ended))) ended = e;
    }
    return ServiceWorkExecutionRef(
      id: row.read<String>('id'),
      executionNumber: row.read<String>('execution_number'),
      status: ServiceWorkExecutionStatusX.fromWire(row.read<String>('status')),
      executionDate: row.read<DateTime>('execution_date').toUtc(),
      workLineCount: lines.length,
      allLinesComplete:
          lines.isNotEmpty &&
          lines.every((line) => line.isStarted && line.isFinished) &&
          !lines.any((line) => line.hasInvalidRange),
      startedAtUtc: started,
      endedAtUtc: ended,
    );
  }

  @override
  Future<Result<ServiceWorkExecutionRef?>> getExecutionForInspection(
    AuthContext context,
    String inspectionId,
  ) async {
    final failure = _viewAccess(context);
    if (failure != null) return Failed(failure);
    try {
      return Success(await _refForInspection(context, inspectionId));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Stream<Result<ServiceWorkExecutionRef?>> watchExecutionForInspection(
    AuthContext context,
    String inspectionId,
  ) {
    final failure = _viewAccess(context);
    if (failure != null) return Stream.value(Failed(failure));
    return db
        .customSelect(
          'SELECT 1 FROM $_table WHERE company_id=?',
          variables: [Variable(context.company.id)],
          readsFrom: _reads,
        )
        .watch()
        .asyncMap<Result<ServiceWorkExecutionRef?>>(
          (_) async => Success(await _refForInspection(context, inspectionId)),
        )
        .transform(
          StreamTransformer<
            Result<ServiceWorkExecutionRef?>,
            Result<ServiceWorkExecutionRef?>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceWorkExecutionRef?>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  @override
  Stream<Result<ServiceWorkExecutionRef?>> watchExecutionForAssignment(
    AuthContext context,
    String jobAssignmentId,
  ) {
    final failure = _viewAccess(context);
    if (failure != null) return Stream.value(Failed(failure));
    return db
        .customSelect(
          'SELECT 1 FROM $_table WHERE company_id=?',
          variables: [Variable(context.company.id)],
          readsFrom: _reads,
        )
        .watch()
        .asyncMap<Result<ServiceWorkExecutionRef?>>(
          (_) async =>
              Success(await _refForAssignment(context, jobAssignmentId)),
        )
        .transform(
          StreamTransformer<
            Result<ServiceWorkExecutionRef?>,
            Result<ServiceWorkExecutionRef?>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceWorkExecutionRef?>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  @override
  Future<Result<List<ServiceWorkExecutionRef>>> getExecutionsForEnquiry(
    AuthContext context,
    String enquiryId,
  ) async {
    final failure = _viewAccess(context);
    if (failure != null) return Failed(failure);
    try {
      final scope = _scopeClause(context);
      final rows = await db
          .customSelect(
            'SELECT w.* FROM $_table w '
            'WHERE w.company_id=? AND w.source_enquiry_id=? AND ${scope.sql} '
            'ORDER BY w.execution_date DESC, w.created_at DESC',
            variables: [
              Variable(context.company.id),
              Variable(enquiryId),
              ...scope.variables,
            ],
          )
          .get();
      final refs = <ServiceWorkExecutionRef>[];
      for (final row in rows) {
        final id = row.read<String>('id');
        refs.add(_buildRef(row, await _loadLines(context.company.id, id)));
      }
      return Success(refs);
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  // ------------------------------------------------------------- summary

  @override
  Future<Result<ServiceWorkExecutionSummary>> summary(
    AuthContext context,
  ) async {
    final failure = _viewAccess(context);
    if (failure != null) return Failed(failure);
    try {
      final scope = _scopeClause(context);
      final today = _companyDate(context);
      final row = await db
          .customSelect(
            'SELECT COUNT(*) AS total, '
            "SUM(CASE WHEN w.status='pending' THEN 1 ELSE 0 END) AS pending_count, "
            "SUM(CASE WHEN w.status='inProgress' THEN 1 ELSE 0 END) AS in_progress_count, "
            "SUM(CASE WHEN w.status='completed' AND w.execution_date=? THEN 1 ELSE 0 END) AS completed_today "
            'FROM $_table w WHERE ${scope.sql}',
            variables: [Variable(today), ...scope.variables],
          )
          .getSingle();
      return Success(
        ServiceWorkExecutionSummary(
          pendingCount: row.readNullable<int>('pending_count') ?? 0,
          inProgressCount: row.readNullable<int>('in_progress_count') ?? 0,
          completedTodayCount: row.readNullable<int>('completed_today') ?? 0,
          totalCount: row.read<int>('total'),
        ),
      );
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Stream<Result<List<ServiceWorkExecutionListItem>>> watchRecentExecutions(
    AuthContext context, {
    int limit = 5,
  }) {
    final failure = _viewAccess(context);
    if (failure != null) return Stream.value(Failed(failure));
    final scope = _scopeClause(context);
    return db
        .customSelect(
          'SELECT $_listColumns FROM $_table w $_listJoins '
          'WHERE ${scope.sql} '
          'ORDER BY w.execution_date DESC, w.created_at DESC LIMIT ?',
          variables: [...scope.variables, Variable(limit.clamp(1, 50))],
          readsFrom: _reads,
        )
        .watch()
        .asyncMap<Result<List<ServiceWorkExecutionListItem>>>(
          (rows) async => Success(await _listItems(context, rows)),
        )
        .transform(
          StreamTransformer<
            Result<List<ServiceWorkExecutionListItem>>,
            Result<List<ServiceWorkExecutionListItem>>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<List<ServiceWorkExecutionListItem>>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  // -------------------------------------------------------- persistence

  DateTime _companyDate(AuthContext context) {
    final local = time.localWallTime(clock.now(), context.company.timezone);
    final wall = local is Success<DateTime> ? local.value : clock.now().toUtc();
    return DateTime.utc(wall.year, wall.month, wall.day);
  }

  String _searchText(
    String executionNumber,
    String inspectionNumber,
    String assignmentNumber,
    String enquiryNumber,
    String? jobOrderReference,
    String? quotationReference,
    ServiceEnquiryPartySnapshot snapshot,
    List<ServiceWorkExecutionLineDraft> lines,
    List<ServiceWorkExecutionMaterialUsedDraft> materials,
  ) =>
      [
            executionNumber,
            inspectionNumber,
            assignmentNumber,
            enquiryNumber,
            jobOrderReference,
            quotationReference,
            snapshot.customerName,
            snapshot.customerMobile,
            snapshot.siteName,
            snapshot.buildingName,
            snapshot.unitNumber,
            for (final line in lines) ...[line.work, line.description],
            for (final material in materials) ...[
              material.code,
              material.description,
            ],
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

  String? _nullable(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  Failure? _validateDraft(ServiceWorkExecutionDraft draft) {
    if (draft.workLines.isEmpty) {
      return const Failure(code: 'servicesWorkExecutionLinesRequired');
    }
    for (final line in draft.workLines) {
      if (line.work.trim().isEmpty) {
        return const Failure(code: 'servicesWorkExecutionWorkRequired');
      }
    }
    for (final material in draft.materialsUsed) {
      if (material.code.trim().isEmpty) {
        return const Failure(code: 'servicesWorkExecutionCodeRequired');
      }
      if (material.description.trim().isEmpty) {
        return const Failure(code: 'servicesWorkExecutionDescriptionRequired');
      }
    }
    for (final entry in draft.afterWorkPhotoEntries) {
      if (entry.description.trim().isEmpty) {
        return const Failure(
          code: 'servicesWorkExecutionPhotoDescriptionRequired',
        );
      }
    }
    return null;
  }

  Future<void> _validateTeam(String companyId, String? teamId) async {
    if (teamId == null) return;
    final row = await db
        .customSelect(
          'SELECT status FROM service_teams WHERE company_id=? AND id=?',
          variables: [Variable(companyId), Variable(teamId)],
        )
        .getSingleOrNull();
    if (row == null ||
        row.read<String>('status') != ConfigurationStatus.active.name) {
      throw const _WorkExecutionException('servicesWorkExecutionTeamInvalid');
    }
  }

  Future<void> _validateEmployee(String companyId, String? employeeId) async {
    if (employeeId == null) return;
    final refs = await workforce.getEmployees([employeeId]);
    if (refs.isEmpty || refs.first.id != employeeId) {
      throw const _WorkExecutionException(
        'servicesWorkExecutionEmployeeInvalid',
      );
    }
  }

  Future<void> _validateTargets(
    String companyId,
    List<ServiceWorkExecutionLineDraft> lines,
  ) async {
    for (final line in lines) {
      await _validateTeam(companyId, line.serviceTeamId);
      await _validateEmployee(companyId, line.employeeId);
    }
  }

  @override
  Future<Result<ServiceWorkExecution>> createExecution(
    AuthContext context,
    ServiceWorkExecutionDraft draft, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceWorkExecutionCreate,
    );
    if (failure != null) return Failed(failure);
    if (draft.sourceInspectionId == null) {
      return const Failed(
        Failure(
          code: 'servicesWorkExecutionInspectionRequired',
          kind: FailureKind.invalidData,
        ),
      );
    }
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
            final row = await _rawRowForCreate(context, existingId);
            if (row != null) return _aggregate(context, row);
          }
          final source = await _sourceContext(
            context,
            draft.sourceInspectionId!,
          );
          if (source == null || !source.inspectionStatus.isCompleted) {
            throw const _WorkExecutionException(
              'servicesWorkExecutionInspectionNotEligible',
            );
          }
          final active = await db
              .customSelect(
                "SELECT 1 FROM $_table WHERE company_id=? AND source_inspection_id=? AND status<>'cancelled' LIMIT 1",
                variables: [
                  Variable(context.company.id),
                  Variable(source.inspectionId),
                ],
              )
              .get();
          if (active.isNotEmpty) {
            throw const _WorkExecutionException(
              'servicesWorkExecutionAlreadyActive',
            );
          }
          await _validateTargets(context.company.id, draft.workLines);
          await _validateMaterialSources(
            context.company.id,
            source.inspectionId,
            draft.materialsUsed,
          );
          final now = clock.now();
          final numberResult = await numbers.nextNumber(
            companyId: context.company.id,
            type: DocumentSequenceType.workExecution,
          );
          final number = switch (numberResult) {
            Success<String>(:final value) => value,
            Failed<String>() => throw const _WorkExecutionException(
              'servicesWorkExecutionSequenceFailed',
            ),
          };
          final id = _uuid.v4();
          final header = ServiceWorkExecution(
            id: id,
            companyId: context.company.id,
            executionNumber: number,
            executionDate: _companyDate(context),
            sourceInspectionId: source.inspectionId,
            sourceJobAssignmentId: source.jobAssignmentId,
            sourceEnquiryId: source.enquiryId,
            jobOrderReference: _nullable(draft.jobOrderReference),
            quotationReference: _nullable(draft.quotationReference),
            status: ServiceWorkExecutionStatus.pending,
            version: 1,
            createdAt: now,
            updatedAt: now,
            createdByUserId: context.user.id,
            updatedByUserId: context.user.id,
            requestId: effectiveRequest,
            syncStatus: RecordSyncStatus.pending,
          );
          await _insertHeader(
            header,
            searchText: _searchText(
              number,
              source.inspectionNumber,
              source.assignmentNumber,
              source.enquiryNumber,
              header.jobOrderReference,
              header.quotationReference,
              source.partySnapshot,
              draft.workLines,
              draft.materialsUsed,
            ),
          );
          await _persistChildren(context, id, draft, now);
          final created = await _aggregate(
            context,
            (await _rawRowForCreate(context, id))!,
          );
          await _activity(context, created, 'services.workExecution.created');
          await _enqueue(
            context,
            created,
            'SERVICES_WORK_EXECUTION_CREATE',
            effectiveRequest,
          );
          return created;
        }),
      );
    } on _WorkExecutionException catch (e) {
      return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  Future<void> _insertHeader(
    ServiceWorkExecution e, {
    required String searchText,
  }) => db
      .into(db.serviceWorkExecutions)
      .insert(
        ServiceWorkExecutionsCompanion.insert(
          id: e.id,
          companyId: e.companyId,
          executionNumber: e.executionNumber,
          executionDate: e.executionDate,
          sourceInspectionId: e.sourceInspectionId,
          sourceJobAssignmentId: e.sourceJobAssignmentId,
          sourceEnquiryId: e.sourceEnquiryId,
          jobOrderReference: Value(e.jobOrderReference),
          quotationReference: Value(e.quotationReference),
          status: e.status.wire,
          version: Value(e.version),
          searchText: Value(searchText),
          createdAt: e.createdAt,
          updatedAt: e.updatedAt,
          createdByUserId: e.createdByUserId,
          updatedByUserId: e.updatedByUserId,
          requestId: Value(e.requestId),
          syncStatus: e.syncStatus.name,
        ),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> _persistChildren(
    AuthContext context,
    String executionId,
    ServiceWorkExecutionDraft draft,
    DateTime now,
  ) async {
    var order = 0;
    for (final line in draft.workLines) {
      order++;
      await db
          .into(db.serviceWorkExecutionLines)
          .insert(
            ServiceWorkExecutionLinesCompanion.insert(
              id: line.id,
              companyId: context.company.id,
              workExecutionId: executionId,
              sourceJobAssignmentLineId: Value(line.sourceJobAssignmentLineId),
              lineNumber: order,
              work: line.work.trim(),
              description: Value(line.description.trim()),
              serviceTeamId: Value(line.serviceTeamId),
              employeeId: Value(line.employeeId),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
    order = 0;
    for (final material in draft.materialsUsed) {
      order++;
      await db
          .into(db.serviceWorkExecutionMaterialsUsed)
          .insert(
            ServiceWorkExecutionMaterialsUsedCompanion.insert(
              id: material.id,
              companyId: context.company.id,
              workExecutionId: executionId,
              sourceMaterialRequestLineId: Value(
                material.sourceMaterialRequestLineId,
              ),
              lineNumber: order,
              code: material.code.trim(),
              description: material.description.trim(),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
    order = 0;
    for (final entry in draft.afterWorkPhotoEntries) {
      order++;
      await db
          .into(db.serviceWorkExecutionPhotoEntries)
          .insert(
            ServiceWorkExecutionPhotoEntriesCompanion.insert(
              id: entry.id,
              companyId: context.company.id,
              workExecutionId: executionId,
              lineNumber: order,
              description: entry.description.trim(),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
    await _reconcilePhotoAttachments(context, executionId, draft, now);
  }

  Future<void> _reconcilePhotoAttachments(
    AuthContext context,
    String executionId,
    ServiceWorkExecutionDraft draft,
    DateTime now,
  ) async {
    final companyId = context.company.id;
    final allIds = await db
        .customSelect(
          'SELECT id FROM $_photoTable WHERE company_id=? AND work_execution_id=?',
          variables: [Variable(companyId), Variable(executionId)],
        )
        .get();
    final ownerIds = [for (final row in allIds) row.read<String>('id')];
    final existingResult = await attachments.getForOwners(
      companyId: companyId,
      ownerType: _photoOwnerType,
      ownerIds: ownerIds,
    );
    final existing = existingResult is Success<List<AttachmentRef>>
        ? existingResult.value
        : const <AttachmentRef>[];
    final existingById = {for (final a in existing) a.id: a};
    final desired = <String, ({String ownerId, AttachmentRef ref})>{
      for (final entry in draft.afterWorkPhotoEntries)
        for (final ref in entry.attachments)
          ref.id: (ownerId: entry.id, ref: ref),
    };
    for (final entry in desired.entries) {
      if (existingById.containsKey(entry.key)) continue;
      final ref = entry.value.ref;
      final result = await attachments.addLocalAttachment(
        AttachmentDraft(
          companyId: companyId,
          ownerType: _photoOwnerType,
          ownerId: entry.value.ownerId,
          category: AttachmentCategory.afterWorkPhoto,
          fileName: ref.fileName,
          displayName: ref.displayName,
          mimeType: ref.mimeType,
          sizeBytes: ref.sizeBytes,
          createdByUserId: context.user.id,
          localPath: ref.localPath,
          checksum: ref.checksum,
        ),
        id: ref.id,
      );
      if (result case Failed<AttachmentRef>(:final failure)) {
        throw _WorkExecutionException(failure.code);
      }
    }
    for (final ref in existing) {
      if (desired.containsKey(ref.id)) continue;
      await attachments.removeAttachment(
        companyId: companyId,
        attachmentId: ref.id,
      );
    }
  }

  @override
  Future<Result<ServiceWorkExecution>> updateExecution(
    AuthContext context,
    String id,
    ServiceWorkExecutionDraft draft, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceWorkExecutionEdit,
    );
    if (failure != null) return Failed(failure);
    final invalid = _validateDraft(draft);
    if (invalid != null) return Failed(invalid);
    try {
      return Success(
        await db.transaction(() async {
          final row = await _rawRow(context, id);
          if (row == null) {
            throw const _WorkExecutionException(
              'servicesWorkExecutionNotFound',
            );
          }
          final previous = await _aggregate(context, row);
          if (!previous.isEditable) {
            throw const _WorkExecutionException(
              'servicesWorkExecutionNotEditable',
            );
          }
          final effectiveRequest = requestId ?? _uuid.v4();
          final existingId = await _requestEntity(
            context.company.id,
            effectiveRequest,
          );
          if (existingId != null) {
            return await _aggregate(context, (await _rawRow(context, id))!);
          }
          await _validateTargets(context.company.id, draft.workLines);
          await _validateMaterialSources(
            context.company.id,
            previous.sourceInspectionId,
            draft.materialsUsed,
          );
          final now = clock.now();
          final source = await _sourceContext(
            context,
            previous.sourceInspectionId,
            viewOnly: true,
          );
          await _reconcileLines(context, id, previous, draft.workLines, now);
          await _reconcileMaterials(context, id, draft.materialsUsed, now);
          await _reconcilePhotoEntries(
            context,
            id,
            draft.afterWorkPhotoEntries,
            now,
          );
          await db.customUpdate(
            'UPDATE $_table SET job_order_reference=?, quotation_reference=?, search_text=?, '
            'version=version+1, updated_at=?, updated_by_user_id=?, sync_status=? WHERE company_id=? AND id=?',
            variables: [
              Variable(_nullable(draft.jobOrderReference)),
              Variable(_nullable(draft.quotationReference)),
              Variable(
                _searchText(
                  previous.executionNumber,
                  source?.inspectionNumber ?? '',
                  source?.assignmentNumber ?? '',
                  source?.enquiryNumber ?? '',
                  _nullable(draft.jobOrderReference),
                  _nullable(draft.quotationReference),
                  source?.partySnapshot ?? const ServiceEnquiryPartySnapshot(),
                  draft.workLines,
                  draft.materialsUsed,
                ),
              ),
              Variable(now),
              Variable(context.user.id),
              const Variable('pending'),
              Variable(context.company.id),
              Variable(id),
            ],
          );
          final updated = await _aggregate(
            context,
            (await _rawRow(context, id))!,
          );
          await _activity(context, updated, 'services.workExecution.updated');
          await _enqueue(
            context,
            updated,
            'SERVICES_WORK_EXECUTION_UPDATE',
            effectiveRequest,
          );
          return updated;
        }),
      );
    } on _WorkExecutionException catch (e) {
      return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  Future<void> _reconcileLines(
    AuthContext context,
    String executionId,
    ServiceWorkExecution previous,
    List<ServiceWorkExecutionLineDraft> draft,
    DateTime now,
  ) async {
    final existingById = {for (final l in previous.workLines) l.id: l};
    final draftIds = {for (final line in draft) line.id};
    for (final line in previous.workLines) {
      if (draftIds.contains(line.id)) continue;
      if (line.isStarted) {
        throw const _WorkExecutionException('servicesWorkExecutionNotEditable');
      }
      await (db.delete(db.serviceWorkExecutionLines)..where(
            (t) =>
                t.companyId.equals(context.company.id) & t.id.equals(line.id),
          ))
          .go();
    }
    var order = 0;
    for (final line in draft) {
      order++;
      final existing = existingById[line.id];
      if (existing != null) {
        await db.customUpdate(
          'UPDATE $_lineTable SET line_number=?, work=?, description=?, service_team_id=?, employee_id=?, updated_at=? '
          'WHERE company_id=? AND id=?',
          variables: [
            Variable(order),
            Variable(line.work.trim()),
            Variable(line.description.trim()),
            Variable(line.serviceTeamId),
            Variable(line.employeeId),
            Variable(now),
            Variable(context.company.id),
            Variable(line.id),
          ],
        );
      } else {
        await db
            .into(db.serviceWorkExecutionLines)
            .insert(
              ServiceWorkExecutionLinesCompanion.insert(
                id: line.id,
                companyId: context.company.id,
                workExecutionId: executionId,
                sourceJobAssignmentLineId: Value(
                  line.sourceJobAssignmentLineId,
                ),
                lineNumber: order,
                work: line.work.trim(),
                description: Value(line.description.trim()),
                serviceTeamId: Value(line.serviceTeamId),
                employeeId: Value(line.employeeId),
                createdAt: now,
                updatedAt: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    }
  }

  Future<void> _reconcileMaterials(
    AuthContext context,
    String executionId,
    List<ServiceWorkExecutionMaterialUsedDraft> draft,
    DateTime now,
  ) async {
    await (db.delete(db.serviceWorkExecutionMaterialsUsed)..where(
          (t) =>
              t.companyId.equals(context.company.id) &
              t.workExecutionId.equals(executionId),
        ))
        .go();
    var order = 0;
    for (final material in draft) {
      order++;
      await db
          .into(db.serviceWorkExecutionMaterialsUsed)
          .insert(
            ServiceWorkExecutionMaterialsUsedCompanion.insert(
              id: material.id,
              companyId: context.company.id,
              workExecutionId: executionId,
              sourceMaterialRequestLineId: Value(
                material.sourceMaterialRequestLineId,
              ),
              lineNumber: order,
              code: material.code.trim(),
              description: material.description.trim(),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  Future<void> _reconcilePhotoEntries(
    AuthContext context,
    String executionId,
    List<ServiceWorkExecutionPhotoEntryDraft> draft,
    DateTime now,
  ) async {
    final existingRows = await db
        .customSelect(
          'SELECT id FROM $_photoTable WHERE company_id=? AND work_execution_id=?',
          variables: [Variable(context.company.id), Variable(executionId)],
        )
        .get();
    final existingIds = {
      for (final row in existingRows) row.read<String>('id'),
    };
    final draftIds = {for (final entry in draft) entry.id};
    for (final removed in existingIds.difference(draftIds)) {
      final refs = await attachments.getForOwner(
        companyId: context.company.id,
        ownerType: _photoOwnerType,
        ownerId: removed,
      );
      if (refs is Success<List<AttachmentRef>>) {
        for (final ref in refs.value) {
          await attachments.removeAttachment(
            companyId: context.company.id,
            attachmentId: ref.id,
          );
        }
      }
      await (db.delete(db.serviceWorkExecutionPhotoEntries)..where(
            (t) =>
                t.companyId.equals(context.company.id) & t.id.equals(removed),
          ))
          .go();
    }
    var order = 0;
    for (final entry in draft) {
      order++;
      if (existingIds.contains(entry.id)) {
        await db.customUpdate(
          'UPDATE $_photoTable SET line_number=?, description=?, updated_at=? WHERE company_id=? AND id=?',
          variables: [
            Variable(order),
            Variable(entry.description.trim()),
            Variable(now),
            Variable(context.company.id),
            Variable(entry.id),
          ],
        );
      } else {
        await db
            .into(db.serviceWorkExecutionPhotoEntries)
            .insert(
              ServiceWorkExecutionPhotoEntriesCompanion.insert(
                id: entry.id,
                companyId: context.company.id,
                workExecutionId: executionId,
                lineNumber: order,
                description: entry.description.trim(),
                createdAt: now,
                updatedAt: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    }
    await _reconcilePhotoAttachments(
      context,
      executionId,
      ServiceWorkExecutionDraft(afterWorkPhotoEntries: draft),
      now,
    );
  }

  // ------------------------------------------------- operational actions

  Future<ServiceWorkExecution> _loadAggregateOrThrow(
    AuthContext context,
    String id,
  ) async {
    final row = await _rawRow(context, id);
    if (row == null) {
      throw const _WorkExecutionException('servicesWorkExecutionNotFound');
    }
    return _aggregate(context, row);
  }

  void _requireOpen(ServiceWorkExecution execution) {
    if (execution.isCompleted) {
      throw const _WorkExecutionException(
        'servicesWorkExecutionAlreadyCompleted',
      );
    }
    if (execution.isCancelled) {
      throw const _WorkExecutionException('servicesWorkExecutionCancelled');
    }
  }

  Future<Result<ServiceWorkExecution>> _operate(
    AuthContext context,
    String executionId,
    String requestId,
    Future<void> Function(ServiceWorkExecution execution) action,
    String operation,
    String? eventType,
  ) async {
    try {
      return Success(
        await db.transaction(() async {
          final execution = await _loadAggregateOrThrow(context, executionId);
          final existingId = await _requestEntity(
            context.company.id,
            requestId,
          );
          if (existingId != null) {
            return await _loadAggregateOrThrow(context, executionId);
          }
          await action(execution);
          final updated = await _loadAggregateOrThrow(context, executionId);
          if (eventType != null) {
            await _activity(context, updated, eventType);
          }
          await _enqueue(context, updated, operation, requestId);
          return updated;
        }),
      );
    } on _WorkExecutionException catch (e) {
      return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<ServiceWorkExecution>> startWorkLine(
    AuthContext context,
    String executionId,
    String lineId, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceWorkExecutionPerform,
    );
    if (failure != null) return Failed(failure);
    final effectiveRequest = requestId ?? _uuid.v4();
    return _operate(
      context,
      executionId,
      effectiveRequest,
      (execution) async {
        _requireOpen(execution);
        final line = execution.workLines
            .where((l) => l.id == lineId)
            .firstOrNull;
        if (line == null) {
          throw const _WorkExecutionException(
            'servicesWorkExecutionLineNotFound',
          );
        }
        if (line.isStarted) {
          throw const _WorkExecutionException(
            'servicesWorkExecutionLineAlreadyStarted',
          );
        }
        final now = clock.now().toUtc();
        await db.customUpdate(
          'UPDATE $_lineTable SET started_at_utc=?, updated_at=? WHERE company_id=? AND work_execution_id=? AND id=? AND started_at_utc IS NULL',
          variables: [
            Variable(now),
            Variable(now),
            Variable(context.company.id),
            Variable(executionId),
            Variable(lineId),
          ],
        );
        if (execution.isPending) {
          await db.customUpdate(
            "UPDATE $_table SET status='inProgress', version=version+1, updated_at=?, updated_by_user_id=?, sync_status=? WHERE company_id=? AND id=?",
            variables: [
              Variable(now),
              Variable(context.user.id),
              const Variable('pending'),
              Variable(context.company.id),
              Variable(executionId),
            ],
          );
        }
      },
      'SERVICES_WORK_EXECUTION_START_LINE',
      'services.workExecution.workStarted',
    );
  }

  @override
  Future<Result<ServiceWorkExecution>> endWorkLine(
    AuthContext context,
    String executionId,
    String lineId, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceWorkExecutionPerform,
    );
    if (failure != null) return Failed(failure);
    final effectiveRequest = requestId ?? _uuid.v4();
    return _operate(
      context,
      executionId,
      effectiveRequest,
      (execution) async {
        _requireOpen(execution);
        final line = execution.workLines
            .where((l) => l.id == lineId)
            .firstOrNull;
        if (line == null) {
          throw const _WorkExecutionException(
            'servicesWorkExecutionLineNotFound',
          );
        }
        if (!line.isStarted) {
          throw const _WorkExecutionException(
            'servicesWorkExecutionLineNotStarted',
          );
        }
        if (line.isFinished) {
          throw const _WorkExecutionException(
            'servicesWorkExecutionLineAlreadyEnded',
          );
        }
        final now = clock.now().toUtc();
        if (line.startedAtUtc != null && now.isBefore(line.startedAtUtc!)) {
          throw const _WorkExecutionException(
            'servicesWorkExecutionInvalidTimeRange',
          );
        }
        await db.customUpdate(
          'UPDATE $_lineTable SET ended_at_utc=?, updated_at=? WHERE company_id=? AND work_execution_id=? AND id=? AND ended_at_utc IS NULL',
          variables: [
            Variable(now),
            Variable(now),
            Variable(context.company.id),
            Variable(executionId),
            Variable(lineId),
          ],
        );
      },
      'SERVICES_WORK_EXECUTION_END_LINE',
      'services.workExecution.workEnded',
    );
  }

  @override
  Future<Result<ServiceWorkExecution>> addMaterialUsed(
    AuthContext context,
    String executionId,
    ServiceWorkExecutionMaterialUsedDraft draft, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceWorkExecutionPerform,
    );
    if (failure != null) return Failed(failure);
    if (draft.code.trim().isEmpty) {
      return const Failed(
        Failure(
          code: 'servicesWorkExecutionCodeRequired',
          kind: FailureKind.invalidData,
        ),
      );
    }
    if (draft.description.trim().isEmpty) {
      return const Failed(
        Failure(
          code: 'servicesWorkExecutionDescriptionRequired',
          kind: FailureKind.invalidData,
        ),
      );
    }
    final effectiveRequest = requestId ?? _uuid.v4();
    return _operate(
      context,
      executionId,
      effectiveRequest,
      (execution) async {
        _requireOpen(execution);
        await _validateMaterialSource(context, execution, draft);
        final now = clock.now();
        await db
            .into(db.serviceWorkExecutionMaterialsUsed)
            .insert(
              ServiceWorkExecutionMaterialsUsedCompanion.insert(
                id: draft.id,
                companyId: context.company.id,
                workExecutionId: executionId,
                sourceMaterialRequestLineId: Value(
                  draft.sourceMaterialRequestLineId,
                ),
                lineNumber: execution.materialsUsed.length + 1,
                code: draft.code.trim(),
                description: draft.description.trim(),
                createdAt: now,
                updatedAt: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      },
      'SERVICES_WORK_EXECUTION_UPDATE',
      'services.workExecution.materialUsedAdded',
    );
  }

  Future<void> _validateMaterialSource(
    AuthContext context,
    ServiceWorkExecution execution,
    ServiceWorkExecutionMaterialUsedDraft draft,
  ) => _validateMaterialSourceId(
    context.company.id,
    execution.sourceInspectionId,
    draft.sourceMaterialRequestLineId,
  );

  Future<void> _validateMaterialSources(
    String companyId,
    String sourceInspectionId,
    Iterable<ServiceWorkExecutionMaterialUsedDraft> drafts,
  ) async {
    for (final draft in drafts) {
      await _validateMaterialSourceId(
        companyId,
        sourceInspectionId,
        draft.sourceMaterialRequestLineId,
      );
    }
  }

  Future<void> _validateMaterialSourceId(
    String companyId,
    String sourceInspectionId,
    String? sourceLineId,
  ) async {
    if (sourceLineId == null) return;
    final row = await db
        .customSelect(
          'SELECT l.id FROM $_materialRequestLineTable l '
          'JOIN $_materialRequestTable r ON r.id=l.material_request_id AND r.company_id=l.company_id '
          'WHERE l.company_id=? AND l.id=? AND r.source_inspection_id=?',
          variables: [
            Variable(companyId),
            Variable(sourceLineId),
            Variable(sourceInspectionId),
          ],
        )
        .getSingleOrNull();
    if (row == null) {
      throw const _WorkExecutionException(
        'servicesWorkExecutionMaterialRequestLineInvalid',
      );
    }
  }

  @override
  Future<Result<ServiceWorkExecution>> removeMaterialUsed(
    AuthContext context,
    String executionId,
    String materialUsedId, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceWorkExecutionPerform,
    );
    if (failure != null) return Failed(failure);
    final effectiveRequest = requestId ?? _uuid.v4();
    return _operate(
      context,
      executionId,
      effectiveRequest,
      (execution) async {
        _requireOpen(execution);
        await (db.delete(db.serviceWorkExecutionMaterialsUsed)..where(
              (t) =>
                  t.companyId.equals(context.company.id) &
                  t.workExecutionId.equals(executionId) &
                  t.id.equals(materialUsedId),
            ))
            .go();
      },
      'SERVICES_WORK_EXECUTION_UPDATE',
      'services.workExecution.materialUsedRemoved',
    );
  }

  @override
  Future<Result<ServiceWorkExecution>> addPhotoEntry(
    AuthContext context,
    String executionId,
    ServiceWorkExecutionPhotoEntryDraft draft, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceWorkExecutionPerform,
    );
    if (failure != null) return Failed(failure);
    if (draft.description.trim().isEmpty) {
      return const Failed(
        Failure(
          code: 'servicesWorkExecutionPhotoDescriptionRequired',
          kind: FailureKind.invalidData,
        ),
      );
    }
    final effectiveRequest = requestId ?? _uuid.v4();
    return _operate(
      context,
      executionId,
      effectiveRequest,
      (execution) async {
        _requireOpen(execution);
        final now = clock.now();
        await db
            .into(db.serviceWorkExecutionPhotoEntries)
            .insert(
              ServiceWorkExecutionPhotoEntriesCompanion.insert(
                id: draft.id,
                companyId: context.company.id,
                workExecutionId: executionId,
                lineNumber: execution.afterWorkPhotoEntries.length + 1,
                description: draft.description.trim(),
                createdAt: now,
                updatedAt: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );
        await _reconcilePhotoAttachments(
          context,
          executionId,
          ServiceWorkExecutionDraft(afterWorkPhotoEntries: [draft]),
          now,
        );
      },
      'SERVICES_WORK_EXECUTION_UPDATE',
      'services.workExecution.photoAdded',
    );
  }

  @override
  Future<Result<ServiceWorkExecution>> updatePhotoEntryDescription(
    AuthContext context,
    String executionId,
    String photoEntryId,
    String description, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceWorkExecutionPerform,
    );
    if (failure != null) return Failed(failure);
    if (description.trim().isEmpty) {
      return const Failed(
        Failure(
          code: 'servicesWorkExecutionPhotoDescriptionRequired',
          kind: FailureKind.invalidData,
        ),
      );
    }
    final effectiveRequest = requestId ?? _uuid.v4();
    return _operate(
      context,
      executionId,
      effectiveRequest,
      (execution) async {
        _requireOpen(execution);
        final now = clock.now();
        await db.customUpdate(
          'UPDATE $_photoTable SET description=?, updated_at=? WHERE company_id=? AND work_execution_id=? AND id=?',
          variables: [
            Variable(description.trim()),
            Variable(now),
            Variable(context.company.id),
            Variable(executionId),
            Variable(photoEntryId),
          ],
        );
      },
      'SERVICES_WORK_EXECUTION_UPDATE',
      'services.workExecution.photoUpdated',
    );
  }

  @override
  Future<Result<ServiceWorkExecution>> removePhotoEntry(
    AuthContext context,
    String executionId,
    String photoEntryId, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceWorkExecutionPerform,
    );
    if (failure != null) return Failed(failure);
    final effectiveRequest = requestId ?? _uuid.v4();
    return _operate(
      context,
      executionId,
      effectiveRequest,
      (execution) async {
        _requireOpen(execution);
        final refs = await attachments.getForOwner(
          companyId: context.company.id,
          ownerType: _photoOwnerType,
          ownerId: photoEntryId,
        );
        if (refs is Success<List<AttachmentRef>>) {
          for (final ref in refs.value) {
            await attachments.removeAttachment(
              companyId: context.company.id,
              attachmentId: ref.id,
            );
          }
        }
        await (db.delete(db.serviceWorkExecutionPhotoEntries)..where(
              (t) =>
                  t.companyId.equals(context.company.id) &
                  t.workExecutionId.equals(executionId) &
                  t.id.equals(photoEntryId),
            ))
            .go();
      },
      'SERVICES_WORK_EXECUTION_UPDATE',
      'services.workExecution.photoRemoved',
    );
  }

  @override
  Future<Result<ServiceWorkExecution>> completeExecution(
    AuthContext context,
    String id, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceWorkExecutionComplete,
    );
    if (failure != null) return Failed(failure);
    final effectiveRequest = requestId ?? _uuid.v4();
    return _operate(
      context,
      id,
      effectiveRequest,
      (execution) async {
        if (execution.isCompleted) {
          throw const _WorkExecutionException(
            'servicesWorkExecutionAlreadyCompleted',
          );
        }
        if (execution.isCancelled) {
          throw const _WorkExecutionException('servicesWorkExecutionCancelled');
        }
        if (execution.workLines.isEmpty) {
          throw const _WorkExecutionException(
            'servicesWorkExecutionLinesRequired',
          );
        }
        if (execution.hasInvalidRange) {
          throw const _WorkExecutionException(
            'servicesWorkExecutionInvalidTimeRange',
          );
        }
        if (!execution.allLinesComplete) {
          throw const _WorkExecutionException(
            'servicesWorkExecutionNotCompletable',
          );
        }
        final now = clock.now();
        await db.customUpdate(
          "UPDATE $_table SET status='completed', version=version+1, updated_at=?, updated_by_user_id=?, sync_status=? WHERE company_id=? AND id=?",
          variables: [
            Variable(now),
            Variable(context.user.id),
            const Variable('pending'),
            Variable(context.company.id),
            Variable(id),
          ],
        );
      },
      'SERVICES_WORK_EXECUTION_COMPLETE',
      'services.workExecution.completed',
    );
  }

  @override
  Future<Result<ServiceWorkExecution>> cancelExecution(
    AuthContext context,
    String id, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceWorkExecutionCancel,
    );
    if (failure != null) return Failed(failure);
    final effectiveRequest = requestId ?? _uuid.v4();
    return _operate(
      context,
      id,
      effectiveRequest,
      (execution) async {
        if (execution.isCancelled) {
          throw const _WorkExecutionException('servicesWorkExecutionCancelled');
        }
        if (execution.isCompleted) {
          throw const _WorkExecutionException(
            'servicesWorkExecutionAlreadyCompleted',
          );
        }
        final now = clock.now();
        await db.customUpdate(
          "UPDATE $_table SET status='cancelled', version=version+1, updated_at=?, updated_by_user_id=?, sync_status=? WHERE company_id=? AND id=?",
          variables: [
            Variable(now),
            Variable(context.user.id),
            const Variable('pending'),
            Variable(context.company.id),
            Variable(id),
          ],
        );
      },
      'SERVICES_WORK_EXECUTION_CANCEL',
      'services.workExecution.cancelled',
    );
  }

  // ------------------------------------------------------------- activity

  Future<void> _activity(
    AuthContext context,
    ServiceWorkExecution e,
    String eventType,
  ) => activity.append(
    BusinessActivityEvent(
      id: _uuid.v4(),
      companyId: context.company.id,
      moduleKey: 'services',
      entityType: 'serviceWorkExecution',
      entityId: e.id,
      eventType: eventType,
      occurredAt: clock.now(),
      actorUserId: context.user.id,
      actorEmployeeId: context.employeeReference?.id,
      syncStatus: 'pending',
      metadata: {
        'executionNumber': e.executionNumber,
        'sourceInspectionId': e.sourceInspectionId,
        'status': e.status.wire,
        'workLineCount': e.workLines.length,
        'materialUsedCount': e.materialsUsed.length,
        'photoEntryCount': e.afterWorkPhotoEntries.length,
      },
    ),
  );

  Map<String, Object?> _linePayload(ServiceWorkExecutionLine line) => {
    'id': line.id,
    'sourceJobAssignmentLineId': line.sourceJobAssignmentLineId,
    'work': line.work,
    'description': line.description,
    'serviceTeamId': line.serviceTeamId,
    'employeeId': line.employeeId,
    'startedAtUtc': line.startedAtUtc?.toIso8601String(),
    'endedAtUtc': line.endedAtUtc?.toIso8601String(),
  };

  Future<void> _enqueue(
    AuthContext context,
    ServiceWorkExecution e,
    String operation,
    String requestId,
  ) => db
      .into(db.syncOutbox)
      .insert(
        SyncOutboxCompanion.insert(
          id: _uuid.v4(),
          moduleId: 'services',
          entityId: e.id,
          entityType: const Value('serviceWorkExecution'),
          operation: operation,
          payload: jsonEncode({
            'id': e.id,
            'executionNumber': e.executionNumber,
            'executionDate': e.executionDate.toIso8601String(),
            'sourceInspectionId': e.sourceInspectionId,
            'sourceJobAssignmentId': e.sourceJobAssignmentId,
            'sourceEnquiryId': e.sourceEnquiryId,
            'jobOrderReference': e.jobOrderReference,
            'quotationReference': e.quotationReference,
            'status': e.status.wire,
            'version': e.version,
            'workLines': [for (final line in e.workLines) _linePayload(line)],
            'materialsUsed': [
              for (final material in e.materialsUsed)
                {
                  'id': material.id,
                  'sourceMaterialRequestLineId':
                      material.sourceMaterialRequestLineId,
                  'code': material.code,
                  'description': material.description,
                },
            ],
            'afterWorkPhotoEntries': [
              for (final entry in e.afterWorkPhotoEntries)
                {
                  'id': entry.id,
                  'description': entry.description,
                  'attachments': [
                    for (final a in entry.attachments)
                      {
                        'id': a.id,
                        'fileName': a.fileName,
                        'mimeType': a.mimeType,
                        'sizeBytes': a.sizeBytes,
                        'category': a.category.value,
                      },
                  ],
                },
            ],
          }),
          createdAt: e.updatedAt,
          companyId: Value(context.company.id),
          requestId: Value(requestId),
        ),
        mode: InsertMode.insertOrIgnore,
      );
}

class _WorkExecutionException implements Exception {
  const _WorkExecutionException(this.code);
  final String code;
}
