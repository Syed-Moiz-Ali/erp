// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthSessionDto _$AuthSessionDtoFromJson(Map<String, dynamic> json) =>
    AuthSessionDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      user: json['user'] as Map<String, dynamic>,
      company: json['company'] as Map<String, dynamic>,
      employee: json['employee'] as Map<String, dynamic>?,
      settings:
          (json['settings'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      version: (json['version'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$AuthSessionDtoToJson(AuthSessionDto instance) =>
    <String, dynamic>{
      'version': instance.version,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'user': instance.user,
      'company': instance.company,
      'employee': instance.employee,
      'settings': instance.settings,
    };
