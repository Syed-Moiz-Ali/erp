import 'package:drift/drift.dart';

@DataClassName('ServiceCustomerRow')
class ServiceCustomers extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get customerCode => text()();
  TextColumn get name => text()();
  TextColumn get kind => text().withDefault(const Constant('individual'))();
  TextColumn get mobile => text()();
  TextColumn get alternateMobile => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get createdByUserId => text()();
  TextColumn get updatedByUserId => text()();
  TextColumn get syncStatus => text()();
  TextColumn get requestId => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, customerCode},
  ];
}

@DataClassName('ServiceSiteRow')
class ServiceSites extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get customerId => text()();
  TextColumn get siteCode => text()();
  TextColumn get siteName => text()();
  TextColumn get tenantName => text().nullable()();
  TextColumn get buildingName => text().nullable()();
  TextColumn get unitNumber => text().nullable()();
  TextColumn get contactName => text().nullable()();
  TextColumn get contactMobile => text().nullable()();
  TextColumn get contactEmail => text().nullable()();
  TextColumn get addressLine1 => text()();
  TextColumn get addressLine2 => text().nullable()();
  TextColumn get area => text().nullable()();
  TextColumn get city => text()();
  TextColumn get state => text().nullable()();
  TextColumn get postalCode => text().nullable()();
  TextColumn get countryCode => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get createdByUserId => text()();
  TextColumn get updatedByUserId => text()();
  TextColumn get syncStatus => text()();
  TextColumn get requestId => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, siteCode},
  ];
}

@DataClassName('ServiceTeamRow')
class ServiceTeams extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get teamCode => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get leadEmployeeId => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get createdByUserId => text()();
  TextColumn get updatedByUserId => text()();
  TextColumn get syncStatus => text()();
  TextColumn get requestId => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, teamCode},
  ];
}

@DataClassName('ServiceTeamMemberRow')
class ServiceTeamMembers extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get teamId => text()();
  TextColumn get employeeId => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get createdByUserId => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, teamId, employeeId},
  ];
}

/// Shared shape for the four Services master-data tables.
mixin ServiceMasterColumns on Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get status => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ServiceTypeRow')
class ServiceTypes extends Table with ServiceMasterColumns {
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, code},
  ];
}

@DataClassName('ComplaintTypeRow')
class ComplaintTypes extends Table with ServiceMasterColumns {
  TextColumn get serviceTypeId => text().nullable()();
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, code},
  ];
}

@DataClassName('ServicePriorityRow')
class ServicePriorities extends Table with ServiceMasterColumns {
  IntColumn get rank => integer().withDefault(const Constant(0))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, code},
  ];
}

@DataClassName('ServiceTicketTypeRow')
class ServiceTicketTypes extends Table with ServiceMasterColumns {
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, code},
  ];
}
