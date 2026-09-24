import 'package:drift/drift.dart';

class WorkforceDepartments extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get name => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  @override
  Set<Column> get primaryKey => {id};
}

class WorkforceDesignations extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get name => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  @override
  Set<Column> get primaryKey => {id};
}

class WorkforceAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get displayName => text()();
  TextColumn get email => text()();
  TextColumn get phone => text()();
  TextColumn get grants => text()();
  TextColumn get status => text()();
  BoolColumn get credentialPending =>
      boolean().withDefault(const Constant(true))();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [
    {companyId, email},
    {companyId, phone},
  ];
}

@DataClassName('EmployeeRecord')
class WorkforceEmployees extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get employeeCode => text()();
  TextColumn get firstName => text()();
  TextColumn get middleName => text().withDefault(const Constant(''))();
  TextColumn get lastName => text().withDefault(const Constant(''))();
  TextColumn get email => text()();
  TextColumn get phone => text()();
  TextColumn get departmentId => text().references(WorkforceDepartments, #id)();
  TextColumn get designationId =>
      text().references(WorkforceDesignations, #id)();
  TextColumn get managerId =>
      text().nullable().references(WorkforceEmployees, #id)();
  DateTimeColumn get joiningDate => dateTime()();
  TextColumn get employmentType => text()();
  TextColumn get status => text()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get shiftId => text().nullable()();
  TextColumn get workLocationId => text().nullable()();
  TextColumn get attendancePolicyId => text().nullable()();
  TextColumn get linkedUserId =>
      text().nullable().references(WorkforceAccounts, #id)();
  BoolColumn get loginEnabled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [
    {companyId, employeeCode},
    {companyId, email},
    {companyId, phone},
    {linkedUserId},
  ];
}

class WorkforceSeeds extends Table {
  TextColumn get companyId => text()();
  IntColumn get version => integer()();
  @override
  Set<Column> get primaryKey => {companyId};
}
