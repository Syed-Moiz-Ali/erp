/// Outcome of a single token refresh attempt, classified for safe handling.
enum TokenRefreshOutcome {
  /// A new access token was obtained and persisted. The caller may retry.
  refreshed,

  /// The session is no longer valid (logged out, reused, expired, inactive).
  /// Clear local tokens and return to the login screen.
  invalidated,

  /// Transient failure (offline / server down). Keep tokens and retry later.
  unavailable,
}

/// Implemented by the authentication data layer. Runs exactly one refresh,
/// persists the rotated tokens before returning, and never throws.
abstract interface class TokenRefresher {
  Future<TokenRefreshOutcome> refresh();
}
