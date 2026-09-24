import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/security/permission_catalog.dart';
import 'package:modular_erp/core/security/permission_definition.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/access/application/user_access_cubit.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/grant_authority.dart';
import 'package:modular_erp/platform/access/presentation/access_localization.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

/// Access Detail: a permission editor grouped Module → Submodule → Action.
class UserAccessDetailPage extends StatelessWidget {
  const UserAccessDetailPage({
    super.key,
    required this.repository,
    required this.catalog,
    required this.authority,
    required this.userId,
  });
  final AccessRepository repository;
  final PermissionCatalog catalog;
  final GrantAuthorityResolver authority;
  final String userId;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<AuthBloc, AuthState, AuthContext?>(
        selector: (state) => state.context,
        builder: (context, account) {
          if (account == null) return const SizedBox.shrink();
          return BlocProvider(
            key: ValueKey('access-user-$userId'),
            create: (_) => UserAccessCubit(
              catalog: catalog,
              repository: repository,
              authority: authority,
              actor: account,
              userId: userId,
            )..start(),
            child: const _UserAccessBody(),
          );
        },
      );
}

enum _ModuleAction { grantView, grantFull, clear }

class _UserAccessBody extends StatelessWidget {
  const _UserAccessBody();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cubit = context.read<UserAccessCubit>();
    return BlocConsumer<UserAccessCubit, UserAccessState>(
      listenWhen: (previous, current) =>
          (current.saved && !previous.saved) ||
          (current.failureCode != null &&
              current.failureCode != previous.failureCode),
      listener: (context, state) {
        if (state.failureCode != null) {
          AppFeedback.showMessage(
            context,
            message: (l) => _failureMessage(l, state.failureCode!),
          );
        } else if (state.saved) {
          AppFeedback.showMessage(context, message: (l) => l.accessSaved);
        }
      },
      builder: (context, state) {
        final user = state.user;
        return AppPage(
          header: AppPageHeader(
            title: user?.displayName ?? l.usersAccessTitle,
            subtitle: user == null
                ? l.usersAccessSubtitle
                : [
                    if (user.employeeCode != null) user.employeeCode!,
                    if (user.designationName != null) user.designationName!,
                    if (user.departmentName != null) user.departmentName!,
                  ].join(' · '),
            actions: [
              if (cubit.canManage) ...[
                AppSecondaryButton(
                  label: l.accessResetChanges,
                  onPressed: state.dirty && !state.saving ? cubit.reset : null,
                ),
                AppPrimaryButton(
                  label: l.accessSaveChanges,
                  loading: state.saving,
                  onPressed: state.dirty && !state.saving
                      ? () => _confirmSave(context, cubit)
                      : null,
                ),
              ],
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _UserHeader(state: state),
              const SizedBox(height: AppSpacing.lg),
              _Summary(state: state),
              const SizedBox(height: AppSpacing.lg),
              AppInfoCard(
                title: l.accessScopeLabel,
                message: l.accessScopeHint,
                icon: Icons.info_outline,
              ),
              if (!state.hasEmployeeLink) ...[
                const SizedBox(height: AppSpacing.lg),
                AppInfoCard(
                  title: l.accessNoLinkedEmployeeTitle,
                  message: l.accessLinkEmployeeHint,
                  icon: Icons.link_off,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              for (final module in cubit.catalog.orderedModules)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: AppSpacing.lg,
                  ),
                  child: _ModuleCard(module: module),
                ),
              _History(history: state.history),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmSave(BuildContext context, UserAccessCubit cubit) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: (l) => l.accessConfirmTitle,
      message: (l) => l.accessConfirmMessage,
      confirmLabel: (l) => l.accessSaveChanges,
    );
    if (confirmed) await cubit.save();
  }
}

String _failureMessage(AppLocalizations l, String code) => switch (code) {
  'access.selfEscalation' => l.accessSelfEscalation,
  'access.lastAdmin' => l.accessLastAdmin,
  'access.employeeLinkRequired' => l.accessEmployeeLinkRequired,
  'access.moduleDisabled' => l.accessModuleDisabled,
  'access.platformOnly' || 'access.notDelegable' => l.accessPlatformOnly,
  'access.notPermitted' => l.accessNotPermitted,
  _ => l.accessSaveFailed,
};

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.state});
  final UserAccessState state;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final user = state.user;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            child: Text(
              (user?.displayName.isNotEmpty ?? false)
                  ? user!.displayName.characters.first.toUpperCase()
                  : '?',
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.displayName ?? l.usersAccessTitle),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppStatusBadge(
                      label: user?.hasLogin ?? false
                          ? (user?.email ?? '')
                          : l.accessNoLogin,
                      status: (user?.hasLogin ?? false)
                          ? AppStatus.info
                          : AppStatus.neutral,
                      isPill: true,
                    ),
                    AppStatusBadge(
                      label: (user?.isEmployeeActive ?? false)
                          ? l.accessStatusActive
                          : l.accessStatusInactive,
                      status: (user?.isEmployeeActive ?? false)
                          ? AppStatus.success
                          : AppStatus.neutral,
                      isPill: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.state});
  final UserAccessState state;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cubit = context.read<UserAccessCubit>();
    final stats = [
      for (final module in cubit.catalog.orderedModules)
        (
          module: module,
          granted: module.definitions
              .where((d) => state.draft.any((grant) => grant.key == d.key))
              .length,
          total: module.definitions.length,
        ),
    ];
    final activeModules = stats.where((s) => s.granted > 0).length;
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.accessSummary, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          Builder(
            builder: (context) {
              final tiles = <Widget>[
                _SummaryStat(
                  icon: Icons.key_outlined,
                  label: l.accessGrantedPermissions,
                  value: state.draft.length,
                ),
                _SummaryStat(
                  icon: Icons.widgets_outlined,
                  label: l.accessModuleAccess,
                  value: activeModules,
                ),
                _SummaryStat(
                  icon: Icons.badge_outlined,
                  label: state.hasEmployeeLink
                      ? l.accessLinkedEmployee
                      : l.accessNoLinkedEmployeeTitle,
                  status: state.hasEmployeeLink
                      ? AppStatus.success
                      : AppStatus.warning,
                ),
              ];
              if (AppBreakpoints.of(context) == AppSize.compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final tile in tiles)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          bottom: AppSpacing.md,
                        ),
                        child: tile,
                      ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (final tile in tiles) Expanded(child: tile)],
              );
            },
          ),
          if (stats.any((s) => s.granted > 0)) ...[
            const Divider(height: AppSpacing.xxl),
            for (final stat in stats)
              if (stat.granted > 0)
                _ModuleProgress(
                  label: l.moduleLabel(stat.module.nameKey),
                  granted: stat.granted,
                  total: stat.total,
                ),
          ],
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.icon,
    required this.label,
    this.value,
    this.status,
  });
  final IconData icon;
  final String label;
  final int? value;
  final AppStatus? status;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueText = value == null ? null : '$value';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (valueText != null) ...[
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(valueText, style: theme.textTheme.titleLarge),
              ] else
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: AppStatusBadge(
                      label: label,
                      status: status ?? AppStatus.neutral,
                      isPill: true,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModuleProgress extends StatelessWidget {
  const _ModuleProgress({
    required this.label,
    required this.granted,
    required this.total,
  });
  final String label;
  final int granted, total;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = '$granted / $total';
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(ratio, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          LinearProgressIndicator(
            value: total == 0 ? 0 : granted / total,
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});
  final PermissionModule module;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cubit = context.read<UserAccessCubit>();
    final granted = cubit.grantedCount(module.id);
    final hasAccess = granted > 0;
    final statusLabel = hasAccess
        ? l.accessHasAccess
        : l.accessNoAccessAssigned;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                _moduleIcon(module.id),
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.moduleLabel(module.nameKey)),
                    const SizedBox(height: AppSpacing.xs),
                    AppStatusBadge(
                      label: statusLabel,
                      status: hasAccess ? AppStatus.success : AppStatus.neutral,
                      isPill: true,
                    ),
                  ],
                ),
              ),
              if (cubit.canManage)
                PopupMenuButton<_ModuleAction>(
                  icon: const Icon(Icons.tune),
                  tooltip: l.accessModuleAccess,
                  onSelected: (action) {
                    switch (action) {
                      case _ModuleAction.grantView:
                        cubit.grantModule(module.id, full: false);
                      case _ModuleAction.grantFull:
                        _confirmFull(context, cubit, module);
                      case _ModuleAction.clear:
                        cubit.clearModule(module.id);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _ModuleAction.grantView,
                      child: Text(l.accessGrantView),
                    ),
                    PopupMenuItem(
                      value: _ModuleAction.grantFull,
                      child: Text(l.accessGrantFull),
                    ),
                    PopupMenuItem(
                      value: _ModuleAction.clear,
                      child: Text(l.accessClear),
                    ),
                  ],
                ),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          if (module.definitions.any((d) => d.requiresEmployeeLink) &&
              !cubit.state.hasEmployeeLink)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(l.accessSelfRequiresEmployee)),
                ],
              ),
            ),
          for (final submodule in module.submodules) ...[
            AppSectionHeader(title: l.submoduleLabel(submodule.id)),
            for (final definition in submodule.definitions)
              _PermissionRow(definition: definition),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmFull(
    BuildContext context,
    UserAccessCubit cubit,
    PermissionModule module,
  ) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: (l) => l.accessFullConfirmTitle,
      message: (l) => l.accessFullConfirmMessage,
      confirmLabel: (l) => l.accessGrantFull,
    );
    if (confirmed) cubit.grantModule(module.id, full: true);
  }
}

