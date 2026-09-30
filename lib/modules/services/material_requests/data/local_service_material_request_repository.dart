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
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request_repository.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request_scope.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';
import 'package:modular_erp/shared/transactions/domain/document_number.dart';
import 'package:modular_erp/shared/transactions/domain/document_number_service.dart';

/// Local (Drift) implementation of the Service Material Request transaction.
class LocalServiceMaterialRequestRepository
    implements ServiceMaterialRequestRepository {
  LocalServiceMaterialRequestRepository(
    this.db,
    this.clock,
    this.numbers,
    this.activity,
    this.workforce,
    this.time, {
    ServiceMaterialRequestScopeResolver scopeResolver =
        const ServiceMaterialRequestScopeResolver(),
    Uuid? uuid,
  }) : _scopeResolver = scopeResolver,
       _uuid = uuid ?? const Uuid();

  final AppDatabase db;
  final AppClock clock;
  final DocumentNumberService numbers;
  final ActivityRepository activity;
  final WorkforceDirectory workforce;
  final CompanyTimeService time;
  final ServiceMaterialRequestScopeResolver _scopeResolver;
  final Uuid _uuid;

  static const _table = 'service_material_requests';
  static const _lineTable = 'service_material_request_lines';
  static const _purposeTable = 'service_material_request_purposes';
  static const _requirementTable = 'service_inspection_material_requirements';

  Failure? _denied() => const Failure(code: 'servicesMaterialRequestDenied');

  bool _enabled(AuthContext c) =>
      c.user.status == AccountStatus.active &&
      c.user.companyId == c.company.id &&
      c.company.enabledModules.contains('services');

  bool _can(AuthContext c, AppPermission p) => c.user.permissions.contains(p);

  ServiceMaterialRequestScope _scope(AuthContext c) =>
      _scopeResolver.resolve(c);

  Failure? _viewAccess(AuthContext c) =>
      _enabled(c) && _scope(c) != ServiceMaterialRequestScope.none
      ? null
      : _denied();

  Failure? _actionAccess(AuthContext c, AppPermission p) =>
      _enabled(c) && _can(c, p) ? null : _denied();

  Failure? _referenceAccess(AuthContext c) =>
      _enabled(c) && _can(c, AppPermission.serviceMaterialRequestCreate)
      ? null
      : _denied();

  static const _listColumns =
      'r.*, i.inspection_number, a.assignment_number, e.enquiry_number, '
      'e.party_snapshot, p.name AS purpose_name, '
      '(SELECT COUNT(*) FROM $_lineTable ml WHERE ml.company_id=r.company_id AND ml.material_request_id=r.id) AS item_count, '
      '(SELECT COALESCE(SUM(ml.quantity),0) FROM $_lineTable ml WHERE ml.company_id=r.company_id AND ml.material_request_id=r.id) AS total_qty';

  static const _listJoins =
      'LEFT JOIN service_inspections i ON i.id=r.source_inspection_id AND i.company_id=r.company_id '
      'LEFT JOIN service_job_assignments a ON a.id=r.source_job_assignment_id AND a.company_id=r.company_id '
      'LEFT JOIN service_enquiries e ON e.id=r.source_enquiry_id AND e.company_id=r.company_id '
      'LEFT JOIN $_purposeTable p ON p.id=r.purpose_id AND p.company_id=r.company_id';

  Set<ResultSetImplementation> get _reads => {
    db.serviceMaterialRequests,
    db.serviceMaterialRequestLines,
    db.serviceMaterialRequestPurposes,
    db.serviceInspections,
    db.serviceJobAssignments,
    db.serviceEnquiries,
    db.serviceInspectionMaterialRequirements,
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
      case ServiceMaterialRequestScope.all:
        return (sql: 'r.company_id=?', variables: [company]);
      case ServiceMaterialRequestScope.team:
      case ServiceMaterialRequestScope.assigned:
        final employeeId = context.employeeReference?.id;
        if (employeeId == null) return (sql: '0', variables: const []);
        const teamExists =
            "EXISTS (SELECT 1 FROM service_job_assignment_lines l WHERE l.company_id=r.company_id AND l.assignment_id IN (SELECT i2.source_job_assignment_id FROM service_inspections i2 WHERE i2.company_id=r.company_id AND i2.id=r.source_inspection_id) AND l.removed_at IS NULL AND l.assigned_team_id IN (SELECT tm.team_id FROM service_team_members tm WHERE tm.company_id=r.company_id AND tm.employee_id=? AND tm.status='active'))";
        if (_scope(context) == ServiceMaterialRequestScope.team) {
          return (
            sql: 'r.company_id=? AND $teamExists',
            variables: [company, Variable(employeeId)],
          );
        }
        const employeeExists =
            "EXISTS (SELECT 1 FROM service_job_assignment_lines l WHERE l.company_id=r.company_id AND l.assignment_id IN (SELECT i2.source_job_assignment_id FROM service_inspections i2 WHERE i2.company_id=r.company_id AND i2.id=r.source_inspection_id) AND l.removed_at IS NULL AND l.assigned_employee_id=?)";
        const technicianExists =
            'EXISTS (SELECT 1 FROM service_inspections i2 WHERE i2.company_id=r.company_id AND i2.id=r.source_inspection_id AND i2.technician_employee_id=?)';
        return (
          sql:
              'r.company_id=? AND ($technicianExists OR $employeeExists OR $teamExists)',
          variables: [
            company,
            Variable(employeeId),
            Variable(employeeId),
            Variable(employeeId),
          ],
        );
      case ServiceMaterialRequestScope.none:
        return (sql: '0', variables: const []);
    }
  }

  ({String sql, List<Variable> variables}) _where(
    AuthContext context, {
    String query = '',
    ServiceMaterialRequestStatus? status,
    String? purposeId,
    String? inspectionId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    final scope = _scopeClause(context);
    final parts = <String>[scope.sql];
    final variables = <Variable>[...scope.variables];
    if (status != null) {
      parts.add('r.status=?');
      variables.add(Variable(status.wire));
    }
    if (purposeId != null) {
      parts.add('r.purpose_id=?');
      variables.add(Variable(purposeId));
    }
    if (inspectionId != null) {
      parts.add('r.source_inspection_id=?');
      variables.add(Variable(inspectionId));
    }
    if (dateFrom != null) {
      parts.add('r.request_date>=?');
      variables.add(Variable(dateFrom));
    }
    if (dateTo != null) {
      parts.add('r.request_date<=?');
      variables.add(Variable(dateTo));
    }
    if (query.trim().isNotEmpty) {
      final escaped = query
          .trim()
          .toLowerCase()
          .replaceAll('\\', '\\\\')
          .replaceAll('%', '\\%')
          .replaceAll('_', '\\_');
      parts.add("r.search_text LIKE ? ESCAPE '\\'");
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
          'SELECT COUNT(*) AS c FROM $_table r WHERE ${where.sql}',
          variables: where.variables,
        )
        .getSingle();
    return row.read<int>('c');
  }

  ServiceMaterialRequest _record(
    QueryRow row, {
    List<ServiceMaterialRequestLine> lines = const [],
  }) => ServiceMaterialRequest(
    id: row.read<String>('id'),
    companyId: row.read<String>('company_id'),
    requestNumber: row.read<String>('request_number'),
    requestDate: row.read<DateTime>('request_date').toUtc(),
    sourceInspectionId: row.read<String>('source_inspection_id'),
    sourceJobAssignmentId: row.read<String>('source_job_assignment_id'),
    sourceEnquiryId: row.read<String>('source_enquiry_id'),
    jobOrderReference: row.readNullable<String>('job_order_reference'),
    purposeId: row.readNullable<String>('purpose_id'),
    acknowledgement: row.readNullable<String>('acknowledgement'),
    receivedBy: row.readNullable<String>('received_by'),
    remarks: row.readNullable<String>('remarks'),
    status: ServiceMaterialRequestStatusX.fromWire(row.read<String>('status')),
    version: row.read<int>('version'),
    createdAt: row.read<DateTime>('created_at').toUtc(),
    updatedAt: row.read<DateTime>('updated_at').toUtc(),
    createdByUserId: row.read<String>('created_by_user_id'),
    updatedByUserId: row.read<String>('updated_by_user_id'),
    requestId: row.readNullable<String>('request_id'),
    syncStatus: RecordSyncStatus.values.byName(row.read<String>('sync_status')),
    lines: lines,
  );

  Future<List<ServiceMaterialRequestLine>> _loadLines(
    String companyId,
    String requestId,
  ) async {
    final rows = await db
        .customSelect(
          'SELECT * FROM $_lineTable WHERE company_id=? AND material_request_id=? ORDER BY line_number, id',
          variables: [Variable(companyId), Variable(requestId)],
        )
        .get();
    return [
      for (final row in rows)
        ServiceMaterialRequestLine(
          id: row.read<String>('id'),
          companyId: row.read<String>('company_id'),
          materialRequestId: row.read<String>('material_request_id'),
          sourceInspectionMaterialRequirementId: row.readNullable<String>(
            'source_inspection_material_requirement_id',
          ),
          lineNumber: row.read<int>('line_number'),
          code: row.read<String>('code'),
          description: row.read<String>('description'),
          batchNumber: row.readNullable<String>('batch_number'),
          quantity: row.read<double>('quantity'),
          remark: row.readNullable<String>('remark'),
          createdAt: row.read<DateTime>('created_at').toUtc(),
          updatedAt: row.read<DateTime>('updated_at').toUtc(),
        ),
    ];
  }

  ServiceMaterialRequestListItem _listItem(QueryRow row) {
    final snapshot = _snapshot(row.readNullable<String>('party_snapshot'));
    final site = [
      snapshot.buildingName,
      snapshot.unitNumber,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' / ');
    return ServiceMaterialRequestListItem(
      id: row.read<String>('id'),
      requestNumber: row.read<String>('request_number'),
      requestDate: row.read<DateTime>('request_date').toUtc(),
      createdAt: row.read<DateTime>('created_at').toUtc(),
      status: ServiceMaterialRequestStatusX.fromWire(
        row.read<String>('status'),
      ),
      inspectionNumber: row.readNullable<String>('inspection_number') ?? '',
      assignmentNumber: row.readNullable<String>('assignment_number') ?? '',
      enquiryNumber: row.readNullable<String>('enquiry_number') ?? '',
      customerName: snapshot.customerName ?? '',
      siteSummary: site.isEmpty ? (snapshot.siteName ?? '') : site,
      purposeName: row.readNullable<String>('purpose_name'),
      preparedByUserId: row.read<String>('created_by_user_id'),
      itemCount: row.read<int>('item_count'),
      totalQuantity: row.read<double>('total_qty'),
    );
  }

  Stream<Result<ServiceMaterialRequestPage>> _watchPage(
    AuthContext context, {
    required ({String sql, List<Variable> variables}) where,
    required int page,
    required int limit,
  }) {
    final sql =
        'SELECT $_listColumns FROM $_table r $_listJoins '
        'WHERE ${where.sql} '
        'ORDER BY r.request_date DESC, r.created_at DESC, r.id DESC LIMIT ? OFFSET ?';
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
        .asyncMap<Result<ServiceMaterialRequestPage>>((rows) async {
          final scope = _scopeClause(context);
          final total = await _count(context, (
            sql: scope.sql,
            variables: scope.variables,
          ));
          final filtered = await _count(context, where);
          return Success(
            ServiceMaterialRequestPage(
              [for (final row in rows) _listItem(row)],
              total,
              filtered,
            ),
          );
        })
        .transform(
          StreamTransformer<
            Result<ServiceMaterialRequestPage>,
            Result<ServiceMaterialRequestPage>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceMaterialRequestPage>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  @override
  Stream<Result<ServiceMaterialRequestPage>> watchRequests(
    AuthContext context, {
    String query = '',
    ServiceMaterialRequestStatus? status,
    String? purposeId,
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
        purposeId: purposeId,
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
          'SELECT $_listColumns FROM $_table r $_listJoins '
          'WHERE r.id=? AND ${scope.sql}',
          variables: [Variable(id), ...scope.variables],
        )
        .getSingleOrNull();
  }

  /// Company-scoped read used only by the create path to return the record the
  /// caller just inserted (or an idempotent replay of it). Creation must never
  /// require or widen a View scope.
  Future<QueryRow?> _rawRowForCreate(AuthContext context, String id) => db
      .customSelect(
        'SELECT $_listColumns FROM $_table r $_listJoins '
        'WHERE r.id=? AND r.company_id=?',
        variables: [Variable(id), Variable(context.company.id)],
      )
      .getSingleOrNull();

  Future<ServiceMaterialRequestView> _view(
    AuthContext context,
    QueryRow row,
  ) async {
    final id = row.read<String>('id');
    final lines = await _loadLines(context.company.id, id);
    final source = await _sourceContext(
      context,
      row.read<String>('source_inspection_id'),
      viewOnly: true,
    );
    final snapshot =
        source?.partySnapshot ??
        _snapshot(row.readNullable<String>('party_snapshot'));
    return ServiceMaterialRequestView(
      request: _record(row, lines: lines),
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
      purposeName: row.readNullable<String>('purpose_name'),
      technicianName: source?.technicianName,
    );
  }

  @override
  Stream<Result<ServiceMaterialRequestView?>> watchRequest(
    AuthContext context,
    String id,
  ) {
    final failure = _viewAccess(context);
    if (failure != null) return Stream.value(Failed(failure));
    final scope = _scopeClause(context);
    return db
        .customSelect(
          'SELECT $_listColumns FROM $_table r $_listJoins '
          'WHERE r.id=? AND ${scope.sql}',
          variables: [Variable(id), ...scope.variables],
          readsFrom: _reads,
        )
        .watchSingleOrNull()
        .asyncMap<Result<ServiceMaterialRequestView?>>((row) async {
          if (row == null) {
            return const Success<ServiceMaterialRequestView?>(null);
          }
          return Success<ServiceMaterialRequestView?>(
            await _view(context, row),
          );
        })
        .transform(
          StreamTransformer<
            Result<ServiceMaterialRequestView?>,
            Result<ServiceMaterialRequestView?>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceMaterialRequestView?>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  @override
  Future<Result<ServiceMaterialRequestView?>> getRequest(
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
        'SELECT id, inspection_number, status, source_job_assignment_id, source_enquiry_id, technician_employee_id '
        'FROM service_inspections WHERE company_id=? AND id=?',
        variables: [Variable(companyId), Variable(id)],
      )
      .getSingleOrNull();

  Future<ServiceMaterialRequestSourceContext?> _sourceContext(
    AuthContext context,
    String inspectionId, {
    bool viewOnly = false,
  }) async {
    final companyId = context.company.id;
    final inspection = await _inspectionRow(companyId, inspectionId);
    if (inspection == null) return null;
    if (viewOnly &&
        ServiceInspectionStatusX.fromWire(
          inspection.read<String>('status'),
        ).isCancelled) {
      return null;
    }
    final assignmentId = inspection.read<String>('source_job_assignment_id');
    final enquiryId = inspection.read<String>('source_enquiry_id');
    final assignment = await db
        .customSelect(
          'SELECT assignment_number FROM service_job_assignments WHERE company_id=? AND id=?',
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
    final requirementRows = await db
        .customSelect(
          "SELECT * FROM $_requirementTable WHERE company_id=? AND inspection_id=? AND removed_at IS NULL AND status='waiting' ORDER BY line_number, id",
          variables: [Variable(companyId), Variable(inspectionId)],
        )
        .get();
    final technicianId = inspection.readNullable<String>(
      'technician_employee_id',
    );
    final technicianName = technicianId == null
        ? null
        : (await _employeeNames([technicianId]))[technicianId];
    return ServiceMaterialRequestSourceContext(
      inspectionId: inspectionId,
      inspectionNumber: inspection.read<String>('inspection_number'),
      inspectionStatus: ServiceInspectionStatusX.fromWire(
        inspection.read<String>('status'),
      ),
      jobAssignmentId: assignmentId,
      assignmentNumber: assignment?.read<String>('assignment_number') ?? '',
      enquiryId: enquiryId,
      enquiryNumber: enquiry.read<String>('enquiry_number'),
      customerName:
          _snapshot(
            enquiry.readNullable<String>('party_snapshot'),
          ).customerName ??
          '',
      customerMobile: _snapshot(
        enquiry.readNullable<String>('party_snapshot'),
      ).customerMobile,
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
      partySnapshot: _snapshot(enquiry.readNullable<String>('party_snapshot')),
      technicianName: technicianName,
      waitingRequirements: [
        for (final row in requirementRows)
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
      ],
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

  Future<Map<String, String>> _employeeNames(Iterable<String> ids) async {
    final wanted = {
      for (final id in ids)
        if (id.isNotEmpty) id,
    };
    if (wanted.isEmpty) return const {};
    final refs = await workforce.getEmployees(wanted);
    return {for (final ref in refs) ref.id: ref.name};
  }

  @override
  Future<Result<ServiceMaterialRequestSourceContext?>> getSourceContext(
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
  Future<Result<List<ServiceEligibleInspectionRef>>> searchEligibleInspections(
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
            "SELECT i.id, i.inspection_number, i.visit_date, a.assignment_number, "
            "e.enquiry_number, e.party_snapshot, "
            "(SELECT COUNT(*) FROM $_requirementTable mr WHERE mr.company_id=i.company_id AND mr.inspection_id=i.id AND mr.removed_at IS NULL AND mr.status='waiting') AS waiting_count "
            "FROM service_inspections i "
            "LEFT JOIN service_job_assignments a ON a.id=i.source_job_assignment_id AND a.company_id=i.company_id "
            "LEFT JOIN service_enquiries e ON e.id=i.source_enquiry_id AND e.company_id=i.company_id "
            "WHERE i.company_id=? AND i.status='completed' "
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
      return Success([for (final row in rows) _eligibleRef(row)]);
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  ServiceEligibleInspectionRef _eligibleRef(QueryRow row) {
    final snapshot = _snapshot(row.readNullable<String>('party_snapshot'));
    final site = [
      snapshot.buildingName,
      snapshot.unitNumber,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' / ');
    return ServiceEligibleInspectionRef(
      id: row.read<String>('id'),
      inspectionNumber: row.read<String>('inspection_number'),
      assignmentNumber: row.readNullable<String>('assignment_number') ?? '',
      enquiryNumber: row.readNullable<String>('enquiry_number') ?? '',
      customerName: snapshot.customerName ?? '',
      siteSummary: site.isEmpty ? (snapshot.siteName ?? '') : site,
      visitDate: row.read<DateTime>('visit_date').toUtc(),
      waitingRequirementCount: row.read<int>('waiting_count'),
    );
  }

  ServiceMaterialRequestRef _ref(QueryRow row) => ServiceMaterialRequestRef(
    id: row.read<String>('id'),
    requestNumber: row.read<String>('request_number'),
    status: ServiceMaterialRequestStatusX.fromWire(row.read<String>('status')),
    requestDate: row.read<DateTime>('request_date').toUtc(),
    itemCount: row.read<int>('item_count'),
    totalQuantity: row.read<double>('total_qty'),
  );

  @override
  Future<Result<List<ServiceMaterialRequestRef>>> getRequestsForInspection(
    AuthContext context,
    String inspectionId,
  ) async {
    final failure = _viewAccess(context);
    if (failure != null) return Failed(failure);
    try {
      return Success(await _refsForInspection(context, inspectionId));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  Future<List<ServiceMaterialRequestRef>> _refsForInspection(
    AuthContext context,
    String inspectionId,
  ) async {
    final scope = _scopeClause(context);
    final rows = await db
        .customSelect(
          'SELECT $_listColumns FROM $_table r $_listJoins '
          'WHERE r.company_id=? AND r.source_inspection_id=? AND ${scope.sql} '
          'ORDER BY r.request_date DESC, r.created_at DESC, r.id DESC',
          variables: [
            Variable(context.company.id),
            Variable(inspectionId),
            ...scope.variables,
          ],
        )
        .get();
    return [for (final row in rows) _ref(row)];
  }

  @override
  Stream<Result<List<ServiceMaterialRequestRef>>> watchRequestsForInspection(
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
        .asyncMap<Result<List<ServiceMaterialRequestRef>>>(
          (_) async => Success(await _refsForInspection(context, inspectionId)),
        )
        .transform(
          StreamTransformer<
            Result<List<ServiceMaterialRequestRef>>,
            Result<List<ServiceMaterialRequestRef>>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<List<ServiceMaterialRequestRef>>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  // ------------------------------------------------------------- summary

  @override
  Future<Result<ServiceMaterialRequestSummary>> summary(
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
            "SUM(CASE WHEN r.status='open' THEN 1 ELSE 0 END) AS open_count, "
            "SUM(CASE WHEN r.request_date=? THEN 1 ELSE 0 END) AS today_count, "
            '(SELECT COUNT(*) FROM $_lineTable ml WHERE ml.company_id=r.company_id AND ml.material_request_id=r.id) AS line_count '
            'FROM $_table r WHERE ${scope.sql}',
            variables: [Variable(today), ...scope.variables],
          )
          .getSingle();
      return Success(
        ServiceMaterialRequestSummary(
          openCount: row.readNullable<int>('open_count') ?? 0,
          todayCount: row.readNullable<int>('today_count') ?? 0,
          lineCount: row.readNullable<int>('line_count') ?? 0,
          totalCount: row.read<int>('total'),
        ),
      );
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Stream<Result<List<ServiceMaterialRequestListItem>>> watchRecentRequests(
    AuthContext context, {
    int limit = 5,
  }) {
    final failure = _viewAccess(context);
    if (failure != null) return Stream.value(Failed(failure));
    final scope = _scopeClause(context);
    return db
        .customSelect(
          'SELECT $_listColumns FROM $_table r $_listJoins '
          'WHERE ${scope.sql} '
          'ORDER BY r.request_date DESC, r.created_at DESC LIMIT ?',
          variables: [...scope.variables, Variable(limit.clamp(1, 50))],
          readsFrom: _reads,
        )
        .watch()
        .map<Result<List<ServiceMaterialRequestListItem>>>(
          (rows) => Success([for (final row in rows) _listItem(row)]),
        )
        .transform(
          StreamTransformer<
            Result<List<ServiceMaterialRequestListItem>>,
            Result<List<ServiceMaterialRequestListItem>>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<List<ServiceMaterialRequestListItem>>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  // ------------------------------------------------------- create/update

  DateTime _companyDate(AuthContext context) {
    final local = time.localWallTime(clock.now(), context.company.timezone);
    final wall = local is Success<DateTime> ? local.value : clock.now().toUtc();
    return DateTime.utc(wall.year, wall.month, wall.day);
  }

  String _searchText(
    String requestNumber,
    String inspectionNumber,
    String assignmentNumber,
    String enquiryNumber,
    String? jobOrderReference,
    ServiceEnquiryPartySnapshot snapshot,
    List<ServiceMaterialRequestLineDraft> lines,
  ) =>
      [
            requestNumber,
            inspectionNumber,
            assignmentNumber,
            enquiryNumber,
            jobOrderReference,
            snapshot.customerName,
            snapshot.customerMobile,
            snapshot.siteName,
            snapshot.buildingName,
            snapshot.unitNumber,
            for (final line in lines) ...[
              line.code,
              line.description,
              line.batchNumber,
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

  Failure? _validateLines(List<ServiceMaterialRequestLineDraft> lines) {
    if (lines.isEmpty) {
      return const Failure(code: 'servicesMaterialRequestLinesRequired');
    }
    for (final line in lines) {
      if (line.code.trim().isEmpty) {
        return const Failure(code: 'servicesMaterialRequestCodeRequired');
      }
      if (line.description.trim().isEmpty) {
        return const Failure(
          code: 'servicesMaterialRequestDescriptionRequired',
        );
      }
      if (parseMaterialRequestQuantity(line.quantity) == null) {
        return const Failure(code: 'servicesMaterialRequestQuantityRequired');
      }
    }
    return null;
  }

  Future<void> _validatePurpose(
    String companyId,
    String? purposeId,
    String? previousPurposeId,
  ) async {
    if (purposeId == null || purposeId == previousPurposeId) return;
    final row = await db
        .customSelect(
          'SELECT status FROM $_purposeTable WHERE company_id=? AND id=?',
          variables: [Variable(companyId), Variable(purposeId)],
        )
        .getSingleOrNull();
    if (row == null ||
        row.read<String>('status') != ConfigurationStatus.active.name) {
      throw const _MaterialRequestException(
        'servicesMaterialRequestPurposeInvalid',
      );
    }
  }

  /// Validates that each linked source requirement belongs to the source
  /// Inspection and is available (WAITING, or already linked to this request).
  Future<void> _validateRequirements(
    String companyId,
    String inspectionId,
    List<ServiceMaterialRequestLineDraft> lines,
    Set<String> alreadyLinkedByThisRequest, {
    String? excludeRequestId,
  }) async {
    for (final line in lines) {
      final requirementId = line.sourceInspectionMaterialRequirementId;
      if (requirementId == null) continue;
      final row = await db
          .customSelect(
            'SELECT inspection_id, status, removed_at FROM $_requirementTable WHERE company_id=? AND id=?',
            variables: [Variable(companyId), Variable(requirementId)],
          )
          .getSingleOrNull();
      if (row == null ||
          row.read<String>('inspection_id') != inspectionId ||
          row.readNullable<DateTime>('removed_at') != null) {
        throw const _MaterialRequestException(
          'servicesMaterialRequestInspectionInvalid',
        );
      }
      final status = row.read<String>('status');
      if (status != ServiceInspectionMaterialStatus.waiting.wire &&
          !alreadyLinkedByThisRequest.contains(requirementId)) {
        throw const _MaterialRequestException(
          'servicesMaterialRequestRequirementLinked',
        );
      }
      final other = await db
          .customSelect(
            'SELECT 1 FROM $_lineTable WHERE company_id=? AND active_requirement_id=? '
            '${excludeRequestId == null ? '' : 'AND material_request_id<>?'} LIMIT 1',
            variables: [
              Variable(companyId),
              Variable(requirementId),
              if (excludeRequestId != null) Variable(excludeRequestId),
            ],
          )
          .get();
      if (other.isNotEmpty) {
        throw const _MaterialRequestException(
          'servicesMaterialRequestRequirementLinked',
        );
      }
    }
  }

  @override
  Future<Result<ServiceMaterialRequest>> createRequest(
    AuthContext context,
    ServiceMaterialRequestDraft draft, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceMaterialRequestCreate,
    );
    if (failure != null) return Failed(failure);
    if (draft.sourceInspectionId == null) {
      return const Failed(
        Failure(
          code: 'servicesMaterialRequestInspectionRequired',
          kind: FailureKind.invalidData,
        ),
      );
    }
    final invalid = _validateLines(draft.lines);
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
            if (row != null) {
              return _record(
                row,
                lines: await _loadLines(context.company.id, existingId),
              );
            }
          }
          final source = await _sourceContext(
            context,
            draft.sourceInspectionId!,
          );
          if (source == null || !source.inspectionStatus.isCompleted) {
            throw const _MaterialRequestException(
              'servicesMaterialRequestInspectionInvalid',
            );
          }
          await _validatePurpose(context.company.id, draft.purposeId, null);
          await _validateRequirements(
            context.company.id,
            source.inspectionId,
            draft.lines,
            const {},
          );
          final now = clock.now();
          final numberResult = await numbers.nextNumber(
            companyId: context.company.id,
            type: DocumentSequenceType.materialRequest,
          );
          final number = switch (numberResult) {
            Success<String>(:final value) => value,
            Failed<String>() => throw const _MaterialRequestException(
              'servicesMaterialRequestSequenceFailed',
            ),
          };
          final id = _uuid.v4();
          final header = ServiceMaterialRequest(
            id: id,
            companyId: context.company.id,
            requestNumber: number,
            requestDate: _companyDate(context),
            sourceInspectionId: source.inspectionId,
            sourceJobAssignmentId: source.jobAssignmentId,
            sourceEnquiryId: source.enquiryId,
            jobOrderReference: _nullable(draft.jobOrderReference),
            purposeId: draft.purposeId,
            acknowledgement: _nullable(draft.acknowledgement),
            receivedBy: _nullable(draft.receivedBy),
            remarks: _nullable(draft.remarks),
            status: ServiceMaterialRequestStatus.open,
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
              source.partySnapshot,
              draft.lines,
            ),
          );
          await _insertLines(context, id, draft.lines, now);
          await _setRequirementStatus(
            context,
            draft.lines
                .map((l) => l.sourceInspectionMaterialRequirementId)
                .whereType<String>()
                .toSet(),
            ServiceInspectionMaterialStatus.requested,
            now,
          );
          final created = _record(
            (await _rawRowForCreate(context, id))!,
            lines: await _loadLines(context.company.id, id),
          );
          await _activity(context, created, 'services.materialRequest.created');
          await _enqueue(
            context,
            created,
            'SERVICES_MATERIAL_REQUEST_CREATE',
            effectiveRequest,
          );
          return created;
        }),
      );
    } on _MaterialRequestException catch (e) {
      return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<ServiceMaterialRequest>> updateRequest(
    AuthContext context,
    String id,
    ServiceMaterialRequestDraft draft, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceMaterialRequestEdit,
    );
    if (failure != null) return Failed(failure);
    final invalid = _validateLines(draft.lines);
    if (invalid != null) return Failed(invalid);
    try {
      return Success(
        await db.transaction(() async {
          final row = await _rawRow(context, id);
          if (row == null) {
            throw const _MaterialRequestException(
              'servicesMaterialRequestNotFound',
            );
          }
          final previous = _record(
            row,
            lines: await _loadLines(context.company.id, id),
          );
          if (!previous.isOpen) {
            throw const _MaterialRequestException(
              'servicesMaterialRequestNotEditable',
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
          await _validatePurpose(
            context.company.id,
            draft.purposeId,
            previous.purposeId,
          );
          final alreadyLinked = {
            for (final line in previous.lines)
              if (line.sourceInspectionMaterialRequirementId != null)
                line.sourceInspectionMaterialRequirementId!,
          };
          await _validateRequirements(
            context.company.id,
            previous.sourceInspectionId,
            draft.lines,
            alreadyLinked,
            excludeRequestId: id,
          );
          final now = clock.now();
          final source = await _sourceContext(
            context,
            previous.sourceInspectionId,
            viewOnly: true,
          );
          final desiredIds = {
            for (final line in draft.lines)
              if (line.sourceInspectionMaterialRequirementId != null)
                line.sourceInspectionMaterialRequirementId!,
          };
          final removed = alreadyLinked.difference(desiredIds);
          await db.customUpdate(
            'UPDATE $_table SET job_order_reference=?, purpose_id=?, acknowledgement=?, received_by=?, remarks=?, search_text=?, version=version+1, updated_at=?, updated_by_user_id=?, sync_status=? WHERE company_id=? AND id=?',
            variables: [
              Variable(_nullable(draft.jobOrderReference)),
              Variable(draft.purposeId),
              Variable(_nullable(draft.acknowledgement)),
              Variable(_nullable(draft.receivedBy)),
              Variable(_nullable(draft.remarks)),
              Variable(
                _searchText(
                  previous.requestNumber,
                  source?.inspectionNumber ?? '',
                  source?.assignmentNumber ?? '',
                  source?.enquiryNumber ?? '',
                  _nullable(draft.jobOrderReference),
                  source?.partySnapshot ?? const ServiceEnquiryPartySnapshot(),
                  draft.lines,
                ),
              ),
              Variable(now),
              Variable(context.user.id),
              const Variable('pending'),
              Variable(context.company.id),
              Variable(id),
            ],
          );
          await db.customUpdate(
            'DELETE FROM $_lineTable WHERE company_id=? AND material_request_id=?',
            variables: [Variable(context.company.id), Variable(id)],
          );
          await _insertLines(context, id, draft.lines, now);
          await _setRequirementStatus(
            context,
            removed,
            ServiceInspectionMaterialStatus.waiting,
            now,
          );
          await _setRequirementStatus(
            context,
            desiredIds,
            ServiceInspectionMaterialStatus.requested,
            now,
          );
          final updated = _record(
            (await _rawRow(context, id))!,
            lines: await _loadLines(context.company.id, id),
          );
          await _activity(context, updated, 'services.materialRequest.updated');
          if (removed.isNotEmpty || desiredIds.isNotEmpty) {
            await _activity(
              context,
              updated,
              'services.materialRequest.linesChanged',
            );
          }
          await _enqueue(
            context,
            updated,
            'SERVICES_MATERIAL_REQUEST_UPDATE',
            effectiveRequest,
          );
          return updated;
        }),
      );
    } on _MaterialRequestException catch (e) {
      return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<void>> cancelRequest(
    AuthContext context,
    String id, {
    String? requestId,
  }) async {
    final failure = _actionAccess(
      context,
      AppPermission.serviceMaterialRequestCancel,
    );
    if (failure != null) return Failed(failure);
    try {
      await db.transaction(() async {
        final row = await _rawRow(context, id);
        if (row == null) {
          throw const _MaterialRequestException(
            'servicesMaterialRequestNotFound',
          );
        }
        final previous = _record(
          row,
          lines: await _loadLines(context.company.id, id),
        );
        if (previous.isCancelled) {
          throw const _MaterialRequestException(
            'servicesMaterialRequestAlreadyCancelled',
          );
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
            const Variable('pending'),
            Variable(context.company.id),
            Variable(id),
          ],
        );
        final linked = {
          for (final line in previous.lines)
            if (line.sourceInspectionMaterialRequirementId != null)
              line.sourceInspectionMaterialRequirementId!,
        };
        // Release the active-requirement links so the requirements can be
        // re-requested later. Source lineage is retained.
        await db.customUpdate(
          'UPDATE $_lineTable SET active_requirement_id=NULL, updated_at=? WHERE company_id=? AND material_request_id=?',
          variables: [
            Variable(now),
            Variable(context.company.id),
            Variable(id),
          ],
        );
        await _setRequirementStatus(
          context,
          linked,
          ServiceInspectionMaterialStatus.waiting,
          now,
        );
        final cancelled = ServiceMaterialRequest(
          id: previous.id,
          companyId: previous.companyId,
          requestNumber: previous.requestNumber,
          requestDate: previous.requestDate,
          sourceInspectionId: previous.sourceInspectionId,
          sourceJobAssignmentId: previous.sourceJobAssignmentId,
          sourceEnquiryId: previous.sourceEnquiryId,
          jobOrderReference: previous.jobOrderReference,
          purposeId: previous.purposeId,
          acknowledgement: previous.acknowledgement,
          receivedBy: previous.receivedBy,
          remarks: previous.remarks,
          status: ServiceMaterialRequestStatus.cancelled,
          version: previous.version + 1,
          createdAt: previous.createdAt,
          updatedAt: now,
          createdByUserId: previous.createdByUserId,
          updatedByUserId: context.user.id,
          requestId: previous.requestId,
          syncStatus: RecordSyncStatus.pending,
          lines: previous.lines,
        );
        await _activity(
          context,
          cancelled,
          'services.materialRequest.cancelled',
        );
        await _enqueue(
          context,
          cancelled,
          'SERVICES_MATERIAL_REQUEST_CANCEL',
          effectiveRequest,
        );
      });
      return const Success(null);
    } on _MaterialRequestException catch (e) {
      return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  // ---------------------------------------------------------- persistence

  Future<void> _insertHeader(
    ServiceMaterialRequest r, {
    required String searchText,
  }) => db
      .into(db.serviceMaterialRequests)
      .insert(
        ServiceMaterialRequestsCompanion.insert(
          id: r.id,
          companyId: r.companyId,
          requestNumber: r.requestNumber,
          requestDate: r.requestDate,
          sourceInspectionId: r.sourceInspectionId,
          sourceJobAssignmentId: r.sourceJobAssignmentId,
          sourceEnquiryId: r.sourceEnquiryId,
          jobOrderReference: Value(r.jobOrderReference),
          purposeId: Value(r.purposeId),
          acknowledgement: Value(r.acknowledgement),
          receivedBy: Value(r.receivedBy),
          remarks: Value(r.remarks),
          status: r.status.wire,
          version: Value(r.version),
          searchText: Value(searchText),
          createdAt: r.createdAt,
          updatedAt: r.updatedAt,
          createdByUserId: r.createdByUserId,
          updatedByUserId: r.updatedByUserId,
          requestId: Value(r.requestId),
          syncStatus: r.syncStatus.name,
        ),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> _insertLines(
    AuthContext context,
    String requestId,
    List<ServiceMaterialRequestLineDraft> lines,
    DateTime now,
  ) async {
    var order = 0;
    for (final line in lines) {
      order++;
      final quantity = parseMaterialRequestQuantity(line.quantity)!;
      await db
          .into(db.serviceMaterialRequestLines)
          .insert(
            ServiceMaterialRequestLinesCompanion.insert(
              id: line.id,
              companyId: context.company.id,
              materialRequestId: requestId,
              sourceInspectionMaterialRequirementId: Value(
                line.sourceInspectionMaterialRequirementId,
              ),
              activeRequirementId: Value(
                line.sourceInspectionMaterialRequirementId,
              ),
              lineNumber: order,
              code: line.code.trim(),
              description: line.description.trim(),
              batchNumber: Value(_nullable(line.batchNumber)),
              quantity: quantity,
              remark: Value(_nullable(line.remark)),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  Future<void> _setRequirementStatus(
    AuthContext context,
    Set<String> requirementIds,
    ServiceInspectionMaterialStatus status,
    DateTime now,
  ) async {
    if (requirementIds.isEmpty) return;
    final placeholders = List.filled(requirementIds.length, '?').join(',');
    await db.customUpdate(
      'UPDATE $_requirementTable SET status=?, updated_at=? WHERE company_id=? AND id IN ($placeholders)',
      variables: [
        Variable(status.wire),
        Variable(now),
        Variable(context.company.id),
        ...requirementIds.map((id) => Variable(id)),
      ],
    );
  }

  String? _nullable(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _activity(
    AuthContext context,
    ServiceMaterialRequest r,
    String eventType,
  ) => activity.append(
    BusinessActivityEvent(
      id: _uuid.v4(),
      companyId: context.company.id,
      moduleKey: 'services',
      entityType: 'serviceMaterialRequest',
      entityId: r.id,
      eventType: eventType,
      occurredAt: clock.now(),
      actorUserId: context.user.id,
      actorEmployeeId: context.employeeReference?.id,
      syncStatus: 'pending',
      metadata: {
        'requestNumber': r.requestNumber,
        'sourceInspectionId': r.sourceInspectionId,
        'status': r.status.wire,
        'lineCount': r.lines.length,
      },
    ),
  );

  Future<void> _enqueue(
    AuthContext context,
    ServiceMaterialRequest r,
    String operation,
    String requestId,
  ) => db
      .into(db.syncOutbox)
      .insert(
        SyncOutboxCompanion.insert(
          id: _uuid.v4(),
          moduleId: 'services',
          entityId: r.id,
          entityType: const Value('serviceMaterialRequest'),
          operation: operation,
          payload: jsonEncode({
            'id': r.id,
            'requestNumber': r.requestNumber,
            'requestDate': r.requestDate.toIso8601String(),
            'sourceInspectionId': r.sourceInspectionId,
            'sourceJobAssignmentId': r.sourceJobAssignmentId,
            'sourceEnquiryId': r.sourceEnquiryId,
            'jobOrderReference': r.jobOrderReference,
            'purposeId': r.purposeId,
            'acknowledgement': r.acknowledgement,
            'receivedBy': r.receivedBy,
            'remarks': r.remarks,
            'status': r.status.wire,
            'version': r.version,
            'lines': [
              for (final line in r.lines)
                {
                  'id': line.id,
                  'sourceInspectionMaterialRequirementId':
                      line.sourceInspectionMaterialRequirementId,
                  'code': line.code,
                  'description': line.description,
                  'batchNumber': line.batchNumber,
                  'quantity': line.quantity,
                  'remark': line.remark,
                },
            ],
          }),
          createdAt: r.updatedAt,
          companyId: Value(context.company.id),
          requestId: Value(requestId),
        ),
        mode: InsertMode.insertOrIgnore,
      );
}

class _MaterialRequestException implements Exception {
  const _MaterialRequestException(this.code);
  final String code;
}
