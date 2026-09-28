import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_attachment_strip.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_reference_field.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team.dart';

/// Repeatable work-item editor. The owning form renders the section header +
/// "+ Add" action; this renders the item cards.
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
          AppRepeatableItemCard(
            title: l.servicesJobAssignmentLineTitle('${i + 1}'),
            statusLabel: l.servicesJobAssignmentLineStatusPending,
            status: AppStatus.info,
            removeTooltip: l.servicesJobAssignmentRemoveLine,
            onRemove: lines.length > 1 && enabled
                ? () => onRemove(lines[i].id)
                : null,
            children: [
              AppTextField(
                key: ValueKey('job-work-${lines[i].id}'),
                label: l.servicesJobAssignmentWork,
                initialValue: lines[i].work,
                enabled: enabled,
                errorText: workErrorFor?.call(lines[i].id),
                onChanged: (v) => onWorkChanged(lines[i].id, v),
              ),
              AppFormGrid(
                children: [
                  ServiceReferenceField<WorkforcePersonRef>(
                    label: l.servicesJobAssignmentTechnician,
                    valueLabel: lines[i].assignedEmployeeId == null
                        ? null
                        : employeeNames[lines[i].assignedEmployeeId!],
                    hint: l.servicesJobAssignmentTechnician,
                    enabled: enabled,
                    onPick: () => onPickEmployee(lines[i].id, lines[i]),
                    onClear: lines[i].assignedEmployeeId == null
                        ? null
                        : () => onClearEmployee(lines[i].id),
                  ),
                  ServiceReferenceField<ServiceTeamRef>(
                    label: l.servicesJobAssignmentServiceTeam,
                    valueLabel: lines[i].assignedTeamId == null
                        ? null
                        : teamNames[lines[i].assignedTeamId!],
                    hint: l.servicesJobAssignmentServiceTeam,
                    enabled: enabled,
                    onPick: () => onPickTeam(lines[i].id, lines[i]),
                    onClear: lines[i].assignedTeamId == null
                        ? null
                        : () => onClearTeam(lines[i].id),
                  ),
                ],
              ),
              AppTextField(
                key: ValueKey('job-desc-${lines[i].id}'),
                label: l.servicesJobAssignmentDescriptionForWork,
                initialValue: lines[i].descriptionForWork,
                enabled: enabled,
                maxLines: 2,
                minLines: 2,
                onChanged: (v) => onDescriptionChanged(lines[i].id, v),
              ),
            ],
          ),
        ],
      ],
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
        AppReadOnlyContextSection(
          title: l.servicesJobAssignmentSectionCustomerLocation,
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
        const SizedBox(height: AppSpacing.xl),
        AppReadOnlyContextSection(
          title: l.servicesJobAssignmentSectionServiceContext,
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
              value: serviceMaterialReceivedLabel(context_.materialReceived, l),
            ),
          ],
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
            AppRepeatableItemCard(
              title: l.servicesEnquiryDetailLine('${i + 1}'),
              statusLabel: serviceEnquiryDetailStatusLabel(
                details[i].status,
                l,
              ),
              status: details[i].status.isOpen
                  ? AppStatus.info
                  : AppStatus.neutral,
              children: [
                Text(
                  details[i].description,
                  style: AppTypography.of(context).body,
                ),
                if (details[i].attachments.isNotEmpty)
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final attachment in details[i].attachments)
                        AttachmentThumbnail(attachment: attachment),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
