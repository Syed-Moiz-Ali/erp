import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';

class LeaveRequestDraft {
  const LeaveRequestDraft({
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    this.startPortion = LeaveDayPortion.fullDay,
    this.endPortion = LeaveDayPortion.fullDay,
    this.reason = '',
    this.attachmentName,
  });
  final String leaveTypeId;
  final DateTime startDate, endDate;
  final LeaveDayPortion startPortion, endPortion;
  final String reason;
  final String? attachmentName;

  LeaveRequestDraft copyWith({
    String? leaveTypeId,
    DateTime? startDate,
    DateTime? endDate,
    LeaveDayPortion? startPortion,
    LeaveDayPortion? endPortion,
    String? reason,
    String? attachmentName,
  }) => LeaveRequestDraft(
    leaveTypeId: leaveTypeId ?? this.leaveTypeId,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    startPortion: startPortion ?? this.startPortion,
    endPortion: endPortion ?? this.endPortion,
    reason: reason ?? this.reason,
    attachmentName: attachmentName ?? this.attachmentName,
  );
}

class LeaveRequestPreview {
  const LeaveRequestPreview({
    required this.leaveTypeName,
    required this.requestedDays,
    required this.excludedWeekends,
    required this.excludedHolidays,
    required this.available,
    required this.afterApproval,
    required this.requiresReason,
  });
  final String leaveTypeName;
  final double requestedDays;
  final int excludedWeekends, excludedHolidays;
  final double available, afterApproval;
  final bool requiresReason;
}

class LeaveBalanceAdjustment {
  const LeaveBalanceAdjustment({
    required this.employeeId,
    required this.leaveTypeId,
    required this.add,
    required this.quantityDays,
    required this.effectiveDate,
    required this.reason,
  });
  final String employeeId, leaveTypeId, reason;
  final bool add;
  final double quantityDays;
  final DateTime effectiveDate;
}

enum LeaveRequestScope { self, team, company, approvals }

abstract interface class LeaveRepository {
  /// Company business date (UTC midnight) for the actor's company time zone.
  DateTime companyToday(AuthContext context);

  /// Centralized leave year for a date.
  int leaveYearFor(DateTime date);

  // ---- configuration -------------------------------------------------------
  Stream<Result<List<LeaveType>>> watchLeaveTypes(
    AuthContext context, {
    bool includeInactive = false,
  });
  Future<Result<LeaveType>> saveLeaveType(
    AuthContext context,
    LeaveTypeDraft draft, {
    String? id,
  });
  Future<Result<void>> setLeaveTypeStatus(
    AuthContext context,
    String id,
    bool active,
  );

  Stream<Result<List<LeavePolicy>>> watchLeavePolicies(
    AuthContext context, {
    bool includeInactive = false,
  });
  Future<Result<LeavePolicy>> saveLeavePolicy(
    AuthContext context,
    LeavePolicyDraft draft, {
    String? id,
  });
  Future<Result<void>> setLeavePolicyStatus(
    AuthContext context,
    String id,
    bool active,
  );

  Stream<Result<List<Holiday>>> watchHolidays(
    AuthContext context, {
    bool includeInactive = false,
  });
  Future<Result<Holiday>> saveHoliday(
    AuthContext context,
    HolidayDraft draft, {
    String? id,
  });
  Future<Result<void>> setHolidayStatus(
    AuthContext context,
    String id,
    bool active,
  );

  // ---- holiday calendars / yearly management -------------------------------
  Stream<Result<List<Holiday>>> watchHolidaysForYear(
    AuthContext context,
    int year, {
    bool includeInactive = false,
  });
  Stream<Result<List<HolidayCalendar>>> watchHolidayCalendars(
    AuthContext context,
  );
  Future<Result<HolidayCalendar>> saveHolidayCalendar(
    AuthContext context,
    HolidayCalendarDraft draft,
  );
  Future<Result<int>> copyHolidaysToYear(
    AuthContext context, {
    required int fromYear,
    required int toYear,
  });
  Future<Result<HolidayImportResult>> importHolidays(
    AuthContext context,
    List<HolidayImportRow> rows,
  );
  Future<Result<Holiday?>> nextHoliday(
    AuthContext context,
    String employeeId,
    DateTime from,
  );

  // ---- requests ------------------------------------------------------------
  Future<Result<LeaveRequestPreview>> previewRequest(
    AuthContext context,
    LeaveRequestDraft draft,
  );
  Future<Result<LeaveRequest>> submitRequest(
    AuthContext context,
    LeaveRequestDraft draft,
  );
  Future<Result<LeaveRequest>> cancelRequest(
    AuthContext context,
    String id, {
    String? reason,
  });
  Future<Result<LeaveRequest>> approveRequest(
    AuthContext context,
    String id, {
    String? note,
  });
  Future<Result<LeaveRequest>> rejectRequest(
    AuthContext context,
    String id, {
    required String note,
  });

  Stream<Result<List<LeaveRequestRow>>> watchRequests(
    AuthContext context, {
    required LeaveRequestScope scope,
    LeaveRequestStatus? status,
    LeaveRequestFilter filter = const LeaveRequestFilter(),
    int limit = 200,
  });
  Future<Result<LeaveRequestRow?>> requestById(AuthContext context, String id);

  // ---- organizational operations ------------------------------------------
  Stream<Result<LeaveOperationsData>> watchOperations(
    AuthContext context, {
    required LeaveRequestScope scope,
    LeaveRequestFilter filter = const LeaveRequestFilter(),
    int upcomingDays = 30,
  });
  Stream<Result<List<LeaveApprovalItem>>> watchApprovalQueue(
    AuthContext context,
  );
  Stream<Result<EmployeeLeaveSummary?>> watchEmployeeLeave(
    AuthContext context,
    String employeeId,
  );
  Stream<Result<List<LeaveBalanceRow>>> watchBalanceTable(
    AuthContext context, {
    int? year,
    String? departmentId,
    String? leaveTypeId,
    String search = '',
  });
  Stream<Result<List<LeaveDepartmentOption>>> watchDepartments(
    AuthContext context,
  );

  // ---- balances ------------------------------------------------------------
  Stream<Result<List<LeaveBalanceSummary>>> watchBalances(
    AuthContext context,
    String employeeId, {
    int? year,
  });
  Future<Result<List<LeaveBalanceTransaction>>> balanceLedger(
    AuthContext context,
    String employeeId,
    String leaveTypeId,
    int year,
  );
  Future<Result<void>> adjustBalance(
    AuthContext context,
    LeaveBalanceAdjustment adjustment,
  );

  // ---- calendar & holidays -------------------------------------------------
  Future<Result<List<LeaveCalendarEntry>>> calendar(
    AuthContext context,
    DateTime from,
    DateTime to,
  );
  Future<Result<List<Holiday>>> applicableHolidays(
    AuthContext context,
    String employeeId,
    DateTime from,
    DateTime to,
  );

  /// Leave/Holiday interpretation for a single scheduled workday, used to
  /// annotate attendance without contaminating the attendance state machine.
  Future<Result<LeaveWorkdayOverlay?>> dayOverride(
    AuthContext context,
    String employeeId,
    DateTime date,
  );

  /// Employee ids (from [employeeIds]) on approved leave covering [date].
  Future<Result<Set<String>>> employeesOnApprovedLeave(
    AuthContext context,
    DateTime date, {
    required List<String> employeeIds,
  });

  /// True when [date] is a company-wide, non-optional holiday.
  Future<Result<bool>> companyHolidayOn(AuthContext context, DateTime date);
}
