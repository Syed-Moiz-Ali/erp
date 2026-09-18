import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_routes.dart';
import '../../core/errors/result.dart';
import '../../core/models/configuration_record.dart';
import '../../core/security/app_permission.dart';
import '../../design_system/design_system.dart';
import '../../features/auth/domain/entities/auth_context.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/shifts/domain/shift_repository.dart';
import '../../features/work_locations/domain/work_location_repository.dart';
import '../../features/attendance_policies/domain/attendance_policy_repository.dart';
import '../../l10n/l10n.dart';
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
    this.policies,
  ) : super(const ConfigurationLandingState({}, {})) {
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
  final _subscriptions = <StreamSubscription<dynamic>>[];
  @override
  Future<void> close() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    return super.close();
  }
}

class ConfigurationLandingPage extends StatelessWidget {
  const ConfigurationLandingPage({
    super.key,
    this.shiftRepository,
    this.workLocationRepository,
    this.attendancePolicyRepository,
  });
  final ShiftRepository? shiftRepository;
  final WorkLocationRepository? workLocationRepository;
  final AttendancePolicyRepository? attendancePolicyRepository;
  @override
  Widget build(
    BuildContext c,
  ) => BlocSelector<AuthBloc, AuthState, AuthContext?>(
    selector: (s) => s.context,
    builder: (c, account) {
      if (account == null) return const SizedBox.shrink();
      return BlocProvider(
        key: ValueKey(account),
        create: (_) => ConfigurationLandingBloc(
          account,
          shiftRepository,
          workLocationRepository,
          attendancePolicyRepository,
        )..add(const ConfigurationLandingStarted()),
        child: BlocBuilder<ConfigurationLandingBloc, ConfigurationLandingState>(
          builder: (c, s) {
            final l = c.l10n;
            Widget tile(
              String key,
              String title,
              String description,
              IconData icon,
              String route,
            ) => AppSettingsTile(
              title: title,
              description: description,
              icon: icon,
              count: s.counts[key] == null
                  ? null
                  : configurationNumber(c, s.counts[key]!),
              onPressed: () => c.go(route),
            );
            return AppPage(
              header: AppPageHeader(
                title: l.cfgConfiguration,
                subtitle: l.cfgIntro,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (s.failures.isNotEmpty)
                    AppErrorState(message: l.cfgStorageError),
                  if (account.user.permissions.contains(
                    AppPermission.shiftView,
                  ))
                    tile(
                      'shifts',
                      l.cfgShifts,
                      l.cfgShiftIntro,
                      Icons.schedule_outlined,
                      AppRoutes.shifts,
                    ),
                  if (account.user.permissions.contains(
                    AppPermission.workLocationView,
                  ))
                    tile(
                      'locations',
                      l.cfgLocations,
                      l.cfgLocationIntro,
                      Icons.location_on_outlined,
                      AppRoutes.workLocations,
                    ),
                  if (account.user.permissions.contains(
                    AppPermission.attendancePolicyView,
                  ))
                    tile(
                      'policies',
                      l.cfgPolicies,
                      l.cfgPolicyIntro,
                      Icons.rule_outlined,
                      AppRoutes.attendancePolicies,
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  AppInfoCard(
                    title: l.cfgConfiguration,
                    message: l.cfgFoundationNote,
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