IconData _moduleIcon(String moduleId) => switch (moduleId) {
  'hr' => Icons.groups_outlined,
  'services' => Icons.handyman_outlined,
  'platform' => Icons.admin_panel_settings_outlined,
  _ => Icons.widgets_outlined,
};

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({required this.definition});
  final PermissionDefinition definition;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cubit = context.read<UserAccessCubit>();
    final decision = cubit.canGrant(definition);
    final current = cubit.state.grantFor(definition.key);
    final title = Text(l.permissionLabel(definition.nameKey));
    final subtitle = Text(l.permissionDescription(definition.descriptionKey));
    if (definition.supportedScopes.length == 1 &&
        definition.supportedScopes.first == PermissionScope.none) {
      return SwitchListTile.adaptive(
        value: current != null,
        onChanged: decision.allowed
            ? (value) => cubit.toggleAction(definition, value)
            : null,
        title: title,
        subtitle: subtitle,
        contentPadding: EdgeInsets.zero,
        dense: true,
      );
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: AppSpacing.xs),
          subtitle,
          const SizedBox(height: AppSpacing.sm),
          if (decision.allowed) ...[
            Text(l.accessScopeLabel),
            const SizedBox(height: AppSpacing.xs),
            _ScopeSelector(
              definition: definition,
              current: current?.scope ?? PermissionScope.none,
              onChanged: (scope) => cubit.setScope(definition, scope),
            ),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 16),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(_deniedReason(l, decision.reason))),
              ],
            ),
        ],
      ),
    );
  }
}

