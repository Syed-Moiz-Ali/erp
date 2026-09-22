import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../app/app_config.dart';
import '../../../core/errors/result.dart';
import '../../../core/security/app_permission.dart';
import '../../../core/utils/app_clock.dart';
import '../../auth/domain/entities/auth_context.dart';
import '../../auth/domain/repositories/auth_repository.dart';
import '../../notifications/domain/app_notification.dart';
import '../../notifications/domain/notification_repository.dart';
import '../domain/attendance_correction.dart';
import '../domain/attendance_correction_repository.dart';
import '../domain/attendance_correction_validator.dart';
import '../domain/attendance_models.dart';
import '../domain/attendance_summary_calculator.dart';
import 'attendance_local_data_source.dart';

/// All reads and writes are scoped to the active company and its live employee
/// relationship. Approved requests remain immutable audit records.
class LocalAttendanceCorrectionRepository
    implements AttendanceCorrectionRepository {
  LocalAttendanceCorrectionRepository(
    this.db,
    this.auth,
    this.clock, {
    this.demoEnabled = AppConfig.demoAuthEnabled,
    this.notifications,
  });
  final AppDatabase db;
  final AuthRepository auth;
  final AppClock clock;
  final bool demoEnabled;
  final NotificationRepository? notifications;
  final _validator = const AttendanceCorrectionValidator();
  AttendanceLocalDataSource get _days => AttendanceLocalDataSource(db);

  Failed<T> _fail<T>(String code) =>
      Failed(Failure(code: code, kind: FailureKind.invalidData));

  Future<void> _enqueue(
    String id,
    String company,
    String operation,
    Map<String, Object?> payload,
    DateTime now,
  ) async {
    if (demoEnabled) return;
    final operationId = const Uuid().v4();
    await db
        .into(db.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            id: operationId,
            moduleId: 'attendance-correction',
            entityId: id,
            operation: operation,
            payload: jsonEncode(payload),
            createdAt: now,
            companyId: Value(company),
            requestId: Value(operationId),
          ),
        );
  }

  Future<Result<AuthContext>> _actor() async {
    final result = await auth.checkSession();
    if (result is Failed<AuthContext?>) return Failed(result.failure);
    final actor = (result as Success<AuthContext?>).value;
    if (actor == null ||
        actor.user.status != AccountStatus.active ||
        !actor.company.enabledModules.contains('attendance')) {
      return _fail('attendanceUnavailable');
    }
    return Success(actor);
  }

  Future<bool> _visible(
    AuthContext actor,
    String employeeId, {
    bool review = false,
  }) async {
    final p = PermissionChecker(actor.user.permissions);
    if (review && !p.can(AppPermission.attendanceApprove)) return false;
    if (employeeId == actor.employeeReference?.id) return !review;
    if (p.can(AppPermission.attendanceViewAll)) return true;
    if (!p.can(AppPermission.attendanceViewTeam) ||
        actor.employeeReference == null) {
      return false;
    }
    final employee =
        await (db.select(db.workforceEmployees)..where(
              (t) =>
                  t.companyId.equals(actor.company.id) &
                  t.id.equals(employeeId),
            ))
            .getSingleOrNull();
    return employee?.managerId == actor.employeeReference!.id;
  }

  AttendanceCorrectionRequest _map(
    AttendanceCorrectionRequestData row, {
    EmployeeRecord? employee,
    String? department,
  }) => AttendanceCorrectionRequest(
    id: row.id,
    companyId: row.companyId,
    employeeId: row.employeeId,
    attendanceDayId: row.attendanceDayId,
    requestType: AttendanceCorrectionType.values.byName(row.requestType),
    status: AttendanceCorrectionStatus.values.byName(row.status),
    reason: row.reason,
    originalSnapshot: row.originalSnapshot,
    changes: (jsonDecode(row.requestedChanges) as List)
        .map(
          (e) => AttendanceCorrectionChange.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList(growable: false),
    requestedByUserId: row.requestedByUserId,
    requestedAt: DateTime.fromMillisecondsSinceEpoch(
      row.requestedMilliseconds,
      isUtc: true,
    ),
    reviewedByUserId: row.reviewedByUserId,
    reviewedAt: row.reviewedMilliseconds == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            row.reviewedMilliseconds!,
            isUtc: true,
          ),
    reviewNote: row.reviewNote,
    employeeName: employee == null
        ? null
        : '${employee.firstName} ${employee.lastName}'.trim(),
    employeeCode: employee?.employeeCode,
    departmentName: department,
    syncStatus: AttendanceSyncStatus.values.byName(row.syncStatus),
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      row.createdMilliseconds,
      isUtc: true,
    ),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      row.updatedMilliseconds,
      isUtc: true,
    ),
  );

  Future<Result<List<AttendanceCorrectionRequest>>> _list({
    bool review = false,
  }) async {
    final session = await _actor();
    if (session is Failed<AuthContext>) return Failed(session.failure);
    final actor = (session as Success<AuthContext>).value;
    final p = PermissionChecker(actor.user.permissions);
    if (review && !p.can(AppPermission.attendanceApprove)) {
      return _fail('correctionPermissionDenied');
    }
    if (!review && !p.can(AppPermission.attendanceRequestCorrection)) {
      return _fail('correctionPermissionDenied');
    }
    final query = db.select(db.attendanceCorrectionRequests)
      ..where((t) => t.companyId.equals(actor.company.id))
      ..orderBy([(t) => OrderingTerm.desc(t.requestedMilliseconds)]);
    if (!review) {
      query.where(
        (t) => t.employeeId.equals(actor.employeeReference?.id ?? ''),
      );
    } else if (!p.can(AppPermission.attendanceViewAll)) {
      if (!p.can(AppPermission.attendanceViewTeam) ||
          actor.employeeReference == null) {
        return _fail('correctionPermissionDenied');
      }
      final team =
          await (db.select(db.workforceEmployees)..where(
                (t) =>
                    t.companyId.equals(actor.company.id) &
                    t.managerId.equals(actor.employeeReference!.id),
              ))
              .get();
      if (team.isEmpty) return const Success([]);
      query.where((t) => t.employeeId.isIn(team.map((e) => e.id)));
    }
    final rows = await query.get();
    final employees = rows.isEmpty
        ? <EmployeeRecord>[]
        : await (db.select(db.workforceEmployees)..where(
                (t) =>
                    t.companyId.equals(actor.company.id) &
                    t.id.isIn(rows.map((r) => r.employeeId)),
              ))
              .get();
    final byId = {for (final e in employees) e.id: e};
    final departments = employees.isEmpty
        ? <WorkforceDepartment>[]
        : await (db.select(db.workforceDepartments)..where(
                (t) =>
                    t.companyId.equals(actor.company.id) &
                    t.id.isIn(employees.map((e) => e.departmentId)),
              ))
              .get();
    final deptById = {for (final d in departments) d.id: d.name};
    final latest = await _actor();
    if (latest is Failed<AuthContext> ||
        (latest as Success<AuthContext>).value.user.id != actor.user.id) {
      return _fail('correctionSessionChanged');
    }
    return Success(
      rows
          .map(
            (r) => _map(
              r,
              employee: byId[r.employeeId],
              department: deptById[byId[r.employeeId]?.departmentId],
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Stream<Result<List<AttendanceCorrectionRequest>>> watchMyRequests() async* {
    await for (final _ in db.select(db.attendanceCorrectionRequests).watch()) {
      yield await _list();
    }
  }

  @override
  Stream<Result<List<AttendanceCorrectionRequest>>>
  watchPendingRequests() async* {
    await for (final _ in db.select(db.attendanceCorrectionRequests).watch()) {
      yield await _list(review: true);
    }
  }

  @override
  Future<Result<AttendanceCorrectionRequest?>> getRequestById(String id) async {
    final session = await _actor();
    if (session is Failed<AuthContext>) return Failed(session.failure);
    final actor = (session as Success<AuthContext>).value;
    if (!PermissionChecker(actor.user.permissions).canAny({
      AppPermission.attendanceRequestCorrection,
      AppPermission.attendanceApprove,
    })) {
      return _fail('correctionPermissionDenied');
    }
    final row =
        await (db.select(db.attendanceCorrectionRequests)..where(
              (t) => t.id.equals(id) & t.companyId.equals(actor.company.id),
            ))
            .getSingleOrNull();
    if (row == null) return const Success(null);
    if (!await _visible(actor, row.employeeId)) {
      return _fail('correctionNotFound');
    }
    final employee =
        await (db.select(db.workforceEmployees)..where(
              (t) =>
                  t.companyId.equals(actor.company.id) &
                  t.id.equals(row.employeeId),
            ))
            .getSingleOrNull();
    return Success(_map(row, employee: employee));
  }

  Future<List<AttendanceEvent>> _effective(
    String company,
    String employee,
    String dayId,
    DateTime now,
  ) async {
    var events = await _days.events(company, employee, dayId);
    final approved =
        await (db.select(db.attendanceCorrectionRequests)
              ..where(
                (t) =>
                    t.companyId.equals(company) &
                    t.employeeId.equals(employee) &
                    t.attendanceDayId.equals(dayId) &
                    t.status.equals('approved'),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.reviewedMilliseconds)]))
            .get();
    for (final row in approved) {
      final request = _map(row);
      final projection = _validator.project(
        events,
        request.changes,
        now,
        requestId: request.id,
      );
      if (projection is Success<List<AttendanceEvent>>) {
        events = projection.value;
      }
    }
    return events;
  }

  Future<List<AttendanceEvent>> effectiveEvents(
    String company,
    String employee,
    String dayId,
  ) => _effective(company, employee, dayId, clock.now().toUtc());

  Future<List<AttendanceCorrectionRequest>> approvedForDay(
    String company,
    String employee,
    String dayId,
  ) async =>
      (await (db.select(db.attendanceCorrectionRequests)
                ..where(
                  (t) =>
                      t.companyId.equals(company) &
                      t.employeeId.equals(employee) &
                      t.attendanceDayId.equals(dayId) &
                      t.status.equals('approved'),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.reviewedMilliseconds)]))
              .get())
          .map(_map)
          .toList(growable: false);

  @override
  Future<Result<AttendanceCorrectionRequest>> createRequest(
    AttendanceCorrectionRequest request,
  ) async {
    final session = await _actor();
    if (session is Failed<AuthContext>) return Failed(session.failure);
    final actor = (session as Success<AuthContext>).value;
    if (!actor.user.permissions.contains(
          AppPermission.attendanceRequestCorrection,
        ) ||
        actor.employeeReference?.id != request.employeeId ||
        actor.company.id != request.companyId ||
        actor.user.id != request.requestedByUserId ||
        request.reason.trim().isEmpty ||
        request.reason.trim().length > 1000 ||
        request.status != AttendanceCorrectionStatus.pending) {
      return _fail('correctionInvalidRequest');
    }
    return db.transaction(() async {
      final day = await _days.byId(
        actor.company.id,
        request.employeeId,
        request.attendanceDayId,
      );
      if (day == null) return _fail('correctionDayNotFound');
      if (!day.snapshot.policy.allowEmployeeCorrectionRequest) {
        return _fail('correctionPolicyDisabled');
      }
      final pending =
          await (db.select(db.attendanceCorrectionRequests)..where(
                (t) =>
                    t.companyId.equals(actor.company.id) &
                    t.attendanceDayId.equals(day.id) &
                    t.status.equals('pending'),
              ))
              .get();
      final targets = request.changes
          .map((e) => e.originalEventId ?? e.eventType.name)
          .toSet();
      for (final row in pending) {
        if (_map(row).changes.any(
          (e) => targets.contains(e.originalEventId ?? e.eventType.name),
        )) {
          return _fail('correctionAlreadyPending');
        }
      }
      final now = clock.now().toUtc();
      final events = await _effective(
        actor.company.id,
        request.employeeId,
        day.id,
        now,
      );
      final preview = _validator.validate(events, request.changes, now);
      if (preview is Failed<AttendanceSummary>) return Failed(preview.failure);
      final id = request.id.isEmpty ? const Uuid().v4() : request.id;
      final snapshot = jsonEncode({
        'day': day.toJson(),
        'events': events.map((e) => e.toJson()).toList(),
      });
      await db
          .into(db.attendanceCorrectionRequests)
          .insert(
            AttendanceCorrectionRequestsCompanion.insert(
              id: id,
              companyId: actor.company.id,
              employeeId: request.employeeId,
              attendanceDayId: day.id,
              requestType: request.requestType.name,
              status: AttendanceCorrectionStatus.pending.name,
              reason: request.reason.trim(),
              originalSnapshot: snapshot,
              requestedChanges: request.changesJson,
              requestedByUserId: actor.user.id,
              requestedMilliseconds: now.millisecondsSinceEpoch,
              syncStatus: demoEnabled
                  ? AttendanceSyncStatus.synced.name
                  : AttendanceSyncStatus.pending.name,
              createdMilliseconds: now.millisecondsSinceEpoch,
              updatedMilliseconds: now.millisecondsSinceEpoch,
            ),
          );
      await _enqueue(id, actor.company.id, 'request', {
        'requestId': id,
        'attendanceDayId': day.id,
        'changes': request.changes.map((e) => e.toJson()).toList(),
        'reason': request.reason.trim(),
      }, now);
      final stored = await (db.select(
        db.attendanceCorrectionRequests,
      )..where((t) => t.id.equals(id))).getSingle();
      return Success(_map(stored));
    });
  }

  @override
  Future<Result<void>> cancelRequest(String id) async {
    final session = await _actor();
    if (session is Failed<AuthContext>) return Failed(session.failure);
    final actor = (session as Success<AuthContext>).value;
    final now = clock.now().toUtc();
    return db.transaction(() async {
      final changed =
          await (db.update(db.attendanceCorrectionRequests)..where(
                (t) =>
                    t.id.equals(id) &
                    t.companyId.equals(actor.company.id) &
                    t.employeeId.equals(actor.employeeReference?.id ?? '') &
                    t.status.equals('pending'),
              ))
              .write(
                AttendanceCorrectionRequestsCompanion(
                  status: const Value('cancelled'),
                  updatedMilliseconds: Value(now.millisecondsSinceEpoch),
                  syncStatus: Value(
                    demoEnabled
                        ? AttendanceSyncStatus.synced.name
                        : AttendanceSyncStatus.pending.name,
                  ),
                ),
              );
      if (changed != 1) return _fail('correctionNotCancellable');
      await _enqueue(id, actor.company.id, 'cancel', {'requestId': id}, now);
      return const Success(null);
    });
  }

  Future<Result<AttendanceCorrectionRequest>> _review(
    String id,
    String reviewerId,
    String status,
    String? note,
  ) async {
    final session = await _actor();
    if (session is Failed<AuthContext>) return Failed(session.failure);
    final actor = (session as Success<AuthContext>).value;
    if (actor.user.id != reviewerId ||
        !actor.user.permissions.contains(AppPermission.attendanceApprove)) {
      return _fail('correctionPermissionDenied');
    }
    if (status == 'rejected' && (note == null || note.trim().isEmpty)) {
      return _fail('correctionReviewNoteRequired');
    }
    return db.transaction(() async {
      final row =
          await (db.select(db.attendanceCorrectionRequests)..where(
                (t) => t.id.equals(id) & t.companyId.equals(actor.company.id),
              ))
              .getSingleOrNull();
      if (row == null) return _fail('correctionNotFound');
      if (row.status != 'pending') return _fail('correctionAlreadyReviewed');
      if (row.requestedByUserId == actor.user.id ||
          !await _visible(actor, row.employeeId, review: true)) {
        return _fail('correctionPermissionDenied');
      }
      final now = clock.now().toUtc();
      if (status == 'approved') {
        final day = await _days.byId(
          actor.company.id,
          row.employeeId,
          row.attendanceDayId,
        );
        if (day == null) return _fail('correctionDayNotFound');
        final events = await _effective(
          actor.company.id,
          row.employeeId,
          day.id,
          now,
        );
        final projection = _validator.project(
          events,
          _map(row).changes,
          now,
          requestId: row.id,
        );
        if (projection is Failed<List<AttendanceEvent>>) {
          return Failed(projection.failure);
        }
        final summary = const AttendanceSummaryCalculator().calculate(
          (projection as Success<List<AttendanceEvent>>).value,
          now,
        );
        if (summary is Failed<AttendanceSummary>) {
          return Failed(summary.failure);
        }
        final value = (summary as Success<AttendanceSummary>).value;
        await (db.update(db.attendanceDays)..where(
              (t) =>
                  t.id.equals(day.id) &
                  t.companyId.equals(actor.company.id) &
                  t.employeeId.equals(row.employeeId),
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
                elapsedMilliseconds: Value(
                  value.elapsedDuration.inMilliseconds,
                ),
                workMilliseconds: Value(value.workDuration.inMilliseconds),
                breakMilliseconds: Value(value.breakDuration.inMilliseconds),
                status: Value(
                  value.punchInTime != null &&
                          value.punchInTime!.isAfter(
                            day.snapshot.scheduledStart.add(
                              Duration(
                                minutes: day.snapshot.shift.gracePeriodMinutes,
                              ),
                            ),
                          )
                      ? AttendanceDayStatus.late.name
                      : value.currentState == AttendanceWorkdayState.completed
                      ? AttendanceDayStatus.completed.name
                      : AttendanceDayStatus.working.name,
                ),
                updatedMilliseconds: Value(now.millisecondsSinceEpoch),
              ),
            );
      }
      final changed =
          await (db.update(
            db.attendanceCorrectionRequests,
          )..where((t) => t.id.equals(id) & t.status.equals('pending'))).write(
            AttendanceCorrectionRequestsCompanion(
              status: Value(status),
              reviewedByUserId: Value(actor.user.id),
              reviewedMilliseconds: Value(now.millisecondsSinceEpoch),
              reviewNote: Value(note?.trim()),
              updatedMilliseconds: Value(now.millisecondsSinceEpoch),
              syncStatus: Value(
                demoEnabled
                    ? AttendanceSyncStatus.synced.name
                    : AttendanceSyncStatus.pending.name,
              ),
            ),
          );
      if (changed != 1) return _fail('correctionAlreadyReviewed');
      await _enqueue(id, actor.company.id, status, {
        'requestId': id,
        'reviewerId': actor.user.id,
        'note': note?.trim(),
      }, now);
      await _notifyOutcome(actor, row, status, now);
      final updated = await (db.select(
        db.attendanceCorrectionRequests,
      )..where((t) => t.id.equals(id))).getSingle();
      return Success(_map(updated));
    });
  }

  /// In-app notification for the requesting user; content is localized at
  /// render time, so no translated strings are persisted.
  Future<void> _notifyOutcome(
    AuthContext actor,
    AttendanceCorrectionRequestData row,
    String status,
    DateTime now,
  ) async {
    final repository = notifications;
    if (repository == null) return;
    await repository.createLocal(
      AppNotification(
        id: const Uuid().v4(),
        companyId: actor.company.id,
        userId: row.requestedByUserId,
        type: status == 'approved'
            ? AppNotificationType.correctionApproved
            : AppNotificationType.correctionRejected,
        priority: AppNotificationPriority.normal,
        dedupeKey: 'correctionReview:${row.id}:$status',
        payload: {'correctionId': row.id, 'dayId': row.attendanceDayId},
        createdAt: now,
      ),
    );
  }

  @override
  Future<Result<AttendanceCorrectionRequest>> approveRequest(
    String id, {
    required String reviewerId,
    String? note,
  }) => _review(id, reviewerId, 'approved', note);

  @override
  Future<Result<AttendanceCorrectionRequest>> rejectRequest(
    String id, {
    required String reviewerId,
    required String note,
  }) => _review(id, reviewerId, 'rejected', note);
}
