import '../domain/shift_workday_resolver.dart';
import '../domain/attendance_history.dart';
import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../domain/attendance_models.dart';

class AttendanceLocalDataSource {
  const AttendanceLocalDataSource(this.db);
  final AppDatabase db;
  String dateKey(DateTime date) => date.toIso8601String().substring(0, 10);
  DateTime instant(int milliseconds) =>
      DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
  // The existing company/employee/workday index bounds all reads to one month.
  // SQL projects status from frozen scheduledEnd; no event/configuration N+1 reads.
  static String get _wallOffset {
    final cases = FixedOffsetCompanyTimeService.offsets.entries
        .map((e) => "WHEN '${e.key}' THEN '${e.value} minutes'")
        .join(' ');
    return "CASE json_extract(configuration_snapshot, '\$.timezone') $cases END";
  }

  static String get _historyStatus =>
      "CASE WHEN state='completed' AND punch_out_milliseconds IS NOT NULL THEN CASE WHEN status='late' THEN 'late' ELSE 'present' END WHEN attendance_date < date(?, $_wallOffset) AND julianday(json_extract(configuration_snapshot, '\$.scheduledEnd')) < julianday(?) THEN 'incomplete' ELSE 'working' END";
  Future<AttendanceHistoryPageData> history(
    String company,
    String employee,
    AttendanceHistoryQuery query,
    DateTime now,
  ) async {
    final scope =
        'company_id=? AND employee_id=? AND attendance_date>=? AND attendance_date<?';
    final scopeVariables = [
      Variable(company),
      Variable(employee),
      Variable(dateKey(query.start)),
      Variable(dateKey(query.end)),
    ];
    final projected =
        'SELECT *, $_historyStatus AS history_status FROM attendance_days WHERE $scope';
    final variables = [
      Variable(now.toUtc().toIso8601String()),
      Variable(now.toUtc().toIso8601String()),
      ...scopeVariables,
    ];
    final groups = await db
        .customSelect(
          "SELECT history_status, COUNT(*) AS n, SUM(CASE WHEN history_status IN ('present','late') THEN work_milliseconds ELSE 0 END) AS work, SUM(CASE WHEN history_status IN ('present','late') THEN break_milliseconds ELSE 0 END) AS breaks FROM ($projected) GROUP BY history_status",
          variables: variables,
          readsFrom: {db.attendanceDays},
        )
        .get();
    final counts = {
      for (final status in AttendanceHistoryStatus.values) status: 0,
    };
    var work = 0, breaks = 0;
    for (final row in groups) {
      counts[AttendanceHistoryStatus.values.byName(
        row.read<String>('history_status'),
      )] = row.read<int>(
        'n',
      );
      work += row.read<int>('work');
      breaks += row.read<int>('breaks');
    }
    final filter = query.statuses.isEmpty
        ? ''
        : ' WHERE history_status IN (${List.filled(query.statuses.length, '?').join(',')})';
    final filteredVariables = [
      ...variables,
      for (final status in query.statuses) Variable(status.name),
    ];
    final count = await db
        .customSelect(
          'SELECT COUNT(*) AS n FROM ($projected)$filter',
          variables: filteredVariables,
          readsFrom: {db.attendanceDays},
        )
        .getSingle();
    final direction = query.sort == AttendanceHistorySort.newest
        ? 'DESC'
        : 'ASC';
    final rows = await db
        .customSelect(
          "SELECT id, attendance_date, punch_in_milliseconds, punch_out_milliseconds, work_milliseconds, break_milliseconds, sync_status, history_status, json_extract(configuration_snapshot, '\$.shift.name') AS shift_name, json_extract(configuration_snapshot, '\$.timezone') AS timezone, json_extract(configuration_snapshot, '\$.workLocation.name') AS location_name FROM ($projected)$filter ORDER BY attendance_date $direction, id $direction LIMIT ? OFFSET ?",
          variables: [
            ...filteredVariables,
            Variable(query.pageSize),
            Variable(query.page * query.pageSize),
          ],
          readsFrom: {db.attendanceDays},
        )
        .get();
    return AttendanceHistoryPageData(
      query,
      rows
          .map(
            (r) => AttendanceHistoryItem(
              id: r.read<String>('id'),
              attendanceDate: DateTime.parse(
                '${r.read<String>('attendance_date')}T00:00:00Z',
              ),
              shiftName: r.read<String>('shift_name'),
              timezone: r.read<String>('timezone'),
              locationName: r.readNullable<String>('location_name'),
              status: AttendanceHistoryStatus.values.byName(
                r.read<String>('history_status'),
              ),
              syncStatus: AttendanceSyncStatus.values.byName(
                r.read<String>('sync_status'),
              ),
              punchInAt: r.readNullable<int>('punch_in_milliseconds') == null
                  ? null
                  : instant(r.read<int>('punch_in_milliseconds')),
              punchOutAt: r.readNullable<int>('punch_out_milliseconds') == null
                  ? null
                  : instant(r.read<int>('punch_out_milliseconds')),
              totalWorkDuration: Duration(
                milliseconds: r.read<int>('work_milliseconds'),
              ),
              totalBreakDuration: Duration(
                milliseconds: r.read<int>('break_milliseconds'),
              ),
            ),
          )
          .toList(),
      count.read<int>('n'),
      AttendanceMonthSummary(
        counts: Map.unmodifiable(counts),
        work: Duration(milliseconds: work),
        breaks: Duration(milliseconds: breaks),
        completed:
            counts[AttendanceHistoryStatus.present]! +
            counts[AttendanceHistoryStatus.late]!,
      ),
      now,
    );
  }

