import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/user_capability.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

/// Attendance is one primary module; this renders its internal sub-navigation
/// (only the destinations the current capabilities allow) above the active
/// attendance screen. Presentation only — routes remain the source of truth.
class AttendanceModuleScaffold extends StatelessWidget {
  const AttendanceModuleScaffold({super.key, required this.child, this.banner});
  final Widget child;
  final Widget? banner;

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

  @override
  Widget build(BuildContext context) =>
      BlocSelector<AuthBloc, AuthState, AuthContext?>(
        selector: (state) => state.context,
        builder: (context, account) {
          if (account == null) return child;
          final l = context.l10n;
          final capabilities = const UserCapabilityResolver().forAuthContext(
            account,
          );
          final items = <(String, String)>[
            if (capabilities.has(UserCapability.selfAttendance))
              (AppRoutes.attendance, l.attendanceTodayTitle),
            if (capabilities.has(UserCapability.selfAttendanceHistory))
              (AppRoutes.attendanceHistory, l.historyNav),
            if (capabilities.has(UserCapability.requestAttendanceCorrection))
              (AppRoutes.attendanceCorrections, l.correctionMyRequests),
            if (capabilities.has(UserCapability.teamAttendance))
              (AppRoutes.attendanceTeam, l.workforceTeam),
            if (capabilities.has(UserCapability.companyAttendance))
              (AppRoutes.attendanceAll, l.workforceAll),
            if (capabilities.has(UserCapability.approveAttendanceCorrections))
              (AppRoutes.attendanceRequests, l.correctionReviewQueue),
          ];
          if (items.length <= 1) return _body();
          final path = GoRouterState.of(context).uri.path;
          final selected = _match(path, items);
          final padding = AppBreakpoints.of(context) == AppSize.compact
              ? AppSpacing.lg
              : AppSpacing.section;
          return Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                padding: EdgeInsetsDirectional.fromSTEB(
                  padding,
                  AppSpacing.sm,
                  padding,
                  AppSpacing.sm,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final (route, label) in items)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            end: AppSpacing.sm,
                          ),
                          child: AppFilterChip(
                            label: label,
                            selected: route == selected,
                            onSelected: (_) => context.go(route),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(child: _body()),
            ],
          );
        },
      );

  /// Picks the longest route that owns [path] so nested detail routes keep the
  /// correct sub-navigation item selected.
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
