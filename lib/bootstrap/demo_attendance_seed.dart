import 'package:drift/drift.dart';
import '../app/app_config.dart';
import '../core/database/app_database.dart';
import '../core/errors/result.dart';
import '../core/models/configuration_record.dart';
import '../core/utils/app_clock.dart';
import '../core/utils/local_time.dart';
import '../features/auth/data/datasources/local/demo_auth_source.dart';
import '../features/auth/domain/entities/auth_context.dart';
import '../features/shifts/domain/shift.dart';
import '../features/shifts/data/local_shift_repository.dart';
import '../features/work_locations/data/local_work_location_repository.dart';
import '../features/attendance_policies/domain/attendance_policy.dart';
import '../features/attendance_policies/data/local_attendance_policy_repository.dart';
import '../features/attendance/data/attendance_local_data_source.dart';
import '../features/attendance/domain/attendance_models.dart';
import '../features/attendance/domain/attendance_summary_calculator.dart';
import '../features/attendance/domain/shift_workday_resolver.dart';

/// UI fixtures through real Drift records, opt-in only; never run in production.
/// Idempotent per employee/month and never overwrites an existing attendance day.
Future<void> seedDemoAttendance(
  AppDatabase db, {
  bool enabled = AppConfig.demoAuthEnabled,
  AppClock clock = const SystemAppClock(),
  CompanyTimeService time = const FixedOffsetCompanyTimeService(),
}) async {
  if (!enabled) return;
  await db.transaction(() async {
    final admin = DemoAuthSource().accounts
        .firstWhere((a) => a.context.user.role == AppRole.superAdmin)
        .context;
    final shifts = LocalShiftRepository(db),
        policies = LocalAttendancePolicyRepository(db);
    final now = clock.now().toUtc();
    var shift = await shifts.raw(admin, 'shift-attendance-demo');
    if (shift == null) {
      shift = shifts
          .createRecord(
            admin,
            ShiftDraft(
              name: 'Demo General Shift',
              code: 'DEMO',
              startTime: const LocalTime(hour: 9, minute: 0),
              endTime: const LocalTime(hour: 18, minute: 0),
              workingDays: WorkingDay.values.toSet(),
              gracePeriodMinutes: 10,
            ),
            id: 'shift-attendance-demo',
            now: now,
          )
          .copyWith(syncStatus: RecordSyncStatus.synced);
      await shifts.unique(shift);
      await shifts.put(shift);
    }
    var policy = await policies.raw(admin, 'policy-attendance-demo');
    if (policy == null) {
      policy = policies
          .createRecord(
            admin,
            const AttendancePolicyDraft(
              name: 'Demo UI Attendance Policy',
              description:
                  'Demo-only: GPS-free punch, breaks and history testing.',
              requireLocation: false,
              allowRemoteAttendance: true,
              allowEarlyPunchIn: true,
              earlyPunchInLimitMinutes: 540,
              allowLatePunchIn: true,
              allowEarlyPunchOut: true,
              allowPunchOutDuringBreak: true,
            ),
            id: 'policy-attendance-demo',
            now: now,
          )
          .copyWith(syncStatus: RecordSyncStatus.synced);
      await policies.unique(policy);
      await policies.put(policy);
    }
    final location = await LocalWorkLocationRepository(
      db,
    ).raw(admin, 'location-hyderabad');
    final wall = time.localWallTime(now, admin.company.timezone);
    if (wall is! Success<DateTime>) return;
    final today = DateTime.utc(
      wall.value.year,
      wall.value.month,
      wall.value.day,
    );
    final local = AttendanceLocalDataSource(db);
    for (final employee in [
      'employee-employee',
      'employee-manager',
      'employee-hr',
    ]) {
      final row =
          await (db.select(db.workforceEmployees)..where(
                (t) =>
                    t.companyId.equals(admin.company.id) &
                    t.id.equals(employee),
              ))
              .getSingleOrNull();
      if (row == null) continue;
      // Fill missing assignments only. Preserve deliberate configuration edits.
      await (db.update(db.workforceEmployees)..where(
            (t) => t.companyId.equals(admin.company.id) & t.id.equals(employee),
          ))
          .write(
            WorkforceEmployeesCompanion(
              shiftId: row.shiftId == null
                  ? const Value('shift-attendance-demo')
                  : const Value.absent(),
              attendancePolicyId: row.attendancePolicyId == null
                  ? const Value('policy-attendance-demo')
                  : const Value.absent(),
              workLocationId: row.workLocationId == null && location != null
                  ? Value(location.id)
                  : const Value.absent(),
            ),
          );
      // Previous month plus current month, with a few intentional empty days.
      // Leave today unseeded so Punch In/Break/Punch Out stay genuinely interactive.
      for (final month in [
        DateTime.utc(today.year, today.month - 1),
        DateTime.utc(today.year, today.month),
      ]) {
        final marker =
            'demo-attendance-v1-$employee-${month.year}-${month.month}';
        if (await (db.select(
              db.workforceSeeds,
            )..where((t) => t.companyId.equals(marker))).getSingleOrNull() !=
            null) {
          continue;
        }
        final next = DateTime.utc(month.year, month.month + 1);
        for (
          var date = month;
          date.isBefore(next) && date.isBefore(today);
          date = date.add(const Duration(days: 1))
        ) {
          if (date.day % 7 == 0 ||
              await local.forDate(admin.company.id, employee, date) != null) {
            continue;
          }
          final overnight = date.day % 9 == 0;
          final frozenShift = overnight
              ? shift.copyWith(
                  name: 'Demo Night Shift',
                  startTime: const LocalTime(hour: 22, minute: 0),
                  endTime: const LocalTime(hour: 7, minute: 0),
                )
              : shift;
          DateTime instant(int minutes, {int days = 0}) =>
              (time.toInstant(
                        date.add(Duration(days: days, minutes: minutes)),
                        admin.company.timezone,
                      )
                      as Success<DateTime>)
                  .value;
          final start = instant(frozenShift.startTime.minutes),
              end = instant(
                frozenShift.endTime.minutes,
                days: overnight ? 1 : 0,
              );
          // Skip the most recent overnight if its end has not actually passed.
          if (!end.isBefore(now)) continue;
          final late = date.day % 5 == 0;
          final punchIn = start.add(Duration(minutes: late ? 18 : 3));
          final id = 'demo-attendance-$employee-${local.dateKey(date)}';
          final snapshot = AttendanceConfigurationSnapshot(
            shift: frozenShift,
            policy: policy,
            workLocation: location,
            timezone: admin.company.timezone,
            scheduledStart: start,
            scheduledEnd: end,
          );
          final events = <AttendanceEvent>[];
          final entries = [
            (AttendanceEventType.punchIn, punchIn),
            (
              AttendanceEventType.breakStart,
              start.add(const Duration(hours: 2)),
            ),
            (
              AttendanceEventType.breakEnd,
              start.add(const Duration(hours: 2, minutes: 15)),
            ),
            if (date.day % 3 == 0) ...[
              (
                AttendanceEventType.breakStart,
                start.add(const Duration(hours: 5)),
              ),
              (
                AttendanceEventType.breakEnd,
                start.add(const Duration(hours: 5, minutes: 30)),
              ),
            ],
            (AttendanceEventType.punchOut, end.add(const Duration(minutes: 4))),
          ];
          for (var i = 0; i < entries.length; i++) {
            events.add(
              AttendanceEvent(
                id: '$id-event-$i',
                attendanceDayId: id,
                companyId: admin.company.id,
                employeeId: employee,
                eventType: entries[i].$1,
                deviceTimestamp: entries[i].$2,
                sequence: i + 1,
                requestId: '$id-request-$i',
                source: AttendanceEventSource.web,
                syncStatus: AttendanceSyncStatus.synced,
                workLocationId: location?.id,
                locationValidation: const AttendanceLocationValidation(
                  state: AttendanceLocationState.notRequired,
                ),
                createdAt: entries[i].$2,
              ),
            );
          }
          final summary =
              (const AttendanceSummaryCalculator().calculate(events, now)
                      as Success<AttendanceSummary>)
                  .value;
          await local.putDay(
            AttendanceDay(
              id: id,
              companyId: admin.company.id,
              employeeId: employee,
              attendanceDate: date,
              snapshot: snapshot,
              state: AttendanceWorkdayState.completed,
              punchInAt: summary.punchInTime,
              punchOutAt: summary.punchOutTime,
              elapsedMilliseconds: summary.elapsedDuration.inMilliseconds,
              breakMilliseconds: summary.breakDuration.inMilliseconds,
              workMilliseconds: summary.workDuration.inMilliseconds,
              status: late
                  ? AttendanceDayStatus.late
                  : AttendanceDayStatus.completed,
              syncStatus: AttendanceSyncStatus.synced,
              createdAt: punchIn,
              updatedAt: events.last.effectiveTimestamp,
            ),
          );
          for (final event in events) {
            await local.insertEvent(event);
          }
        }
        await db
            .into(db.workforceSeeds)
            .insert(
              WorkforceSeedsCompanion.insert(companyId: marker, version: 1),
            );
      }
    }
  });
}
