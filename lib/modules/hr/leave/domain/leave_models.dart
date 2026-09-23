import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';

part 'leave_models.freezed.dart';
part 'leave_models.g.dart';

/// Normalizes a business (date-only) value to a UTC midnight date, matching the
/// attendance workday convention. Leave has no time-of-day semantics.
DateTime leaveDate(DateTime value) =>
    DateTime.utc(value.year, value.month, value.day);

enum LeaveCompensationType { paid, unpaid, informational }

enum LeaveRequestStatus { pending, approved, rejected, cancelled }

enum LeaveDayPortion { fullDay, firstHalf, secondHalf }

enum LeaveBalanceTransactionType {
  entitlement,
  adjustmentAdd,
  adjustmentSubtract,
  leaveReserved,
  leaveReleased,
  leaveConsumed,
  carryForward,
  expiry,
  migration,
}

/// What a holiday *is*. Optionality is modelled separately by `isOptional`.
enum HolidayType {
  publicHoliday,
  festivalHoliday,
  regionalHoliday,
  companyHoliday,
  specialClosure,
}

/// Where a holiday entry came from. Never an authoritative government feed.
enum HolidaySource { manual, copiedFromPreviousYear, imported, companyTemplate }

enum HolidayScope { companyWide, specificWorkLocations }

/// Higher-level interpretation of a scheduled workday. Attendance events keep
/// their own state machine; this classification adds Leave/Holiday meaning
/// without contaminating it.
enum WorkdayClassification {
  scheduledNoRecord,
  working,
  onBreak,
  completed,
  incomplete,
  approvedLeave,
  holiday,
  nonWorkingDay,
  issue,
}

/// A leave/holiday overlay for a scheduled workday. Attendance remains the
/// source of truth for events; this only adds meaning for display.
class LeaveWorkdayOverlay {
  const LeaveWorkdayOverlay({required this.classification, this.text = ''});
  final WorkdayClassification classification;
  final String text;
}

@freezed
abstract class LeaveType with _$LeaveType implements ConfigurationRecord {
  const factory LeaveType({
    required String id,
    required String companyId,
    required String name,
    required String code,
    @Default('') String description,
    @Default(LeaveCompensationType.paid) LeaveCompensationType compensation,
    @Default(true) bool requiresApproval,
    @Default(true) bool allowsHalfDay,
    @Default(true) bool requiresReason,
    @Default(false) bool requiresAttachment,
    @Default('annual') String colorKey,
    @Default(ConfigurationStatus.active) ConfigurationStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(RecordSyncStatus.pending) RecordSyncStatus syncStatus,
  }) = _LeaveType;
  factory LeaveType.fromJson(Map<String, dynamic> json) =>
      _$LeaveTypeFromJson(json);
}

@freezed
abstract class LeavePolicy with _$LeavePolicy implements ConfigurationRecord {
  const factory LeavePolicy({
    required String id,
    required String companyId,
    required String name,
    required String code,
    required String leaveTypeId,
    @Default(0) double annualEntitlementDays,
    @Default(true) bool allowHalfDay,
    @Default(0.5) double minimumRequestDays,
    int? maximumConsecutiveDays,
    @Default(0) int advanceNoticeDays,
    @Default(false) bool allowPastRequest,
    @Default(0) int pastRequestWindowDays,
    int? requiresAttachmentAfterDays,
    @Default(false) bool allowNegativeBalance,
    @Default(false) bool carryForwardEnabled,
    double? carryForwardLimitDays,
    @Default(<EmploymentType>{}) Set<EmploymentType> applicableEmploymentTypes,
    @Default(ConfigurationStatus.active) ConfigurationStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(RecordSyncStatus.pending) RecordSyncStatus syncStatus,
  }) = _LeavePolicy;
  factory LeavePolicy.fromJson(Map<String, dynamic> json) =>
      _$LeavePolicyFromJson(json);
}

