/// Per-request `RequestOptions.extra` keys shared by the API interceptors.
///
/// These are transport concerns and must never be used by domain code.
abstract final class ApiOptionKeys {
  const ApiOptionKeys._();

  /// Skip attaching the bearer token (login, refresh, public endpoints).
  static const skipAuthentication = 'api.skipAuthentication';

  /// Skip proactive + reactive token refresh (login, refresh).
  static const skipTokenRefresh = 'api.skipTokenRefresh';

  /// Marks a request that has already been retried after a refresh.
  static const authRetried = 'api.authRetried';

  /// Skip the permission re-fetch signal on `403 ACCESS_DENIED`.
  ///
  /// Used by the permission loader itself so a denied bootstrap cannot cause a
  /// reload loop.
  static const skipPermissionRefresh = 'api.skipPermissionRefresh';

  /// Opt this request into an `Idempotency-Key` header.
  static const idempotent = 'api.idempotent';

  /// Carries the generated idempotency key across retries.
  static const idempotencyKey = 'api.idempotencyKey';
}
