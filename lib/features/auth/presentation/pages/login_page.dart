import '../../../../app/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';
import '../../../../core/errors/failure_localization.dart';
import '../../../../core/validation/app_validation.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/demo_credential_info.dart';
import '../auth_localization.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.demoAccounts = const []});
  final List<DemoCredentialInfo> demoAccounts;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _identifier = TextEditingController(),
      _password = TextEditingController();
  final _identifierFocus = FocusNode(), _passwordFocus = FocusNode();
  void _submit() {
    if (context.read<AuthBloc>().state.status == AuthStatus.authenticating) {
      return;
    }
    if (_form.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(_identifier.text, _password.text),
      );
    }
  }

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    _identifierFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _showDemoAccountsDialog(BuildContext context) {
    AppDialog.show<void>(context, (dialogContext) {
      final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
      return AppDialog(
        title: dialogContext.l10n.authDemoAccounts,
        actions: [
          AppTextButton(
            label: dialogContext.l10n.close,
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                dialogContext.l10n.authDemoNotice,
                style: AppTypography.of(dialogContext).bodySmall.copyWith(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final account in widget.demoAccounts) ...[
                InkWell(
                  onTap: () {
                    _identifier.text = account.email;
                    _password.text = account.password;
                    Navigator.pop(dialogContext);
                  },
                  borderRadius: BorderRadius.circular(AppRadius.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF141A29)
                          : AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(AppRadius.radiusMd),
                      border: Border.all(
                        color: isDark
                            ? const Color(0x26FFFFFF)
                            : AppColors.borderSubtle,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              account.role.label(dialogContext.l10n),
                              style: AppTypography.of(dialogContext).label
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFF38BDF8)
                                        : AppColors.brandPrimary,
                                  ),
                            ),
                            Icon(
                              Icons.touch_app_outlined,
                              size: 14,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : AppColors.textMuted,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        SelectableText(
                          account.email,
                          style: AppTypography.of(dialogContext).bodySmall
                              .copyWith(
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                        ),
                        SelectableText(
                          account.phone,
                          style: AppTypography.of(dialogContext).bodySmall
                              .copyWith(
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        SelectableText(
                          '${dialogContext.l10n.authDemoPassword}: ${account.password}',
                          style: AppTypography.of(dialogContext).caption
                              .copyWith(
                                color: isDark
                                    ? const Color(0xFF64748B)
                                    : AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => FocusTraversalGroup(
    policy: OrderedTraversalPolicy(),
    child: AppAuthLayout(
      child: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            current.isAuthenticated && !previous.isAuthenticated,
        listener: (context, state) {
          TextInput.finishAutofillContext();
          _password.clear();
        },
        builder: (context, state) {
          final loading = state.status == AuthStatus.authenticating;
          final typography = AppTypography.of(context);
          return AutofillGroup(
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.authWelcomeBack,
                    style: typography.pageTitle.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.l10n.authSignInSubtitle,
                    style: typography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(1),
                    child: AppTextField(
                      key: const ValueKey('login-identifier'),
                      label: context.l10n.authIdentifier,
                      controller: _identifier,
                      focusNode: _identifierFocus,
                      enabled: !loading,
                      prefixIcon: Icons.alternate_email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.username],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      validator: (value) => AppValidation.identifier(
                        value,
                      )?.message(context.l10n),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(2),
                    child: AppPasswordField(
                      key: const ValueKey('login-password'),
                      controller: _password,
                      focusNode: _passwordFocus,
                      enabled: !loading,
                      prefixIcon: Icons.lock_outline_rounded,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) =>
                          AppValidation.password(value)?.message(context.l10n),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(3),
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: AppTextButton(
                        label: context.l10n.forgotPassword,
                        onPressed: loading
                            ? null
                            : () => context.go(AppRoutes.forgotPassword),
                      ),
                    ),
                  ),
                  if (state.failure != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Semantics(
                      liveRegion: true,
                      child: AppMotion.entrance(
                        context,
                        AppAlert(
                          message: state.failure!.localizedMessage(
                            context.l10n,
                          ),
                          status: AppStatus.danger,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(4),
                    child: SizedBox(
                      width: double.infinity,
                      child: AppPrimaryButton(
                        key: const ValueKey('login-submit'),
                        label: loading
                            ? context.l10n.authLoggingIn
                            : context.l10n.login,
                        loading: loading,
                        onPressed: _submit,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    context.l10n.authSessionNote,
                    style: typography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.demoAccounts.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    const Divider(color: AppColors.borderSubtle),
                    const SizedBox(height: AppSpacing.xs),
                    Center(
                      child: AppTextButton(
                        label: context.l10n.authDemoAccounts,
                        icon: Icons.auto_awesome_rounded,
                        onPressed: loading
                            ? null
                            : () => _showDemoAccountsDialog(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
