import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_catalog.dart';
import 'package:modular_erp/core/security/permission_definition.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/access/application/user_access_cubit.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/grant_authority.dart';
import 'package:modular_erp/platform/access/domain/user_permission_grant.dart';
import 'package:modular_erp/platform/access/presentation/access_localization.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

/// Access Detail: a permission editor grouped Module â†’ Submodule â†’ Action.
///
/// Presentation only: [UserAccessCubit] still owns the catalog, the draft and
/// the save/validation flow. This screen renders that resolved state through the
/// UI-7 specialized primitives so it reads as a business access interface rather
/// than a developer enum inspector.
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
            create: (blocContext) => UserAccessCubit(
              catalog: catalog,
              repository: repository,
              authority: authority,
              actor: account,
              userId: userId,
              onCurrentUserAccessChanged: userId == account.user.id
                  ? () async {
                      final auth = blocContext.read<AuthBloc>();
                      if (!auth.isClosed) {
                        auth.add(const AuthPermissionsReloadRequested());
                      }
                    }
                  : null,
            )..start(),
            child: const _UserAccessBody(),
          );
        },
      );
}

enum _ModuleAction { grantView, grantFull, clear }

class _UserAccessBody extends StatefulWidget {
  const _UserAccessBody();

  @override
  State<_UserAccessBody> createState() => _UserAccessBodyState();
}

