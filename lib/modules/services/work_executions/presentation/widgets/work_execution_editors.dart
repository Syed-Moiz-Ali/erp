import 'package:flutter/material.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/enquiries/presentation/widgets/enquiry_detail_editor.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';

/// Card-based work line editor.
///
/// Uses stacked cards (never a horizontal spreadsheet) so it works identically
/// on mobile and desktop inside the one global content width. Start/End times
/// are derived state captured by operational actions, never typed here.
class WorkExecutionLinesEditor extends StatelessWidget {
  const WorkExecutionLinesEditor({
    super.key,
    required this.lines,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
    required this.onWorkChanged,
    required this.onDescriptionChanged,
    required this.onTeamChanged,
    required this.onEmployeeChanged,
    required this.teamOptions,
    required this.employeeOptions,
    this.workErrorFor,
  });
  final List<ServiceWorkExecutionLineDraft> lines;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final void Function(String id, String value) onWorkChanged;
  final void Function(String id, String value) onDescriptionChanged;
  final void Function(String id, String value) onTeamChanged;
  final void Function(String id, String value) onEmployeeChanged;
  final List<AppSelectOption<String>> teamOptions;
  final List<AppSelectOption<String>> employeeOptions;
  final String? Function(String id)? workErrorFor;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final times = AppTimeFormatter(Localizations.localeOf(context));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (lines.isEmpty)
          Text(l.servicesWorkExecutionNoLines)
        else
          for (var i = 0; i < lines.length; i++) ...[
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
                          l.servicesWorkExecutionLineTitle('${i + 1}'),
                          style: AppTypography.of(context).label,
                        ),
                      ),
                      AppStatusBadge(
                        label: serviceWorkLineStateLabel(
                          serviceWorkLineState(
                            startedAtUtc: lines[i].startedAtUtc,
                            endedAtUtc: lines[i].endedAtUtc,
                          ),
                          l,
                        ),
                        status: serviceWorkLineStateStatus(
                          serviceWorkLineState(
                            startedAtUtc: lines[i].startedAtUtc,
                            endedAtUtc: lines[i].endedAtUtc,
                          ),
                        ),
                        isPill: true,
                      ),
                      AppIconButton(
                        icon: Icons.delete_outline,
                        tooltip: l.servicesWorkExecutionRemoveLine,
                        onPressed: enabled && lines[i].startedAtUtc == null
                            ? () => onRemove(lines[i].id)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    key: ValueKey('we-work-${lines[i].id}'),
                    label: l.servicesWorkExecutionWork,
                    initialValue: lines[i].work,
                    enabled: enabled,
                    errorText: workErrorFor?.call(lines[i].id),
                    onChanged: (v) => onWorkChanged(lines[i].id, v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    key: ValueKey('we-desc-${lines[i].id}'),
                    label: l.servicesWorkExecutionDescription,
                    initialValue: lines[i].description,
                    enabled: enabled,
                    maxLines: 2,
                    onChanged: (v) => onDescriptionChanged(lines[i].id, v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppFormGrid(
                    children: [
                      AppSelectField<String>(
                        label: l.servicesWorkExecutionTeam,
                        value: lines[i].serviceTeamId ?? '',
                        enabled: enabled,
                        onChanged: (v) => onTeamChanged(lines[i].id, v ?? ''),
                        options: teamOptions,
                      ),
                      AppSelectField<String>(
                        label: l.servicesWorkExecutionEmployee,
                        value: lines[i].employeeId ?? '',
                        enabled: enabled,
                        onChanged: (v) =>
                            onEmployeeChanged(lines[i].id, v ?? ''),
                        options: employeeOptions,
                      ),
                    ],
                  ),
                  if (lines[i].startedAtUtc != null ||
                      lines[i].endedAtUtc != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppDetailsGrid(
                      fields: [
                        AppDetailField(
                          label: l.servicesWorkExecutionStartTime,
                          value: lines[i].startedAtUtc == null
                              ? ''
                              : times.time(lines[i].startedAtUtc!),
                        ),
                        AppDetailField(
                          label: l.servicesWorkExecutionEndTime,
                          value: lines[i].endedAtUtc == null
                              ? ''
                              : times.time(lines[i].endedAtUtc!),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppSecondaryButton(
            label: l.servicesWorkExecutionAddLine,
            icon: Icons.add,
            onPressed: enabled ? onAdd : null,
          ),
        ),
      ],
    );
  }
}

/// Card editor for the Material Used section. Only Code + Description exist;
/// there is intentionally no quantity/UOM/batch/cost field.
class WorkExecutionMaterialsEditor extends StatelessWidget {
  const WorkExecutionMaterialsEditor({
    super.key,
    required this.materials,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
    required this.onCodeChanged,
    required this.onDescriptionChanged,
  });
  final List<ServiceWorkExecutionMaterialUsedDraft> materials;
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
          Text(l.servicesWorkExecutionNoMaterials)
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
                          l.servicesWorkExecutionMaterialTitle('${i + 1}'),
                          style: AppTypography.of(context).label,
                        ),
                      ),
                      AppIconButton(
                        icon: Icons.delete_outline,
                        tooltip: l.servicesWorkExecutionRemoveMaterial,
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
                        key: ValueKey('we-mat-code-${materials[i].id}'),
                        label: l.servicesWorkExecutionCode,
                        initialValue: materials[i].code,
                        enabled: enabled,
                        onChanged: (v) => onCodeChanged(materials[i].id, v),
                      ),
                      AppTextField(
                        key: ValueKey('we-mat-desc-${materials[i].id}'),
                        label: l.servicesWorkExecutionDescription,
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
            label: l.servicesWorkExecutionAddMaterial,
            icon: Icons.add,
            onPressed: enabled ? onAdd : null,
          ),
        ),
      ],
    );
  }
}

