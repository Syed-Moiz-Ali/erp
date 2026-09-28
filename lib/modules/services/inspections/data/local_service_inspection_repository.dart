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
import 'package:modular_erp/modules/services/inspections/domain/service_inspection_repository.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection_scope.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/notifications/domain/app_notification.dart';
import 'package:modular_erp/platform/notifications/domain/notification_repository.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';
import 'package:modular_erp/shared/transactions/domain/attachment_repository.dart';
import 'package:modular_erp/shared/transactions/domain/document_number.dart';
import 'package:modular_erp/shared/transactions/domain/document_number_service.dart';

/// Local (Drift) implementation of the Service Inspection transaction.
class LocalServiceInspectionRepository implements ServiceInspectionRepository {
  LocalServiceInspectionRepository(
    this.db,
    this.clock,
    this.numbers,
    this.activity,
    this.attachments,
    this.workforce,
    this.time, {
    NotificationRepository? notifications,
    ServiceInspectionScopeResolver scopeResolver =
        const ServiceInspectionScopeResolver(),
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
  final ServiceInspectionScopeResolver _scopeResolver;
  final Uuid _uuid;

  static const _table = 'service_inspections';
  static const _checklistTable = 'service_inspection_checklist_items';
  static const _pointTable = 'service_inspection_points';
  static const _materialTable = 'service_inspection_material_requirements';
  static const _checklistOwnerType = 'serviceInspectionChecklistItem';

  Failure? _denied() => const Failure(code: 'servicesInspectionDenied');

  bool _enabled(AuthContext c) =>
      c.user.status == AccountStatus.active &&
      c.user.companyId == c.company.id &&
      c.company.enabledModules.contains('services');

  bool _can(AuthContext c, AppPermission p) => c.user.permissions.contains(p);

  ServiceInspectionScope _scope(AuthContext c) => _scopeResolver.resolve(c);

  Failure? _viewAccess(AuthContext c) =>
      _enabled(c) && _scope(c) != ServiceInspectionScope.none
      ? null
      : _denied();

  Failure? _actionAccess(AuthContext c, AppPermission p) =>
      _enabled(c) && _can(c, p) ? null : _denied();

  Failure? _referenceAccess(AuthContext c) =>
      _enabled(c) &&
          (_can(c, AppPermission.serviceInspectionCreate) ||
              _can(c, AppPermission.serviceInspectionEdit))
      ? null
      : _denied();

  static const _listColumns =
      'i.*, a.assignment_number, e.enquiry_number, e.party_snapshot, '
      'pr.name AS priority_name, pr.rank AS priority_rank';

  static const _listJoins =
      'LEFT JOIN service_job_assignments a ON a.id=i.source_job_assignment_id AND a.company_id=i.company_id '
      'LEFT JOIN service_enquiries e ON e.id=i.source_enquiry_id AND e.company_id=i.company_id '
      'LEFT JOIN service_priorities pr ON pr.id=e.priority_id AND pr.company_id=e.company_id';

  Set<ResultSetImplementation> get _reads => {
    db.serviceInspections,
    db.serviceJobAssignments,
    db.serviceEnquiries,
    db.servicePriorities,
    db.serviceJobAssignmentLines,
    db.serviceTeamMembers,
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
    final company = Variable(context.company.id);
    switch (_scope(context)) {
      case ServiceInspectionScope.all:
        return (sql: 'i.company_id=?', variables: [company]);
      case ServiceInspectionScope.team:
      case ServiceInspectionScope.assigned:
        final employeeId = context.employeeReference?.id;
        if (employeeId == null) return (sql: '0', variables: const []);
        const teamExists =
            "EXISTS (SELECT 1 FROM service_job_assignment_lines l WHERE l.company_id=i.company_id AND l.assignment_id=i.source_job_assignment_id AND l.removed_at IS NULL AND l.assigned_team_id IN (SELECT tm.team_id FROM service_team_members tm WHERE tm.company_id=i.company_id AND tm.employee_id=? AND tm.status='active'))";
        if (_scope(context) == ServiceInspectionScope.team) {
          return (
            sql: 'i.company_id=? AND $teamExists',
            variables: [company, Variable(employeeId)],
          );
        }
        const employeeExists =
            "EXISTS (SELECT 1 FROM service_job_assignment_lines l WHERE l.company_id=i.company_id AND l.assignment_id=i.source_job_assignment_id AND l.removed_at IS NULL AND l.assigned_employee_id=?)";
        return (
          sql:
              'i.company_id=? AND (i.technician_employee_id=? OR $employeeExists OR $teamExists)',
          variables: [
            company,
            Variable(employeeId),
            Variable(employeeId),
            Variable(employeeId),
          ],
        );
      case ServiceInspectionScope.none:
        return (sql: '0', variables: const []);
    }
  }

  ({String sql, List<Variable> variables}) _where(
    AuthContext context, {
    String query = '',
    ServiceInspectionStatus? status,
    String? technicianEmployeeId,
    String? rootCauseId,
    String? priorityId,
    DateTime? visitFrom,
    DateTime? visitTo,
  }) {
    final scope = _scopeClause(context);
    final parts = <String>[scope.sql];
    final variables = <Variable>[...scope.variables];
    if (status != null) {
      parts.add('i.status=?');
      variables.add(Variable(status.wire));
    }
    if (technicianEmployeeId != null) {
      parts.add('i.technician_employee_id=?');
      variables.add(Variable(technicianEmployeeId));
    }
    if (rootCauseId != null) {
      parts.add('i.root_cause_id=?');
      variables.add(Variable(rootCauseId));
    }
    if (priorityId != null) {
      parts.add('e.priority_id=?');
      variables.add(Variable(priorityId));
    }
    if (visitFrom != null) {
      parts.add('i.visit_date>=?');
      variables.add(Variable(visitFrom));
    }
    if (visitTo != null) {
      parts.add('i.visit_date<=?');
      variables.add(Variable(visitTo));
    }
    if (query.trim().isNotEmpty) {
      final escaped = query
          .trim()
          .toLowerCase()
          .replaceAll('\\', '\\\\')
          .replaceAll('%', '\\%')
          .replaceAll('_', '\\_');
      parts.add(
        "(lower(i.inspection_number) LIKE ? ESCAPE '\\' OR i.search_text LIKE ? ESCAPE '\\' "
        "OR lower(COALESCE(a.assignment_number,'')) LIKE ? ESCAPE '\\' "
        "OR lower(COALESCE(e.enquiry_number,'')) LIKE ? ESCAPE '\\')",
      );
      variables.addAll([for (var k = 0; k < 4; k++) Variable('%$escaped%')]);
    }
    return (sql: parts.join(' AND '), variables: variables);
  }

  Future<int> _count(
    AuthContext context,
    ({String sql, List<Variable> variables}) where,
  ) async {
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM $_table i $_listJoins WHERE ${where.sql}',
          variables: where.variables,
        )
        .getSingle();
    return row.read<int>('c');
  }

  ServiceInspection _record(
    QueryRow row, {
    List<ServiceInspectionChecklistItem> checklist = const [],
    List<ServiceInspectionPoint> points = const [],
    List<ServiceInspectionMaterialRequirement> materials = const [],
  }) => ServiceInspection(
    id: row.read<String>('id'),
    companyId: row.read<String>('company_id'),
    inspectionNumber: row.read<String>('inspection_number'),
    inspectionDate: row.read<DateTime>('inspection_date').toUtc(),
    sourceJobAssignmentId: row.read<String>('source_job_assignment_id'),
    sourceEnquiryId: row.read<String>('source_enquiry_id'),
    visitDate: row.read<DateTime>('visit_date').toUtc(),
    visitMinutes: row.readNullable<int>('visit_minutes'),
    technicianEmployeeId: row.readNullable<String>('technician_employee_id'),
    rootCauseId: row.readNullable<String>('root_cause_id'),
    chargeResponsibilityId: row.readNullable<String>(
      'charge_responsibility_id',
    ),
    status: ServiceInspectionStatusX.fromWire(row.read<String>('status')),
    checklistItems: checklist,
    inspectedPoints: points,
    materialRequirements: materials,
    version: row.read<int>('version'),
    createdAt: row.read<DateTime>('created_at').toUtc(),
    updatedAt: row.read<DateTime>('updated_at').toUtc(),
    createdByUserId: row.read<String>('created_by_user_id'),
    updatedByUserId: row.read<String>('updated_by_user_id'),
    requestId: row.readNullable<String>('request_id'),
    syncStatus: RecordSyncStatus.values.byName(row.read<String>('sync_status')),
  );

  Future<Map<String, List<AttachmentRef>>> _attachmentsByOwner(
    String companyId,
    List<String> ownerIds,
  ) async {
    if (ownerIds.isEmpty) return const {};
    final result = await attachments.getForOwners(
      companyId: companyId,
      ownerType: _checklistOwnerType,
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

  Future<
    ({
      List<ServiceInspectionChecklistItem> checklist,
      List<ServiceInspectionPoint> points,
      List<ServiceInspectionMaterialRequirement> materials,
    })
  >
  _loadChildren(String companyId, String inspectionId) async {
    final checklistRows = await db
        .customSelect(
          'SELECT * FROM $_checklistTable WHERE company_id=? AND inspection_id=? AND removed_at IS NULL ORDER BY line_number, id',
          variables: [Variable(companyId), Variable(inspectionId)],
        )
        .get();
    final byOwner = await _attachmentsByOwner(companyId, [
      for (final row in checklistRows) row.read<String>('id'),
    ]);
    final checklist = [
      for (final row in checklistRows)
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
    final pointRows = await db
        .customSelect(
          'SELECT * FROM $_pointTable WHERE company_id=? AND inspection_id=? AND removed_at IS NULL ORDER BY line_number, id',
          variables: [Variable(companyId), Variable(inspectionId)],
        )
        .get();
    final points = [
      for (final row in pointRows)
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
    final materialRows = await db
        .customSelect(
          'SELECT * FROM $_materialTable WHERE company_id=? AND inspection_id=? AND removed_at IS NULL ORDER BY line_number, id',
          variables: [Variable(companyId), Variable(inspectionId)],
        )
        .get();
    final materials = [
      for (final row in materialRows)
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
    return (checklist: checklist, points: points, materials: materials);
  }

  Future<Map<String, String>> _employeeNames(Iterable<String> ids) async {
    final wanted = {
      for (final id in ids)
        if (id.isNotEmpty) id,
    };
    if (wanted.isEmpty) return const {};
    final refs = await workforce.getEmployees(wanted);
    return {for (final ref in refs) ref.id: ref.name};
  }

  Future<Map<String, String>> _masterNames(
    String table,
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
          'SELECT id, name FROM $table WHERE company_id=? AND id IN ($placeholders)',
          variables: [Variable(companyId), ...wanted.map((id) => Variable(id))],
        )
        .get();
    return {
      for (final row in rows) row.read<String>('id'): row.read<String>('name'),
    };
  }

  ServiceInspectionListItem _listItem(
    QueryRow row,
    Map<String, String> employeeNames,
    Map<String, String> rootCauseNames,
  ) {
    final snapshot = _snapshot(row.readNullable<String>('party_snapshot'));
    final site = [
      snapshot.buildingName,
      snapshot.unitNumber,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' / ');
    final techId = row.readNullable<String>('technician_employee_id');
    final rcId = row.readNullable<String>('root_cause_id');
    return ServiceInspectionListItem(
      id: row.read<String>('id'),
      inspectionNumber: row.read<String>('inspection_number'),
      createdAt: row.read<DateTime>('created_at').toUtc(),
      visitDate: row.read<DateTime>('visit_date').toUtc(),
      visitMinutes: row.readNullable<int>('visit_minutes'),
      status: ServiceInspectionStatusX.fromWire(row.read<String>('status')),
      assignmentNumber: row.readNullable<String>('assignment_number') ?? '',
      enquiryNumber: row.readNullable<String>('enquiry_number') ?? '',
      customerName: snapshot.customerName ?? '',
      siteSummary: site.isEmpty ? (snapshot.siteName ?? '') : site,
      technicianName: techId == null ? null : employeeNames[techId],
      rootCauseName: rcId == null ? null : rootCauseNames[rcId],
    );
  }

  Stream<Result<ServiceInspectionPage>> _watchPage(
    AuthContext context, {
    required ({String sql, List<Variable> variables}) where,
    required int page,
    required int limit,
  }) {
    final sql =
        'SELECT $_listColumns FROM $_table i $_listJoins '
        'WHERE ${where.sql} '
        'ORDER BY i.visit_date DESC, i.created_at DESC, i.id DESC LIMIT ? OFFSET ?';
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
        .asyncMap<Result<ServiceInspectionPage>>((rows) async {
          final scope = _scopeClause(context);
          final total = await _count(context, (
            sql: scope.sql,
            variables: scope.variables,
          ));
          final filtered = await _count(context, where);
          final employeeNames = await _employeeNames([
            for (final row in rows)
              row.readNullable<String>('technician_employee_id') ?? '',
          ]);
          final rootCauseNames = await _masterNames(
            'service_root_causes',
            context.company.id,
            [
              for (final row in rows)
                row.readNullable<String>('root_cause_id') ?? '',
            ],
          );
          return Success(
            ServiceInspectionPage(
              [
                for (final row in rows)
                  _listItem(row, employeeNames, rootCauseNames),
              ],
              total,
              filtered,
            ),
          );
        })
        .transform(
          StreamTransformer<
            Result<ServiceInspectionPage>,
            Result<ServiceInspectionPage>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceInspectionPage>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  @override
  Stream<Result<ServiceInspectionPage>> watchInspections(
    AuthContext context, {
    String query = '',
    ServiceInspectionStatus? status,
    String? technicianEmployeeId,
    String? rootCauseId,
    String? priorityId,
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
        technicianEmployeeId: technicianEmployeeId,
        rootCauseId: rootCauseId,
        priorityId: priorityId,
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
          'SELECT $_listColumns FROM $_table i $_listJoins '
          'WHERE i.id=? AND ${scope.sql}',
          variables: [Variable(id), ...scope.variables],
        )
        .getSingleOrNull();
  }

  Future<ServiceInspectionView> _view(AuthContext context, QueryRow row) async {
    final id = row.read<String>('id');
    final children = await _loadChildren(context.company.id, id);
    final technicianId = row.readNullable<String>('technician_employee_id');
    final rootCauseId = row.readNullable<String>('root_cause_id');
    final chargeId = row.readNullable<String>('charge_responsibility_id');
    final employeeRefs = technicianId == null
        ? const <WorkforcePersonRef>[]
        : await workforce.getEmployees([technicianId]);
    final rootCauseNames = await _masterNames(
      'service_root_causes',
      context.company.id,
      [rootCauseId ?? ''],
    );
    final chargeNames = await _masterNames(
      'service_charge_responsibilities',
      context.company.id,
      [chargeId ?? ''],
    );
    final sourceContext = await _sourceContext(
      context,
      row.read<String>('source_job_assignment_id'),
    );
    return ServiceInspectionView(
      inspection: _record(
        row,
        checklist: children.checklist,
        points: children.points,
        materials: children.materials,
      ),
      assignmentNumber: row.readNullable<String>('assignment_number') ?? '',
      enquiryNumber:
          sourceContext?.enquiryNumber ??
          row.readNullable<String>('enquiry_number') ??
          '',
      customerName: sourceContext?.customerName ?? '',
      customerMobile: sourceContext?.customerMobile,
      priorityName:
          sourceContext?.priorityName ??
          row.readNullable<String>('priority_name') ??
          '',
      priorityRank:
          sourceContext?.priorityRank ??
          row.readNullable<int>('priority_rank') ??
          0,
      complaintTypeName: sourceContext?.complaintTypeName ?? '',
      materialReceived: sourceContext?.materialReceived ?? MaterialReceived.no,
      partySnapshot:
          sourceContext?.partySnapshot ?? const ServiceEnquiryPartySnapshot(),
      technicianName: employeeRefs.isEmpty ? null : employeeRefs.first.name,
      technicianCode: employeeRefs.isEmpty
          ? null
          : employeeRefs.first.employeeCode,
      rootCauseName: rootCauseId == null ? null : rootCauseNames[rootCauseId],
      chargeResponsibilityName: chargeId == null ? null : chargeNames[chargeId],
    );
  }

  @override
  Stream<Result<ServiceInspectionView?>> watchInspection(
    AuthContext context,
    String id,
  ) {
    final failure = _viewAccess(context);
    if (failure != null) return Stream.value(Failed(failure));
    final scope = _scopeClause(context);
    return db
        .customSelect(
          'SELECT $_listColumns FROM $_table i $_listJoins '
          'WHERE i.id=? AND ${scope.sql}',
          variables: [Variable(id), ...scope.variables],
          readsFrom: {
            ..._reads,
            db.serviceInspectionChecklistItems,
            db.serviceInspectionPoints,
            db.serviceInspectionMaterialRequirements,
          },
        )
        .watchSingleOrNull()
        .asyncMap<Result<ServiceInspectionView?>>((row) async {
          if (row == null) {
            return const Success<ServiceInspectionView?>(null);
          }
          return Success<ServiceInspectionView?>(await _view(context, row));
        })
        .transform(
          StreamTransformer<
            Result<ServiceInspectionView?>,
            Result<ServiceInspectionView?>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceInspectionView?>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  @override
  Future<Result<ServiceInspectionView?>> getInspection(
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

  Failure? _validateDraft(ServiceInspectionDraft draft) {
    if (draft.sourceJobAssignmentId == null) {
      return const Failure(code: 'servicesInspectionAssignmentRequired');
    }
    if (draft.visitDate == null) {
      return const Failure(code: 'servicesInspectionVisitDateRequired');
    }
    for (final item in draft.checklistItems) {
      if (item.workType.trim().isEmpty) {
        return const Failure(code: 'servicesInspectionWorkTypeRequired');
      }
    }
    for (final point in draft.inspectedPoints) {
      if (point.description.trim().isEmpty) {
        return const Failure(code: 'servicesInspectionPointRequired');
      }
    }
    for (final material in draft.materialRequirements) {
      if (material.code.trim().isEmpty) {
        return const Failure(code: 'servicesInspectionMaterialCodeRequired');
      }
      if (material.description.trim().isEmpty) {
        return const Failure(
          code: 'servicesInspectionMaterialDescriptionRequired',
        );
      }
    }
    return null;
  }

  Future<QueryRow?> _assignmentRow(String companyId, String id) => db
      .customSelect(
        'SELECT id, status, source_enquiry_id FROM service_job_assignments WHERE company_id=? AND id=?',
        variables: [Variable(companyId), Variable(id)],
      )
      .getSingleOrNull();

  Future<QueryRow?> _enquiryRow(String companyId, String id) => db
      .customSelect(
        'SELECT enquiry_number, party_snapshot, material_received, complaint_type_id, priority_id '
        'FROM service_enquiries WHERE company_id=? AND id=?',
        variables: [Variable(companyId), Variable(id)],
      )
      .getSingleOrNull();

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

  Future<bool> _masterActive(String table, String companyId, String id) async {
    final row = await db
        .customSelect(
          'SELECT status FROM $table WHERE company_id=? AND id=?',
          variables: [Variable(companyId), Variable(id)],
        )
        .getSingleOrNull();
    return row != null &&
        row.read<String>('status') == ConfigurationStatus.active.name;
  }

  Future<List<ServiceJobAssignmentLine>> _assignmentLines(
    String companyId,
    String assignmentId,
  ) async {
    final rows = await db
        .customSelect(
          'SELECT * FROM service_job_assignment_lines WHERE company_id=? AND assignment_id=? AND removed_at IS NULL ORDER BY line_number, id',
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

  Future<List<ServiceInspectionTechnicianRef>> _eligibleTechnicians(
    String companyId,
    List<ServiceJobAssignmentLine> lines,
  ) async {
    final employeeIds = <String>{};
    final teamIds = <String>{};
    for (final line in lines) {
      if (line.assignedEmployeeId != null) {
        employeeIds.add(line.assignedEmployeeId!);
      }
      if (line.assignedTeamId != null) teamIds.add(line.assignedTeamId!);
    }
    for (final teamId in teamIds) {
      final rows = await db
          .customSelect(
            "SELECT employee_id FROM service_team_members WHERE company_id=? AND team_id=? AND status='active'",
            variables: [Variable(companyId), Variable(teamId)],
          )
          .get();
      for (final row in rows) {
        employeeIds.add(row.read<String>('employee_id'));
      }
      final lead = await db
          .customSelect(
            'SELECT lead_employee_id FROM service_teams WHERE company_id=? AND id=?',
            variables: [Variable(companyId), Variable(teamId)],
          )
          .getSingleOrNull();
      final leadId = lead?.readNullable<String>('lead_employee_id');
      if (leadId != null) employeeIds.add(leadId);
    }
    final refs = await workforce.getEmployees(employeeIds);
    return [
      for (final ref in refs)
        if (ref.isActive)
          ServiceInspectionTechnicianRef(
            id: ref.id,
            name: ref.name,
            employeeCode: ref.employeeCode,
          ),
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<ServiceInspectionSourceContext?> _sourceContext(
    AuthContext context,
    String assignmentId,
  ) async {
    final companyId = context.company.id;
    final assignment = await _assignmentRow(companyId, assignmentId);
    if (assignment == null) return null;
    final enquiryId = assignment.read<String>('source_enquiry_id');
    final enquiry = await _enquiryRow(companyId, enquiryId);
    if (enquiry == null) return null;
    final lines = await _assignmentLines(companyId, assignmentId);
    final technicians = await _eligibleTechnicians(companyId, lines);
    final snapshot = _snapshot(enquiry.readNullable<String>('party_snapshot'));
    final priorityId = enquiry.readNullable<String>('priority_id');
    final rankRow = priorityId == null
        ? null
        : await db
              .customSelect(
                'SELECT rank FROM service_priorities WHERE company_id=? AND id=?',
                variables: [Variable(companyId), Variable(priorityId)],
              )
              .getSingleOrNull();
    return ServiceInspectionSourceContext(
      jobAssignmentId: assignmentId,
      assignmentNumber: await _assignmentNumber(companyId, assignmentId),
      enquiryId: enquiryId,
      enquiryNumber: enquiry.read<String>('enquiry_number'),
      customerName: snapshot.customerName ?? '',
      customerMobile: snapshot.customerMobile,
      priorityName: await _masterName(
        'service_priorities',
        companyId,
        priorityId,
      ),
      priorityRank: rankRow?.read<int>('rank') ?? 0,
      complaintTypeName: await _masterName(
        'complaint_types',
        companyId,
        enquiry.readNullable<String>('complaint_type_id'),
      ),
      materialReceived: MaterialReceivedX.fromWire(
        enquiry.readNullable<String>('material_received') ?? 'no',
      ),
      partySnapshot: snapshot,
      scheduledVisitDate: DateTime.utc(
        (await _assignmentVisit(companyId, assignmentId)).year,
        (await _assignmentVisit(companyId, assignmentId)).month,
        (await _assignmentVisit(companyId, assignmentId)).day,
      ),
      workLines: lines,
      eligibleTechnicians: technicians,
    );
  }

  Future<String> _assignmentNumber(String companyId, String id) async {
    final row = await db
        .customSelect(
          'SELECT assignment_number FROM service_job_assignments WHERE company_id=? AND id=?',
          variables: [Variable(companyId), Variable(id)],
        )
        .getSingleOrNull();
    return row?.read<String>('assignment_number') ?? '';
  }

  Future<DateTime> _assignmentVisit(String companyId, String id) async {
    final row = await db
        .customSelect(
          'SELECT scheduled_visit_date FROM service_job_assignments WHERE company_id=? AND id=?',
          variables: [Variable(companyId), Variable(id)],
        )
        .getSingleOrNull();
    return row?.read<DateTime>('scheduled_visit_date').toUtc() ??
        DateTime.now();
  }

  @override
  Future<Result<ServiceInspectionSourceContext?>> getSourceContext(
    AuthContext context,
    String jobAssignmentId,
  ) async {
    final failure = _referenceAccess(context);
    if (failure != null) return Failed(failure);
    try {
      return Success(await _sourceContext(context, jobAssignmentId));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<List<ServiceAssignableJobAssignmentRef>>>
  searchEligibleJobAssignments(
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
            "SELECT a.id, a.assignment_number, a.scheduled_visit_date, "
            "e.enquiry_number, e.party_snapshot, pr.name AS priority_name "
            "FROM service_job_assignments a "
            "LEFT JOIN service_enquiries e ON e.id=a.source_enquiry_id AND e.company_id=a.company_id "
            "LEFT JOIN service_priorities pr ON pr.id=e.priority_id AND pr.company_id=e.company_id "
            "WHERE a.company_id=? AND a.status='active' "
            "AND NOT EXISTS (SELECT 1 FROM $_table i WHERE i.company_id=a.company_id AND i.source_job_assignment_id=a.id AND i.status<>'cancelled') "
            "AND (lower(a.assignment_number) LIKE ? ESCAPE '\\' OR a.search_text LIKE ? ESCAPE '\\' "
            "OR lower(COALESCE(e.enquiry_number,'')) LIKE ? ESCAPE '\\') "
            "ORDER BY a.scheduled_visit_date DESC, a.created_at DESC LIMIT ?",
            variables: [
              Variable(context.company.id),
              Variable('%$escaped%'),
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

  ServiceAssignableJobAssignmentRef _assignableRef(QueryRow row) {
    final snapshot = _snapshot(row.readNullable<String>('party_snapshot'));
    final site = [
      snapshot.buildingName,
      snapshot.unitNumber,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' / ');
    return ServiceAssignableJobAssignmentRef(
      id: row.read<String>('id'),
      assignmentNumber: row.read<String>('assignment_number'),
      enquiryNumber: row.readNullable<String>('enquiry_number') ?? '',
      customerName: snapshot.customerName ?? '',
      customerMobile: snapshot.customerMobile,
      siteSummary: site.isEmpty ? (snapshot.siteName ?? '') : site,
      scheduledVisitDate: row.read<DateTime>('scheduled_visit_date').toUtc(),
      priorityName: row.readNullable<String>('priority_name'),
    );
  }

  Future<ServiceInspectionRef?> _refForAssignment(
    AuthContext context,
    String assignmentId,
  ) async {
    final scope = _scopeClause(context);
    final row = await db
        .customSelect(
          'SELECT i.id, i.inspection_number, i.status, i.visit_date, i.visit_minutes, '
          'i.technician_employee_id, i.root_cause_id FROM $_table i '
          "WHERE i.company_id=? AND i.source_job_assignment_id=? AND i.status<>'cancelled' "
          'AND ${scope.sql} LIMIT 1',
          variables: [
            Variable(context.company.id),
            Variable(assignmentId),
            ...scope.variables,
          ],
        )
        .getSingleOrNull();
    if (row == null) return null;
    final techId = row.readNullable<String>('technician_employee_id');
    final rcId = row.readNullable<String>('root_cause_id');
    final names = await _employeeNames([techId ?? '']);
    final rc = await _masterNames('service_root_causes', context.company.id, [
      rcId ?? '',
    ]);
    return ServiceInspectionRef(
      id: row.read<String>('id'),
      inspectionNumber: row.read<String>('inspection_number'),
      status: ServiceInspectionStatusX.fromWire(row.read<String>('status')),
      visitDate: row.read<DateTime>('visit_date').toUtc(),
      visitMinutes: row.readNullable<int>('visit_minutes'),
      technicianName: techId == null ? null : names[techId],
      rootCauseName: rcId == null ? null : rc[rcId],
    );
  }

  @override
  Future<Result<ServiceInspectionRef?>> getInspectionForAssignment(
    AuthContext context,
    String jobAssignmentId,
  ) async {
    final failure = _viewAccess(context);
    if (failure != null) return Failed(failure);
    try {
      return Success(await _refForAssignment(context, jobAssignmentId));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Stream<Result<ServiceInspectionRef?>> watchInspectionForAssignment(
    AuthContext context,
    String jobAssignmentId,
  ) {
    final failure = _viewAccess(context);
    if (failure != null) return Stream.value(Failed(failure));
    return db
        .customSelect(
          'SELECT 1 FROM $_table WHERE company_id=?',
          variables: [Variable(context.company.id)],
          readsFrom: {
            db.serviceInspections,
            db.serviceInspectionChecklistItems,
          },
        )
        .watch()
        .asyncMap<Result<ServiceInspectionRef?>>(
          (_) async =>
              Success(await _refForAssignment(context, jobAssignmentId)),
        )
        .transform(
          StreamTransformer<
            Result<ServiceInspectionRef?>,
            Result<ServiceInspectionRef?>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceInspectionRef?>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  // ------------------------------------------------------------- summary

  @override
  Future<Result<ServiceInspectionSummary>> summary(AuthContext context) async {
    final failure = _viewAccess(context);
    if (failure != null) return Failed(failure);
    try {
      final scope = _scopeClause(context);
      final today = _companyDate(context);
      final row = await db
          .customSelect(
            'SELECT COUNT(*) AS total, '
            "SUM(CASE WHEN i.status='pending' THEN 1 ELSE 0 END) AS pending_count, "
            "SUM(CASE WHEN i.status='completed' THEN 1 ELSE 0 END) AS completed_count, "
            "SUM(CASE WHEN i.visit_date=? THEN 1 ELSE 0 END) AS today_count "
            'FROM $_table i WHERE ${scope.sql}',
            variables: [Variable(today), ...scope.variables],
          )
          .getSingle();
      return Success(
        ServiceInspectionSummary(
          pendingCount: row.readNullable<int>('pending_count') ?? 0,
          todayCount: row.readNullable<int>('today_count') ?? 0,
          completedCount: row.readNullable<int>('completed_count') ?? 0,
          totalCount: row.read<int>('total'),
        ),
      );
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Stream<Result<List<ServiceInspectionListItem>>> watchRecentInspections(
    AuthContext context, {
    int limit = 5,
  }) {
    final failure = _viewAccess(context);
    if (failure != null) return Stream.value(Failed(failure));
    final scope = _scopeClause(context);
    return db
        .customSelect(
          'SELECT $_listColumns FROM $_table i $_listJoins '
          'WHERE ${scope.sql} '
          'ORDER BY i.visit_date DESC, i.created_at DESC LIMIT ?',
          variables: [...scope.variables, Variable(limit.clamp(1, 50))],
          readsFrom: _reads,
        )
        .watch()
        .asyncMap<Result<List<ServiceInspectionListItem>>>((rows) async {
          final employeeNames = await _employeeNames([
            for (final row in rows)
              row.readNullable<String>('technician_employee_id') ?? '',
          ]);
          final rootCauseNames = await _masterNames(
            'service_root_causes',
            context.company.id,
            [
              for (final row in rows)
                row.readNullable<String>('root_cause_id') ?? '',
            ],
          );
          return Success([
            for (final row in rows)
              _listItem(row, employeeNames, rootCauseNames),
          ]);
        })
        .transform(
          StreamTransformer<
            Result<List<ServiceInspectionListItem>>,
            Result<List<ServiceInspectionListItem>>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<List<ServiceInspectionListItem>>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  // -------------------------------------------------------- create/update

  DateTime _companyDate(AuthContext context) {
    final local = time.localWallTime(clock.now(), context.company.timezone);
    final wall = local is Success<DateTime> ? local.value : clock.now().toUtc();
    return DateTime.utc(wall.year, wall.month, wall.day);
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime.utc(value.year, value.month, value.day);

  String _searchText(
    String inspectionNumber,
    String assignmentNumber,
    String enquiryNumber,
    ServiceEnquiryPartySnapshot snapshot,
    String? technicianName,
    String? rootCauseName,
  ) =>
      [
            inspectionNumber,
            assignmentNumber,
            enquiryNumber,
            snapshot.customerName,
            snapshot.customerMobile,
            snapshot.siteName,
            snapshot.buildingName,
            snapshot.unitNumber,
            technicianName,
            rootCauseName,
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
  Future<Result<ServiceInspection>> createInspection(
    AuthContext context,
    ServiceInspectionDraft draft, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceInspectionCreate,
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
              final children = await _loadChildren(
                context.company.id,
                existingId,
              );
              return _record(
                row,
                checklist: children.checklist,
                points: children.points,
                materials: children.materials,
              );
            }
          }
          final assignment = await _assignmentRow(
            context.company.id,
            draft.sourceJobAssignmentId!,
          );
          if (assignment == null ||
              assignment.read<String>('status') !=
                  ServiceJobAssignmentStatus.active.wire) {
            throw const _InspectionException(
              'servicesInspectionAssignmentInvalid',
            );
          }
          final active = await db
              .customSelect(
                "SELECT 1 FROM $_table WHERE company_id=? AND source_job_assignment_id=? AND status<>'cancelled' LIMIT 1",
                variables: [
                  Variable(context.company.id),
                  Variable(draft.sourceJobAssignmentId!),
                ],
              )
              .get();
          if (active.isNotEmpty) {
            throw const _InspectionException('servicesInspectionAlreadyActive');
          }
          await _validateReferences(context, draft);
          final sourceContext = await _sourceContext(
            context,
            draft.sourceJobAssignmentId!,
          );
          if (sourceContext == null) {
            throw const _InspectionException(
              'servicesInspectionAssignmentInvalid',
            );
          }
          final now = clock.now();
          final numberResult = await numbers.nextNumber(
            companyId: context.company.id,
            type: DocumentSequenceType.serviceInspection,
          );
          final number = switch (numberResult) {
            Success<String>(:final value) => value,
            Failed<String>() => throw const _InspectionException(
              'servicesInspectionSequenceFailed',
            ),
          };
          final inspectionId = _uuid.v4();
          final technicianName = draft.technicianEmployeeId == null
              ? null
              : (await _employeeNames([
                  draft.technicianEmployeeId!,
                ]))[draft.technicianEmployeeId!];
          final rootCauseName = await _masterName(
            'service_root_causes',
            context.company.id,
            draft.rootCauseId,
          );
          final header = ServiceInspection(
            id: inspectionId,
            companyId: context.company.id,
            inspectionNumber: number,
            inspectionDate: _companyDate(context),
            sourceJobAssignmentId: draft.sourceJobAssignmentId!,
            sourceEnquiryId: sourceContext.enquiryId,
            visitDate: _dateOnly(draft.visitDate!),
            visitMinutes: draft.visitMinutes,
            technicianEmployeeId: draft.technicianEmployeeId,
            rootCauseId: draft.rootCauseId,
            chargeResponsibilityId: draft.chargeResponsibilityId,
            status: ServiceInspectionStatus.pending,
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
              sourceContext.assignmentNumber,
              sourceContext.enquiryNumber,
              sourceContext.partySnapshot,
              technicianName,
              rootCauseName,
            ),
          );
          await _persistChildren(context, inspectionId, draft, now);
          await _reconcileAttachments(context, inspectionId, draft, now);
          final created = _withChildren(
            header,
            await _loadChildren(context.company.id, inspectionId),
          );
          await _activity(context, created, 'services.inspection.created');
          await _enqueue(
            context,
            created,
            'SERVICES_INSPECTION_CREATE',
            effectiveRequest,
          );
          await _notifyTechnician(context, created);
          return created;
        }),
      );
    } on _InspectionException catch (e) {
      return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  Future<void> _validateReferences(
    AuthContext context,
    ServiceInspectionDraft draft,
  ) async {
    final companyId = context.company.id;
    if (draft.technicianEmployeeId != null) {
      final source = await _sourceContext(
        context,
        draft.sourceJobAssignmentId!,
      );
      final eligible =
          source?.eligibleTechnicians.any(
            (t) => t.id == draft.technicianEmployeeId,
          ) ??
          false;
      if (!eligible) {
        throw const _InspectionException('servicesInspectionTechnicianInvalid');
      }
    }
    if (draft.rootCauseId != null &&
        !await _masterActive(
          'service_root_causes',
          companyId,
          draft.rootCauseId!,
        )) {
      throw const _InspectionException('servicesInspectionRootCauseInvalid');
    }
    if (draft.chargeResponsibilityId != null &&
        !await _masterActive(
          'service_charge_responsibilities',
          companyId,
          draft.chargeResponsibilityId!,
        )) {
      throw const _InspectionException(
        'servicesInspectionChargeResponsibilityInvalid',
      );
    }
  }

  ServiceInspection _withChildren(
    ServiceInspection header,
    ({
      List<ServiceInspectionChecklistItem> checklist,
      List<ServiceInspectionPoint> points,
      List<ServiceInspectionMaterialRequirement> materials,
    })
    children,
  ) => ServiceInspection(
    id: header.id,
    companyId: header.companyId,
    inspectionNumber: header.inspectionNumber,
    inspectionDate: header.inspectionDate,
    sourceJobAssignmentId: header.sourceJobAssignmentId,
    sourceEnquiryId: header.sourceEnquiryId,
    visitDate: header.visitDate,
    visitMinutes: header.visitMinutes,
    technicianEmployeeId: header.technicianEmployeeId,
    rootCauseId: header.rootCauseId,
    chargeResponsibilityId: header.chargeResponsibilityId,
    status: header.status,
    checklistItems: children.checklist,
    inspectedPoints: children.points,
    materialRequirements: children.materials,
    version: header.version,
    createdAt: header.createdAt,
    updatedAt: header.updatedAt,
    createdByUserId: header.createdByUserId,
    updatedByUserId: header.updatedByUserId,
    requestId: header.requestId,
    syncStatus: header.syncStatus,
  );

  Future<
    ({
      List<ServiceInspectionChecklistItem> checklist,
      List<ServiceInspectionPoint> points,
      List<ServiceInspectionMaterialRequirement> materials,
    })
  >
  _persistChildren(
    AuthContext context,
    String inspectionId,
    ServiceInspectionDraft draft,
    DateTime now,
  ) async {
    var order = 0;
    for (final item in draft.checklistItems) {
      order++;
      await db
          .into(db.serviceInspectionChecklistItems)
          .insert(
            ServiceInspectionChecklistItemsCompanion.insert(
              id: item.id,
              companyId: context.company.id,
              inspectionId: inspectionId,
              sourceJobAssignmentLineId: Value(item.sourceJobAssignmentLineId),
              lineNumber: order,
              workType: item.workType.trim(),
              descriptionForWork: Value(item.descriptionForWork.trim()),
              status: item.status.wire,
              createdAt: now,
              updatedAt: now,
              createdByUserId: context.user.id,
              updatedByUserId: context.user.id,
              syncStatus: 'pending',
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
    order = 0;
    for (final point in draft.inspectedPoints) {
      order++;
      await db
          .into(db.serviceInspectionPoints)
          .insert(
            ServiceInspectionPointsCompanion.insert(
              id: point.id,
              companyId: context.company.id,
              inspectionId: inspectionId,
              lineNumber: order,
              description: point.description.trim(),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
    order = 0;
    for (final material in draft.materialRequirements) {
      order++;
      await db
          .into(db.serviceInspectionMaterialRequirements)
          .insert(
            ServiceInspectionMaterialRequirementsCompanion.insert(
              id: material.id,
              companyId: context.company.id,
              inspectionId: inspectionId,
              lineNumber: order,
              code: material.code.trim(),
              description: material.description.trim(),
              status: material.status.wire,
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
    return _loadChildren(context.company.id, inspectionId);
  }

  Future<void> _reconcileAttachments(
    AuthContext context,
    String inspectionId,
    ServiceInspectionDraft draft,
    DateTime now,
  ) async {
    final companyId = context.company.id;
    final allIds = await db
        .customSelect(
          'SELECT id FROM $_checklistTable WHERE company_id=? AND inspection_id=?',
          variables: [Variable(companyId), Variable(inspectionId)],
        )
        .get();
    final ownerIds = [for (final row in allIds) row.read<String>('id')];
    final existingResult = await attachments.getForOwners(
      companyId: companyId,
      ownerType: _checklistOwnerType,
      ownerIds: ownerIds,
    );
    final existing = existingResult is Success<List<AttachmentRef>>
        ? existingResult.value
        : const <AttachmentRef>[];
    final existingById = {for (final a in existing) a.id: a};
    final desired = <String, ({String ownerId, AttachmentRef ref})>{
      for (final item in draft.checklistItems)
        for (final ref in item.attachments)
          ref.id: (ownerId: item.id, ref: ref),
    };
    for (final entry in desired.entries) {
      if (existingById.containsKey(entry.key)) continue;
      final ref = entry.value.ref;
      final result = await attachments.addLocalAttachment(
        AttachmentDraft(
          companyId: companyId,
          ownerType: _checklistOwnerType,
          ownerId: entry.value.ownerId,
          category: AttachmentCategory.beforeWorkPhoto,
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
        throw _InspectionException(failure.code);
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
  Future<Result<ServiceInspection>> updateInspection(
    AuthContext context,
    String id,
    ServiceInspectionDraft draft, {
    String? requestId,
  }) async {
    final failure = _actionAccess(context, AppPermission.serviceInspectionEdit);
    if (failure != null) return Failed(failure);
    final invalid = _validateDraft(draft);
    if (invalid != null) return Failed(invalid);
    try {
      return Success(
        await db.transaction(() async {
          final row = await _rawRow(context, id);
          if (row == null) {
            throw const _InspectionException('servicesInspectionNotFound');
          }
          final previous = _record(row);
          if (!previous.isPending) {
            throw const _InspectionException('servicesInspectionNotEditable');
          }
          final effectiveRequest = requestId ?? _uuid.v4();
          final existingId = await _requestEntity(
            context.company.id,
            effectiveRequest,
          );
          if (existingId != null) {
            final children = await _loadChildren(context.company.id, id);
            return _record(
              row,
              checklist: children.checklist,
              points: children.points,
              materials: children.materials,
            );
          }
          await _validateReferences(context, draft);
          final now = clock.now();
          final existingChecklist = await db
              .customSelect(
                'SELECT id FROM $_checklistTable WHERE company_id=? AND inspection_id=? AND removed_at IS NULL',
                variables: [Variable(context.company.id), Variable(id)],
              )
              .get();
          final existingIds = {
            for (final r in existingChecklist) r.read<String>('id'),
          };
          final draftIds = {for (final c in draft.checklistItems) c.id};
          await _softRemove(
            _checklistTable,
            context.company.id,
            id,
            existingIds.difference(draftIds).toList(),
            now,
          );
          var order = 0;
          for (final item in draft.checklistItems) {
            order++;
            if (existingIds.contains(item.id)) {
              await (db.update(db.serviceInspectionChecklistItems)..where(
                    (t) =>
                        t.id.equals(item.id) &
                        t.companyId.equals(context.company.id) &
                        t.inspectionId.equals(id),
                  ))
                  .write(
                    ServiceInspectionChecklistItemsCompanion(
                      lineNumber: Value(order),
                      workType: Value(item.workType.trim()),
                      descriptionForWork: Value(item.descriptionForWork.trim()),
                      status: Value(item.status.wire),
                      removedAt: const Value(null),
                      updatedAt: Value(now),
                      updatedByUserId: Value(context.user.id),
                      syncStatus: const Value('pending'),
                    ),
                  );
            } else {
              await _persistChildren(
                context,
                id,
                ServiceInspectionDraft(checklistItems: [item]),
                now,
              );
            }
          }
          await _reconcileSimpleChildren(context, id, draft, now);
          await _reconcileAttachments(context, id, draft, now);

          final technicianChanged =
              draft.technicianEmployeeId != previous.technicianEmployeeId;
          final visitChanged =
              _dateOnly(draft.visitDate!) != previous.visitDate ||
              draft.visitMinutes != previous.visitMinutes;
          final rootCauseChanged = draft.rootCauseId != previous.rootCauseId;
          final technicianName = draft.technicianEmployeeId == null
              ? null
              : (await _employeeNames([
                  draft.technicianEmployeeId!,
                ]))[draft.technicianEmployeeId!];
          final rootCauseName = await _masterName(
            'service_root_causes',
            context.company.id,
            draft.rootCauseId,
          );
          final sourceContext = await _sourceContext(
            context,
            previous.sourceJobAssignmentId,
          );
          await (db.update(db.serviceInspections)..where(
                (t) => t.id.equals(id) & t.companyId.equals(context.company.id),
              ))
              .write(
                ServiceInspectionsCompanion(
                  visitDate: Value(_dateOnly(draft.visitDate!)),
                  visitMinutes: Value(draft.visitMinutes),
                  technicianEmployeeId: Value(draft.technicianEmployeeId),
                  rootCauseId: Value(draft.rootCauseId),
                  chargeResponsibilityId: Value(draft.chargeResponsibilityId),
                  searchText: Value(
                    _searchText(
                      previous.inspectionNumber,
                      sourceContext?.assignmentNumber ?? '',
                      sourceContext?.enquiryNumber ?? '',
                      sourceContext?.partySnapshot ??
                          const ServiceEnquiryPartySnapshot(),
                      technicianName,
                      rootCauseName,
                    ),
                  ),
                  version: Value(previous.version + 1),
                  updatedAt: Value(now),
                  updatedByUserId: Value(context.user.id),
                  syncStatus: const Value('pending'),
                ),
              );
          final children = await _loadChildren(context.company.id, id);
          final updated = _withChildren(
            ServiceInspection(
              id: previous.id,
              companyId: previous.companyId,
              inspectionNumber: previous.inspectionNumber,
              inspectionDate: previous.inspectionDate,
              sourceJobAssignmentId: previous.sourceJobAssignmentId,
              sourceEnquiryId: previous.sourceEnquiryId,
              visitDate: _dateOnly(draft.visitDate!),
              visitMinutes: draft.visitMinutes,
              technicianEmployeeId: draft.technicianEmployeeId,
              rootCauseId: draft.rootCauseId,
              chargeResponsibilityId: draft.chargeResponsibilityId,
              status: ServiceInspectionStatus.pending,
              version: previous.version + 1,
              createdAt: previous.createdAt,
              updatedAt: now,
              createdByUserId: previous.createdByUserId,
              updatedByUserId: context.user.id,
              requestId: previous.requestId,
              syncStatus: RecordSyncStatus.pending,
            ),
            children,
          );
          await _activity(context, updated, 'services.inspection.updated');
          if (technicianChanged) {
            await _activity(
              context,
              updated,
              'services.inspection.technicianChanged',
            );
          }
          if (visitChanged) {
            await _activity(
              context,
              updated,
              'services.inspection.visitChanged',
            );
          }
          if (rootCauseChanged) {
            await _activity(
              context,
              updated,
              'services.inspection.rootCauseChanged',
            );
          }
          await _enqueue(
            context,
            updated,
            'SERVICES_INSPECTION_UPDATE',
            effectiveRequest,
          );
          await _notifyTechnician(context, updated);
          return updated;
        }),
      );
    } on _InspectionException catch (e) {
      return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  Future<void> _softRemove(
    String table,
    String companyId,
    String inspectionId,
    List<String> ids,
    DateTime now,
  ) async {
    if (ids.isEmpty) return;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.customUpdate(
      'UPDATE $table SET removed_at=?, updated_at=? WHERE company_id=? AND inspection_id=? AND id IN ($placeholders)',
      variables: [
        Variable(now),
        Variable(now),
        Variable(companyId),
        Variable(inspectionId),
        ...ids.map((id) => Variable(id)),
      ],
    );
  }

  Future<void> _reconcileSimpleChildren(
    AuthContext context,
    String id,
    ServiceInspectionDraft draft,
    DateTime now,
  ) async {
    // Points.
    final pointRows = await db
        .customSelect(
          'SELECT id FROM $_pointTable WHERE company_id=? AND inspection_id=? AND removed_at IS NULL',
          variables: [Variable(context.company.id), Variable(id)],
        )
        .get();
    final pointIds = {for (final r in pointRows) r.read<String>('id')};
    final pointDraftIds = {for (final p in draft.inspectedPoints) p.id};
    await _softRemove(
      _pointTable,
      context.company.id,
      id,
      pointIds.difference(pointDraftIds).toList(),
      now,
    );
    var order = 0;
    for (final point in draft.inspectedPoints) {
      order++;
      if (pointIds.contains(point.id)) {
        await db.customUpdate(
          'UPDATE $_pointTable SET line_number=?, description=?, updated_at=? WHERE company_id=? AND id=?',
          variables: [
            Variable(order),
            Variable(point.description.trim()),
            Variable(now),
            Variable(context.company.id),
            Variable(point.id),
          ],
        );
      } else {
        await db
            .into(db.serviceInspectionPoints)
            .insert(
              ServiceInspectionPointsCompanion.insert(
                id: point.id,
                companyId: context.company.id,
                inspectionId: id,
                lineNumber: order,
                description: point.description.trim(),
                createdAt: now,
                updatedAt: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    }
    // Materials.
    final materialRows = await db
        .customSelect(
          'SELECT id FROM $_materialTable WHERE company_id=? AND inspection_id=? AND removed_at IS NULL',
          variables: [Variable(context.company.id), Variable(id)],
        )
        .get();
    final materialIds = {for (final r in materialRows) r.read<String>('id')};
    final materialDraftIds = {for (final m in draft.materialRequirements) m.id};
    await _softRemove(
      _materialTable,
      context.company.id,
      id,
      materialIds.difference(materialDraftIds).toList(),
      now,
    );
    order = 0;
    for (final material in draft.materialRequirements) {
      order++;
      if (materialIds.contains(material.id)) {
        await db.customUpdate(
          'UPDATE $_materialTable SET line_number=?, code=?, description=?, updated_at=? WHERE company_id=? AND id=?',
          variables: [
            Variable(order),
            Variable(material.code.trim()),
            Variable(material.description.trim()),
            Variable(now),
            Variable(context.company.id),
            Variable(material.id),
          ],
        );
      } else {
        await db
            .into(db.serviceInspectionMaterialRequirements)
            .insert(
              ServiceInspectionMaterialRequirementsCompanion.insert(
                id: material.id,
                companyId: context.company.id,
                inspectionId: id,
                lineNumber: order,
                code: material.code.trim(),
                description: material.description.trim(),
                status: material.status.wire,
                createdAt: now,
                updatedAt: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    }
  }

  @override
  Future<Result<ServiceInspection>> completeInspection(
    AuthContext context,
    String id, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceInspectionComplete,
    );
    if (failure != null) return Failed(failure);
    try {
      return Success(
        await db.transaction(() async {
          final row = await _rawRow(context, id);
          if (row == null) {
            throw const _InspectionException('servicesInspectionNotFound');
          }
          final previous = _record(row);
          if (!previous.isPending) {
            throw const _InspectionException(
              'servicesInspectionNotCompletable',
            );
          }
          final children = await _loadChildren(context.company.id, id);
          if (previous.technicianEmployeeId == null) {
            throw const _InspectionException(
              'servicesInspectionTechnicianRequired',
            );
          }
          if (previous.visitMinutes == null) {
            throw const _InspectionException(
              'servicesInspectionVisitTimeRequired',
            );
          }
          if (previous.rootCauseId == null) {
            throw const _InspectionException(
              'servicesInspectionRootCauseRequired',
            );
          }
          if (previous.chargeResponsibilityId == null) {
            throw const _InspectionException(
              'servicesInspectionChargeResponsibilityRequired',
            );
          }
          if (children.checklist.isEmpty && children.points.isEmpty) {
            throw const _InspectionException(
              'servicesInspectionAssessmentRequired',
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
              checklist: children.checklist,
              points: children.points,
              materials: children.materials,
            );
          }
          final now = clock.now();
          await db.customUpdate(
            "UPDATE $_table SET status='completed', version=version+1, updated_at=?, updated_by_user_id=?, sync_status=? WHERE company_id=? AND id=?",
            variables: [
              Variable(now),
              Variable(context.user.id),
              Variable('pending'),
              Variable(context.company.id),
              Variable(id),
            ],
          );
          final completed = _withChildren(
            ServiceInspection(
              id: previous.id,
              companyId: previous.companyId,
              inspectionNumber: previous.inspectionNumber,
              inspectionDate: previous.inspectionDate,
              sourceJobAssignmentId: previous.sourceJobAssignmentId,
              sourceEnquiryId: previous.sourceEnquiryId,
              visitDate: previous.visitDate,
              visitMinutes: previous.visitMinutes,
              technicianEmployeeId: previous.technicianEmployeeId,
              rootCauseId: previous.rootCauseId,
              chargeResponsibilityId: previous.chargeResponsibilityId,
              status: ServiceInspectionStatus.completed,
              version: previous.version + 1,
              createdAt: previous.createdAt,
              updatedAt: now,
              createdByUserId: previous.createdByUserId,
              updatedByUserId: context.user.id,
              requestId: previous.requestId,
              syncStatus: RecordSyncStatus.pending,
            ),
            children,
          );
          await _activity(context, completed, 'services.inspection.completed');
          await _enqueue(
            context,
            completed,
            'SERVICES_INSPECTION_COMPLETE',
            effectiveRequest,
          );
          return completed;
        }),
      );
    } on _InspectionException catch (e) {
      return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<void>> cancelInspection(
    AuthContext context,
    String id, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceInspectionCancel,
    );
    if (failure != null) return Failed(failure);
    try {
      await db.transaction(() async {
        final row = await _rawRow(context, id);
        if (row == null) {
          throw const _InspectionException('servicesInspectionNotFound');
        }
        final previous = _record(row);
        if (previous.isCancelled) {
          throw const _InspectionException(
            'servicesInspectionAlreadyCancelled',
          );
        }
        if (previous.isCompleted) {
          throw const _InspectionException('servicesInspectionNotCancellable');
        }
        final effectiveRequest = requestId ?? _uuid.v4();
        final existingId = await _requestEntity(
          context.company.id,
          effectiveRequest,
        );
        if (existingId != null) return;
        final now = clock.now();
        await db.customUpdate(
          "UPDATE $_table SET status='cancelled', version=version+1, updated_at=?, updated_by_user_id=?, sync_status=? WHERE company_id=? AND id=?",
          variables: [
            Variable(now),
            Variable(context.user.id),
            Variable('pending'),
            Variable(context.company.id),
            Variable(id),
          ],
        );
        final cancelled = ServiceInspection(
          id: previous.id,
          companyId: previous.companyId,
          inspectionNumber: previous.inspectionNumber,
          inspectionDate: previous.inspectionDate,
          sourceJobAssignmentId: previous.sourceJobAssignmentId,
          sourceEnquiryId: previous.sourceEnquiryId,
          visitDate: previous.visitDate,
          visitMinutes: previous.visitMinutes,
          technicianEmployeeId: previous.technicianEmployeeId,
          rootCauseId: previous.rootCauseId,
          chargeResponsibilityId: previous.chargeResponsibilityId,
          status: ServiceInspectionStatus.cancelled,
          version: previous.version + 1,
          createdAt: previous.createdAt,
          updatedAt: now,
          createdByUserId: previous.createdByUserId,
          updatedByUserId: context.user.id,
          requestId: previous.requestId,
          syncStatus: RecordSyncStatus.pending,
        );
        await _activity(context, cancelled, 'services.inspection.cancelled');
        await _enqueue(
          context,
          cancelled,
          'SERVICES_INSPECTION_CANCEL',
          effectiveRequest,
        );
      });
      return const Success(null);
    } on _InspectionException catch (e) {
      return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  // ---------------------------------------------------------- persistence

  Future<void> _insertHeader(
    ServiceInspection i, {
    required String searchText,
  }) => db
      .into(db.serviceInspections)
      .insert(
        ServiceInspectionsCompanion.insert(
          id: i.id,
          companyId: i.companyId,
          inspectionNumber: i.inspectionNumber,
          inspectionDate: i.inspectionDate,
          sourceJobAssignmentId: i.sourceJobAssignmentId,
          sourceEnquiryId: i.sourceEnquiryId,
          visitDate: i.visitDate,
          visitMinutes: Value(i.visitMinutes),
          technicianEmployeeId: Value(i.technicianEmployeeId),
          rootCauseId: Value(i.rootCauseId),
          chargeResponsibilityId: Value(i.chargeResponsibilityId),
          status: i.status.wire,
          version: Value(i.version),
          searchText: Value(searchText),
          createdAt: i.createdAt,
          updatedAt: i.updatedAt,
          createdByUserId: i.createdByUserId,
          updatedByUserId: i.updatedByUserId,
          requestId: Value(i.requestId),
          syncStatus: i.syncStatus.name,
        ),
      );

  Future<void> _activity(
    AuthContext context,
    ServiceInspection i,
    String eventType,
  ) => activity.append(
    BusinessActivityEvent(
      id: _uuid.v4(),
      companyId: context.company.id,
      moduleKey: 'services',
      entityType: 'serviceInspection',
      entityId: i.id,
      eventType: eventType,
      occurredAt: clock.now(),
      actorUserId: context.user.id,
      actorEmployeeId: context.employeeReference?.id,
      syncStatus: 'pending',
      metadata: {
        'inspectionNumber': i.inspectionNumber,
        'sourceJobAssignmentId': i.sourceJobAssignmentId,
        'status': i.status.wire,
        'checklistCount': i.checklistItems.length,
        'pointCount': i.inspectedPoints.length,
        'materialCount': i.materialRequirements.length,
      },
    ),
  );

  Map<String, Object?> _checklistPayload(ServiceInspectionChecklistItem item) =>
      {
        'id': item.id,
        'sourceJobAssignmentLineId': item.sourceJobAssignmentLineId,
        'lineNumber': item.lineNumber,
        'workType': item.workType,
        'descriptionForWork': item.descriptionForWork,
        'status': item.status.wire,
        'attachments': [
          for (final a in item.attachments)
            {
              'id': a.id,
              'fileName': a.fileName,
              'mimeType': a.mimeType,
              'sizeBytes': a.sizeBytes,
              'category': a.category.value,
            },
        ],
      };

  Future<void> _enqueue(
    AuthContext context,
    ServiceInspection i,
    String operation,
    String requestId,
  ) => db
      .into(db.syncOutbox)
      .insert(
        SyncOutboxCompanion.insert(
          id: _uuid.v4(),
          moduleId: 'services',
          entityId: i.id,
          entityType: const Value('serviceInspection'),
          operation: operation,
          payload: jsonEncode({
            'id': i.id,
            'inspectionNumber': i.inspectionNumber,
            'inspectionDate': i.inspectionDate.toIso8601String(),
            'sourceJobAssignmentId': i.sourceJobAssignmentId,
            'sourceEnquiryId': i.sourceEnquiryId,
            'visitDate': i.visitDate.toIso8601String(),
            'visitMinutes': i.visitMinutes,
            'technicianEmployeeId': i.technicianEmployeeId,
            'rootCauseId': i.rootCauseId,
            'chargeResponsibilityId': i.chargeResponsibilityId,
            'status': i.status.wire,
            'version': i.version,
            'checklistItems': [
              for (final item in i.checklistItems) _checklistPayload(item),
            ],
            'inspectedPoints': [
              for (final p in i.inspectedPoints)
                {
                  'id': p.id,
                  'lineNumber': p.lineNumber,
                  'description': p.description,
                },
            ],
            'materialRequirements': [
              for (final m in i.materialRequirements)
                {
                  'id': m.id,
                  'lineNumber': m.lineNumber,
                  'code': m.code,
                  'description': m.description,
                  'status': m.status.wire,
                },
            ],
          }),
          createdAt: i.updatedAt,
          companyId: Value(context.company.id),
          requestId: Value(requestId),
        ),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> _notifyTechnician(
    AuthContext context,
    ServiceInspection inspection,
  ) async {
    final repository = _notifications;
    final technicianId = inspection.technicianEmployeeId;
    if (repository == null || technicianId == null) return;
    final refs = await workforce.getEmployees([technicianId]);
    if (refs.isEmpty || refs.first.linkedUserId == null) return;
    await repository.createLocal(
      AppNotification(
        id: _uuid.v4(),
        companyId: context.company.id,
        userId: refs.first.linkedUserId!,
        type: AppNotificationType.serviceInspectionAssigned,
        priority: AppNotificationPriority.normal,
        dedupeKey: 'inspection:${inspection.id}:${refs.first.linkedUserId}',
        route: ServicesRoutes.inspection(inspection.id),
        payload: {'inspectionId': inspection.id},
        createdAt: clock.now().toUtc(),
      ),
    );
  }
}

class _InspectionException implements Exception {
  const _InspectionException(this.code);
  final String code;
}
