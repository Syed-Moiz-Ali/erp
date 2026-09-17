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
        ),
        mode: InsertMode.insertOrIgnore,
      );
  Stream<List<PendingMutation>> watch() =>
      (database.select(
        database.syncOutbox,
      )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).watch().map(
        (rows) => rows
            .map(
              (r) => PendingMutation(
                id: r.id,
                moduleId: r.moduleId,
                entityId: r.entityId,
                operation: r.operation,
                payload: jsonDecode(r.payload) as Map<String, dynamic>,
                createdAt: r.createdAt.toUtc(),
              ),
            )
            .toList(),
      );
  Future<void> delete(String id) async {
    await (database.delete(
      database.syncOutbox,
    )..where((t) => t.id.equals(id))).go();
  }
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
      await local.delete(id);
      return const Success(null);
    } catch (_) {
      return const Failed(
        Failure(code: 'storage', kind: FailureKind.storageUpdate),
      );
    }
  }
}
