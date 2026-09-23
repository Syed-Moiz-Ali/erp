import 'package:flutter/widgets.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';

String leaveDaysCount(BuildContext c, num value) =>
    '${configurationNumber(c, value)} ${c.l10n.days}';

String leaveDaysValue(BuildContext c, num value) {
  final number = configurationNumber(c, value);
  final unit = value == 1 ? c.l10n.leaveDayOne : c.l10n.days;
  return '$number $unit';
}

String leaveDateRange(BuildContext c, DateTime from, DateTime to) =>
    '${configurationDate(c, from)} – ${configurationDate(c, to)}';

String leaveReturnLabel(BuildContext c, DateTime returnDate) =>
    '${c.l10n.leaveReturnDate}: ${configurationDate(c, returnDate)}';

String leaveDepartmentType(String department, String typeName) =>
    '$department · $typeName';

String leavePeriodDays(BuildContext c, DateTime from, DateTime to, num days) =>
    '${leaveDateRange(c, from, to)} · ${leaveDaysCount(c, days)}';

String leaveCompensationLabel(
  LeaveCompensationType value,
  AppLocalizations l,
) => switch (value) {
  LeaveCompensationType.paid => l.leaveCompensationPaid,
  LeaveCompensationType.unpaid => l.leaveCompensationUnpaid,
  LeaveCompensationType.informational => l.leaveCompensationInformational,
};

String leaveRequestStatusLabel(LeaveRequestStatus value, AppLocalizations l) =>
    switch (value) {
      LeaveRequestStatus.pending => l.leaveStatusPending,
      LeaveRequestStatus.approved => l.leaveStatusApproved,
      LeaveRequestStatus.rejected => l.leaveStatusRejected,
      LeaveRequestStatus.cancelled => l.leaveStatusCancelled,
    };

String leaveDayPortionLabel(LeaveDayPortion value, AppLocalizations l) =>
    switch (value) {
      LeaveDayPortion.fullDay => l.leaveDayFull,
      LeaveDayPortion.firstHalf => l.leaveDayFirstHalf,
      LeaveDayPortion.secondHalf => l.leaveDaySecondHalf,
    };

String holidayTypeLabel(HolidayType value, AppLocalizations l) =>
    switch (value) {
      HolidayType.publicHoliday => l.holidayTypePublic,
      HolidayType.festivalHoliday => l.holidayTypeFestival,
      HolidayType.regionalHoliday => l.holidayTypeRegional,
      HolidayType.companyHoliday => l.holidayTypeCompany,
      HolidayType.specialClosure => l.holidayTypeSpecial,
    };

String holidaySourceLabel(HolidaySource value, AppLocalizations l) =>
    switch (value) {
      HolidaySource.manual => l.holidaySourceManual,
      HolidaySource.copiedFromPreviousYear => l.holidaySourceCopied,
      HolidaySource.imported => l.holidaySourceImported,
      HolidaySource.companyTemplate => l.holidaySourceTemplate,
    };

String holidayScopeLabel(HolidayScope value, AppLocalizations l) =>
    switch (value) {
      HolidayScope.companyWide => l.holidayScopeCompanyWide,
      HolidayScope.specificWorkLocations => l.holidayScopeSpecific,
    };

String workdayClassificationLabel(
  WorkdayClassification value,
  AppLocalizations l,
) => switch (value) {
  WorkdayClassification.scheduledNoRecord => l.workdayScheduled,
  WorkdayClassification.working => l.workdayWorking,
  WorkdayClassification.onBreak => l.workdayOnBreak,
  WorkdayClassification.completed => l.workdayCompleted,
  WorkdayClassification.incomplete => l.workdayIncomplete,
  WorkdayClassification.approvedLeave => l.workdayOnLeave,
  WorkdayClassification.holiday => l.workdayHoliday,
  WorkdayClassification.nonWorkingDay => l.workdayNonWorking,
  WorkdayClassification.issue => l.workdayIssue,
};

String leaveTypeSummary(LeaveType type, AppLocalizations l) =>
    leaveCompensationLabel(type.compensation, l);

String leavePolicySummary(LeavePolicy policy, AppLocalizations l) =>
    '${policy.annualEntitlementDays} ${l.days}';

String holidaySummary(Holiday holiday, AppLocalizations l) =>
    holidayTypeLabel(holiday.type, l);

String leaveBalanceTypeLabel(
  LeaveBalanceTransactionType type,
  AppLocalizations l,
) => switch (type) {
  LeaveBalanceTransactionType.entitlement => l.leaveEntitlement,
  LeaveBalanceTransactionType.adjustmentAdd => l.leaveAdjustmentAdded,
  LeaveBalanceTransactionType.adjustmentSubtract => l.leaveAdjustmentDeducted,
  LeaveBalanceTransactionType.leaveReserved => l.leavePendingBalance,
  LeaveBalanceTransactionType.leaveReleased => l.leaveAvailable,
  LeaveBalanceTransactionType.leaveConsumed => l.leaveUsed,
  LeaveBalanceTransactionType.carryForward => l.leavePolicyCarryForward,
  LeaveBalanceTransactionType.expiry => l.leaveStatusCancelled,
  LeaveBalanceTransactionType.migration => l.leaveEntitlement,
};
