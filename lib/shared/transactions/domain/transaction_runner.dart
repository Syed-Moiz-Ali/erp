import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';

/// Runs a local write atomically.
///
/// Future transaction creates (record + sequence + activity event + outbox
/// entry) execute inside one Drift transaction so a partial failure cannot
/// leave a half-created record.
abstract interface class TransactionRunner {
  Future<Result<T>> run<T>(Future<T> Function() action);
}

class LocalTransactionRunner implements TransactionRunner {
  LocalTransactionRunner(this.database);
  final AppDatabase database;

  @override
  Future<Result<T>> run<T>(Future<T> Function() action) async {
    try {
      return Success(await database.transaction(action));
    } catch (_) {
      return const Failed(
        Failure(code: 'transactionFailure', kind: FailureKind.storageWrite),
      );
    }
  }
}
