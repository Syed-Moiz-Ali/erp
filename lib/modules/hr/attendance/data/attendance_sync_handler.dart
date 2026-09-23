import 'package:modular_erp/core/database/app_database.dart';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/sync/outbox_repository.dart';
import 'package:modular_erp/core/sync/sync_coordinator.dart';
import 'package:modular_erp/core/sync/sync_retry_policy.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/platform/notifications/domain/app_notification.dart';
import 'package:modular_erp/platform/notifications/domain/notification_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_state_machine.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_summary_calculator.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
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
  const AttendanceSyncHandler(
    this.local,
    this.auth,
    this.sender,
    this.clock, {
    this.notifications,
    this.retryPolicy = const SyncRetryPolicy(),
  });
  final AttendanceLocalDataSource local;
  final AuthRepository auth;
  final AttendanceRemoteSender sender;
  final AppClock clock;
  final NotificationRepository? notifications;
  final SyncRetryPolicy retryPolicy;
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
    final now = clock.now().toUtc();
    await OutboxLocalDataSource(db).recoverStaleProcessing(now: now);
    final rows =
        await (db.select(db.syncOutbox)
              ..where(
                (t) =>
                    t.moduleId.equals(moduleId) &
                    t.companyId.equals(a.company.id) &
                    t.status.isIn([
                      'pending',
                      'retryScheduled',
                      'failed',
                      'rejected',
                    ]),
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
      // Out-of-order protection: a blocked/rejected or not-yet-due operation
      // stops the queue so later events never sync before their predecessors.
      if (row.status == 'rejected' || row.status == 'failed') {
        return Failed(
          attendanceFailure(AttendanceFailureCode.synchronizationFailed),
        );
      }
      if (row.status == 'retryScheduled' &&
          row.nextAttemptAt != null &&
          row.nextAttemptAt!.toUtc().isAfter(now)) {
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
          status: const Value('processing'),
          attempts: Value(row.attempts + 1),
          lastAttemptAt: Value(now),
          processingStartedAt: Value(now),
          processorId: const Value('attendance'),
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
          final retryAt = retryPolicy.nextAttemptAt(now, row.attempts + 1);
          await (db.update(
            db.syncOutbox,
          )..where((t) => t.id.equals(row.id))).write(
            SyncOutboxCompanion(
              status: const Value('retryScheduled'),
              failureCode: Value(failure.code),
              lastFailureMessageSafe: const Value('syncTransientFailure'),
              nextAttemptAt: Value(retryAt),
              processingStartedAt: const Value(null),
              processorId: const Value(null),
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
                processingStartedAt: const Value(null),
                processorId: const Value(null),
              ),
            );
            await (db.update(
              db.attendanceEvents,
            )..where((t) => t.id.equals(event.id))).write(
              const AttendanceEventsCompanion(syncStatus: Value('rejected')),
            );
            await _notifyRejection(a, row.id, event);
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

  /// Persistent rejection requires user action; one deduplicated notification
  /// per operation, never one per retry.
  Future<void> _notifyRejection(
    AuthContext actor,
    String operationId,
    AttendanceEvent event,
  ) async {
    final repository = notifications;
    if (repository == null) return;
    await repository.createLocal(
      AppNotification(
        id: const Uuid().v4(),
        companyId: actor.company.id,
        userId: actor.user.id,
        type: AppNotificationType.attendanceSyncFailed,
        priority: AppNotificationPriority.high,
        dedupeKey: 'syncFailure:$operationId',
        payload: {'dayId': event.attendanceDayId},
        createdAt: clock.now().toUtc(),
      ),
    );
  }
}
