import 'package:drift/drift.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/hr/attendance/data/attendance_local_data_source.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_summary_calculator.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/modules/hr/shifts/data/local_shift_repository.dart';
import 'package:modular_erp/modules/hr/attendance_policies/data/local_attendance_policy_repository.dart';
import 'package:modular_erp/modules/hr/work_locations/data/local_work_location_repository.dart';

/// Demo-only colleagues for Team/All views. Linked demo users remain free to
/// punch themselves; this seed never changes their current workday.
Future<void> seedDemoWorkforce(
  AppDatabase db, {
  required bool enabled,
  AppClock clock = const SystemAppClock(),
  CompanyTimeService time = const FixedOffsetCompanyTimeService(),
}) async {
  if (!enabled) return;
  await db.transaction(() async {
    final admin = DemoAuthSource()
        .findByScenario(DemoScenario.platformAdmin)!
        .context;
    final shift = await LocalShiftRepository(
      db,
    ).raw(admin, 'shift-attendance-demo');
    final policy = await LocalAttendancePolicyRepository(
      db,
    ).raw(admin, 'policy-attendance-demo');
    if (shift == null || policy == null) return;
    final location = await LocalWorkLocationRepository(
      db,
    ).raw(admin, 'location-hyderabad');
    final now = clock.now().toUtc();
    final wall = time.localWallTime(now, admin.company.timezone);
    if (wall is! Success<DateTime>) return;
    final today = DateTime.utc(
      wall.value.year,
      wall.value.month,
      wall.value.day,
    );
    final people =
        await (db.select(db.workforceEmployees)..where(
              (t) =>
                  t.companyId.equals(admin.company.id) &
                  t.status.equals('active'),
            ))
            .get();
    final local = AttendanceLocalDataSource(db);
    for (final person in people) {
      if (person.linkedUserId != null) continue;
      await (db.update(db.workforceEmployees)..where(
            (t) =>
                t.id.equals(person.id) & t.companyId.equals(admin.company.id),
          ))
          .write(
            WorkforceEmployeesCompanion(
              shiftId: person.shiftId == null
                  ? const Value('shift-attendance-demo')
                  : const Value.absent(),
              attendancePolicyId: person.attendancePolicyId == null
                  ? const Value('policy-attendance-demo')
                  : const Value.absent(),
              workLocationId: person.workLocationId == null && location != null
                  ? Value(location.id)
                  : const Value.absent(),
            ),
          );
      final index = int.tryParse(person.id.split('-').last);
      if (index == null || index < 4 || index > 9) continue;
      final old = await local.openDay(admin.company.id, person.id);
      if (old != null &&
          old.attendanceDate.isBefore(today) &&
          old.id.startsWith('demo-workforce-')) {
        final previous = await local.events(
          admin.company.id,
          person.id,
          old.id,
        );
        final out = old.snapshot.scheduledEnd;
        final event = AttendanceEvent(
          id: '${old.id}-close',
          attendanceDayId: old.id,
          companyId: admin.company.id,
          employeeId: person.id,
          eventType: AttendanceEventType.punchOut,
          deviceTimestamp: out,
          sequence: previous.length + 1,
          requestId: '${old.id}-close',
          source: AttendanceEventSource.web,
          syncStatus: AttendanceSyncStatus.synced,
          locationValidation: const AttendanceLocationValidation(
            state: AttendanceLocationState.notRequired,
          ),
          createdAt: out,
        );
        final summary = const AttendanceSummaryCalculator().calculate([
          ...previous,
          event,
        ], now);
        if (summary is Success<AttendanceSummary>) {
          await local.putDay(
            old.copyWith(
              state: AttendanceWorkdayState.completed,
              punchOutAt: summary.value.punchOutTime,
              elapsedMilliseconds: summary.value.elapsedDuration.inMilliseconds,
              breakMilliseconds: summary.value.breakDuration.inMilliseconds,
              workMilliseconds: summary.value.workDuration.inMilliseconds,
              status: old.status == AttendanceDayStatus.late
                  ? AttendanceDayStatus.late
                  : AttendanceDayStatus.completed,
              updatedAt: out,
            ),
          );
          await local.insertEvent(event);
        }
      }
      final marker = 'demo-workforce-v1-${person.id}-${local.dateKey(today)}';
      if (await (db.select(
            db.workforceSeeds,
          )..where((t) => t.companyId.equals(marker))).getSingleOrNull() !=
          null) {
        continue;
      }
      if (await local.forDate(admin.company.id, person.id, today) != null) {
        continue;
      }
      final startResult = time.toInstant(
        today.add(Duration(minutes: shift.startTime.minutes)),
        admin.company.timezone,
      );
      final endResult = time.toInstant(
        today.add(Duration(minutes: shift.endTime.minutes)),
        admin.company.timezone,
      );
      if (startResult is! Success<DateTime> ||
          endResult is! Success<DateTime>) {
        continue;
      }
      final start = startResult.value, end = endResult.value;
      if (now.isBefore(start.add(const Duration(minutes: 40)))) continue;
      final late = index == 7;
      final pin = start.add(Duration(minutes: late ? 20 : 3));
      final status = index % 3 == 0
          ? AttendanceWorkdayState.completed
          : index % 3 == 1
          ? AttendanceWorkdayState.working
          : AttendanceWorkdayState.onBreak;
      final out = now.subtract(const Duration(minutes: 25));
      final id = 'demo-workforce-${person.id}-${local.dateKey(today)}';
      final instants = <({AttendanceEventType type, DateTime time})>[
        (type: AttendanceEventType.punchIn, time: pin),
        if (status == AttendanceWorkdayState.onBreak)
          (
            type: AttendanceEventType.breakStart,
            time: now.subtract(const Duration(minutes: 15)),
          ),
        if (status == AttendanceWorkdayState.completed)
          (type: AttendanceEventType.punchOut, time: out),
      ];
      if (instants.any((e) => e.time.isBefore(pin))) continue;
      final events = <AttendanceEvent>[
        for (var i = 0; i < instants.length; i++)
          AttendanceEvent(
            id: '$id-$i',
            attendanceDayId: id,
            companyId: admin.company.id,
            employeeId: person.id,
            eventType: instants[i].type,
            deviceTimestamp: instants[i].time,
            sequence: i + 1,
            requestId: '$id-$i',
            source: AttendanceEventSource.web,
            syncStatus: AttendanceSyncStatus.synced,
            locationValidation: const AttendanceLocationValidation(
              state: AttendanceLocationState.notRequired,
            ),
            createdAt: instants[i].time,
          ),
      ];
      final calculated = const AttendanceSummaryCalculator().calculate(
        events,
        now,
      );
      if (calculated is! Success<AttendanceSummary>) continue;
      final summary = calculated.value;
      await local.putDay(
        AttendanceDay(
          id: id,
          companyId: admin.company.id,
          employeeId: person.id,
          attendanceDate: today,
          snapshot: AttendanceConfigurationSnapshot(
            shift: shift,
            policy: policy,
            workLocation: location,
            timezone: admin.company.timezone,
            scheduledStart: start,
            scheduledEnd: end,
          ),
          state: status,
          punchInAt: summary.punchInTime,
          punchOutAt: summary.punchOutTime,
          elapsedMilliseconds: summary.elapsedDuration.inMilliseconds,
          breakMilliseconds: summary.breakDuration.inMilliseconds,
          workMilliseconds: summary.workDuration.inMilliseconds,
          status: late
              ? AttendanceDayStatus.late
              : status == AttendanceWorkdayState.completed
              ? AttendanceDayStatus.completed
              : AttendanceDayStatus.working,
          syncStatus: AttendanceSyncStatus.synced,
          createdAt: pin,
          updatedAt: events.last.effectiveTimestamp,
        ),
      );
      for (final event in events) {
        await local.insertEvent(event);
      }
      await db
          .into(db.workforceSeeds)
          .insert(
            WorkforceSeedsCompanion.insert(companyId: marker, version: 1),
          );
    }
  });
}
