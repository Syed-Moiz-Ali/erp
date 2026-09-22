import 'package:drift/drift.dart';

@DataClassName('LeaveTypeData')
class LeaveTypes extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get name => text()();
  TextColumn get code => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get compensation => text().withDefault(const Constant('paid'))();
  BoolColumn get requiresApproval =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get allowsHalfDay => boolean().withDefault(const Constant(true))();
  BoolColumn get requiresReason =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get requiresAttachment =>
      boolean().withDefault(const Constant(false))();
  TextColumn get colorKey => text().withDefault(const Constant('annual'))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get createdMilliseconds => integer()();
  IntColumn get updatedMilliseconds => integer()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [
    {companyId, code},
  ];
}

@DataClassName('LeavePolicyData')
class LeavePolicies extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get name => text()();
  TextColumn get code => text()();
  TextColumn get leaveTypeId => text()();
  RealColumn get annualEntitlementDays =>
      real().withDefault(const Constant(0))();
  BoolColumn get allowHalfDay => boolean().withDefault(const Constant(true))();
  RealColumn get minimumRequestDays =>
      real().withDefault(const Constant(0.5))();
  IntColumn get maximumConsecutiveDays => integer().nullable()();
  IntColumn get advanceNoticeDays => integer().withDefault(const Constant(0))();
  BoolColumn get allowPastRequest =>
      boolean().withDefault(const Constant(false))();
  IntColumn get pastRequestWindowDays =>
      integer().withDefault(const Constant(0))();
  IntColumn get requiresAttachmentAfterDays => integer().nullable()();
  BoolColumn get allowNegativeBalance =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get carryForwardEnabled =>
      boolean().withDefault(const Constant(false))();
  RealColumn get carryForwardLimitDays => real().nullable()();
  TextColumn get applicableEmploymentTypes =>
      text().withDefault(const Constant('[]'))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get createdMilliseconds => integer()();
  IntColumn get updatedMilliseconds => integer()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [
    {companyId, code},
  ];
}

@DataClassName('EmployeeLeavePolicyAssignmentData')
class EmployeeLeavePolicyAssignments extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get employeeId => text()();
  TextColumn get policyId => text()();
  TextColumn get effectiveFrom => text()();
  TextColumn get effectiveTo => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get createdMilliseconds => integer()();
  IntColumn get updatedMilliseconds => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LeaveBalanceTransactionData')
class LeaveBalanceTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get employeeId => text()();
  TextColumn get leaveTypeId => text()();
  IntColumn get leaveYear => integer()();
  TextColumn get type => text()();
  RealColumn get quantityDays => real()();
  TextColumn get leaveRequestId => text().nullable()();
  TextColumn get reason => text().withDefault(const Constant(''))();
  TextColumn get createdBy => text()();
  TextColumn get effectiveDate => text()();
  IntColumn get createdMilliseconds => integer()();
  TextColumn get requestId => text().unique()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LeaveRequestData')
class LeaveRequests extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get employeeId => text()();
  TextColumn get typeSnapshot => text()();
  TextColumn get policySnapshot => text().nullable()();
  TextColumn get startDate => text()();
  TextColumn get endDate => text()();
  TextColumn get startPortion =>
      text().withDefault(const Constant('fullDay'))();
  TextColumn get endPortion => text().withDefault(const Constant('fullDay'))();
  RealColumn get requestedDays => real().withDefault(const Constant(0))();
  TextColumn get reason => text().withDefault(const Constant(''))();
  TextColumn get attachmentName => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get submittedMilliseconds => integer().nullable()();
  IntColumn get reviewedMilliseconds => integer().nullable()();
  TextColumn get reviewedBy => text().nullable()();
  TextColumn get reviewNote => text().nullable()();
  IntColumn get cancelledMilliseconds => integer().nullable()();
  TextColumn get cancelledBy => text().nullable()();
  TextColumn get cancellationReason => text().nullable()();
  IntColumn get createdMilliseconds => integer()();
  IntColumn get updatedMilliseconds => integer()();
  TextColumn get requestId => text().unique()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LeaveRequestEventData')
class LeaveRequestEvents extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get requestId => text()();
  TextColumn get type => text()();
  TextColumn get actorId => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get createdMilliseconds => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('HolidayData')
class Holidays extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get name => text()();
  TextColumn get date => text()();
  TextColumn get endDate => text().nullable()();
  TextColumn get type => text().withDefault(const Constant('companyHoliday'))();
  TextColumn get scope => text().withDefault(const Constant('companyWide'))();
  TextColumn get workLocationIds => text().withDefault(const Constant('[]'))();
  TextColumn get description => text().withDefault(const Constant(''))();
  BoolColumn get isOptional => boolean().withDefault(const Constant(false))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get createdMilliseconds => integer()();
  IntColumn get updatedMilliseconds => integer()();
  @override
  Set<Column> get primaryKey => {id};
}
