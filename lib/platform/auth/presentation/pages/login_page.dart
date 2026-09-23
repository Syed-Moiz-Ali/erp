import 'package:modular_erp/app/router/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/core/errors/failure_localization.dart';
import 'package:modular_erp/core/validation/app_validation.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/domain/entities/demo_credential_info.dart';
import 'package:modular_erp/platform/auth/presentation/auth_localization.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

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
    child: BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.isAuthenticated && !previous.isAuthenticated,
      listener: (context, state) {
        TextInput.finishAutofillContext();
        _password.clear();
      },
      builder: (context, state) {
        final loading = state.status == AuthStatus.authenticating;
        return AppAuthLayout(
          developerAccess: !kDebugMode || widget.demoAccounts.isEmpty || loading
              ? null
              : _DeveloperAccessButton(
                  onPressed: () => _showDemoAccountsDialog(context),
                ),
          child: AutofillGroup(
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.authWelcomeBack,
                    style: AppTypography.of(
                      context,
                    ).authTitle.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.authSignInSubtitle,
                    style: AppTypography.of(context).bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(1),
                    child: AppTextField(
                      key: const ValueKey('login-identifier'),
                      label: context.l10n.authIdentifier,
                      hint: context.l10n.authIdentifierHint,
                      controller: _identifier,
                      focusNode: _identifierFocus,
                      enabled: !loading,
                      labelAbove: true,
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
                  const SizedBox(height: AppSpacing.xl),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(2),
                    child: AppPasswordField(
                      key: const ValueKey('login-password'),
                      controller: _password,
                      focusNode: _passwordFocus,
                      enabled: !loading,
                      labelAbove: true,
                      suffixIconSize: 18,
                      label: context.l10n.password,
                      labelTrailing: FocusTraversalOrder(
                        order: const NumericFocusOrder(3),
                        child: _ForgotPasswordAction(
                          enabled: !loading,
                          onPressed: () => context.go(AppRoutes.forgotPassword),
                        ),
                      ),
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) =>
                          AppValidation.password(value)?.message(context.l10n),
                    ),
                  ),
                  if (state.failure != null) ...[
                    const SizedBox(height: AppSpacing.xl),
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
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(4),
                    child: AppPrimaryButton(
                      key: const ValueKey('login-submit'),
                      label: loading
                          ? context.l10n.authLoggingIn
                          : context.l10n.login,
                      loading: loading,
                      onPressed: _submit,
                      size: AppButtonSize.large,
                      fullWidth: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// Compact, low-weight inline action that sits on the password label row.
class _ForgotPasswordAction extends StatelessWidget {
  const _ForgotPasswordAction({required this.enabled, required this.onPressed});
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: enabled ? onPressed : null,
    style:
        TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          disabledForegroundColor: AppColors.textDisabled,
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 2,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: AppTypography.of(
            context,
          ).caption.copyWith(fontWeight: FontWeight.w600),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.hovered)
                ? AppColors.brandSubtle
                : Colors.transparent,
          ),
        ),
    child: Text(context.l10n.forgotPassword),
  );
}

/// Development-only entry point. Icon-only and low-emphasis so it never
/// competes with the primary action; absent entirely in production builds.
class _DeveloperAccessButton extends StatelessWidget {
  const _DeveloperAccessButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.l10n.authDeveloperAccess,
    onPressed: onPressed,
    iconSize: 18,
    visualDensity: VisualDensity.compact,
    style: IconButton.styleFrom(
      foregroundColor: AppColors.textMuted,
      overlayColor: AppColors.brandSubtle,
      hoverColor: AppColors.brandSubtle,
    ),
    icon: const Icon(Icons.more_horiz_rounded),
  );
}
