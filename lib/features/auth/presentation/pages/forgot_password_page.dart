import '../../../../app/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';
import '../../../../core/errors/failure_localization.dart';
import '../../../../core/validation/app_validation.dart';
import '../../../../l10n/l10n.dart';
import '../bloc/password_bloc.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPasswordPage> {
  final _form = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  void _submit() {
    if (context.read<PasswordBloc>().state.status ==
        PasswordStatus.submitting) {
      return;
    }
    if (_form.currentState!.validate()) {
      context.read<PasswordBloc>().add(
        PasswordResetRequested(_identifier.text),
      );
    }
  }

  @override
  void dispose() {
    _identifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppAuthLayout(
    child: BlocBuilder<PasswordBloc, PasswordState>(
      builder: (context, state) {
        final loading = state.status == PasswordStatus.submitting;
        final typography = AppTypography.of(context);
        return Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.authForgotTitle,
                style: typography.authTitle.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.authForgotSubtitle,
                style: typography.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (state.status == PasswordStatus.success) ...[
                Semantics(
                  liveRegion: true,
                  child: AppMotion.entrance(
                    context,
                    AppInfoCard(
                      title: context.l10n.authResetTitle,
                      message: context.l10n.authResetInformation,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  context.l10n.authResetDemoNote,
                  style: typography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ] else ...[
                AutofillGroup(
                  child: AppTextField(
                    label: context.l10n.authIdentifier,
                    hint: context.l10n.authIdentifierHint,
                    controller: _identifier,
                    enabled: !loading,
                    labelAbove: true,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.username],
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (value) =>
                        AppValidation.identifier(value)?.message(context.l10n),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (state.failure != null) ...[
                  Semantics(
                    liveRegion: true,
                    child: AppMotion.entrance(
                      context,
                      AppAlert(
                        message: state.failure!.localizedMessage(context.l10n),
                        status: AppStatus.danger,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                AppPrimaryButton(
                  label: loading
                      ? context.l10n.authSubmitting
                      : context.l10n.continueAction,
                  loading: loading,
                  onPressed: _submit,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppTextButton(
                label: context.l10n.authBackToLogin,
                onPressed: loading ? null : () => context.go(AppRoutes.login),
              ),
            ],
          ),
        );
      },
    ),
  );
}
