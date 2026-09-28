import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/enquiries/presentation/widgets/enquiry_detail_editor.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (items.isEmpty)
          Text(l.servicesInspectionNoChecklist)
        else
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.servicesInspectionChecklistItemTitle('${i + 1}'),
                          style: AppTypography.of(context).label,
                        ),
                      ),
                      AppStatusBadge(
                        label: l.servicesInspectionChecklistStatusPending,
                        status: AppStatus.info,
                      ),
                      AppIconButton(
                        icon: Icons.delete_outline,
                        tooltip: l.servicesInspectionRemoveChecklist,
                        onPressed: enabled ? () => onRemove(items[i].id) : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    key: ValueKey('insp-work-${items[i].id}'),
                    label: l.servicesInspectionWorkType,
                    initialValue: items[i].workType,
                    enabled: enabled,
                    errorText: workTypeErrorFor?.call(items[i].id),
                    onChanged: (v) => onWorkTypeChanged(items[i].id, v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    key: ValueKey('insp-desc-${items[i].id}'),
                    label: l.servicesInspectionDescriptionForWork,
                    initialValue: items[i].descriptionForWork,
                    enabled: enabled,
                    maxLines: 2,
                    onChanged: (v) => onDescriptionChanged(items[i].id, v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PhotoStrip(
                    attachments: items[i].attachments,
                    enabled: enabled,
                    onAdd: () => onAddPhotos(items[i].id),
                    onRemove: (id) => onRemoveAttachment(items[i].id, id),
                  ),
                ],
              ),
            ),
          ],
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppSecondaryButton(
            label: l.servicesInspectionAddChecklist,
            icon: Icons.add,
            onPressed: enabled ? onAdd : null,
          ),
        ),
      ],
    );
  }
}

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({
    required this.attachments,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
  });
  final List<AttachmentRef> attachments;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

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
                l.servicesInspectionBeforeWorkPhotos,
                style: AppTypography.of(
                  context,
                ).caption.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            AppTextButton(
              label: l.servicesInspectionAddPhotos,
              onPressed: enabled ? onAdd : null,
            ),
          ],
        ),
        if (attachments.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final a in attachments)
                AttachmentThumbnail(
                  attachment: a,
                  onRemove: enabled ? () => onRemove(a.id) : null,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (points.isEmpty)
          Text(l.servicesInspectionNoPoints)
        else
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
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppSecondaryButton(
            label: l.servicesInspectionAddPoint,
            icon: Icons.add,
            onPressed: enabled ? onAdd : null,
          ),
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (materials.isEmpty)
          Text(l.servicesInspectionNoMaterials)
        else
          for (var i = 0; i < materials.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.servicesInspectionMaterialTitle('${i + 1}'),
                          style: AppTypography.of(context).label,
                        ),
                      ),
                      AppStatusBadge(
                        label: l.servicesInspectionMaterialStatusWaiting,
                        status: AppStatus.warning,
                      ),
                      AppIconButton(
                        icon: Icons.delete_outline,
                        tooltip: l.servicesInspectionRemoveMaterial,
                        onPressed: enabled
                            ? () => onRemove(materials[i].id)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                        onChanged: (v) =>
                            onDescriptionChanged(materials[i].id, v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppSecondaryButton(
            label: l.servicesInspectionAddMaterial,
            icon: Icons.add,
            onPressed: enabled ? onAdd : null,
          ),
        ),
      ],
    );
  }
}
