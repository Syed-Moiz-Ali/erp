import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/modules/services/job_assignments/presentation/bloc/service_job_assignment_blocs.dart';
import 'package:modular_erp/modules/services/job_assignments/presentation/widgets/job_assignment_widgets.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_reference_field.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team.dart';

class ServiceJobAssignmentFormPage extends StatelessWidget {
  const ServiceJobAssignmentFormPage({super.key, this.assignmentId});
  final String? assignmentId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      ServiceJobAssignmentFormCubit,
      ServiceJobAssignmentFormState
    >(
      listenWhen: (p, c) => c.saved && !p.saved,
      listener: (context, state) {
        if (state.savedId == null) return;
        AppFeedback.showMessage(
          context,
          message: (l) => assignmentId == null
              ? l.servicesJobAssignmentCreated
              : l.servicesJobAssignmentUpdated,
        );
        context.go(ServicesRoutes.assignment(state.savedId!));
      },
      builder: (context, state) {
        final l = context.l10n;
        final cubit = context.read<ServiceJobAssignmentFormCubit>();
        final d = state.draft;
        final dates = AppDateFormatter(Localizations.localeOf(context));
        String? workErrorFor(String lineId) {
          if (state.failure != 'servicesJobAssignmentWorkRequired') return null;
          final line = state.lines.where((x) => x.id == lineId).firstOrNull;
          return line != null && line.work.trim().isEmpty
              ? l.servicesJobAssignmentWorkRequired
              : null;
        }

        return AppPage(
          header: AppPageHeader(
            title: assignmentId == null
                ? l.servicesJobAssignmentFormNew
                : l.servicesJobAssignmentFormEdit,
            actions: [
              AppTextButton(
                label: l.cancel,
                onPressed: state.saving
                    ? null
                    : () => context.go(ServicesRoutes.assignments),
              ),
              AppPrimaryButton(
                label: assignmentId == null
                    ? l.servicesJobAssignmentCreate
                    : l.save,
                loading: state.saving,
                onPressed: cubit.save,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.failure != null) ...[
                AppAlert(
                  message:
                      serviceJobAssignmentFailureMessage(state.failure, l) ??
                      l.servicesJobAssignmentStorageError,
                  status: AppStatus.danger,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              AppFormSection(
                title: l.servicesJobAssignmentSectionJobContext,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppFormGrid(
                      children: [
                        AppDetailField(
                          label: l.servicesJobAssignmentNo,
                          value:
                              state.assignmentNumber ??
                              l.servicesJobAssignmentGenerated,
                          identifier: true,
                        ),
                        AppDetailField(
                          label: l.servicesJobAssignmentDate,
                          value: state.assignmentDate == null
                              ? l.servicesJobAssignmentGenerated
                              : dates.date(state.assignmentDate!),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ServiceReferenceField<ServiceAssignableEnquiryRef>(
                      label: l.servicesJobAssignmentEnquiry,
                      valueLabel: state.enquiryContext?.enquiryNumber,
                      valueSubtitle: state.enquiryContext == null
                          ? null
                          : [
                              state.enquiryContext!.customerName,
                              state.enquiryContext!.priorityName,
                            ].where((s) => s.isNotEmpty).join(' · '),
                      hint: l.servicesJobAssignmentSelectEnquiry,
                      errorText:
                          state.failure ==
                              'servicesJobAssignmentEnquiryRequired'
                          ? l.servicesJobAssignmentEnquiryRequired
                          : null,
                      enabled: !state.saving,
                      onPick: () => _pickEnquiry(context, cubit),
                      onClear: state.enquiryContext == null
                          ? null
                          : cubit.clearEnquiry,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppFormSection(
                title: l.servicesJobAssignmentSectionSchedule,
                child: AppDateField(
                  label: l.servicesJobAssignmentVisitDate,
                  value: d.scheduledVisitDate,
                  errorText:
                      state.failure == 'servicesJobAssignmentVisitDateRequired'
                      ? l.servicesJobAssignmentVisitDateRequired
                      : null,
                  onChanged: cubit.setVisitDate,
                ),
              ),
              if (state.enquiryContext != null) ...[
                const SizedBox(height: AppSpacing.xl),
                AssignmentEnquiryContextCard(context_: state.enquiryContext!),
                const SizedBox(height: AppSpacing.xl),
                SourceEnquiryIssues(details: state.enquiryContext!.details),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppFormSection(
                title: l.servicesJobAssignmentSectionWork,
                child: AssignmentWorkEditor(
                  lines: state.lines,
                  enabled: !state.saving,
                  employeeNames: state.employeeNames,
                  teamNames: state.teamNames,
                  workErrorFor: workErrorFor,
                  onAdd: cubit.addLine,
                  onRemove: cubit.removeLine,
                  onWorkChanged: cubit.updateWork,
                  onDescriptionChanged: cubit.updateDescription,
                  onPickEmployee: (lineId, _) =>
                      _pickEmployee(context, cubit, lineId),
                  onClearEmployee: cubit.clearEmployee,
                  onPickTeam: (lineId, _) => _pickTeam(context, cubit, lineId),
                  onClearTeam: cubit.clearTeam,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickEnquiry(
    BuildContext context,
    ServiceJobAssignmentFormCubit cubit,
  ) async {
    final l = context.l10n;
    final result =
        await showServiceReferencePicker<ServiceAssignableEnquiryRef>(
          context,
          title: l.servicesJobAssignmentSelectEnquiry,
          search: cubit.searchEnquiries,
          labelOf: (e) => e.enquiryNumber,
          idOf: (e) => e.id,
          subtitleOf: (e) => [
            e.customerName,
            e.priorityName,
          ].where((s) => s.isNotEmpty).join(' · '),
          selectedId: cubit.state.draft.sourceEnquiryId,
          searchHint: l.servicesJobAssignmentSearch,
          emptyText: l.servicesJobAssignmentEnquiryNotOpen,
        );
    if (cubit.isClosed) return;
    if (result is ServiceReferenceSelected<ServiceAssignableEnquiryRef>) {
      await cubit.selectEnquiry(result.value);
    }
  }

  Future<void> _pickEmployee(
    BuildContext context,
    ServiceJobAssignmentFormCubit cubit,
    String lineId,
  ) async {
    final l = context.l10n;
    final result = await showServiceReferencePicker<WorkforcePersonRef>(
      context,
      title: l.servicesJobAssignmentTechnician,
      search: cubit.searchEmployees,
      labelOf: (e) => e.name,
      idOf: (e) => e.id,
      subtitleOf: (e) => e.employeeCode,
      selectedId: cubit.state.lines
          .where((line) => line.id == lineId)
          .firstOrNull
          ?.assignedEmployeeId,
      emptyText: l.servicesJobAssignmentEmployeeInvalid,
    );
    if (cubit.isClosed) return;
    if (result is ServiceReferenceSelected<WorkforcePersonRef>) {
      cubit.selectEmployee(lineId, result.value);
    }
  }

  Future<void> _pickTeam(
    BuildContext context,
    ServiceJobAssignmentFormCubit cubit,
    String lineId,
  ) async {
    final l = context.l10n;
    final result = await showServiceReferencePicker<ServiceTeamRef>(
      context,
      title: l.servicesJobAssignmentServiceTeam,
      search: cubit.searchTeams,
      labelOf: (t) => t.displayName,
      idOf: (t) => t.id,
      subtitleOf: (t) => t.teamCode,
      selectedId: cubit.state.lines
          .where((line) => line.id == lineId)
          .firstOrNull
          ?.assignedTeamId,
      emptyText: l.servicesJobAssignmentTeamInvalid,
    );
    if (cubit.isClosed) return;
    if (result is ServiceReferenceSelected<ServiceTeamRef>) {
      cubit.selectTeam(lineId, result.value);
    }
  }
}
