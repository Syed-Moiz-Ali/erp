import 'package:freezed_annotation/freezed_annotation.dart';
part 'pending_mutation.freezed.dart';
part 'pending_mutation.g.dart';

enum OutboxOperationStatus { pending, processing, failed, rejected }

@freezed
abstract class PendingMutation with _$PendingMutation {
  const factory PendingMutation({
    required String id,
    required String moduleId,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
    required DateTime createdAt,
    String? companyId,
    String? requestId,
    @Default(OutboxOperationStatus.pending) OutboxOperationStatus status,
    @Default(0) int attemptCount,
    DateTime? lastAttemptAt,
    String? failureCode,
  }) = _PendingMutation;
  factory PendingMutation.fromJson(Map<String, dynamic> json) =>
      _$PendingMutationFromJson(json);
}
