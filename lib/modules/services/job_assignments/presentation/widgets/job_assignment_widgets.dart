import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/enquiries/presentation/widgets/enquiry_detail_editor.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_reference_field.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team.dart';

/// Repeatable work-item editor. Stacked cards on every size (the mobile-safe
/// pattern; desktop keeps the same structure inside the shared content width).
class AssignmentWorkEditor extends StatelessWidget {
  const AssignmentWorkEditor({
    super.key,
    required this.lines,
    required this.enabled,
    required this.employeeNames,
    required this.teamNames,
    required this.onAdd,
    required this.onRemove,
    required this.onWorkChanged,
    required this.onDescriptionChanged,
    required this.onPickEmployee,
    required this.onClearEmployee,
    required this.onPickTeam,
    required this.onClearTeam,
    this.workErrorFor,
  });
  final List<ServiceJobAssignmentLineDraft> lines;
  final bool enabled;
  final Map<String, String> employeeNames, teamNames;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final void Function(String lineId, String value) onWorkChanged;
  final void Function(String lineId, String value) onDescriptionChanged;
  final void Function(String lineId, ServiceJobAssignmentLineDraft line)
  onPickEmployee;
  final ValueChanged<String> onClearEmployee;
  final void Function(String lineId, ServiceJobAssignmentLineDraft line)
  onPickTeam;
  final ValueChanged<String> onClearTeam;
  final String? Function(String lineId)? workErrorFor;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < lines.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          _WorkCard(
            index: i + 1,
            line: lines[i],
            enabled: enabled,
            canRemove: lines.length > 1,
            employeeName: lines[i].assignedEmployeeId == null
                ? null
                : employeeNames[lines[i].assignedEmployeeId!],
            teamName: lines[i].assignedTeamId == null
                ? null
                : teamNames[lines[i].assignedTeamId!],
            onRemove: () => onRemove(lines[i].id),
            onWorkChanged: (v) => onWorkChanged(lines[i].id, v),
            onDescriptionChanged: (v) => onDescriptionChanged(lines[i].id, v),
            onPickEmployee: () => onPickEmployee(lines[i].id, lines[i]),
            onClearEmployee: () => onClearEmployee(lines[i].id),
            onPickTeam: () => onPickTeam(lines[i].id, lines[i]),
            onClearTeam: () => onClearTeam(lines[i].id),
            workError: workErrorFor?.call(lines[i].id),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppSecondaryButton(
            label: l.servicesJobAssignmentAddLine,
            icon: Icons.add,
            onPressed: enabled ? onAdd : null,
          ),
        ),
      ],
    );
  }
}

class _WorkCard extends StatelessWidget {
  const _WorkCard({
    required this.index,
    required this.line,
    required this.enabled,
    required this.canRemove,
    required this.employeeName,
    required this.teamName,
    required this.onRemove,
    required this.onWorkChanged,
    required this.onDescriptionChanged,
    required this.onPickEmployee,
    required this.onClearEmployee,
    required this.onPickTeam,
    required this.onClearTeam,
    this.workError,
  });
  final int index;
  final ServiceJobAssignmentLineDraft line;
  final bool enabled, canRemove;
  final String? employeeName, teamName, workError;
  final VoidCallback onRemove;
  final ValueChanged<String> onWorkChanged, onDescriptionChanged;
  final VoidCallback onPickEmployee, onClearEmployee, onPickTeam, onClearTeam;

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
                  l.servicesJobAssignmentLineTitle('$index'),
                  style: AppTypography.of(context).label,
                ),
              ),
              AppStatusBadge(
                label: l.servicesJobAssignmentLineStatusPending,
                status: AppStatus.info,
              ),
              if (canRemove)
                AppIconButton(
                  icon: Icons.delete_outline,
                  tooltip: l.servicesJobAssignmentRemoveLine,
                  onPressed: enabled ? onRemove : null,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            key: ValueKey('job-work-${line.id}'),
            label: l.servicesJobAssignmentWork,
            initialValue: line.work,
            enabled: enabled,
            errorText: workError,
            onChanged: onWorkChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          AppFormGrid(
            children: [
              ServiceReferenceField<WorkforcePersonRef>(
                label: l.servicesJobAssignmentTechnician,
                valueLabel: employeeName,
                hint: l.servicesJobAssignmentTechnician,
                enabled: enabled,
                onPick: onPickEmployee,
                onClear: employeeName == null ? null : onClearEmployee,
              ),
              ServiceReferenceField<ServiceTeamRef>(
                label: l.servicesJobAssignmentServiceTeam,
                valueLabel: teamName,
                hint: l.servicesJobAssignmentServiceTeam,
                enabled: enabled,
                onPick: onPickTeam,
                onClear: teamName == null ? null : onClearTeam,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            key: ValueKey('job-desc-${line.id}'),
            label: l.servicesJobAssignmentDescriptionForWork,
            initialValue: line.descriptionForWork,
            enabled: enabled,
            maxLines: 2,
            onChanged: onDescriptionChanged,
          ),
        ],
      ),
    );
  }
}

