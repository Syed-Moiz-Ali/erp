import '../../../core/database/app_database.dart';
import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/errors/result.dart';
import '../../../core/sync/sync_coordinator.dart';
import '../../../core/utils/app_clock.dart';
import '../../auth/domain/entities/auth_context.dart';
import '../../auth/domain/repositories/auth_repository.dart';
import '../domain/attendance_models.dart';
import '../domain/attendance_state_machine.dart';
import '../domain/attendance_summary_calculator.dart';
import '../domain/shift_workday_resolver.dart';
import 'attendance_local_data_source.dart';
import 'local_attendance_repository.dart';

class AttendanceRemoteConfirmation {
  const AttendanceRemoteConfirmation({
    required this.requestId,
    required this.accepted,
    this.serverTimestamp,
    this.rejectionCode,
  });
  final String requestId;
  final bool accepted;
  final DateTime? serverTimestamp;
  final String? rejectionCode;
}

abstract interface class AttendanceRemoteSender {
  Future<Result<AttendanceRemoteConfirmation>> send(AttendanceEvent event);
}

/// Register with SyncCoordinator only when a real sender is configured.
/// Never synthesize server timestamps/acceptance; failures preserve the original operation.
class AttendanceSyncHandler implements ModuleSyncHandler {
  const AttendanceSyncHandler(this.local, this.auth, this.sender, this.clock);
  final AttendanceLocalDataSource local;
  final AuthRepository auth;
  final AttendanceRemoteSender sender;
  final AppClock clock;
  @override
  String get moduleId => 'attendance';
  @override
  Future<Result<void>> synchronize() async {
    try {
      return await _run();
    } catch (_) {
      return Failed(
        attendanceFailure(
          AttendanceFailureCode.synchronizationFailed,
          retryable: true,
        ),
      );
    }
  }

