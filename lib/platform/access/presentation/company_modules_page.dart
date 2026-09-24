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
          // A module is enabled when at least one of its feature flags is part
          // of the company's enabled set (HR uses employees/attendance/leave/
          // reports/settings rather than a single `hr` flag).
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
                for (final module in modules)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: AppSpacing.md,
                    ),
                    child: Builder(
                      builder: (context) {
                        final isEnabled = moduleEnabled(module);
                        return AppSettingsRow(
                          title: l.moduleLabel(module.nameKey),
                          description: isEnabled
                              ? l.accessEnabled
                              : l.accessDisabled,
                          icon: isEnabled
                              ? Icons.check_circle_outline
                              : Icons.remove_circle_outline,
                          trailing: isEnabled
                              ? l.accessEnabled
                              : l.accessDisabled,
                          onPressed: () {},
                        );
                      },
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                Text(l.accessModulesReadOnly),
              ],
            ),
          );
        },
      );
}
