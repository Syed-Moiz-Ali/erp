import 'package:modular_erp/core/errors/result.dart';
import 'pending_mutation.dart';
import 'sync_conflict.dart';
import 'sync_failure.dart';

enum SyncTransportOutcome { accepted, rejected, conflict }

/// Result of handing one operation to a transport. Successful results never
/// fabricate a server confirmation: `accepted` must come from the transport.
class SyncTransportResult {
  const SyncTransportResult.accepted({this.serverTimestamp, this.metadataSafe})
    : outcome = SyncTransportOutcome.accepted,
      failure = null,
      conflictType = null;

  const SyncTransportResult.rejected(this.failure, {this.metadataSafe})
    : outcome = SyncTransportOutcome.rejected,
      serverTimestamp = null,
      conflictType = null;

  const SyncTransportResult.conflict(this.conflictType, {this.metadataSafe})
    : outcome = SyncTransportOutcome.conflict,
      serverTimestamp = null,
      failure = null;

  final SyncTransportOutcome outcome;
  final DateTime? serverTimestamp;
  final SyncFailure? failure;
  final SyncConflictType? conflictType;
  final Map<String, dynamic>? metadataSafe;
}

/// Boundary between the local-first app and a future backend. Today the demo
/// transport is local-authoritative; a future `ApiSyncTransport` can implement
/// the same interface without changing attendance or sync code.
abstract interface class SyncTransport {
  Future<bool> get isAvailable;
  Future<Result<SyncTransportResult>> send(PendingMutation operation);
}

/// Local authoritative transport used in demo mode and tests. It confirms the
/// operation using the local device timestamp; it never invents remote state.
class LocalAuthoritativeSyncTransport implements SyncTransport {
  const LocalAuthoritativeSyncTransport({this.available = true});
  final bool available;

  @override
  Future<bool> get isAvailable async => available;

  @override
  Future<Result<SyncTransportResult>> send(PendingMutation operation) async {
    if (!available) {
      return const Failed(
        Failure(code: 'offline', kind: FailureKind.offline, retryable: true),
      );
    }
    return Success(
      SyncTransportResult.accepted(
        serverTimestamp: operation.createdAt.toUtc(),
      ),
    );
  }
}
