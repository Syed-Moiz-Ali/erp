/// Conflict kinds surfaced when local and server authenticated states differ.
/// Extensible: only the types needed today are enumerated.
enum SyncConflictType {
  duplicatePunchIn,
  remoteDayAlreadyCompleted,
  remoteEventMissing,
  remoteStateAhead,
  localStateAhead,
  timestampMismatch,
  permissionChanged,
  policyChangedServerSide,
  unknown;

  static SyncConflictType fromName(String? name) => values.firstWhere(
    (t) => t.name == name,
    orElse: () => SyncConflictType.unknown,
  );
}

enum SyncConflictStatus { open, resolved, dismissed }

/// Persisted conflict record. Snapshots must stay small and free of secrets.
class SyncConflict {
  const SyncConflict({
    required this.id,
    required this.companyId,
    required this.entityType,
    required this.entityId,
    required this.type,
    required this.createdAt,
    this.operationId,
    this.localSnapshot = const {},
    this.remoteSnapshotSafe,
    this.resolvedAt,
    this.status = SyncConflictStatus.open,
  });

  final String id;
  final String companyId;
  final String entityType;
  final String entityId;
  final String? operationId;
  final SyncConflictType type;
  final Map<String, dynamic> localSnapshot;
  final Map<String, dynamic>? remoteSnapshotSafe;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final SyncConflictStatus status;
}
