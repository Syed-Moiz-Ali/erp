import '../../shifts/domain/shift.dart';
import '../../work_locations/domain/work_location.dart';
import '../../attendance_policies/domain/attendance_policy.dart';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/models/configuration_record.dart';
import '../../../core/security/app_permission.dart';
import '../../auth/domain/entities/auth_context.dart';
import '../../shifts/data/local_shift_repository.dart';
import '../../work_locations/data/local_work_location_repository.dart';
import '../../attendance_policies/data/local_attendance_policy_repository.dart';
import '../domain/employee.dart';

/// Employee assignment discovery is separately authorized by employee workflow
/// permissions. Reading one's assigned labels never grants configuration access.
class EmployeeAttendanceCatalog {
  const EmployeeAttendanceCatalog(this.db);
  final AppDatabase db;
  Future<
    ({
      List<Shift> shifts,
      List<WorkLocation> locations,
      List<AttendancePolicy> policies,
    })
  >
  load(AuthContext context, {Employee? existing}) async {
    final editing =
        context.user.permissions.contains(AppPermission.employeeCreate) ||
        context.user.permissions.contains(AppPermission.employeeUpdate);
    Future<List<QueryRow>> rows(String table, String? current) => db
        .customSelect(
          'SELECT * FROM $table WHERE company_id=? AND (${editing ? "status='active' OR " : ""}id=?) ORDER BY normalized_name,id',
          variables: [Variable(context.company.id), Variable(current ?? '')],
        )
        .get();
    final shifts = LocalShiftRepository(db),
        locations = LocalWorkLocationRepository(db),
        policies = LocalAttendancePolicyRepository(db);
    return (
      shifts: (await rows(
        shifts.tableName,
        existing?.shiftId,
      )).map(shifts.readRow).toList(),
      locations: (await rows(
        locations.tableName,
        existing?.workLocationId,
      )).map(locations.readRow).toList(),
      policies: (await rows(
        policies.tableName,
        existing?.attendancePolicyId,
      )).map(policies.readRow).toList(),
    );
  }

  Future<bool> valid(
    AuthContext context,
    EmployeeDraft draft,
    Employee? previous,
  ) async {
    for (final reference in [
      (table: 'shift_records', value: draft.shiftId, old: previous?.shiftId),
      (
        table: 'work_location_records',
        value: draft.workLocationId,
        old: previous?.workLocationId,
      ),
      (
        table: 'attendance_policy_records',
        value: draft.attendancePolicyId,
        old: previous?.attendancePolicyId,
      ),
    ]) {
      if (reference.value == null) continue;
      final rows = await db
          .customSelect(
            'SELECT status FROM ${reference.table} WHERE company_id=? AND id=?',
            variables: [
              Variable(context.company.id),
              Variable(reference.value!),
            ],
          )
          .get();
      if (rows.isEmpty ||
          rows.single.read<String>('status') !=
                  ConfigurationStatus.active.name &&
              reference.value != reference.old) {
        return false;
      }
    }
    return true;
  }
}
