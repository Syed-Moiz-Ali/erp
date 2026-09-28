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

/// Services Phase 2 business transaction: the incoming service enquiry queue.
///
/// Customer/Site/Service Type/Complaint Type/Priority/Ticket Type are referenced
/// by id (authoritative relationship); [partySnapshot] preserves transaction-time
/// display context so later master edits do not misrepresent history.
@DataClassName('ServiceEnquiryRow')
class ServiceEnquiries extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get enquiryNumber => text()();
  TextColumn get customerId => text()();
  TextColumn get siteId => text()();
  TextColumn get serviceTypeId => text()();
  TextColumn get complaintTypeId => text()();
  TextColumn get priorityId => text()();
  TextColumn get ticketTypeId => text()();
  TextColumn get description => text()();
  TextColumn get status => text()();

  /// Header-level "Material Received" flag (TBD semantics). `no`/`yes`.
  TextColumn get materialReceived => text().withDefault(const Constant('no'))();
  TextColumn get partySnapshot => text()();

  /// Lower-cased concatenation of the snapshot's searchable fields
  /// (customer name/mobile, site name, building, unit, enquiry number). Kept as
  /// a plain column so list search stays a single indexed-friendly LIKE without
  /// depending on SQLite JSON1 being compiled in.
  TextColumn get searchText => text().withDefault(const Constant(''))();
  TextColumn get cancelReason => text().nullable()();
  DateTimeColumn get cancelledAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get createdByUserId => text()();
  TextColumn get updatedByUserId => text()();
  TextColumn get requestId => text().nullable()();
  TextColumn get syncStatus => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, enquiryNumber},
    {companyId, requestId},
  ];
}

/// A normalized Service Enquiry detail line (child of [ServiceEnquiries]).
///
/// Each line has a stable UUID identity, a description, its own status and
/// zero-or-more photo attachments (owned via the shared attachment table with
/// `ownerType = serviceEnquiryDetail`). Lines are soft-removed (`removedAt`),
/// never hard-deleted, so an Enquiry stays historically resolvable.
@DataClassName('ServiceEnquiryDetailRow')
class ServiceEnquiryDetails extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get enquiryId => text()();
  IntColumn get lineNumber => integer()();
  TextColumn get description => text()();
  TextColumn get status => text()();
  DateTimeColumn get removedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get createdByUserId => text()();
  TextColumn get updatedByUserId => text()();
  TextColumn get syncStatus => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Services Phase 3 business transaction: Job Assignment & Scheduling.
///
/// V1 enforces **one ACTIVE assignment per Service Enquiry** (partial unique
/// index). It references the source enquiry (customer/site/priority context is
/// read from the enquiry, never re-typed) and carries 1..N work lines.
@DataClassName('ServiceJobAssignmentRow')
class ServiceJobAssignments extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get assignmentNumber => text()();
  DateTimeColumn get assignmentDate => dateTime()();
  TextColumn get sourceEnquiryId => text()();
  DateTimeColumn get scheduledVisitDate => dateTime()();
  TextColumn get status => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  /// Lower-cased concatenation of searchable fields (assignment/enquiry number,
  /// customer/mobile/site/building/unit, assigned employee/team names) so list
  /// search stays one indexed-friendly LIKE.
  TextColumn get searchText => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get createdByUserId => text()();
  TextColumn get updatedByUserId => text()();
  TextColumn get requestId => text().nullable()();
  TextColumn get syncStatus => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, assignmentNumber},
    {companyId, requestId},
  ];
}

/// A single work item inside a [ServiceJobAssignments] aggregate.
///
/// A line may target an Employee, a Service Team, or both. Lines are soft-removed
/// (`removedAt`) so the assignment stays historically resolvable.
@DataClassName('ServiceJobAssignmentLineRow')
class ServiceJobAssignmentLines extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get assignmentId => text()();
  IntColumn get lineNumber => integer()();
  TextColumn get work => text()();
  TextColumn get assignedEmployeeId => text().nullable()();
  TextColumn get assignedTeamId => text().nullable()();
  TextColumn get status => text()();
  TextColumn get descriptionForWork => text().withDefault(const Constant(''))();
  DateTimeColumn get removedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get createdByUserId => text()();
  TextColumn get updatedByUserId => text()();
  TextColumn get syncStatus => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ServiceRootCauseRow')
