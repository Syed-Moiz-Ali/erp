import 'package:file_selector/file_selector.dart';

/// A file chosen for attachment, reduced to the metadata the shared attachment
/// foundation stores (no bytes are held in the domain or database).
class PickedAttachment {
  const PickedAttachment({
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    this.path,
  });
  final String fileName, mimeType;
  final int sizeBytes;
  final String? path;
}

/// Platform file/camera selection abstraction. Kept behind an interface so the
/// UI and tests never depend on a concrete picker implementation.
abstract interface class AttachmentPicker {
  Future<List<PickedAttachment>> pickImages();
}

/// Default picker backed by the official `file_selector` plugin (works on web,
/// desktop and mobile; no platform-specific hacks).
class FileSelectorAttachmentPicker implements AttachmentPicker {
  const FileSelectorAttachmentPicker();

  static const _extensions = ['jpg', 'jpeg', 'png', 'webp', 'heic', 'pdf'];
  static const _mimeTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/heic',
    'application/pdf',
  ];

  /// Platform file-dialog group label (not a localized in-app UI string).
  static const _typeGroupLabel = 'Images';

  @override
  Future<List<PickedAttachment>> pickImages() async {
    const group = XTypeGroup(
      label: _typeGroupLabel,
      extensions: _extensions,
      mimeTypes: _mimeTypes,
    );
    final files = await openFiles(acceptedTypeGroups: const [group]);
    final result = <PickedAttachment>[];
    for (final file in files) {
      final size = await file.length();
      result.add(
        PickedAttachment(
          fileName: file.name,
          mimeType: file.mimeType ?? _mimeFromName(file.name),
          sizeBytes: size,
          path: file.path.isEmpty ? null : file.path,
        ),
      );
    }
    return result;
  }
}

String _mimeFromName(String name) {
  final extension = name.split('.').last.toLowerCase();
  return switch (extension) {
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'webp' => 'image/webp',
    'heic' => 'image/heic',
    'pdf' => 'application/pdf',
    _ => 'application/octet-stream',
  };
}

/// App-wide picker. Tests override this with a fake; production uses the
/// `file_selector` implementation.
AttachmentPicker attachmentPicker = const FileSelectorAttachmentPicker();
