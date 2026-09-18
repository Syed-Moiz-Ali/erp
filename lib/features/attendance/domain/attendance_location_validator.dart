import 'dart:math' as math;
import '../../attendance_policies/domain/attendance_policy.dart';
import '../../work_locations/domain/work_location.dart';
import 'attendance_models.dart';

class AttendanceLocationRequirementResolver {
  const AttendanceLocationRequirementResolver();
  bool requiresLocation(AttendancePolicy p, AttendanceEventType action) =>
      p.requireLocation &&
      switch (action) {
        AttendanceEventType.punchIn => p.requireLocationOnPunchIn,
        AttendanceEventType.punchOut => p.requireLocationOnPunchOut,
        AttendanceEventType.breakStart ||
        AttendanceEventType.breakEnd => p.requireLocationOnBreak,
      };
}

class AttendanceLocationOutcome {
  const AttendanceLocationOutcome(this.validation, [this.failure]);
  final AttendanceLocationValidation validation;
  final AttendanceFailureCode? failure;
}

class AttendanceLocationValidator {
  const AttendanceLocationValidator({
    this.maximumEvidenceAge = const Duration(minutes: 2),
  });
  final Duration maximumEvidenceAge;
  static double distanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    double radians(double value) => value * math.pi / 180;
    final a =
        math.pow(math.sin(radians(lat2 - lat1) / 2), 2) +
        math.cos(radians(lat1)) *
            math.cos(radians(lat2)) *
            math.pow(math.sin(radians(lon2 - lon1) / 2), 2);
    return 6371000 *
        2 *
        math.atan2(math.sqrt(a.clamp(0, 1)), math.sqrt((1 - a).clamp(0, 1)));
  }

  AttendanceLocationOutcome validate(
    AttendanceConfigurationSnapshot s,
    AttendanceEventType action,
    AttendanceLocationEvidence? e,
    DateTime now,
  ) {
    if (!const AttendanceLocationRequirementResolver().requiresLocation(
      s.policy,
      action,
    )) {
      return const AttendanceLocationOutcome(
        AttendanceLocationValidation(
          state: AttendanceLocationState.notRequired,
        ),
      );
    }
    AttendanceLocationOutcome fail(
      AttendanceFailureCode code,
      AttendanceLocationState state,
    ) => AttendanceLocationOutcome(
      AttendanceLocationValidation(
        state: state,
        accuracyAccepted: state != AttendanceLocationState.accuracyRejected,
      ),
      code,
    );
    if (e == null) {
      return fail(
        AttendanceFailureCode.locationRequired,
        AttendanceLocationState.locationUnavailable,
      );
    }
    if (e.permissionState != AttendancePermissionState.granted) {
      return fail(switch (e.permissionState) {
        AttendancePermissionState.denied ||
        AttendancePermissionState.permanentlyDenied =>
          AttendanceFailureCode.locationPermissionDenied,
        AttendancePermissionState.serviceDisabled =>
          AttendanceFailureCode.locationServicesDisabled,
        _ => AttendanceFailureCode.locationUnavailable,
      }, AttendanceLocationState.locationUnavailable);
    }
    if (!e.latitude.isFinite ||
        e.latitude.abs() > 90 ||
        !e.longitude.isFinite ||
        e.longitude.abs() > 180 ||
        !e.accuracyMeters.isFinite ||
        e.accuracyMeters < 0) {
      return fail(
        AttendanceFailureCode.invalidLocationEvidence,
        AttendanceLocationState.locationUnavailable,
      );
    }
    final age = now.difference(e.capturedAt);
    if (age > maximumEvidenceAge || age < const Duration(seconds: -30)) {
      return fail(
        AttendanceFailureCode.staleLocationEvidence,
        AttendanceLocationState.locationUnavailable,
      );
    }
    final location = s.workLocation;
    final thresholds = <double>[
      if (s.policy.requireLocationAccuracy &&
          s.policy.maximumAcceptedAccuracyMeters != null)
        s.policy.maximumAcceptedAccuracyMeters!,
      if (location?.maximumAccuracyMeters != null)
        location!.maximumAccuracyMeters!,
    ];
    if (s.policy.requireLocationAccuracy &&
        s.policy.maximumAcceptedAccuracyMeters == null) {
      return fail(
        AttendanceFailureCode.invalidAttendanceState,
        AttendanceLocationState.accuracyRejected,
      );
    }
    if (thresholds.any((t) => !t.isFinite || t <= 0 || e.accuracyMeters > t)) {
      return fail(
        AttendanceFailureCode.locationAccuracyTooLow,
        AttendanceLocationState.accuracyRejected,
      );
    }
    if (s.workMode == AttendanceWorkMode.remote) {
      if (!s.policy.allowRemoteAttendance) {
        return fail(
          AttendanceFailureCode.remoteAttendanceNotAllowed,
          AttendanceLocationState.locationUnavailable,
        );
      }
      return const AttendanceLocationOutcome(
        AttendanceLocationValidation(
          state: AttendanceLocationState.remoteAllowed,
        ),
      );
    }
    if (location == null) {
      return fail(
        AttendanceFailureCode.workLocationRequiredButMissing,
        AttendanceLocationState.locationUnavailable,
      );
    }
    if (location.validationMode == LocationValidationMode.none ||
        location.validationMode == LocationValidationMode.locationCaptureOnly) {
      return const AttendanceLocationOutcome(
        AttendanceLocationValidation(state: AttendanceLocationState.captured),
      );
    }
    final distance = distanceMeters(
      e.latitude,
      e.longitude,
      location.latitude,
      location.longitude,
    );
    final inside = distance <= location.allowedRadiusMeters + 1e-7;
    final allowed = inside || s.policy.allowOutsideLocation;
    return AttendanceLocationOutcome(
      AttendanceLocationValidation(
        distanceMeters: distance,
        state: inside
            ? AttendanceLocationState.insideAllowedArea
            : allowed
            ? AttendanceLocationState.outsideAllowedAreaAllowed
            : AttendanceLocationState.outsideAllowedAreaRejected,
      ),
      allowed ? null : AttendanceFailureCode.outsideAllowedLocation,
    );
  }
}
