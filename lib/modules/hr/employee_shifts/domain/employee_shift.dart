/// Employee shift assignment as returned by the MassERP API.
///
/// Dates are kept as the ISO date strings sent by the backend (`yyyy-MM-dd`);
/// times are the backend wall-clock strings. No time-zone conversion is applied
/// on the client.
class EmployeeShift {
  const EmployeeShift({
    required this.employeeShiftId,
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.shiftId,
    required this.shiftName,
    required this.fromDate,
    required this.toDate,
    required this.startTime,
    required this.endTime,
    required this.earlyPunchInMinutes,
    required this.lateGraceMinutes,
    required this.statusId,
    required this.status,
    this.timeZoneId,
    this.punchInOpensAt,
    this.crossesMidnight = false,
  });

  final int employeeShiftId;
  final int employeeId;
  final String employeeCode;
  final String employeeName;
  final int shiftId;
  final String shiftName;
  final String fromDate;
  final String toDate;
  final String startTime;
  final String endTime;
  final int earlyPunchInMinutes;
  final int lateGraceMinutes;
  final int statusId;
  final String status;
  final String? timeZoneId;
  final String? punchInOpensAt;
  final bool crossesMidnight;

  bool get isActive => statusId == 1;
}

/// Request payload for create/update. `employeeId` is only sent on create;
/// update ignores it because the backend treats the employee as immutable.
class EmployeeShiftDraft {
  const EmployeeShiftDraft({
    this.employeeId,
    this.shiftId,
    this.fromDate,
    this.toDate,
    this.timeZoneId,
  });

  final int? employeeId;
  final int? shiftId;
  final String? fromDate;
  final String? toDate;
  final String? timeZoneId;
}

class EmployeeShiftPage {
  const EmployeeShiftPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final List<EmployeeShift> items;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  bool get isEmpty => items.isEmpty;
  bool get hasMore => page < totalPages;
}
