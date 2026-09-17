import 'package:drift/drift.dart';

class WorkLocationRecords extends Table {
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
  TextColumn get addressLine1 => text()();
  TextColumn get addressLine2 => text().withDefault(const Constant(''))();
  TextColumn get city => text()();
  TextColumn get stateRegion => text().withDefault(const Constant(''))();
  TextColumn get postalCode => text().withDefault(const Constant(''))();
  TextColumn get countryCode => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get allowedRadiusMeters => real()();
  RealColumn get maximumAccuracyMeters => real().nullable()();
  TextColumn get validationMode => text()();
}
