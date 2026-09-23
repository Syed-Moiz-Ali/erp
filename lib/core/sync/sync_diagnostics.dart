import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/preferences/app_preferences_repository.dart';
import 'outbox_repository.dart';

/// Aggregate, non-sensitive sync diagnostics. Never exposes payloads or tokens.
class SyncDiagnostics {
  const SyncDiagnostics({
    this.counts = const OutboxCounts(),
    this.oldestPendingAt,
    this.lastSyncedAt,
    this.lastErrorCategory,
    this.operations = const [],
  });
  final OutboxCounts counts;
  final DateTime? oldestPendingAt;
  final DateTime? lastSyncedAt;
  final String? lastErrorCategory;
  final List<PendingOperationSummary> operations;
}

class PendingOperationSummary {
  const PendingOperationSummary({
    required this.operationId,
    required this.moduleId,
    required this.operation,
    required this.status,
    required this.attemptCount,
    required this.createdAt,
    this.failureCode,
  });
  final String operationId, moduleId, operation, status;
  final int attemptCount;
  final DateTime createdAt;
  final String? failureCode;
}

class SyncDiagnosticsService {
  const SyncDiagnosticsService(this.outbox, this.preferences);
  final OutboxLocalDataSource outbox;
  final AppPreferencesRepository preferences;

  Future<SyncDiagnostics> load({required String companyId}) async {
    final rows = await outbox.all(companyId: companyId);
    final counts = await outbox.counts(companyId: companyId);
    final last = await preferences.readLastSyncAt();
    DateTime? oldestPending;
    String? lastError;
    final summaries = <PendingOperationSummary>[];
    for (final row in rows) {
      if (oldestPending == null &&
          (row.status.name == 'pending' ||
              row.status.name == 'retryScheduled' ||
              row.status.name == 'processing')) {
        oldestPending = row.createdAt;
      }
      lastError ??= row.requiresAttention ? row.failureCode : null;
      summaries.add(
        PendingOperationSummary(
          operationId: row.id,
          moduleId: row.moduleId,
          operation: row.operation,
          status: row.status.name,
          attemptCount: row.attemptCount,
          createdAt: row.createdAt,
          failureCode: row.failureCode,
        ),
      );
    }
    return SyncDiagnostics(
      counts: counts,
      oldestPendingAt: oldestPending,
      lastSyncedAt: last is Success<DateTime?> ? last.value : null,
      lastErrorCategory: lastError,
      operations: summaries,
    );
  }
}
