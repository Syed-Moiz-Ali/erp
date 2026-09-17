import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';
import '../../../../core/errors/failure_localization.dart';
import '../../../../core/localization/app_formatters.dart';
import '../../../../l10n/l10n.dart';
import '../auth_localization.dart';
import '../bloc/auth_bloc.dart';

class AuthenticatedHomePlaceholder extends StatelessWidget {
  const AuthenticatedHomePlaceholder({
    super.key,
    this.showPermissionViewer = false,
  });
  final bool showPermissionViewer;
  @override
  Widget build(BuildContext context) => BlocBuilder<AuthBloc, AuthState>(
    builder: (context, state) {
      final account = state.context;
      if (account == null) return const SizedBox.shrink();
      return Scaffold(
        body: SafeArea(
          child: AppPage(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: AppSpacing.lg,
                      runSpacing: AppSpacing.lg,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: const [
                        AppProductIdentity(),
                        AppLanguageSelector(),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.wide),
                    AppPageHeader(
                      title: context.l10n.authGreeting(
                        account.user.displayName,
                      ),
                      subtitle: context.l10n.authHomeSubtitle,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppDetailsSection(
                      title: context.l10n.authAccount,
                      details: {
                        context.l10n.fullName: account.user.displayName,
                        context.l10n.email: account.user.email,
                        context.l10n.authCompany: account.company.name,
                        context.l10n.authRole: account.user.role.label(
                          context.l10n,
                        ),
                        context.l10n.authAccountStatus: account.user.status
                            .label(context.l10n),
                        context.l10n.authPermissions: context.l10n
                            .authPermissionCount(
                              AppNumberFormatter(
                                Localizations.localeOf(context),
                              ).integer(account.user.permissions.length),
                            ),
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    if (state.failure != null) ...[
                      AppAlert(
                        message: state.failure!.localizedMessage(context.l10n),
                        status: AppStatus.danger,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: [
                        AppSecondaryButton(
                          label: context.l10n.authChangePassword,
                          onPressed: state.loggingOut
                              ? null
                              : () => context.go('/app/change-password'),
                        ),
                        if (showPermissionViewer)
                          AppTextButton(
                            label: context.l10n.authPermissionViewer,
                            onPressed: state.loggingOut
                                ? null
                                : () => AppDialog.show<void>(
                                    context,
                                    (dialogContext) => AppDialog(
                                      title: dialogContext
                                          .l10n
                                          .authPermissionViewer,
                                      actions: [
                                        AppTextButton(
                                          label: dialogContext.l10n.close,
                                          onPressed: () =>
                                              Navigator.pop(dialogContext),
                                        ),
                                      ],
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (final permission
                                                in account
                                                    .user
                                                    .permissions
                                                    .values)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: AppSpacing.xs,
                                                    ),
                                                child: Text(
                                                  permission.label(
                                                    dialogContext.l10n,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        AppPrimaryButton(
                          label: context.l10n.logout,
                          loading: state.loggingOut,
                          onPressed: () async {
                            final bloc = context.read<AuthBloc>();
                            final confirmed = await AppConfirmationDialog.show(
                              context,
                              title: (l10n) => l10n.authConfirmLogout,
                              message: (l10n) => l10n.authLogoutMessage,
                              confirmLabel: (l10n) => l10n.logout,
                            );
                            if (confirmed && context.mounted && !bloc.isClosed) {
                              bloc.add(const AuthLogoutRequested());
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
