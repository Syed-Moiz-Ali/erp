import '../../../core/errors/result.dart';
import '../../auth/domain/entities/auth_context.dart';
import '../domain/leave_models.dart';

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
    int limit = 50,
  });
  Future<Result<LeaveRequestRow?>> requestById(AuthContext context, String id);

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
}
