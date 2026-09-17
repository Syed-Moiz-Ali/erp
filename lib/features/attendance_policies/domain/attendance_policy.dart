import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/models/configuration_record.dart';
part 'attendance_policy.freezed.dart';
part 'attendance_policy.g.dart';

enum OfflineAttendanceMode { notAllowed, allowPending, allowWithWarning }

@freezed
abstract class AttendancePolicy
    with _$AttendancePolicy
    implements ConfigurationRecord {
  const AttendancePolicy._();
  const factory AttendancePolicy({
    required String id,
    required String companyId,
    required String name,
    @Default('') String description,
    @Default(true) bool requireLocation,
    @Default(false) bool allowOutsideLocation,
    @Default(false) bool allowRemoteAttendance,
    @Default(true) bool requireLocationOnPunchIn,
    @Default(true) bool requireLocationOnPunchOut,
    @Default(false) bool requireLocationOnBreak,
    @Default(false) bool requireLocationAccuracy,
    double? maximumAcceptedAccuracyMeters,
    @Default(true) bool trackBreaks,
    @Default(true) bool allowMultipleBreaks,
    @Default(false) bool allowPunchOutDuringBreak,
    @Default(true) bool allowEmployeeCorrectionRequest,
    @Default(false) bool allowEarlyPunchIn,
    int? earlyPunchInLimitMinutes,
    @Default(true) bool allowLatePunchIn,
    @Default(false) bool allowEarlyPunchOut,
    @Default(OfflineAttendanceMode.allowPending)
    OfflineAttendanceMode offlineMode,
    @Default(ConfigurationStatus.active) ConfigurationStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(RecordSyncStatus.pending) RecordSyncStatus syncStatus,
  }) = _AttendancePolicy;
  factory AttendancePolicy.fromJson(Map<String, dynamic> json) =>
      _$AttendancePolicyFromJson(json);
}

@freezed
abstract class AttendancePolicyDraft with _$AttendancePolicyDraft {
  const AttendancePolicyDraft._();
  const factory AttendancePolicyDraft({
    @Default('') String name,
    @Default('') String description,
    @Default(true) bool requireLocation,
    @Default(false) bool allowOutsideLocation,
    @Default(false) bool allowRemoteAttendance,
    @Default(true) bool requireLocationOnPunchIn,
    @Default(true) bool requireLocationOnPunchOut,
    @Default(false) bool requireLocationOnBreak,
    @Default(false) bool requireLocationAccuracy,
    double? maximumAcceptedAccuracyMeters,
    @Default(true) bool trackBreaks,
    @Default(true) bool allowMultipleBreaks,
    @Default(false) bool allowPunchOutDuringBreak,
    @Default(true) bool allowEmployeeCorrectionRequest,
    @Default(false) bool allowEarlyPunchIn,
    int? earlyPunchInLimitMinutes,
    @Default(true) bool allowLatePunchIn,
    @Default(false) bool allowEarlyPunchOut,
    @Default(OfflineAttendanceMode.allowPending)
    OfflineAttendanceMode offlineMode,
    @Default(ConfigurationStatus.active) ConfigurationStatus status,
  }) = _AttendancePolicyDraft;
  AttendancePolicyDraft normalized() => copyWith(
    name: name.trim(),
    description: description.trim(),
    allowOutsideLocation: requireLocation && allowOutsideLocation,
    requireLocationOnPunchIn: requireLocation && requireLocationOnPunchIn,
    requireLocationOnPunchOut: requireLocation && requireLocationOnPunchOut,
    requireLocationOnBreak:
        requireLocation && trackBreaks && requireLocationOnBreak,
    requireLocationAccuracy: requireLocation && requireLocationAccuracy,
    maximumAcceptedAccuracyMeters: requireLocation && requireLocationAccuracy
        ? maximumAcceptedAccuracyMeters
        : null,
    allowMultipleBreaks: trackBreaks && allowMultipleBreaks,
    allowPunchOutDuringBreak: trackBreaks && allowPunchOutDuringBreak,
    earlyPunchInLimitMinutes: allowEarlyPunchIn
        ? earlyPunchInLimitMinutes
        : null,
  );
  Map<String, String> validate() {
    final d = normalized(), errors = <String, String>{};
    if (d.name.isEmpty) errors['name'] = 'required';
    if (d.requireLocation &&
        !d.requireLocationOnPunchIn &&
        !d.requireLocationOnPunchOut &&
        !d.requireLocationOnBreak) {
      errors['requireLocation'] = 'invalidPolicyCombination';
    }
    if (d.requireLocationAccuracy &&
        (d.maximumAcceptedAccuracyMeters == null ||
            !d.maximumAcceptedAccuracyMeters!.isFinite ||
            d.maximumAcceptedAccuracyMeters! <= 0)) {
      errors['maximumAcceptedAccuracyMeters'] = 'invalidAccuracy';
    }
    if (d.allowEarlyPunchIn &&
        (d.earlyPunchInLimitMinutes == null ||
            d.earlyPunchInLimitMinutes! < 0 ||
            d.earlyPunchInLimitMinutes! > 1440)) {
      errors['earlyPunchInLimitMinutes'] = 'invalidEarlyLimit';
    }
    return Map.unmodifiable(errors);
  }

  factory AttendancePolicyDraft.fromPolicy(AttendancePolicy p) =>
      AttendancePolicyDraft(
        name: p.name,
        description: p.description,
        requireLocation: p.requireLocation,
        allowOutsideLocation: p.allowOutsideLocation,
        allowRemoteAttendance: p.allowRemoteAttendance,
        requireLocationOnPunchIn: p.requireLocationOnPunchIn,
        requireLocationOnPunchOut: p.requireLocationOnPunchOut,
        requireLocationOnBreak: p.requireLocationOnBreak,
        requireLocationAccuracy: p.requireLocationAccuracy,
        maximumAcceptedAccuracyMeters: p.maximumAcceptedAccuracyMeters,
        trackBreaks: p.trackBreaks,
        allowMultipleBreaks: p.allowMultipleBreaks,
        allowPunchOutDuringBreak: p.allowPunchOutDuringBreak,
        allowEmployeeCorrectionRequest: p.allowEmployeeCorrectionRequest,
        allowEarlyPunchIn: p.allowEarlyPunchIn,
        earlyPunchInLimitMinutes: p.earlyPunchInLimitMinutes,
        allowLatePunchIn: p.allowLatePunchIn,
        allowEarlyPunchOut: p.allowEarlyPunchOut,
        offlineMode: p.offlineMode,
        status: p.status,
      );
}
