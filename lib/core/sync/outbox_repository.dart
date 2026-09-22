import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../errors/result.dart';
import 'pending_mutation.dart';

abstract interface class OutboxRepository {
  Future<Result<void>> enqueue(PendingMutation mutation);
  Stream<List<PendingMutation>> watchPending();
  Future<Result<void>> acknowledge(String id);
}

/// Aggregate counts used by the global sync status indicator.
class OutboxCounts {
  const OutboxCounts({
    this.pending = 0,
    this.processing = 0,
    this.retryScheduled = 0,
    this.failed = 0,
    this.rejected = 0,
    this.conflict = 0,
  });
  final int pending, processing, retryScheduled, failed, rejected, conflict;

  int get waiting => pending + processing + retryScheduled;
  int get needsAttention => failed + rejected + conflict;
  bool get quiet => waiting == 0 && needsAttention == 0;
  int get total => waiting + needsAttention;
}

class OutboxLocalDataSource {
  OutboxLocalDataSource(this.database);
  final AppDatabase database;

  Future<void> insert(PendingMutation mutation) => database
      .into(database.syncOutbox)
      .insert(
        SyncOutboxCompanion.insert(
          id: mutation.id,
          moduleId: mutation.moduleId,
          entityId: mutation.entityId,
          operation: mutation.operation,
          payload: jsonEncode(mutation.payload),
          createdAt: mutation.createdAt,
          entityType: Value(mutation.entityType),
          companyId: Value(mutation.companyId),
          requestId: Value(mutation.requestId),
          status: Value(mutation.status.name),
          attempts: Value(mutation.attemptCount),
          lastAttemptAt: Value(mutation.lastAttemptAt),
          nextAttemptAt: Value(mutation.nextAttemptAt),
          failureCode: Value(mutation.failureCode),
          lastFailureMessageSafe: Value(mutation.lastFailureMessageSafe),
          serverResponseMetadata: Value(
            mutation.serverResponseMetadata == null
                ? null
                : jsonEncode(mutation.serverResponseMetadata),
          ),
          payloadVersion: Value(mutation.payloadVersion),
          processingStartedAt: Value(mutation.processingStartedAt),
          processorId: Value(mutation.processorId),
        ),
        mode: InsertMode.insertOrIgnore,
      );

  static PendingMutation map(SyncOutboxData row) => PendingMutation(
    id: row.id,
    moduleId: row.moduleId,
    entityId: row.entityId,
    entityType: row.entityType,
    operation: row.operation,
    payload: jsonDecode(row.payload) as Map<String, dynamic>,
    createdAt: row.createdAt.toUtc(),
    companyId: row.companyId,
    requestId: row.requestId,
    status: OutboxOperationStatus.values.byName(row.status),
    attemptCount: row.attempts,
    lastAttemptAt: row.lastAttemptAt?.toUtc(),
    nextAttemptAt: row.nextAttemptAt?.toUtc(),
    failureCode: row.failureCode,
    lastFailureMessageSafe: row.lastFailureMessageSafe,
    serverResponseMetadata: row.serverResponseMetadata == null
        ? null
        : jsonDecode(row.serverResponseMetadata!) as Map<String, dynamic>,
    payloadVersion: row.payloadVersion,
    processingStartedAt: row.processingStartedAt?.toUtc(),
    processorId: row.processorId,
  );

  Stream<List<PendingMutation>> watch() =>
      (database.select(database.syncOutbox)
            ..where((t) => t.status.equals('pending'))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch()
          .map((rows) => rows.map(map).toList());

  /// Operations eligible to sync now for one company, in stable creation order.
  Future<List<PendingMutation>> eligible({
    required String companyId,
    required DateTime now,
  }) async {
    final rows =
        await (database.select(database.syncOutbox)
              ..where(
                (t) =>
                    t.companyId.equals(companyId) &
                    t.status.isIn(['pending', 'retryScheduled']) &
                    (t.nextAttemptAt.isNull() |
                        t.nextAttemptAt.isSmallerOrEqualValue(now)),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.createdAt),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    return rows.map(map).toList();
  }

  Future<List<PendingMutation>> all({required String companyId}) async {
    final rows =
        await (database.select(database.syncOutbox)
              ..where((t) => t.companyId.equals(companyId))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();
    return rows.map(map).toList();
  }

  Stream<OutboxCounts> watchCounts({required String companyId}) =>
      (database.select(
        database.syncOutbox,
      )..where((t) => t.companyId.equals(companyId))).watch().map(_count);

  Future<OutboxCounts> counts({required String companyId}) async {
    final rows = await (database.select(
      database.syncOutbox,
    )..where((t) => t.companyId.equals(companyId))).get();
    return _count(rows);
  }

  OutboxCounts _count(List<SyncOutboxData> rows) {
    int n(String status) => rows.where((r) => r.status == status).length;
    return OutboxCounts(
      pending: n('pending'),
      processing: n('processing'),
      retryScheduled: n('retryScheduled'),
      failed: n('failed'),
      rejected: n('rejected'),
      conflict: n('conflict'),
    );
  }

  Future<void> updateFields(String id, SyncOutboxCompanion companion) =>
      (database.update(
        database.syncOutbox,
      )..where((t) => t.id.equals(id))).write(companion);

  /// Returns operations stuck in `processing` (e.g. after a crash) to pending
  /// without changing their request id, so retries stay idempotent.
  Future<int> recoverStaleProcessing({
    required DateTime now,
    Duration staleAfter = const Duration(minutes: 5),
  }) async {
    final cutoff = now.subtract(staleAfter);
    return (database.update(database.syncOutbox)..where(
          (t) =>
              t.status.equals('processing') &
              (t.processingStartedAt.isNull() |
                  t.processingStartedAt.isSmallerOrEqualValue(cutoff)),
        ))
        .write(
          const SyncOutboxCompanion(
            status: Value('pending'),
            processingStartedAt: Value(null),
            processorId: Value(null),
          ),
        );
  }

  Future<void> delete(String id) async {
    await (database.delete(
      database.syncOutbox,
    )..where((t) => t.id.equals(id))).go();
  }

  /// Retention: purge completed/cancelled metadata older than [olderThan].
  Future<int> purgeCompleted({
    required DateTime olderThan,
    String? companyId,
  }) =>
      (database.delete(database.syncOutbox)..where(
            (t) =>
                t.status.isIn(['synced', 'cancelled']) &
                t.createdAt.isSmallerThanValue(olderThan) &
                (companyId == null
                    ? const Constant(true)
                    : t.companyId.equals(companyId)),
          ))
          .go();
}

class LocalOutboxRepository implements OutboxRepository {
  LocalOutboxRepository(this.local);
  final OutboxLocalDataSource local;
  @override
  Future<Result<void>> enqueue(PendingMutation mutation) async {
    try {
      await local.insert(mutation);
      return const Success(null);
    } catch (_) {
      return const Failed(
        Failure(code: 'storage', kind: FailureKind.storageWrite),
      );
    }
  }

  @override
  Stream<List<PendingMutation>> watchPending() => local.watch();
  @override
  Future<Result<void>> acknowledge(String id) async {
    try {
      final row = await (local.database.select(
        local.database.syncOutbox,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row?.moduleId == 'attendance' ||
          row?.moduleId == 'attendance-correction') {
        return const Failed(
          Failure(
            code: 'attendanceConfirmationRequired',
            kind: FailureKind.sync,
          ),
        );
      }
      await local.delete(id);
      return const Success(null);
    } catch (_) {
      return const Failed(
        Failure(code: 'storage', kind: FailureKind.storageUpdate),
      );
    }
  }
}
