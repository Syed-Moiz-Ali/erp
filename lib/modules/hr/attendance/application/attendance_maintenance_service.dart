import 'package:drift/drift.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/modules/hr/attendance/data/attendance_local_data_source.dart';
import 'package:modular_erp/modules/hr/attendance/data/local_attendance_correction_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_summary_calculator.dart';

class AttendanceIntegrityIssue {
  const AttendanceIntegrityIssue({
    required this.code,
    required this.dayId,
    required this.employeeId,
  });
  final String code, dayId, employeeId;
}

/// Derived-data repair and integrity diagnostics. Audit event history is never
/// destructively auto-fixed; only read-model caches are rebuilt from truth.
class AttendanceMaintenanceService {
  AttendanceMaintenanceService(this.db, this.auth, this.clock);
  final AppDatabase db;
  final AuthRepository auth;
  final AppClock clock;

  /// Recomputes a day's cached state/totals from its effective events and any
  /// approved corrections. Useful after migrations or reconciliation.
  Future<Result<void>> rebuildDaySummary({
    required String companyId,
    required String employeeId,
    required String dayId,
  }) async {
    try {
      final local = AttendanceLocalDataSource(db);
      final day = await local.byId(companyId, employeeId, dayId);
      if (day == null) {
        return const Failed(
          Failure(
            code: 'attendanceInvalidAttendanceState',
            kind: FailureKind.invalidData,
          ),
        );
      }
      final corrections = LocalAttendanceCorrectionRepository(db, auth, clock);
      final events = await corrections.effectiveEvents(
        companyId,
        employeeId,
        dayId,
      );
      final summary = const AttendanceSummaryCalculator().calculate(
        events,
        clock.now().toUtc(),
      );
      if (summary is Failed<AttendanceSummary>) return Failed(summary.failure);
      final value = (summary as Success<AttendanceSummary>).value;
      await (db.update(db.attendanceDays)..where(
            (t) =>
                t.id.equals(dayId) &
                t.companyId.equals(companyId) &
                t.employeeId.equals(employeeId),
          ))
          .write(
            AttendanceDaysCompanion(
              state: Value(value.currentState.name),
              punchInMilliseconds: Value(
                value.punchInTime?.millisecondsSinceEpoch,
              ),
              punchOutMilliseconds: Value(
                value.punchOutTime?.millisecondsSinceEpoch,
              ),
              elapsedMilliseconds: Value(value.elapsedDuration.inMilliseconds),
              workMilliseconds: Value(value.workDuration.inMilliseconds),
              breakMilliseconds: Value(value.breakDuration.inMilliseconds),
              updatedMilliseconds: Value(
                clock.now().toUtc().millisecondsSinceEpoch,
              ),
            ),
          );
      return const Success(null);
    } catch (_) {
      return const Failed(
        Failure(
          code: 'attendancePersistenceFailure',
          kind: FailureKind.storageUpdate,
        ),
      );
    }
  }

  /// Reports impossible local attendance state without modifying audit data.
  Future<Result<List<AttendanceIntegrityIssue>>> integrityIssues({
    required String companyId,
  }) async {
    try {
      final issues = <AttendanceIntegrityIssue>[];
      final days = await (db.select(
        db.attendanceDays,
      )..where((t) => t.companyId.equals(companyId))).get();
      final events = await (db.select(
        db.attendanceEvents,
      )..where((t) => t.companyId.equals(companyId))).get();
      for (final day in days) {
        final dayEvents = events
            .where((e) => e.attendanceDayId == day.id)
            .toList();
        if (day.state != 'completed' && dayEvents.isEmpty) {
          issues.add(
            AttendanceIntegrityIssue(
              code: 'openDayWithoutEvents',
              dayId: day.id,
              employeeId: day.employeeId,
            ),
          );
        }
        if (day.state == 'completed' && day.punchOutMilliseconds == null) {
          issues.add(
            AttendanceIntegrityIssue(
              code: 'completedWithoutPunchOut',
              dayId: day.id,
              employeeId: day.employeeId,
            ),
          );
        }
        if (day.state == 'working' && day.punchInMilliseconds == null) {
          issues.add(
            AttendanceIntegrityIssue(
              code: 'workingWithoutPunchIn',
              dayId: day.id,
              employeeId: day.employeeId,
            ),
          );
        }
      }
      return Success(issues);
    } catch (_) {
      return const Failed(
        Failure(
          code: 'attendancePersistenceFailure',
          kind: FailureKind.storageUpdate,
        ),
      );
    }
  }
}
