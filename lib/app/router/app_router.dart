import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/entities/auth_context.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/entities/demo_credential_info.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/bootstrap_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/bloc/password_bloc.dart';
import '../../features/design_system_preview/presentation/design_system_preview_page.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../module_registry/module_registry.dart';
import '../module_registry/navigation_resolver.dart';
import '../module_registry/registered_modules.dart';
import '../shell/app_shell.dart';
import '../shell/pages/more_page.dart';
import '../shell/pages/route_status_pages.dart';
import 'app_routes.dart';

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
