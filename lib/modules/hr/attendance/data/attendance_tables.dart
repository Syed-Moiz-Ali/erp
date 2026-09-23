import 'package:drift/drift.dart';

@DataClassName('AttendanceDayData')
class AttendanceDays extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get employeeId => text()();
  TextColumn get attendanceDate => text()();
  TextColumn get shiftId => text()();
  TextColumn get policyId => text()();
  TextColumn get workLocationId => text().nullable()();
  TextColumn get configurationSnapshot => text()();
  TextColumn get state => text()();
  IntColumn get punchInMilliseconds => integer().nullable()();
  IntColumn get punchOutMilliseconds => integer().nullable()();
  IntColumn get elapsedMilliseconds =>
      integer().withDefault(const Constant(0))();
  IntColumn get breakMilliseconds => integer().withDefault(const Constant(0))();
  IntColumn get workMilliseconds => integer().withDefault(const Constant(0))();
  TextColumn get status => text()();
  TextColumn get syncStatus => text()();
  IntColumn get createdMilliseconds => integer()();
  IntColumn get updatedMilliseconds => integer()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [
    {companyId, employeeId, attendanceDate},
  ];
}

@DataClassName('AttendanceEventData')
class AttendanceEvents extends Table {
  TextColumn get id => text()();
  TextColumn get attendanceDayId => text().references(AttendanceDays, #id)();
  TextColumn get companyId => text()();
  TextColumn get employeeId => text()();
  TextColumn get eventType => text()();
  IntColumn get deviceMilliseconds => integer()();
  IntColumn get serverMilliseconds => integer().nullable()();
  IntColumn get effectiveMilliseconds => integer()();
  IntColumn get sequence => integer()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get accuracyMeters => real().nullable()();
  IntColumn get capturedMilliseconds => integer().nullable()();
  TextColumn get permissionState => text().nullable()();
  TextColumn get workLocationId => text().nullable()();
  TextColumn get locationValidation => text()();
  TextColumn get requestId => text().unique()();
  TextColumn get source => text()();
  TextColumn get syncStatus => text()();
  IntColumn get createdMilliseconds => integer()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [
    {attendanceDayId, sequence},
  ];
}

@DataClassName('AttendanceCorrectionRequestData')
class AttendanceCorrectionRequests extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get employeeId => text()();
  TextColumn get attendanceDayId => text()();
  TextColumn get requestType => text()();
  TextColumn get status => text()();
  TextColumn get reason => text()();
  TextColumn get originalSnapshot => text()();
  TextColumn get requestedChanges => text()();
  TextColumn get requestedByUserId => text()();
  IntColumn get requestedMilliseconds => integer()();
  TextColumn get reviewedByUserId => text().nullable()();
  IntColumn get reviewedMilliseconds => integer().nullable()();
  TextColumn get reviewNote => text().nullable()();
  TextColumn get syncStatus => text()();
  IntColumn get createdMilliseconds => integer()();
  IntColumn get updatedMilliseconds => integer()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [
    {companyId, id},
  ];
}
