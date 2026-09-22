import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/errors/result.dart';
import '../../../core/models/configuration_record.dart';
import '../../../core/security/app_permission.dart';
import '../../../core/utils/app_clock.dart';
import '../../../app/app_config.dart';
import '../../auth/domain/entities/auth_context.dart';
import '../../auth/domain/repositories/auth_repository.dart';
import '../../employees/domain/employee.dart';
import '../../notifications/domain/app_notification.dart';
import '../../notifications/domain/notification_repository.dart';
import '../domain/leave_models.dart';
import '../domain/leave_repository.dart';
import '../domain/leave_services.dart';

class LocalLeaveRepository implements LeaveRepository {
  const LocalLeaveRepository(
    this.db,
    this.auth,
    this.clock, {
    this.notifications,
    this.demoEnabled = AppConfig.demoAuthEnabled,
    this.calculator = const LeaveDayCalculator(),
    this.yearResolver = const LeaveYearResolver(),
  });

  final AppDatabase db;
  final AuthRepository auth;
  final AppClock clock;
  final NotificationRepository? notifications;
  final bool demoEnabled;
  final LeaveDayCalculator calculator;
  final LeaveYearResolver yearResolver;

  Failed<T> _fail<T>(
    String code, {
    FailureKind kind = FailureKind.invalidData,
  }) => Failed(Failure(code: code, kind: kind));

  bool _can(AuthContext actor, AppPermission permission) =>
      PermissionChecker(actor.user.permissions).can(permission);

  DateTime get _companyToday {
    final now = clock.now().toUtc();
    return DateTime.utc(now.year, now.month, now.day);
  }

  String _d(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  DateTime _parseDate(String value) => leaveDate(DateTime.parse(value));

  DateTime? _toDate(int? value) => value == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);

  // ---- configuration streams ----------------------------------------------

  @override
  Stream<Result<List<LeaveType>>> watchLeaveTypes(
    AuthContext context, {
    bool includeInactive = false,
  }) {
    final query = db.select(db.leaveTypes)
      ..where((t) => t.companyId.equals(context.company.id))
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    if (!includeInactive) {
      query.where((t) => t.status.equals('active'));
    }
    return query.watch().map((rows) {
      if (!_can(context, AppPermission.leaveTypeView) &&
          !_can(context, AppPermission.leaveRequest) &&
          !_can(context, AppPermission.leaveViewSelf)) {
        return _fail('leavePermissionDenied');
      }
      return Success(rows.map(_mapType).toList());
    });
  }

  @override
  Future<Result<LeaveType>> saveLeaveType(
    AuthContext context,
    LeaveTypeDraft draft, {
    String? id,
  }) async {
    if (!_can(context, AppPermission.leaveTypeManage)) {
      return _fail('leavePermissionDenied');
    }
    try {
      final now = clock.now().toUtc();
      final typeId = id ?? const Uuid().v4();
      final existing = await (db.select(
        db.leaveTypes,
      )..where((t) => t.id.equals(typeId))).getSingleOrNull();
      final companion = LeaveTypesCompanion.insert(
        id: typeId,
        companyId: context.company.id,
        name: draft.name.trim(),
        code: draft.code.trim().toUpperCase(),
        description: Value(draft.description.trim()),
        compensation: Value(draft.compensation.name),
        requiresApproval: Value(draft.requiresApproval),
        allowsHalfDay: Value(draft.allowsHalfDay),
        requiresReason: Value(draft.requiresReason),
        requiresAttachment: Value(draft.requiresAttachment),
        colorKey: Value(draft.colorKey),
        createdMilliseconds:
            existing?.createdMilliseconds ?? now.millisecondsSinceEpoch,
        updatedMilliseconds: now.millisecondsSinceEpoch,
      );
      if (existing == null) {
        await db.into(db.leaveTypes).insert(companion);
        await _enqueue(context, 'leaveType.create', typeId, draft.code);
      } else {
        await (db.update(
          db.leaveTypes,
        )..where((t) => t.id.equals(typeId))).write(companion);
        await _enqueue(context, 'leaveType.update', typeId, draft.code);
      }
      final row = await (db.select(
        db.leaveTypes,
      )..where((t) => t.id.equals(typeId))).getSingle();
      return Success(_mapType(row));
    } catch (_) {
      return _fail('duplicateName', kind: FailureKind.storageWrite);
    }
  }

  @override
  Future<Result<void>> setLeaveTypeStatus(
    AuthContext context,
    String id,
    bool active,
  ) async {
    if (!_can(context, AppPermission.leaveTypeManage)) {
      return _fail('leavePermissionDenied');
    }
    await (db.update(db.leaveTypes)..where(
          (t) => t.id.equals(id) & t.companyId.equals(context.company.id),
        ))
        .write(
          LeaveTypesCompanion(
            status: Value(active ? 'active' : 'inactive'),
            updatedMilliseconds: Value(
              clock.now().toUtc().millisecondsSinceEpoch,
            ),
          ),
        );
    return const Success(null);
  }

  @override
  Stream<Result<List<LeavePolicy>>> watchLeavePolicies(
    AuthContext context, {
    bool includeInactive = false,
  }) {
    final query = db.select(db.leavePolicies)
      ..where((t) => t.companyId.equals(context.company.id))
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    if (!includeInactive) query.where((t) => t.status.equals('active'));
    return query.watch().map((rows) {
      if (!_can(context, AppPermission.leavePolicyView) &&
          !_can(context, AppPermission.leaveRequest) &&
          !_can(context, AppPermission.leaveViewSelf)) {
        return _fail('leavePermissionDenied');
      }
      return Success(rows.map(_mapPolicy).toList());
    });
  }

  @override
  Future<Result<LeavePolicy>> saveLeavePolicy(
    AuthContext context,
    LeavePolicyDraft draft, {
    String? id,
  }) async {
    if (!_can(context, AppPermission.leavePolicyManage)) {
      return _fail('leavePermissionDenied');
    }
    try {
      final now = clock.now().toUtc();
      final policyId = id ?? const Uuid().v4();
      final existing = await (db.select(
        db.leavePolicies,
      )..where((t) => t.id.equals(policyId))).getSingleOrNull();
      final companion = LeavePoliciesCompanion.insert(
        id: policyId,
        companyId: context.company.id,
        name: draft.name.trim(),
        code: draft.code.trim().toUpperCase(),
        leaveTypeId: draft.leaveTypeId,
        annualEntitlementDays: Value(draft.annualEntitlementDays),
        allowHalfDay: Value(draft.allowHalfDay),
        minimumRequestDays: Value(draft.minimumRequestDays),
        maximumConsecutiveDays: Value(draft.maximumConsecutiveDays),
        advanceNoticeDays: Value(draft.advanceNoticeDays),
        allowPastRequest: Value(draft.allowPastRequest),
        pastRequestWindowDays: Value(draft.pastRequestWindowDays),
        requiresAttachmentAfterDays: Value(draft.requiresAttachmentAfterDays),
        allowNegativeBalance: Value(draft.allowNegativeBalance),
        carryForwardEnabled: Value(draft.carryForwardEnabled),
        carryForwardLimitDays: Value(draft.carryForwardLimitDays),
        applicableEmploymentTypes: Value(
          jsonEncode([
            for (final type in draft.applicableEmploymentTypes) type.name,
          ]),
        ),
        createdMilliseconds:
            existing?.createdMilliseconds ?? now.millisecondsSinceEpoch,
        updatedMilliseconds: now.millisecondsSinceEpoch,
      );
      if (existing == null) {
        await db.into(db.leavePolicies).insert(companion);
        await _enqueue(context, 'leavePolicy.create', policyId, draft.code);
      } else {
        await (db.update(
          db.leavePolicies,
        )..where((t) => t.id.equals(policyId))).write(companion);
        await _enqueue(context, 'leavePolicy.update', policyId, draft.code);
      }
      final row = await (db.select(
        db.leavePolicies,
      )..where((t) => t.id.equals(policyId))).getSingle();
      return Success(_mapPolicy(row));
    } catch (_) {
      return _fail('duplicateName', kind: FailureKind.storageWrite);
    }
  }

