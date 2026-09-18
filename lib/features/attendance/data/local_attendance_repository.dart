import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/errors/result.dart';
import '../../../core/security/app_permission.dart';
import '../../../core/utils/app_clock.dart';
import '../../auth/domain/entities/auth_context.dart';
import '../../employees/domain/employee.dart';
import '../../auth/domain/repositories/auth_repository.dart';
import '../domain/attendance_models.dart';
import '../domain/attendance_context_resolver.dart';
import '../domain/attendance_repository.dart';
import '../domain/attendance_engine.dart';
import '../domain/attendance_state_machine.dart';
import '../domain/attendance_summary_calculator.dart';
import '../domain/shift_workday_resolver.dart';
import 'attendance_local_data_source.dart';

class LocalAttendanceRepository implements AttendanceRepository {
  LocalAttendanceRepository(
    this.local,
    this.auth,
    this.resolver,
    this.clock,
    this.remote, {
    this.authority = AttendanceAuthority.productionPending,
    this.engine = const AttendanceEngine(),
  });
  final AttendanceLocalDataSource local;
  final AuthRepository auth;
  final AttendanceContextResolver resolver;
  final AppClock clock;
  final AttendanceRemoteAvailability remote;
  final AttendanceAuthority authority;
  final AttendanceEngine engine;
  AppDatabase get _db => local.db;
  Future<Result<AuthContext>> _session() async {
    final result = await auth.checkSession();
    if (result case Failed<AuthContext?>(:final failure)) {
      return Failed(failure);
    }
    final context = (result as Success<AuthContext?>).value;
    if (context == null) {
      return Failed(attendanceFailure(AttendanceFailureCode.accountInactive));
    }
    if (context.user.status != AccountStatus.active) {
      return Failed(attendanceFailure(AttendanceFailureCode.accountInactive));
    }
    if (context.user.companyId != context.company.id ||
        !context.company.enabledModules.contains('attendance')) {
      return Failed(
        attendanceFailure(AttendanceFailureCode.companyUnavailable),
      );
    }
    final ref = context.employeeReference;
    if (ref == null ||
        ref.companyId != context.company.id ||
        ref.userAccountId != context.user.id) {
      return Failed(
        attendanceFailure(AttendanceFailureCode.notLinkedToEmployee),
      );
    }
    final linked = await resolver.employees.getEmployeeById(context, ref.id);
    if (linked case Failed<Employee?>(:final failure)) return Failed(failure);
    final employee = (linked as Success<Employee?>).value;
    if (employee == null ||
        employee.companyId != context.company.id ||
        employee.linkedUserId != context.user.id) {
      return Failed(
        attendanceFailure(AttendanceFailureCode.notLinkedToEmployee),
      );
    }
    if (employee.status != EmploymentStatus.active || !employee.loginEnabled) {
      return Failed(attendanceFailure(AttendanceFailureCode.employeeInactive));
    }
    return Success(context);
  }

  Future<Result<AttendanceContext>> _current(
    AuthContext a,
    DateTime now,
    AttendanceWorkMode mode,
    bool available,
  ) async {
    final employee = a.employeeReference!.id;
    final open = await local.openDay(a.company.id, employee);
    if (open != null) {
      return resolver.resolve(
        a,
        now,
        day: open,
        events: await local.events(a.company.id, employee, open.id),
        authority: authority,
        remoteAvailable: available,
      );
    }
    final fresh = await resolver.resolve(
      a,
      now,
      workMode: mode,
      authority: authority,
      remoteAvailable: available,
    );
    if (fresh case Failed<AttendanceContext>()) return fresh;
    final context = (fresh as Success<AttendanceContext>).value;
    final day = await local.forDate(a.company.id, employee, context.workday);
    if (day == null) return fresh;
    return resolver.resolve(
      a,
      now,
      day: day,
      events: await local.events(a.company.id, employee, day.id),
      authority: authority,
      remoteAvailable: available,
    );
  }

