// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_time.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocalTime _$LocalTimeFromJson(Map<String, dynamic> json) => _LocalTime(
  hour: (json['hour'] as num).toInt(),
  minute: (json['minute'] as num).toInt(),
);

Map<String, dynamic> _$LocalTimeToJson(_LocalTime instance) =>
    <String, dynamic>{'hour': instance.hour, 'minute': instance.minute};
