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
