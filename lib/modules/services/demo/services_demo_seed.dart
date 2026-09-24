import 'package:drift/drift.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

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
