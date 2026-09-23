import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/shared/transactions/domain/document_number.dart';
import 'package:modular_erp/shared/transactions/domain/document_number_service.dart';

/// Drift-backed, transactionally-incremented sequence generator.
///
/// The read-increment-write runs inside one database transaction, so two rapid
/// local reservations cannot return the same number on the same connection.
class LocalDocumentNumberService implements DocumentNumberService {
  LocalDocumentNumberService(this.database, this.clock, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();
  final AppDatabase database;
  final AppClock clock;
  final Uuid _uuid;

  @override
  Future<Result<String>> nextNumber({
    required String companyId,
    required DocumentSequenceType type,
  }) async {
    try {
      final value = await database.transaction(() async {
        final existing =
            await (database.select(database.documentSequences)..where(
                  (t) =>
                      t.companyId.equals(companyId) &
                      t.sequenceKey.equals(type.key),
                ))
                .getSingleOrNull();
        final next = (existing?.nextValue ?? 0) + 1;
        if (existing == null) {
          await database
              .into(database.documentSequences)
              .insert(
                DocumentSequencesCompanion.insert(
                  id: _uuid.v4(),
                  companyId: companyId,
                  sequenceKey: type.key,
                  prefix: type.prefix,
                  nextValue: Value(next),
                  padding: Value(type.padding),
                  separator: Value(type.separator),
                  updatedAt: clock.now(),
                ),
              );
        } else {
          await (database.update(
            database.documentSequences,
          )..where((t) => t.id.equals(existing.id))).write(
            DocumentSequencesCompanion(
              nextValue: Value(next),
              updatedAt: Value(clock.now()),
            ),
          );
        }
        return next;
      });
      return Success(
        DocumentNumberFormatter.format(
          prefix: type.prefix,
          value: value,
          padding: type.padding,
          separator: type.separator,
        ),
      );
    } catch (_) {
      return const Failed(
        Failure(code: 'sequenceFailure', kind: FailureKind.storageWrite),
      );
    }
  }

  @override
  Future<Result<void>> adoptServerNumber({
    required String companyId,
    required DocumentSequenceType type,
    required String displayNumber,
  }) async {
    final match = RegExp(r'(\d+)\s*$').firstMatch(displayNumber);
    if (match == null) return const Success(null);
    final parsed = int.tryParse(match.group(1)!);
    if (parsed == null) return const Success(null);
    try {
      await database.transaction(() async {
        final existing =
            await (database.select(database.documentSequences)..where(
                  (t) =>
                      t.companyId.equals(companyId) &
                      t.sequenceKey.equals(type.key),
                ))
                .getSingleOrNull();
        final next = parsed > (existing?.nextValue ?? 0)
            ? parsed
            : existing!.nextValue;
        if (existing == null) {
          await database
              .into(database.documentSequences)
              .insert(
                DocumentSequencesCompanion.insert(
                  id: _uuid.v4(),
                  companyId: companyId,
                  sequenceKey: type.key,
                  prefix: type.prefix,
                  nextValue: Value(next),
                  padding: Value(type.padding),
                  separator: Value(type.separator),
                  updatedAt: clock.now(),
                ),
              );
        } else {
          await (database.update(
            database.documentSequences,
          )..where((t) => t.id.equals(existing.id))).write(
            DocumentSequencesCompanion(
              nextValue: Value(next),
              updatedAt: Value(clock.now()),
            ),
          );
        }
      });
      return const Success(null);
    } catch (_) {
      return const Failed(
        Failure(code: 'sequenceFailure', kind: FailureKind.storageWrite),
      );
    }
  }
}
