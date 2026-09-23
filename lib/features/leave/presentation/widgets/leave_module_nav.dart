import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/security/app_permission.dart';
import '../../../../design_system/design_system.dart';
import '../../../../design_system/theme/app_breakpoints.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/domain/entities/auth_context.dart';
import '../../../auth/domain/policies/user_capability.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Leave is one primary module. This renders a proper secondary navigation
/// (underline tabs on desktop, a section switcher on mobile) for the
/// destinations the current capabilities allow. Routes remain the source of
/// truth; this is presentation only.
class LeaveModuleScaffold extends StatelessWidget {
  const LeaveModuleScaffold({super.key, required this.child, this.banner});
  final Widget child;
  final Widget? banner;

  List<(String, String)> _items(BuildContext context, AuthContext account) {
    final l = context.l10n;
    final capabilities = const UserCapabilityResolver().forAuthContext(account);
    final p = PermissionChecker(account.user.permissions);
    final balanceVisible =
        capabilities.has(UserCapability.viewMyLeaveBalance) ||
        p.canAny([
          AppPermission.leaveBalanceViewTeam,
          AppPermission.leaveBalanceViewAll,
        ]);
    return [
      (AppRoutes.leave, l.shellLeave),
      if (capabilities.has(UserCapability.viewMyLeave))
        (AppRoutes.leaveMyRequests, l.leaveMyRequests),
      if (capabilities.has(UserCapability.viewTeamLeave))
        (AppRoutes.leaveTeam, l.leaveTeam),
      if (capabilities.has(UserCapability.viewCompanyLeave))
        (AppRoutes.leaveAll, l.leaveAllNav),
      if (capabilities.has(UserCapability.approveTeamLeave) ||
          capabilities.has(UserCapability.approveCompanyLeave))
        (AppRoutes.leaveApprovals, l.leaveApprovals),
      if (balanceVisible) (AppRoutes.leaveBalances, l.leaveBalancesNav),
      (AppRoutes.leaveCalendar, l.leaveCalendarNav),
    ];
  }

  @override
  Widget build(BuildContext context) =>
      BlocSelector<AuthBloc, AuthState, AuthContext?>(
        selector: (state) => state.context,
        builder: (context, account) {
          if (account == null) return child;
          final items = _items(context, account);
          if (items.length <= 1) return _body();
          final path = GoRouterState.of(context).uri.path;
          final selected = _match(path, items);
          final compact = AppBreakpoints.of(context) == AppSize.compact;
          return Column(
            children: [
              compact
                  ? _SectionSwitcher(items: items, selected: selected)
                  : _TabBar(items: items, selected: selected),
              Expanded(child: _body()),
            ],
          );
        },
      );

  Widget _body() {
    final placeholder = banner;
    if (placeholder == null) return child;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.section,
            AppSpacing.md,
            AppSpacing.section,
            0,
          ),
          child: placeholder,
        ),
        Expanded(child: child),
      ],
    );
  }

  String _match(String path, List<(String, String)> items) {
    String? best;
    for (final (route, _) in items) {
      if (path == route || path.startsWith('$route/')) {
        if (best == null || route.length > best.length) best = route;
      }
    }
    return best ?? items.first.$1;
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.items, required this.selected});
  final List<(String, String)> items;
  final String selected;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (route, label) in items)
            _TabItem(
              label: label,
              selected: route == selected,
              onTap: () => context.go(route),
            ),
        ],
      ),
    ),
  );
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.of(context).body.copyWith(
              color: selected
                  ? AppColors.brandPrimary
                  : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: 24,
            color: selected ? AppColors.brandPrimary : Colors.transparent,
          ),
        ],
      ),
    ),
  );
}

class _SectionSwitcher extends StatelessWidget {
  const _SectionSwitcher({required this.items, required this.selected});
  final List<(String, String)> items;
  final String selected;
  @override
  Widget build(BuildContext context) {
    final label = items
        .firstWhere((item) => item.$1 == selected, orElse: () => items.first)
        .$2;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.of(
                context,
              ).body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          AppTextButton(
            label: context.l10n.leaveViewMode,
            icon: Icons.unfold_more,
            onPressed: () => _open(context),
          ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final route = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (path, label) in items)
              ListTile(
                title: Text(label),
                selected: path == selected,
                onTap: () => Navigator.of(sheetContext).pop(path),
              ),
          ],
        ),
      ),
    );
    if (route != null && context.mounted) context.go(route);
  }
}
