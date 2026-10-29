import 'package:modular_erp/core/errors/result.dart';

class EmployeeShift {
  const EmployeeShift({
    required this.id,
    required this.employeeId,
    required this.shiftId,
    required this.fromDate,
    required this.toDate,
    required this.statusId,
    required this.raw,
    this.employeeCode,
    this.employeeName,
    this.shiftName,
    this.startTime,
    this.endTime,
    this.timeZoneId,
    this.punchInOpensAt,
    this.crossesMidnight = false,
    this.earlyPunchInMinutes = 15,
    this.lateGraceMinutes = 15,
    this.status,
  });

  final int id, employeeId, shiftId, statusId;
  final String fromDate, toDate;
  final Map<String, dynamic> raw;
  final String? employeeCode,
      employeeName,
      shiftName,
      startTime,
      endTime,
      timeZoneId,
      punchInOpensAt,
      status;
  final bool crossesMidnight;
  final int earlyPunchInMinutes, lateGraceMinutes;

  bool get isActive => statusId == 1;
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
  final int page, pageSize, totalItems, totalPages;
}

class EmployeeShiftDraft {
  const EmployeeShiftDraft({
    this.employeeId,
    this.shiftId,
    this.fromDate,
    this.toDate,
    this.timeZoneId,
  });
  final int? employeeId, shiftId;
  final String? fromDate, toDate, timeZoneId;

  Map<String, String> validate() {
    final errors = <String, String>{};
    if (employeeId == null) errors['employeeId'] = 'required';
    if (shiftId == null) errors['shiftId'] = 'required';
    if (fromDate == null || fromDate!.isEmpty) errors['fromDate'] = 'required';
    if (toDate == null || toDate!.isEmpty) errors['toDate'] = 'required';
    if (fromDate != null &&
        toDate != null &&
        fromDate!.compareTo(toDate!) > 0) {
      errors['toDate'] = 'range';
    }
    return Map.unmodifiable(errors);
  }

  Map<String, dynamic> toBody({bool includeEmployee = true}) => {
    if (includeEmployee && employeeId != null) 'employeeId': employeeId,
    'shiftId': shiftId,
    'fromDate': fromDate,
    'toDate': toDate,
    if (timeZoneId != null && timeZoneId!.isNotEmpty) 'timeZoneId': timeZoneId,
  };
}

class ShiftOption {
  const ShiftOption(this.id, this.name);
  final int id;
  final String name;
}

/// Maps assignment write failures to the editor fields.
Map<String, String> mapEmployeeShiftError(Failure failure) {
  if (failure.field != null && failure.field!.isNotEmpty) {
    return {failure.field!: failure.serverMessage ?? failure.code};
  }
  final message = failure.serverMessage ?? failure.code;
  return switch (failure.code) {
    'EMPLOYEE_SHIFT_OVERLAP' || 'EMPLOYEE_SHIFT_LIMIT' => {'toDate': message},
    'EMPLOYEE_SHIFT_TIMEZONE_MISMATCH' ||
    'BRANCH_TIMEZONE_MISSING' => {'timeZoneId': message},
    _ => const {},
  };
}
