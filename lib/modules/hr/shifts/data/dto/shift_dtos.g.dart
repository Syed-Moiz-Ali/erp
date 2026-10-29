// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShiftDto _$ShiftDtoFromJson(Map<String, dynamic> json) => _ShiftDto(
  shiftId: (json['shiftId'] as num).toInt(),
  shiftName: json['shiftName'] as String,
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
  durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
  crossesMidnight: json['crossesMidnight'] as bool? ?? false,
  punchInOpensAt: json['punchInOpensAt'] as String?,
  earlyPunchInMinutes: (json['earlyPunchInMinutes'] as num?)?.toInt() ?? 15,
  lateGraceMinutes: (json['lateGraceMinutes'] as num?)?.toInt() ?? 15,
  statusId: (json['statusId'] as num?)?.toInt() ?? 1,
  status: json['status'] as String? ?? 'Active',
  activeAssignments: (json['activeAssignments'] as num?)?.toInt() ?? 0,
  createdOn: json['createdOn'] == null
      ? null
      : DateTime.parse(json['createdOn'] as String),
  modifiedOn: json['modifiedOn'] == null
      ? null
      : DateTime.parse(json['modifiedOn'] as String),
);

Map<String, dynamic> _$ShiftDtoToJson(_ShiftDto instance) => <String, dynamic>{
  'shiftId': instance.shiftId,
  'shiftName': instance.shiftName,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'durationMinutes': instance.durationMinutes,
  'crossesMidnight': instance.crossesMidnight,
  'punchInOpensAt': instance.punchInOpensAt,
  'earlyPunchInMinutes': instance.earlyPunchInMinutes,
  'lateGraceMinutes': instance.lateGraceMinutes,
  'statusId': instance.statusId,
  'status': instance.status,
  'activeAssignments': instance.activeAssignments,
  'createdOn': instance.createdOn?.toIso8601String(),
  'modifiedOn': instance.modifiedOn?.toIso8601String(),
};

_ShiftUpsertDto _$ShiftUpsertDtoFromJson(Map<String, dynamic> json) =>
    _ShiftUpsertDto(
      shiftName: json['shiftName'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      earlyPunchInMinutes: (json['earlyPunchInMinutes'] as num).toInt(),
      lateGraceMinutes: (json['lateGraceMinutes'] as num).toInt(),
    );

Map<String, dynamic> _$ShiftUpsertDtoToJson(_ShiftUpsertDto instance) =>
    <String, dynamic>{
      'shiftName': instance.shiftName,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'earlyPunchInMinutes': instance.earlyPunchInMinutes,
      'lateGraceMinutes': instance.lateGraceMinutes,
    };
