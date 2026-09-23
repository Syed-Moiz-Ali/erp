import 'package:modular_erp/core/location/location_service.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_state_machine.dart';
import 'package:modular_erp/modules/hr/attendance/application/execute_attendance_action.dart';

class DeviceAttendanceLocationCapture implements AttendanceLocationCapture {
  const DeviceAttendanceLocationCapture(this.location);
  final LocationService location;
  @override
  Future<Result<AttendanceLocationEvidence>> capture() async {
    final result = await location.currentPosition(requestPermission: true);
    if (result case Failed(:final failure)) {
      if (failure.code == 'location_permanent') {
        return Failed(
          attendanceFailure(
            AttendanceFailureCode.locationPermissionPermanentlyDenied,
          ),
        );
      }
      return Failed(
        attendanceFailure(switch (failure.kind) {
          FailureKind.locationPermission =>
            AttendanceFailureCode.locationPermissionDenied,
          FailureKind.locationDisabled =>
            AttendanceFailureCode.locationServicesDisabled,
          _ => AttendanceFailureCode.locationUnavailable,
        }, retryable: failure.retryable),
      );
    }
    final position = (result as Success).value;
    return Success(
      AttendanceLocationEvidence(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        capturedAt: position.timestamp.toUtc(),
      ),
    );
  }
}
