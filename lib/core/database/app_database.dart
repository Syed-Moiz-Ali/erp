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
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    SyncOutbox,
    WorkforceDepartments,
    WorkforceDesignations,
    WorkforceAccounts,
    WorkforceEmployees,
    WorkforceSeeds,
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
  int get schemaVersion => 2;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from == 1 && to == 2) {
        await m.createTable(workforceDepartments);
        await m.createTable(workforceDesignations);
        await m.createTable(workforceAccounts);
        await m.createTable(workforceEmployees);
        await m.createTable(workforceSeeds);
      } else {
        throw StateError('No migration registered from $from to $to');
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement(
        'CREATE INDEX IF NOT EXISTS workforce_company_manager ON workforce_employees(company_id, manager_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS workforce_company_status ON workforce_employees(company_id, status, department_id, designation_id, employment_type)',
      );
    },
  );
}
