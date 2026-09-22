import 'package:flutter/widgets.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/presentation/configuration_localization.dart';
import '../domain/leave_models.dart';

String leaveDaysCount(BuildContext c, num value) =>
    '${configurationNumber(c, value)} ${c.l10n.days}';

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
      HolidayType.companyHoliday => l.holidayTypeCompany,
      HolidayType.optionalHoliday => l.holidayTypeOptional,
      HolidayType.specialClosure => l.holidayTypeSpecial,
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
