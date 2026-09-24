import 'package:modular_erp/modules/hr/attendance/data/attendance_tables.dart';
import 'package:modular_erp/modules/hr/leave/data/leave_tables.dart';
import 'package:modular_erp/platform/notifications/data/notifications_table.dart';
import 'package:modular_erp/modules/hr/shifts/data/shifts_table.dart';
import 'package:modular_erp/modules/hr/work_locations/data/work_locations_table.dart';
import 'package:modular_erp/modules/hr/attendance_policies/data/attendance_policies_table.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:modular_erp/modules/hr/employees/data/employee_tables.dart';
import 'package:modular_erp/core/sync/sync_conflicts_table.dart';
import 'package:modular_erp/shared/transactions/data/transactions_tables.dart';
import 'package:modular_erp/platform/access/data/access_tables.dart';
import 'package:modular_erp/modules/services/data/services_tables.dart';
part 'app_database.g.dart';

class SyncOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get moduleId => text()();
  TextColumn get entityId => text()();
  TextColumn get entityType => text().nullable()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get companyId => text().nullable()();
  TextColumn get requestId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get failureCode => text().nullable()();
  TextColumn get lastFailureMessageSafe => text().nullable()();
  TextColumn get serverResponseMetadata => text().nullable()();
  IntColumn get payloadVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get processingStartedAt => dateTime().nullable()();
  TextColumn get processorId => text().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    SyncOutbox,
    SyncConflicts,
    AppNotifications,
    AttendanceDays,
    AttendanceEvents,
    AttendanceCorrectionRequests,
    WorkforceDepartments,
    WorkforceDesignations,
    WorkforceAccounts,
    WorkforceEmployees,
    WorkforceSeeds,
    ShiftRecords,
    WorkLocationRecords,
    AttendancePolicyRecords,
    LeaveTypes,
    LeavePolicies,
    EmployeeLeavePolicyAssignments,
    LeaveBalanceTransactions,
    LeaveRequests,
    LeaveRequestEvents,
    Holidays,
    HolidayCalendars,
    DocumentSequences,
    AttachmentRecords,
    BusinessActivityEvents,
    UserPermissionGrants,
    ServiceCustomers,
    ServiceSites,
    ServiceTeams,
    ServiceTeamMembers,
    ServiceTypes,
    ComplaintTypes,
    ServicePriorities,
    ServiceTicketTypes,
    ServiceEnquiries,
    ServiceEnquiryDetails,
    ServiceJobAssignments,
    ServiceJobAssignmentLines,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'modular_erp',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.dart.js'),
              ),
            ),
      );
  @override
  int get schemaVersion => 15;

  Future<bool> _tableExists(String name) async {
    final rows = await customSelect(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      variables: [Variable(name)],
    ).get();
    return rows.isNotEmpty;
  }

  /// Idempotent migration helpers keep upgrades safe even when a database was
  /// created at a newer schema and simulated backwards in tests.
  Future<void> _ensureTable<T extends Table, D>(
    Migrator m,
    TableInfo<T, D> table,
  ) async {
    if (await _tableExists(table.actualTableName)) return;
    await m.createTable(table);
  }

  Future<void> _ensureColumn<T extends Table, D extends Object>(
    Migrator m,
    TableInfo<T, D> table,
    GeneratedColumn<D> column,
  ) async {
    final rows = await customSelect(
      'PRAGMA table_info(${table.actualTableName})',
    ).get();
    if (rows.any((row) => row.read<String>('name') == column.name)) return;
    await m.addColumn(table, column);
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 1 || from > 14 || to != 15) {
        throw StateError('No migration registered from $from to $to');
      }
      if (from < 2) {
        await m.createTable(workforceDepartments);
        await m.createTable(workforceDesignations);
        await m.createTable(workforceAccounts);
        await m.createTable(workforceEmployees);
        await m.createTable(workforceSeeds);
      }
      if (from < 3) {
        await m.createTable(shiftRecords);
        await m.createTable(workLocationRecords);
        await m.createTable(attendancePolicyRecords);
      }
      if (from < 4) {
        await m.createTable(attendanceDays);
        await m.createTable(attendanceEvents);
        await m.addColumn(syncOutbox, syncOutbox.companyId);
        await m.addColumn(syncOutbox, syncOutbox.requestId);
        await m.addColumn(syncOutbox, syncOutbox.status);
        await m.addColumn(syncOutbox, syncOutbox.lastAttemptAt);
        await m.addColumn(syncOutbox, syncOutbox.failureCode);
      }
      if (from < 5) {
        await m.createTable(attendanceCorrectionRequests);
      }
      if (from < 6) {
        await _ensureTable(m, syncConflicts);
        await _ensureTable(m, appNotifications);
        await _ensureColumn(m, syncOutbox, syncOutbox.entityType);
        await _ensureColumn(m, syncOutbox, syncOutbox.nextAttemptAt);
        await _ensureColumn(m, syncOutbox, syncOutbox.lastFailureMessageSafe);
        await _ensureColumn(m, syncOutbox, syncOutbox.serverResponseMetadata);
        await _ensureColumn(m, syncOutbox, syncOutbox.payloadVersion);
        await _ensureColumn(m, syncOutbox, syncOutbox.processingStartedAt);
        await _ensureColumn(m, syncOutbox, syncOutbox.processorId);
      }
      if (from < 7) {
        await _ensureTable(m, leaveTypes);
        await _ensureTable(m, leavePolicies);
        await _ensureTable(m, employeeLeavePolicyAssignments);
        await _ensureTable(m, leaveBalanceTransactions);
        await _ensureTable(m, leaveRequests);
        await _ensureTable(m, leaveRequestEvents);
        await _ensureTable(m, holidays);
      }
      if (from < 8) {
        await _ensureTable(m, holidayCalendars);
        await _ensureColumn(m, holidays, holidays.source);
        await _ensureColumn(m, holidays, holidays.calendarId);
        await _ensureColumn(m, holidays, holidays.countryCode);
        await _ensureColumn(m, holidays, holidays.regionCode);
        // Normalize the legacy optionalHoliday category into an optional type.
        await customStatement(
          "UPDATE holidays SET type='companyHoliday', is_optional=1 WHERE type='optionalHoliday'",
        );
      }
      if (from < 9) {
        // Phase 0.4 shared transaction foundation.
        await _ensureTable(m, documentSequences);
        await _ensureTable(m, attachmentRecords);
        await _ensureTable(m, businessActivityEvents);
      }
      if (from < 10) {
        // Phase 0.5 explicit permission grants.
        await _ensureTable(m, userPermissionGrants);
      }
      if (from < 11) {
        // Access is permission-based: remove the legacy account role column.
        final columns = await customSelect(
          'PRAGMA table_info(workforce_accounts)',
        ).get();
        if (columns.any((row) => row.read<String>('name') == 'role')) {
          await customStatement(
            'ALTER TABLE workforce_accounts DROP COLUMN role',
          );
        }
      }
      if (from < 12) {
        // Services Phase 1: directory, teams and configuration masters.
        await _ensureTable(m, serviceCustomers);
        await _ensureTable(m, serviceSites);
        await _ensureTable(m, serviceTeams);
        await _ensureTable(m, serviceTeamMembers);
        await _ensureTable(m, serviceTypes);
        await _ensureTable(m, complaintTypes);
        await _ensureTable(m, servicePriorities);
        await _ensureTable(m, serviceTicketTypes);
      }
      if (from < 13) {
        // Services Phase 2: the Service Enquiry transaction.
        await _ensureTable(m, serviceEnquiries);
      }
      if (from < 14) {
        // Services Phase 2.1: enquiry detail lines, photos and Material Received.
        await _ensureColumn(
          m,
          serviceEnquiries,
          serviceEnquiries.materialReceived,
        );
        // Repair rows that existed before the column was added (an added column
        // leaves existing rows NULL rather than applying the Dart default).
        await customStatement(
          "UPDATE service_enquiries SET material_received='no' WHERE material_received IS NULL",
        );
        await _ensureTable(m, serviceEnquiryDetails);
        // Preserve existing Phase 2 Enquiries: copy each header description into
        // a single detail line so no historical complaint text is lost.
        await customStatement(
          "INSERT INTO service_enquiry_details "
          "(id, company_id, enquiry_id, line_number, description, status, "
          "created_at, updated_at, created_by_user_id, updated_by_user_id, sync_status) "
          "SELECT e.id || '-d1', e.company_id, e.id, 1, e.description, 'open', "
          "e.created_at, e.updated_at, e.created_by_user_id, e.updated_by_user_id, e.sync_status "
          "FROM service_enquiries e "
          "WHERE trim(e.description) <> '' "
          "AND NOT EXISTS (SELECT 1 FROM service_enquiry_details d WHERE d.enquiry_id = e.id)",
        );
      }
      if (from < 15) {
        // Services Phase 3: Job Assignment & Scheduling.
        await _ensureTable(m, serviceJobAssignments);
        await _ensureTable(m, serviceJobAssignmentLines);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // Idempotent repair: legacy service_enquiries rows may predate the
      // material_received column and read back as NULL. Normalize on every open
      // so a schema already migrated to v14 is healed too.
      await customStatement(
        "UPDATE service_enquiries SET material_received='no' WHERE material_received IS NULL",
      );
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS outbox_request ON sync_outbox(request_id) WHERE request_id IS NOT NULL',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS outbox_status_next ON sync_outbox(status, next_attempt_at)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS outbox_company_status ON sync_outbox(company_id, status, created_at)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS notification_user ON app_notifications(company_id, user_id, created_at)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS notification_unread ON app_notifications(company_id, user_id, read_at)',
      );
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS notification_dedupe ON app_notifications(company_id, user_id, dedupe_key) WHERE dedupe_key IS NOT NULL',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS conflict_company_status ON sync_conflicts(company_id, status, created_at)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS leave_types_company_status ON leave_types(company_id, status)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS leave_policies_company_status ON leave_policies(company_id, status)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS leave_requests_company_status ON leave_requests(company_id, status, start_date)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS leave_requests_company_employee ON leave_requests(company_id, employee_id, start_date)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS leave_ledger_account ON leave_balance_transactions(company_id, employee_id, leave_type_id, leave_year)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS holidays_company_date ON holidays(company_id, date)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS holiday_calendars_company_year ON holiday_calendars(company_id, year)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS leave_assignment_employee ON employee_leave_policy_assignments(company_id, employee_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS leave_request_events_request ON leave_request_events(company_id, request_id)',
      );
      await customStatement(
        "CREATE UNIQUE INDEX IF NOT EXISTS attendance_open ON attendance_days(company_id,employee_id) WHERE state != 'completed'",
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS attendance_current ON attendance_days(company_id,employee_id,state,attendance_date)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS attendance_timeline ON attendance_events(attendance_day_id,effective_milliseconds,sequence)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS attendance_sync ON attendance_events(company_id,sync_status)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS correction_company_status ON attendance_correction_requests(company_id,status,requested_milliseconds)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS correction_employee_status ON attendance_correction_requests(company_id,employee_id,status)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS correction_day ON attendance_correction_requests(company_id,attendance_day_id)',
      );
      for (final table in [
        'shift_records',
        'work_location_records',
        'attendance_policy_records',
      ]) {
        await customStatement(
          "CREATE UNIQUE INDEX IF NOT EXISTS ${table}_active_name ON $table(company_id, normalized_name) WHERE status='active'",
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS ${table}_company_status ON $table(company_id,status,name)',
        );
      }
      for (final column in [
        'shift_id',
        'work_location_id',
        'attendance_policy_id',
      ]) {
        await customStatement(
          'CREATE INDEX IF NOT EXISTS workforce_company_$column ON workforce_employees(company_id,$column)',
        );
      }

      await customStatement(
        'CREATE INDEX IF NOT EXISTS workforce_company_manager ON workforce_employees(company_id, manager_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS workforce_company_status ON workforce_employees(company_id, status, department_id, designation_id, employment_type)',
      );
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS document_sequences_company_key ON document_sequences(company_id, sequence_key)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS attachment_company_owner ON attachment_records(company_id, owner_type, owner_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS activity_company_entity ON business_activity_events(company_id, entity_type, entity_id, occurred_at)',
      );
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS permission_grant_unique ON user_permission_grants(company_id, user_id, permission_key)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS permission_grant_user ON user_permission_grants(company_id, user_id, is_active)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS service_customers_company_status ON service_customers(company_id, status, name)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS service_sites_company_customer ON service_sites(company_id, customer_id, status)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS service_teams_company_status ON service_teams(company_id, status, name)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS service_team_members_team ON service_team_members(company_id, team_id, status)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS service_team_members_employee ON service_team_members(company_id, employee_id)',
      );
      for (final table in [
        'service_types',
        'complaint_types',
        'service_priorities',
        'service_ticket_types',
      ]) {
        await customStatement(
          'CREATE INDEX IF NOT EXISTS ${table}_company_status ON $table(company_id, status, name)',
        );
      }
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS service_enquiries_company_number ON service_enquiries(company_id, enquiry_number)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS service_enquiries_company_status ON service_enquiries(company_id, status, created_at)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS service_enquiries_company_created ON service_enquiries(company_id, created_at)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS service_enquiries_company_customer ON service_enquiries(company_id, customer_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS service_enquiries_company_site ON service_enquiries(company_id, site_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS service_enquiry_details_company_enquiry ON service_enquiry_details(company_id, enquiry_id, line_number)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS service_enquiry_details_company ON service_enquiry_details(company_id, removed_at)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS service_job_assignments_company_status ON service_job_assignments(company_id, status, scheduled_visit_date)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS service_job_assignments_company_enquiry ON service_job_assignments(company_id, source_enquiry_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS service_job_assignments_company_visit ON service_job_assignments(company_id, scheduled_visit_date)',
      );
      // V1: at most one ACTIVE assignment per enquiry.
      await customStatement(
        "CREATE UNIQUE INDEX IF NOT EXISTS service_job_assignments_active_enquiry ON service_job_assignments(company_id, source_enquiry_id) WHERE status='active'",
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS service_job_assignment_lines_assignment ON service_job_assignment_lines(company_id, assignment_id, line_number)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS service_job_assignment_lines_employee ON service_job_assignment_lines(company_id, assigned_employee_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS service_job_assignment_lines_team ON service_job_assignment_lines(company_id, assigned_team_id)',
      );
    },
  );
}
