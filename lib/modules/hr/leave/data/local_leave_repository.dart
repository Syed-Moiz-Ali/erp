import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/app/app_config.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/platform/notifications/domain/app_notification.dart';
import 'package:modular_erp/platform/notifications/domain/notification_repository.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_repository.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_services.dart';
import 'package:modular_erp/modules/hr/module/hr_routes.dart';

class LocalLeaveRepository implements LeaveRepository {
  const LocalLeaveRepository(
    this.db,
    this.auth,
    this.clock, {
    this.notifications,
    this.demoEnabled = AppConfig.demoAuthEnabled,
    this.calculator = const LeaveDayCalculator(),
    this.yearResolver = const LeaveYearResolver(),
    this.time = const FixedOffsetCompanyTimeService(),
  });

  final AppDatabase db;
  final AuthRepository auth;
  final AppClock clock;
  final NotificationRepository? notifications;
  final bool demoEnabled;
  final LeaveDayCalculator calculator;
  final LeaveYearResolver yearResolver;
  final CompanyTimeService time;

  Failed<T> _fail<T>(
    String code, {
    FailureKind kind = FailureKind.invalidData,
  }) => Failed(Failure(code: code, kind: kind));

  bool _can(AuthContext actor, AppPermission permission) =>
      PermissionChecker(actor.user.permissions).can(permission);

  /// Company business date (UTC midnight) resolved through the company time
  /// zone, never the device's local date.
  @override
  DateTime companyToday(AuthContext context) {
    final wall = time.localWallTime(
      clock.now().toUtc(),
      context.company.timezone,
    );
    if (wall is Success<DateTime>) {
      final value = wall.value;
      return DateTime.utc(value.year, value.month, value.day);
    }
    final now = clock.now().toUtc();
    return DateTime.utc(now.year, now.month, now.day);
  }

  @override
  int leaveYearFor(DateTime date) => yearResolver.yearFor(date);

  DateTime _companyTodayFor(AuthContext context) => companyToday(context);

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
        source: Value(draft.source.name),
        calendarId: Value(draft.calendarId),
        countryCode: Value(draft.countryCode),
        regionCode: Value(draft.regionCode),
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

  // ---- holiday calendars / yearly management -------------------------------

  @override
  Stream<Result<List<Holiday>>> watchHolidaysForYear(
    AuthContext context,
    int year, {
    bool includeInactive = false,
  }) => watchHolidays(context, includeInactive: includeInactive).map((result) {
    if (result is Failed<List<Holiday>>) return result;
    final from = DateTime.utc(year, 1, 1), to = DateTime.utc(year, 12, 31);
    return Success(
      (result as Success<List<Holiday>>).value.where((holiday) {
        final end = holiday.endDate ?? holiday.date;
        return !end.isBefore(from) && !holiday.date.isAfter(to);
      }).toList(),
    );
  });

  @override
  Stream<Result<List<HolidayCalendar>>> watchHolidayCalendars(
    AuthContext context,
  ) {
    final p = PermissionChecker(context.user.permissions);
    if (!p.canAny([AppPermission.holidayView, AppPermission.holidayManage])) {
      return Stream.value(_fail('leavePermissionDenied'));
    }
    return (db.select(db.holidayCalendars)
          ..where((t) => t.companyId.equals(context.company.id))
          ..orderBy([(t) => OrderingTerm.desc(t.year)]))
        .watch()
        .map((rows) => Success(rows.map(_mapCalendar).toList()));
  }

