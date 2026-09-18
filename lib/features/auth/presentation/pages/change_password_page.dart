import '../../../../app/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';
import '../../../../core/errors/failure_localization.dart';
import '../../../../core/validation/app_validation.dart';
import '../../../../l10n/l10n.dart';
import '../bloc/password_bloc.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key, this.embedded = false});
  final bool embedded;
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePasswordPage> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController(),
      _replacement = TextEditingController(),
      _confirmation = TextEditingController();
  final _newFocus = FocusNode(), _confirmFocus = FocusNode();
  void _submit() {
    if (context.read<PasswordBloc>().state.status ==
        PasswordStatus.submitting) {
      return;
    }
    if (_form.currentState!.validate()) {
      context.read<PasswordBloc>().add(
        PasswordChangeRequested(
          _current.text,
          _replacement.text,
          _confirmation.text,
        ),
      );
    }
  }

  @override
  void dispose() {
    _current.dispose();
    _replacement.dispose();
    _confirmation.dispose();
    _newFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Widget _layout(Widget form) => widget.embedded
      ? AppPage(maxWidth: AppDimensions.form, child: form)
      : AppAuthLayout(showBrandPanel: false, child: form);
  @override
  Widget build(BuildContext context) => _layout(
    BlocConsumer<PasswordBloc, PasswordState>(
      listenWhen: (previous, current) =>
          current.status == PasswordStatus.success &&
          previous.status != current.status,
      listener: (context, state) {
        _current.clear();
        _replacement.clear();
        _confirmation.clear();
        TextInput.finishAutofillContext();
        AppFeedback.showMessage(
          context,
          message: (l10n) => l10n.authPasswordChanged,
        );
      },
      builder: (context, state) {
        final loading = state.status == PasswordStatus.submitting;
        final typography = AppTypography.of(context);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AutofillGroup(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.authChangePassword,
                  style: typography.authTitle.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.authChangeSubtitle,
                  style: typography.body.copyWith(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppPasswordField(
                  label: context.l10n.authCurrentPassword,
                  labelAbove: true,
                  suffixIconSize: 18,
                  controller: _current,
                  enabled: !loading,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _newFocus.requestFocus(),
                  validator: (value) =>
                      AppValidation.password(value)?.message(context.l10n),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPasswordField(
                  label: context.l10n.authNewPassword,
                  labelAbove: true,
                  suffixIconSize: 18,
                  controller: _replacement,
                  focusNode: _newFocus,
                  enabled: !loading,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
                  validator: (value) => AppValidation.newPassword(
                    value,
                    _current.text,
                  )?.message(context.l10n),
                ),
                const SizedBox(height: AppSpacing.xs),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: AppSpacing.xs,
                  ),
                  child: Text(
                    context.l10n.authPasswordConstraints,
                    style: typography.caption.copyWith(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPasswordField(
                  label: context.l10n.authConfirmPassword,
                  labelAbove: true,
                  suffixIconSize: 18,
                  controller: _confirmation,
                  focusNode: _confirmFocus,
                  enabled: !loading,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onFieldSubmitted: (_) => _submit(),
                  validator: (value) => AppValidation.confirmPassword(
                    value,
                    _replacement.text,
                  )?.message(context.l10n),
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
                      : context.l10n.authChangePassword,
                  loading: loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  context.l10n.authPasswordDemoNote,
                  style: typography.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppTextButton(
                  label: context.l10n.authBackToWorkspace,
                  onPressed: loading ? null : () => context.go(AppRoutes.app),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
