import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/data/local_activity_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_document_number_service.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';
import 'package:modular_erp/shared/transactions/domain/document_number.dart';

/// Deterministic, idempotent Services demo seed. Master data and a small
/// directory so Services screens are demonstrable. Never a production default.
Future<void> seedServicesDemoData(
  AppDatabase db,
  AuthContext admin,
  AppClock clock,
) async {
  final companyId = admin.company.id;
  final now = clock.now();
  final existing = await (db.select(
    db.serviceTypes,
  )..where((t) => t.companyId.equals(companyId))).get();
  if (existing.isNotEmpty) return;

  Future<void> master(TableInfo table, Map<String, Object?> row) async {
    final columns =
        (await db
                .customSelect('PRAGMA table_info(${table.actualTableName})')
                .get())
            .map((r) => r.read<String>('name'))
            .toSet();
    final filtered = {
      for (final entry in row.entries)
        if (columns.contains(entry.key)) entry.key: entry.value,
    };
    await db.customInsert(
      'INSERT OR IGNORE INTO ${table.actualTableName} '
      '(${filtered.keys.join(',')}) VALUES (${filtered.keys.map((_) => '?').join(',')})',
      variables: [for (final v in filtered.values) Variable(v)],
    );
  }

  Map<String, Object?> baseMaster(
    String id,
    String code,
    String name, {
    int sort = 0,
  }) => {
    'id': id,
    'company_id': companyId,
    'code': code,
    'name': name,
    'status': 'active',
    'sort_order': sort,
    'created_at': now,
    'updated_at': now,
    'sync_status': 'synced',
  };

  await master(
    db.serviceTypes,
    baseMaster('demo-st-electrical', 'ELECTRICAL', 'Electrical', sort: 1),
  );
  await master(
    db.serviceTypes,
    baseMaster('demo-st-plumbing', 'PLUMBING', 'Plumbing', sort: 2),
  );
  await master(
    db.serviceTypes,
    baseMaster('demo-st-hvac', 'HVAC', 'HVAC', sort: 3),
  );
  await master(db.complaintTypes, {
    ...baseMaster('demo-ct-power', 'POWER', 'Power Issue', sort: 1),
    'service_type_id': 'demo-st-electrical',
  });
  await master(db.complaintTypes, {
    ...baseMaster('demo-ct-leak', 'LEAK', 'Water Leakage', sort: 2),
    'service_type_id': 'demo-st-plumbing',
  });
  await master(db.complaintTypes, {
    ...baseMaster('demo-ct-ac', 'AC', 'AC Not Cooling', sort: 3),
    'service_type_id': 'demo-st-hvac',
  });
  await master(db.servicePriorities, {
    ...baseMaster('demo-pr-normal', 'NORMAL', 'Normal', sort: 1),
    'rank': 1,
    'is_default': 1,
  });
  await master(db.servicePriorities, {
    ...baseMaster('demo-pr-high', 'HIGH', 'High', sort: 2),
    'rank': 2,
    'is_default': 0,
  });
  await master(db.servicePriorities, {
    ...baseMaster('demo-pr-urgent', 'URGENT', 'Urgent', sort: 3),
    'rank': 3,
    'is_default': 0,
  });
  await master(
    db.serviceTicketTypes,
    baseMaster('demo-tt-complaint', 'COMPLAINT', 'Complaint', sort: 1),
  );
  await master(
    db.serviceTicketTypes,
    baseMaster('demo-tt-request', 'REQUEST', 'Service Request', sort: 2),
  );

  Future<void> customer(
    String id,
    String code,
    String name,
    String mobile, {
    String kind = 'organization',
  }) async {
    await db
        .into(db.serviceCustomers)
        .insert(
          ServiceCustomersCompanion.insert(
            id: id,
            companyId: companyId,
            customerCode: code,
            name: name,
            kind: Value(kind),
            mobile: mobile,
            status: 'active',
            createdAt: now,
            updatedAt: now,
            createdByUserId: admin.user.id,
            updatedByUserId: admin.user.id,
            syncStatus: 'synced',
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  await customer(
    'demo-cus-abc',
    'CUS-000001',
    'ABC Properties',
    '+971500000101',
  );
  await customer(
    'demo-cus-gulf',
    'CUS-000002',
    'Gulf Tower Facility',
    '+971500000102',
  );

  Future<void> site(
    String id,
    String code,
    String name,
    String customerId,
    String building,
    String unit,
    String city,
  ) async {
    await db
        .into(db.serviceSites)
        .insert(
          ServiceSitesCompanion.insert(
            id: id,
            companyId: companyId,
            customerId: customerId,
            siteCode: code,
            siteName: name,
            buildingName: Value(building),
            unitNumber: Value(unit),
            addressLine1: '$building, Main Road',
            city: city,
            status: 'active',
            createdAt: now,
            updatedAt: now,
            createdByUserId: admin.user.id,
            updatedByUserId: admin.user.id,
            syncStatus: 'synced',
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  await site(
    'demo-site-abc-1',
    'SITE-000001',
    'ABC Tower 1',
    'demo-cus-abc',
    'ABC Tower',
    'Unit 1201',
    'Dubai',
  );
  await site(
    'demo-site-abc-2',
    'SITE-000002',
    'ABC Tower 2',
    'demo-cus-abc',
    'ABC Tower',
    'Unit 0804',
    'Dubai',
  );
  await site(
    'demo-site-gulf-1',
    'SITE-000003',
    'Gulf Tower Lobby',
    'demo-cus-gulf',
    'Gulf Tower',
    'Lobby',
    'Abu Dhabi',
  );

  final employees =
      await (db.select(db.workforceEmployees)
            ..where((t) => t.companyId.equals(companyId))
            ..limit(6))
          .get();
  final memberIds = [for (final e in employees) e.id];

  Future<void> team(
    String id,
    String code,
    String name,
    String? lead,
    List<String> members,
  ) async {
    await db
        .into(db.serviceTeams)
        .insert(
          ServiceTeamsCompanion.insert(
            id: id,
            companyId: companyId,
            teamCode: code,
            name: name,
            leadEmployeeId: Value(lead),
            status: 'active',
            createdAt: now,
            updatedAt: now,
            createdByUserId: admin.user.id,
            updatedByUserId: admin.user.id,
            syncStatus: 'synced',
          ),
          mode: InsertMode.insertOrIgnore,
        );
    for (final employeeId in members) {
      await db
          .into(db.serviceTeamMembers)
          .insert(
            ServiceTeamMembersCompanion.insert(
              id: '$id-$employeeId',
              companyId: companyId,
              teamId: id,
              employeeId: employeeId,
              status: 'active',
              createdAt: now,
              createdByUserId: admin.user.id,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  await team(
    'demo-team-electrical',
    'TEAM-000001',
    'Electrical Team',
    memberIds.isNotEmpty ? memberIds.first : null,
    memberIds.take(2).toList(),
  );
  await team(
    'demo-team-plumbing',
    'TEAM-000002',
    'Plumbing Team',
    memberIds.length > 2 ? memberIds[2] : null,
    memberIds.skip(2).take(2).toList(),
  );
}

/// Deterministic, idempotent Service Enquiry demo seed. Demonstrates different
/// customers/sites/priorities plus OPEN and CANCELLED states. Never seeds future
/// Job/Inspection records.
Future<void> seedServiceEnquiriesDemoData(
  AppDatabase db,
  AuthContext admin,
  AppClock clock,
) async {
  final companyId = admin.company.id;
  final existing = await (db.select(
    db.serviceEnquiries,
  )..where((t) => t.companyId.equals(companyId))).get();
  if (existing.isNotEmpty) return;

  Future<ServiceCustomerRow?> customer(String id) =>
      (db.select(db.serviceCustomers)
            ..where((t) => t.companyId.equals(companyId) & t.id.equals(id)))
          .getSingleOrNull();
  Future<ServiceSiteRow?> site(String id) =>
      (db.select(db.serviceSites)
            ..where((t) => t.companyId.equals(companyId) & t.id.equals(id)))
          .getSingleOrNull();

  final abc = await customer('demo-cus-abc');
  final gulf = await customer('demo-cus-gulf');
  final site1 = await site('demo-site-abc-1');
  final site2 = await site('demo-site-abc-2');
  final site3 = await site('demo-site-gulf-1');
  if (abc == null || gulf == null || site1 == null || site3 == null) return;

  final activity = LocalActivityRepository(db);
  final numbers = LocalDocumentNumberService(db, clock);
  final now = clock.now();

  ServiceEnquiryPartySnapshot snapshot(
    ServiceCustomerRow c,
    ServiceSiteRow s,
  ) => ServiceEnquiryPartySnapshot(
    customerName: c.name,
    customerCode: c.customerCode,
    customerMobile: c.mobile,
    siteName: s.siteName,
    tenantName: s.tenantName,
    buildingName: s.buildingName,
    unitNumber: s.unitNumber,
    addressSummary: [
      s.addressLine1,
      s.addressLine2,
      s.area,
      s.city,
      s.state,
      s.postalCode,
      s.countryCode,
    ].whereType<String>().where((v) => v.trim().isNotEmpty).join(', '),
    siteContactName: s.contactName,
    siteContactMobile: s.contactMobile,
  );

  Future<void> enquiry({
    required String id,
    required String number,
    required ServiceCustomerRow c,
    required ServiceSiteRow s,
    required String serviceTypeId,
    required String complaintTypeId,
    required String priorityId,
    required String ticketTypeId,
    required String description,
    required ServiceEnquiryStatus status,
    required DateTime createdAt,
    MaterialReceived materialReceived = MaterialReceived.no,
    List<({String description, ServiceEnquiryDetailStatus status})> details =
        const [],
    String? cancelReason,
  }) async {
    final party = snapshot(c, s);
    await db
        .into(db.serviceEnquiries)
        .insert(
          ServiceEnquiriesCompanion.insert(
            id: id,
            companyId: companyId,
            enquiryNumber: number,
            customerId: c.id,
            siteId: s.id,
            serviceTypeId: serviceTypeId,
            complaintTypeId: complaintTypeId,
            priorityId: priorityId,
            ticketTypeId: ticketTypeId,
            description: description,
            status: status.wire,
            partySnapshot: jsonEncode(party.toJson()),
            searchText: Value(
              [
                number,
                party.customerName,
                party.customerMobile,
                party.siteName,
                party.buildingName,
                party.unitNumber,
              ].whereType<String>().join(' ').toLowerCase(),
            ),
            materialReceived: Value(materialReceived.wire),
            cancelReason: Value(cancelReason),
            cancelledAt: Value(
              status.isCancelled
                  ? createdAt.add(const Duration(hours: 3))
                  : null,
            ),
            createdAt: createdAt,
            updatedAt: createdAt,
            createdByUserId: admin.user.id,
            updatedByUserId: admin.user.id,
            requestId: Value('demo-enquiry-$id'),
            syncStatus: 'synced',
          ),
          mode: InsertMode.insertOrIgnore,
        );
    var lineNumber = 0;
    for (final detail in details) {
      lineNumber++;
      await db
          .into(db.serviceEnquiryDetails)
          .insert(
            ServiceEnquiryDetailsCompanion.insert(
              id: '$id-d$lineNumber',
              companyId: companyId,
              enquiryId: id,
              lineNumber: lineNumber,
              description: detail.description,
              status: detail.status.wire,
              createdAt: createdAt,
              updatedAt: createdAt,
              createdByUserId: admin.user.id,
              updatedByUserId: admin.user.id,
              syncStatus: 'synced',
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
    await activity.append(
      BusinessActivityEvent(
        id: 'demo-activity-$id',
        companyId: companyId,
        moduleKey: 'services',
        entityType: 'serviceEnquiry',
        entityId: id,
        eventType: status.isCancelled
            ? 'services.enquiry.cancelled'
            : 'services.enquiry.created',
        occurredAt: createdAt,
        actorUserId: admin.user.id,
        syncStatus: 'synced',
        metadata: {
          'enquiryNumber': number,
          'status': status.wire,
          'detailCount': details.length,
        },
      ),
    );
  }

  await enquiry(
    id: 'demo-enq-1',
    number: 'ENQ-000001',
    c: abc,
    s: site1,
    serviceTypeId: 'demo-st-electrical',
    complaintTypeId: 'demo-ct-power',
    priorityId: 'demo-pr-high',
    ticketTypeId: 'demo-tt-complaint',
    description: 'Power outage reported in the main distribution board.',
    status: ServiceEnquiryStatus.open,
    createdAt: now.subtract(const Duration(days: 2, hours: 4)),
    details: [
      (
        description: 'Main distribution board tripped repeatedly.',
        status: ServiceEnquiryDetailStatus.open,
      ),
      (
        description: 'Emergency lighting did not activate during the outage.',
        status: ServiceEnquiryDetailStatus.open,
      ),
    ],
  );
  await enquiry(
    id: 'demo-enq-2',
    number: 'ENQ-000002',
    c: gulf,
    s: site3,
    serviceTypeId: 'demo-st-plumbing',
    complaintTypeId: 'demo-ct-leak',
    priorityId: 'demo-pr-urgent',
    ticketTypeId: 'demo-tt-complaint',
    description: 'Water leakage near the lobby entrance.',
    status: ServiceEnquiryStatus.open,
    createdAt: now.subtract(const Duration(hours: 5)),
    details: [
      (
        description: 'Continuous leak under the lobby washbasin.',
        status: ServiceEnquiryDetailStatus.open,
      ),
    ],
  );
  if (site2 != null) {
    await enquiry(
      id: 'demo-enq-3',
      number: 'ENQ-000003',
      c: abc,
      s: site2,
      serviceTypeId: 'demo-st-hvac',
      complaintTypeId: 'demo-ct-ac',
      priorityId: 'demo-pr-normal',
      ticketTypeId: 'demo-tt-request',
      description: 'AC unit is not cooling in the reception area.',
      status: ServiceEnquiryStatus.cancelled,
      createdAt: now.subtract(const Duration(days: 3, hours: 1)),
      cancelReason: 'Customer cancelled the request.',
      details: [
        (
          description: 'Indoor unit blowing warm air.',
          status: ServiceEnquiryDetailStatus.closed,
        ),
        (
          description: 'Outdoor unit making abnormal noise.',
          status: ServiceEnquiryDetailStatus.closed,
        ),
      ],
    );
  }
  await enquiry(
    id: 'demo-enq-4',
    number: 'ENQ-000004',
    c: gulf,
    s: site3,
    serviceTypeId: 'demo-st-electrical',
    complaintTypeId: 'demo-ct-power',
    priorityId: 'demo-pr-normal',
    ticketTypeId: 'demo-tt-complaint',
    description: 'Flickering lights in the common corridor.',
    status: ServiceEnquiryStatus.open,
    createdAt: now.subtract(const Duration(days: 1, hours: 2)),
    materialReceived: MaterialReceived.yes,
    details: [
      (
        description: 'Corridor lights flicker every few minutes.',
        status: ServiceEnquiryDetailStatus.open,
      ),
    ],
  );

  // Keep the local sequence ahead of the seeded display numbers.
  await numbers.adoptServerNumber(
    companyId: companyId,
    type: DocumentSequenceType.serviceEnquiry,
    displayNumber: 'ENQ-000004',
  );
}

/// Deterministic, idempotent Job Assignment demo seed built from the seeded
/// OPEN enquiries. Transitions those enquiries to ASSIGNED. Never seeds future
/// Inspection/Material/Execution records.
Future<void> seedServiceJobAssignmentDemoData(
  AppDatabase db,
  AuthContext admin,
  AppClock clock,
) async {
  final companyId = admin.company.id;
  final existing = await (db.select(
    db.serviceJobAssignments,
  )..where((t) => t.companyId.equals(companyId))).get();
  if (existing.isNotEmpty) return;

  final now = clock.now();
  final numbers = LocalDocumentNumberService(db, clock);
  final activity = LocalActivityRepository(db);

  final employees =
      await (db.select(db.workforceEmployees)
            ..where((t) => t.companyId.equals(companyId))
            ..limit(6))
          .get();
  if (employees.isEmpty) return;
  final employeeId = employees.first.id;

  final teams = await (db.select(
    db.serviceTeams,
  )..where((t) => t.companyId.equals(companyId))).get();
  final teamId = teams.isNotEmpty ? teams.first.id : null;

  Future<void> assign({
    required String id,
    required String number,
    required String enquiryId,
    required DateTime visitDate,
    required List<
      ({String work, String? employeeId, String? teamId, String description})
    >
    lines,
  }) async {
    final enquiry =
        await (db.select(db.serviceEnquiries)..where(
              (t) => t.companyId.equals(companyId) & t.id.equals(enquiryId),
            ))
            .getSingleOrNull();
    if (enquiry == null) return;
    await db
        .into(db.serviceJobAssignments)
        .insert(
          ServiceJobAssignmentsCompanion.insert(
            id: id,
            companyId: companyId,
            assignmentNumber: number,
            assignmentDate: now,
            sourceEnquiryId: enquiryId,
            scheduledVisitDate: visitDate,
            status: 'active',
            createdAt: now,
            updatedAt: now,
            createdByUserId: admin.user.id,
            updatedByUserId: admin.user.id,
            requestId: Value('demo-assignment-$id'),
            syncStatus: 'synced',
          ),
          mode: InsertMode.insertOrIgnore,
        );
    var lineNumber = 0;
    for (final line in lines) {
      lineNumber++;
      await db
          .into(db.serviceJobAssignmentLines)
          .insert(
            ServiceJobAssignmentLinesCompanion.insert(
              id: '$id-l$lineNumber',
              companyId: companyId,
              assignmentId: id,
              lineNumber: lineNumber,
              work: line.work,
              assignedEmployeeId: Value(line.employeeId),
              assignedTeamId: Value(line.teamId),
              status: 'pending',
              descriptionForWork: Value(line.description),
              createdAt: now,
              updatedAt: now,
              createdByUserId: admin.user.id,
              updatedByUserId: admin.user.id,
              syncStatus: 'synced',
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
    await db.customUpdate(
      "UPDATE service_enquiries SET status='assigned', updated_at=? "
      'WHERE company_id=? AND id=? AND status=\'open\'',
      variables: [Variable(now), Variable(companyId), Variable(enquiryId)],
    );
    await activity.append(
      BusinessActivityEvent(
        id: 'demo-assignment-activity-$id',
        companyId: companyId,
        moduleKey: 'services',
        entityType: 'serviceJobAssignment',
        entityId: id,
        eventType: 'services.jobAssignment.created',
        occurredAt: now,
        actorUserId: admin.user.id,
        syncStatus: 'synced',
        metadata: {'assignmentNumber': number, 'sourceEnquiryId': enquiryId},
      ),
    );
  }

  await assign(
    id: 'demo-ja-1',
    number: 'JA-000001',
    enquiryId: 'demo-enq-1',
    visitDate: DateTime.utc(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1)),
    lines: [
      (
        work: 'Inspect the distribution board and emergency lighting',
        employeeId: employeeId,
        teamId: teamId,
        description: 'Verify breakers, earthing and emergency light battery.',
      ),
      (
        work: 'Verify corridor lighting circuit',
        employeeId: null,
        teamId: teamId,
        description:
            'Check flickering corridor lights and replace faulty lamps.',
      ),
    ],
  );
  await assign(
    id: 'demo-ja-2',
    number: 'JA-000002',
    enquiryId: 'demo-enq-4',
    visitDate: DateTime.utc(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 2)),
    lines: [
      (
        work: 'Replace corridor light fittings',
        employeeId: null,
        teamId: teamId,
        description: 'Swap the flickering fittings and verify the circuit.',
      ),
    ],
  );

  await numbers.adoptServerNumber(
    companyId: companyId,
    type: DocumentSequenceType.serviceJobAssignment,
    displayNumber: 'JA-000002',
  );
}
