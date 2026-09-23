import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/demo_credential_info.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/platform/auth/presentation/pages/bootstrap_page.dart';
import 'package:modular_erp/platform/auth/presentation/pages/login_page.dart';
import 'package:modular_erp/platform/auth/presentation/pages/forgot_password_page.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/password_bloc.dart';
import 'package:modular_erp/platform/design_system_preview/presentation/design_system_preview_page.dart';
import 'package:modular_erp/platform/notifications/presentation/notifications_page.dart';
import 'package:modular_erp/platform/notifications/presentation/bloc/reminder_settings_cubit.dart';
import 'package:modular_erp/platform/notifications/presentation/reminder_settings_page.dart';
import 'package:modular_erp/platform/notifications/application/attendance_reminder_service.dart';
import 'package:modular_erp/platform/notifications/domain/device_notification_service.dart';
import 'package:modular_erp/platform/sync/presentation/sync_settings_page.dart';
import 'package:modular_erp/platform/sync/presentation/sync_inspector_page.dart';
import 'package:modular_erp/core/preferences/app_preferences_repository.dart';
import 'package:modular_erp/core/sync/app_sync_status_cubit.dart';
import 'package:modular_erp/core/sync/sync_diagnostics.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/module_registry/navigation_resolver.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/app/shell/app_shell.dart';
import 'package:modular_erp/app/shell/pages/more_page.dart';
import 'package:modular_erp/app/shell/pages/route_status_pages.dart';
import 'app_routes.dart';

T? _providerOrNull<T>(BuildContext context) {
  try {
    return context.read<T>();
  } catch (_) {
    return null;
  }
}

class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh(AuthBloc bloc) {
    _subscription = bloc.stream
        .map(
          (state) =>
              (state.isInitializing, state.isAuthenticated, state.context),
        )
        .distinct()
        .listen((_) => notifyListeners());
  }
  late final StreamSubscription<(bool, bool, AuthContext?)> _subscription;
  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}

String? authRedirect(
  AuthState auth,
  Uri uri, {
  required NavigationResolver navigation,
  bool enablePreview = false,
}) {
  final path = uri.path;
  final public = path == AppRoutes.login || path == AppRoutes.forgotPassword;
  bool safeTarget(String? target) {
    if (target == null) return false;
    final parsed = Uri.tryParse(target);
    return parsed != null &&
        !parsed.hasScheme &&
        !parsed.hasAuthority &&
        (navigation.registry.ownerOf(parsed.path) != null ||
            parsed.path == AppRoutes.app ||
            AppRoutes.utilityPaths.contains(parsed.path) ||
            (enablePreview && parsed.path == AppRoutes.designSystem));
  }

  final target = uri.queryParameters['from'];
  final currentTarget = safeTarget(uri.toString()) ? uri.toString() : null;
  if (auth.isInitializing) {
    if (path == AppRoutes.bootstrap) return null;
    return Uri(
      path: AppRoutes.bootstrap,
      queryParameters: {'from': public ? path : currentTarget ?? AppRoutes.app},
    ).toString();
  }
  if (!auth.isAuthenticated) {
    if (public) return null;
    if (path == AppRoutes.bootstrap && target == AppRoutes.forgotPassword) {
      return AppRoutes.forgotPassword;
    }
    final requested = currentTarget ?? (safeTarget(target) ? target : null);
    return Uri(
      path: AppRoutes.login,
      queryParameters: requested == null ? null : {'from': requested},
    ).toString();
  }
  final account = auth.context!;
  final landing = DefaultLandingResolver(navigation).resolve(account);
  if (public ||
      path == AppRoutes.bootstrap ||
      path == AppRoutes.root ||
      path == AppRoutes.app) {
    return safeTarget(target) && Uri.parse(target!).path != AppRoutes.app
        ? target
        : landing;
  }
  final access = navigation.routeAccess(path, account);
  return switch (access) {
    RouteAccess.unauthorized => Uri(
      path: AppRoutes.unauthorized,
      queryParameters: {'from': uri.toString()},
    ).toString(),
    RouteAccess.moduleUnavailable => Uri(
      path: AppRoutes.unavailable,
      queryParameters: {'from': uri.toString()},
    ).toString(),
    _ => null,
  };
}

