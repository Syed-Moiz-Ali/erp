import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';

/// Metadata thumbnail for an attachment. File bytes are never stored in the
/// domain; the tile shows the file identity and upload state instead. This is
/// the single attachment treatment shared by every Services repeatable editor
/// (enquiry issues, inspection checklist, work execution after-work photos).
class AttachmentThumbnail extends StatelessWidget {
  const AttachmentThumbnail({
    super.key,
    required this.attachment,
    this.onRemove,
  });
  final AttachmentRef attachment;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isImage = attachment.mimeType.startsWith('image/');
    return Container(
      width: 132,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isImage ? Icons.image_outlined : Icons.description_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const Spacer(),
              if (onRemove != null)
                AppIconButton(
                  icon: Icons.close,
                  tooltip: l.delete,
                  onPressed: onRemove,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            attachment.displayName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.of(context).caption,
          ),
          const SizedBox(height: AppSpacing.xxs),
          AppStatusBadge(
            label: attachmentUploadStatusLabel(attachment.uploadStatus, l),
            status: attachmentUploadStatus(attachment.uploadStatus),
          ),
        ],
      ),
    );
  }
}

/// A labelled photo/attachment strip with a "+ Add" action and thumbnails.
/// Replaces native file controls across Services forms.
class ServiceAttachmentStrip extends StatelessWidget {
  const ServiceAttachmentStrip({
    super.key,
    required this.label,
    required this.addLabel,
    required this.attachments,
    this.enabled = true,
    this.onAdd,
    this.onRemove,
  });
  final String label, addLabel;
  final List<AttachmentRef> attachments;
  final bool enabled;
  final VoidCallback? onAdd;
  final ValueChanged<String>? onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.of(
                  context,
                ).caption.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            AppTextButton(label: addLabel, onPressed: enabled ? onAdd : null),
          ],
        ),
        if (attachments.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final attachment in attachments)
                AttachmentThumbnail(
                  attachment: attachment,
                  onRemove: enabled && onRemove != null
                      ? () => onRemove!(attachment.id)
                      : null,
                ),
            ],
          ),
        ],
      ],
    );
  }
}
