import '../../../core/utils/local_time.dart';
import '../../../core/errors/result.dart';
import '../../auth/domain/entities/auth_context.dart';
import '../../employees/domain/employee.dart';
import '../../employees/domain/employee_repository.dart';
import 'attendance_engine.dart';
import 'attendance_models.dart';
import 'attendance_state_machine.dart';
import 'shift_workday_resolver.dart';

class AttendanceContextResolver {
  const AttendanceContextResolver(this.employees, this.workdays);
  final EmployeeRepository employees;
  final ShiftWorkdayResolver workdays;
  Future<Result<AttendanceContext>> resolve(
    AuthContext auth,
    DateTime now, {
    AttendanceDay? day,
    List<AttendanceEvent> events = const [],
    AttendanceWorkMode workMode = AttendanceWorkMode.office,
    required AttendanceAuthority authority,
    required bool remoteAvailable,
  }) async {
    final ref = auth.employeeReference;
    if (ref == null ||
        ref.companyId != auth.company.id ||
        ref.userAccountId != auth.user.id) {
      return Failed(
        attendanceFailure(AttendanceFailureCode.notLinkedToEmployee),
      );
    }
    final employeeResult = await employees.getEmployeeById(auth, ref.id);
    if (employeeResult case Failed<Employee?>(:final failure)) {
      return Failed(failure);
    }
    final employee = (employeeResult as Success<Employee?>).value;
    if (employee == null ||
        employee.linkedUserId != auth.user.id ||
        employee.companyId != auth.company.id) {
      return Failed(
        attendanceFailure(AttendanceFailureCode.notLinkedToEmployee),
      );
    }
    if (employee.status != EmploymentStatus.active || !employee.loginEnabled) {
      return Failed(attendanceFailure(AttendanceFailureCode.employeeInactive));
    }
    if (day != null) {
      if (day.companyId != auth.company.id || day.employeeId != employee.id) {
        return Failed(
          attendanceFailure(AttendanceFailureCode.permissionDenied),
        );
      }
      return Success(
        AttendanceContext(
          auth: auth,
          employee: employee,
          snapshot: day.snapshot,
          workday: day.attendanceDate,
          currentTime: now,
          scheduled: day.snapshot.shift.workingDays.any(
            (d) => d.isoWeekday == day.attendanceDate.weekday,
          ),
          remoteAvailable: remoteAvailable,
          authority: authority,
          day: day,
          events: events,
        ),
      );
    }
    if (employee.shiftId == null) {
      return Failed(attendanceFailure(AttendanceFailureCode.shiftNotAssigned));
    }
    if (employee.attendancePolicyId == null) {
      return Failed(attendanceFailure(AttendanceFailureCode.policyNotAssigned));
    }
    final references = await employees.getReferences(
      auth,
      excludingId: employee.id,
    );
    if (references case Failed<EmployeeReferences>(:final failure)) {
      return Failed(failure);
    }
    final r = (references as Success<EmployeeReferences>).value;
    final shifts = r.shifts.where(
      (s) => s.id == employee.shiftId && s.companyId == auth.company.id,
    );
    final policies = r.attendancePolicies.where(
      (p) =>
          p.id == employee.attendancePolicyId && p.companyId == auth.company.id,
    );
    if (shifts.isEmpty) {
      return Failed(attendanceFailure(AttendanceFailureCode.shiftNotAssigned));
    }
    if (policies.isEmpty) {
      return Failed(attendanceFailure(AttendanceFailureCode.policyNotAssigned));
    }
    final shift = shifts.single, policy = policies.single;
    final locations = r.workLocations.where(
      (l) => l.id == employee.workLocationId && l.companyId == auth.company.id,
    );
    final location = locations.isEmpty ? null : locations.single;
    if (policy.requireLocation &&
        location == null &&
        !(workMode == AttendanceWorkMode.remote &&
            policy.allowRemoteAttendance)) {
      return Failed(
        attendanceFailure(AttendanceFailureCode.workLocationRequiredButMissing),
      );
    }
    final resolved = workdays.resolve(
      shift,
      policy,
      now,
      auth.company.timezone,
    );
    if (resolved case Failed<ShiftWorkday>(:final failure)) {
      return Failed(failure);
    }
    final workday = (resolved as Success<ShiftWorkday>).value;
    return Success(
      AttendanceContext(
        auth: auth,
        employee: employee,
        snapshot: AttendanceConfigurationSnapshot(
          shift: shift,
          policy: policy,
          workLocation: location,
          timezone: auth.company.timezone,
          scheduledStart: workday.start,
          scheduledEnd: workday.end,
          workMode: workMode,
        ),
        workday: workday.date,
        currentTime: now,
        scheduled: workday.scheduled,
        authority: authority,
        remoteAvailable: remoteAvailable,
        events: events,
      ),
    );
  }
}