class _UserAccessBodyState extends State<_UserAccessBody> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

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
        final company = context.watch<AuthBloc>().state.context?.company.name;
        final user = state.user;
        final compact = AppBreakpoints.of(context) == AppSize.compact;
        final scopeNote = '${l.accessScopeHint} ${l.accessActionScopeNote}';

        final body = AppPage(
          header: AppDetailHeader(
            title: user?.displayName ?? l.usersAccessTitle,
            description: user == null
                ? l.usersAccessSubtitle
                : (user.hasLogin ? user.email : l.accessNoLogin),
            leading: user == null
                ? null
                : AppAvatar(name: user.displayName, radius: 24),
            status: AppDetailStatus(
              label: (user?.isEmployeeActive ?? false)
                  ? l.accessStatusActive
                  : l.accessStatusInactive,
              status: (user?.isEmployeeActive ?? false)
                  ? AppStatus.success
                  : AppStatus.neutral,
              showDot: true,
            ),
            metadata: [
              if (company != null && company.isNotEmpty)
                AppMetadataItem(
                  label: l.accessCompany,
                  value: company,
                  icon: Icons.business_outlined,
                ),
              AppMetadataItem(
                label: l.accessEmployee,
                value: user?.employeeId == null
                    ? l.accessNotLinked
                    : (user?.employeeCode ?? l.accessLinkedEmployee),
                icon: user?.employeeId == null
                    ? Icons.link_off
                    : Icons.badge_outlined,
              ),
            ],
            primaryAction: cubit.canManage
                ? AppPrimaryButton(
                    label: l.accessSaveChanges,
                    loading: state.saving,
                    onPressed: state.dirty && !state.saving
                        ? () => _confirmSave(context, cubit)
                        : null,
                  )
                : null,
            secondaryActions: [
              if (cubit.canManage)
                AppSecondaryButton(
                  label: l.accessAddPermissions,
                  onPressed: state.saving
                      ? null
                      : () => _addPermissions(context, cubit),
                ),
              if (cubit.canManage)
                AppSecondaryButton(
                  label: l.accessResetChanges,
                  onPressed: state.dirty && !state.saving ? cubit.reset : null,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppAccessSummary(
                title: l.accessSummary,
                metrics: _summaryMetrics(context, state, cubit),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppInfoCard(
                title: l.accessScopeLabel,
                message: '$scopeNote ${l.accessReplaceAllHint}',
                icon: Icons.info_outline,
              ),
              if (state.orphans.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l.accessOrphanHint,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final orphan in state.orphans)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l.accessOrphanGrant(
                                  orphan.orphanPermissionId?.toString() ??
                                      orphan.id,
                                ),
                              ),
                            ),
                            AppTextButton(
                              label: l.accessRevoke,
                              onPressed: state.saving
                                  ? null
                                  : () => cubit.revokeOrphan(orphan),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
              if (!state.hasEmployeeLink) ...[
                const SizedBox(height: AppSpacing.lg),
                AppInfoCard(
                  title: l.accessNoLinkedEmployeeTitle,
                  message: l.accessLinkEmployeeHint,
                  icon: Icons.link_off,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppSearchField(
                controller: _search,
                label: l.accessPermissionSearch,
                hint: l.accessPermissionSearch,
                onChanged: (value) => setState(() => _query = value),
                onClear: () => setState(() {
                  _query = '';
                  _search.clear();
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppPermissionMatrix(
                groups: [
                  for (final module in cubit.catalog.orderedModules)
                    if (module.definitions.isNotEmpty)
                      AppPermissionGroupPresentation(
                        id: module.id,
                        title: l.moduleLabel(module.nameKey),
                        dirtyCount: _dirtyCount(state, cubit, module.id),
                        trailing: cubit.canManage
                            ? _ModuleQuickActions(module: module)
                            : null,
                        subgroups: [
                          for (final submodule in module.submodules)
                            if (submodule.definitions.isNotEmpty)
                              AppPermissionSubgroupPresentation(
                                title: l.submoduleLabel(submodule.id),
                                rows: [
                                  for (final definition
                                      in submodule.definitions)
                                    _rowFor(context, state, cubit, definition),
                                ],
                              ),
                        ],
                      ),
                ],
                searchQuery: _query,
                emptyMessage: l.accessNoPermissionMatch,
                dense: compact,
              ),
              const SizedBox(height: AppSpacing.xxl),
              _History(history: state.history),
            ],
          ),
        );

        return PopScope(
          canPop: !state.dirty,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop || !state.dirty) return;
            final leave = await AppConfirmationDialog.show(
              context,
              title: (l) => l.accessUnsavedTitle,
              message: (l) => l.accessUnsavedMessage,
              confirmLabel: (l) => l.accessLeave,
              cancelLabel: (l) => l.accessStay,
              destructive: true,
            );
            if (leave && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: body,
        );
      },
    );
  }

  List<AppSummaryMetric> _summaryMetrics(
    BuildContext context,
    UserAccessState state,
    UserAccessCubit cubit,
  ) {
    final l = context.l10n;
    final activeModules = cubit.catalog.orderedModules
        .where(
          (module) => module.definitions.any(
            (definition) =>
                state.grantFor(definition.key) != null ||
                _isIncluded(state, cubit, definition),
          ),
        )
        .length;
    return [
      AppSummaryMetric(
        label: l.accessGrantedPermissions,
        value: state.draft.length.toString(),
        icon: Icons.key_outlined,
      ),
      AppSummaryMetric(
        label: l.accessModuleAccess,
        value: activeModules.toString(),
        icon: Icons.widgets_outlined,
      ),
      AppSummaryMetric(
        label: state.hasEmployeeLink
            ? l.accessLinkedEmployee
            : l.accessNoLinkedEmployeeTitle,
        value: state.hasEmployeeLink
            ? (state.user?.employeeCode ?? l.accessLinkedEmployee)
            : l.accessNotLinked,
        icon: Icons.badge_outlined,
        status: state.hasEmployeeLink ? AppStatus.success : AppStatus.warning,
      ),
    ];
  }

  int _dirtyCount(
    UserAccessState state,
    UserAccessCubit cubit,
    String moduleId,
  ) => state.draft.where((grant) {
    if (cubit.catalog.byKey(grant.key)?.moduleId != moduleId) return false;
    final saved = state.grants.where((g) => g.key == grant.key).firstOrNull;
    return saved != grant;
  }).length;

  AppPermissionRowPresentation _rowFor(
    BuildContext context,
    UserAccessState state,
    UserAccessCubit cubit,
    PermissionDefinition definition,
  ) {
    final l = context.l10n;
    final decision = cubit.canGrant(definition);
    final current = state.grantFor(definition.key);
    final actionOnly =
        definition.supportedScopes.length == 1 &&
        definition.supportedScopes.first == PermissionScope.none;
    final scopes = [
      for (final scope in definition.supportedScopes)
        if (scope != PermissionScope.none) scope,
    ];
    final included = _isIncluded(state, cubit, definition);
    final canToggle = cubit.canManage && decision.allowed && !included;
    final enabled = current != null || included;
    final linkRequired =
        definition.requiresEmployeeLink && !state.hasEmployeeLink;
    final defaultScope = scopes.isNotEmpty
        ? scopes.first
        : PermissionScope.self;
    return AppPermissionRowPresentation(
      label: l.permissionLabel(definition.nameKey),
      description: l.permissionDescription(definition.descriptionKey),
      enabled: enabled,
      canToggle: canToggle,
      onToggle: canToggle
          ? (value) {
              if (actionOnly) {
                cubit.toggleAction(definition, value);
              } else {
                cubit.setScope(
                  definition,
                  value
                      ? (current?.scope ?? defaultScope)
                      : PermissionScope.none,
                );
              }
            }
          : null,
      scopeLabel: l.accessScopeLabel,
      scopeOptions: [
        for (final scope in scopes)
          AppScopeOption(value: scope.name, label: l.scopeLabel(scope.name)),
      ],
      scopeValue:
          current?.scope.name ?? (scopes.isNotEmpty ? scopes.first.name : null),
      onScopeChanged: canToggle && !actionOnly
          ? (name) =>
                cubit.setScope(definition, PermissionScope.values.byName(name))
          : null,
      badgeLabel: included ? l.accessIncluded : null,
      badgeStatus: AppStatus.info,
      requirementMessage:
          linkRequired &&
              decision.reason != AccessDecisionReason.employeeLinkRequired
          ? l.accessEmployeeLinkRequired
          : null,
      deniedReason: decision.allowed || included
          ? null
          : _deniedReason(l, decision.reason),
    );
  }

  Future<void> _addPermissions(
    BuildContext context,
    UserAccessCubit cubit,
  ) async {
    final existing = cubit.state.draft.map((grant) => grant.key).toSet();
    final selected = <String>{};
    final result = await AppDialog.show<List<PermissionGrantInput>>(
      context,
      (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final l = dialogContext.l10n;
          PermissionScope scopeFor(PermissionDefinition definition) {
            final scopes = definition.supportedScopes;
            if (scopes.contains(PermissionScope.all)) return PermissionScope.all;
            if (scopes.contains(PermissionScope.team)) {
              return PermissionScope.team;
            }
            if (scopes.contains(PermissionScope.assigned)) {
              return PermissionScope.assigned;
            }
            if (scopes.contains(PermissionScope.self)) return PermissionScope.self;
            return PermissionScope.none;
          }

          return AppDialog(
            title: l.accessAddPermissions,
            actions: [
              AppTextButton(
                label: l.cancel,
                onPressed: () => Navigator.pop(dialogContext),
              ),
              AppPrimaryButton(
                label: l.accessAddPermissions,
                onPressed: selected.isEmpty
                    ? null
                    : () => Navigator.pop(
                        dialogContext,
                        [
                          for (final definition in cubit.catalog.definitions)
                            if (selected.contains(definition.key))
                              PermissionGrantInput(
                                key: definition.key,
                                scope: scopeFor(definition),
                              ),
                        ],
                      ),
              ),
            ],
            child: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.accessAddPermissionsHint),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 360,
                    child: ListView(
                      children: [
                          for (final module in cubit.catalog.orderedModules)
                            if (module.definitions
                                .where(
                                  (definition) =>
                                      !existing.contains(definition.key) &&
                                      cubit
                                          .canGrant(definition)
                                          .allowed,
                                )
                                .isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.md,
                                  bottom: AppSpacing.xs,
                                ),
                                child: Text(
                                  l.moduleLabel(module.nameKey),
                                  style: Theme.of(dialogContext)
                                      .textTheme
                                      .titleSmall,
                                ),
                              ),
                              for (final definition in module.definitions)
                                if (!existing.contains(definition.key) &&
                                    cubit.canGrant(definition).allowed)
                                  CheckboxListTile(
                                    value: selected.contains(definition.key),
                                    onChanged: (value) => setState(() {
                                      if (value == true) {
                                        selected.add(definition.key);
                                      } else {
                                        selected.remove(definition.key);
                                      }
                                    }),
                                    title: Text(
                                      l.permissionLabel(definition.nameKey),
                                    ),
                                    subtitle: Text(
                                      l.permissionDescription(
                                        definition.descriptionKey,
                                      ),
                                    ),
                                    dense: true,
                                  ),
                            ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (result != null && result.isNotEmpty) {
      await cubit.assignAdditive(result);
    }
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

/// A View permission whose structural Manage counterpart is granted renders as
/// "included": runtime normalization (`permissionViewDependencies`) already
/// derives it, so the editor must not present it as an independent grant.
bool _isIncluded(
  UserAccessState state,
  UserAccessCubit cubit,
  PermissionDefinition definition,
) {
  for (final entry in permissionViewDependencies.entries) {
    if (!definition.permissions.containsValue(entry.value)) continue;
    for (final candidate in cubit.catalog.definitions) {
      if (candidate.permissions.containsValue(entry.key)) {
        return state.grantFor(candidate.key) != null;
      }
    }
  }
  return false;
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

String _deniedReason(AppLocalizations l, AccessDecisionReason? reason) =>
    switch (reason) {
      AccessDecisionReason.employeeLinkRequired => l.accessEmployeeLinkRequired,
      AccessDecisionReason.moduleDisabled => l.accessModuleDisabled,
      AccessDecisionReason.platformOnly ||
      AccessDecisionReason.notDelegable => l.accessPlatformOnly,
      _ => l.accessNotPermitted,
    };

class _ModuleQuickActions extends StatelessWidget {
  const _ModuleQuickActions({required this.module});
  final PermissionModule module;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cubit = context.read<UserAccessCubit>();
    return PopupMenuButton<_ModuleAction>(
      icon: const Icon(Icons.tune),
      tooltip: l.accessModuleAccess,
      onSelected: (action) {
        switch (action) {
          case _ModuleAction.grantView:
            cubit.grantModule(module.id, full: false);
          case _ModuleAction.grantFull:
            _confirmFull(context, cubit);
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
        PopupMenuItem(value: _ModuleAction.clear, child: Text(l.accessClear)),
      ],
    );
  }

  Future<void> _confirmFull(BuildContext context, UserAccessCubit cubit) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: (l) => l.accessFullConfirmTitle,
      message: (l) => l.accessFullConfirmMessage,
      confirmLabel: (l) => l.accessGrantFull,
    );
    if (confirmed) cubit.grantModule(module.id, full: true);
  }
}

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
    final formatter = AppDateFormatter(Localizations.localeOf(context));
    return AppSettingsSection(
      title: l.accessHistory,
      children: [
        AppTimeline(
          items: [
            for (final event in history.take(20))
              _item(l, catalog, formatter, event),
          ],
        ),
      ],
    );
  }

  AppTimelineItem _item(
    AppLocalizations l,
    PermissionCatalog catalog,
    AppDateFormatter formatter,
    dynamic event,
  ) {
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
    ].join(' â†’ ');
    return AppTimelineItem(
      id: event.id as String,
      title: definition == null
          ? (key ?? label)
          : l.permissionLabel(definition.nameKey),
      time: formatter.relative(event.occurredAt as DateTime, l),
      icon: switch (action) {
        'added' => Icons.add_circle_outline,
        'removed' => Icons.remove_circle_outline,
        _ => Icons.edit_outlined,
      },
      status: switch (action) {
        'added' => AppStatus.success,
        'removed' => AppStatus.danger,
        _ => AppStatus.info,
      },
      detail: scopeText.isEmpty ? null : scopeText,
      trailing: AppStatusBadge(label: label, isPill: true),
    );
  }
}