/// Card editor for the After Work Photos section. Multiple attachments per
/// entry are supported; images are shared attachment metadata.
class WorkExecutionPhotosEditor extends StatelessWidget {
  const WorkExecutionPhotosEditor({
    super.key,
    required this.entries,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
    required this.onDescriptionChanged,
    required this.onAddPhotos,
    required this.onRemoveAttachment,
  });
  final List<ServiceWorkExecutionPhotoEntryDraft> entries;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final void Function(String id, String value) onDescriptionChanged;
  final ValueChanged<String> onAddPhotos;
  final void Function(String id, String attachmentId) onRemoveAttachment;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (entries.isEmpty)
          Text(l.servicesWorkExecutionNoPhotos)
        else
          for (var i = 0; i < entries.length; i++) ...[
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
                          l.servicesWorkExecutionPhotoTitle('${i + 1}'),
                          style: AppTypography.of(context).label,
                        ),
                      ),
                      AppIconButton(
                        icon: Icons.delete_outline,
                        tooltip: l.servicesWorkExecutionRemovePhoto,
                        onPressed: enabled
                            ? () => onRemove(entries[i].id)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    key: ValueKey('we-photo-desc-${entries[i].id}'),
                    label: l.servicesWorkExecutionPhotoDescription,
                    initialValue: entries[i].description,
                    enabled: enabled,
                    onChanged: (v) => onDescriptionChanged(entries[i].id, v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.servicesWorkExecutionPhotos,
                          style: AppTypography.of(
                            context,
                          ).caption.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      AppTextButton(
                        label: l.servicesWorkExecutionAddPhotos,
                        onPressed: enabled
                            ? () => onAddPhotos(entries[i].id)
                            : null,
                      ),
                    ],
                  ),
                  if (entries[i].attachments.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final a in entries[i].attachments)
                          AttachmentThumbnail(
                            attachment: a,
                            onRemove: enabled
                                ? () => onRemoveAttachment(entries[i].id, a.id)
                                : null,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppSecondaryButton(
            label: l.servicesWorkExecutionAddPhoto,
            icon: Icons.add,
            onPressed: enabled ? onAdd : null,
          ),
        ),
      ],
    );
  }
}
