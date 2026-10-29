// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_envelope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiEnvelope<T> _$ApiEnvelopeFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _ApiEnvelope<T>(
  success: json['success'] as bool,
  message: json['message'] as String? ?? '',
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
  errors:
      (json['errors'] as List<dynamic>?)
          ?.map((e) => ApiError.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ApiError>[],
);

Map<String, dynamic> _$ApiEnvelopeToJson<T>(
  _ApiEnvelope<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
  'errors': instance.errors,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);