  @override
  Future<Result<void>> setLeavePolicyStatus(
    AuthContext context,
    String id,
    bool active,
  ) async {
    if (!_can(context, AppPermission.leavePolicyManage)) {
      return _fail('leavePermissionDenied');
    }
    await (db.update(db.leavePolicies)..where(
          (t) => t.id.equals(id) & t.companyId.equals(context.company.id),
        ))
        .write(
          LeavePoliciesCompanion(
            status: Value(active ? 'active' : 'inactive'),
            updatedMilliseconds: Value(
              clock.now().toUtc().millisecondsSinceEpoch,
            ),
          ),
        );
    return const Success(null);
  }

  @override
  Stream<Result<List<Holiday>>> watchHolidays(
    AuthContext context, {
    bool includeInactive = false,
  }) {
    final query = db.select(db.holidays)
      ..where((t) => t.companyId.equals(context.company.id))
      ..orderBy([(t) => OrderingTerm.asc(t.date)]);
    if (!includeInactive) query.where((t) => t.status.equals('active'));
    return query.watch().map((rows) {
      if (!_can(context, AppPermission.holidayView) &&
          !_can(context, AppPermission.leaveViewSelf)) {
        return _fail('leavePermissionDenied');
      }
      return Success(rows.map(_mapHoliday).toList());
    });
  }

  @override
  Future<Result<Holiday>> saveHoliday(
    AuthContext context,
    HolidayDraft draft, {
    String? id,
  }) async {
    if (!_can(context, AppPermission.holidayManage)) {
      return _fail('leavePermissionDenied');
    }
    try {
      final now = clock.now().toUtc();
      final holidayId = id ?? const Uuid().v4();
      final existing = await (db.select(
        db.holidays,
      )..where((t) => t.id.equals(holidayId))).getSingleOrNull();
      final companion = HolidaysCompanion.insert(
        id: holidayId,
        companyId: context.company.id,
        name: draft.name.trim(),
        date: _d(leaveDate(draft.date!)),
        endDate: Value(
          draft.endDate == null ? null : _d(leaveDate(draft.endDate!)),
        ),
        type: Value(draft.type.name),
        scope: Value(draft.scope.name),
        workLocationIds: Value(jsonEncode(draft.workLocationIds.toList())),
        description: Value(draft.description.trim()),
        isOptional: Value(draft.isOptional),
        createdMilliseconds:
            existing?.createdMilliseconds ?? now.millisecondsSinceEpoch,
        updatedMilliseconds: now.millisecondsSinceEpoch,
      );
      if (existing == null) {
        await db.into(db.holidays).insert(companion);
        await _enqueue(context, 'holiday.create', holidayId, draft.name);
      } else {
        await (db.update(
          db.holidays,
        )..where((t) => t.id.equals(holidayId))).write(companion);
        await _enqueue(context, 'holiday.update', holidayId, draft.name);
      }
      final row = await (db.select(
        db.holidays,
      )..where((t) => t.id.equals(holidayId))).getSingle();
      return Success(_mapHoliday(row));
    } catch (_) {
      return _fail('leaveStorageError', kind: FailureKind.storageWrite);
    }
  }

  @override
  Future<Result<void>> setHolidayStatus(
    AuthContext context,
    String id,
    bool active,
  ) async {
    if (!_can(context, AppPermission.holidayManage)) {
      return _fail('leavePermissionDenied');
    }
    await (db.update(db.holidays)..where(
          (t) => t.id.equals(id) & t.companyId.equals(context.company.id),
        ))
        .write(
          HolidaysCompanion(
            status: Value(active ? 'active' : 'inactive'),
            updatedMilliseconds: Value(
              clock.now().toUtc().millisecondsSinceEpoch,
            ),
          ),
        );
    return const Success(null);
  }

  // ---- request support -----------------------------------------------------

  Future<Set<int>> _workingWeekdays(String companyId, String? shiftId) async {
    if (shiftId == null) return const {1, 2, 3, 4, 5};
    final row =
        await (db.select(db.shiftRecords)..where(
              (t) => t.id.equals(shiftId) & t.companyId.equals(companyId),
            ))
            .getSingleOrNull();
    if (row == null) return const {1, 2, 3, 4, 5};
    return {
      for (var weekday = 1; weekday <= 7; weekday++)
        if ((row.workingDayMask & (1 << (weekday - 1))) != 0) weekday,
    };
  }

  Future<String?> _employeeWorkLocation(
    String companyId,
    String employeeId,
  ) async {
    final row =
        await (db.select(db.workforceEmployees)..where(
              (t) => t.id.equals(employeeId) & t.companyId.equals(companyId),
            ))
            .getSingleOrNull();
    return row?.workLocationId;
  }

  Future<String?> _employeeShift(String companyId, String employeeId) async {
    final row =
        await (db.select(db.workforceEmployees)..where(
              (t) => t.id.equals(employeeId) & t.companyId.equals(companyId),
            ))
            .getSingleOrNull();
    return row?.shiftId;
  }

  Future<Set<String>> _holidayDates(
    String companyId,
    String? workLocationId,
    DateTime from,
    DateTime to,
  ) async {
    final rows =
        await (db.select(db.holidays)..where(
              (t) =>
                  t.companyId.equals(companyId) &
                  t.status.equals('active') &
                  t.isOptional.equals(false) &
                  t.date.isSmallerOrEqualValue(_d(to)),
            ))
            .get();
    final result = <String>{};
    for (final row in rows) {
      final scopeOk =
          row.scope == HolidayScope.companyWide.name ||
          (row.scope == HolidayScope.specificWorkLocations.name &&
              workLocationId != null &&
              (jsonDecode(row.workLocationIds) as List).contains(
                workLocationId,
              ));
      if (!scopeOk) continue;
      final start = _parseDate(row.date);
      final end = row.endDate == null ? start : _parseDate(row.endDate!);
      if (end.isBefore(from) || start.isAfter(to)) continue;
      for (
        var day = start;
        !day.isAfter(end);
        day = day.add(const Duration(days: 1))
      ) {
        result.add(_d(day));
      }
    }
    return result;
  }

  Future<LeaveTypeData?> _activeType(String companyId, String typeId) =>
      (db.select(db.leaveTypes)..where(
            (t) =>
                t.id.equals(typeId) &
                t.companyId.equals(companyId) &
                t.status.equals('active'),
          ))
          .getSingleOrNull();

  Future<LeavePolicyData?> _policyForType(
    String companyId,
    String employeeId,
    String typeId,
  ) async {
    // Effective-dated assignment first, else any active policy for the type.
    final assignment =
        await (db.select(db.employeeLeavePolicyAssignments)..where(
              (t) =>
                  t.companyId.equals(companyId) &
                  t.employeeId.equals(employeeId) &
                  t.status.equals('active'),
            ))
            .get();
    for (final a in assignment) {
      final policy =
          await (db.select(db.leavePolicies)..where(
                (t) =>
                    t.id.equals(a.policyId) &
                    t.companyId.equals(companyId) &
                    t.leaveTypeId.equals(typeId) &
                    t.status.equals('active'),
              ))
              .getSingleOrNull();
      if (policy != null) return policy;
    }
    return (db.select(db.leavePolicies)..where(
          (t) =>
              t.companyId.equals(companyId) &
              t.leaveTypeId.equals(typeId) &
              t.status.equals('active'),
        ))
        .getSingleOrNull();
  }

