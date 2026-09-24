import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/teams/presentation/bloc/service_team_blocs.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class ServiceTeamDetailPage extends StatelessWidget {
  const ServiceTeamDetailPage({super.key, required this.teamId});
  final String teamId;

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    final canManage =
        permissions?.contains(AppPermission.serviceTeamManage) ?? false;
    return BlocBuilder<ServiceTeamDetailCubit, ServiceTeamDetailState>(
      builder: (context, state) {
        final l = context.l10n;
        final team = state.team;
        if (state.loading && team == null) {
          return const AppPage(child: AppConfigurationSkeleton());
        }
        if (team == null) {
          return AppPage(
            header: AppPageHeader(title: l.servicesTeamsTitle),
            child: AppEmptyState(
              title: l.servicesTeamNotFound,
              message: l.servicesTeamEmptyMessage,
            ),
          );
        }
        final numbers = AppNumberFormatter(Localizations.localeOf(context));
        Future<void> toggle() async {
          final active = team.status != ConfigurationStatus.active;
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: (l) =>
                active ? l.servicesTeamActivate : l.servicesTeamDeactivate,
            message: (l) => team.name,
            confirmLabel: (l) => active ? l.confirm : l.servicesTeamDeactivate,
          );
          if (!confirmed || !context.mounted) return;
          final result = await context.read<ServiceTeamDetailCubit>().setActive(
            active,
          );
          if (context.mounted) {
            AppFeedback.showMessage(
              context,
              message: (l) => result is Success
                  ? l.servicesTeamSaved
                  : l.servicesTeamStorageError,
            );
          }
        }

        final lead = state.members
            .where((m) => m.employeeId == team.leadEmployeeId)
            .firstOrNull;

        return AppPage(
          maxWidth: AppDimensions.wideContent,
          header: AppPageHeader(
            title: team.name,
            subtitle: team.teamCode,
            actions: [
              if (canManage)
                AppSecondaryButton(
                  label: l.edit,
                  icon: Icons.edit_outlined,
                  onPressed: () => context.go(ServicesRoutes.teamEdit(team.id)),
                ),
              if (canManage)
                AppSecondaryButton(
                  label: team.status == ConfigurationStatus.active
                      ? l.servicesTeamDeactivate
                      : l.servicesTeamActivate,
                  onPressed: toggle,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Row(
                  children: [
                    AppAvatar(name: team.name, radius: 28),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.name,
                            style: AppTypography.of(context).sectionTitle,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          AppStatusBadge(
                            label: serviceStatusLabel(team.status, l),
                            status: serviceStatus(team.status),
                            isPill: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesTeamDetails,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.servicesTeamCode,
                      value: team.teamCode,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesTeamLead,
                      value: lead?.name ?? l.servicesTeamLeadNone,
                    ),
                    AppDetailField(
                      label: l.servicesTeamMembers,
                      value: numbers.integer(state.members.length),
                    ),
                    if (team.description != null &&
                        team.description!.isNotEmpty)
                      AppDetailField(
                        label: l.servicesTeamDescription,
                        value: team.description!,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppSettingsSection(
                title: l.servicesTeamMembers,
                children: [
                  if (state.members.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(l.servicesTeamNoMembers),
                    )
                  else
                    for (final member in state.members)
                      ListTile(
                        leading: AppAvatar(name: member.name),
                        title: Text(member.name),
                        subtitle: Text(
                          member.employeeCode,
                          textDirection: TextDirection.ltr,
                        ),
                        trailing: member.isActive
                            ? null
                            : AppStatusBadge(
                                label: l.inactive,
                                status: AppStatus.neutral,
                              ),
                      ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
