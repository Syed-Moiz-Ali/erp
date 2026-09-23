import 'attendance_history.dart';
import 'package:modular_erp/core/connectivity/connectivity_service.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'attendance_engine.dart';
import 'attendance_models.dart';

abstract interface class AttendanceRepository {
  Future<Result<DateTime>> getCompanyAttendanceDate();
  Future<Result<AttendanceHistoryPageData>> getAttendanceHistory(
    AttendanceHistoryQuery query,
  );
  Stream<Result<AttendanceHistoryPageData>> watchAttendanceHistory(
    AttendanceHistoryQuery query,
  );
  Future<Result<AttendanceDayDetails?>> getAttendanceDayById(String dayId);
  Stream<Result<AttendanceDayDetails?>> watchAttendanceDayById(String dayId);
  Future<Result<AttendanceContext>> getCurrentAttendance({
    AttendanceWorkMode workMode = AttendanceWorkMode.office,
    String? expectedUserId,
    String? expectedCompanyId,
  });
  Stream<Result<AttendanceContext>> watchCurrentAttendance();
  Future<Result<AttendanceDay?>> getAttendanceForDate(DateTime date);
  Stream<Result<List<AttendanceEvent>>> watchAttendanceEvents(String dayId);
  Future<Result<AttendanceMutationResult>> execute(AttendanceCommand command);
  Future<Result<void>> retryPendingOperation(String operationId);
}

class AttendanceMutationResult {
  const AttendanceMutationResult(this.day, this.event, this.decision);
  final AttendanceDay day;
  final AttendanceEvent event;
  final AttendanceActionDecision decision;
}

abstract interface class AttendanceRemoteAvailability {
  Future<bool> get isAvailable;
}

/// No server is configured. Connectivity alone never implies API availability.
class UnconfiguredAttendanceRemote implements AttendanceRemoteAvailability {
  const UnconfiguredAttendanceRemote();
  @override
  Future<bool> get isAvailable async => false;
}

/// Connectivity is a hint; the configured API probe must also confirm availability.
class ConnectedAttendanceRemoteAvailability
    implements AttendanceRemoteAvailability {
  const ConnectedAttendanceRemoteAvailability(this.connectivity, this.probe);
  final ConnectivityService connectivity;
  final Future<bool> Function() probe;
  @override
  Future<bool> get isAvailable async {
    try {
      return await connectivity.isConnected && await probe();
    } catch (_) {
      return false;
    }
  }
}
