import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';
import 'package:modular_erp/shared/transactions/domain/attachment_repository.dart';
import 'package:modular_erp/shared/transactions/domain/document_number.dart';
import 'package:modular_erp/shared/transactions/domain/document_number_service.dart';

/// Local (Drift) implementation of the Service Enquiry transaction.
///
/// All mutations run in one database transaction (sequence allocation + header +
/// detail lines + attachment metadata + activity + outbox), so a failure leaves
/// no partial Enquiry. Customer and Site reference lookups are authorized by
/// Enquiry Create/Edit, never by the full directory View capability.
class LocalServiceEnquiryRepository implements ServiceEnquiryRepository {
  LocalServiceEnquiryRepository(
    this.db,
    this.clock,
    this.numbers,
    this.activity,
    this.attachments, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();
  final AppDatabase db;
  final AppClock clock;
  final DocumentNumberService numbers;
  final ActivityRepository activity;
  final AttachmentRepository attachments;
  final Uuid _uuid;

  static const _table = 'service_enquiries';
  static const _detailTable = 'service_enquiry_details';
  static const _detailOwnerType = 'serviceEnquiryDetail';
  static const _maxDescription = 4000;

  // ---------------------------------------------------------------- access

  Failure? _denied() => const Failure(code: 'servicesEnquiryDenied');

  bool _enabled(AuthContext context) =>
      context.user.status == AccountStatus.active &&
      context.user.companyId == context.company.id &&
      context.company.enabledModules.contains('services');

  bool _can(AuthContext context, AppPermission permission) =>
      context.user.permissions.contains(permission);

  Failure? _viewAccess(AuthContext context) =>
      _enabled(context) && _can(context, AppPermission.serviceEnquiryView)
      ? null
      : _denied();

  Failure? _actionAccess(AuthContext context, AppPermission permission) =>
      _enabled(context) && _can(context, permission) ? null : _denied();

  Failure? _referenceAccess(AuthContext context) =>
      _enabled(context) &&
          (_can(context, AppPermission.serviceEnquiryCreate) ||
              _can(context, AppPermission.serviceEnquiryEdit))
      ? null
      : _denied();

  // ------------------------------------------------------------- read model

  static const _listColumns =
      'e.*, '
      'st.name AS service_type_name, '
      'ct.name AS complaint_type_name, '
      'pr.name AS priority_name, pr.rank AS priority_rank, '
      'tt.name AS ticket_type_name';

  static const _listJoins =
      'LEFT JOIN service_types st ON st.id=e.service_type_id AND st.company_id=e.company_id '
      'LEFT JOIN complaint_types ct ON ct.id=e.complaint_type_id AND ct.company_id=e.company_id '
      'LEFT JOIN service_priorities pr ON pr.id=e.priority_id AND pr.company_id=e.company_id '
      'LEFT JOIN service_ticket_types tt ON tt.id=e.ticket_type_id AND tt.company_id=e.company_id';

  Set<ResultSetImplementation> get _listReads => {
    db.serviceEnquiries,
    db.serviceTypes,
    db.complaintTypes,
    db.servicePriorities,
    db.serviceTicketTypes,
  };

  ServiceEnquiryPartySnapshot _snapshot(String raw) {
    try {
      return ServiceEnquiryPartySnapshot.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const ServiceEnquiryPartySnapshot();
    }
  }

  ServiceEnquiryListItem _listItem(QueryRow row) {
    final snapshot = _snapshot(row.read<String>('party_snapshot'));
    return ServiceEnquiryListItem(
      id: row.read<String>('id'),
      enquiryNumber: row.read<String>('enquiry_number'),
      createdAt: row.read<DateTime>('created_at').toUtc(),
      customerName: snapshot.customerName ?? '',
      customerMobile: snapshot.customerMobile,
      siteName: snapshot.siteName ?? '',
      serviceTypeName: row.readNullable<String>('service_type_name') ?? '',
      complaintTypeName: row.readNullable<String>('complaint_type_name') ?? '',
      priorityName: row.readNullable<String>('priority_name') ?? '',
      priorityRank: row.readNullable<int>('priority_rank') ?? 0,
      ticketTypeName: row.readNullable<String>('ticket_type_name') ?? '',
      status: ServiceEnquiryStatusX.fromWire(row.read<String>('status')),
    );
  }

  ServiceEnquiry _record(
    QueryRow row, {
    List<ServiceEnquiryDetailLine> details = const [],
  }) => ServiceEnquiry(
    id: row.read<String>('id'),
    companyId: row.read<String>('company_id'),
    enquiryNumber: row.read<String>('enquiry_number'),
    customerId: row.read<String>('customer_id'),
    siteId: row.read<String>('site_id'),
    serviceTypeId: row.read<String>('service_type_id'),
    complaintTypeId: row.read<String>('complaint_type_id'),
    priorityId: row.read<String>('priority_id'),
    ticketTypeId: row.read<String>('ticket_type_id'),
    materialReceived: MaterialReceivedX.fromWire(
      row.readNullable<String>('material_received') ?? 'no',
    ),
    status: ServiceEnquiryStatusX.fromWire(row.read<String>('status')),
    partySnapshot: _snapshot(row.read<String>('party_snapshot')),
    details: details,
    cancelReason: row.readNullable<String>('cancel_reason'),
    cancelledAt: row.readNullable<DateTime>('cancelled_at')?.toUtc(),
    version: row.read<int>('version'),
    createdAt: row.read<DateTime>('created_at').toUtc(),
    updatedAt: row.read<DateTime>('updated_at').toUtc(),
    createdByUserId: row.read<String>('created_by_user_id'),
    updatedByUserId: row.read<String>('updated_by_user_id'),
    requestId: row.readNullable<String>('request_id'),
    syncStatus: RecordSyncStatus.values.byName(row.read<String>('sync_status')),
  );

  ServiceEnquiryView _view(QueryRow row, ServiceEnquiry enquiry) =>
      ServiceEnquiryView(
        enquiry: enquiry,
        serviceTypeName: row.readNullable<String>('service_type_name') ?? '',
        complaintTypeName:
            row.readNullable<String>('complaint_type_name') ?? '',
        priorityName: row.readNullable<String>('priority_name') ?? '',
        priorityRank: row.readNullable<int>('priority_rank') ?? 0,
        ticketTypeName: row.readNullable<String>('ticket_type_name') ?? '',
      );

  ServiceEnquiryDetailLine _detailLine(
    QueryRow row,
    List<AttachmentRef> attachments,
  ) => ServiceEnquiryDetailLine(
    id: row.read<String>('id'),
    companyId: row.read<String>('company_id'),
    enquiryId: row.read<String>('enquiry_id'),
    lineNumber: row.read<int>('line_number'),
    description: row.read<String>('description'),
    status: ServiceEnquiryDetailStatusX.fromWire(row.read<String>('status')),
    attachments: attachments,
    createdAt: row.read<DateTime>('created_at').toUtc(),
    updatedAt: row.read<DateTime>('updated_at').toUtc(),
    createdByUserId: row.read<String>('created_by_user_id'),
    updatedByUserId: row.read<String>('updated_by_user_id'),
    syncStatus: RecordSyncStatus.values.byName(row.read<String>('sync_status')),
  );

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
    for (final list in map.values) {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return map;
  }

  Future<List<ServiceEnquiryDetailLine>> _loadDetails(
    String companyId,
    String enquiryId,
  ) async {
    final rows = await db
        .customSelect(
          'SELECT * FROM $_detailTable '
          'WHERE company_id=? AND enquiry_id=? AND removed_at IS NULL '
          'ORDER BY line_number, id',
          variables: [Variable(companyId), Variable(enquiryId)],
        )
        .get();
    if (rows.isEmpty) return const [];
    final byOwner = await _attachmentsByOwner(companyId, [
      for (final row in rows) row.read<String>('id'),
    ]);
    return [
      for (final row in rows)
        _detailLine(row, byOwner[row.read<String>('id')] ?? const []),
    ];
  }

  ({String sql, List<Variable> variables}) _where(
    AuthContext context, {
    String query = '',
    ServiceEnquiryStatus? status,
    String? serviceTypeId,
    String? complaintTypeId,
    String? priorityId,
    String? ticketTypeId,
    DateTime? createdFrom,
    DateTime? createdTo,
    String? customerId,
    String? siteId,
  }) {
    final parts = <String>['e.company_id=?'];
    final variables = <Variable>[Variable(context.company.id)];
    if (status != null) {
      parts.add('e.status=?');
      variables.add(Variable(status.wire));
    }
    for (final (column, value) in [
      ('e.service_type_id', serviceTypeId),
      ('e.complaint_type_id', complaintTypeId),
      ('e.priority_id', priorityId),
      ('e.ticket_type_id', ticketTypeId),
      ('e.customer_id', customerId),
      ('e.site_id', siteId),
    ]) {
      if (value != null) {
        parts.add('$column=?');
        variables.add(Variable(value));
      }
    }
    if (createdFrom != null) {
      parts.add('e.created_at>=?');
      variables.add(Variable(createdFrom));
    }
    if (createdTo != null) {
      parts.add('e.created_at<=?');
      variables.add(Variable(createdTo));
    }
    if (query.trim().isNotEmpty) {
      final escaped = query
          .trim()
          .toLowerCase()
          .replaceAll('\\', '\\\\')
          .replaceAll('%', '\\%')
          .replaceAll('_', '\\_');
      parts.add(
        "(lower(e.enquiry_number) LIKE ? ESCAPE '\\' OR e.search_text LIKE ? ESCAPE '\\')",
      );
      variables.addAll([Variable('%$escaped%'), Variable('%$escaped%')]);
    }
    return (sql: parts.join(' AND '), variables: variables);
  }

  Future<int> _count(
    AuthContext context,
    ({String sql, List<Variable> variables}) where,
  ) async {
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM $_table e WHERE ${where.sql}',
          variables: where.variables,
        )
        .getSingle();
    return row.read<int>('c');
  }