  @override
  Future<Result<HolidayCalendar>> saveHolidayCalendar(
    AuthContext context,
    HolidayCalendarDraft draft,
  ) async {
    if (!_can(context, AppPermission.holidayManage)) {
      return _fail('leavePermissionDenied');
    }
    if (draft.name.trim().isEmpty || draft.year < 2000 || draft.year > 2200) {
      return _fail('leaveInvalidQuantity');
    }
    try {
      final now = clock.now().toUtc();
      return await db.transaction(() async {
        final existing =
            await (db.select(db.holidayCalendars)..where(
                  (t) =>
                      t.companyId.equals(context.company.id) &
                      t.year.equals(draft.year) &
                      t.name.equals(draft.name.trim()),
                ))
                .getSingleOrNull();
        final id = existing?.id ?? const Uuid().v4();
        final count =
            (await (db.select(db.holidayCalendars)..where(
                      (t) =>
                          t.companyId.equals(context.company.id) &
                          t.year.equals(draft.year),
                    ))
                    .get())
                .length;
        final makeDefault = draft.isDefault || count == 0;
        if (makeDefault) {
          await (db.update(db.holidayCalendars)..where(
                (t) =>
                    t.companyId.equals(context.company.id) &
                    t.year.equals(draft.year),
              ))
              .write(const HolidayCalendarsCompanion(isDefault: Value(false)));
        }
        final companion = HolidayCalendarsCompanion.insert(
          id: id,
          companyId: context.company.id,
          name: draft.name.trim(),
          year: draft.year,
          countryCode: Value(draft.countryCode),
          regionCode: Value(draft.regionCode),
          isDefault: Value(makeDefault),
          createdMilliseconds:
              existing?.createdMilliseconds ?? now.millisecondsSinceEpoch,
          updatedMilliseconds: now.millisecondsSinceEpoch,
        );
        if (existing == null) {
          await db.into(db.holidayCalendars).insert(companion);
        } else {
          await (db.update(
            db.holidayCalendars,
          )..where((t) => t.id.equals(id))).write(companion);
        }
        final row = await (db.select(
          db.holidayCalendars,
        )..where((t) => t.id.equals(id))).getSingle();
        return Success(_mapCalendar(row));
      });
    } catch (_) {
      return _fail('leaveStorageError', kind: FailureKind.storageWrite);
    }
  }

  @override
  Future<Result<int>> copyHolidaysToYear(
    AuthContext context, {
    required int fromYear,
    required int toYear,
  }) async {
    if (!_can(context, AppPermission.holidayManage)) {
      return _fail('leavePermissionDenied');
    }
    if (fromYear == toYear) return _fail('leaveInvalidQuantity');
    try {
      final now = clock.now().toUtc();
      return await db.transaction(() async {
        final source = await _holidayRowsForYear(context.company.id, fromYear);
        final calendarId = await _ensureYearCalendar(
          context.company.id,
          toYear,
          now,
        );
        final existing = await _holidayRowsForYear(context.company.id, toYear);
        final existingKeys = {
          for (final row in existing) '${row.date}|${row.name}',
        };
        var copied = 0;
        for (final row in source) {
          final shifted = _shiftYear(_parseDate(row.date), toYear);
          if (existingKeys.contains('${_d(shifted)}|${row.name}')) continue;
          await db
              .into(db.holidays)
              .insert(
                HolidaysCompanion.insert(
                  id: const Uuid().v4(),
                  companyId: context.company.id,
                  name: row.name,
                  date: _d(shifted),
                  endDate: Value(
                    row.endDate == null
                        ? null
                        : _d(_shiftYear(_parseDate(row.endDate!), toYear)),
                  ),
                  type: Value(row.type),
                  scope: Value(row.scope),
                  workLocationIds: Value(row.workLocationIds),
                  description: Value(row.description),
                  isOptional: Value(row.isOptional),
                  source: Value(HolidaySource.copiedFromPreviousYear.name),
                  calendarId: Value(calendarId),
                  countryCode: Value(row.countryCode),
                  regionCode: Value(row.regionCode),
                  createdMilliseconds: now.millisecondsSinceEpoch,
                  updatedMilliseconds: now.millisecondsSinceEpoch,
                ),
              );
          copied++;
        }
        return Success(copied);
      });
    } catch (_) {
      return _fail('leaveStorageError', kind: FailureKind.storageWrite);
    }
  }