  Future<Result<void>> _run() async {
    final session = await auth.checkSession();
    if (session case Failed<AuthContext?>(:final failure)) {
      return Failed(failure);
    }
    final a = (session as Success<AuthContext?>).value;
    if (a == null ||
        a.employeeReference == null ||
        a.user.status != AccountStatus.active) {
      return Failed(attendanceFailure(AttendanceFailureCode.accountInactive));
    }
    final db = local.db;
    final rows =
        await (db.select(db.syncOutbox)
              ..where(
                (t) =>
                    t.moduleId.equals(moduleId) &
                    t.companyId.equals(a.company.id) &
                    t.status.isIn(['pending', 'failed', 'rejected']),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.createdAt),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    rows.sort((a, b) {
      final first = AttendanceEvent.fromJson(
            jsonDecode(a.payload) as Map<String, dynamic>,
          ),
          second = AttendanceEvent.fromJson(
            jsonDecode(b.payload) as Map<String, dynamic>,
          );
      final time = first.deviceTimestamp.compareTo(second.deviceTimestamp);
      return time != 0 ? time : first.sequence.compareTo(second.sequence);
    });
    for (final row in rows) {
      final event = AttendanceEvent.fromJson(
        jsonDecode(row.payload) as Map<String, dynamic>,
      );
      if (event.employeeId != a.employeeReference!.id ||
          event.companyId != a.company.id) {
        continue;
      }
      if (row.status != 'pending') {
        return Failed(
          attendanceFailure(AttendanceFailureCode.synchronizationFailed),
        );
      }
      final current = await auth.checkSession();
      if (current is! Success<AuthContext?> ||
          current.value?.user.id != a.user.id ||
          current.value?.company.id != a.company.id) {
        return Failed(attendanceFailure(AttendanceFailureCode.accountInactive));
      }
      await (db.update(db.syncOutbox)..where((t) => t.id.equals(row.id))).write(
        SyncOutboxCompanion(
          attempts: Value(row.attempts + 1),
          lastAttemptAt: Value(clock.now()),
        ),
      );
      Result<AttendanceRemoteConfirmation> result;
      try {
        result = await sender.send(event);
      } catch (_) {
        result = Failed(
          attendanceFailure(
            AttendanceFailureCode.synchronizationFailed,
            retryable: true,
          ),
        );
      }
      await db.transaction(() async {
        final stored =
            await (db.select(db.attendanceEvents)..where(
                  (t) =>
                      t.id.equals(event.id) &
                      t.companyId.equals(a.company.id) &
                      t.employeeId.equals(a.employeeReference!.id),
                ))
                .getSingleOrNull();
        if (stored == null) throw StateError('Missing event');
        final day = await local.byId(
          a.company.id,
          event.employeeId,
          event.attendanceDayId,
        );
        if (day == null) throw StateError('Missing day');
        if (result case Failed<AttendanceRemoteConfirmation>(:final failure)) {
          await (db.update(
            db.syncOutbox,
          )..where((t) => t.id.equals(row.id))).write(
            SyncOutboxCompanion(
              status: const Value('failed'),
              failureCode: Value(failure.code),
            ),
          );
          await (db.update(
            db.attendanceEvents,
          )..where((t) => t.id.equals(event.id))).write(
            const AttendanceEventsCompanion(syncStatus: Value('failed')),
          );
        } else {
          final confirmation =
              (result as Success<AttendanceRemoteConfirmation>).value;
          if (confirmation.requestId != event.requestId) {
            throw StateError('Mismatched confirmation');
          }
          if (!confirmation.accepted) {
            await (db.update(
              db.syncOutbox,
            )..where((t) => t.id.equals(row.id))).write(
              SyncOutboxCompanion(
                status: const Value('rejected'),
                failureCode: Value(
                  confirmation.rejectionCode ?? 'synchronizationFailed',
                ),
              ),
            );
            await (db.update(
              db.attendanceEvents,
            )..where((t) => t.id.equals(event.id))).write(
              const AttendanceEventsCompanion(syncStatus: Value('rejected')),
            );
          } else {
            final candidate = local
                .readEvent(stored)
                .copyWith(
                  serverTimestamp: confirmation.serverTimestamp == null
                      ? null
                      : attendanceInstant(confirmation.serverTimestamp!),
                  syncStatus: AttendanceSyncStatus.synced,
                );
            final history = await local.events(
              a.company.id,
              event.employeeId,
              day.id,
            );
            final revised = [
              for (final e in history) e.id == candidate.id ? candidate : e,
            ];
            final summary = const AttendanceSummaryCalculator().calculate(
              revised,
              clock.now(),
            );
            if (summary is Failed<AttendanceSummary>) {
              throw StateError('Invalid authoritative timeline');
            }
            await (db.update(
              db.attendanceEvents,
            )..where((t) => t.id.equals(event.id))).write(
              AttendanceEventsCompanion(
                serverMilliseconds: Value(
                  candidate.serverTimestamp?.millisecondsSinceEpoch,
                ),
                effectiveMilliseconds: Value(
                  candidate.effectiveTimestamp.millisecondsSinceEpoch,
                ),
                syncStatus: const Value('synced'),
              ),
            );
            await (db.delete(
              db.syncOutbox,
            )..where((t) => t.id.equals(row.id))).go();
          }
        }
        final events = await local.events(
          a.company.id,
          event.employeeId,
          day.id,
        );
        final summary = const AttendanceSummaryCalculator().calculate(
          events,
          clock.now(),
        );
        if (summary is Failed<AttendanceSummary>) {
          throw StateError('Invalid timeline');
        }
        final s = (summary as Success<AttendanceSummary>).value;
        final late = const AttendanceTimingEvaluator().isLate(
          day.snapshot,
          s.punchInTime!,
        );
        await local.putDay(
          day.copyWith(
            state: s.currentState,
            punchInAt: s.punchInTime,
            punchOutAt: s.punchOutTime,
            elapsedMilliseconds: s.elapsedDuration.inMilliseconds,
            breakMilliseconds: s.breakDuration.inMilliseconds,
            workMilliseconds: s.workDuration.inMilliseconds,
            status: late
                ? AttendanceDayStatus.late
                : s.currentState == AttendanceWorkdayState.completed
                ? AttendanceDayStatus.completed
                : AttendanceDayStatus.working,
            syncStatus: aggregateSync(events.map((e) => e.syncStatus)),
            updatedAt: clock.now(),
          ),
        );
      });
      if (result case Failed<AttendanceRemoteConfirmation>(:final failure)) {
        return Failed(failure);
      }
      if (!(result as Success<AttendanceRemoteConfirmation>).value.accepted) {
        return Failed(
          attendanceFailure(AttendanceFailureCode.synchronizationFailed),
        );
      }
    }
    return const Success(null);
  }
}