  Future<double> _availableDays(
    String companyId,
    String employeeId,
    String leaveTypeId,
    int year,
  ) async {
    final ledger =
        await (db.select(db.leaveBalanceTransactions)..where(
              (t) =>
                  t.companyId.equals(companyId) &
                  t.employeeId.equals(employeeId) &
                  t.leaveTypeId.equals(leaveTypeId) &
                  t.leaveYear.equals(year),
            ))
            .get();
    var entitlement = 0.0;
    for (final t in ledger) {
      entitlement += switch (t.type) {
        'entitlement' ||
        'carryForward' ||
        'migration' ||
        'adjustmentAdd' => t.quantityDays,
        'adjustmentSubtract' || 'expiry' => -t.quantityDays,
        _ => 0.0,
      };
    }
    final yearPrefix = year.toString().padLeft(4, '0');
    final requests =
        await (db.select(db.leaveRequests)..where(
              (t) =>
                  t.companyId.equals(companyId) &
                  t.employeeId.equals(employeeId) &
                  t.status.isIn(['approved', 'pending']) &
                  t.startDate.like('$yearPrefix%'),
            ))
            .get();
    var used = 0.0, pending = 0.0;
    for (final r in requests) {
      final snapshot = LeaveTypeSnapshot.fromJson(
        jsonDecode(r.typeSnapshot) as Map<String, dynamic>,
      );
      if (snapshot.typeId != leaveTypeId) continue;
      if (r.status == 'approved') {
        used += r.requestedDays;
      } else {
        pending += r.requestedDays;
      }
    }
    return entitlement - used - pending;
  }

  @override
  Future<Result<LeaveRequestPreview>> previewRequest(
    AuthContext context,
    LeaveRequestDraft draft,
  ) async {
    try {
      final type = await _activeType(context.company.id, draft.leaveTypeId);
      if (type == null) return _fail('leaveTypeInactive');
      final employeeId = context.employeeReference?.id;
      if (employeeId == null) return _fail('leaveNoEmployee');
      final workLocationId = await _employeeWorkLocation(
        context.company.id,
        employeeId,
      );
      final shiftId = await _employeeShift(context.company.id, employeeId);
      final weekdays = await _workingWeekdays(context.company.id, shiftId);
      final holidays = await _holidayDates(
        context.company.id,
        workLocationId,
        leaveDraftStart(draft),
        leaveDraftEnd(draft),
      );
      final calc = calculator.calculate(
        startDate: draft.startDate,
        endDate: draft.endDate,
        workingWeekdays: weekdays,
        holidayDates: holidays,
        startPortion: draft.startPortion,
        endPortion: draft.endPortion,
        allowHalfDay: type.allowsHalfDay,
      );
      final year = yearResolver.yearFor(leaveDate(draft.startDate));
      final available = await _availableDays(
        context.company.id,
        employeeId,
        draft.leaveTypeId,
        year,
      );
      final typeSnapshot = _mapType(type);
      return Success(
        LeaveRequestPreview(
          leaveTypeName: typeSnapshot.name,
          requestedDays: calc.quantityDays,
          excludedWeekends: calc.excludedWeekends,
          excludedHolidays: calc.excludedHolidays,
          available: available,
          afterApproval: available - calc.quantityDays,
          requiresReason: typeSnapshot.requiresReason,
        ),
      );
    } catch (_) {
      return _fail('leaveStorageError', kind: FailureKind.unknown);
    }
  }

  DateTime leaveDraftStart(LeaveRequestDraft draft) =>
      leaveDate(draft.startDate);
  DateTime leaveDraftEnd(LeaveRequestDraft draft) => leaveDate(draft.endDate);

  @override
  Future<Result<LeaveRequest>> submitRequest(
    AuthContext context,
    LeaveRequestDraft draft,
  ) async {
    final actor = context;
    if (!_can(actor, AppPermission.leaveRequest)) {
      return _fail('leavePermissionDenied');
    }
    final employeeId = actor.employeeReference?.id;
    if (employeeId == null) return _fail('leaveNoEmployee');
    final start = leaveDate(draft.startDate);
    final end = leaveDate(draft.endDate);
    if (end.isBefore(start)) return _fail('leaveInvalidDateRange');
    try {
      return await db.transaction(() async {
        final type = await _activeType(actor.company.id, draft.leaveTypeId);
        if (type == null) return _fail<LeaveRequest>('leaveTypeInactive');
        final typeModel = _mapType(type);
        if (typeModel.requiresReason && draft.reason.trim().isEmpty) {
          return _fail<LeaveRequest>('leaveReasonRequired');
        }
        final policy = await _policyForType(
          actor.company.id,
          employeeId,
          draft.leaveTypeId,
        );
        final today = _companyToday;
        if (policy != null &&
            !policy.allowPastRequest &&
            start.isBefore(today)) {
          final window = policy.pastRequestWindowDays;
          if (window == 0 || today.difference(start).inDays > window) {
            return _fail<LeaveRequest>('leavePastRequestNotAllowed');
          }
        }
        if (policy != null && policy.advanceNoticeDays > 0) {
          final notice = start.difference(today).inDays;
          if (notice >= 0 && notice < policy.advanceNoticeDays) {
            return _fail<LeaveRequest>('leaveAdvanceNoticeRequired');
          }
        }
        final workLocationId = await _employeeWorkLocation(
          actor.company.id,
          employeeId,
        );
        final shiftId = await _employeeShift(actor.company.id, employeeId);
        final weekdays = await _workingWeekdays(actor.company.id, shiftId);
        final holidays = await _holidayDates(
          actor.company.id,
          workLocationId,
          start,
          end,
        );
        final calc = calculator.calculate(
          startDate: start,
          endDate: end,
          workingWeekdays: weekdays,
          holidayDates: holidays,
          startPortion: draft.startPortion,
          endPortion: draft.endPortion,
          allowHalfDay: type.allowsHalfDay,
        );
        if (!calc.hasWorkingDays) {
          return _fail<LeaveRequest>('leaveNoWorkingDays');
        }
        if (calc.quantityDays < (policy?.minimumRequestDays ?? 0)) {
          return _fail<LeaveRequest>('leaveMinimumDays');
        }
        // Overlap validation against pending/approved requests.
        final overlapping =
            await (db.select(db.leaveRequests)..where(
                  (t) =>
                      t.companyId.equals(actor.company.id) &
                      t.employeeId.equals(employeeId) &
                      t.status.isIn(['pending', 'approved']) &
                      t.startDate.isSmallerOrEqualValue(_d(end)) &
                      t.endDate.isBiggerOrEqualValue(_d(start)),
                ))
                .get();
        if (overlapping.isNotEmpty) {
          return _fail<LeaveRequest>('leaveOverlapping');
        }
        final year = yearResolver.yearFor(start);
        final available = await _availableDays(
          actor.company.id,
          employeeId,
          draft.leaveTypeId,
          year,
        );
        final isPaid = typeModel.compensation == LeaveCompensationType.paid;
        final allowNegative = policy?.allowNegativeBalance ?? false;
        if (isPaid && !allowNegative && calc.quantityDays > available + 1e-6) {
          return _fail<LeaveRequest>('leaveInsufficientBalance');
        }
        final now = clock.now().toUtc();
        final requestId = const Uuid().v4();
        final request = LeaveRequest(
          id: requestId,
          companyId: actor.company.id,
          employeeId: employeeId,
          typeSnapshot: LeaveTypeSnapshot(
            typeId: typeModel.id,
            name: typeModel.name,
            code: typeModel.code,
            compensation: typeModel.compensation,
            requiresReason: typeModel.requiresReason,
            requiresAttachment: typeModel.requiresAttachment,
            allowsHalfDay: typeModel.allowsHalfDay,
          ),
          policySnapshot: policy == null
              ? null
              : LeavePolicySnapshot(
                  policyId: policy.id,
                  name: policy.name,
                  code: policy.code,
                  annualEntitlementDays: policy.annualEntitlementDays,
                  allowHalfDay: policy.allowHalfDay,
                  allowNegativeBalance: policy.allowNegativeBalance,
                ),
          startDate: start,
          endDate: end,
          startPortion: draft.startPortion,
          endPortion: draft.endPortion,
          requestedDays: calc.quantityDays,
          reason: draft.reason.trim(),
          attachmentName: draft.attachmentName,
          status: LeaveRequestStatus.pending,
          submittedAt: now,
          createdAt: now,
          updatedAt: now,
          requestId: requestId,
          syncStatus: demoEnabled ? 'synced' : 'pending',
        );
        await db.into(db.leaveRequests).insert(_requestCompanion(request));
        await _insertEvent(
          actor.company.id,
          requestId,
          'submitted',
          actor.user.id,
          null,
          now,
        );
        await _insertLedger(
          companyId: actor.company.id,
          employeeId: employeeId,
          leaveTypeId: draft.leaveTypeId,
          leaveYear: year,
          type: LeaveBalanceTransactionType.leaveReserved,
          quantityDays: calc.quantityDays,
          leaveRequestId: requestId,
          reason: 'leaveReserved',
          createdBy: actor.user.id,
          effectiveDate: start,
          now: now,
        );
        if (!demoEnabled) {
          await _enqueue(
            actor,
            'leaveRequest.create',
            requestId,
            request.reason,
          );
        }
        await _notifyApprover(actor, employeeId, request);
        return Success(request);
      });
    } catch (_) {
      return _fail('leaveStorageError', kind: FailureKind.storageWrite);
    }
  }

