import '../../../features/employees/domain/employee_access.dart';
import '../../../features/employees/domain/employee.dart';
import '../../../features/auth/domain/entities/auth_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/auth_localization.dart';
import '../../../core/localization/app_formatters.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../router/app_routes.dart';

class ProfilePlaceholderPage extends StatelessWidget {
  const ProfilePlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocSelector<AuthBloc, AuthState, AuthContext?>(
        selector: (state) => state.context,
        builder: (context, account) {
          if (account == null) return const SizedBox.shrink();
          return AppPage(
            maxWidth: AppDimensions.details,
            header: AppPageHeader(
              title: context.l10n.shellProfile,
              subtitle: context.l10n.shellProfileDescription,
              actions: [
                if (account.employeeReference != null &&
                    const EmployeeScopeResolver().resolve(account) !=
                        EmployeeScope.none)
                  AppSecondaryButton(
                    label: context.l10n.empSelfProfile,
                    onPressed: () => context.go(
                      AppRoutes.employeeDetails(account.employeeReference!.id),
                    ),
                  ),
                AppSecondaryButton(
                  label: context.l10n.authChangePassword,
                  onPressed: () => context.go(AppRoutes.changePassword),
                ),
              ],
            ),
            child: AppDetailsSection(
              title: context.l10n.authAccount,
              details: {
                context.l10n.fullName: account.user.displayName,
                context.l10n.email: account.user.email,
                context.l10n.authCompany: account.company.name,
                context.l10n.authRole: account.user.role.label(context.l10n),
                context.l10n.authAccountStatus: account.user.status.label(
                  context.l10n,
                ),
                context.l10n.authPermissions: context.l10n.authPermissionCount(
                  AppNumberFormatter(
                    Localizations.localeOf(context),
                  ).integer(account.user.permissions.length),
                ),
              },
            ),
          );
        },
      );
}