  Future<AttendanceDay?> forDate(
    String company,
    String employee,
    DateTime date,
  ) async {
    final row =
        await (db.select(db.attendanceDays)..where(
              (t) =>
                  t.companyId.equals(company) &
                  t.employeeId.equals(employee) &
                  t.attendanceDate.equals(dateKey(date)),
            ))
            .getSingleOrNull();
    return row == null ? null : readDay(row);
  }

  Future<AttendanceDay?> openDay(String company, String employee) async {
    // Literal state predicate matches the partial open-day index exactly.
    final rows = await db
        .customSelect(
          "SELECT * FROM attendance_days WHERE company_id=? AND employee_id=? AND state != 'completed' ORDER BY attendance_date DESC LIMIT 2",
          variables: [Variable(company), Variable(employee)],
          readsFrom: {db.attendanceDays},
        )
        .get();
    if (rows.length > 1) throw StateError('Multiple open attendance days');
    return rows.isEmpty
        ? null
        : readDay(db.attendanceDays.map(rows.single.data));
  }

  Future<AttendanceDay?> byId(
    String company,
    String employee,
    String id,
  ) async {
    final row =
        await (db.select(db.attendanceDays)..where(
              (t) =>
                  t.companyId.equals(company) &
                  t.employeeId.equals(employee) &
                  t.id.equals(id),
            ))
            .getSingleOrNull();
    return row == null ? null : readDay(row);
  }

