import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/shared/transactions/data/transactions_tables.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';
import 'package:modular_erp/shared/transactions/domain/attachment_repository.dart';

class LocalAttachmentRepository implements AttachmentRepository {
  LocalAttachmentRepository(this.database, this.clock, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();
  final AppDatabase database;
  final AppClock clock;
  final Uuid _uuid;

  static const _syncPending = 'pending';

  AttachmentRef _map(AttachmentRecord row) => AttachmentRef(
    id: row.id,
    companyId: row.companyId,
    ownerType: row.ownerType,
    ownerId: row.ownerId,
    category: AttachmentCategory(row.category),
    fileName: row.fileName,
    displayName: row.displayName,
    mimeType: row.mimeType,
    sizeBytes: row.sizeBytes,
    localPath: row.localPath,
    remoteUrl: row.remoteUrl,
    storageKey: row.storageKey,
    thumbnailPath: row.thumbnailPath,
    checksum: row.checksum,
    uploadStatus: AttachmentUploadStatus.values.byName(row.uploadStatus),
    syncStatus: row.syncStatus,
    createdByUserId: row.createdByUserId,
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
    deletedAt: row.deletedAt?.toUtc(),
  );

  SimpleSelectStatement<AttachmentRecords, AttachmentRecord> _ownerQuery({
    required String companyId,
    required String ownerType,
    required String ownerId,
  }) => database.select(database.attachmentRecords)
    ..where(
      (t) =>
          t.companyId.equals(companyId) &
          t.ownerType.equals(ownerType) &
          t.ownerId.equals(ownerId) &
          t.uploadStatus.isNotValue('deleted'),
    );

  @override
  Stream<List<AttachmentRef>> watchForOwner({
    required String companyId,
    required String ownerType,
    required String ownerId,
  }) =>
      (_ownerQuery(companyId: companyId, ownerType: ownerType, ownerId: ownerId)
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch()
          .map((rows) => rows.map(_map).toList());

  @override
  Future<Result<List<AttachmentRef>>> getForOwner({
    required String companyId,
    required String ownerType,
    required String ownerId,
  }) async {
    try {
      final rows = await _ownerQuery(
        companyId: companyId,
        ownerType: ownerType,
        ownerId: ownerId,
      ).get();
      return Success(rows.map(_map).toList());
    } catch (_) {
      return const Failed(
        Failure(code: 'attachmentFailure', kind: FailureKind.storageWrite),
      );
    }
  }

  @override
  Future<Result<AttachmentRef>> addLocalAttachment(
    AttachmentDraft draft,
  ) async {
    try {
      final existing = await _ownerQuery(
        companyId: draft.companyId,
        ownerType: draft.ownerType,
        ownerId: draft.ownerId,
      ).get();
      final validation = AttachmentValidation.check(
        mimeType: draft.mimeType,
        sizeBytes: draft.sizeBytes,
        existingCount: existing.length,
      );
      if (validation case Failed<void>(:final failure)) {
        return Failed(failure);
      }
      final now = clock.now();
      final row = AttachmentRecordsCompanion.insert(
        id: _uuid.v4(),
        companyId: draft.companyId,
        ownerType: draft.ownerType,
        ownerId: draft.ownerId,
        category: draft.category.value,
        fileName: draft.fileName,
        displayName: draft.displayName,
        mimeType: draft.mimeType,
        sizeBytes: draft.sizeBytes,
        localPath: Value(draft.localPath),
        checksum: Value(draft.checksum),
        uploadStatus: AttachmentUploadStatus.localOnly.name,
        syncStatus: _syncPending,
        createdByUserId: draft.createdByUserId,
        createdAt: now,
        updatedAt: now,
      );
      await database.into(database.attachmentRecords).insert(row);
      return Success(
        _map(
          (await _ownerQuery(
            companyId: draft.companyId,
            ownerType: draft.ownerType,
            ownerId: draft.ownerId,
          ).get()).firstWhere((r) => r.id == row.id.value),
        ),
      );
    } catch (_) {
      return const Failed(
        Failure(code: 'attachmentFailure', kind: FailureKind.storageWrite),
      );
    }
  }

  Future<Result<void>> _updateStatus({
    required String companyId,
    required String attachmentId,
    required AttachmentUploadStatus status,
    String? remoteUrl,
    String? storageKey,
    String? failureCode,
  }) async {
    try {
      final now = clock.now();
      final updated =
          await (database.update(database.attachmentRecords)..where(
                (t) =>
                    t.id.equals(attachmentId) & t.companyId.equals(companyId),
              ))
              .write(
                AttachmentRecordsCompanion(
                  uploadStatus: Value(status.name),
                  remoteUrl: Value(remoteUrl),
                  storageKey: Value(storageKey),
                  syncStatus: Value(_syncPending),
                  updatedAt: Value(now),
                  deletedAt: Value(
                    status == AttachmentUploadStatus.deleted ? now : null,
                  ),
                ),
              );
      if (updated == 0) {
        return const Failed(
          Failure(code: 'attachmentNotFound', kind: FailureKind.invalidData),
        );
      }
      return const Success(null);
    } catch (_) {
      return const Failed(
        Failure(code: 'attachmentFailure', kind: FailureKind.storageWrite),
      );
    }
  }

  @override
  Future<Result<void>> removeAttachment({
    required String companyId,
    required String attachmentId,
  }) => _updateStatus(
    companyId: companyId,
    attachmentId: attachmentId,
    status: AttachmentUploadStatus.deleted,
  );

  @override
  Future<Result<void>> markUploaded({
    required String companyId,
    required String attachmentId,
    required String remoteUrl,
    String? storageKey,
  }) => _updateStatus(
    companyId: companyId,
    attachmentId: attachmentId,
    status: AttachmentUploadStatus.uploaded,
    remoteUrl: remoteUrl,
    storageKey: storageKey,
  );

  @override
  Future<Result<void>> markFailed({
    required String companyId,
    required String attachmentId,
    required String failureCode,
  }) => _updateStatus(
    companyId: companyId,
    attachmentId: attachmentId,
    status: AttachmentUploadStatus.failed,
    failureCode: failureCode,
  );
}
