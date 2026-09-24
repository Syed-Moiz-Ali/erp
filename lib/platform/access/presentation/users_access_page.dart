import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/security/permission_catalog.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/user_permission_grant.dart';
import 'package:modular_erp/platform/access/presentation/access_localization.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

/// Users & Access: find company users and manage their ERP access.
class UsersAccessPage extends StatefulWidget {
  const UsersAccessPage({
    super.key,
    required this.repository,
    required this.catalog,
  });
  final AccessRepository repository;
  final PermissionCatalog catalog;

  @override
  State<UsersAccessPage> createState() => _UsersAccessPageState();
}

class _UsersAccessPageState extends State<UsersAccessPage> {
  final _search = TextEditingController();
  bool _activeOnly = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Set<String> _businessModules(
    List<UserPermissionGrant> grants,
    String userId,
  ) => {
    for (final grant in grants)
      if (grant.userId == userId)
        if (widget.catalog.byKey(grant.permissionKey) case final definition?)
          if (definition.moduleId != 'platform') definition.moduleId,
  };

  @override
  Widget build(
    BuildContext context,
  ) => BlocSelector<AuthBloc, AuthState, AuthContext?>(
    selector: (state) => state.context,
    builder: (context, account) {
      if (account == null) return const SizedBox.shrink();
      final l = context.l10n;
      return StreamBuilder<List<AccessUserListItem>>(
        stream: widget.repository.watchUsers(companyId: account.company.id),
        builder: (context, usersSnapshot) =>
            StreamBuilder<List<UserPermissionGrant>>(
              stream: widget.repository.watchCompanyGrants(
                companyId: account.company.id,
              ),
              builder: (context, grantsSnapshot) {
                final users =
                    usersSnapshot.data ?? const <AccessUserListItem>[];
                final grants =
                    grantsSnapshot.data ?? const <UserPermissionGrant>[];
                final query = _search.text.trim().toLowerCase();
                final filtered = users.where((user) {
                  if (_activeOnly && !user.isEmployeeActive) return false;
                  if (query.isEmpty) return true;
                  return user.displayName.toLowerCase().contains(query) ||
                      user.email.toLowerCase().contains(query) ||
                      (user.employeeCode ?? '').toLowerCase().contains(query);
                }).toList();
                final withAccess = filtered
                    .where(
                      (user) =>
                          _businessModules(grants, user.userId).isNotEmpty,
                    )
                    .length;
                return AppPage(
                  header: AppPageHeader(
                    title: l.usersAccessTitle,
                    subtitle: l.usersAccessSubtitle,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: 320,
                            child: AppSearchField(
                              controller: _search,
                              hint: l.accessSearchUsers,
                              onChanged: (_) => setState(() {}),
                              onClear: () => setState(() => _search.clear()),
                            ),
                          ),
                          ChoiceChip(
                            label: Text(l.accessFilterAll),
                            selected: !_activeOnly,
                            onSelected: (_) =>
                                setState(() => _activeOnly = false),
                          ),
                          ChoiceChip(
                            label: Text(l.accessStatusActive),
                            selected: _activeOnly,
                            onSelected: (_) =>
                                setState(() => _activeOnly = true),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(l.accessUsersSummary(filtered.length, withAccess)),
                      const SizedBox(height: AppSpacing.lg),
                      if (filtered.isEmpty)
                        AppEmptyState(
                          title: l.noRecords,
                          message: l.accessNoBusinessAccess,
                        )
                      else if (AppBreakpoints.of(context) == AppSize.compact)
                        Column(
                          children: [
                            for (final user in filtered)
                              _UserCard(
                                user: user,
                                modules: _businessModules(grants, user.userId),
                              ),
                          ],
                        )
                      else
                        AppDataTable(
                          columns: [
                            DataColumn(label: Text(l.accessEmployee)),
                            DataColumn(label: Text(l.empCode)),
                            DataColumn(label: Text(l.accessLogin)),
                            DataColumn(label: Text(l.accessCompanyModules)),
                            DataColumn(label: Text(l.status)),
                            DataColumn(label: Text(l.actions)),
                          ],
                          rows: [
                            for (final user in filtered)
                              DataRow(
                                cells: [
                                  DataCell(_UserIdentity(user: user)),
                                  DataCell(
                                    user.employeeId == null
                                        ? AppStatusBadge(
                                            label: l.accessNotLinked,
                                            status: AppStatus.warning,
                                            isPill: true,
                                          )
                                        : user.employeeCode != null
                                        ? Text(user.employeeCode!)
                                        : AppStatusBadge(
                                            label: l.accessLinkedEmployee,
                                            status: AppStatus.success,
                                            isPill: true,
                                          ),
                                  ),
                                  DataCell(
                                    AppStatusBadge(
                                      label: user.hasLogin
                                          ? user.email
                                          : l.accessNoLogin,
                                      status: user.hasLogin
                                          ? AppStatus.info
                                          : AppStatus.neutral,
                                      isPill: true,
                                    ),
                                  ),
                                  DataCell(
                                    _ModuleChips(
                                      modules: _businessModules(
                                        grants,
                                        user.userId,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    AppStatusBadge(
                                      label: user.isEmployeeActive
                                          ? l.accessStatusActive
                                          : l.accessStatusInactive,
                                      status: user.isEmployeeActive
                                          ? AppStatus.success
                                          : AppStatus.neutral,
                                      isPill: true,
                                    ),
                                  ),
                                  DataCell(
                                    AppSecondaryButton(
                                      label: l.accessManage,
                                      onPressed: () => context.go(
                                        AppRoutes.accessUser(user.userId),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
      );
    },
  );
}

class _UserIdentity extends StatelessWidget {
  const _UserIdentity({required this.user});
  final AccessUserListItem user;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 16,
        child: Text(
          user.displayName.isNotEmpty
              ? user.displayName.characters.first.toUpperCase()
              : '?',
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(user.displayName, overflow: TextOverflow.ellipsis),
            Text(user.email, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    ],
  );
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.modules});
  final AccessUserListItem user;
  final Set<String> modules;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final modulesText = modules.isEmpty
        ? l.accessNoAccessAssigned
        : modules.map(l.moduleLabel).join(' + ');
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
      child: AppMobileRecordCard(
        leading: CircleAvatar(
          child: Text(
            user.displayName.isNotEmpty
                ? user.displayName.characters.first.toUpperCase()
                : '?',
          ),
        ),
        title: user.displayName,
        subtitle: user.employeeCode ?? user.email,
        tertiary: user.hasLogin ? user.email : l.accessNoLogin,
        status: user.isEmployeeActive ? AppStatus.success : AppStatus.neutral,
        statusLabel: user.isEmployeeActive
            ? l.accessStatusActive
            : l.accessStatusInactive,
        trailing: AppSecondaryButton(
          label: l.accessManage,
          onPressed: () => context.go(AppRoutes.accessUser(user.userId)),
        ),
        metrics: [
          (label: l.accessCompanyModules, value: modulesText),
          (
            label: l.accessEmployee,
            value: user.employeeId == null
                ? l.accessNotLinked
                : (user.employeeCode ?? l.accessLinkedEmployee),
          ),
        ],
      ),
    );
  }
}

class _ModuleChips extends StatelessWidget {
  const _ModuleChips({required this.modules});
  final Set<String> modules;
  @override
  Widget build(BuildContext context) => modules.isEmpty
      ? Text(context.l10n.accessNoAccessAssigned)
      : Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final module in modules)
              AppStatusBadge(
                label: context.l10n.moduleLabel(module),
                status: AppStatus.brand,
                isPill: true,
              ),
          ],
        );
}
