import 'package:modular_erp/modules/hr/employee_shifts/data/dto/employee_shift_dtos.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift.dart';

/// Anti-corruption boundary between the employee-shift wire contract and the
/// app's [EmployeeShift]. Dates remain ISO strings exactly as received.
abstract final class EmployeeShiftMapper {
  const EmployeeShiftMapper._();

  static EmployeeShift toDomain(EmployeeShiftDto dto) => EmployeeShift(
    employeeShiftId: dto.employeeShiftId,
    employeeId: dto.employeeId,
    employeeCode: dto.employeeCode,
    employeeName: dto.employeeName,
    shiftId: dto.shiftId,
    shiftName: dto.shiftName,
    fromDate: dto.fromDate,
    toDate: dto.toDate,
    startTime: dto.startTime,
    endTime: dto.endTime,
    earlyPunchInMinutes: dto.earlyPunchInMinutes,
    lateGraceMinutes: dto.lateGraceMinutes,
    statusId: dto.statusId,
    status: dto.status,
    timeZoneId: dto.timeZoneId,
    punchInOpensAt: dto.punchInOpensAt,
    crossesMidnight: dto.crossesMidnight,
  );

  static EmployeeShiftCreateDto toCreate(EmployeeShiftDraft draft) =>
      EmployeeShiftCreateDto(
        employeeId: draft.employeeId!,
        shiftId: draft.shiftId!,
        fromDate: draft.fromDate!.trim(),
        toDate: draft.toDate!.trim(),
        timeZoneId: _timeZone(draft.timeZoneId),
      );

  static EmployeeShiftUpdateDto toUpdate(EmployeeShiftDraft draft) =>
      EmployeeShiftUpdateDto(
        shiftId: draft.shiftId!,
        fromDate: draft.fromDate!.trim(),
        toDate: draft.toDate!.trim(),
        timeZoneId: _timeZone(draft.timeZoneId),
      );

  static String? _timeZone(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
