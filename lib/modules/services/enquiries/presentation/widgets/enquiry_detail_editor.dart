import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';

/// Repeatable editor for an Enquiry's detail lines.
///
/// Stacked cards on every size (the mobile pattern is the safe, overflow-free
/// default; desktop keeps the same structure inside the controlled form width).
class EnquiryDetailEditor extends StatelessWidget {
  const EnquiryDetailEditor({
    super.key,
    required this.details,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
    required this.onDescriptionChanged,
    required this.onStatusChanged,
    required this.onAddPhotos,
    required this.onRemoveAttachment,
    this.descriptionErrorFor,
  });
  final List<ServiceEnquiryDraftDetail> details;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final void Function(String detailId, String value) onDescriptionChanged;
  final void Function(String detailId, ServiceEnquiryDetailStatus status)
  onStatusChanged;
  final ValueChanged<String> onAddPhotos;
  final void Function(String detailId, String attachmentId) onRemoveAttachment;
  final String? Function(String detailId)? descriptionErrorFor;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < details.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          _DetailCard(
            index: i + 1,
            detail: details[i],
            enabled: enabled,
            canRemove: details.length > 1,
            onRemove: () => onRemove(details[i].id),
            onDescriptionChanged: (v) => onDescriptionChanged(details[i].id, v),
            onStatusChanged: (s) => onStatusChanged(details[i].id, s),
            onAddPhotos: () => onAddPhotos(details[i].id),
            onRemoveAttachment: (id) => onRemoveAttachment(details[i].id, id),
            descriptionError: descriptionErrorFor?.call(details[i].id),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppSecondaryButton(
            label: l.servicesEnquiryAddDetail,
            icon: Icons.add,
            onPressed: enabled ? onAdd : null,
          ),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.index,
    required this.detail,
    required this.enabled,
    required this.canRemove,
    required this.onRemove,
    required this.onDescriptionChanged,
    required this.onStatusChanged,
    required this.onAddPhotos,
    required this.onRemoveAttachment,
    this.descriptionError,
  });
  final int index;
  final ServiceEnquiryDraftDetail detail;
  final bool enabled, canRemove;
  final VoidCallback onRemove;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<ServiceEnquiryDetailStatus> onStatusChanged;
  final VoidCallback onAddPhotos;
  final ValueChanged<String> onRemoveAttachment;
  final String? descriptionError;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.servicesEnquiryDetailLine('$index'),
                  style: AppTypography.of(context).label,
                ),
              ),
              if (canRemove)
                AppIconButton(
                  icon: Icons.delete_outline,
                  tooltip: l.servicesEnquiryRemoveDetail,
                  onPressed: enabled ? onRemove : null,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            key: ValueKey('enquiry-detail-description-${detail.id}'),
            label: l.servicesEnquiryDetailDescription,
            hint: l.servicesEnquiryDescriptionHint,
            initialValue: detail.description,
            enabled: enabled,
            maxLines: 3,
            errorText: descriptionError,
            onChanged: onDescriptionChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          AppSelectField<ServiceEnquiryDetailStatus>(
            label: l.servicesEnquiryDetailStatus,
            value: detail.status,
            enabled: enabled,
            onChanged: (value) {
              if (value != null) onStatusChanged(value);
            },
            options: [
              AppSelectOption(
                ServiceEnquiryDetailStatus.open,
                l.servicesEnquiryDetailStatusOpen,
              ),
              AppSelectOption(
                ServiceEnquiryDetailStatus.closed,
                l.servicesEnquiryDetailStatusClosed,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _AttachmentStrip(
            attachments: detail.attachments,
            enabled: enabled,
            onAddPhotos: onAddPhotos,
            onRemoveAttachment: onRemoveAttachment,
          ),
        ],
      ),
    );
  }
}

class _AttachmentStrip extends StatelessWidget {
  const _AttachmentStrip({
    required this.attachments,
    required this.enabled,
    required this.onAddPhotos,
    required this.onRemoveAttachment,
  });
  final List<AttachmentRef> attachments;
  final bool enabled;
  final VoidCallback onAddPhotos;
  final ValueChanged<String> onRemoveAttachment;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l.servicesEnquiryPhotos,
                style: AppTypography.of(
                  context,
                ).caption.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            AppTextButton(
              label: l.servicesEnquiryAddPhotos,
              onPressed: enabled ? onAddPhotos : null,
            ),
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
                  onRemove: enabled
                      ? () => onRemoveAttachment(attachment.id)
                      : null,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Metadata thumbnail for an attachment. File bytes are never stored in the
/// domain; the tile shows the file identity and upload state instead.
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
