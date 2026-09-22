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
      companyId: json['companyId'] as String?,
      entityType: json['entityType'] as String?,
      requestId: json['requestId'] as String?,
      status:
          $enumDecodeNullable(_$OutboxOperationStatusEnumMap, json['status']) ??
          OutboxOperationStatus.pending,
      attemptCount: (json['attemptCount'] as num?)?.toInt() ?? 0,
      lastAttemptAt: json['lastAttemptAt'] == null
          ? null
          : DateTime.parse(json['lastAttemptAt'] as String),
      nextAttemptAt: json['nextAttemptAt'] == null
          ? null
          : DateTime.parse(json['nextAttemptAt'] as String),
      failureCode: json['failureCode'] as String?,
      lastFailureMessageSafe: json['lastFailureMessageSafe'] as String?,
      serverResponseMetadata:
          json['serverResponseMetadata'] as Map<String, dynamic>?,
      payloadVersion: (json['payloadVersion'] as num?)?.toInt() ?? 1,
      processingStartedAt: json['processingStartedAt'] == null
          ? null
          : DateTime.parse(json['processingStartedAt'] as String),
      processorId: json['processorId'] as String?,
    );

Map<String, dynamic> _$PendingMutationToJson(_PendingMutation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'moduleId': instance.moduleId,
      'entityId': instance.entityId,
      'operation': instance.operation,
      'payload': instance.payload,
      'createdAt': instance.createdAt.toIso8601String(),
      'companyId': instance.companyId,
      'entityType': instance.entityType,
      'requestId': instance.requestId,
      'status': _$OutboxOperationStatusEnumMap[instance.status]!,
      'attemptCount': instance.attemptCount,
      'lastAttemptAt': instance.lastAttemptAt?.toIso8601String(),
      'nextAttemptAt': instance.nextAttemptAt?.toIso8601String(),
      'failureCode': instance.failureCode,
      'lastFailureMessageSafe': instance.lastFailureMessageSafe,
      'serverResponseMetadata': instance.serverResponseMetadata,
      'payloadVersion': instance.payloadVersion,
      'processingStartedAt': instance.processingStartedAt?.toIso8601String(),
      'processorId': instance.processorId,
    };

const _$OutboxOperationStatusEnumMap = {
  OutboxOperationStatus.pending: 'pending',
  OutboxOperationStatus.processing: 'processing',
  OutboxOperationStatus.retryScheduled: 'retryScheduled',
  OutboxOperationStatus.synced: 'synced',
  OutboxOperationStatus.failed: 'failed',
  OutboxOperationStatus.rejected: 'rejected',
  OutboxOperationStatus.conflict: 'conflict',
  OutboxOperationStatus.cancelled: 'cancelled',
};
