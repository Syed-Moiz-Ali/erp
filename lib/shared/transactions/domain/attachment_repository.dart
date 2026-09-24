import 'package:modular_erp/core/errors/result.dart';
import 'attachment.dart';

/// Generic, company-scoped attachment metadata repository.
///
/// Owner references use `ownerType`/`ownerId` (repository-level integrity)
/// rather than SQL foreign keys, because owners span future module tables.
abstract interface class AttachmentRepository {
  Stream<List<AttachmentRef>> watchForOwner({
    required String companyId,
    required String ownerType,
    required String ownerId,
  });

  Future<Result<List<AttachmentRef>>> getForOwner({
    required String companyId,
    required String ownerType,
    required String ownerId,
  });

  /// Batch lookup for owners of the same type (avoids N+1 when loading an
  /// aggregate whose child rows each own attachments).
  Future<Result<List<AttachmentRef>>> getForOwners({
    required String companyId,
    required String ownerType,
    required List<String> ownerIds,
  });

  /// [id] lets a caller reserve the attachment identity up-front so a
  /// client-generated draft can be reconciled by id at save time.
  Future<Result<AttachmentRef>> addLocalAttachment(
    AttachmentDraft draft, {
    String? id,
  });

  Future<Result<void>> removeAttachment({
    required String companyId,
    required String attachmentId,
  });

  Future<Result<void>> markUploaded({
    required String companyId,
    required String attachmentId,
    required String remoteUrl,
    String? storageKey,
  });

  Future<Result<void>> markFailed({
    required String companyId,
    required String attachmentId,
    required String failureCode,
  });
}
