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
    this.employeeName,
    this.employeeCode,
  });

  final int? employeeId;
  final int? shiftId;
  final String? fromDate;
  final String? toDate;
  final String? timeZoneId;

  /// Display-only context carried from the loaded assignment so the edit form
  /// can show the immutable employee without re-querying.
  final String? employeeName;
  final String? employeeCode;

  EmployeeShiftDraft copyWith({
    int? employeeId,
    int? shiftId,
    String? fromDate,
    String? toDate,
    String? timeZoneId,
    String? employeeName,
    String? employeeCode,
    bool clearEmployeeId = false,
    bool clearTimeZoneId = false,
  }) => EmployeeShiftDraft(
    employeeId: clearEmployeeId ? null : employeeId ?? this.employeeId,
    shiftId: shiftId ?? this.shiftId,
    fromDate: fromDate ?? this.fromDate,
    toDate: toDate ?? this.toDate,
    timeZoneId: clearTimeZoneId ? null : timeZoneId ?? this.timeZoneId,
    employeeName: employeeName ?? this.employeeName,
    employeeCode: employeeCode ?? this.employeeCode,
  );

  EmployeeShiftDraft normalized() => EmployeeShiftDraft(
    employeeId: employeeId,
    shiftId: shiftId,
    fromDate: _clean(fromDate),
    toDate: _clean(toDate),
    timeZoneId: _clean(timeZoneId),
    employeeName: employeeName,
    employeeCode: employeeCode,
  );

  Map<String, String> validate({bool requireEmployee = true}) {
    final errors = <String, String>{};
    if (requireEmployee && employeeId == null) {
      errors['employeeId'] = 'required';
    }
    if (shiftId == null) errors['shiftId'] = 'required';
    final from = fromDate?.trim() ?? '';
    if (from.isEmpty) {
      errors['fromDate'] = 'required';
    } else if (!_isIsoDate(from)) {
      errors['fromDate'] = 'invalidDate';
    }
    final to = toDate?.trim() ?? '';
    if (to.isEmpty) {
      errors['toDate'] = 'required';
    } else if (!_isIsoDate(to)) {
      errors['toDate'] = 'invalidDate';
    }
    if (from.isNotEmpty && to.isNotEmpty && from.compareTo(to) > 0) {
      errors['toDate'] = 'invalidDateRange';
    }
    return Map.unmodifiable(errors);
  }

  factory EmployeeShiftDraft.fromShift(EmployeeShift shift) =>
      EmployeeShiftDraft(
        employeeId: shift.employeeId,
        shiftId: shift.shiftId,
        fromDate: shift.fromDate,
        toDate: shift.toDate,
        timeZoneId: shift.timeZoneId,
        employeeName: shift.employeeName,
        employeeCode: shift.employeeCode,
      );

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static bool _isIsoDate(String value) =>
      RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) &&
      DateTime.tryParse(value) != null;
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
