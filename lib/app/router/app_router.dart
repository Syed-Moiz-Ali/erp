import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/entities/demo_credential_info.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/password_bloc.dart';
import '../../features/auth/presentation/pages/bootstrap_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../../features/auth/presentation/pages/authenticated_home_placeholder.dart';
import '../../features/design_system_preview/presentation/design_system_preview_page.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';

class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh(AuthBloc bloc) {
    _subscription = bloc.stream
        .map((state) => (state.isInitializing, state.isAuthenticated))
        .distinct()
        .listen((_) => notifyListeners());
  }
  late final StreamSubscription<(bool, bool)> _subscription;
  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}

/// Pure guard policy. Return targets are restricted to known protected paths.
String? authRedirect(AuthState auth, Uri uri, {bool enablePreview = false}) {
  final path = uri.path;
  final initializing = auth.isInitializing;
  final public = path == '/login' || path == '/forgot-password';
  final protected =
      path == '/app' ||
      path == '/app/change-password' ||
      (enablePreview && path == '/design-system');
  String destination() {
    final requested = uri.queryParameters['from'];
    return requested == '/app/change-password' ||
            (enablePreview && requested == '/design-system')
        ? requested!
        : '/app';
  }

  if (initializing) {
    return path == '/bootstrap'
        ? null
        : Uri(
            path: '/bootstrap',
            queryParameters: {'from': protected ? path : '/app'},
          ).toString();
  }
  if (!auth.isAuthenticated) {
    if (public) return null;
    return Uri(
      path: '/login',
      queryParameters: protected
          ? {'from': path}
          : uri.queryParameters['from'] == '/app/change-password' ||
                (enablePreview &&
                    uri.queryParameters['from'] == '/design-system')
          ? {'from': uri.queryParameters['from']!}
          : null,
    ).toString();
  }
  if (public || path == '/bootstrap' || path == '/') return destination();
  return null;
}

GoRouter createAppRouter({
  required AuthBloc authBloc,
  required AuthRepository authRepository,
  required Listenable refresh,
  List<DemoCredentialInfo> demoAccounts = const [],
  bool enablePreview = false,
  String? initialLocation,
}) => GoRouter(
  initialLocation: initialLocation,
  refreshListenable: refresh,
  redirect: (context, state) =>
      authRedirect(authBloc.state, state.uri, enablePreview: enablePreview),
  errorBuilder: (context, state) => Scaffold(
    body: AppErrorState(
      message: context.l10n.pageNotFound,
      onRetry: () => context.go('/app'),
    ),
  ),
  routes: [
    GoRoute(path: '/', redirect: (context, state) => '/app'),
    GoRoute(
      path: '/bootstrap',
      builder: (context, state) => const BootstrapPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(demoAccounts: demoAccounts),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => BlocProvider(
        create: (_) => PasswordBloc(authRepository),
        child: const ForgotPasswordPage(),
      ),
    ),
    GoRoute(
      path: '/app',
      builder: (context, state) => AuthenticatedHomePlaceholder(
        showPermissionViewer: demoAccounts.isNotEmpty,
      ),
      routes: [
        GoRoute(
          path: 'change-password',
          builder: (context, state) => BlocProvider(
            create: (_) => PasswordBloc(authRepository),
            child: const ChangePasswordPage(),
          ),
        ),
      ],
    ),
    if (enablePreview)
      GoRoute(
        path: '/design-system',
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