  Stream<Result<ServiceEnquiryPage>> _watchPage(
    AuthContext context, {
    required ({String sql, List<Variable> variables}) where,
    required int page,
    required int limit,
  }) {
    final order = 'ORDER BY e.created_at DESC, e.id DESC';
    final sql =
        'SELECT $_listColumns FROM $_table e $_listJoins '
        'WHERE ${where.sql} $order LIMIT ? OFFSET ?';
    return db
        .customSelect(
          sql,
          variables: [
            ...where.variables,
            Variable(limit.clamp(1, 200)),
            Variable(page.clamp(0, 1000000) * limit.clamp(1, 200)),
          ],
          readsFrom: _listReads,
        )
        .watch()
        .asyncMap<Result<ServiceEnquiryPage>>((rows) async {
          final total = await _count(context, (
            sql: 'e.company_id=?',
            variables: [Variable(context.company.id)],
          ));
          final filtered = await _count(context, where);
          return Success(
            ServiceEnquiryPage(
              [for (final row in rows) _listItem(row)],
              total,
              filtered,
            ),
          );
        })
        .transform(
          StreamTransformer<
            Result<ServiceEnquiryPage>,
            Result<ServiceEnquiryPage>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceEnquiryPage>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  @override
  Stream<Result<ServiceEnquiryPage>> watchEnquiries(
    AuthContext context, {
    String query = '',
    ServiceEnquiryStatus? status,
    String? serviceTypeId,
    String? complaintTypeId,
    String? priorityId,
    String? ticketTypeId,
    DateTime? createdFrom,
    DateTime? createdTo,
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
        serviceTypeId: serviceTypeId,
        complaintTypeId: complaintTypeId,
        priorityId: priorityId,
        ticketTypeId: ticketTypeId,
        createdFrom: createdFrom,
        createdTo: createdTo,
      ),
      page: page,
      limit: pageSize,
    );
  }

  Stream<Result<List<ServiceEnquiryListItem>>> _watchShortList(
    AuthContext context, {
    required ({String sql, List<Variable> variables}) where,
    required int limit,
  }) {
    return db
        .customSelect(
          'SELECT $_listColumns FROM $_table e $_listJoins '
          'WHERE ${where.sql} ORDER BY e.created_at DESC, e.id DESC LIMIT ?',
          variables: [...where.variables, Variable(limit.clamp(1, 50))],
          readsFrom: _listReads,
        )
        .watch()
        .map<Result<List<ServiceEnquiryListItem>>>(
          (rows) => Success([for (final row in rows) _listItem(row)]),
        )
        .transform(
          StreamTransformer<
            Result<List<ServiceEnquiryListItem>>,
            Result<List<ServiceEnquiryListItem>>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<List<ServiceEnquiryListItem>>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  @override
  Stream<Result<List<ServiceEnquiryListItem>>> watchRecentEnquiries(
    AuthContext context, {
    int limit = 5,
  }) {
    final failure = _viewAccess(context);
    if (failure != null) return Stream.value(Failed(failure));
    return _watchShortList(context, where: _where(context), limit: limit);
  }

  @override
  Stream<Result<List<ServiceEnquiryListItem>>> watchEnquiriesForCustomer(
    AuthContext context,
    String customerId, {
    int limit = 5,
  }) {
    final failure = _viewAccess(context);
    if (failure != null) return Stream.value(Failed(failure));
    return _watchShortList(
      context,
      where: _where(context, customerId: customerId),
      limit: limit,
    );
  }

  @override
  Stream<Result<List<ServiceEnquiryListItem>>> watchEnquiriesForSite(
    AuthContext context,
    String siteId, {
    int limit = 5,
  }) {
    final failure = _viewAccess(context);
    if (failure != null) return Stream.value(Failed(failure));
    return _watchShortList(
      context,
      where: _where(context, siteId: siteId),
      limit: limit,
    );
  }

  Future<QueryRow?> _rawRow(AuthContext context, String id) => db
      .customSelect(
        'SELECT $_listColumns FROM $_table e $_listJoins '
        'WHERE e.company_id=? AND e.id=?',
        variables: [Variable(context.company.id), Variable(id)],
      )
      .getSingleOrNull();

  @override
  Stream<Result<ServiceEnquiryView?>> watchEnquiry(
    AuthContext context,
    String id,
  ) {
    final failure = _viewAccess(context);
    if (failure != null) return Stream.value(Failed(failure));
    return db
        .customSelect(
          'SELECT $_listColumns FROM $_table e $_listJoins '
          'WHERE e.company_id=? AND e.id=?',
          variables: [Variable(context.company.id), Variable(id)],
          readsFrom: {..._listReads, db.serviceEnquiryDetails},
        )
        .watchSingleOrNull()
        .asyncMap<Result<ServiceEnquiryView?>>((row) async {
          if (row == null) return const Success<ServiceEnquiryView?>(null);
          final enquiry = _record(
            row,
            details: await _loadDetails(context.company.id, id),
          );
          return Success<ServiceEnquiryView?>(_view(row, enquiry));
        })
        .transform(
          StreamTransformer<
            Result<ServiceEnquiryView?>,
            Result<ServiceEnquiryView?>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceEnquiryView?>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  @override
  Future<Result<ServiceEnquiryView?>> getEnquiry(
    AuthContext context,
    String id,
  ) async {
    final failure = _viewAccess(context);
    if (failure != null) return Failed(failure);
    try {
      final row = await _rawRow(context, id);
      if (row == null) return const Success(null);
      final enquiry = _record(
        row,
        details: await _loadDetails(context.company.id, id),
      );
      return Success(_view(row, enquiry));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  // ------------------------------------------------------------- mutations

  Failure? _validateDraft(ServiceEnquiryDraft draft) {
    if (draft.customerId == null) {
      return const Failure(code: 'servicesEnquiryCustomerRequired');
    }
    if (draft.siteId == null) {
      return const Failure(code: 'servicesEnquirySiteRequired');
    }
    if (draft.serviceTypeId == null) {
      return const Failure(code: 'servicesEnquiryServiceTypeRequired');
    }
    if (draft.complaintTypeId == null) {
      return const Failure(code: 'servicesEnquiryComplaintTypeRequired');
    }
    if (draft.priorityId == null) {
      return const Failure(code: 'servicesEnquiryPriorityRequired');
    }
    if (draft.ticketTypeId == null) {
      return const Failure(code: 'servicesEnquiryTicketTypeRequired');
    }
    if (draft.details.isEmpty) {
      return const Failure(code: 'servicesEnquiryDetailsRequired');
    }
    for (final detail in draft.details) {
      final description = detail.description.trim();
      if (description.isEmpty) {
        return const Failure(code: 'servicesEnquiryDetailDescriptionRequired');
      }
      if (description.length > _maxDescription) {
        return const Failure(code: 'servicesEnquiryDescriptionTooLong');
      }
    }
    return null;
  }

  Future<QueryRow?> _customerRow(String companyId, String id) => db
      .customSelect(
        'SELECT id, customer_code, name, mobile, status FROM service_customers '
        'WHERE company_id=? AND id=?',
        variables: [Variable(companyId), Variable(id)],
      )
      .getSingleOrNull();

  Future<QueryRow?> _siteRow(String companyId, String id) => db
      .customSelect(
        'SELECT id, customer_id, site_code, site_name, tenant_name, building_name, '
        'unit_number, contact_name, contact_mobile, address_line1, address_line2, '
        'area, city, state, postal_code, country_code, status FROM service_sites '
        'WHERE company_id=? AND id=?',
        variables: [Variable(companyId), Variable(id)],
      )
      .getSingleOrNull();

  Future<QueryRow?> _masterRow(String table, String companyId, String id) => db
      .customSelect(
        'SELECT id, name, status, ${table == 'complaint_types' ? 'service_type_id' : 'NULL AS service_type_id'} '
        'FROM $table WHERE company_id=? AND id=?',
        variables: [Variable(companyId), Variable(id)],
      )
      .getSingleOrNull();

  Future<ServiceEnquiryPartySnapshot> _resolveReferences(
    AuthContext context,
    ServiceEnquiryDraft draft,
  ) async {
    final companyId = context.company.id;
    final customer = await _customerRow(companyId, draft.customerId!);
    if (customer == null) {
      throw const _EnquiryException('servicesEnquiryCustomerNotFound');
    }
    if (customer.read<String>('status') != ConfigurationStatus.active.name) {
      throw const _EnquiryException('servicesEnquiryCustomerInactive');
    }
    final site = await _siteRow(companyId, draft.siteId!);
    if (site == null) {
      throw const _EnquiryException('servicesEnquirySiteNotFound');
    }
    if (site.read<String>('customer_id') != draft.customerId) {
      throw const _EnquiryException('servicesEnquirySiteCustomerMismatch');
    }
    if (site.read<String>('status') != ConfigurationStatus.active.name) {
      throw const _EnquiryException('servicesEnquirySiteInactive');
    }

    final serviceType = await _masterRow(
      'service_types',
      companyId,
      draft.serviceTypeId!,
    );
    if (serviceType == null ||
        serviceType.read<String>('status') != ConfigurationStatus.active.name) {
      throw const _EnquiryException('servicesEnquiryServiceTypeInvalid');
    }
    final complaintType = await _masterRow(
      'complaint_types',
      companyId,
      draft.complaintTypeId!,
    );
    if (complaintType == null ||
        complaintType.read<String>('status') !=
            ConfigurationStatus.active.name) {
      throw const _EnquiryException('servicesEnquiryComplaintTypeInvalid');
    }
    final complaintServiceTypeId = complaintType.readNullable<String>(
      'service_type_id',
    );
    if (complaintServiceTypeId != null &&
        complaintServiceTypeId != draft.serviceTypeId) {
      throw const _EnquiryException('servicesEnquiryComplaintTypeMismatch');
    }
    final priority = await _masterRow(
      'service_priorities',
      companyId,
      draft.priorityId!,
    );
    if (priority == null ||
        priority.read<String>('status') != ConfigurationStatus.active.name) {
      throw const _EnquiryException('servicesEnquiryPriorityInvalid');
    }
    final ticketType = await _masterRow(
      'service_ticket_types',
      companyId,
      draft.ticketTypeId!,
    );
    if (ticketType == null ||
        ticketType.read<String>('status') != ConfigurationStatus.active.name) {
      throw const _EnquiryException('servicesEnquiryTicketTypeInvalid');
    }

    final address = [
      site.readNullable<String>('address_line1'),
      site.readNullable<String>('address_line2'),
      site.readNullable<String>('area'),
      site.readNullable<String>('city'),
      site.readNullable<String>('state'),
      site.readNullable<String>('postal_code'),
      site.readNullable<String>('country_code'),
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(', ');

    return ServiceEnquiryPartySnapshot(
      customerName: customer.read<String>('name'),
      customerCode: customer.read<String>('customer_code'),
      customerMobile: customer.read<String>('mobile'),
      siteName: site.read<String>('site_name'),
      tenantName: site.readNullable<String>('tenant_name'),
      buildingName: site.readNullable<String>('building_name'),
      unitNumber: site.readNullable<String>('unit_number'),
      addressSummary: address.isEmpty ? null : address,
      siteContactName: site.readNullable<String>('contact_name'),
      siteContactMobile: site.readNullable<String>('contact_mobile'),
    );
  }

  String _searchText(String enquiryNumber, ServiceEnquiryPartySnapshot s) =>
      [
            enquiryNumber,
            s.customerName,
            s.customerMobile,
            s.siteName,
            s.buildingName,
            s.unitNumber,
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

  // -------------------------------------------------- detail line persistence

  Future<void> _insertDetail(ServiceEnquiryDetailLine line) => db
      .into(db.serviceEnquiryDetails)
      .insert(
        ServiceEnquiryDetailsCompanion.insert(
          id: line.id,
          companyId: line.companyId,
          enquiryId: line.enquiryId,
          lineNumber: line.lineNumber,
          description: line.description,
          status: line.status.wire,
          createdAt: line.createdAt,
          updatedAt: line.updatedAt,
          createdByUserId: line.createdByUserId,
          updatedByUserId: line.updatedByUserId,
          syncStatus: line.syncStatus.name,
        ),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> _updateDetail(
    AuthContext context,
    String enquiryId,
    ServiceEnquiryDraftDetail draft,
    int lineNumber,
    DateTime now,
  ) =>
      (db.update(db.serviceEnquiryDetails)..where(
            (t) =>
                t.id.equals(draft.id) &
                t.companyId.equals(context.company.id) &
                t.enquiryId.equals(enquiryId),
          ))
          .write(
            ServiceEnquiryDetailsCompanion(
              lineNumber: Value(lineNumber),
              description: Value(draft.description.trim()),
              status: Value(draft.status.wire),
              removedAt: const Value(null),
              updatedAt: Value(now),
              updatedByUserId: Value(context.user.id),
              syncStatus: const Value('pending'),
            ),
          );

  Future<void> _softRemoveDetails(
    AuthContext context,
    String enquiryId,
    List<String> ids,
    DateTime now,
  ) async {
    if (ids.isEmpty) return;
    await (db.update(db.serviceEnquiryDetails)..where(
          (t) =>
              t.companyId.equals(context.company.id) &
              t.enquiryId.equals(enquiryId) &
              t.id.isIn(ids),
        ))
        .write(
          ServiceEnquiryDetailsCompanion(
            removedAt: Value(now),
            updatedAt: Value(now),
            updatedByUserId: Value(context.user.id),
            syncStatus: const Value('pending'),
          ),
        );
  }

  /// Reconciles attachment metadata for every draft detail line: inserts new
  /// client-generated attachments, soft-removes ones no longer present. Runs in
  /// the caller's transaction so the Enquiry + details + attachments are atomic.
  Future<void> _reconcileAttachments(
    AuthContext context,
    String enquiryId,
    List<ServiceEnquiryDraftDetail> drafts,
    DateTime now,
  ) async {
    final companyId = context.company.id;
    final allDetailIds = await db
        .customSelect(
          'SELECT id FROM $_detailTable WHERE company_id=? AND enquiry_id=?',
          variables: [Variable(companyId), Variable(enquiryId)],
        )
        .get();
    final ownerIds = [for (final row in allDetailIds) row.read<String>('id')];
    final existingResult = await attachments.getForOwners(
      companyId: companyId,
      ownerType: _detailOwnerType,
      ownerIds: ownerIds,
    );
    final existing = existingResult is Success<List<AttachmentRef>>
        ? existingResult.value
        : const <AttachmentRef>[];
    final existingById = {for (final a in existing) a.id: a};

    final desired =
        <String, ({ServiceEnquiryDraftDetail line, AttachmentRef ref})>{
          for (final line in drafts)
            for (final ref in line.attachments) ref.id: (line: line, ref: ref),
        };

    for (final entry in desired.entries) {
      if (existingById.containsKey(entry.key)) continue;
      final ref = entry.value.ref;
      final result = await attachments.addLocalAttachment(
        AttachmentDraft(
          companyId: companyId,
          ownerType: _detailOwnerType,
          ownerId: entry.value.line.id,
          category: AttachmentCategory.problemPhoto,
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
        throw _EnquiryException(failure.code);
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
  Future<Result<ServiceEnquiry>> createEnquiry(
    AuthContext context,
    ServiceEnquiryDraft draft, {
    String? requestId,
  }) async {
    final failure = _actionAccess(context, AppPermission.serviceEnquiryCreate);
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
                details: await _loadDetails(context.company.id, existingId),
              );
            }
          }
          final snapshot = await _resolveReferences(context, draft);
          final now = clock.now();
          final numberResult = await numbers.nextNumber(
            companyId: context.company.id,
            type: DocumentSequenceType.serviceEnquiry,
          );
          final number = switch (numberResult) {
            Success<String>(:final value) => value,
            Failed<String>() => throw const _EnquiryException(
              'servicesEnquirySequenceFailed',
            ),
          };
          final enquiryId = _uuid.v4();
          await _insertHeader(
            ServiceEnquiry(
              id: enquiryId,
              companyId: context.company.id,
              enquiryNumber: number,
              customerId: draft.customerId!,
              siteId: draft.siteId!,
              serviceTypeId: draft.serviceTypeId!,
              complaintTypeId: draft.complaintTypeId!,
              priorityId: draft.priorityId!,
              ticketTypeId: draft.ticketTypeId!,
              materialReceived: draft.materialReceived,
              status: ServiceEnquiryStatus.open,
              partySnapshot: snapshot,
              version: 1,
              createdAt: now,
              updatedAt: now,
              createdByUserId: context.user.id,
              updatedByUserId: context.user.id,
              requestId: effectiveRequest,
              syncStatus: RecordSyncStatus.pending,
            ),
          );
          await _persistNewDetails(context, enquiryId, draft.details, now);
          await _reconcileAttachments(context, enquiryId, draft.details, now);
          final lines = await _loadDetails(context.company.id, enquiryId);
          final enquiry = ServiceEnquiry(
            id: enquiryId,
            companyId: context.company.id,
            enquiryNumber: number,
            customerId: draft.customerId!,
            siteId: draft.siteId!,
            serviceTypeId: draft.serviceTypeId!,
            complaintTypeId: draft.complaintTypeId!,
            priorityId: draft.priorityId!,
            ticketTypeId: draft.ticketTypeId!,
            materialReceived: draft.materialReceived,
            status: ServiceEnquiryStatus.open,
            partySnapshot: snapshot,
            details: lines,
            version: 1,
            createdAt: now,
            updatedAt: now,
            createdByUserId: context.user.id,
            updatedByUserId: context.user.id,
            requestId: effectiveRequest,
            syncStatus: RecordSyncStatus.pending,
          );
          await _activity(context, enquiry, 'services.enquiry.created');
          await _enqueue(
            context,
            enquiry,
            'SERVICES_ENQUIRY_CREATE',
            effectiveRequest,
          );
          return enquiry;
        }),
      );
    } on _EnquiryException catch (e) {
      return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  Future<List<ServiceEnquiryDetailLine>> _persistNewDetails(
    AuthContext context,
    String enquiryId,
    List<ServiceEnquiryDraftDetail> drafts,
    DateTime now,
  ) async {
    final lines = <ServiceEnquiryDetailLine>[];
    var order = 0;
    for (final draft in drafts) {
      order++;
      final line = ServiceEnquiryDetailLine(
        id: draft.id,
        companyId: context.company.id,
        enquiryId: enquiryId,
        lineNumber: order,
        description: draft.description.trim(),
        status: draft.status,
        createdAt: now,
        updatedAt: now,
        createdByUserId: context.user.id,
        updatedByUserId: context.user.id,
        syncStatus: RecordSyncStatus.pending,
      );
      await _insertDetail(line);
      lines.add(line);
    }
    return lines;
  }

  @override
  Future<Result<ServiceEnquiry>> updateEnquiry(
    AuthContext context,
    String id,
    ServiceEnquiryDraft draft, {
    String? requestId,
  }) async {
    final failure = _actionAccess(context, AppPermission.serviceEnquiryEdit);
    if (failure != null) return Failed(failure);
    final invalid = _validateDraft(draft);
    if (invalid != null) return Failed(invalid);
    try {
      return Success(
        await db.transaction(() async {
          final row = await _rawRow(context, id);
          if (row == null) {
            throw const _EnquiryException('servicesEnquiryNotFound');
          }
          final previous = _record(row);
          if (!previous.isOpen) {
            throw const _EnquiryException('servicesEnquiryNotEditable');
          }
          final effectiveRequest = requestId ?? _uuid.v4();
          final existingId = await _requestEntity(
            context.company.id,
            effectiveRequest,
          );
          if (existingId != null) {
            return _record(
              row,
              details: await _loadDetails(context.company.id, id),
            );
          }
          final snapshot = await _resolveReferences(context, draft);
          final now = clock.now();
          final existingDetailRows = await db
              .customSelect(
                'SELECT id FROM $_detailTable '
                'WHERE company_id=? AND enquiry_id=? AND removed_at IS NULL',
                variables: [Variable(context.company.id), Variable(id)],
              )
              .get();
          final existingIds = {
            for (final r in existingDetailRows) r.read<String>('id'),
          };
          final draftIds = {for (final d in draft.details) d.id};

          await _softRemoveDetails(
            context,
            id,
            existingIds.difference(draftIds).toList(),
            now,
          );

          var order = 0;
          for (final detail in draft.details) {
            order++;
            if (existingIds.contains(detail.id)) {
              await _updateDetail(context, id, detail, order, now);
            } else {
              await _insertDetail(
                ServiceEnquiryDetailLine(
                  id: detail.id,
                  companyId: context.company.id,
                  enquiryId: id,
                  lineNumber: order,
                  description: detail.description.trim(),
                  status: detail.status,
                  createdAt: now,
                  updatedAt: now,
                  createdByUserId: context.user.id,
                  updatedByUserId: context.user.id,
                  syncStatus: RecordSyncStatus.pending,
                ),
              );
            }
          }
          await _reconcileAttachments(context, id, draft.details, now);
          final lines = await _loadDetails(context.company.id, id);

          final updated = ServiceEnquiry(
            id: previous.id,
            companyId: previous.companyId,
            enquiryNumber: previous.enquiryNumber,
            customerId: draft.customerId!,
            siteId: draft.siteId!,
            serviceTypeId: draft.serviceTypeId!,
            complaintTypeId: draft.complaintTypeId!,
            priorityId: draft.priorityId!,
            ticketTypeId: draft.ticketTypeId!,
            materialReceived: draft.materialReceived,
            status: ServiceEnquiryStatus.open,
            partySnapshot: snapshot,
            details: lines,
            version: previous.version + 1,
            createdAt: previous.createdAt,
            updatedAt: now,
            createdByUserId: previous.createdByUserId,
            updatedByUserId: context.user.id,
            requestId: previous.requestId,
            syncStatus: RecordSyncStatus.pending,
          );
          await _updateHeader(context, updated);
          await _activity(context, updated, 'services.enquiry.updated');
          await _enqueue(
            context,
            updated,
            'SERVICES_ENQUIRY_UPDATE',
            effectiveRequest,
          );
          return updated;
        }),
      );
    } on _EnquiryException catch (e) {
      return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<void>> cancelEnquiry(
    AuthContext context,
    String id, {
    String? requestId,
    String? reason,
  }) async {
    final failure = _actionAccess(context, AppPermission.serviceEnquiryCancel);
    if (failure != null) return Failed(failure);
    try {
      await db.transaction(() async {
        final row = await _rawRow(context, id);
        if (row == null) {
          throw const _EnquiryException('servicesEnquiryNotFound');
        }
        final previous = _record(row);
        if (!previous.isOpen) {
          throw const _EnquiryException('servicesEnquiryAlreadyCancelled');
        }
        final effectiveRequest = requestId ?? _uuid.v4();
        final existingId = await _requestEntity(
          context.company.id,
          effectiveRequest,
        );
        if (existingId != null) return;
        final now = clock.now();
        final trimmedReason = reason?.trim();
        final cancelled = ServiceEnquiry(
          id: previous.id,
          companyId: previous.companyId,
          enquiryNumber: previous.enquiryNumber,
          customerId: previous.customerId,
          siteId: previous.siteId,
          serviceTypeId: previous.serviceTypeId,
          complaintTypeId: previous.complaintTypeId,
          priorityId: previous.priorityId,
          ticketTypeId: previous.ticketTypeId,
          materialReceived: previous.materialReceived,
          status: ServiceEnquiryStatus.cancelled,
          partySnapshot: previous.partySnapshot,
          cancelReason: (trimmedReason == null || trimmedReason.isEmpty)
              ? null
              : trimmedReason,
          cancelledAt: now,
          version: previous.version + 1,
          createdAt: previous.createdAt,
          updatedAt: now,
          createdByUserId: previous.createdByUserId,
          updatedByUserId: context.user.id,
          requestId: previous.requestId,
          syncStatus: RecordSyncStatus.pending,
        );
        await _updateHeader(context, cancelled);
        await _activity(context, cancelled, 'services.enquiry.cancelled');
        await _enqueue(
          context,
          cancelled,
          'SERVICES_ENQUIRY_CANCEL',
          effectiveRequest,
        );
      });
      return const Success(null);
    } on _EnquiryException catch (e) {
      return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  // ------------------------------------------------------------- summary

  @override
  Future<Result<ServiceEnquirySummary>> summary(AuthContext context) async {
    final failure = _viewAccess(context);
    if (failure != null) return Failed(failure);
    try {
      final now = clock.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final row = await db
          .customSelect(
            'SELECT '
            'COUNT(*) AS total, '
            "SUM(CASE WHEN e.status='open' THEN 1 ELSE 0 END) AS open_count, "
            "SUM(CASE WHEN e.status='open' AND e.created_at>=? THEN 1 ELSE 0 END) AS today_count, "
            "SUM(CASE WHEN e.status='open' AND e.priority_id IN "
            "(SELECT id FROM service_priorities WHERE company_id=? AND rank>=2) THEN 1 ELSE 0 END) AS high_count "
            'FROM $_table e WHERE e.company_id=?',
            variables: [
              Variable(startOfDay),
              Variable(context.company.id),
              Variable(context.company.id),
            ],
          )
          .getSingle();
      return Success(
        ServiceEnquirySummary(
          openCount: row.readNullable<int>('open_count') ?? 0,
          todayCount: row.readNullable<int>('today_count') ?? 0,
          highUrgentOpenCount: row.readNullable<int>('high_count') ?? 0,
          totalCount: row.read<int>('total'),
        ),
      );
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  // --------------------------------------------------- restricted references

  @override
  Future<Result<List<ServiceCustomerRef>>> searchCustomerRefsForEnquiry(
    AuthContext context, {
    String query = '',
    int limit = 30,
  }) async {
    final failure = _referenceAccess(context);
    if (failure != null) return Failed(failure);
    try {
      final escaped = query.trim().toLowerCase();
      final rows = await db
          .customSelect(
            "SELECT id, customer_code, name, mobile FROM service_customers "
            "WHERE company_id=? AND status='active' AND "
            "(lower(name) LIKE ? ESCAPE '\\' OR lower(customer_code) LIKE ? ESCAPE '\\' OR lower(mobile) LIKE ? ESCAPE '\\') "
            'ORDER BY lower(name) LIMIT ?',
            variables: [
              Variable(context.company.id),
              Variable('%$escaped%'),
              Variable('%$escaped%'),
              Variable('%$escaped%'),
              Variable(limit.clamp(1, 50)),
            ],
          )
          .get();
      return Success([
        for (final row in rows)
          ServiceCustomerRef(
            id: row.read<String>('id'),
            customerCode: row.read<String>('customer_code'),
            displayName: row.read<String>('name'),
            mobile: row.read<String>('mobile'),
          ),
      ]);
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<List<ServiceEnquirySiteRef>>> searchSiteRefsForEnquiry(
    AuthContext context, {
    required String customerId,
    String query = '',
    int limit = 30,
  }) async {
    final failure = _referenceAccess(context);
    if (failure != null) return Failed(failure);
    try {
      final escaped = query.trim().toLowerCase();
      final rows = await db
          .customSelect(
            "SELECT id, site_code, site_name, customer_id, tenant_name, building_name, "
            "unit_number, contact_name, contact_mobile, address_line1, address_line2, "
            "area, city, state, postal_code, country_code FROM service_sites "
            "WHERE company_id=? AND customer_id=? AND status='active' AND "
            "(lower(site_name) LIKE ? ESCAPE '\\' OR lower(site_code) LIKE ? ESCAPE '\\' "
            "OR lower(COALESCE(building_name,'')) LIKE ? ESCAPE '\\' "
            "OR lower(COALESCE(unit_number,'')) LIKE ? ESCAPE '\\') "
            'ORDER BY lower(site_name) LIMIT ?',
            variables: [
              Variable(context.company.id),
              Variable(customerId),
              Variable('%$escaped%'),
              Variable('%$escaped%'),
              Variable('%$escaped%'),
              Variable('%$escaped%'),
              Variable(limit.clamp(1, 50)),
            ],
          )
          .get();
      return Success([
        for (final row in rows)
          ServiceEnquirySiteRef(
            id: row.read<String>('id'),
            siteCode: row.read<String>('site_code'),
            siteName: row.read<String>('site_name'),
            customerId: row.read<String>('customer_id'),
            tenantName: row.readNullable<String>('tenant_name'),
            buildingName: row.readNullable<String>('building_name'),
            unitNumber: row.readNullable<String>('unit_number'),
            addressSummary: [
              row.readNullable<String>('address_line1'),
              row.readNullable<String>('address_line2'),
              row.readNullable<String>('area'),
              row.readNullable<String>('city'),
              row.readNullable<String>('state'),
              row.readNullable<String>('postal_code'),
              row.readNullable<String>('country_code'),
            ].whereType<String>().where((s) => s.trim().isNotEmpty).join(', '),
            contactName: row.readNullable<String>('contact_name'),
            contactMobile: row.readNullable<String>('contact_mobile'),
          ),
      ]);
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<ServiceCustomerRef?>> getCustomerRefForEnquiry(
    AuthContext context,
    String id,
  ) async {
    final failure = _referenceAccess(context);
    if (failure != null) return Failed(failure);
    try {
      final row = await db
          .customSelect(
            'SELECT id, customer_code, name, mobile FROM service_customers '
            'WHERE company_id=? AND id=?',
            variables: [Variable(context.company.id), Variable(id)],
          )
          .getSingleOrNull();
      return Success(
        row == null
            ? null
            : ServiceCustomerRef(
                id: row.read<String>('id'),
                customerCode: row.read<String>('customer_code'),
                displayName: row.read<String>('name'),
                mobile: row.read<String>('mobile'),
              ),
      );
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<ServiceEnquirySiteRef?>> getSiteRefForEnquiry(
    AuthContext context,
    String id,
  ) async {
    final failure = _referenceAccess(context);
    if (failure != null) return Failed(failure);
    try {
      final row = await _siteRow(context.company.id, id);
      if (row == null) return const Success(null);
      return Success(
        ServiceEnquirySiteRef(
          id: row.read<String>('id'),
          siteCode: row.read<String>('site_code'),
          siteName: row.read<String>('site_name'),
          customerId: row.read<String>('customer_id'),
          tenantName: row.readNullable<String>('tenant_name'),
          buildingName: row.readNullable<String>('building_name'),
          unitNumber: row.readNullable<String>('unit_number'),
          addressSummary: [
            row.readNullable<String>('address_line1'),
            row.readNullable<String>('address_line2'),
            row.readNullable<String>('area'),
            row.readNullable<String>('city'),
            row.readNullable<String>('state'),
            row.readNullable<String>('postal_code'),
            row.readNullable<String>('country_code'),
          ].whereType<String>().where((s) => s.trim().isNotEmpty).join(', '),
          contactName: row.readNullable<String>('contact_name'),
          contactMobile: row.readNullable<String>('contact_mobile'),
        ),
      );
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  // ------------------------------------------------------------ persistence

  Future<void> _insertHeader(ServiceEnquiry e) => db
      .into(db.serviceEnquiries)
      .insert(
        ServiceEnquiriesCompanion.insert(
          id: e.id,
          companyId: e.companyId,
          enquiryNumber: e.enquiryNumber,
          customerId: e.customerId,
          siteId: e.siteId,
          serviceTypeId: e.serviceTypeId,
          complaintTypeId: e.complaintTypeId,
          priorityId: e.priorityId,
          ticketTypeId: e.ticketTypeId,
          // Legacy header description column is retained but unused; complaint
          // text now lives on the normalized detail lines.
          description: '',
          status: e.status.wire,
          partySnapshot: jsonEncode(e.partySnapshot.toJson()),
          searchText: Value(_searchText(e.enquiryNumber, e.partySnapshot)),
          materialReceived: Value(e.materialReceived.wire),
          version: Value(e.version),
          createdAt: e.createdAt,
          updatedAt: e.updatedAt,
          createdByUserId: e.createdByUserId,
          updatedByUserId: e.updatedByUserId,
          requestId: Value(e.requestId),
          syncStatus: e.syncStatus.name,
        ),
      );

  Future<void> _updateHeader(AuthContext context, ServiceEnquiry e) =>
      (db.update(db.serviceEnquiries)
            ..where((t) => t.id.equals(e.id) & t.companyId.equals(e.companyId)))
          .write(
            ServiceEnquiriesCompanion(
              customerId: Value(e.customerId),
              siteId: Value(e.siteId),
              serviceTypeId: Value(e.serviceTypeId),
              complaintTypeId: Value(e.complaintTypeId),
              priorityId: Value(e.priorityId),
              ticketTypeId: Value(e.ticketTypeId),
              materialReceived: Value(e.materialReceived.wire),
              status: Value(e.status.wire),
              partySnapshot: Value(jsonEncode(e.partySnapshot.toJson())),
              searchText: Value(_searchText(e.enquiryNumber, e.partySnapshot)),
              cancelReason: Value(e.cancelReason),
              cancelledAt: Value(e.cancelledAt),
              version: Value(e.version),
              updatedAt: Value(e.updatedAt),
              updatedByUserId: Value(e.updatedByUserId),
              syncStatus: const Value('pending'),
            ),
          );

  Future<void> _activity(
    AuthContext context,
    ServiceEnquiry e,
    String eventType,
  ) => activity.append(
    BusinessActivityEvent(
      id: _uuid.v4(),
      companyId: context.company.id,
      moduleKey: 'services',
      entityType: 'serviceEnquiry',
      entityId: e.id,
      eventType: eventType,
      occurredAt: clock.now(),
      actorUserId: context.user.id,
      actorEmployeeId: context.employeeReference?.id,
      syncStatus: 'pending',
      metadata: {
        'enquiryNumber': e.enquiryNumber,
        'status': e.status.wire,
        'customerId': e.customerId,
        'siteId': e.siteId,
        'serviceTypeId': e.serviceTypeId,
        'priorityId': e.priorityId,
        'detailCount': e.detailCount,
      },
    ),
  );

  Map<String, Object?> _detailPayload(ServiceEnquiryDetailLine line) => {
    'id': line.id,
    'lineNumber': line.lineNumber,
    'description': line.description,
    'status': line.status.wire,
    'attachments': [
      for (final attachment in line.attachments)
        {
          'id': attachment.id,
          'fileName': attachment.fileName,
          'mimeType': attachment.mimeType,
          'sizeBytes': attachment.sizeBytes,
          'category': attachment.category.value,
        },
    ],
  };

  Future<void> _enqueue(
    AuthContext context,
    ServiceEnquiry e,
    String operation,
    String requestId,
  ) => db
      .into(db.syncOutbox)
      .insert(
        SyncOutboxCompanion.insert(
          id: _uuid.v4(),
          moduleId: 'services',
          entityId: e.id,
          entityType: const Value('serviceEnquiry'),
          operation: operation,
          payload: jsonEncode({
            'id': e.id,
            'enquiryNumber': e.enquiryNumber,
            'status': e.status.wire,
            'customerId': e.customerId,
            'siteId': e.siteId,
            'serviceTypeId': e.serviceTypeId,
            'complaintTypeId': e.complaintTypeId,
            'priorityId': e.priorityId,
            'ticketTypeId': e.ticketTypeId,
            'materialReceived': e.materialReceived.wire,
            'version': e.version,
            'details': [for (final line in e.details) _detailPayload(line)],
          }),
          createdAt: e.updatedAt,
          companyId: Value(context.company.id),
          requestId: Value(requestId),
        ),
        mode: InsertMode.insertOrIgnore,
      );
}

class _EnquiryException implements Exception {
  const _EnquiryException(this.code);
  final String code;
}
