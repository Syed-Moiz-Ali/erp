// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_mutation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PendingMutation _$PendingMutationFromJson(Map<String, dynamic> json) =>
    _PendingMutation(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      entityId: json['entityId'] as String,
      operation: json['operation'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PendingMutationToJson(_PendingMutation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'moduleId': instance.moduleId,
      'entityId': instance.entityId,
      'operation': instance.operation,
      'payload': instance.payload,
      'createdAt': instance.createdAt.toIso8601String(),
    };
