import 'package:modular_erp/l10n/generated/app_localizations.dart';
import 'result.dart';

extension FailureLocalization on Failure {
  String localizedMessage(AppLocalizations l10n) => switch (kind) {
    FailureKind.invalidCredentials => l10n.authInvalidCredentials,
    FailureKind.sessionStorage => l10n.authSessionStorageError,
    FailureKind.demoDisabled => l10n.authDemoDisabled,
    FailureKind.notConfigured => l10n.authNotConfigured,
    FailureKind.currentPassword => l10n.authCurrentPasswordInvalid,
    FailureKind.passwordPolicy => l10n.authPasswordConstraints,
    FailureKind.server => l10n.authServerError,
    FailureKind.unknown => l10n.somethingWentWrong,
    FailureKind.timeout => l10n.failureTimeout,
    FailureKind.offline => l10n.failureOffline,
    FailureKind.cancelled => l10n.failureCancelled,
    FailureKind.sessionExpired => l10n.failureSessionExpired,
    FailureKind.request => l10n.failureRequest,
    FailureKind.invalidData => l10n.failureInvalidData,
    FailureKind.validation => l10n.failureValidation,
    FailureKind.conflict => l10n.failureConflict,
    FailureKind.notFound => l10n.failureNotFound,
    FailureKind.rateLimited => l10n.failureRateLimited,
    FailureKind.forbidden => l10n.failureForbidden,
    FailureKind.accountInactive => l10n.failureAccountInactive,
    FailureKind.locationDisabled => l10n.failureLocationDisabled,
    FailureKind.locationPermission => l10n.failureLocationPermission,
    FailureKind.locationUnavailable => l10n.failureLocationUnavailable,
    FailureKind.storageWrite => l10n.failureStorageWrite,
    FailureKind.storageUpdate => l10n.failureStorageUpdate,
    FailureKind.sync => l10n.failureSync,
    FailureKind.preferencesRead => l10n.failurePreferencesRead,
    FailureKind.preferencesWrite => l10n.failurePreferencesWrite,
  };
}
