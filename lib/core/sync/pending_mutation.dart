import 'package:freezed_annotation/freezed_annotation.dart';
part 'pending_mutation.freezed.dart';
part 'pending_mutation.g.dart';

/// Strongly typed outbox lifecycle. `bool isSynced` is intentionally avoided.
enum OutboxOperationStatus {
  pending,
  processing,
  retryScheduled,
  synced,
  failed,
  rejected,
  conflict,
  cancelled,
}

@freezed
abstract class PendingMutation with _$PendingMutation {
  const PendingMutation._();
  const factory PendingMutation({
    required String id,
    required String moduleId,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
    required DateTime createdAt,
    String? companyId,
    String? entityType,
    String? requestId,
    @Default(OutboxOperationStatus.pending) OutboxOperationStatus status,
    @Default(0) int attemptCount,
    DateTime? lastAttemptAt,
    DateTime? nextAttemptAt,
    String? failureCode,
    String? lastFailureMessageSafe,
    Map<String, dynamic>? serverResponseMetadata,
    @Default(1) int payloadVersion,
    DateTime? processingStartedAt,
    String? processorId,
  }) = _PendingMutation;
  factory PendingMutation.fromJson(Map<String, dynamic> json) =>
      _$PendingMutationFromJson(json);

  bool get isEligible => switch (status) {
    OutboxOperationStatus.pending => true,
    OutboxOperationStatus.retryScheduled => true,
    _ => false,
  };
  bool get requiresAttention => switch (status) {
    OutboxOperationStatus.failed ||
    OutboxOperationStatus.rejected ||
    OutboxOperationStatus.conflict => true,
    _ => false,
  };
}
