import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/user_capability.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift_repository.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location_repository.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy_repository.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/shared/domain/configuration_repository.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'configuration_localization.dart';

sealed class ConfigurationLandingEvent {
  const ConfigurationLandingEvent();
}

class ConfigurationLandingStarted extends ConfigurationLandingEvent {
  const ConfigurationLandingStarted();
}

class _CountUpdated extends ConfigurationLandingEvent {
  const _CountUpdated(this.key, this.count, this.failure);
  final String key;
  final int? count;
  final Failure? failure;
}

class ConfigurationLandingState {
  const ConfigurationLandingState(this.counts, this.failures);
  final Map<String, int> counts;
  final Map<String, Failure> failures;
}

class ConfigurationLandingBloc
    extends Bloc<ConfigurationLandingEvent, ConfigurationLandingState> {
  ConfigurationLandingBloc(
    this.account,
    this.shifts,
    this.locations,
    this.policies, {
    this.leaveTypes,
    this.leavePolicies,
    this.holidays,
  }) : super(const ConfigurationLandingState({}, {})) {
    on<ConfigurationLandingStarted>((event, emit) {
      void watch<T extends ConfigurationRecord>(
        String key,
        Stream<Result<ConfigurationPageData<T>>> stream,
      ) {
        _subscriptions.add(
          stream.listen(
            (result) {
              if (isClosed) return;
              if (result is Success<ConfigurationPageData<T>>) {
                add(_CountUpdated(key, result.value.total, null));
              } else if (result is Failed<ConfigurationPageData<T>>) {
                add(_CountUpdated(key, null, result.failure));
              }
            },
            onError: (Object _) {
              if (!isClosed) {
                add(
                  _CountUpdated(
                    key,
                    null,
                    const Failure(code: 'databaseFailure'),
                  ),
                );
              }
            },
          ),
        );
      }

      if (shifts != null &&
          account.user.permissions.contains(AppPermission.shiftView)) {
        watch('shifts', shifts!.watchList(account, pageSize: 1));
      }
      if (locations != null &&
          account.user.permissions.contains(AppPermission.workLocationView)) {
        watch('locations', locations!.watchList(account, pageSize: 1));
      }
      if (policies != null &&
          account.user.permissions.contains(
            AppPermission.attendancePolicyView,
          )) {
        watch('policies', policies!.watchList(account, pageSize: 1));
      }
      if (leaveTypes != null &&
          account.user.permissions.contains(AppPermission.leaveTypeView)) {
        watch('leave-types', leaveTypes!.watchList(account, pageSize: 1));
      }
      if (leavePolicies != null &&
          account.user.permissions.contains(AppPermission.leavePolicyView)) {
        watch('leave-policies', leavePolicies!.watchList(account, pageSize: 1));
      }
      if (holidays != null &&
          account.user.permissions.contains(AppPermission.holidayView)) {
        watch('holidays', holidays!.watchList(account, pageSize: 1));
      }
    });
    on<_CountUpdated>((e, emit) {
      final failures = {...state.failures}..remove(e.key);
      if (e.failure != null) failures[e.key] = e.failure!;
      emit(
        ConfigurationLandingState({
          ...state.counts,
          if (e.count != null) e.key: e.count!,
        }, failures),
      );
    });
  }
  final AuthContext account;
  final ShiftRepository? shifts;
  final WorkLocationRepository? locations;
  final AttendancePolicyRepository? policies;
  final ConfigurationRepository<LeaveType, LeaveTypeDraft>? leaveTypes;
  final ConfigurationRepository<LeavePolicy, LeavePolicyDraft>? leavePolicies;
  final ConfigurationRepository<Holiday, HolidayDraft>? holidays;
  final _subscriptions = <StreamSubscription<dynamic>>[];
  @override
  Future<void> close() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    return super.close();
  }
}

/// Settings Hub: grouped, permission/capability-filtered navigation into real
/// configuration destinations. Contains no fake tiles for unimplemented areas.
class ConfigurationLandingPage extends StatelessWidget {
  const ConfigurationLandingPage({
    super.key,
    this.shiftRepository,
    this.workLocationRepository,
    this.attendancePolicyRepository,
    this.leaveTypeRepository,
    this.leavePolicyRepository,
    this.holidayRepository,
  });
  final ShiftRepository? shiftRepository;
  final WorkLocationRepository? workLocationRepository;
  final AttendancePolicyRepository? attendancePolicyRepository;
  final ConfigurationRepository<LeaveType, LeaveTypeDraft>? leaveTypeRepository;
  final ConfigurationRepository<LeavePolicy, LeavePolicyDraft>?
  leavePolicyRepository;
  final ConfigurationRepository<Holiday, HolidayDraft>? holidayRepository;

