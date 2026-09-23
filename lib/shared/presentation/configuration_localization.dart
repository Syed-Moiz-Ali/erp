import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/utils/local_time.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:flutter/material.dart';

String configurationStatusLabel(
  ConfigurationStatus status,
  AppLocalizations l,
) => status == ConfigurationStatus.active ? l.cfgActive : l.cfgInactive;
String configurationFailure(Failure failure, AppLocalizations l) =>
    switch (failure.code) {
      'required' => l.cfgRequired,
      'validation' => l.cfgValidation,
      'duplicateName' => l.cfgDuplicateName,
      'invalidTimeRange' => l.cfgInvalidTime,
      'workingDays' => l.cfgWorkingDaysError,
      'invalidGrace' => l.cfgInvalidGrace,
      'invalidBreak' => l.cfgInvalidBreak,
      'invalidMinimumWork' => l.cfgInvalidMinimum,
      'invalidCoordinates' => l.cfgInvalidCoordinates,
      'invalidRadius' => l.cfgInvalidRadius,
      'invalidAccuracy' => l.cfgInvalidAccuracy,
      'countryCode' => l.cfgCountryError,
      'invalidPolicyCombination' => l.cfgPolicyError,
      'invalidEarlyLimit' => l.cfgEarlyError,
      'assignment' => l.cfgAssignmentError,
      'location_permission' => l.cfgLocationDenied,
      'location_permanent' => l.cfgLocationPermanent,
      'location_disabled' => l.cfgLocationDisabled,
      'location_timeout' => l.cfgLocationTimeout,
      'location_unavailable' => l.cfgLocationUnavailable,
      'denied' => l.shellAccessMessage,
      'notFound' => l.cfgNotFound,
      'invalidQuantity' => l.leaveInvalidQuantity,
      'invalidDateRange' => l.leaveInvalidDateRange,
      'leavePermissionDenied' => l.leavePermissionDenied,
      'leaveStorageError' => l.leaveStorageError,
      'leaveUnavailable' => l.leaveUnavailable,
      'leaveTypeInactive' => l.leaveTypeInactive,
      'leaveNoEmployee' => l.leaveNoEmployee,
      'leaveInvalidDateRange' => l.leaveInvalidDateRange,
      'leaveReasonRequired' => l.leaveReasonRequired,
      'leaveNoWorkingDays' => l.leaveNoWorkingDays,
      'leaveMinimumDays' => l.leaveMinimumDays,
      'leaveOverlapping' => l.leaveOverlapping,
      'leaveInsufficientBalance' => l.leaveInsufficientBalance,
      'leavePastRequestNotAllowed' => l.leavePastRequestNotAllowed,
      'leaveAdvanceNoticeRequired' => l.leaveAdvanceNoticeRequired,
      'leaveInvalidQuantity' => l.leaveInvalidQuantity,
      'leaveRequestNotFound' => l.leaveRequestNotFound,
      'leaveAlreadyReviewed' => l.leaveAlreadyReviewed,
      'leaveCannotCancelApproved' => l.leaveCannotCancelApproved,
      'leaveReviewNoteRequired' => l.leaveReviewNoteRequired,
      'leaveSelfApprovalNotAllowed' => l.leaveSelfApprovalNotAllowed,
      _ => l.cfgStorageError,
    };
String shiftBreakLabel(ShiftBreakMode mode, AppLocalizations l) =>
    switch (mode) {
      ShiftBreakMode.manualBreak => l.cfgManualBreak,
      ShiftBreakMode.fixedBreak => l.cfgFixedBreak,
      ShiftBreakMode.noBreak => l.cfgNoBreak,
    };
String validationModeLabel(LocationValidationMode mode, AppLocalizations l) =>
    switch (mode) {
      LocationValidationMode.geofenceRequired => l.cfgGeofenceRequired,
      LocationValidationMode.geofencePreferred => l.cfgGeofencePreferred,
      LocationValidationMode.locationCaptureOnly => l.cfgCaptureOnly,
      LocationValidationMode.none => l.cfgNoLocation,
    };
String offlineModeLabel(OfflineAttendanceMode mode, AppLocalizations l) =>
    switch (mode) {
      OfflineAttendanceMode.notAllowed => l.cfgOfflineNo,
      OfflineAttendanceMode.allowPending => l.cfgOfflinePending,
      OfflineAttendanceMode.allowWithWarning => l.cfgOfflineWarning,
    };
String configurationNumber(BuildContext c, num value) => AppNumberFormatter(
  Localizations.localeOf(c),
).decimal(value, decimalDigits: value == value.roundToDouble() ? 0 : 2);
String configurationDate(BuildContext c, DateTime value) =>
    AppDateFormatter(Localizations.localeOf(c)).date(value);
String configurationTime(BuildContext c, LocalTime value) =>
    AppTimeFormatter(Localizations.localeOf(c)).timeOfDay(
      TimeOfDay(hour: value.hour, minute: value.minute),
      use24Hour: MediaQuery.alwaysUse24HourFormatOf(c),
    );
String configurationDuration(BuildContext c, int minutes) => AppTimeFormatter(
  Localizations.localeOf(c),
).duration(Duration(minutes: minutes), c.l10n);
String shiftSummary(BuildContext c, Shift shift) => [
  configurationTime(c, shift.startTime),
  configurationTime(c, shift.endTime),
  if (shift.isOvernight) c.l10n.cfgOvernight,
].join(' · ');
String workingDaysSummary(Set<WorkingDay> days, AppLocalizations l) =>
    WorkingDay.values
        .where(days.contains)
        .map((d) => appWeekdayLabel(d, l))
        .join(' · ');
String policyLocationSummary(AttendancePolicy p, AppLocalizations l) =>
    !p.requireLocation
    ? l.cfgNoLocation
    : [
        if (p.requireLocationOnPunchIn) l.cfgLocationIn,
        if (p.requireLocationOnPunchOut) l.cfgLocationOut,
        if (p.requireLocationOnBreak) l.cfgLocationBreak,
        if (p.allowOutsideLocation) l.cfgOutside,
        if (p.requireLocationAccuracy) l.cfgRequireAccuracy,
      ].join(' · ');
String policyBreakSummary(AttendancePolicy p, AppLocalizations l) =>
    !p.trackBreaks
    ? l.cfgNoBreak
    : [
        l.cfgTrackBreaks,
        if (p.allowMultipleBreaks) l.cfgMultipleBreaks,
        if (p.allowPunchOutDuringBreak) l.cfgOutDuringBreak,
      ].join(' · ');
String policyTimingSummary(AttendancePolicy p, AppLocalizations l) => [
  if (p.allowEarlyPunchIn) l.cfgEarlyIn,
  if (p.allowLatePunchIn) l.cfgLateIn,
  if (p.allowEarlyPunchOut) l.cfgEarlyOut,
].join(' · ');