GoRouter createAppRouter({
  required AuthBloc authBloc,
  required AuthRepository authRepository,
  required Listenable refresh,
  ModuleRegistry? registry,
  List<DemoCredentialInfo> demoAccounts = const [],
  bool enablePreview = false,
  String? initialLocation,
}) {
  // Critical for cross-platform URL state: go_router does not reflect
  // imperative push/replace in the URL by default, which left the browser URL
  // stuck on the list route while a detail screen was pushed. Enabling this
  // keeps the URL authoritative for every navigable destination.
  GoRouter.optionURLReflectsImperativeAPIs = true;
  final modules = registry ?? createErpRegistry(authRepository);
  final navigation = NavigationResolver(modules);
  String landing() => authBloc.state.context == null
      ? AppRoutes.app
      : DefaultLandingResolver(navigation).resolve(authBloc.state.context!);
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: refresh,
    redirect: (context, state) => authRedirect(
      authBloc.state,
      state.uri,
      navigation: navigation,
      enablePreview: enablePreview,
    ),
    onException: (context, state, router) {
      // Apply access rules before 404 even when a nested route is not implemented yet.
      final known = modules.ownerOf(state.uri.path) != null;
      final missing = Uri(
        path: AppRoutes.notFound,
        queryParameters: {'from': state.uri.toString()},
      );
      final redirect = authRedirect(
        authBloc.state,
        known ? state.uri : missing,
        navigation: navigation,
        enablePreview: enablePreview,
      );
      router.go(redirect ?? missing.toString());
    },
    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) => AppRoutes.app,
      ),
      GoRoute(path: AppRoutes.app, redirect: (context, state) => landing()),
      GoRoute(
        path: AppRoutes.bootstrap,
        builder: (context, state) => const BootstrapPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginPage(demoAccounts: demoAccounts),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => BlocProvider(
          create: (_) => PasswordBloc(authRepository),
          child: const ForgotPasswordPage(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(
          navigationShell: shell,
          registry: modules,
          resolver: navigation,
          route: state.uri.path,
        ),
        branches: [
          for (final entry in modules.registrations)
            StatefulShellBranch(routes: entry.routes),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.more,
                name: 'more',
                builder: (context, state) =>
                    BlocSelector<AuthBloc, AuthState, AuthContext?>(
                      selector: (state) => state.context,
                      builder: (context, account) => account == null
                          ? const SizedBox.shrink()
                          : MorePage(
                              navigation: navigation.resolve(
                                account.company,
                                account.user.permissions,
                                employee: account.employeeReference,
                              ),
                            ),
                    ),
              ),
              GoRoute(
                path: AppRoutes.unauthorized,
                builder: (context, state) =>
                    UnauthorizedPage(landing: landing()),
              ),
              GoRoute(
                path: AppRoutes.unavailable,
                builder: (context, state) =>
                    ModuleUnavailablePage(landing: landing()),
              ),
              GoRoute(
                path: AppRoutes.notifications,
                name: 'notifications',
                builder: (context, state) => const NotificationsPage(),
              ),
              GoRoute(
                path: AppRoutes.reminderSettings,
                name: 'reminder-settings',
                builder: (context, state) {
                  final preferences = _providerOrNull<AppPreferencesRepository>(
                    context,
                  );
                  final device = _providerOrNull<DeviceNotificationService>(
                    context,
                  );
                  final reminders = _providerOrNull<AttendanceReminderService>(
                    context,
                  );
                  if (preferences == null || device == null) {
                    return AppPage(
                      maxWidth: AppDimensions.details,
                      header: AppPageHeader(
                        title: context.l10n.notificationsReminders,
                      ),
                      child: AppErrorState(
                        message: context.l10n.reminderSaveFailed,
                      ),
                    );
                  }
                  // Attendance reminders only make sense for a linked employee.
                  final linked = context
                      .read<AuthBloc>()
                      .state
                      .context
                      ?.employeeReference;
                  if (linked == null) {
                    return AppPage(
                      maxWidth: AppDimensions.details,
                      header: AppPageHeader(
                        title: context.l10n.notificationsReminders,
                      ),
                      child: AppEmptyState(
                        title: context.l10n.profileNoEmployeeLinked,
                        message: context.l10n.reminderPermissionHint,
                      ),
                    );
                  }
                  final locale = Localizations.localeOf(context);
                  return BlocProvider(
                    create: (_) => ReminderSettingsCubit(
                      preferences,
                      device,
                      onChanged: reminders == null
                          ? null
                          : () => reminders.reconcile(locale: locale),
                    )..load(),
                    child: const ReminderSettingsPage(),
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.syncSettings,
                name: 'sync-settings',
                builder: (context, state) {
                  final cubit = _providerOrNull<AppSyncStatusCubit>(context);
                  if (cubit == null) {
                    return AppPage(
                      maxWidth: AppDimensions.details,
                      header: AppPageHeader(
                        title: context.l10n.syncDataAndSync,
                      ),
                      child: AppEmptyState(
                        title: context.l10n.syncAllChangesSynced,
                        message: context.l10n.syncNoPendingChanges,
                      ),
                    );
                  }
                  return BlocProvider.value(
                    value: cubit,
                    child: const SyncSettingsPage(),
                  );
                },
              ),
              if (kDebugMode)
                GoRoute(
                  path: AppRoutes.syncInspector,
                  name: 'sync-inspector',
                  builder: (context, state) {
                    final diagnostics = _providerOrNull<SyncDiagnosticsService>(
                      context,
                    );
                    if (diagnostics == null) {
                      return const SizedBox.shrink();
                    }
                    return SyncInspectorPage(
                      diagnostics: diagnostics,
                      auth: authRepository,
                    );
                  },
                ),
              GoRoute(
                path: AppRoutes.notFound,
                builder: (context, state) => NotFoundPage(landing: landing()),
              ),
              GoRoute(
                path: AppRoutes.noDestinations,
                builder: (context, state) => const NoDestinationsPage(),
              ),
            ],
          ),
        ],
      ),
      if (enablePreview)
        GoRoute(
          path: AppRoutes.designSystem,
          builder: (context, state) => Scaffold(
            appBar: AppBar(
              title: Text(context.l10n.designSystem),
              actions: const [AppLanguageSelector()],
            ),
            body: DesignSystemPreviewPage(),
          ),
        ),
    ],
  );
}
