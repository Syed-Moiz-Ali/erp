import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_attachment_strip.dart';
import 'package:modular_erp/modules/services/services_localization.dart';

/// Repeatable editor for an Enquiry's detail lines. The owning form renders the
/// section header + "+ Add" action; this renders the item cards.
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
          AppRepeatableItemCard(
            title: l.servicesEnquiryDetailLine('${i + 1}'),
            statusLabel: serviceEnquiryDetailStatusLabel(details[i].status, l),
            status: details[i].status.isOpen
                ? AppStatus.info
                : AppStatus.neutral,
            removeTooltip: l.servicesEnquiryRemoveDetail,
            onRemove: details.length > 1 && enabled
                ? () => onRemove(details[i].id)
                : null,
            children: [
              AppTextField(
                key: ValueKey('enquiry-detail-description-${details[i].id}'),
                label: l.servicesEnquiryDetailDescription,
                hint: l.servicesEnquiryDescriptionHint,
                initialValue: details[i].description,
                enabled: enabled,
                maxLines: 3,
                minLines: 2,
                errorText: descriptionErrorFor?.call(details[i].id),
                onChanged: (v) => onDescriptionChanged(details[i].id, v),
              ),
              AppSelectField<ServiceEnquiryDetailStatus>(
                label: l.servicesEnquiryDetailStatus,
                value: details[i].status,
                enabled: enabled,
                onChanged: (value) {
                  if (value != null) onStatusChanged(details[i].id, value);
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
              ServiceAttachmentStrip(
                label: l.servicesEnquiryPhotos,
                addLabel: l.servicesEnquiryAddPhotos,
                attachments: details[i].attachments,
                enabled: enabled,
                onAdd: () => onAddPhotos(details[i].id),
                onRemove: (id) => onRemoveAttachment(details[i].id, id),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