class _ScopeSelector extends StatelessWidget {
  const _ScopeSelector({
    required this.definition,
    required this.current,
    required this.onChanged,
  });
  final PermissionDefinition definition;
  final PermissionScope current;
  final ValueChanged<PermissionScope> onChanged;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scopes = [
      PermissionScope.none,
      ...definition.supportedScopes.where((s) => s != PermissionScope.none),
    ];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final scope in scopes)
          ChoiceChip(
            label: Text(l.scopeLabel(scope.name)),
            selected: scope == current,
            onSelected: (_) => onChanged(scope),
          ),
      ],
    );
  }
}

String _deniedReason(AppLocalizations l, AccessDecisionReason? reason) =>
    switch (reason) {
      AccessDecisionReason.employeeLinkRequired => l.accessEmployeeLinkRequired,
      AccessDecisionReason.moduleDisabled => l.accessModuleDisabled,
      AccessDecisionReason.platformOnly ||
      AccessDecisionReason.notDelegable => l.accessPlatformOnly,
      _ => l.accessNotPermitted,
    };

class _History extends StatelessWidget {
  const _History({required this.history});
  final List history;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (history.isEmpty) {
      return AppSettingsSection(
        title: l.accessHistory,
        children: [Text(l.accessNoHistory)],
      );
    }
    final catalog = context.read<UserAccessCubit>().catalog;
    return AppSettingsSection(
      title: l.accessHistory,
      children: [
        for (final event in history.take(20))
          Builder(
            builder: (context) {
              final metadata = event.metadata as Map<String, Object?>;
              final key = metadata['permissionKey'] as String?;
              final definition = key == null ? null : catalog.byKey(key);
              final action = (event.eventType as String).split('.').last;
              final label = switch (action) {
                'added' => l.accessAdded,
                'removed' => l.accessRemoved,
                _ => l.accessChanged,
              };
              final scopeText = [
                if (metadata['oldScope'] != null)
                  l.scopeLabel(metadata['oldScope'] as String),
                if (metadata['newScope'] != null)
                  l.scopeLabel(metadata['newScope'] as String),
              ].join(' → ');
              return ListTile(
                dense: true,
                leading: AppStatusBadge(label: label, isPill: true),
                title: Text(
                  definition == null
                      ? (key ?? '')
                      : l.permissionLabel(definition.nameKey),
                ),
                subtitle: Text(
                  scopeText.isEmpty
                      ? event.occurredAt.toIso8601String()
                      : scopeText,
                ),
              );
            },
          ),
      ],
    );
  }
}