class ServiceRootCauses extends Table with ServiceMasterColumns {
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, code},
  ];
}

@DataClassName('ServiceChargeResponsibilityRow')
class ServiceChargeResponsibilities extends Table with ServiceMasterColumns {
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, code},
  ];
}

/// Services Phase 4: the Service Inspection transaction (header).
///
/// One non-cancelled Inspection per active Job Assignment (V1, partial unique
/// index). Customer/site/priority context is read from the source Enquiry.
@DataClassName('ServiceInspectionRow')
class ServiceInspections extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get inspectionNumber => text()();
  DateTimeColumn get inspectionDate => dateTime()();
  TextColumn get sourceJobAssignmentId => text()();
  TextColumn get sourceEnquiryId => text()();
  DateTimeColumn get visitDate => dateTime()();

  /// Minutes-of-day (company-local), a typed time-only value.
  IntColumn get visitMinutes => integer().nullable()();
  TextColumn get technicianEmployeeId => text().nullable()();
  TextColumn get rootCauseId => text().nullable()();
  TextColumn get chargeResponsibilityId => text().nullable()();
  TextColumn get status => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get searchText => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get createdByUserId => text()();
  TextColumn get updatedByUserId => text()();
  TextColumn get requestId => text().nullable()();
  TextColumn get syncStatus => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, inspectionNumber},
    {companyId, requestId},
  ];
}

@DataClassName('ServiceInspectionChecklistItemRow')
class ServiceInspectionChecklistItems extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get inspectionId => text()();
  TextColumn get sourceJobAssignmentLineId => text().nullable()();
  IntColumn get lineNumber => integer()();
  TextColumn get workType => text()();
  TextColumn get descriptionForWork => text().withDefault(const Constant(''))();
  TextColumn get status => text()();
  DateTimeColumn get removedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get createdByUserId => text()();
  TextColumn get updatedByUserId => text()();
  TextColumn get syncStatus => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ServiceInspectionPointRow')
class ServiceInspectionPoints extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get inspectionId => text()();
  IntColumn get lineNumber => integer()();
  TextColumn get description => text()();
  DateTimeColumn get removedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ServiceInspectionMaterialRequirementRow')
class ServiceInspectionMaterialRequirements extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get inspectionId => text()();
  IntColumn get lineNumber => integer()();
  TextColumn get code => text()();
  TextColumn get description => text()();
  TextColumn get status => text()();
  DateTimeColumn get removedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Services Phase 5 configuration master: configurable Material Request Purpose.
@DataClassName('ServiceMaterialRequestPurposeRow')
class ServiceMaterialRequestPurposes extends Table with ServiceMasterColumns {
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, code},
  ];
}

/// Services Phase 5: the Request for Material transaction (header).
///
/// References a completed source Inspection (lineage to Job Assignment and
/// Enquiry is preserved). Intentionally stores NO editable `materialReceived`:
/// that value is owned by the Service Enquiry and only inherited for display.
@DataClassName('ServiceMaterialRequestRow')
class ServiceMaterialRequests extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get requestNumber => text()();
  DateTimeColumn get requestDate => dateTime()();
  TextColumn get sourceInspectionId => text()();
  TextColumn get sourceJobAssignmentId => text()();
  TextColumn get sourceEnquiryId => text()();

  /// Optional free-text business/reference value. NOT an authoritative FK; no
  /// Job Order entity is created (authoritative owner is TBD).
  TextColumn get jobOrderReference => text().nullable()();
  TextColumn get purposeId => text().nullable()();

  /// Safe optional metadata (exact client semantics TBD). Never drives state.
  TextColumn get acknowledgement => text().nullable()();

  /// Safe optional free text (identity type TBD — no relationship).
  TextColumn get receivedBy => text().nullable()();
  TextColumn get remarks => text().nullable()();
  TextColumn get status => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get searchText => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get createdByUserId => text()();
  TextColumn get updatedByUserId => text()();
  TextColumn get requestId => text().nullable()();
  TextColumn get syncStatus => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, requestNumber},
    {companyId, requestId},
  ];
}

