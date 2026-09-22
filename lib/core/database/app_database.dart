import '../../features/attendance/data/attendance_tables.dart';
import '../../features/leave/data/leave_tables.dart';
import '../../features/notifications/data/notifications_table.dart';
import '../../features/shifts/data/shifts_table.dart';
import '../../features/work_locations/data/work_locations_table.dart';
import '../../features/attendance_policies/data/attendance_policies_table.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../../features/employees/data/employee_tables.dart';
import '../sync/sync_conflicts_table.dart';
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
  int get schemaVersion => 7;

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
      if (from < 1 || from > 6 || to != 7) {
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
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
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
    },
  );
}
