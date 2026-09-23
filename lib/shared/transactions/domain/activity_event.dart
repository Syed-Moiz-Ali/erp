import 'package:modular_erp/core/errors/result.dart';

/// Append-only, structured business activity/audit event.
///
/// `eventType` is a stable namespaced key (for example `hr.leave.approved`,
/// `services.enquiry.created`); `metadata` carries typed-from values such as
/// `fromStatus`/`toStatus`. Presentation localizes the event; English sentences
/// are never persisted.
class BusinessActivityEvent {
  const BusinessActivityEvent({
    required this.id,
    required this.companyId,
    required this.moduleKey,
    required this.entityType,
    required this.entityId,
    required this.eventType,
    required this.occurredAt,
    required this.actorUserId,
    required this.syncStatus,
    this.actorEmployeeId,
    this.summaryKey,
    this.metadata = const {},
    this.requestId,
  });
  final String id, companyId, moduleKey, entityType, entityId, eventType;
  final DateTime occurredAt;
  final String actorUserId;
  final String? actorEmployeeId, summaryKey, requestId;
  final Map<String, Object?> metadata;
  final String syncStatus;
}

/// Stable namespaced event-key helper. Module definitions remain module-owned;
/// this only builds the shared key shape.
abstract final class ActivityEventKeys {
  static String of(String module, String entity, String action) =>
      '$module.$entity.$action';
}

/// Append-only activity repository. There is deliberately no update/delete path
/// for historical events.
abstract interface class ActivityRepository {
  Stream<List<BusinessActivityEvent>> watchForEntity({
    required String companyId,
    required String entityType,
    required String entityId,
  });

  Future<Result<void>> append(BusinessActivityEvent event);
}
