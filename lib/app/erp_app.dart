import '../features/attendance/presentation/attendance_session_scope.dart';
import '../features/attendance/presentation/bloc/attendance_bloc.dart';
import '../features/attendance/domain/shift_workday_resolver.dart';
import '../core/utils/app_clock.dart';
import 'dart:async';
import 'module_registry/module_registry.dart';
import 'shell/app_shell_cubit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/localization/locale_cubit.dart';
import '../core/errors/failure_localization.dart';
import '../l10n/l10n.dart';
import '../design_system/theme/app_theme.dart';
import '../design_system/components/feedback/app_feedback.dart';
import 'router/app_router.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/domain/entities/demo_credential_info.dart';

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
  @override
  State<ErpApp> createState() => _ErpAppState();
}

class _ErpAppState extends State<ErpApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.authBloc.add(const AuthSessionCheckRequested());
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
    if (widget.shellCubit == null) unawaited(shellCubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider.value(value: widget.localeCubit),
      BlocProvider.value(value: widget.authBloc),
      BlocProvider.value(value: shellCubit),
    ],
    child: BlocBuilder<LocaleCubit, LocaleState>(
      buildWhen: (previous, current) => previous.language != current.language,
      builder: (context, state) => MaterialApp.router(
        onGenerateTitle: (context) => context.l10n.appName,
        debugShowCheckedModeBanner: false,
        locale: state.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => BlocListener<LocaleCubit, LocaleState>(
          listenWhen: (previous, current) =>
              current.failure != null && previous.failure != current.failure,
          listener: (context, state) {
            // One listener serves all selectors; copy tracks live localization.
            AppFeedback.showMessage(
              context,
              message: (l10n) => state.failure!.localizedMessage(l10n),
            );
          },
          child: widget.attendanceBlocFactory == null
              ? child ?? const SizedBox.shrink()
              : AttendanceSessionScope(
                  create: widget.attendanceBlocFactory!,
                  clock: widget.attendanceClock ?? const SystemAppClock(),
                  time:
                      widget.companyTime ??
                      const FixedOffsetCompanyTimeService(),
                  child: child ?? const SizedBox.shrink(),
                ),
        ),
        theme: AppTheme.light(locale: state.locale),
        themeMode: ThemeMode.light,
        routerConfig: router,
      ),
    ),
  );
}