  Future<void> _notifyApprover(
    AuthContext actor,
    String employeeId,
    LeaveRequest request,
  ) async {
    final repository = notifications;
    if (repository == null) return;
    final employee = await (db.select(
      db.workforceEmployees,
    )..where((t) => t.id.equals(employeeId))).getSingleOrNull();
    final managerId = employee?.managerId;
    if (managerId == null) return;
    final manager = await (db.select(
      db.workforceEmployees,
    )..where((t) => t.id.equals(managerId))).getSingleOrNull();
    final userId = manager?.linkedUserId;
    if (userId == null) return;
    await repository.createLocal(
      AppNotification(
        id: const Uuid().v4(),
        companyId: actor.company.id,
        userId: userId,
        type: AppNotificationType.leaveApprovalRequired,
        priority: AppNotificationPriority.normal,
        dedupeKey: 'leaveApproval:${request.id}',
        route: '/app/leave/requests/${request.id}',
        payload: {'requestId': request.id},
        createdAt: clock.now().toUtc(),
      ),
    );
  }

  // ---- review --------------------------------------------------------------

  Future<bool> _canReview(AuthContext actor, String employeeId) async {
    final p = PermissionChecker(actor.user.permissions);
    if (actor.employeeReference?.id == employeeId) return false; // self
    if (p.can(AppPermission.leaveApproveAll)) return true;
    if (p.can(AppPermission.leaveApproveTeam) &&
        actor.employeeReference != null) {
      final employee =
          await (db.select(db.workforceEmployees)..where(
                (t) =>
                    t.id.equals(employeeId) &
                    t.companyId.equals(actor.company.id),
              ))
              .getSingleOrNull();
      return employee?.managerId == actor.employeeReference!.id;
    }
    return false;
  }

  @override
  Future<Result<LeaveRequest>> approveRequest(
    AuthContext context,
    String id, {
    String? note,
  }) => _review(context, id, approve: true, note: note);

  @override
  Future<Result<LeaveRequest>> rejectRequest(
    AuthContext context,
    String id, {
    required String note,
  }) {
    if (note.trim().isEmpty) {
      return Future.value(_fail('leaveReviewNoteRequired'));
    }
    return _review(context, id, approve: false, note: note.trim());
  }

  Future<Result<LeaveRequest>> _review(
    AuthContext actor,
    String id, {
    required bool approve,
    String? note,
  }) async {
    if (!_can(actor, AppPermission.leaveApproveTeam) &&
        !_can(actor, AppPermission.leaveApproveAll)) {
      return _fail('leavePermissionDenied');
    }
    try {
      return await db.transaction(() async {
        final row =
            await (db.select(db.leaveRequests)..where(
                  (t) => t.id.equals(id) & t.companyId.equals(actor.company.id),
                ))
                .getSingleOrNull();
        if (row == null) return _fail<LeaveRequest>('leaveRequestNotFound');
        if (row.status != 'pending') {
          return _fail<LeaveRequest>('leaveAlreadyReviewed');
        }
        if (!await _canReview(actor, row.employeeId)) {
          return _fail<LeaveRequest>('leaveSelfApprovalNotAllowed');
        }
        final now = clock.now().toUtc();
        final request = _mapRequest(row);
        if (approve) {
          final isPaid =
              request.typeSnapshot.compensation == LeaveCompensationType.paid;
          if (isPaid) {
            final year = yearResolver.yearFor(request.startDate);
            final available = await _availableDays(
              actor.company.id,
              row.employeeId,
              request.typeSnapshot.typeId,
              year,
            );
            // The reservation already reduced available; ensure not negative
            // unless policy allows.
            final allowNegative =
                request.policySnapshot?.allowNegativeBalance ?? false;
            if (!allowNegative && available + request.requestedDays < -1e-6) {
              return _fail<LeaveRequest>('leaveInsufficientBalance');
            }
            await _insertLedger(
              companyId: actor.company.id,
              employeeId: row.employeeId,
              leaveTypeId: request.typeSnapshot.typeId,
              leaveYear: year,
              type: LeaveBalanceTransactionType.leaveConsumed,
              quantityDays: request.requestedDays,
              leaveRequestId: id,
              reason: 'leaveConsumed',
              createdBy: actor.user.id,
              effectiveDate: request.startDate,
              now: now,
            );
            await _insertLedger(
              companyId: actor.company.id,
              employeeId: row.employeeId,
              leaveTypeId: request.typeSnapshot.typeId,
              leaveYear: year,
              type: LeaveBalanceTransactionType.leaveReleased,
              quantityDays: request.requestedDays,
              leaveRequestId: id,
              reason: 'leaveReservationConverted',
              createdBy: actor.user.id,
              effectiveDate: request.startDate,
              now: now,
            );
          }
        } else {
          final year = yearResolver.yearFor(request.startDate);
          await _insertLedger(
            companyId: actor.company.id,
            employeeId: row.employeeId,
            leaveTypeId: request.typeSnapshot.typeId,
            leaveYear: year,
            type: LeaveBalanceTransactionType.leaveReleased,
            quantityDays: request.requestedDays,
            leaveRequestId: id,
            reason: 'leaveRejected',
            createdBy: actor.user.id,
            effectiveDate: request.startDate,
            now: now,
          );
        }
        await (db.update(
          db.leaveRequests,
        )..where((t) => t.id.equals(id) & t.status.equals('pending'))).write(
          LeaveRequestsCompanion(
            status: Value(
              approve
                  ? LeaveRequestStatus.approved.name
                  : LeaveRequestStatus.rejected.name,
            ),
            reviewedMilliseconds: Value(now.millisecondsSinceEpoch),
            reviewedBy: Value(actor.user.id),
            reviewNote: Value(note),
            updatedMilliseconds: Value(now.millisecondsSinceEpoch),
            syncStatus: Value(demoEnabled ? 'synced' : 'pending'),
          ),
        );
        await _insertEvent(
          actor.company.id,
          id,
          approve ? 'approved' : 'rejected',
          actor.user.id,
          note,
          now,
        );
        if (!demoEnabled) {
          await _enqueue(
            actor,
            approve ? 'leaveRequest.approve' : 'leaveRequest.reject',
            id,
            note ?? '',
          );
        }
        await _notifyEmployee(
          actor,
          row.employeeId,
          id,
          approve
              ? AppNotificationType.leaveRequestApproved
              : AppNotificationType.leaveRequestRejected,
        );
        final updated = await (db.select(
          db.leaveRequests,
        )..where((t) => t.id.equals(id))).getSingle();
        return Success(_mapRequest(updated));
      });
    } catch (_) {
      return _fail('leaveStorageError', kind: FailureKind.storageWrite);
    }
  }