  @override
  Future<Result<HolidayImportResult>> importHolidays(
    AuthContext context,
    List<HolidayImportRow> rows,
  ) async {
    if (!_can(context, AppPermission.holidayManage)) {
      return _fail('leavePermissionDenied');
    }
    try {
      final now = clock.now().toUtc();
      return await db.transaction(() async {
        final allowedLocations = {
          for (final row in await (db.select(
            db.workLocationRecords,
          )..where((t) => t.companyId.equals(context.company.id))).get())
            row.id,
        };
        final existing = <String>{};
        final all = await (db.select(
          db.holidays,
        )..where((t) => t.companyId.equals(context.company.id))).get();
        for (final holiday in all) {
          existing.add(
            '${holiday.date}|${holiday.isOptional}|${holiday.scope}|${holiday.name}',
          );
        }
        final errors = <String>[];
        var imported = 0, skipped = 0;
        for (final row in rows) {
          if (!row.isValid) {
            skipped++;
            errors.add(row.error ?? 'invalid');
            continue;
          }
          final draft = row.draft;
          final date = draft.date;
          if (date == null) {
            skipped++;
            errors.add('invalidDate');
            continue;
          }
          if (draft.scope == HolidayScope.specificWorkLocations &&
              !draft.workLocationIds.every(allowedLocations.contains)) {
            skipped++;
            errors.add('${draft.name}: invalidWorkLocation');
            continue;
          }
          final key =
              '${_d(date)}|${draft.isOptional}|${draft.scope.name}|${draft.name.trim()}';
          if (existing.contains(key)) {
            skipped++;
            errors.add('${draft.name}: duplicate');
            continue;
          }
          await db
              .into(db.holidays)
              .insert(
                HolidaysCompanion.insert(
                  id: const Uuid().v4(),
                  companyId: context.company.id,
                  name: draft.name.trim(),
                  date: _d(date),
                  endDate: Value(
                    draft.endDate == null ? null : _d(draft.endDate!),
                  ),
                  type: Value(draft.type.name),
                  scope: Value(draft.scope.name),
                  workLocationIds: Value(
                    jsonEncode(draft.workLocationIds.toList()),
                  ),
                  description: Value(draft.description.trim()),
                  isOptional: Value(draft.isOptional),
                  source: Value(HolidaySource.imported.name),
                  calendarId: Value(draft.calendarId),
                  countryCode: Value(draft.countryCode),
                  regionCode: Value(draft.regionCode),
                  createdMilliseconds: now.millisecondsSinceEpoch,
                  updatedMilliseconds: now.millisecondsSinceEpoch,
                ),
              );
          existing.add(key);
          imported++;
        }
        return Success(
          HolidayImportResult(
            imported: imported,
            skipped: skipped,
            errors: errors,
          ),
        );
      });
    } catch (_) {
      return _fail('leaveStorageError', kind: FailureKind.storageWrite);
    }
  }

  @override
  Future<Result<Holiday?>> nextHoliday(
    AuthContext context,
    String employeeId,
    DateTime from,
  ) async {
    final result = await applicableHolidays(
      context,
      employeeId,
      leaveDate(from),
      leaveDate(from).add(const Duration(days: 400)),
    );
    if (result is Failed<List<Holiday>>) return Failed(result.failure);
    final holidays = (result as Success<List<Holiday>>).value;
    final upcoming =
        holidays
            .where((h) => !(h.endDate ?? h.date).isBefore(leaveDate(from)))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return Success(upcoming.isEmpty ? null : upcoming.first);
  }

  Future<List<HolidayData>> _holidayRowsForYear(
    String companyId,
    int year,
  ) async {
    final rows =
        await (db.select(db.holidays)..where(
              (t) =>
                  t.companyId.equals(companyId) &
                  t.date.isSmallerOrEqualValue('$year-12-31'),
            ))
            .get();
    final from = DateTime.utc(year, 1, 1), to = DateTime.utc(year, 12, 31);
    return rows.where((row) {
      final end = row.endDate == null
          ? _parseDate(row.date)
          : _parseDate(row.endDate!);
      return !end.isBefore(from) && !_parseDate(row.date).isAfter(to);
    }).toList();
  }

  Future<String?> _ensureYearCalendar(
    String companyId,
    int year,
    DateTime now,
  ) async {
    final existing =
        await (db.select(db.holidayCalendars)..where(
              (t) =>
                  t.companyId.equals(companyId) &
                  t.year.equals(year) &
                  t.isDefault.equals(true),
            ))
            .getSingleOrNull();
    if (existing != null) return existing.id;
    final id = const Uuid().v4();
    await db
        .into(db.holidayCalendars)
        .insert(
          HolidayCalendarsCompanion.insert(
            id: id,
            companyId: companyId,
            name: '$year Calendar',
            year: year,
            isDefault: const Value(true),
            createdMilliseconds: now.millisecondsSinceEpoch,
            updatedMilliseconds: now.millisecondsSinceEpoch,
          ),
        );
    return id;
  }

  DateTime _shiftYear(DateTime date, int year) {
    final shifted = DateTime.utc(year, date.month, date.day);
    return shifted;
  }

