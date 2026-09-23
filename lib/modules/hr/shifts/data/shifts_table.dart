import 'package:drift/drift.dart';

class ShiftRecords extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text()();
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get code => text().nullable()();
  IntColumn get startMinutes => integer()();
  IntColumn get endMinutes => integer()();
  IntColumn get workingDayMask => integer()();
  IntColumn get gracePeriodMinutes => integer()();
  TextColumn get breakMode => text()();
  IntColumn get defaultBreakMinutes => integer().nullable()();
  IntColumn get minimumWorkMinutes => integer().nullable()();
}
