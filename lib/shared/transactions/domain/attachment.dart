import 'package:modular_erp/core/errors/result.dart';

/// Upload/lifecycle state for an attachment reference.
enum AttachmentUploadStatus {
  /// Stored locally only; upload not attempted (offline capture).
  localOnly,

  /// Queued for upload.
  pendingUpload,

  /// Remote reference available.
  uploaded,

  /// Upload attempted and failed; local copy retained for retry.
  failed,

  /// Marked for deletion; remote audit evidence may still exist.
  pendingDelete,

  /// Soft-deleted.
  deleted,
}

/// String-backed, typed attachment category. Raw values are never shown in the
/// UI; presentation maps them to localized labels.
class AttachmentCategory {
  const AttachmentCategory(this.value);
  final String value;

  static const problemPhoto = AttachmentCategory('problemPhoto');
  static const beforeWorkPhoto = AttachmentCategory('beforeWorkPhoto');
  static const afterWorkPhoto = AttachmentCategory('afterWorkPhoto');
  static const supportingDocument = AttachmentCategory('supportingDocument');
  static const inspectionEvidence = AttachmentCategory('inspectionEvidence');
  static const signature = AttachmentCategory('signature');

  @override
  bool operator ==(Object other) =>
      other is AttachmentCategory && other.value == value;
  @override
  int get hashCode => value.hashCode;
}

/// Immutable attachment **metadata** reference. No file bytes are held here.
class AttachmentRef {
  const AttachmentRef({
    required this.id,
    required this.companyId,
    required this.ownerType,
    required this.ownerId,
    required this.category,
    required this.fileName,
    required this.displayName,
    required this.mimeType,
    required this.sizeBytes,
    required this.uploadStatus,
    required this.syncStatus,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
    this.localPath,
    this.remoteUrl,
    this.storageKey,
    this.thumbnailPath,
    this.checksum,
    this.deletedAt,
  });
  final String id, companyId, ownerType, ownerId, fileName, displayName;
  final AttachmentCategory category;
  final String mimeType;
  final int sizeBytes;
  final String? localPath, remoteUrl, storageKey, thumbnailPath, checksum;
  final AttachmentUploadStatus uploadStatus;
  final String syncStatus;
  final String createdByUserId;
  final DateTime createdAt, updatedAt;
  final DateTime? deletedAt;

  bool get isUploaded => uploadStatus == AttachmentUploadStatus.uploaded;
}

/// Draft used when adding a local attachment.
class AttachmentDraft {
  const AttachmentDraft({
    required this.companyId,
    required this.ownerType,
    required this.ownerId,
    required this.category,
    required this.fileName,
    required this.displayName,
    required this.mimeType,
    required this.sizeBytes,
    required this.createdByUserId,
    this.localPath,
    this.checksum,
  });
  final String companyId, ownerType, ownerId, fileName, displayName, mimeType;
  final AttachmentCategory category;
  final int sizeBytes;
  final String createdByUserId;
  final String? localPath, checksum;
}

/// Centralized attachment validation. Server-side verification remains
/// authoritative once a backend exists.
abstract final class AttachmentValidation {
  static const allowedMimeTypes = <String>{
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/heic',
    'application/pdf',
  };
  static const maxFileSizeBytes = 15 * 1024 * 1024;
  static const maxPerOwner = 20;

  /// Returns a failure code when invalid, or null when acceptable.
  static String? validate({
    required String mimeType,
    required int sizeBytes,
    required int existingCount,
  }) {
    if (!allowedMimeTypes.contains(mimeType)) {
      return 'attachmentUnsupportedType';
    }
    if (sizeBytes <= 0) return 'attachmentEmptyFile';
    if (sizeBytes > maxFileSizeBytes) return 'attachmentTooLarge';
    if (existingCount >= maxPerOwner) return 'attachmentLimitReached';
    return null;
  }

  static Result<void> check({
    required String mimeType,
    required int sizeBytes,
    required int existingCount,
  }) {
    final code = validate(
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      existingCount: existingCount,
    );
    return code == null
        ? const Success(null)
        : Failed(Failure(code: code, kind: FailureKind.invalidData));
  }
}
