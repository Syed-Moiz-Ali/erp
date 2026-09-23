import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';

class LocalActivityRepository implements ActivityRepository {
  LocalActivityRepository(this.database);
  final AppDatabase database;

  BusinessActivityEvent _fromRow(BusinessActivityEventRow row) =>
      BusinessActivityEvent(
        id: row.id,
        companyId: row.companyId,
        moduleKey: row.moduleKey,
        entityType: row.entityType,
        entityId: row.entityId,
        eventType: row.eventType,
        occurredAt: row.occurredAt.toUtc(),
        actorUserId: row.actorUserId,
        actorEmployeeId: row.actorEmployeeId,
        summaryKey: row.summaryKey,
        metadata:
            jsonDecode(row.metadataJson) as Map<String, Object?>? ?? const {},
        requestId: row.requestId,
        syncStatus: row.syncStatus,
      );

  @override
  Stream<List<BusinessActivityEvent>> watchForEntity({
    required String companyId,
    required String entityType,
    required String entityId,
  }) =>
      (database.select(database.businessActivityEvents)..where(
            (t) =>
                t.companyId.equals(companyId) &
                t.entityType.equals(entityType) &
                t.entityId.equals(entityId),
          ))
          .watch()
          .map(
            (rows) =>
                (rows.map(_fromRow).toList()
                  ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt))),
          );

  @override
  Future<Result<void>> append(BusinessActivityEvent event) async {
    try {
      await database
          .into(database.businessActivityEvents)
          .insert(
            BusinessActivityEventsCompanion.insert(
              id: event.id,
              companyId: event.companyId,
              moduleKey: event.moduleKey,
              entityType: event.entityType,
              entityId: event.entityId,
              eventType: event.eventType,
              occurredAt: event.occurredAt,
              actorUserId: event.actorUserId,
              actorEmployeeId: Value(event.actorEmployeeId),
              summaryKey: Value(event.summaryKey),
              metadataJson: Value(jsonEncode(event.metadata)),
              requestId: Value(event.requestId),
              syncStatus: event.syncStatus,
            ),
          );
      return const Success(null);
    } catch (_) {
      return const Failed(
        Failure(code: 'activityFailure', kind: FailureKind.storageWrite),
      );
    }
  }
}
