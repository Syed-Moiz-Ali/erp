import 'package:freezed_annotation/freezed_annotation.dart';

part 'shift_dtos.freezed.dart';
part 'shift_dtos.g.dart';

/// Wire DTO for a shift as returned by the MassERP API.
///
/// Transport-only. Times are `HH:mm:ss` wall-clock strings of the company time
/// zone; `shiftId` is the backend integer identity.
@freezed
abstract class ShiftDto with _$ShiftDto {
  const factory ShiftDto({
    required int shiftId,
    required String shiftName,
    required String startTime,
    required String endTime,
    @Default(0) int durationMinutes,
    @Default(false) bool crossesMidnight,
    String? punchInOpensAt,
    @Default(15) int earlyPunchInMinutes,
    @Default(15) int lateGraceMinutes,
    @Default(1) int statusId,
    @Default('Active') String status,
    @Default(0) int activeAssignments,
    DateTime? createdOn,
    DateTime? modifiedOn,
  }) = _ShiftDto;

  factory ShiftDto.fromJson(Map<String, dynamic> json) =>
      _$ShiftDtoFromJson(json);
}

/// Request body for create (`POST`) and update (`PUT`).
@freezed
abstract class ShiftUpsertDto with _$ShiftUpsertDto {
  const factory ShiftUpsertDto({
    required String shiftName,
    required String startTime,
    required String endTime,
    required int earlyPunchInMinutes,
    required int lateGraceMinutes,
  }) = _ShiftUpsertDto;

  factory ShiftUpsertDto.fromJson(Map<String, dynamic> json) =>
      _$ShiftUpsertDtoFromJson(json);
}