@freezed
abstract class Holiday with _$Holiday implements ConfigurationRecord {
  const factory Holiday({
    required String id,
    required String companyId,
    required String name,
    required DateTime date,
    DateTime? endDate,
    @Default(HolidayType.companyHoliday) HolidayType type,
    @Default(HolidayScope.companyWide) HolidayScope scope,
    @Default(<String>{}) Set<String> workLocationIds,
    @Default('') String description,
    @Default(false) bool isOptional,
    @Default(HolidaySource.manual) HolidaySource source,
    String? calendarId,
    String? countryCode,
    String? regionCode,
    @Default(ConfigurationStatus.active) ConfigurationStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(RecordSyncStatus.pending) RecordSyncStatus syncStatus,
  }) = _Holiday;
  factory Holiday.fromJson(Map<String, dynamic> json) =>
      _$HolidayFromJson(json);
}

/// A company's annual holiday calendar. Year management is first-class so a new
/// year can be set up, copied or imported deliberately rather than silently.
class HolidayCalendar {
  const HolidayCalendar({
    required this.id,
    required this.companyId,
    required this.name,
    required this.year,
    this.countryCode,
    this.regionCode,
    this.isDefault = false,
    this.status = ConfigurationStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id, companyId, name;
  final int year;
  final String? countryCode, regionCode;
  final bool isDefault;
  final ConfigurationStatus status;
  final DateTime createdAt, updatedAt;
}

@freezed
abstract class LeaveTypeSnapshot with _$LeaveTypeSnapshot {
  const factory LeaveTypeSnapshot({
    required String typeId,
    required String name,
    required String code,
    @Default(LeaveCompensationType.paid) LeaveCompensationType compensation,
    @Default(true) bool requiresReason,
    @Default(false) bool requiresAttachment,
    @Default(true) bool allowsHalfDay,
  }) = _LeaveTypeSnapshot;
  factory LeaveTypeSnapshot.fromJson(Map<String, dynamic> json) =>
      _$LeaveTypeSnapshotFromJson(json);
}

@freezed
abstract class LeavePolicySnapshot with _$LeavePolicySnapshot {
  const factory LeavePolicySnapshot({
    required String policyId,
    required String name,
    required String code,
    @Default(0) double annualEntitlementDays,
    @Default(true) bool allowHalfDay,
    @Default(false) bool allowNegativeBalance,
  }) = _LeavePolicySnapshot;
  factory LeavePolicySnapshot.fromJson(Map<String, dynamic> json) =>
      _$LeavePolicySnapshotFromJson(json);
}

@freezed
abstract class LeaveRequest with _$LeaveRequest {
  const LeaveRequest._();
  bool get isPending => status == LeaveRequestStatus.pending;
  bool get isFullDay =>
      startPortion == LeaveDayPortion.fullDay &&
      endPortion == LeaveDayPortion.fullDay;
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory LeaveRequest({
    required String id,
    required String companyId,
    required String employeeId,
    required LeaveTypeSnapshot typeSnapshot,
    LeavePolicySnapshot? policySnapshot,
    required DateTime startDate,
    required DateTime endDate,
    @Default(LeaveDayPortion.fullDay) LeaveDayPortion startPortion,
    @Default(LeaveDayPortion.fullDay) LeaveDayPortion endPortion,
    required double requestedDays,
    @Default('') String reason,
    String? attachmentName,
    @Default(LeaveRequestStatus.pending) LeaveRequestStatus status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? reviewNote,
    DateTime? cancelledAt,
    String? cancelledBy,
    String? cancellationReason,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String requestId,
    @Default('pending') String syncStatus,
  }) = _LeaveRequest;
  factory LeaveRequest.fromJson(Map<String, dynamic> json) =>
      _$LeaveRequestFromJson(json);
}

@freezed
abstract class LeaveBalanceTransaction with _$LeaveBalanceTransaction {
  const factory LeaveBalanceTransaction({
    required String id,
    required String companyId,
    required String employeeId,
    required String leaveTypeId,
    required int leaveYear,
    required LeaveBalanceTransactionType type,
    required double quantityDays,
    String? leaveRequestId,
    @Default('') String reason,
    required String createdBy,
    required DateTime effectiveDate,
    required DateTime createdAt,
    required String requestId,
    @Default('pending') String syncStatus,
  }) = _LeaveBalanceTransaction;
  factory LeaveBalanceTransaction.fromJson(Map<String, dynamic> json) =>
      _$LeaveBalanceTransactionFromJson(json);
}

/// Ledger-derived balance for one employee + leave type + leave year.
class LeaveBalanceSummary {
  const LeaveBalanceSummary({
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.compensation,
    required this.entitlement,
    required this.used,
    required this.pending,
  });
  final String leaveTypeId, leaveTypeName;
  final LeaveCompensationType compensation;
  final double entitlement, used, pending;
  double get available => entitlement - used - pending;
}

class LeaveRequestRow {
  const LeaveRequestRow({
    required this.request,
    required this.employeeName,
    required this.employeeCode,
    required this.department,
    this.departmentId = '',
    this.designation = '',
    this.managerName = '',
  });
  final LeaveRequest request;
  final String employeeName, employeeCode, department;
  final String departmentId, designation, managerName;
}

enum LeaveCalendarKind { leave, holiday }

class LeaveCalendarEntry {
  const LeaveCalendarEntry({
    required this.date,
    required this.kind,
    required this.title,
    this.leaveTypeName,
    this.status,
    this.employeeName,
    this.requestId,
  });
  final DateTime date;
  final LeaveCalendarKind kind;
  final String title;
  final String? leaveTypeName, employeeName;
  final LeaveRequestStatus? status;
  final String? requestId;
}

class LeaveRequestPage {
  LeaveRequestPage({
    required List<LeaveRequestRow> rows,
    required this.total,
    required this.page,
    required this.pageSize,
  }) : rows = List.unmodifiable(rows);
  final List<LeaveRequestRow> rows;
  final int total, page, pageSize;
}

// ---- configuration drafts --------------------------------------------------

@freezed
abstract class LeaveTypeDraft with _$LeaveTypeDraft {
  const LeaveTypeDraft._();
  const factory LeaveTypeDraft({
    @Default('') String name,
    @Default('') String code,
    @Default('') String description,
    @Default(LeaveCompensationType.paid) LeaveCompensationType compensation,
    @Default(true) bool requiresApproval,
    @Default(true) bool allowsHalfDay,
    @Default(true) bool requiresReason,
    @Default(false) bool requiresAttachment,
    @Default('annual') String colorKey,
    @Default(ConfigurationStatus.active) ConfigurationStatus status,
  }) = _LeaveTypeDraft;

  LeaveTypeDraft normalized() =>
      copyWith(name: name.trim(), code: code.trim().toUpperCase());

  Map<String, String> validate() {
    final errors = <String, String>{};
    if (name.trim().isEmpty) errors['name'] = 'required';
    if (code.trim().isEmpty) errors['code'] = 'required';
    return Map.unmodifiable(errors);
  }

  factory LeaveTypeDraft.fromType(LeaveType type) => LeaveTypeDraft(
    name: type.name,
    code: type.code,
    description: type.description,
    compensation: type.compensation,
    requiresApproval: type.requiresApproval,
    allowsHalfDay: type.allowsHalfDay,
    requiresReason: type.requiresReason,
    requiresAttachment: type.requiresAttachment,
    colorKey: type.colorKey,
    status: type.status,
  );
}

@freezed
abstract class LeavePolicyDraft with _$LeavePolicyDraft {
  const LeavePolicyDraft._();
  const factory LeavePolicyDraft({
    @Default('') String name,
    @Default('') String code,
    @Default('') String leaveTypeId,
    @Default(0) double annualEntitlementDays,
    @Default(true) bool allowHalfDay,
    @Default(0.5) double minimumRequestDays,
    int? maximumConsecutiveDays,
    @Default(0) int advanceNoticeDays,
    @Default(false) bool allowPastRequest,
    @Default(0) int pastRequestWindowDays,
    int? requiresAttachmentAfterDays,
    @Default(false) bool allowNegativeBalance,
    @Default(false) bool carryForwardEnabled,
    double? carryForwardLimitDays,
    @Default(<EmploymentType>{}) Set<EmploymentType> applicableEmploymentTypes,
    @Default(ConfigurationStatus.active) ConfigurationStatus status,
  }) = _LeavePolicyDraft;

  LeavePolicyDraft normalized() =>
      copyWith(name: name.trim(), code: code.trim().toUpperCase());

  Map<String, String> validate() {
    final errors = <String, String>{};
    if (name.trim().isEmpty) errors['name'] = 'required';
    if (code.trim().isEmpty) errors['code'] = 'required';
    if (leaveTypeId.trim().isEmpty) errors['leaveTypeId'] = 'required';
    if (annualEntitlementDays < 0) {
      errors['annualEntitlementDays'] = 'invalidQuantity';
    }
    if (minimumRequestDays < 0) {
      errors['minimumRequestDays'] = 'invalidQuantity';
    }
    if (advanceNoticeDays < 0) errors['advanceNoticeDays'] = 'invalidQuantity';
    return Map.unmodifiable(errors);
  }

  factory LeavePolicyDraft.fromPolicy(LeavePolicy policy) => LeavePolicyDraft(
    name: policy.name,
    code: policy.code,
    leaveTypeId: policy.leaveTypeId,
    annualEntitlementDays: policy.annualEntitlementDays,
    allowHalfDay: policy.allowHalfDay,
    minimumRequestDays: policy.minimumRequestDays,
    maximumConsecutiveDays: policy.maximumConsecutiveDays,
    advanceNoticeDays: policy.advanceNoticeDays,
    allowPastRequest: policy.allowPastRequest,
    pastRequestWindowDays: policy.pastRequestWindowDays,
    requiresAttachmentAfterDays: policy.requiresAttachmentAfterDays,
    allowNegativeBalance: policy.allowNegativeBalance,
    carryForwardEnabled: policy.carryForwardEnabled,
    carryForwardLimitDays: policy.carryForwardLimitDays,
    applicableEmploymentTypes: policy.applicableEmploymentTypes,
    status: policy.status,
  );
}

@freezed
abstract class HolidayDraft with _$HolidayDraft {
  const HolidayDraft._();
  const factory HolidayDraft({
    @Default('') String name,
    DateTime? date,
    DateTime? endDate,
    @Default(HolidayType.companyHoliday) HolidayType type,
    @Default(HolidayScope.companyWide) HolidayScope scope,
    @Default(<String>{}) Set<String> workLocationIds,
    @Default('') String description,
    @Default(false) bool isOptional,
    @Default(HolidaySource.manual) HolidaySource source,
    String? calendarId,
    String? countryCode,
    String? regionCode,
    @Default(ConfigurationStatus.active) ConfigurationStatus status,
  }) = _HolidayDraft;

  HolidayDraft normalized() => copyWith(name: name.trim());

  Map<String, String> validate() {
    final errors = <String, String>{};
    if (name.trim().isEmpty) errors['name'] = 'required';
    if (date == null) errors['date'] = 'required';
    if (date != null && endDate != null && endDate!.isBefore(date!)) {
      errors['endDate'] = 'invalidDateRange';
    }
    if (scope == HolidayScope.specificWorkLocations &&
        workLocationIds.isEmpty) {
      errors['workLocationIds'] = 'required';
    }
    return Map.unmodifiable(errors);
  }

  factory HolidayDraft.fromHoliday(Holiday holiday) => HolidayDraft(
    name: holiday.name,
    date: holiday.date,
    endDate: holiday.endDate,
    type: holiday.type,
    scope: holiday.scope,
    workLocationIds: holiday.workLocationIds,
    description: holiday.description,
    isOptional: holiday.isOptional,
    source: holiday.source,
    calendarId: holiday.calendarId,
    countryCode: holiday.countryCode,
    regionCode: holiday.regionCode,
    status: holiday.status,
  );
}

/// Draft for creating/updating an annual holiday calendar.
class HolidayCalendarDraft {
  const HolidayCalendarDraft({
    required this.name,
    required this.year,
    this.countryCode,
    this.regionCode,
    this.isDefault = false,
  });
  final String name;
  final int year;
  final String? countryCode, regionCode;
  final bool isDefault;
}

/// One parsed import row; [error] is set when the row cannot be imported.
class HolidayImportRow {
  const HolidayImportRow({required this.draft, this.error});
  final HolidayDraft draft;
  final String? error;
  bool get isValid => error == null;
}

class HolidayImportResult {
  const HolidayImportResult({
    required this.imported,
    required this.skipped,
    this.errors = const [],
  });
  final int imported, skipped;
  final List<String> errors;
}

// ---- operational read models ----------------------------------------------

/// Filters for organizational leave request lists. All fields are optional;
/// scope (team/company) is always resolved from capabilities, never a filter.
class LeaveRequestFilter {
  const LeaveRequestFilter({
    this.status,
    this.leaveTypeId,
    this.employeeId,
    this.departmentId,
    this.from,
    this.to,
    this.search = '',
  });
  final LeaveRequestStatus? status;
  final String? leaveTypeId, employeeId, departmentId;
  final DateTime? from, to;
  final String search;

  bool get isEmpty =>
      status == null &&
      leaveTypeId == null &&
      employeeId == null &&
      departmentId == null &&
      from == null &&
      to == null &&
      search.trim().isEmpty;

  LeaveRequestFilter copyWith({
    LeaveRequestStatus? status,
    bool clearStatus = false,
    String? leaveTypeId,
    bool clearLeaveType = false,
    String? employeeId,
    bool clearEmployee = false,
    String? departmentId,
    bool clearDepartment = false,
    DateTime? from,
    bool clearFrom = false,
    DateTime? to,
    bool clearTo = false,
    String? search,
  }) => LeaveRequestFilter(
    status: clearStatus ? null : status ?? this.status,
    leaveTypeId: clearLeaveType ? null : leaveTypeId ?? this.leaveTypeId,
    employeeId: clearEmployee ? null : employeeId ?? this.employeeId,
    departmentId: clearDepartment ? null : departmentId ?? this.departmentId,
    from: clearFrom ? null : from ?? this.from,
    to: clearTo ? null : to ?? this.to,
    search: search ?? this.search,
  );
}

/// One employee currently on approved leave for a day.
class LeaveTodayItem {
  const LeaveTodayItem({
    required this.row,
    required this.returnDate,
    this.designation = '',
  });
  final LeaveRequestRow row;
  final DateTime returnDate;
  final String designation;
  bool get isHalfDay => !row.request.isFullDay;
}

/// An upcoming approved leave, nearest first.
class UpcomingLeaveItem {
  const UpcomingLeaveItem({required this.row, required this.workingDays});
  final LeaveRequestRow row;
  final double workingDays;
}

/// A pending request enriched with the requester's balance for its type/year.
class LeaveApprovalItem {
  const LeaveApprovalItem({
    required this.row,
    required this.entitlement,
    required this.used,
    required this.pending,
  });
  final LeaveRequestRow row;
  final double entitlement, used, pending;
  double get available => entitlement - used - pending;
  double get afterApproval => available - row.request.requestedDays;
}

/// One employee/leave-type balance line for the organizational balance table.
class LeaveBalanceRow {
  const LeaveBalanceRow({
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.department,
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.entitlement,
    required this.used,
    required this.pending,
  });
  final String employeeId,
      employeeName,
      employeeCode,
      department,
      leaveTypeId,
      leaveTypeName;
  final double entitlement, used, pending;
  double get available => entitlement - used - pending;
}

class LeaveOperationsSummary {
  const LeaveOperationsSummary({
    required this.onLeaveToday,
    required this.upcoming,
    required this.pending,
    required this.approvedThisMonth,
    required this.teamMembers,
  });
  final int onLeaveToday, upcoming, pending, approvedThisMonth, teamMembers;
}

/// Combined organizational leave read: summary + today + upcoming + requests.
class LeaveOperationsData {
  const LeaveOperationsData({
    required this.summary,
    required this.today,
    required this.upcoming,
    required this.requests,
  });
  final LeaveOperationsSummary summary;
  final List<LeaveTodayItem> today;
  final List<UpcomingLeaveItem> upcoming;
  final List<LeaveRequestRow> requests;
}

/// A department option for organizational filters.
class LeaveDepartmentOption {
  const LeaveDepartmentOption(this.id, this.name);
  final String id, name;
}

/// Employee leave profile: identity, balances, upcoming and recent requests.
class EmployeeLeaveSummary {
  const EmployeeLeaveSummary({
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.department,
    required this.designation,
    required this.managerName,
    required this.balances,
    required this.upcoming,
    required this.recent,
  });
  final String employeeId,
      employeeName,
      employeeCode,
      department,
      designation,
      managerName;
  final List<LeaveBalanceSummary> balances;
  final List<LeaveRequestRow> upcoming;
  final List<LeaveRequestRow> recent;
}
