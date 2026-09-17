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
  const ChangePasswordPage({super.key});
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
    if (context.read<PasswordBloc>().state.status == PasswordStatus.submitting) {
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

  @override
  Widget build(BuildContext context) => AppAuthLayout(
    showBrandPanel: false,
    child: BlocConsumer<PasswordBloc, PasswordState>(
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
        return AutofillGroup(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.authChangePassword,
                  style: AppTypography.of(context).pageTitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(context.l10n.authChangeSubtitle),
                const SizedBox(height: AppSpacing.section),
                AppPasswordField(
                  label: context.l10n.authCurrentPassword,
                  controller: _current,
                  enabled: !loading,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _newFocus.requestFocus(),
                  validator: (value) =>
                      AppValidation.password(value)?.message(context.l10n),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppPasswordField(
                  label: context.l10n.authNewPassword,
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
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.l10n.authPasswordConstraints,
                  style: AppTypography.of(context).caption,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppPasswordField(
                  label: context.l10n.authConfirmPassword,
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
                const SizedBox(height: AppSpacing.xxl),
                if (state.failure != null) ...[
                  Semantics(
                    liveRegion: true,
                    child: AppAlert(
                      message: state.failure!.localizedMessage(context.l10n),
                      status: AppStatus.danger,
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
                  style: AppTypography.of(context).caption,
                ),
                AppTextButton(
                  label: context.l10n.authBackToWorkspace,
                  onPressed: loading ? null : () => context.go('/app'),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