  @override
  Future<Result<LeaveRequest>> cancelRequest(
    AuthContext actor,
    String id, {
    String? reason,
  }) async {
    try {
      return await db.transaction(() async {
        final row =
            await (db.select(db.leaveRequests)..where(
                  (t) => t.id.equals(id) & t.companyId.equals(actor.company.id),
                ))
                .getSingleOrNull();
        if (row == null) return _fail<LeaveRequest>('leaveRequestNotFound');
        final isSelf = actor.employeeReference?.id == row.employeeId;
        final canManage =
            _can(actor, AppPermission.leaveManage) ||
            _can(actor, AppPermission.leaveApproveAll);
        if (row.status == 'pending') {
          if (!isSelf &&
              !canManage &&
              !_can(actor, AppPermission.leaveCancelSelf)) {
            return _fail<LeaveRequest>('leavePermissionDenied');
          }
        } else if (row.status == 'approved') {
          // Employees cannot silently cancel approved leave.
          if (!canManage) {
            return _fail<LeaveRequest>('leaveCannotCancelApproved');
          }
        } else {
          return _fail<LeaveRequest>('leaveAlreadyReviewed');
        }
        final now = clock.now().toUtc();
        final request = _mapRequest(row);
        final year = yearResolver.yearFor(request.startDate);
        await _insertLedger(
          companyId: actor.company.id,
          employeeId: row.employeeId,
          leaveTypeId: request.typeSnapshot.typeId,
          leaveYear: year,
          type: LeaveBalanceTransactionType.leaveReleased,
          quantityDays: request.requestedDays,
          leaveRequestId: id,
          reason: 'leaveCancelled',
          createdBy: actor.user.id,
          effectiveDate: request.startDate,
          now: now,
        );
        await (db.update(
          db.leaveRequests,
        )..where((t) => t.id.equals(id))).write(
          LeaveRequestsCompanion(
            status: Value(LeaveRequestStatus.cancelled.name),
            cancelledMilliseconds: Value(now.millisecondsSinceEpoch),
            cancelledBy: Value(actor.user.id),
            cancellationReason: Value(reason),
            updatedMilliseconds: Value(now.millisecondsSinceEpoch),
            syncStatus: Value(demoEnabled ? 'synced' : 'pending'),
          ),
        );
        await _insertEvent(
          actor.company.id,
          id,
          'cancelled',
          actor.user.id,
          reason,
          now,
        );
        if (!demoEnabled) {
          await _enqueue(actor, 'leaveRequest.cancel', id, reason ?? '');
        }
        await _notifyEmployee(
          actor,
          row.employeeId,
          id,
          AppNotificationType.leaveRequestCancelled,
        );
        final updated = await (db.select(
          db.leaveRequests,
        )..where((t) => t.id.equals(id))).getSingle();
        return Success(_mapRequest(updated));
      });
    } catch (_) {
      return _fail('leaveStorageError', kind: FailureKind.storageWrite);
    }
  }

  Future<void> _notifyEmployee(
    AuthContext actor,
    String employeeId,
    String requestId,
    AppNotificationType type,
  ) async {
    final repository = notifications;
    if (repository == null) return;
    final employee = await (db.select(
      db.workforceEmployees,
    )..where((t) => t.id.equals(employeeId))).getSingleOrNull();
    final userId = employee?.linkedUserId;
    if (userId == null) return;
    await repository.createLocal(
      AppNotification(
        id: const Uuid().v4(),
        companyId: actor.company.id,
        userId: userId,
        type: type,
        priority: AppNotificationPriority.normal,
        dedupeKey: 'leave:${type.name}:$requestId',
        route: '/app/leave/requests/$requestId',
        payload: {'requestId': requestId},
        createdAt: clock.now().toUtc(),
      ),
    );
  }

  // ---- request lists -------------------------------------------------------

  @override
  Stream<Result<List<LeaveRequestRow>>> watchRequests(
    AuthContext context, {
    required LeaveRequestScope scope,
    LeaveRequestStatus? status,
    int limit = 50,
  }) {
    final p = PermissionChecker(context.user.permissions);
    String scopeClause = '';
    final vars = <Variable<Object>>[Variable(context.company.id)];
    switch (scope) {
      case LeaveRequestScope.self:
        final employeeId = context.employeeReference?.id;
        if (employeeId == null || !p.can(AppPermission.leaveViewSelf)) {
          return Stream.value(_fail('leavePermissionDenied'));
        }
        scopeClause = ' AND r.employee_id = ?';
        vars.add(Variable(employeeId));
      case LeaveRequestScope.team:
        if (context.employeeReference == null ||
            !p.can(AppPermission.leaveViewTeam)) {
          return Stream.value(_fail('leavePermissionDenied'));
        }
        scopeClause = ' AND e.manager_id = ?';
        vars.add(Variable(context.employeeReference!.id));
      case LeaveRequestScope.company:
        if (!p.can(AppPermission.leaveViewAll)) {
          return Stream.value(_fail('leavePermissionDenied'));
        }
      case LeaveRequestScope.approvals:
        if (!p.can(AppPermission.leaveApproveTeam) &&
            !p.can(AppPermission.leaveApproveAll)) {
          return Stream.value(_fail('leavePermissionDenied'));
        }
        if (p.can(AppPermission.leaveApproveAll)) {
          // company-wide approvals
        } else {
          scopeClause = ' AND e.manager_id = ?';
          vars.add(Variable(context.employeeReference!.id));
        }
        status = LeaveRequestStatus.pending;
    }
    final statusClause = status == null ? '' : ' AND r.status = ?';
    if (status != null) vars.add(Variable(status.name));
    final sql =
        '''SELECT r.id, r.company_id, r.employee_id, r.type_snapshot,
 r.policy_snapshot, r.start_date, r.end_date, r.start_portion, r.end_portion,
 r.requested_days, r.reason, r.attachment_name, r.status,
 r.submitted_milliseconds, r.reviewed_milliseconds, r.reviewed_by,
 r.review_note, r.cancelled_milliseconds, r.cancelled_by,
 r.cancellation_reason, r.created_milliseconds, r.updated_milliseconds,
 r.request_id, r.sync_status,
 e.first_name || ' ' || e.middle_name || ' ' || e.last_name employee_name,
 e.employee_code, COALESCE(d.name,'') department
FROM leave_requests r
JOIN workforce_employees e ON e.id = r.employee_id AND e.company_id = r.company_id
LEFT JOIN workforce_departments d ON d.id = e.department_id AND d.company_id = e.company_id
WHERE r.company_id = ?$scopeClause$statusClause
ORDER BY r.start_date DESC, r.created_milliseconds DESC
LIMIT ?''';
    vars.add(Variable(limit));
    return db
        .customSelect(
          sql,
          variables: vars,
          readsFrom: {
            db.leaveRequests,
            db.workforceEmployees,
            db.workforceDepartments,
          },
        )
        .watch()
        .map((rows) => Success(rows.map(_mapRequestRow).toList()));
  }

  @override
  Future<Result<LeaveRequestRow?>> requestById(
    AuthContext context,
    String id,
  ) async {
    try {
      final row =
          await (db.select(db.leaveRequests)..where(
                (t) => t.id.equals(id) & t.companyId.equals(context.company.id),
              ))
              .getSingleOrNull();
      if (row == null) return const Success(null);
      final p = PermissionChecker(context.user.permissions);
      final isSelf = context.employeeReference?.id == row.employeeId;
      final canTeam = isSelf
          ? p.can(AppPermission.leaveViewSelf)
          : await _canReview(context, row.employeeId) ||
                p.can(AppPermission.leaveViewAll);
      if (!isSelf && !canTeam) return _fail('leavePermissionDenied');
      final employee = await (db.select(
        db.workforceEmployees,
      )..where((t) => t.id.equals(row.employeeId))).getSingleOrNull();
      final department = employee == null
          ? ''
          : (await (db.select(db.workforceDepartments)
                          ..where((t) => t.id.equals(employee.departmentId)))
                        .getSingleOrNull())
                    ?.name ??
                '';
      return Success(
        LeaveRequestRow(
          request: _mapRequest(row),
          employeeName: employee == null
              ? ''
              : [
                  employee.firstName,
                  employee.middleName,
                  employee.lastName,
                ].where((s) => s.isNotEmpty).join(' '),
          employeeCode: employee?.employeeCode ?? '',
          department: department,
        ),
      );
    } catch (_) {
      return _fail('leaveStorageError', kind: FailureKind.unknown);
    }
  }

