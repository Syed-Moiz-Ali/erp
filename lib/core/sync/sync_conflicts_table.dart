import 'package:drift/drift.dart';

@DataClassName('SyncConflictData')
class SyncConflicts extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operationId => text().nullable()();
  TextColumn get conflictType => text()();
  TextColumn get localSnapshot => text().withDefault(const Constant('{}'))();
  TextColumn get remoteSnapshotSafe => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  @override
  Set<Column> get primaryKey => {id};
}
