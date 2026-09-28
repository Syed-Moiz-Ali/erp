import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_attachment_strip.dart';

class InspectionChecklistEditor extends StatelessWidget {
  const InspectionChecklistEditor({
    super.key,
    required this.items,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
    required this.onWorkTypeChanged,
    required this.onDescriptionChanged,
    required this.onAddPhotos,
    required this.onRemoveAttachment,
    this.workTypeErrorFor,
  });
  final List<ServiceInspectionChecklistItemDraft> items;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final void Function(String id, String value) onWorkTypeChanged;
  final void Function(String id, String value) onDescriptionChanged;
  final ValueChanged<String> onAddPhotos;
  final void Function(String id, String attachmentId) onRemoveAttachment;
  final String? Function(String id)? workTypeErrorFor;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (items.isEmpty) {
      return Text(
        l.servicesInspectionNoChecklist,
        style: AppTypography.of(context).caption,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          AppRepeatableItemCard(
            title: l.servicesInspectionChecklistItemTitle('${i + 1}'),
            statusLabel: l.servicesInspectionChecklistStatusPending,
            status: AppStatus.info,
            removeTooltip: l.servicesInspectionRemoveChecklist,
            onRemove: enabled ? () => onRemove(items[i].id) : null,
            children: [
              AppTextField(
                key: ValueKey('insp-work-${items[i].id}'),
                label: l.servicesInspectionWorkType,
                initialValue: items[i].workType,
                enabled: enabled,
                errorText: workTypeErrorFor?.call(items[i].id),
                onChanged: (v) => onWorkTypeChanged(items[i].id, v),
              ),
              AppTextField(
                key: ValueKey('insp-desc-${items[i].id}'),
                label: l.servicesInspectionDescriptionForWork,
                initialValue: items[i].descriptionForWork,
                enabled: enabled,
                maxLines: 2,
                minLines: 2,
                onChanged: (v) => onDescriptionChanged(items[i].id, v),
              ),
              ServiceAttachmentStrip(
                label: l.servicesInspectionBeforeWorkPhotos,
                addLabel: l.servicesInspectionAddPhotos,
                attachments: items[i].attachments,
                enabled: enabled,
                onAdd: () => onAddPhotos(items[i].id),
                onRemove: (id) => onRemoveAttachment(items[i].id, id),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class InspectionPointsEditor extends StatelessWidget {
  const InspectionPointsEditor({
    super.key,
    required this.points,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
    required this.onChanged,
  });
  final List<ServiceInspectionPointDraft> points;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final void Function(String id, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (points.isEmpty) {
      return Text(
        l.servicesInspectionNoPoints,
        style: AppTypography.of(context).caption,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < points.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  key: ValueKey('insp-point-${points[i].id}'),
                  label: l.servicesInspectionPointTitle('${i + 1}'),
                  initialValue: points[i].description,
                  enabled: enabled,
                  maxLines: 2,
                  minLines: 2,
                  onChanged: (v) => onChanged(points[i].id, v),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppIconButton(
                icon: Icons.delete_outline,
                tooltip: l.servicesInspectionRemovePoint,
                onPressed: enabled ? () => onRemove(points[i].id) : null,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class InspectionMaterialsEditor extends StatelessWidget {
  const InspectionMaterialsEditor({
    super.key,
    required this.materials,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
    required this.onCodeChanged,
    required this.onDescriptionChanged,
  });
  final List<ServiceInspectionMaterialRequirementDraft> materials;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final void Function(String id, String value) onCodeChanged;
  final void Function(String id, String value) onDescriptionChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (materials.isEmpty) {
      return Text(
        l.servicesInspectionNoMaterials,
        style: AppTypography.of(context).caption,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < materials.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          AppRepeatableItemCard(
            title: l.servicesInspectionMaterialTitle('${i + 1}'),
            statusLabel: l.servicesInspectionMaterialStatusWaiting,
            status: AppStatus.warning,
            removeTooltip: l.servicesInspectionRemoveMaterial,
            onRemove: enabled ? () => onRemove(materials[i].id) : null,
            children: [
              AppFormGrid(
                children: [
                  AppTextField(
                    key: ValueKey('insp-mat-code-${materials[i].id}'),
                    label: l.servicesInspectionMaterialCode,
                    initialValue: materials[i].code,
                    enabled: enabled,
                    onChanged: (v) => onCodeChanged(materials[i].id, v),
                  ),
                  AppTextField(
                    key: ValueKey('insp-mat-desc-${materials[i].id}'),
                    label: l.servicesInspectionMaterialDescription,
                    initialValue: materials[i].description,
                    enabled: enabled,
                    onChanged: (v) => onDescriptionChanged(materials[i].id, v),
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }
}
