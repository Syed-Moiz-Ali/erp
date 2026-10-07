import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/security/permission_catalog.dart';
import 'package:modular_erp/core/security/permission_definition.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/access/presentation/access_localization.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

/// Company Modules: which ERP modules are enabled for the current company.
///
/// This is deliberately distinct from user access. Enabling a module here makes
/// it available for the company; granting an individual user access still
/// happens in Users & Access. Module availability is managed at platform level,
/// so the rows reflect actual state read-only.
class CompanyModulesPage extends StatelessWidget {
  const CompanyModulesPage({super.key, required this.catalog});
  final PermissionCatalog catalog;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<AuthBloc, AuthState, AuthContext?>(
        selector: (state) => state.context,
        builder: (context, account) {
          if (account == null) return const SizedBox.shrink();
          final l = context.l10n;
          final enabled = account.company.enabledModules;
          final modules = catalog.orderedModules
              .where((module) => module.id != 'platform')
              .toList();
          bool moduleEnabled(PermissionModule module) => module.definitions.any(
            (PermissionDefinition definition) =>
                definition.moduleId == 'platform' ||
                enabled.contains(definition.requiredFeature),
          );
          return AppPage(
            header: AppPageHeader(
              title: l.accessCompanyModules,
              subtitle: l.accessCompanyModulesSubtitle,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < modules.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        Builder(
                          builder: (context) {
                            final isEnabled = moduleEnabled(modules[i]);
                            return AppModuleToggleRow(
                              title: l.moduleLabel(modules[i].nameKey),
                              description: _moduleDescription(l, modules[i].id),
                              icon: _moduleIcon(modules[i].id),
                              enabled: isEnabled,
                              statusLabel: isEnabled
                                  ? l.accessEnabled
                                  : l.accessDisabled,
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppInfoCard(
                  title: l.accessCompanyModules,
                  message: l.accessModuleScopeNote,
                  icon: Icons.info_outline,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l.accessModulesReadOnly,
                  style: AppTypography.of(
                    context,
                  ).caption.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          );
        },
      );
}

String? _moduleDescription(AppLocalizations l, String moduleId) =>
    switch (moduleId) {
      'hr' => l.accessModuleHrDesc,
      'services' => l.accessModuleServicesDesc,
      _ => null,
    };

IconData _moduleIcon(String moduleId) => switch (moduleId) {
  'hr' => Icons.groups_outlined,
  'services' => Icons.handyman_outlined,
  'platform' => Icons.admin_panel_settings_outlined,
  _ => Icons.widgets_outlined,
};
