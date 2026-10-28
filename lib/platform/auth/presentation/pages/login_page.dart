import 'package:modular_erp/app/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/core/errors/failure_localization.dart';
import 'package:modular_erp/core/validation/app_validation.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
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