  Future<List<AttendanceEvent>> events(
    String company,
    String employee,
    String day,
  ) async =>
      (await (db.select(db.attendanceEvents)
                ..where(
                  (t) =>
                      t.companyId.equals(company) &
                      t.employeeId.equals(employee) &
                      t.attendanceDayId.equals(day),
                )
                ..orderBy([
                  (t) => OrderingTerm.asc(t.effectiveMilliseconds),
                  (t) => OrderingTerm.asc(t.sequence),
                ]))
              .get())
          .map(readEvent)
          .toList();
  Stream<void> changes(String company, String employee) => db
      .customSelect(
        'SELECT id FROM attendance_days WHERE company_id=? AND employee_id=? ORDER BY attendance_date DESC LIMIT 1',
        variables: [Variable(company), Variable(employee)],
        readsFrom: {
          db.attendanceDays,
          db.attendanceEvents,
          db.workforceEmployees,
          db.workforceAccounts,
          db.shiftRecords,
          db.workLocationRecords,
          db.attendancePolicyRecords,
          db.syncOutbox,
        },
      )
      .watch()
      .map((_) {});
  AttendanceDay readDay(AttendanceDayData r) => AttendanceDay(
    id: r.id,
    companyId: r.companyId,
    employeeId: r.employeeId,
    attendanceDate: DateTime.parse('${r.attendanceDate}T00:00:00Z'),
    snapshot: AttendanceConfigurationSnapshot.fromJson(
      jsonDecode(r.configurationSnapshot) as Map<String, dynamic>,
    ),
    state: AttendanceWorkdayState.values.byName(r.state),
    punchInAt: r.punchInMilliseconds == null
        ? null
        : instant(r.punchInMilliseconds!),
    punchOutAt: r.punchOutMilliseconds == null
        ? null
        : instant(r.punchOutMilliseconds!),
    elapsedMilliseconds: r.elapsedMilliseconds,
    breakMilliseconds: r.breakMilliseconds,
    workMilliseconds: r.workMilliseconds,
    status: AttendanceDayStatus.values.byName(r.status),
    syncStatus: AttendanceSyncStatus.values.byName(r.syncStatus),
    createdAt: instant(r.createdMilliseconds),
    updatedAt: instant(r.updatedMilliseconds),
  );
  AttendanceEvent readEvent(AttendanceEventData r) => AttendanceEvent(
    id: r.id,
    attendanceDayId: r.attendanceDayId,
    companyId: r.companyId,
    employeeId: r.employeeId,
    eventType: AttendanceEventType.values.byName(r.eventType),
    deviceTimestamp: instant(r.deviceMilliseconds),
    serverTimestamp: r.serverMilliseconds == null
        ? null
        : instant(r.serverMilliseconds!),
    sequence: r.sequence,
    locationEvidence: r.latitude == null
        ? null
        : AttendanceLocationEvidence(
            latitude: r.latitude!,
            longitude: r.longitude!,
            accuracyMeters: r.accuracyMeters!,
            capturedAt: instant(r.capturedMilliseconds!),
            permissionState: AttendancePermissionState.values.byName(
              r.permissionState!,
            ),
          ),
    workLocationId: r.workLocationId,
    locationValidation: AttendanceLocationValidation.fromJson(
      jsonDecode(r.locationValidation) as Map<String, dynamic>,
    ),
    requestId: r.requestId,
    source: AttendanceEventSource.values.byName(r.source),
    syncStatus: AttendanceSyncStatus.values.byName(r.syncStatus),
    createdAt: instant(r.createdMilliseconds),
  );
  Future<void> putDay(AttendanceDay d) async {
    await db
        .into(db.attendanceDays)
        .insertOnConflictUpdate(
          AttendanceDaysCompanion.insert(
            id: d.id,
            companyId: d.companyId,
            employeeId: d.employeeId,
            attendanceDate: dateKey(d.attendanceDate),
            shiftId: d.snapshot.shift.id,
            policyId: d.snapshot.policy.id,
            workLocationId: Value(d.snapshot.workLocation?.id),
            configurationSnapshot: jsonEncode(d.snapshot.toJson()),
            state: d.state.name,
            punchInMilliseconds: Value(d.punchInAt?.millisecondsSinceEpoch),
            punchOutMilliseconds: Value(d.punchOutAt?.millisecondsSinceEpoch),
            elapsedMilliseconds: Value(d.elapsedMilliseconds),
            breakMilliseconds: Value(d.breakMilliseconds),
            workMilliseconds: Value(d.workMilliseconds),
            status: d.status.name,
            syncStatus: d.syncStatus.name,
            createdMilliseconds: d.createdAt.millisecondsSinceEpoch,
            updatedMilliseconds: d.updatedAt.millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> insertEvent(AttendanceEvent e) async {
    final l = e.locationEvidence;
    await db
        .into(db.attendanceEvents)
        .insert(
          AttendanceEventsCompanion.insert(
            id: e.id,
            attendanceDayId: e.attendanceDayId,
            companyId: e.companyId,
            employeeId: e.employeeId,
            eventType: e.eventType.name,
            deviceMilliseconds: e.deviceTimestamp.millisecondsSinceEpoch,
            serverMilliseconds: Value(
              e.serverTimestamp?.millisecondsSinceEpoch,
            ),
            effectiveMilliseconds: e.effectiveTimestamp.millisecondsSinceEpoch,
            sequence: e.sequence,
            latitude: Value(l?.latitude),
            longitude: Value(l?.longitude),
            accuracyMeters: Value(l?.accuracyMeters),
            capturedMilliseconds: Value(l?.capturedAt.millisecondsSinceEpoch),
            permissionState: Value(l?.permissionState.name),
            workLocationId: Value(e.workLocationId),
            locationValidation: jsonEncode(e.locationValidation.toJson()),
            requestId: e.requestId,
            source: e.source.name,
            syncStatus: e.syncStatus.name,
            createdMilliseconds: e.createdAt.millisecondsSinceEpoch,
          ),
        );
  }
}
