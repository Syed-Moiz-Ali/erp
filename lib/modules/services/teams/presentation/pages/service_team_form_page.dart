import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/teams/presentation/bloc/service_team_blocs.dart';

class ServiceTeamFormPage extends StatelessWidget {
  const ServiceTeamFormPage({super.key, this.teamId});
  final String? teamId;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocConsumer<ServiceTeamFormCubit, ServiceTeamFormState>(
      listenWhen: (p, c) => c.saved && !p.saved,
      listener: (context, state) {
        AppFeedback.showMessage(context, message: (l) => l.servicesTeamSaved);
        context.go(ServicesRoutes.teams);
      },
      builder: (context, state) {
        final d = state.draft;
        final cubit = context.read<ServiceTeamFormCubit>();
        String? fieldError(String field) =>
            serviceFieldForFailure(state.failure) == field
            ? serviceFailureMessage(state.failure, l)
            : null;
        final notFound = state.failure == 'servicesTeamNotFound';
        return AppFormPage(
          title: teamId == null ? l.servicesTeamAdd : l.servicesTeamEdit,
          actions: [
            AppTextButton(
              label: l.cancel,
              onPressed: state.saving
                  ? null
                  : () => context.go(ServicesRoutes.teams),
            ),
            AppPrimaryButton(
              label: l.save,
              loading: state.saving,
              onPressed: state.saving ? null : cubit.save,
            ),
          ],
          error: state.failure == null || notFound
              ? null
              : (serviceFailureMessage(state.failure, l) ??
                    l.servicesTeamStorageError),
          loading: state.loading,
          child: notFound
              ? AppErrorState(
                  message: l.servicesTeamNotFound,
                  onRetry: () => context.go(ServicesRoutes.teams),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppFormSection(
                      title: l.servicesTeamInformationSection,
                      child: AppFormGrid(
                        children: [
                          AppTextField(
                            label: l.servicesTeamName,
                            initialValue: d.name,
                            enabled: !state.saving,
                            required: true,
                            errorText: fieldError('name'),
                            onChanged: (v) => cubit.change(d.copyWith(name: v)),
                          ),
                          if (state.selected.isNotEmpty)
                            AppSelectField<String>(
                              label: l.servicesTeamLead,
                              value: d.leadEmployeeId ?? '',
                              enabled: !state.saving,
                              onChanged: (v) => cubit.change(
                                d.copyWith(
                                  leadEmployeeId: (v == null || v.isEmpty)
                                      ? null
                                      : v,
                                  clearLead: v == null || v.isEmpty,
                                ),
                              ),
                              options: [
                                AppSelectOption('', l.servicesTeamLeadOptional),
                                for (final ref in state.selected)
                                  AppSelectOption(ref.id, ref.name),
                              ],
                            ),
                          AppTextField(
                            label: l.servicesTeamDescription,
                            initialValue: d.description,
                            enabled: !state.saving,
                            maxLines: 3,
                            minLines: 2,
                            onChanged: (v) =>
                                cubit.change(d.copyWith(description: v)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppFormSection(
                      title: l.servicesTeamMembers,
                      subtitle: l.servicesTeamMembersSubtitle,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppFormGrid(
                            spans: [AppFormSpan.half],
                            children: [
                              AppSearchField(
                                hint: l.servicesTeamMemberSearch,
                                onChanged: cubit.search,
                              ),
                            ],
                          ),
                          if (state.searching) ...[
                            const SizedBox(height: AppSpacing.sm),
                            const LinearProgressIndicator(minHeight: 2),
                          ],
                          for (final ref in state.results)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: AppAvatar(name: ref.name),
                              title: Text(ref.name),
                              subtitle: Text(
                                ref.employeeCode,
                                textDirection: TextDirection.ltr,
                              ),
                              trailing: AppTextButton(
                                label: l.servicesTeamMemberAdd,
                                onPressed: () => cubit.addMember(ref),
                              ),
                            ),
                          const Divider(),
                          if (state.selected.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              child: Text(l.servicesTeamNoMembers),
                            )
                          else
                            AppCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: [
                                  for (
                                    var i = 0;
                                    i < state.selected.length;
                                    i++
                                  ) ...[
                                    if (i > 0)
                                      const Divider(height: 1, thickness: 1),
                                    ListTile(
                                      leading: AppAvatar(
                                        name: state.selected[i].name,
                                      ),
                                      title: Text(state.selected[i].name),
                                      subtitle: Text(
                                        state.selected[i].employeeCode,
                                        textDirection: TextDirection.ltr,
                                      ),
                                      trailing: AppIconButton(
                                        icon: Icons.delete_outline,
                                        tooltip: l.servicesTeamMemberRemove,
                                        onPressed: state.saving
                                            ? null
                                            : () => cubit.removeMember(
                                                state.selected[i].id,
                                              ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
