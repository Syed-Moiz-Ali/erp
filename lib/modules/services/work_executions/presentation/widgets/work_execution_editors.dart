import 'package:flutter/material.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_attachment_strip.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';

/// Card-based work line editor. The owning form renders the section header +
/// "+ Add" action; this renders the line cards. Start/End times are derived
/// state captured by operational actions, never typed here.
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
    if (lines.isEmpty) {
      return Text(
        l.servicesWorkExecutionNoLines,
        style: AppTypography.of(context).caption,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < lines.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          AppRepeatableItemCard(
            title: l.servicesWorkExecutionLineTitle('${i + 1}'),
            statusLabel: serviceWorkLineStateLabel(
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
            removeTooltip: l.servicesWorkExecutionRemoveLine,
            onRemove: enabled && lines[i].startedAtUtc == null
                ? () => onRemove(lines[i].id)
                : null,
            children: [
              AppTextField(
                key: ValueKey('we-work-${lines[i].id}'),
                label: l.servicesWorkExecutionWork,
                initialValue: lines[i].work,
                enabled: enabled,
                errorText: workErrorFor?.call(lines[i].id),
                onChanged: (v) => onWorkChanged(lines[i].id, v),
              ),
              AppTextField(
                key: ValueKey('we-desc-${lines[i].id}'),
                label: l.servicesWorkExecutionDescription,
                initialValue: lines[i].description,
                enabled: enabled,
                maxLines: 2,
                minLines: 2,
                onChanged: (v) => onDescriptionChanged(lines[i].id, v),
              ),
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
                    onChanged: (v) => onEmployeeChanged(lines[i].id, v ?? ''),
                    options: employeeOptions,
                  ),
                ],
              ),
              if (lines[i].startedAtUtc != null || lines[i].endedAtUtc != null)
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
          ),
        ],
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
    if (materials.isEmpty) {
      return Text(
        l.servicesWorkExecutionNoMaterials,
        style: AppTypography.of(context).caption,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < materials.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          AppRepeatableItemCard(
            title: l.servicesWorkExecutionMaterialTitle('${i + 1}'),
            removeTooltip: l.servicesWorkExecutionRemoveMaterial,
            onRemove: enabled ? () => onRemove(materials[i].id) : null,
            children: [
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
    if (entries.isEmpty) {
      return Text(
        l.servicesWorkExecutionNoPhotos,
        style: AppTypography.of(context).caption,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          AppRepeatableItemCard(
            title: l.servicesWorkExecutionPhotoTitle('${i + 1}'),
            removeTooltip: l.servicesWorkExecutionRemovePhoto,
            onRemove: enabled ? () => onRemove(entries[i].id) : null,
            children: [
              AppTextField(
                key: ValueKey('we-photo-desc-${entries[i].id}'),
                label: l.servicesWorkExecutionPhotoDescription,
                initialValue: entries[i].description,
                enabled: enabled,
                onChanged: (v) => onDescriptionChanged(entries[i].id, v),
              ),
              ServiceAttachmentStrip(
                label: l.servicesWorkExecutionPhotos,
                addLabel: l.servicesWorkExecutionAddPhotos,
                attachments: entries[i].attachments,
                enabled: enabled,
                onAdd: () => onAddPhotos(entries[i].id),
                onRemove: (id) => onRemoveAttachment(entries[i].id, id),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
