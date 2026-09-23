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

  Future<Result<AttachmentRef>> addLocalAttachment(AttachmentDraft draft);

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
