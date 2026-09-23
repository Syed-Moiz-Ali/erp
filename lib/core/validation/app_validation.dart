import 'package:modular_erp/core/auth/password_policy.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/l10n/generated/app_localizations.dart';

enum ValidationIssue {
  required,
  emailRequired,
  emailInvalid,
  identifierRequired,
  identifierInvalid,
  passwordRequired,
  passwordWeak,
  passwordMismatch,
  passwordUnchanged,
}

abstract final class AppValidation {
  static ValidationIssue? identifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationIssue.identifierRequired;
    }
    return AuthIdentifier.parse(value) == null
        ? ValidationIssue.identifierInvalid
        : null;
  }

  static ValidationIssue? password(String? value) =>
      value == null || value.isEmpty ? ValidationIssue.passwordRequired : null;
  static ValidationIssue? newPassword(String? value, String current) {
    if (password(value) != null) return ValidationIssue.passwordRequired;
    if (!PasswordPolicy.accepts(value!)) {
      return ValidationIssue.passwordWeak;
    }
    if (value == current) return ValidationIssue.passwordUnchanged;
    return null;
  }

  static ValidationIssue? confirmPassword(String? value, String replacement) =>
      password(value) ??
      (value != replacement ? ValidationIssue.passwordMismatch : null);
  static ValidationIssue? required(String? value) =>
      value == null || value.trim().isEmpty ? ValidationIssue.required : null;
  static ValidationIssue? email(String? value) {
    if (required(value) != null) return ValidationIssue.emailRequired;
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value!.trim())
        ? null
        : ValidationIssue.emailInvalid;
  }
}

extension ValidationLocalization on ValidationIssue {
  String message(AppLocalizations l10n) => switch (this) {
    ValidationIssue.identifierRequired => l10n.authIdentifierRequired,
    ValidationIssue.identifierInvalid => l10n.authIdentifierInvalid,
    ValidationIssue.passwordRequired => l10n.authPasswordRequired,
    ValidationIssue.passwordWeak => l10n.authPasswordConstraints,
    ValidationIssue.passwordMismatch => l10n.authPasswordsMismatch,
    ValidationIssue.passwordUnchanged => l10n.authPasswordMustDiffer,
    ValidationIssue.required => l10n.fieldRequired,
    ValidationIssue.emailRequired => l10n.emailRequired,
    ValidationIssue.emailInvalid => l10n.emailInvalid,
  };
}