  @override
  Widget build(
    BuildContext context,
  ) => BlocSelector<AuthBloc, AuthState, AuthContext?>(
    selector: (state) => state.context,
    builder: (context, account) {
      if (account == null) return const SizedBox.shrink();
      return BlocProvider(
        key: ValueKey(account),
        create: (_) => ConfigurationLandingBloc(
          account,
          shiftRepository,
          workLocationRepository,
          attendancePolicyRepository,
          leaveTypes: leaveTypeRepository,
          leavePolicies: leavePolicyRepository,
          holidays: holidayRepository,
        )..add(const ConfigurationLandingStarted()),
        child: BlocBuilder<ConfigurationLandingBloc, ConfigurationLandingState>(
          builder: (context, state) {
            final l = context.l10n;
            final permissions = PermissionChecker(account.user.permissions);
            final capabilities = const UserCapabilityResolver().forAuthContext(
              account,
            );
            String? count(String key) => state.counts[key] == null
                ? null
                : configurationNumber(context, state.counts[key]!);

            final attendanceRows = <Widget>[
              if (permissions.can(AppPermission.shiftView))
                AppSettingsRow(
                  title: l.cfgShifts,
                  description: l.settingsShiftDesc,
                  icon: Icons.schedule_outlined,
                  trailing: count('shifts'),
                  onPressed: () => context.push(AppRoutes.shifts),
                ),
              if (permissions.can(AppPermission.workLocationView))
                AppSettingsRow(
                  title: l.cfgLocations,
                  description: l.settingsLocationDesc,
                  icon: Icons.location_on_outlined,
                  trailing: count('locations'),
                  onPressed: () => context.push(AppRoutes.workLocations),
                ),
              if (permissions.can(AppPermission.attendancePolicyView))
                AppSettingsRow(
                  title: l.cfgPolicies,
                  description: l.settingsPolicyDesc,
                  icon: Icons.rule_outlined,
                  trailing: count('policies'),
                  onPressed: () => context.push(AppRoutes.attendancePolicies),
                ),
            ];
            final leaveRows = <Widget>[
              if (permissions.can(AppPermission.leaveTypeView))
                AppSettingsRow(
                  title: l.leaveTypesNav,
                  description: l.leaveTypeIntro,
                  icon: Icons.category_outlined,
                  trailing: count('leave-types'),
                  onPressed: () => context.push(AppRoutes.leaveTypes),
                ),
              if (permissions.can(AppPermission.leavePolicyView))
                AppSettingsRow(
                  title: l.leavePoliciesNav,
                  description: l.leavePolicyIntro,
                  icon: Icons.rule_folder_outlined,
                  trailing: count('leave-policies'),
                  onPressed: () => context.push(AppRoutes.leavePolicies),
                ),
              if (permissions.can(AppPermission.holidayView))
                AppSettingsRow(
                  title: l.holidaysNav,
                  description: l.leaveManageHolidaysHint,
                  icon: Icons.beach_access_outlined,
                  trailing: count('holidays'),
                  onPressed: () => context.push(AppRoutes.holidays),
                ),
            ];
            final accessRows = <Widget>[
              if (permissions.can(AppPermission.accessUsersView) ||
                  permissions.can(AppPermission.accessPermissionsManage))
                AppSettingsRow(
                  title: l.usersAccessTitle,
                  description: l.usersAccessSubtitle,
                  icon: Icons.manage_accounts_outlined,
                  onPressed: () => context.push(AppRoutes.access),
                ),
              if (permissions.can(AppPermission.companyModulesView))
                AppSettingsRow(
                  title: l.accessCompanyModules,
                  description: l.accessCompanyModulesSubtitle,
                  icon: Icons.widgets_outlined,
                  onPressed: () => context.push(AppRoutes.modules),
                ),
            ];
            final preferenceRows = <Widget>[
              AppSettingsRow(
                title: l.language,
                description: l.settingsLanguageDesc,
                icon: Icons.translate_outlined,
                trailing: Localizations.localeOf(
                  context,
                ).languageCode.toUpperCase(),
                onPressed: () => AppDialog.show<void>(
                  context,
                  (dialogContext) => AppDialog(
                    title: dialogContext.l10n.language,
                    actions: [
                      AppTextButton(
                        label: dialogContext.l10n.close,
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                    child: const AppLanguageSelector(),
                  ),
                ),
              ),
              if (capabilities.hasLinkedEmployee)
                AppSettingsRow(
                  title: l.notificationsReminders,
                  description: l.settingsNotificationsDesc,
                  icon: Icons.notifications_active_outlined,
                  onPressed: () => context.push(AppRoutes.reminderSettings),
                ),
            ];
            final systemRows = <Widget>[
              AppSettingsRow(
                title: l.syncDataAndSync,
                description: l.settingsSyncDesc,
                icon: Icons.sync_outlined,
                onPressed: () => context.push(AppRoutes.syncSettings),
              ),
            ];
            return AppPage(
              maxWidth: AppDimensions.details,
              header: AppPageHeader(
                title: l.cfgConfiguration,
                subtitle: l.settingsIntro,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.failures.isNotEmpty)
                    AppErrorState(message: l.cfgStorageError),
                  if (attendanceRows.isNotEmpty) ...[
                    AppSettingsSection(
                      title: l.settingsAttendanceCategory,
                      description: l.settingsAttendanceCategoryDesc,
                      children: attendanceRows,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  if (leaveRows.isNotEmpty) ...[
                    AppSettingsSection(
                      title: l.settingsLeaveCategory,
                      description: l.settingsLeaveCategoryDesc,
                      children: leaveRows,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  if (accessRows.isNotEmpty) ...[
                    AppSettingsSection(
                      title: l.accessSubAccess,
                      children: accessRows,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  if (preferenceRows.isNotEmpty) ...[
                    AppSettingsSection(
                      title: l.settingsPreferencesCategory,
                      description: l.settingsPreferencesCategoryDesc,
                      children: preferenceRows,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  if (systemRows.isNotEmpty)
                    AppSettingsSection(
                      title: l.settingsSystemCategory,
                      description: l.settingsSystemCategoryDesc,
                      children: systemRows,
                    ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
