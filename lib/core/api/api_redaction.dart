/// Redacts sensitive values before they could reach logs, diagnostics or error
/// surfaces. Never log a raw [Map] of request/response headers without passing
/// it through [headers].
abstract final class ApiRedaction {
  const ApiRedaction._();

  static const mask = '***';

  static const Set<String> sensitiveHeaders = {
    'authorization',
    'proxy-authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
    'x-auth-token',
    'idempotency-key',
  };

  /// Returns a copy of [headers] with sensitive values masked.
  static Map<String, String> headers(Map<String, dynamic>? headers) {
    if (headers == null) return const {};
    return {
      for (final entry in headers.entries)
        entry.key: sensitiveHeaders.contains(entry.key.toLowerCase())
            ? mask
            : entry.value.toString(),
    };
  }

  /// Masks an Authorization value, keeping nothing of the token.
  static String authorization(String? value) => value == null ? '' : mask;

  /// Masks a bearer/refresh token for safe display.
  static String token(String? value) =>
      (value == null || value.isEmpty) ? '' : mask;
}
