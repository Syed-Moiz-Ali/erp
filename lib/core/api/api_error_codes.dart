import 'package:modular_erp/core/api/models/api_error.dart';
import 'package:modular_erp/core/errors/result.dart';

/// Maps backend `errors[]` entries and HTTP statuses to safe [Failure]s.
///
/// Domain and presentation code branch on [Failure.code] (the backend code is
/// preserved verbatim) and show localized copy via [Failure.kind]. Field-level
/// validation detail is preserved on [Failure.field]; the backend's user-facing
/// message is preserved on [Failure.serverMessage]. Raw response bodies never
/// escape this mapper.
abstract final class ApiErrorCodes {
  const ApiErrorCodes._();

  // Authentication.
  static const invalidCredentials = 'AUTH_INVALID_CREDENTIALS';
  static const accountInactive = 'AUTH_ACCOUNT_INACTIVE';
  static const rateLimited = 'AUTH_RATE_LIMITED';
  static const tokenExpired = 'AUTH_TOKEN_EXPIRED';
  static const unauthorized = 'AUTH_UNAUTHORIZED';
  static const refreshInvalid = 'AUTH_REFRESH_INVALID';
  static const refreshExpired = 'AUTH_REFRESH_EXPIRED';
  static const refreshReused = 'AUTH_REFRESH_REUSED';

  // Generic / shared.
  static const validationError = 'VALIDATION_ERROR';
  static const accessDenied = 'ACCESS_DENIED';
  static const serviceUnavailable = 'SERVICE_UNAVAILABLE';
  static const serviceBusy = 'SERVICE_BUSY';
  static const serverError = 'SERVER_ERROR';

  /// Codes that mean this device's session must be discarded.
  static const Set<String> sessionEndingCodes = {
    unauthorized,
    refreshInvalid,
    refreshExpired,
    refreshReused,
    accountInactive,
  };

  /// Maps a backend error [code] (when present) or falls back to [statusCode].
  static Failure fromCode(String? code, {int? statusCode}) {
    if (code == null || code.isEmpty) return fromStatus(statusCode);
    return switch (code) {
      invalidCredentials => Failure(
        code: code,
        kind: FailureKind.invalidCredentials,
      ),
      accountInactive => Failure(code: code, kind: FailureKind.accountInactive),
      rateLimited => Failure(code: code, kind: FailureKind.rateLimited),
      tokenExpired ||
      unauthorized ||
      refreshInvalid ||
      refreshExpired ||
      refreshReused => Failure(code: code, kind: FailureKind.sessionExpired),
      accessDenied => Failure(code: code, kind: FailureKind.forbidden),
      validationError => Failure(code: code, kind: FailureKind.validation),
      serviceUnavailable || serviceBusy || serverError => Failure(
        code: code,
        kind: FailureKind.server,
        retryable: true,
      ),
      _ => _fromStatusWithCode(statusCode, code),
    };
  }

  /// Fallback when the backend did not send a known `code`.
  static Failure fromStatus(int? statusCode) {
    final code = statusCode == null ? 'unknown' : 'http_$statusCode';
    return _fromStatusWithCode(statusCode, code);
  }

  static Failure _fromStatusWithCode(int? statusCode, String code) {
    final status = statusCode ?? 0;
    return switch (status) {
      400 || 422 => Failure(code: code, kind: FailureKind.validation),
      401 => Failure(code: code, kind: FailureKind.sessionExpired),
      403 => Failure(code: code, kind: FailureKind.forbidden),
      404 => Failure(code: code, kind: FailureKind.notFound),
      409 => Failure(code: code, kind: FailureKind.conflict),
      429 => Failure(code: code, kind: FailureKind.rateLimited),
      >= 500 => Failure(code: code, kind: FailureKind.server, retryable: true),
      _ => Failure(code: code, kind: FailureKind.request),
    };
  }

  /// Reads the envelope `errors[]` array if present, tolerating malformed data.
  static List<ApiError> extract(dynamic body) {
    if (body is! Map) return const [];
    final raw = body['errors'];
    if (raw is! List) return const [];
    return raw.map(_parse).whereType<ApiError>().toList(growable: false);
  }

  static ApiError? _parse(dynamic raw) {
    if (raw is! Map) return null;
    final code = raw['code'];
    if (code is! String || code.isEmpty) return null;
    final rawMessage = raw['message'];
    final field = raw['field'];
    return ApiError(
      code: code,
      message: rawMessage is String ? rawMessage : '',
      field: field is String ? field : null,
    );
  }

  /// Builds a [Failure] from a backend response body and status.
  static Failure fromResponse(dynamic body, int? statusCode) =>
      fromErrors(extract(body), statusCode);

  /// Builds a [Failure] from parsed [errors], preserving the first entry's
  /// field-level and message detail.
  static Failure fromErrors(List<ApiError> errors, int? statusCode) {
    if (errors.isEmpty) return fromStatus(statusCode);
    final first = errors.first;
    return fromCode(first.code, statusCode: statusCode).copyWith(
      field: first.field,
      serverMessage: first.message.isEmpty ? null : first.message,
    );
  }
}