  HolidayCalendar _mapCalendar(HolidayCalendarData row) => HolidayCalendar(
    id: row.id,
    companyId: row.companyId,
    name: row.name,
    year: row.year,
    countryCode: row.countryCode,
    regionCode: row.regionCode,
    isDefault: row.isDefault,
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
  );

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
        final today = _companyTodayFor(actor);
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
        route: HrRoutes.leaveRequestDetails(request.id),
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
        route: HrRoutes.leaveRequestDetails(requestId),
        payload: {'requestId': requestId},
        createdAt: clock.now().toUtc(),
      ),
    );
  }

  // ---- request lists -------------------------------------------------------

  static const String _requestSelect =
      '''SELECT r.id, r.company_id, r.employee_id, r.type_snapshot,
 r.policy_snapshot, r.start_date, r.end_date, r.start_portion, r.end_portion,
 r.requested_days, r.reason, r.attachment_name, r.status,
 r.submitted_milliseconds, r.reviewed_milliseconds, r.reviewed_by,
 r.review_note, r.cancelled_milliseconds, r.cancelled_by,
 r.cancellation_reason, r.created_milliseconds, r.updated_milliseconds,
 r.request_id, r.sync_status,
 e.first_name, e.middle_name, e.last_name, e.employee_code, e.department_id,
 COALESCE(d.name,'') department, COALESCE(g.name,'') designation,
 COALESCE(m.first_name || ' ' || m.last_name,'') manager_name
FROM leave_requests r
JOIN workforce_employees e ON e.id = r.employee_id AND e.company_id = r.company_id
LEFT JOIN workforce_departments d ON d.id = e.department_id AND d.company_id = e.company_id
LEFT JOIN workforce_designations g ON g.id = e.designation_id AND g.company_id = e.company_id
LEFT JOIN workforce_employees m ON m.id = e.manager_id AND m.company_id = e.company_id''';

  static const String _requestOrder =
      'ORDER BY r.start_date DESC, r.created_milliseconds DESC';

  /// Returns the scope predicate for [scope] and appends its bind variables, or
  /// `null` when the actor lacks the capability. Company/approve-all return ''.
  String? _scopeClause(
    AuthContext context,
    LeaveRequestScope scope,
    PermissionChecker p,
    List<Variable<Object>> vars,
  ) {
    switch (scope) {
      case LeaveRequestScope.self:
        final id = context.employeeReference?.id;
        if (id == null || !p.can(AppPermission.leaveViewSelf)) return null;
        vars.add(Variable(id));
        return 'r.employee_id = ?';
      case LeaveRequestScope.team:
        final id = context.employeeReference?.id;
        if (id == null || !p.can(AppPermission.leaveViewTeam)) return null;
        vars.add(Variable(id));
        return 'e.manager_id = ?';
      case LeaveRequestScope.company:
        if (!p.can(AppPermission.leaveViewAll)) return null;
        return '';
      case LeaveRequestScope.approvals:
        if (p.can(AppPermission.leaveApproveAll)) return '';
        final id = context.employeeReference?.id;
        if (p.can(AppPermission.leaveApproveTeam) && id != null) {
          vars.add(Variable(id));
          return 'e.manager_id = ?';
        }
        return null;
    }
  }

  LeaveRequestRow _rowFromQuery(QueryRow row) {
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
    final name = [
      row.read<String>('first_name'),
      row.readNullable<String>('middle_name') ?? '',
      row.read<String>('last_name'),
    ].where((s) => s.isNotEmpty).join(' ');
    return LeaveRequestRow(
      request: _mapRequest(data),
      employeeName: name,
      employeeCode: row.read<String>('employee_code'),
      department: row.read<String>('department'),
      departmentId: row.read<String>('department_id'),
      designation: row.read<String>('designation'),
      managerName: row.read<String>('manager_name'),
    );
  }

  Stream<Result<List<LeaveRequestRow>>> _scopedRows(
    AuthContext context,
    LeaveRequestScope scope, {
    int limit = 1000,
  }) {
    final p = PermissionChecker(context.user.permissions);
    final vars = <Variable<Object>>[Variable(context.company.id)];
    final scopeClause = _scopeClause(context, scope, p, vars);
    if (scopeClause == null) {
      return Stream.value(_fail('leavePermissionDenied'));
    }
    final where = scopeClause.isEmpty ? '' : ' AND $scopeClause';
    vars.add(Variable(limit));
    return db
        .customSelect(
          '$_requestSelect WHERE r.company_id = ?$where $_requestOrder LIMIT ?',
          variables: vars,
          readsFrom: {
            db.leaveRequests,
            db.workforceEmployees,
            db.workforceDepartments,
            db.workforceDesignations,
          },
        )
        .watch()
        .map((rows) => Success(rows.map(_rowFromQuery).toList()));
  }

  bool _matchesFilter(LeaveRequestRow row, LeaveRequestFilter filter) {
    final request = row.request;
    if (filter.status != null && request.status != filter.status) return false;
    if (filter.leaveTypeId != null &&
        request.typeSnapshot.typeId != filter.leaveTypeId) {
      return false;
    }
    if (filter.employeeId != null && request.employeeId != filter.employeeId) {
      return false;
    }
    if (filter.departmentId != null &&
        row.departmentId != filter.departmentId) {
      return false;
    }
    if (filter.from != null &&
        request.endDate.isBefore(leaveDate(filter.from!))) {
      return false;
    }
    if (filter.to != null && request.startDate.isAfter(leaveDate(filter.to!))) {
      return false;
    }
    final q = filter.search.trim().toLowerCase();
    if (q.isNotEmpty &&
        !row.employeeName.toLowerCase().contains(q) &&
        !row.employeeCode.toLowerCase().contains(q)) {
      return false;
    }
    return true;
  }

  Future<int> _scopedEmployeeCount(
    AuthContext context,
    LeaveRequestScope scope,
  ) async {
    final team = scope == LeaveRequestScope.team;
    final row = await db
        .customSelect(
          'SELECT COUNT(*) n FROM workforce_employees WHERE company_id = ? AND status = ?${team ? ' AND manager_id = ?' : ''}',
          variables: [
            Variable(context.company.id),
            Variable('active'),
            if (team) Variable(context.employeeReference!.id),
          ],
        )
        .getSingle();
    return row.read<int>('n');
  }

  @override
  Stream<Result<List<LeaveRequestRow>>> watchRequests(
    AuthContext context, {
    required LeaveRequestScope scope,
    LeaveRequestStatus? status,
    LeaveRequestFilter filter = const LeaveRequestFilter(),
    int limit = 200,
  }) {
    final effective = status == null ? filter : filter.copyWith(status: status);
    return _scopedRows(context, scope, limit: limit).map((result) {
      switch (result) {
        case Success<List<LeaveRequestRow>>(:final value):
          return Success(
            value.where((r) => _matchesFilter(r, effective)).toList(),
          );
        case Failed<List<LeaveRequestRow>>():
          return result;
      }
    });
  }

  @override
  Stream<Result<LeaveOperationsData>> watchOperations(
    AuthContext context, {
    required LeaveRequestScope scope,
    LeaveRequestFilter filter = const LeaveRequestFilter(),
    int upcomingDays = 30,
  }) {
    return _scopedRows(context, scope).asyncMap((result) async {
      if (result is Failed<List<LeaveRequestRow>>) {
        return Failed<LeaveOperationsData>(result.failure);
      }
      final rows = (result as Success<List<LeaveRequestRow>>).value;
      final today = _companyTodayFor(context);
      final horizon = today.add(Duration(days: upcomingDays));
      final onLeaveToday = <LeaveTodayItem>[];
      final upcoming = <UpcomingLeaveItem>[];
      var pending = 0;
      var approvedThisMonth = 0;
      for (final row in rows) {
        final request = row.request;
        if (request.status == LeaveRequestStatus.approved) {
          if (!request.startDate.isAfter(today) &&
              !request.endDate.isBefore(today)) {
            onLeaveToday.add(
              LeaveTodayItem(
                row: row,
                returnDate: request.endDate.add(const Duration(days: 1)),
                designation: row.designation,
              ),
            );
          } else if (request.startDate.isAfter(today) &&
              !request.startDate.isAfter(horizon)) {
            upcoming.add(
              UpcomingLeaveItem(row: row, workingDays: request.requestedDays),
            );
          }
          if (request.startDate.year == today.year &&
              request.startDate.month == today.month) {
            approvedThisMonth++;
          }
        } else if (request.status == LeaveRequestStatus.pending) {
          pending++;
        }
      }
      upcoming.sort(
        (a, b) => a.row.request.startDate.compareTo(b.row.request.startDate),
      );
      onLeaveToday.sort(
        (a, b) => a.row.employeeName.compareTo(b.row.employeeName),
      );
      final teamMembers = await _scopedEmployeeCount(context, scope);
      return Success(
        LeaveOperationsData(
          summary: LeaveOperationsSummary(
            onLeaveToday: onLeaveToday.length,
            upcoming: upcoming.length,
            pending: pending,
            approvedThisMonth: approvedThisMonth,
            teamMembers: teamMembers,
          ),
          today: onLeaveToday,
          upcoming: upcoming,
          requests: rows.where((r) => _matchesFilter(r, filter)).toList(),
        ),
      );
    });
  }

  @override
  Stream<Result<List<LeaveApprovalItem>>> watchApprovalQueue(
    AuthContext context,
  ) {
    return _scopedRows(context, LeaveRequestScope.approvals).asyncMap((
      result,
    ) async {
      if (result is Failed<List<LeaveRequestRow>>) {
        return Failed<List<LeaveApprovalItem>>(result.failure);
      }
      final pending = (result as Success<List<LeaveRequestRow>>).value
          .where((r) => r.request.isPending)
          .toList();
      final cache = <String, List<double>>{};
      final items = <LeaveApprovalItem>[];
      for (final row in pending) {
        final request = row.request;
        final year = yearResolver.yearFor(request.startDate);
        final key =
            '${request.employeeId}|${request.typeSnapshot.typeId}|$year';
        final totals = cache[key] ??= await _balanceTotals(
          context.company.id,
          request.employeeId,
          request.typeSnapshot.typeId,
          year,
        );
        items.add(
          LeaveApprovalItem(
            row: row,
            entitlement: totals[0],
            used: totals[1],
            pending: totals[2],
          ),
        );
      }
      items.sort((a, b) {
        final start = a.row.request.startDate.compareTo(
          b.row.request.startDate,
        );
        if (start != 0) return start;
        final aSubmitted = a.row.request.submittedAt ?? a.row.request.createdAt;
        final bSubmitted = b.row.request.submittedAt ?? b.row.request.createdAt;
        return aSubmitted.compareTo(bSubmitted);
      });
      return Success(items);
    });
  }

  /// Returns [entitlement, used, pending] for one employee/type/year.
  Future<List<double>> _balanceTotals(
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
    return [entitlement, used, pending];
  }

  @override
  Stream<Result<EmployeeLeaveSummary?>> watchEmployeeLeave(
    AuthContext context,
    String employeeId,
  ) {
    final p = PermissionChecker(context.user.permissions);
    final isSelf = context.employeeReference?.id == employeeId;
    final canViewAll = p.can(AppPermission.leaveViewAll);
    final allowed = isSelf
        ? p.can(AppPermission.leaveViewSelf)
        : canViewAll ||
              (p.can(AppPermission.leaveViewTeam) &&
                  context.employeeReference != null);
    if (!allowed) {
      return Stream.value(_fail('leavePermissionDenied'));
    }
    final scope = isSelf
        ? LeaveRequestScope.self
        : (canViewAll ? LeaveRequestScope.company : LeaveRequestScope.team);
    return _scopedRows(context, scope).asyncMap((result) async {
      if (result is Failed<List<LeaveRequestRow>>) {
        return Failed<EmployeeLeaveSummary?>(result.failure);
      }
      final rows = (result as Success<List<LeaveRequestRow>>).value
          .where((r) => r.request.employeeId == employeeId)
          .toList();
      final employee = await _employeeIdentity(context.company.id, employeeId);
      if (employee == null) return const Success(null);
      final today = _companyTodayFor(context);
      final year = yearResolver.yearFor(today);
      final balancesResult = await _balanceSummaries(context, employeeId, year);
      final balances = balancesResult is Success<List<LeaveBalanceSummary>>
          ? balancesResult.value
          : const <LeaveBalanceSummary>[];
      final upcoming =
          rows
              .where(
                (r) =>
                    r.request.status == LeaveRequestStatus.approved &&
                    r.request.startDate.isAfter(today),
              )
              .toList()
            ..sort(
              (a, b) => a.request.startDate.compareTo(b.request.startDate),
            );
      final recent = rows.toList()
        ..sort(
          (a, b) => (b.request.submittedAt ?? b.request.createdAt).compareTo(
            a.request.submittedAt ?? a.request.createdAt,
          ),
        );
      return Success(
        EmployeeLeaveSummary(
          employeeId: employeeId,
          employeeName: employee.name,
          employeeCode: employee.code,
          department: employee.department,
          designation: employee.designation,
          managerName: employee.managerName,
          balances: balances,
          upcoming: upcoming,
          recent: recent,
        ),
      );
    });
  }

  Future<
    ({
      String name,
      String code,
      String department,
      String designation,
      String managerName,
    })?
  >
  _employeeIdentity(String companyId, String employeeId) async {
    final row = await db
        .customSelect(
          '''SELECT e.first_name, e.middle_name, e.last_name, e.employee_code,
 COALESCE(d.name,'') department, COALESCE(g.name,'') designation,
 COALESCE(m.first_name || ' ' || m.last_name,'') manager_name
FROM workforce_employees e
LEFT JOIN workforce_departments d ON d.id = e.department_id AND d.company_id = e.company_id
LEFT JOIN workforce_designations g ON g.id = e.designation_id AND g.company_id = e.company_id
LEFT JOIN workforce_employees m ON m.id = e.manager_id AND m.company_id = e.company_id
WHERE e.company_id = ? AND e.id = ?''',
          variables: [Variable(companyId), Variable(employeeId)],
        )
        .getSingleOrNull();
    if (row == null) return null;
    final name = [
      row.read<String>('first_name'),
      row.readNullable<String>('middle_name') ?? '',
      row.read<String>('last_name'),
    ].where((s) => s.isNotEmpty).join(' ');
    return (
      name: name,
      code: row.read<String>('employee_code'),
      department: row.read<String>('department'),
      designation: row.read<String>('designation'),
      managerName: row.read<String>('manager_name'),
    );
  }

  @override
  Stream<Result<List<LeaveBalanceRow>>> watchBalanceTable(
    AuthContext context, {
    int? year,
    String? departmentId,
    String? leaveTypeId,
    String search = '',
  }) {
    final p = PermissionChecker(context.user.permissions);
    final canAll = p.can(AppPermission.leaveBalanceViewAll);
    final canTeam = p.can(AppPermission.leaveBalanceViewTeam);
    if (!canAll && !canTeam) {
      return Stream.value(_fail('leavePermissionDenied'));
    }
    final leaveYear = year ?? yearResolver.yearFor(_companyTodayFor(context));
    final scope = canAll ? LeaveRequestScope.company : LeaveRequestScope.team;
    return _scopedRows(context, scope).asyncMap((_) async {
      try {
        final team = !canAll;
        final employees = await db
            .customSelect(
              '''SELECT e.id, e.first_name, e.middle_name, e.last_name,
 e.employee_code, e.department_id, COALESCE(d.name,'') department
FROM workforce_employees e
LEFT JOIN workforce_departments d ON d.id = e.department_id AND d.company_id = e.company_id
WHERE e.company_id = ? AND e.status = ?${team ? ' AND e.manager_id = ?' : ''}
ORDER BY e.first_name''',
              variables: [
                Variable(context.company.id),
                Variable('active'),
                if (team) Variable(context.employeeReference!.id),
              ],
            )
            .get();
        final types =
            await (db.select(db.leaveTypes)..where(
                  (t) =>
                      t.companyId.equals(context.company.id) &
                      t.status.equals('active'),
                ))
                .get();
        final ledger =
            await (db.select(db.leaveBalanceTransactions)..where(
                  (t) =>
                      t.companyId.equals(context.company.id) &
                      t.leaveYear.equals(leaveYear),
                ))
                .get();
        final requests =
            await (db.select(db.leaveRequests)..where(
                  (t) =>
                      t.companyId.equals(context.company.id) &
                      t.status.isIn(['approved', 'pending']) &
                      t.startDate.like(
                        '${leaveYear.toString().padLeft(4, '0')}%',
                      ),
                ))
                .get();
        final entitlement = <String, double>{};
        for (final t in ledger) {
          final key = '${t.employeeId}|${t.leaveTypeId}';
          entitlement[key] =
              (entitlement[key] ?? 0) +
              switch (t.type) {
                'entitlement' ||
                'carryForward' ||
                'migration' ||
                'adjustmentAdd' => t.quantityDays,
                'adjustmentSubtract' || 'expiry' => -t.quantityDays,
                _ => 0.0,
              };
        }
        final used = <String, double>{};
        final pending = <String, double>{};
        for (final r in requests) {
          final snapshot = LeaveTypeSnapshot.fromJson(
            jsonDecode(r.typeSnapshot) as Map<String, dynamic>,
          );
          final key = '${r.employeeId}|${snapshot.typeId}';
          if (r.status == 'approved') {
            used[key] = (used[key] ?? 0) + r.requestedDays;
          } else {
            pending[key] = (pending[key] ?? 0) + r.requestedDays;
          }
        }
        final q = search.trim().toLowerCase();
        final rows = <LeaveBalanceRow>[];
        for (final employee in employees) {
          final name = [
            employee.read<String>('first_name'),
            employee.readNullable<String>('middle_name') ?? '',
            employee.read<String>('last_name'),
          ].where((s) => s.isNotEmpty).join(' ');
          if (q.isNotEmpty &&
              !name.toLowerCase().contains(q) &&
              !employee
                  .read<String>('employee_code')
                  .toLowerCase()
                  .contains(q)) {
            continue;
          }
          if (departmentId != null &&
              employee.read<String>('department_id') != departmentId) {
            continue;
          }
          for (final type in types) {
            if (leaveTypeId != null && type.id != leaveTypeId) continue;
            final key = '${employee.read<String>('id')}|${type.id}';
            rows.add(
              LeaveBalanceRow(
                employeeId: employee.read<String>('id'),
                employeeName: name,
                employeeCode: employee.read<String>('employee_code'),
                department: employee.read<String>('department'),
                leaveTypeId: type.id,
                leaveTypeName: type.name,
                entitlement: entitlement[key] ?? 0,
                used: used[key] ?? 0,
                pending: pending[key] ?? 0,
              ),
            );
          }
        }
        return Success(rows);
      } catch (_) {
        return _fail('leaveStorageError');
      }
    });
  }

  @override
  Stream<Result<List<LeaveDepartmentOption>>> watchDepartments(
    AuthContext context,
  ) {
    final p = PermissionChecker(context.user.permissions);
    if (!p.canAny([
      AppPermission.leaveViewAll,
      AppPermission.leaveBalanceViewAll,
      AppPermission.leaveBalanceViewTeam,
    ])) {
      return Stream.value(_fail('leavePermissionDenied'));
    }
    return db
        .customSelect(
          'SELECT id, name FROM workforce_departments WHERE company_id = ? AND active = ? ORDER BY name',
          variables: [Variable(context.company.id), Variable(true)],
          readsFrom: {db.workforceDepartments},
        )
        .watch()
        .map(
          (rows) => Success([
            for (final row in rows)
              LeaveDepartmentOption(
                row.read<String>('id'),
                row.read<String>('name'),
              ),
          ]),
        );
  }

  @override
  Future<Result<LeaveRequestRow?>> requestById(
    AuthContext context,
    String id,
  ) async {
    try {
      final rows = await db
          .customSelect(
            '$_requestSelect WHERE r.company_id = ? AND r.id = ?',
            variables: [Variable(context.company.id), Variable(id)],
          )
          .get();
      if (rows.isEmpty) return const Success(null);
      final row = _rowFromQuery(rows.single);
      final p = PermissionChecker(context.user.permissions);
      final isSelf = context.employeeReference?.id == row.request.employeeId;
      final canView = isSelf
          ? p.can(AppPermission.leaveViewSelf)
          : p.can(AppPermission.leaveViewAll) ||
                await _canReview(context, row.request.employeeId);
      if (!canView) return _fail('leavePermissionDenied');
      return Success(row);
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
    final leaveYear = year ?? yearResolver.yearFor(_companyTodayFor(context));
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
              requestId: request.id,
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

  @override
  Future<Result<Set<String>>> employeesOnApprovedLeave(
    AuthContext context,
    DateTime date, {
    required List<String> employeeIds,
  }) async {
    if (employeeIds.isEmpty) return const Success(<String>{});
    try {
      final day = leaveDate(date);
      final rows =
          await (db.select(db.leaveRequests)..where(
                (t) =>
                    t.companyId.equals(context.company.id) &
                    t.status.equals('approved') &
                    t.startDate.isSmallerOrEqualValue(_d(day)) &
                    t.endDate.isBiggerOrEqualValue(_d(day)),
              ))
              .get();
      final ids = employeeIds.toSet();
      return Success({
        for (final row in rows)
          if (ids.contains(row.employeeId)) row.employeeId,
      });
    } catch (_) {
      return _fail('leaveStorageError');
    }
  }

  @override
  Future<Result<bool>> companyHolidayOn(
    AuthContext context,
    DateTime date,
  ) async {
    try {
      final day = leaveDate(date);
      final rows =
          await (db.select(db.holidays)..where(
                (t) =>
                    t.companyId.equals(context.company.id) &
                    t.status.equals('active') &
                    t.isOptional.equals(false) &
                    t.scope.equals(HolidayScope.companyWide.name) &
                    t.date.isSmallerOrEqualValue(_d(day)),
              ))
              .get();
      for (final row in rows) {
        final start = _parseDate(row.date);
        final end = row.endDate == null ? start : _parseDate(row.endDate!);
        if (!end.isBefore(day) && !start.isAfter(day)) {
          return const Success(true);
        }
      }
      return const Success(false);
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
    source: HolidaySource.values.firstWhere(
      (s) => s.name == row.source,
      orElse: () => HolidaySource.manual,
    ),
    calendarId: row.calendarId,
    countryCode: row.countryCode,
    regionCode: row.regionCode,
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
