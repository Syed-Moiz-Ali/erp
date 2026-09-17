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
  });
  final LocaleCubit localeCubit;
  final AuthBloc authBloc;
  final List<DemoCredentialInfo> demoAccounts;

  /// Injection for internal Phase 0 visual QA; production always uses auth guards.
  final GoRouter? routerOverride;
  @override
  State<ErpApp> createState() => _ErpAppState();
}

class _ErpAppState extends State<ErpApp> {
  late final AuthRouterRefresh refresh = AuthRouterRefresh(widget.authBloc);
  late final GoRouter router =
      widget.routerOverride ??
      createAppRouter(
        authBloc: widget.authBloc,
        authRepository: widget.authBloc.repository,
        refresh: refresh,
        demoAccounts: widget.demoAccounts,
        enablePreview: widget.demoAccounts.isNotEmpty,
      );
  @override
  void dispose() {
    router.dispose();
    refresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider.value(value: widget.localeCubit),
      BlocProvider.value(value: widget.authBloc),
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
          child: child ?? const SizedBox.shrink(),
        ),
        theme: AppTheme.light(locale: state.locale),
        themeMode: ThemeMode.light,
        routerConfig: router,
      ),
    ),
  );
}
