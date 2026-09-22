import '../../features/attendance/data/attendance_tables.dart';
import '../../features/shifts/data/shifts_table.dart';
import '../../features/work_locations/data/work_locations_table.dart';
import '../../features/attendance_policies/data/attendance_policies_table.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../../features/employees/data/employee_tables.dart';
part 'app_database.g.dart';

class SyncOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get moduleId => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get companyId => text().nullable()();
  TextColumn get requestId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get failureCode => text().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    SyncOutbox,
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
  int get schemaVersion => 5;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 1 || from > 4 || to != 5) {
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
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS outbox_request ON sync_outbox(request_id) WHERE request_id IS NOT NULL',
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
