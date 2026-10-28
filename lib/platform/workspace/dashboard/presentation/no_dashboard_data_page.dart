import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/security/access_tree.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

/// Live dashboard state until a dashboard endpoint exists.
///
/// It never renders business numbers. Links are generated from [accessTree],
/// so the dashboard can only open screens the signed-in user may view.
class NoDashboardDataPage extends StatelessWidget {
  const NoDashboardDataPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<AuthBloc, AuthState, AuthContext?>(
        selector: (state) => state.context,
        builder: (context, account) {
          if (account == null) return const SizedBox.shrink();
          final l = context.l10n;
          final permissions = account.user.permissions;
          final modules = accessTree.visibleModules(permissions);
          return AppPage(
            header: AppPageHeader(
              title: l.shellDashboard,
              subtitle: l.dashboardNoDataSource,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: AppEmptyState(
                    title: l.dashboardNoDataSource,
                    message: l.dashboardNoDataSourceMessage,
                    icon: Icons.insights_outlined,
                  ),
                ),
                if (permissions.length == 0) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: AppEmptyState(
                      title: l.shellNoPermissionsTitle,
                      message: l.shellNoPermissionsMessage,
                      icon: Icons.lock_outline,
                    ),
                  ),
                ] else if (modules.isEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: AppEmptyState(
                      title: l.shellNoDestinations,
                      message: l.shellNoDestinationsMessage,
                      icon: Icons.explore_off_outlined,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l.dashboardQuickLinks,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final module in modules) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.name(l),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              for (final screen
                                  in accessTree.visibleNavigationScreens(
                                    permissions,
                                  ))
                                if (screen.moduleId == module.id)
                                  AppTextButton(
                                    key: ValueKey(
                                      'dashboard-quick-link-${screen.id}',
                                    ),
                                    label: screen.name(l),
                                    onPressed: () => context.go(screen.route),
                                  ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ],
            ),
          );
        },
      );
}
