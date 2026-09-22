import 'attendance_models.dart';

enum AttendanceScope { self, team, company }

enum WorkforceAttendanceSort { nameAscending, nameDescending, code, status }

enum WorkforceAttendanceState {
  notStarted,
  working,
  onBreak,
  completed,
  incomplete,
  noSchedule,
  noRecord,
}

class WorkforceAttendanceFilter {
  const WorkforceAttendanceFilter({
    this.search = '',
    this.departmentId,
    this.shiftId,
    this.workLocationId,
    this.status,
    this.page = 0,
    this.pageSize = 25,
    this.sort = WorkforceAttendanceSort.nameAscending,
  });
  final String search;
  final String? departmentId, shiftId, workLocationId;
  final WorkforceAttendanceState? status;
  final int page, pageSize;
  final WorkforceAttendanceSort sort;
}

class WorkforceFilterOption {
  const WorkforceFilterOption(this.id, this.name);
  final String id, name;
}

class WorkforceFilterOptions {
  const WorkforceFilterOptions({
    required this.departments,
    required this.shifts,
    required this.locations,
  });
  final List<WorkforceFilterOption> departments, shifts, locations;
}

class WorkforceAttendanceItem {
  const WorkforceAttendanceItem({
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.attendanceState,
    this.department,
    this.designation,
    this.manager,
    this.shiftName,
    this.workLocationName,
    this.attendanceDayId,
    this.attendanceStatus,
    this.punchInAt,
    this.punchOutAt,
    this.workDuration = Duration.zero,
    this.breakDuration = Duration.zero,
    this.currentBreakStartedAt,
    this.isLate = false,
    this.hasIssue = false,
    this.hasPendingCorrection = false,
    this.syncStatus,
  });
  final String employeeId, employeeCode, employeeName;
  final String? department,
      designation,
      manager,
      shiftName,
      workLocationName,
      attendanceDayId;
  final WorkforceAttendanceState attendanceState;
  final AttendanceDayStatus? attendanceStatus;
  final DateTime? punchInAt, punchOutAt, currentBreakStartedAt;
  final Duration workDuration, breakDuration;
  final bool isLate, hasIssue, hasPendingCorrection;
  final AttendanceSyncStatus? syncStatus;
}

class WorkforceAttendancePage {
  const WorkforceAttendancePage({
    required this.items,
    required this.total,
    required this.scope,
    this.counts = const {},
    this.lateCount = 0,
  });
  final List<WorkforceAttendanceItem> items;
  final int total;
  final AttendanceScope scope;
  final Map<WorkforceAttendanceState, int> counts;
  final int lateCount;
}