  @override
  Future<Result<AttendanceContext>> getCurrentAttendance({
    AttendanceWorkMode workMode = AttendanceWorkMode.office,
  }) async {
    try {
      final session = await _session();
      if (session case Failed<AuthContext>(:final failure)) {
        return Failed(failure);
      }
      final a = (session as Success<AuthContext>).value;
      final available = await remote.isAvailable;
      return _db.transaction(
        () => _current(a, clock.now().toUtc(), workMode, available),
      );
    } catch (_) {
      return Failed(
        attendanceFailure(
          AttendanceFailureCode.persistenceFailure,
          retryable: true,
        ),
      );
    }
  }

  @override
  Stream<Result<AttendanceContext>> watchCurrentAttendance() =>
      _watchScoped((_) => getCurrentAttendance());
  Stream<Result<T>> _watchScoped<T>(
    Future<Result<T>> Function(AuthContext) read,
  ) {
    StreamSubscription<void>? database;
    StreamSubscription<AuthContext?>? session;
    final controller = StreamController<Result<T>>();
    var cancelled = false, generation = 0;
    Future<void> bind() async {
      final ticket = ++generation;
      await database?.cancel();
      database = null;
      if (cancelled || ticket != generation) return;
      final a = await _session();
      if (cancelled || ticket != generation) return;
      if (a case Failed<AuthContext>(:final failure)) {
        controller.add(Failed(failure));
        return;
      }
      final context = (a as Success<AuthContext>).value;
      database = local
          .changes(context.company.id, context.employeeReference!.id)
          .asyncMap((_) => read(context))
          .listen(
            (value) {
              if (!cancelled && ticket == generation) controller.add(value);
            },
            onError: (Object error) {
              if (!cancelled && ticket == generation) {
                controller.add(
                  Failed(
                    attendanceFailure(
                      AttendanceFailureCode.persistenceFailure,
                      retryable: true,
                    ),
                  ),
                );
              }
            },
          );
    }

    controller.onListen = () {
      session = auth.sessionChanges.listen((_) {
        unawaited(bind());
      });
      unawaited(bind());
    };
    controller.onCancel = () async {
      cancelled = true;
      generation++;
      await session?.cancel();
      await database?.cancel();
    };
    return controller.stream;
  }

  @override
  Future<Result<AttendanceDay?>> getAttendanceForDate(DateTime date) async {
    try {
      final session = await _session();
      if (session case Failed<AuthContext>(:final failure)) {
        return Failed(failure);
      }
      final a = (session as Success<AuthContext>).value;
      if (!a.user.permissions.contains(AppPermission.attendanceViewSelf)) {
        return Failed(
          attendanceFailure(AttendanceFailureCode.permissionDenied),
        );
      }
      return Success(
        await local.forDate(a.company.id, a.employeeReference!.id, date),
      );
    } catch (_) {
      return Failed(
        attendanceFailure(AttendanceFailureCode.persistenceFailure),
      );
    }
  }

