/// Wire DTO for an employee shift assignment.
///
/// Transport-only. Dates stay as the backend ISO date strings and times as the
/// backend wall-clock strings; no time-zone conversion happens here.
class EmployeeShiftDto {
  const EmployeeShiftDto({
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

  factory EmployeeShiftDto.fromJson(Map<String, dynamic> json) =>
      EmployeeShiftDto(
        employeeShiftId: _int(json['employeeShiftId']),
        employeeId: _int(json['employeeId']),
        employeeCode: json['employeeCode'] as String? ?? '',
        employeeName: json['employeeName'] as String? ?? '',
        shiftId: _int(json['shiftId']),
        shiftName: json['shiftName'] as String? ?? '',
        fromDate: json['fromDate'] as String? ?? '',
        toDate: json['toDate'] as String? ?? '',
        startTime: json['startTime'] as String? ?? '',
        endTime: json['endTime'] as String? ?? '',
        earlyPunchInMinutes: _int(json['earlyPunchInMinutes']),
        lateGraceMinutes: _int(json['lateGraceMinutes']),
        statusId: _int(json['statusId']),
        status: json['status'] as String? ?? '',
        timeZoneId: _stringOrNull(json['timeZoneId']),
        punchInOpensAt: _stringOrNull(json['punchInOpensAt']),
        crossesMidnight: json['crossesMidnight'] as bool? ?? false,
      );
}

/// Create body: `{employeeId, shiftId, fromDate, toDate, optional timeZoneId}`.
class EmployeeShiftCreateDto {
  const EmployeeShiftCreateDto({
    required this.employeeId,
    required this.shiftId,
    required this.fromDate,
    required this.toDate,
    this.timeZoneId,
  });

  final int employeeId;
  final int shiftId;
  final String fromDate;
  final String toDate;
  final String? timeZoneId;

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'shiftId': shiftId,
    'fromDate': fromDate,
    'toDate': toDate,
    if (_hasValue(timeZoneId)) 'timeZoneId': timeZoneId!.trim(),
  };
}

/// Update body: `{shiftId, fromDate, toDate, optional timeZoneId}`.
///
/// `employeeId` is intentionally absent because the backend treats it as
/// immutable.
class EmployeeShiftUpdateDto {
  const EmployeeShiftUpdateDto({
    required this.shiftId,
    required this.fromDate,
    required this.toDate,
    this.timeZoneId,
  });

  final int shiftId;
  final String fromDate;
  final String toDate;
  final String? timeZoneId;

  Map<String, dynamic> toJson() => {
    'shiftId': shiftId,
    'fromDate': fromDate,
    'toDate': toDate,
    if (_hasValue(timeZoneId)) 'timeZoneId': timeZoneId!.trim(),
  };
}

int _int(dynamic value) => (value as num?)?.toInt() ?? 0;

String? _stringOrNull(dynamic value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