  // ---- balances ------------------------------------------------------------

  @override
  Stream<Result<List<LeaveBalanceSummary>>> watchBalances(
    AuthContext context,
    String employeeId, {
    int? year,
  }) {
    final p = PermissionChecker(context.user.permissions);
    final isSelf = context.employeeReference?.id == employeeId;
    final allowed = isSelf
        ? p.can(AppPermission.leaveBalanceViewSelf) ||
              p.can(AppPermission.leaveViewSelf)
        : p.can(AppPermission.leaveBalanceViewAll) ||
              p.can(AppPermission.leaveBalanceViewTeam);
    if (!allowed) return Stream.value(_fail('leavePermissionDenied'));
    final leaveYear = year ?? yearResolver.yearFor(_companyToday);
    return db
        .customSelect(
          'SELECT * FROM leave_balance_transactions WHERE company_id=? AND employee_id=? AND leave_year=?',
          variables: [
            Variable(context.company.id),
            Variable(employeeId),
            Variable(leaveYear),
          ],
          readsFrom: {db.leaveBalanceTransactions},
        )
        .watch()
        .asyncMap((_) => _balanceSummaries(context, employeeId, leaveYear));
  }

  Future<Result<List<LeaveBalanceSummary>>> _balanceSummaries(
    AuthContext context,
    String employeeId,
    int year,
  ) async {
    final types =
        await (db.select(db.leaveTypes)..where(
              (t) =>
                  t.companyId.equals(context.company.id) &
                  t.status.equals('active'),
            ))
            .get();
    final result = <LeaveBalanceSummary>[];
    for (final type in types) {
      final available = await _availableDays(
        context.company.id,
        employeeId,
        type.id,
        year,
      );
      final yearPrefix = year.toString().padLeft(4, '0');
      final requests =
          await (db.select(db.leaveRequests)..where(
                (t) =>
                    t.companyId.equals(context.company.id) &
                    t.employeeId.equals(employeeId) &
                    t.status.isIn(['approved', 'pending']) &
                    t.startDate.like('$yearPrefix%'),
              ))
              .get();
      var used = 0.0, pending = 0.0;
      for (final r in requests) {
        final snapshot = LeaveTypeSnapshot.fromJson(
          jsonDecode(r.typeSnapshot) as Map<String, dynamic>,
        );
        if (snapshot.typeId != type.id) continue;
        if (r.status == 'approved') {
          used += r.requestedDays;
        } else {
          pending += r.requestedDays;
        }
      }
      result.add(
        LeaveBalanceSummary(
          leaveTypeId: type.id,
          leaveTypeName: type.name,
          compensation: _compensation(type.compensation),
          entitlement: available + used + pending,
          used: used,
          pending: pending,
        ),
      );
    }
    return Success(result);
  }