  @override
  Stream<Result<List<AttendanceEvent>>> watchAttendanceEvents(
    String dayId,
  ) => _watchScoped((a) async {
    if (!a.user.permissions.contains(AppPermission.attendanceViewSelf)) {
      return Failed(attendanceFailure(AttendanceFailureCode.permissionDenied));
    }
    final day = await local.byId(a.company.id, a.employeeReference!.id, dayId);
    if (day == null) {
      return Failed(attendanceFailure(AttendanceFailureCode.permissionDenied));
    }
    return Success(
      await local.events(a.company.id, a.employeeReference!.id, dayId),
    );
  });
  @override
  Future<Result<AttendanceMutationResult>> execute(
    AttendanceCommand command,
  ) async {
    try {
      final available = await remote.isAvailable;
      return await _db.transaction(() async {
        final session = await _session();
        if (session case Failed<AuthContext>(:final failure)) {
          return Failed<AttendanceMutationResult>(failure);
        }
        final a = (session as Success<AuthContext>).value,
            now = attendanceInstant(clock.now());
        if (a.user.id != command.expectedUserId) {
          return Failed<AttendanceMutationResult>(
            attendanceFailure(AttendanceFailureCode.permissionDenied),
          );
        }
        if (!RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
        ).hasMatch(command.requestId)) {
          return Failed<AttendanceMutationResult>(
            attendanceFailure(AttendanceFailureCode.duplicateRequestId),
          );
        }
        if (command.source == AttendanceEventSource.manual ||
            command.source == AttendanceEventSource.kiosk) {
          return Failed<AttendanceMutationResult>(
            attendanceFailure(AttendanceFailureCode.permissionDenied),
          );
        }
        if (now.difference(command.deviceTimestamp.toUtc()).abs() >
            const Duration(seconds: 30)) {
          return Failed<AttendanceMutationResult>(
            attendanceFailure(AttendanceFailureCode.invalidTimestamp),
          );
        }
        final duplicate =
            await (_db.select(_db.attendanceEvents)
                  ..where((t) => t.requestId.equals(command.requestId)))
                .getSingleOrNull();
        if (duplicate != null) {
          return Failed<AttendanceMutationResult>(
            attendanceFailure(AttendanceFailureCode.duplicateRequestId),
          );
        }
        final resolved = await _current(
          a,
          command.deviceTimestamp.toUtc(),
          command.workMode,
          available,
        );
        if (resolved case Failed<AttendanceContext>(:final failure)) {
          return Failed<AttendanceMutationResult>(failure);
        }
        final c = (resolved as Success<AttendanceContext>).value;
        final decision = engine.decide(
          c,
          command.type,
          evidence: command.locationEvidence,
        );
        if (!decision.allowed) {
          return Failed<AttendanceMutationResult>(
            attendanceFailure(decision.failure!),
          );
        }
        final sync = authority == AttendanceAuthority.demoLocal
            ? AttendanceSyncStatus.synced
            : AttendanceSyncStatus.pending;
        final dayId = c.day?.id ?? const Uuid().v4();
        final event = AttendanceEvent(
          id: const Uuid().v4(),
          attendanceDayId: dayId,
          companyId: a.company.id,
          employeeId: c.employee.id,
          eventType: command.type,
          deviceTimestamp: attendanceInstant(command.deviceTimestamp),
          sequence: c.events.length,
          locationEvidence: command.locationEvidence?.copyWith(
            capturedAt: attendanceInstant(command.locationEvidence!.capturedAt),
          ),
          workLocationId: c.snapshot.workLocation?.id,
          locationValidation: decision.locationValidation,
          requestId: command.requestId,
          source: command.source,
          syncStatus: sync,
          createdAt: now,
        );
        final summary = const AttendanceSummaryCalculator().calculate([
          ...c.events,
          event,
        ], event.effectiveTimestamp);
        if (summary case Failed<AttendanceSummary>(:final failure)) {
          return Failed<AttendanceMutationResult>(failure);
        }
        final s = (summary as Success<AttendanceSummary>).value;
        final statuses = [...c.events.map((e) => e.syncStatus), sync];
        final combined = aggregateSync(statuses);
        final late = const AttendanceTimingEvaluator().isLate(
          c.snapshot,
          s.punchInTime!,
        );
        final day = AttendanceDay(
          id: dayId,
          companyId: a.company.id,
          employeeId: c.employee.id,
          attendanceDate: c.workday,
          snapshot: c.snapshot,
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
          syncStatus: combined,
          createdAt: c.day?.createdAt ?? now,
          updatedAt: now,
        );
        await local.putDay(day);
        await local.insertEvent(event);
        if (authority == AttendanceAuthority.productionPending) {
          await _db
              .into(_db.syncOutbox)
              .insert(
                SyncOutboxCompanion.insert(
                  id: command.requestId,
                  moduleId: 'attendance',
                  entityId: event.id,
                  operation: operationType(command.type),
                  payload: jsonEncode(event.toJson()),
                  createdAt: now,
                  companyId: Value(a.company.id),
                  requestId: Value(command.requestId),
                ),
              );
        }
        return Success(AttendanceMutationResult(day, event, decision));
      });
    } catch (_) {
      return Failed(
        attendanceFailure(
          AttendanceFailureCode.persistenceFailure,
          retryable: true,
        ),
      );
    }
  }

  @override
  Future<Result<void>> retryPendingOperation(String operationId) async {
    try {
      return await _db.transaction(() async {
        final session = await _session();
        if (session case Failed<AuthContext>(:final failure)) {
          return Failed<void>(failure);
        }
        final a = (session as Success<AuthContext>).value;
        final row =
            await (_db.select(_db.syncOutbox)..where(
                  (t) =>
                      t.id.equals(operationId) &
                      t.moduleId.equals('attendance') &
                      t.companyId.equals(a.company.id),
                ))
                .getSingleOrNull();
        if (row == null) {
          return Failed<void>(
            attendanceFailure(AttendanceFailureCode.operationNotFound),
          );
        }
        final event =
            await (_db.select(_db.attendanceEvents)..where(
                  (t) =>
                      t.id.equals(row.entityId) &
                      t.companyId.equals(a.company.id) &
                      t.employeeId.equals(a.employeeReference!.id),
                ))
                .getSingleOrNull();
        if (event == null) {
          return Failed<void>(
            attendanceFailure(AttendanceFailureCode.permissionDenied),
          );
        }
        if (event.syncStatus == 'rejected' || row.status == 'rejected') {
          return Failed<void>(
            attendanceFailure(AttendanceFailureCode.invalidAttendanceState),
          );
        }
        final current = await _current(
          a,
          clock.now(),
          AttendanceWorkMode.office,
          false,
        );
        if (current case Failed<AttendanceContext>(:final failure)) {
          return Failed<void>(failure);
        }
        final e = local.readEvent(event),
            day = await local.byId(
              a.company.id,
              a.employeeReference!.id,
              e.attendanceDayId,
            );
        if (day == null) {
          return Failed<void>(
            attendanceFailure(AttendanceFailureCode.invalidAttendanceState),
          );
        }
        await (_db.update(
          _db.syncOutbox,
        )..where((t) => t.id.equals(row.id))).write(
          const SyncOutboxCompanion(
            status: Value('pending'),
            failureCode: Value(null),
          ),
        );
        await (_db.update(
          _db.attendanceEvents,
        )..where((t) => t.id.equals(event.id))).write(
          const AttendanceEventsCompanion(syncStatus: Value('pending')),
        );
        final events = await local.events(
          a.company.id,
          a.employeeReference!.id,
          day.id,
        );
        await local.putDay(
          day.copyWith(
            syncStatus: aggregateSync(events.map((e) => e.syncStatus)),
            updatedAt: clock.now(),
          ),
        );
        // Only requeue. No network call, fake acceptance, new event or replacement request ID.
        return const Success<void>(null);
      });
    } catch (_) {
      return Failed(
        attendanceFailure(
          AttendanceFailureCode.persistenceFailure,
          retryable: true,
        ),
      );
    }
  }
}

String operationType(AttendanceEventType type) => switch (type) {
  AttendanceEventType.punchIn => 'attendancePunchIn',
  AttendanceEventType.breakStart => 'attendanceBreakStart',
  AttendanceEventType.breakEnd => 'attendanceBreakEnd',
  AttendanceEventType.punchOut => 'attendancePunchOut',
};
AttendanceSyncStatus aggregateSync(Iterable<AttendanceSyncStatus> statuses) {
  if (statuses.contains(AttendanceSyncStatus.rejected)) {
    return AttendanceSyncStatus.rejected;
  }
  if (statuses.contains(AttendanceSyncStatus.failed)) {
    return AttendanceSyncStatus.failed;
  }
  if (statuses.contains(AttendanceSyncStatus.pending)) {
    return AttendanceSyncStatus.pending;
  }
  return AttendanceSyncStatus.synced;
}
