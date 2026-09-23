import 'package:modular_erp/modules/hr/attendance/presentation/attendance_session_scope.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/platform/notifications/domain/notification_repository.dart';
import 'package:modular_erp/platform/notifications/presentation/bloc/notification_badge_cubit.dart';
import 'package:modular_erp/platform/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:modular_erp/core/sync/app_sync_status_cubit.dart';
import 'package:modular_erp/core/sync/sync_diagnostics.dart';
import 'package:modular_erp/core/preferences/app_preferences_repository.dart';
import 'package:modular_erp/platform/notifications/application/attendance_reminder_service.dart';
import 'package:modular_erp/platform/notifications/domain/device_notification_service.dart';
import 'package:modular_erp/shared/presentation/app_sync_status.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'app_lifecycle_coordinator.dart';
import 'dart:async';
import 'module_registry/module_registry.dart';
import 'shell/app_shell_cubit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/localization/locale_cubit.dart';
import 'package:modular_erp/core/errors/failure_localization.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/design_system/theme/app_theme.dart';
import 'package:modular_erp/design_system/components/feedback/app_feedback.dart';
import 'router/app_router.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/platform/auth/domain/entities/demo_credential_info.dart';

class ErpApp extends StatefulWidget {
  const ErpApp({
    super.key,
    required this.localeCubit,
    required this.authBloc,
    this.demoAccounts = const [],
    this.routerOverride,
    this.moduleRegistry,
    this.shellCubit,
    this.attendanceBlocFactory,
    this.attendanceClock,
    this.companyTime,
    this.notificationRepository,
    this.syncStatusCubit,
    this.lifecycleCoordinator,
    this.preferences,
    this.deviceNotifications,
    this.reminderService,
    this.syncDiagnostics,
  });
  final LocaleCubit localeCubit;
  final AuthBloc authBloc;
  final List<DemoCredentialInfo> demoAccounts;

  /// Injection for internal Phase 0 visual QA; production always uses auth guards.
  final GoRouter? routerOverride;
  final ModuleRegistry? moduleRegistry;
  final AppShellCubit? shellCubit;
  final AttendanceBloc Function()? attendanceBlocFactory;
  final AppClock? attendanceClock;
  final CompanyTimeService? companyTime;
  final NotificationRepository? notificationRepository;
  final AppSyncStatusCubit? syncStatusCubit;
  final AppLifecycleCoordinator? lifecycleCoordinator;
  final AppPreferencesRepository? preferences;
  final DeviceNotificationService? deviceNotifications;
  final AttendanceReminderService? reminderService;
  final SyncDiagnosticsService? syncDiagnostics;
  @override
  State<ErpApp> createState() => _ErpAppState();
}

class _ErpAppState extends State<ErpApp> with WidgetsBindingObserver {
  NotificationBadgeCubit? _badgeCubit;
  NotificationsBloc? _notificationsBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final repository = widget.notificationRepository;
    if (repository != null) {
      final badge = NotificationBadgeCubit(
        repository,
        widget.authBloc.repository,
      );
      final notifications = NotificationsBloc(
        repository,
        widget.authBloc.repository,
      )..add(const NotificationsStarted());
      _badgeCubit = badge;
      _notificationsBloc = notifications;
      unawaited(badge.start());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.authBloc.add(const AuthSessionCheckRequested());
      widget.lifecycleCoordinator?.onResumed();
    } else if (state == AppLifecycleState.paused) {
      widget.lifecycleCoordinator?.onPaused();
    }
  }

  late final AppShellCubit shellCubit = widget.shellCubit ?? AppShellCubit();
  late final AuthRouterRefresh refresh = AuthRouterRefresh(widget.authBloc);
  late final GoRouter router =
      widget.routerOverride ??
      createAppRouter(
        authBloc: widget.authBloc,
        authRepository: widget.authBloc.repository,
        refresh: refresh,
        demoAccounts: widget.demoAccounts,
        enablePreview: widget.demoAccounts.isNotEmpty,
        registry: widget.moduleRegistry,
      );
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    router.dispose();
    refresh.dispose();
    final notifications = _notificationsBloc;
    final badge = _badgeCubit;
    if (notifications != null) unawaited(notifications.close());
    if (badge != null) unawaited(badge.close());
    if (widget.shellCubit == null) unawaited(shellCubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider.value(value: widget.localeCubit),
      BlocProvider.value(value: widget.authBloc),
      BlocProvider.value(value: shellCubit),
      if (_notificationsBloc != null)
        BlocProvider.value(value: _notificationsBloc!),
      if (_badgeCubit != null) BlocProvider.value(value: _badgeCubit!),
      if (widget.syncStatusCubit != null)
        BlocProvider.value(value: widget.syncStatusCubit!),
      if (widget.preferences != null)
        RepositoryProvider<AppPreferencesRepository>.value(
          value: widget.preferences!,
        ),
      if (widget.deviceNotifications != null)
        RepositoryProvider<DeviceNotificationService>.value(
          value: widget.deviceNotifications!,
        ),
      if (widget.reminderService != null)
        RepositoryProvider<AttendanceReminderService>.value(
          value: widget.reminderService!,
        ),
      if (widget.syncDiagnostics != null)
        RepositoryProvider<SyncDiagnosticsService>.value(
          value: widget.syncDiagnostics!,
        ),
    ],
    child: BlocBuilder<LocaleCubit, LocaleState>(
      buildWhen: (previous, current) => previous.language != current.language,
      builder: (context, state) => MaterialApp.router(
        onGenerateTitle: (context) => context.l10n.appName,
        debugShowCheckedModeBanner: false,
        locale: state.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) {
          final content = widget.attendanceBlocFactory == null
              ? child ?? const SizedBox.shrink()
              : AttendanceSessionScope(
                  create: widget.attendanceBlocFactory!,
                  clock: widget.attendanceClock ?? const SystemAppClock(),
                  time:
                      widget.companyTime ??
                      const FixedOffsetCompanyTimeService(),
                  child: child ?? const SizedBox.shrink(),
                );
          return BlocListener<LocaleCubit, LocaleState>(
            listenWhen: (previous, current) =>
                current.failure != null && previous.failure != current.failure,
            listener: (context, state) {
              // One listener serves all selectors; copy tracks live localization.
              AppFeedback.showMessage(
                context,
                message: (l10n) => state.failure!.localizedMessage(l10n),
              );
            },
            child: widget.syncStatusCubit == null
                ? content
                : AppSyncStatusBanner(
                    cubit: widget.syncStatusCubit,
                    child: content,
                  ),
          );
        },
        theme: AppTheme.light(locale: state.locale),
        themeMode: ThemeMode.light,
        routerConfig: router,
      ),
    ),
  );
}
