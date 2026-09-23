import 'package:drift/drift.dart';

class AttendancePolicyRecords extends Table {
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
  TextColumn get description => text().withDefault(const Constant(''))();
  BoolColumn get requireLocation => boolean()();
  BoolColumn get allowOutsideLocation => boolean()();
  BoolColumn get allowRemoteAttendance => boolean()();
  BoolColumn get requireLocationOnPunchIn => boolean()();
  BoolColumn get requireLocationOnPunchOut => boolean()();
  BoolColumn get requireLocationOnBreak => boolean()();
  BoolColumn get requireLocationAccuracy => boolean()();
  RealColumn get maximumAcceptedAccuracyMeters => real().nullable()();
  BoolColumn get trackBreaks => boolean()();
  BoolColumn get allowMultipleBreaks => boolean()();
  BoolColumn get allowPunchOutDuringBreak => boolean()();
  BoolColumn get allowEmployeeCorrectionRequest => boolean()();
  BoolColumn get allowEarlyPunchIn => boolean()();
  IntColumn get earlyPunchInLimitMinutes => integer().nullable()();
  BoolColumn get allowLatePunchIn => boolean()();
  BoolColumn get allowEarlyPunchOut => boolean()();
  TextColumn get offlineMode => text()();
}