/// A single requested material line inside a [ServiceMaterialRequests] aggregate.
///
/// [sourceInspectionMaterialRequirementId] preserves lineage to the Inspection
/// material requirement (null for manual lines). [activeRequirementId] is an
/// internal linkage column maintained by the repository: it mirrors the source
/// requirement while the owning request is OPEN and is cleared on cancellation,
/// enabling a partial unique index that guarantees a requirement is linked to at
/// most one ACTIVE request. Lines are reconciled by stable UUID identity.
@DataClassName('ServiceMaterialRequestLineRow')
class ServiceMaterialRequestLines extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get materialRequestId => text()();
  TextColumn get sourceInspectionMaterialRequirementId => text().nullable()();
  TextColumn get activeRequirementId => text().nullable()();
  IntColumn get lineNumber => integer()();
  TextColumn get code => text()();
  TextColumn get description => text()();
  TextColumn get batchNumber => text().nullable()();
  RealColumn get quantity => real()();
  TextColumn get remark => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Services Phase 6: the Work Execution transaction (header).
///
/// The primary source is a COMPLETED Inspection; the Job Assignment and Enquiry
/// are derived through its lineage and never selected independently. Customer/
/// site context is read from the source Enquiry, never duplicated here.
@DataClassName('ServiceWorkExecutionRow')
class ServiceWorkExecutions extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get executionNumber => text()();
  DateTimeColumn get executionDate => dateTime()();
  TextColumn get sourceInspectionId => text()();
  TextColumn get sourceJobAssignmentId => text()();
  TextColumn get sourceEnquiryId => text()();

  /// Optional free-text compatibility references. NOT authoritative foreign
  /// keys; no JobOrder/Quotation entity is created (owner/source is TBD).
  TextColumn get jobOrderReference => text().nullable()();
  TextColumn get quotationReference => text().nullable()();
  TextColumn get status => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get searchText => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get createdByUserId => text()();
  TextColumn get updatedByUserId => text()();
  TextColumn get requestId => text().nullable()();
  TextColumn get syncStatus => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, executionNumber},
    {companyId, requestId},
  ];
}

/// A single work item inside a [ServiceWorkExecutions] aggregate.
///
/// [sourceJobAssignmentLineId] preserves lineage to the prefilled Job Assignment
/// line (null for manually added lines). Start/end timestamps are nullable;
/// there is deliberately NO stored duration field — state and duration are
/// derived from the timestamps.
@DataClassName('ServiceWorkExecutionLineRow')
class ServiceWorkExecutionLines extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get workExecutionId => text()();
  TextColumn get sourceJobAssignmentLineId => text().nullable()();
  IntColumn get lineNumber => integer()();
  TextColumn get work => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get serviceTeamId => text().nullable()();
  TextColumn get employeeId => text().nullable()();
  DateTimeColumn get startedAtUtc => dateTime().nullable()();
  DateTimeColumn get endedAtUtc => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// A single "Material Used" record inside a [ServiceWorkExecutions] aggregate.
///
/// Intentionally stores only Code and Description. There is NO quantity, batch,
/// UOM or cost column and no inventory/stock side effect.
@DataClassName('ServiceWorkExecutionMaterialUsedRow')
class ServiceWorkExecutionMaterialsUsed extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get workExecutionId => text()();
  TextColumn get sourceMaterialRequestLineId => text().nullable()();
  IntColumn get lineNumber => integer()();
  TextColumn get code => text()();
  TextColumn get description => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  String get tableName => 'service_work_execution_materials_used';
}

/// A single "Photos After Work" evidence entry inside a [ServiceWorkExecutions]
/// aggregate. The description is a real field; the images live in the shared
/// attachment table (`ownerType = serviceWorkExecutionPhotoEntry`,
/// `category = afterWorkPhoto`).
@DataClassName('ServiceWorkExecutionPhotoEntryRow')
class ServiceWorkExecutionPhotoEntries extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get workExecutionId => text()();
  IntColumn get lineNumber => integer()();
  TextColumn get description => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}