  @override
  Future<Result<List<LeaveBalanceTransaction>>> balanceLedger(
    AuthContext context,
    String employeeId,
    String leaveTypeId,
    int year,
  ) async {
    final p = PermissionChecker(context.user.permissions);
    final isSelf = context.employeeReference?.id == employeeId;
    if (!isSelf &&
        !p.can(AppPermission.leaveBalanceViewAll) &&
        !p.can(AppPermission.leaveBalanceViewTeam)) {
      return _fail('leavePermissionDenied');
    }
    final rows =
        await (db.select(db.leaveBalanceTransactions)
              ..where(
                (t) =>
                    t.companyId.equals(context.company.id) &
                    t.employeeId.equals(employeeId) &
                    t.leaveTypeId.equals(leaveTypeId) &
                    t.leaveYear.equals(year),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.createdMilliseconds)]))
            .get();
    return Success(rows.map(_mapTransaction).toList());
  }

  @override
  Future<Result<void>> adjustBalance(
    AuthContext context,
    LeaveBalanceAdjustment adjustment,
  ) async {
    if (!_can(context, AppPermission.leaveBalanceAdjust)) {
      return _fail('leavePermissionDenied');
    }
    if (adjustment.reason.trim().isEmpty) {
      return _fail('leaveReasonRequired');
    }
    if (adjustment.quantityDays <= 0) {
      return _fail('leaveInvalidQuantity');
    }
    try {
      final now = clock.now().toUtc();
      final year = yearResolver.yearFor(adjustment.effectiveDate);
      await _insertLedger(
        companyId: context.company.id,
        employeeId: adjustment.employeeId,
        leaveTypeId: adjustment.leaveTypeId,
        leaveYear: year,
        type: adjustment.add
            ? LeaveBalanceTransactionType.adjustmentAdd
            : LeaveBalanceTransactionType.adjustmentSubtract,
        quantityDays: adjustment.quantityDays,
        reason: adjustment.reason.trim(),
        createdBy: context.user.id,
        effectiveDate: adjustment.effectiveDate,
        now: now,
      );
      await _enqueue(
        context,
        'leaveBalance.adjust',
        adjustment.employeeId,
        adjustment.reason.trim(),
      );
      return const Success(null);
    } catch (_) {
      return _fail('leaveStorageError', kind: FailureKind.storageWrite);
    }
  }

  // ---- calendar & holidays -------------------------------------------------

  @override
  Future<Result<List<LeaveCalendarEntry>>> calendar(
    AuthContext context,
    DateTime from,
    DateTime to,
  ) async {
    final p = PermissionChecker(context.user.permissions);
    final fromD = leaveDate(from), toD = leaveDate(to);
    try {
      final rows =
          await (db.select(db.leaveRequests)..where(
                (t) =>
                    t.companyId.equals(context.company.id) &
                    t.status.isIn(['pending', 'approved']) &
                    t.startDate.isSmallerOrEqualValue(_d(toD)) &
                    t.endDate.isBiggerOrEqualValue(_d(fromD)),
              ))
              .get();
      final entries = <LeaveCalendarEntry>[];
      final maskCache = <String, Set<int>>{};
      for (final row in rows) {
        final isSelf = context.employeeReference?.id == row.employeeId;
        final canSee =
            isSelf ||
            p.can(AppPermission.leaveViewAll) ||
            (p.can(AppPermission.leaveViewTeam) &&
                await _canViewTeamEmployee(context, row.employeeId));
        if (!canSee) continue;
        final request = _mapRequest(row);
        final weekdays = maskCache[row.employeeId] ??= await _workingWeekdays(
          context.company.id,
          await _employeeShift(context.company.id, row.employeeId),
        );
        final workLocationId = await _employeeWorkLocation(
          context.company.id,
          row.employeeId,
        );
        final holidays = await _holidayDates(
          context.company.id,
          workLocationId,
          request.startDate,
          request.endDate,
        );
        final calc = calculator.calculate(
          startDate: request.startDate,
          endDate: request.endDate,
          workingWeekdays: weekdays,
          holidayDates: holidays,
          startPortion: request.startPortion,
          endPortion: request.endPortion,
          allowHalfDay: request.typeSnapshot.allowsHalfDay,
        );
        final employeeName = await _employeeName(
          context.company.id,
          row.employeeId,
        );
        for (final date in calc.leaveDates) {
          if (date.isBefore(fromD) || date.isAfter(toD)) continue;
          entries.add(
            LeaveCalendarEntry(
              date: date,
              kind: LeaveCalendarKind.leave,
              title: employeeName,
              employeeName: employeeName,
              leaveTypeName: request.typeSnapshot.name,
              status: request.status,
            ),
          );
        }
      }
      final holidayRows =
          await (db.select(db.holidays)..where(
                (t) =>
                    t.companyId.equals(context.company.id) &
                    t.status.equals('active') &
                    t.date.isSmallerOrEqualValue(_d(toD)),
              ))
              .get();
      for (final h in holidayRows) {
        final start = _parseDate(h.date);
        final end = h.endDate == null ? start : _parseDate(h.endDate!);
        if (end.isBefore(fromD) || start.isAfter(toD)) continue;
        for (
          var day = start;
          !day.isAfter(end);
          day = day.add(const Duration(days: 1))
        ) {
          if (day.isBefore(fromD) || day.isAfter(toD)) continue;
          entries.add(
            LeaveCalendarEntry(
              date: day,
              kind: LeaveCalendarKind.holiday,
              title: h.name,
            ),
          );
        }
      }
      entries.sort((a, b) => a.date.compareTo(b.date));
      return Success(entries);
    } catch (_) {
      return _fail('leaveStorageError', kind: FailureKind.unknown);
    }
  }

  @override
  Future<Result<List<Holiday>>> applicableHolidays(
    AuthContext context,
    String employeeId,
    DateTime from,
    DateTime to,
  ) async {
    try {
      final workLocationId = await _employeeWorkLocation(
        context.company.id,
        employeeId,
      );
      final rows =
          await (db.select(db.holidays)..where(
                (t) =>
                    t.companyId.equals(context.company.id) &
                    t.status.equals('active') &
                    t.date.isSmallerOrEqualValue(_d(leaveDate(to))),
              ))
              .get();
      final result = <Holiday>[];
      for (final row in rows) {
        final holiday = _mapHoliday(row);
        final end = holiday.endDate ?? holiday.date;
        if (end.isBefore(leaveDate(from))) continue;
        if (holiday.scope == HolidayScope.companyWide ||
            (workLocationId != null &&
                holiday.workLocationIds.contains(workLocationId))) {
          result.add(holiday);
        }
      }
      return Success(result);
    } catch (_) {
      return _fail('leaveStorageError', kind: FailureKind.unknown);
    }
  }

  @override
  Future<Result<LeaveWorkdayOverlay?>> dayOverride(
    AuthContext context,
    String employeeId,
    DateTime date,
  ) async {
    try {
      final day = leaveDate(date);
      final workLocationId = await _employeeWorkLocation(
        context.company.id,
        employeeId,
      );
      final holidays = await _holidayDates(
        context.company.id,
        workLocationId,
        day,
        day,
      );
      if (holidays.contains(_d(day))) {
        final applicable = await applicableHolidays(
          context,
          employeeId,
          day,
          day,
        );
        final name =
            applicable is Success<List<Holiday>> && applicable.value.isNotEmpty
            ? applicable.value.first.name
            : '';
        return Success(
          LeaveWorkdayOverlay(
            classification: WorkdayClassification.holiday,
            text: name,
          ),
        );
      }
      final rows =
          await (db.select(db.leaveRequests)..where(
                (t) =>
                    t.companyId.equals(context.company.id) &
                    t.employeeId.equals(employeeId) &
                    t.status.equals('approved') &
                    t.startDate.isSmallerOrEqualValue(_d(day)) &
                    t.endDate.isBiggerOrEqualValue(_d(day)),
              ))
              .get();
      final shiftId = await _employeeShift(context.company.id, employeeId);
      final weekdays = await _workingWeekdays(context.company.id, shiftId);
      for (final row in rows) {
        final request = _mapRequest(row);
        final requestHolidays = await _holidayDates(
          context.company.id,
          workLocationId,
          request.startDate,
          request.endDate,
        );
        final calc = calculator.calculate(
          startDate: request.startDate,
          endDate: request.endDate,
          workingWeekdays: weekdays,
          holidayDates: requestHolidays,
          startPortion: request.startPortion,
          endPortion: request.endPortion,
          allowHalfDay: request.typeSnapshot.allowsHalfDay,
        );
        if (calc.leaveDates.any((d) => d.isAtSameMomentAs(day))) {
          return Success(
            LeaveWorkdayOverlay(
              classification: WorkdayClassification.approvedLeave,
              text: request.typeSnapshot.name,
            ),
          );
        }
      }
      return const Success(null);
    } catch (_) {
      return _fail('leaveStorageError');
    }
  }

  Future<bool> _canViewTeamEmployee(
    AuthContext actor,
    String employeeId,
  ) async {
    if (actor.employeeReference == null) return false;
    final employee = await (db.select(
      db.workforceEmployees,
    )..where((t) => t.id.equals(employeeId))).getSingleOrNull();
    return employee?.managerId == actor.employeeReference!.id;
  }

  Future<String> _employeeName(String companyId, String employeeId) async {
    final row =
        await (db.select(db.workforceEmployees)..where(
              (t) => t.id.equals(employeeId) & t.companyId.equals(companyId),
            ))
            .getSingleOrNull();
    if (row == null) return '';
    return [
      row.firstName,
      row.middleName,
      row.lastName,
    ].where((s) => s.isNotEmpty).join(' ');
  }

  // ---- persistence helpers -------------------------------------------------

  Future<void> _insertEvent(
    String companyId,
    String requestId,
    String type,
    String? actorId,
    String? note,
    DateTime now,
  ) => db
      .into(db.leaveRequestEvents)
      .insert(
        LeaveRequestEventsCompanion.insert(
          id: const Uuid().v4(),
          companyId: companyId,
          requestId: requestId,
          type: type,
          actorId: Value(actorId),
          note: Value(note),
          createdMilliseconds: now.millisecondsSinceEpoch,
        ),
      );

  Future<void> _insertLedger({
    required String companyId,
    required String employeeId,
    required String leaveTypeId,
    required int leaveYear,
    required LeaveBalanceTransactionType type,
    required double quantityDays,
    String? leaveRequestId,
    required String reason,
    required String createdBy,
    required DateTime effectiveDate,
    required DateTime now,
  }) => db
      .into(db.leaveBalanceTransactions)
      .insert(
        LeaveBalanceTransactionsCompanion.insert(
          id: const Uuid().v4(),
          companyId: companyId,
          employeeId: employeeId,
          leaveTypeId: leaveTypeId,
          leaveYear: leaveYear,
          type: type.name,
          quantityDays: quantityDays,
          leaveRequestId: Value(leaveRequestId),
          reason: Value(reason),
          createdBy: createdBy,
          effectiveDate: _d(leaveDate(effectiveDate)),
          createdMilliseconds: now.millisecondsSinceEpoch,
          requestId: const Uuid().v4(),
          syncStatus: Value(demoEnabled ? 'synced' : 'pending'),
        ),
      );

  Future<void> _enqueue(
    AuthContext actor,
    String operation,
    String entityId,
    String payloadNote,
  ) async {
    if (demoEnabled) return;
    final requestId = const Uuid().v4();
    await db
        .into(db.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            id: requestId,
            moduleId: 'leave',
            entityId: entityId,
            operation: operation,
            payload: jsonEncode({'operation': operation, 'entityId': entityId}),
            createdAt: clock.now().toUtc(),
            companyId: Value(actor.company.id),
            requestId: Value(requestId),
          ),
        );
  }

  LeaveRequestsCompanion _requestCompanion(LeaveRequest r) =>
      LeaveRequestsCompanion.insert(
        id: r.id,
        companyId: r.companyId,
        employeeId: r.employeeId,
        typeSnapshot: jsonEncode(r.typeSnapshot.toJson()),
        policySnapshot: Value(
          r.policySnapshot == null
              ? null
              : jsonEncode(r.policySnapshot!.toJson()),
        ),
        startDate: _d(r.startDate),
        endDate: _d(r.endDate),
        startPortion: Value(r.startPortion.name),
        endPortion: Value(r.endPortion.name),
        requestedDays: Value(r.requestedDays),
        reason: Value(r.reason),
        attachmentName: Value(r.attachmentName),
        status: Value(r.status.name),
        submittedMilliseconds: Value(r.submittedAt?.millisecondsSinceEpoch),
        reviewedMilliseconds: Value(r.reviewedAt?.millisecondsSinceEpoch),
        reviewedBy: Value(r.reviewedBy),
        reviewNote: Value(r.reviewNote),
        cancelledMilliseconds: Value(r.cancelledAt?.millisecondsSinceEpoch),
        cancelledBy: Value(r.cancelledBy),
        cancellationReason: Value(r.cancellationReason),
        createdMilliseconds: r.createdAt.millisecondsSinceEpoch,
        updatedMilliseconds: r.updatedAt.millisecondsSinceEpoch,
        requestId: r.requestId,
        syncStatus: Value(r.syncStatus),
      );

  // ---- mapping -------------------------------------------------------------

  LeaveType _mapType(LeaveTypeData row) => LeaveType(
    id: row.id,
    companyId: row.companyId,
    name: row.name,
    code: row.code,
    description: row.description,
    compensation: _compensation(row.compensation),
    requiresApproval: row.requiresApproval,
    allowsHalfDay: row.allowsHalfDay,
    requiresReason: row.requiresReason,
    requiresAttachment: row.requiresAttachment,
    colorKey: row.colorKey,
    status: row.status == 'inactive'
        ? ConfigurationStatus.inactive
        : ConfigurationStatus.active,
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      row.createdMilliseconds,
      isUtc: true,
    ),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      row.updatedMilliseconds,
      isUtc: true,
    ),
    syncStatus: demoEnabled
        ? RecordSyncStatus.synced
        : RecordSyncStatus.pending,
  );

  LeavePolicy _mapPolicy(LeavePolicyData row) => LeavePolicy(
    id: row.id,
    companyId: row.companyId,
    name: row.name,
    code: row.code,
    leaveTypeId: row.leaveTypeId,
    annualEntitlementDays: row.annualEntitlementDays,
    allowHalfDay: row.allowHalfDay,
    minimumRequestDays: row.minimumRequestDays,
    maximumConsecutiveDays: row.maximumConsecutiveDays,
    advanceNoticeDays: row.advanceNoticeDays,
    allowPastRequest: row.allowPastRequest,
    pastRequestWindowDays: row.pastRequestWindowDays,
    requiresAttachmentAfterDays: row.requiresAttachmentAfterDays,
    allowNegativeBalance: row.allowNegativeBalance,
    carryForwardEnabled: row.carryForwardEnabled,
    carryForwardLimitDays: row.carryForwardLimitDays,
    applicableEmploymentTypes: {
      for (final name in (jsonDecode(row.applicableEmploymentTypes) as List))
        EmploymentType.values.firstWhere(
          (e) => e.name == name,
          orElse: () => EmploymentType.fullTime,
        ),
    },
    status: row.status == 'inactive'
        ? ConfigurationStatus.inactive
        : ConfigurationStatus.active,
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      row.createdMilliseconds,
      isUtc: true,
    ),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      row.updatedMilliseconds,
      isUtc: true,
    ),
    syncStatus: demoEnabled
        ? RecordSyncStatus.synced
        : RecordSyncStatus.pending,
  );

  Holiday _mapHoliday(HolidayData row) => Holiday(
    id: row.id,
    companyId: row.companyId,
    name: row.name,
    date: _parseDate(row.date),
    endDate: row.endDate == null ? null : _parseDate(row.endDate!),
    type: HolidayType.values.firstWhere(
      (t) => t.name == row.type,
      orElse: () => HolidayType.companyHoliday,
    ),
    scope: HolidayScope.values.firstWhere(
      (s) => s.name == row.scope,
      orElse: () => HolidayScope.companyWide,
    ),
    workLocationIds: {
      for (final id in (jsonDecode(row.workLocationIds) as List)) id as String,
    },
    description: row.description,
    isOptional: row.isOptional,
    status: row.status == 'inactive'
        ? ConfigurationStatus.inactive
        : ConfigurationStatus.active,
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      row.createdMilliseconds,
      isUtc: true,
    ),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      row.updatedMilliseconds,
      isUtc: true,
    ),
    syncStatus: demoEnabled
        ? RecordSyncStatus.synced
        : RecordSyncStatus.pending,
  );

  LeaveRequest _mapRequest(LeaveRequestData row) => LeaveRequest(
    id: row.id,
    companyId: row.companyId,
    employeeId: row.employeeId,
    typeSnapshot: LeaveTypeSnapshot.fromJson(
      jsonDecode(row.typeSnapshot) as Map<String, dynamic>,
    ),
    policySnapshot: row.policySnapshot == null
        ? null
        : LeavePolicySnapshot.fromJson(
            jsonDecode(row.policySnapshot!) as Map<String, dynamic>,
          ),
    startDate: _parseDate(row.startDate),
    endDate: _parseDate(row.endDate),
    startPortion: LeaveDayPortion.values.firstWhere(
      (p) => p.name == row.startPortion,
      orElse: () => LeaveDayPortion.fullDay,
    ),
    endPortion: LeaveDayPortion.values.firstWhere(
      (p) => p.name == row.endPortion,
      orElse: () => LeaveDayPortion.fullDay,
    ),
    requestedDays: row.requestedDays,
    reason: row.reason,
    attachmentName: row.attachmentName,
    status: LeaveRequestStatus.values.firstWhere(
      (s) => s.name == row.status,
      orElse: () => LeaveRequestStatus.pending,
    ),
    submittedAt: _toDate(row.submittedMilliseconds),
    reviewedAt: _toDate(row.reviewedMilliseconds),
    reviewedBy: row.reviewedBy,
    reviewNote: row.reviewNote,
    cancelledAt: _toDate(row.cancelledMilliseconds),
    cancelledBy: row.cancelledBy,
    cancellationReason: row.cancellationReason,
    createdAt: _toDate(row.createdMilliseconds)!,
    updatedAt: _toDate(row.updatedMilliseconds)!,
    requestId: row.requestId,
    syncStatus: row.syncStatus,
  );

  LeaveRequestRow _mapRequestRow(QueryRow row) {
    final data = LeaveRequestData(
      id: row.read<String>('id'),
      companyId: row.read<String>('company_id'),
      employeeId: row.read<String>('employee_id'),
      typeSnapshot: row.read<String>('type_snapshot'),
      policySnapshot: row.readNullable<String>('policy_snapshot'),
      startDate: row.read<String>('start_date'),
      endDate: row.read<String>('end_date'),
      startPortion: row.read<String>('start_portion'),
      endPortion: row.read<String>('end_portion'),
      requestedDays: row.read<double>('requested_days'),
      reason: row.read<String>('reason'),
      attachmentName: row.readNullable<String>('attachment_name'),
      status: row.read<String>('status'),
      submittedMilliseconds: row.readNullable<int>('submitted_milliseconds'),
      reviewedMilliseconds: row.readNullable<int>('reviewed_milliseconds'),
      reviewedBy: row.readNullable<String>('reviewed_by'),
      reviewNote: row.readNullable<String>('review_note'),
      cancelledMilliseconds: row.readNullable<int>('cancelled_milliseconds'),
      cancelledBy: row.readNullable<String>('cancelled_by'),
      cancellationReason: row.readNullable<String>('cancellation_reason'),
      createdMilliseconds: row.read<int>('created_milliseconds'),
      updatedMilliseconds: row.read<int>('updated_milliseconds'),
      requestId: row.read<String>('request_id'),
      syncStatus: row.read<String>('sync_status'),
    );
    return LeaveRequestRow(
      request: _mapRequest(data),
      employeeName: row.read<String>('employee_name'),
      employeeCode: row.read<String>('employee_code'),
      department: row.read<String>('department'),
    );
  }

  LeaveBalanceTransaction _mapTransaction(LeaveBalanceTransactionData row) =>
      LeaveBalanceTransaction(
        id: row.id,
        companyId: row.companyId,
        employeeId: row.employeeId,
        leaveTypeId: row.leaveTypeId,
        leaveYear: row.leaveYear,
        type: LeaveBalanceTransactionType.values.firstWhere(
          (t) => t.name == row.type,
          orElse: () => LeaveBalanceTransactionType.migration,
        ),
        quantityDays: row.quantityDays,
        leaveRequestId: row.leaveRequestId,
        reason: row.reason,
        createdBy: row.createdBy,
        effectiveDate: _parseDate(row.effectiveDate),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          row.createdMilliseconds,
          isUtc: true,
        ),
        requestId: row.requestId,
        syncStatus: row.syncStatus,
      );

  LeaveCompensationType _compensation(String value) =>
      LeaveCompensationType.values.firstWhere(
        (c) => c.name == value,
        orElse: () => LeaveCompensationType.paid,
      );
}