/// Read-only source-Enquiry context (customer/location/service/material).
class AssignmentEnquiryContextCard extends StatelessWidget {
  const AssignmentEnquiryContextCard({super.key, required this.context_});
  // ignore: non_constant_identifier_names
  final ServiceAssignableEnquiryContext context_;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final snapshot = context_.partySnapshot;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFormSection(
          title: l.servicesJobAssignmentSectionCustomerLocation,
          child: AppDetailsGrid(
            fields: [
              AppDetailField(
                label: l.servicesEnquiryCustomerName,
                value: context_.customerName,
              ),
              if (snapshot.customerCode != null)
                AppDetailField(
                  label: l.servicesEnquiryCustomerCode,
                  value: snapshot.customerCode!,
                  identifier: true,
                ),
              if (context_.customerMobile != null)
                AppDetailField(
                  label: l.servicesEnquiryCustomerMobile,
                  value: context_.customerMobile!,
                  identifier: true,
                ),
              if (snapshot.siteName != null)
                AppDetailField(
                  label: l.servicesEnquirySite,
                  value: snapshot.siteName!,
                ),
              if (snapshot.tenantName != null)
                AppDetailField(
                  label: l.servicesEnquiryTenant,
                  value: snapshot.tenantName!,
                ),
              if (snapshot.buildingName != null)
                AppDetailField(
                  label: l.servicesEnquiryBuilding,
                  value: snapshot.buildingName!,
                ),
              if (snapshot.unitNumber != null)
                AppDetailField(
                  label: l.servicesEnquiryUnit,
                  value: snapshot.unitNumber!,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppFormSection(
          title: l.servicesJobAssignmentSectionServiceContext,
          child: AppDetailsGrid(
            fields: [
              AppDetailField(
                label: l.servicesEnquiryComplaintType,
                value: context_.complaintTypeName,
              ),
              AppDetailField(
                label: l.servicesEnquiryPriority,
                value: context_.priorityName,
              ),
              AppDetailField(
                label: l.servicesJobAssignmentMaterialReceived,
                value: serviceMaterialReceivedLabel(
                  context_.materialReceived,
                  l,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Read-only source-Enquiry issue lines (with photo thumbnails).
class SourceEnquiryIssues extends StatelessWidget {
  const SourceEnquiryIssues({super.key, required this.details});
  final List<ServiceEnquiryDetailLine> details;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (details.isEmpty) {
      return AppFormSection(
        title: l.servicesJobAssignmentSectionSourceIssues,
        child: Text(l.servicesJobAssignmentNoIssues),
      );
    }
    return AppFormSection(
      title: l.servicesJobAssignmentSectionSourceIssues,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < details.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.lg),
            AppCard(
              variant: AppCardVariant.subtle,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.servicesEnquiryDetailLine('${i + 1}'),
                          style: AppTypography.of(context).label,
                        ),
                      ),
                      AppStatusBadge(
                        label: serviceEnquiryDetailStatusLabel(
                          details[i].status,
                          l,
                        ),
                        status: details[i].status.isOpen
                            ? AppStatus.info
                            : AppStatus.neutral,
                        isPill: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    details[i].description,
                    style: AppTypography.of(context).body,
                  ),
                  if (details[i].attachments.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final attachment in details[i].attachments)
                          AttachmentThumbnail(attachment: attachment),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
