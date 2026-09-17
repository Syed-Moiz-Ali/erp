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
          return AutofillGroup(
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.authWelcomeBack,
                    style: AppTypography.of(context).pageTitle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.authSignInSubtitle,
                    style: AppTypography.of(context).body,
                  ),
                  const SizedBox(height: AppSpacing.section),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(1),
                    child: AppTextField(
                      key: const ValueKey('login-identifier'),
                      label: context.l10n.authIdentifier,
                      controller: _identifier,
                      focusNode: _identifierFocus,
                      enabled: !loading,
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
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) =>
                          AppValidation.password(value)?.message(context.l10n),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
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
                    const SizedBox(height: AppSpacing.md),
                    Semantics(
                      liveRegion: true,
                      child: AppAlert(
                        message: state.failure!.localizedMessage(context.l10n),
                        status: AppStatus.danger,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  const SizedBox(height: AppSpacing.lg),
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
                    style: AppTypography.of(context).caption,
                  ),
                  if (widget.demoAccounts.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    const Divider(),
                    AppTextButton(
                      label: context.l10n.authDemoAccounts,
                      onPressed: loading
                          ? null
                          : () => AppDialog.show<void>(
                              context,
                              (dialogContext) => AppDialog(
                                title: dialogContext.l10n.authDemoAccounts,
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
                                      Text(dialogContext.l10n.authDemoNotice),
                                      const SizedBox(height: AppSpacing.lg),
                                      for (final account in widget.demoAccounts)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: AppSpacing.sm,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                account.role.label(
                                                  dialogContext.l10n,
                                                ),
                                                style: AppTypography.of(
                                                  dialogContext,
                                                ).label,
                                              ),
                                              SelectableText(account.email),
                                              SelectableText(account.phone),
                                              SelectableText(
                                                '${dialogContext.l10n.authDemoPassword}: ${account.password}',
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
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
