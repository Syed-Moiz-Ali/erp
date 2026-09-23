import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/platform/auth/presentation/auth_localization.dart';
import 'package:modular_erp/platform/notifications/presentation/bloc/notification_badge_cubit.dart';
import 'package:modular_erp/platform/notifications/presentation/notification_panel.dart';
import 'package:modular_erp/platform/notifications/presentation/widgets/notification_bell.dart';
import 'package:modular_erp/core/errors/failure_localization.dart';
import 'package:modular_erp/core/sync/app_sync_status_cubit.dart';
import 'package:modular_erp/shared/presentation/app_sync_status.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/module_registry/navigation_resolver.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'app_shell_cubit.dart';

AppSyncStatusCubit? _syncStatusOf(BuildContext context) {
  try {
    return context.read<AppSyncStatusCubit>();
  } catch (_) {
    return null;
  }
}

T? _maybeRead<T>(BuildContext context) {
  try {
    return context.read<T>();
  } catch (_) {
    return null;
  }
}

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.registry,
    required this.resolver,
    required this.route,
  });
  final StatefulNavigationShell navigationShell;
  final ModuleRegistry registry;
  final NavigationResolver resolver;
  final String route;
  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
    listenWhen: (previous, current) =>
        current.isAuthenticated &&
        current.failure != null &&
        previous.failure != current.failure,
    listener: (context, state) => AppFeedback.showMessage(
      context,
      message: (l) => state.failure!.localizedMessage(l),
    ),
    child: BlocListener<AppShellCubit, AppShellState>(
      listenWhen: (previous, current) =>
          current.failure != null && current.failure != previous.failure,
      listener: (context, state) => AppFeedback.showMessage(
        context,
        message: (l) => state.failure!.localizedMessage(l),
      ),
      child: BlocSelector<AuthBloc, AuthState, AuthContext?>(
        selector: (state) => state.context,
        builder: (context, account) {
          if (account == null) return const SizedBox.shrink();
          final navigation = resolver.resolve(
            account.company,
            account.user.permissions,
            employee: account.employeeReference,
          );
          final owner = registry.ownerOf(route);
          final primary = navigation.mobilePrimary;
          // Primary navigation always targets the module's canonical root.
          // `goBranch` would restore that branch's preserved nested location,
          // so an explicit module click from a detail screen would look like a
          // no-op. Reselecting the active module root is an intentional no-op.
          void navigate(String target) => context.go(target);

          void companyInformation() => AppDialog.show<void>(
            context,
            (dialogContext) => AppDialog(
              title: dialogContext.l10n.shellCompanyInformation,
              actions: [
                AppTextButton(
                  label: dialogContext.l10n.close,
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ],
              child: AppDetailsSection(
                title: account.company.name,
                details: {
                  dialogContext.l10n.shellCompanyCode: account.company.code,
                  dialogContext.l10n.shellTimezone: account.company.timezone,
                },
              ),
            ),
          );
          final title = owner != null && navigation.destinations.contains(owner)
              ? owner.name(context.l10n)
              : route == AppRoutes.more
              ? context.l10n.shellMore
              : context.l10n.workspace;
          return BlocSelector<AppShellCubit, AppShellState, bool>(
            selector: (state) => state.collapsed,
            builder: (context, collapsed) => AppResponsiveScaffold(
              modules: navigation.desktop,
              route: route,
              collapsed: collapsed,
              companyName: account.company.name,
              onCompanyPressed: companyInformation,
              onToggleSidebar: () =>
                  unawaited(context.read<AppShellCubit>().toggle()),
              bottomModules: navigation.mobileDestinations,
              bottomSelectedRoute:
                  primary
                      .where((module) => module.owns(route))
                      .map((module) => module.route)
                      .firstOrNull ??
                  AppRoutes.more,
              onNavigate: navigate,
              topBar: AppTopBar(
                title: title,
                onSearch: () => AppCommandPalette.show(context),
                onNotifications: () => NotificationPanel.show(context),
                notificationsButton: NotificationBell(
                  cubit: _maybeRead<NotificationBadgeCubit>(context),
                  onPressed: () => NotificationPanel.show(context),
                ),
                syncIndicator: AppSyncIndicator(cubit: _syncStatusOf(context)),
                accountMenu: BlocSelector<AuthBloc, AuthState, bool>(
                  selector: (state) => state.loggingOut,
                  builder: (context, busy) => AppUserMenu(
                    name: account.user.displayName,
                    email: account.user.email,
                    roleLabel: account.user.role.label,
                    busy: busy,
                    onProfile: () => navigate(AppRoutes.profile),
                    onPassword: () => context.go(AppRoutes.changePassword),
                    onLanguage: () => AppDialog.show<void>(
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
                    onLogout: () async {
                      final bloc = context.read<AuthBloc>();
                      final confirmed = await AppConfirmationDialog.show(
                        context,
                        title: (l) => l.authConfirmLogout,
                        message: (l) => l.authLogoutMessage,
                        confirmLabel: (l) => l.logout,
                      );
                      if (confirmed && context.mounted && !bloc.isClosed) {
                        bloc.add(const AuthLogoutRequested());
                      }
                    },
                  ),
                ),
              ),
              child: navigationShell,
            ),
          );
        },
      ),
    ),
  );
}
