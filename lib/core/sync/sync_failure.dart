import 'package:modular_erp/core/errors/result.dart';

/// Outcome classification for a sync attempt. Transient failures may be
/// retried with backoff; permanent failures stop retrying and need attention.
enum SyncFailureClass { transient, permanent }

/// Safe, typed sync failure. Never carries raw server payloads or stack traces.
class SyncFailure {
  const SyncFailure({
    required this.code,
    required this.classification,
    this.messageSafe,
  });

  final String code;
  final SyncFailureClass classification;
  final String? messageSafe;

  bool get retryable => classification == SyncFailureClass.transient;

  static SyncFailure fromFailure(Failure failure) {
    final transient = switch (failure.kind) {
      FailureKind.offline ||
      FailureKind.timeout ||
      FailureKind.server ||
      FailureKind.sync => true,
      _ => failure.retryable,
    };
    return SyncFailure(
      code: failure.code,
      classification: transient
          ? SyncFailureClass.transient
          : SyncFailureClass.permanent,
    );
  }

  static const sessionExpired = SyncFailure(
    code: 'sessionExpired',
    classification: SyncFailureClass.transient,
  );

  static const networkUnavailable = SyncFailure(
    code: 'offline',
    classification: SyncFailureClass.transient,
  );

  static const unsupportedPayload = SyncFailure(
    code: 'unsupportedPayload',
    classification: SyncFailureClass.permanent,
  );

  static const conflict = SyncFailure(
    code: 'conflict',
    classification: SyncFailureClass.permanent,
  );

  static const rejected = SyncFailure(
    code: 'rejected',
    classification: SyncFailureClass.permanent,
  );
}
