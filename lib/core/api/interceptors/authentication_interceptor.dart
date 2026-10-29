import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/api_option_keys.dart';
import 'package:modular_erp/core/api/token_refresh_coordinator.dart';
import 'package:modular_erp/core/storage/secure_session_storage.dart';

/// Attaches `Authorization: Bearer <accessToken>` to protected requests and
/// proactively refreshes shortly before the access token expires.
///
/// The token is only attached when the resolved request host matches
/// [trustedHost], preventing authorization-header leakage to external origins
/// (redirects or absolute URLs to another domain never receive the token).
class AuthenticationInterceptor extends Interceptor {
  AuthenticationInterceptor({
    required this.storage,
    required this.refreshCoordinator,
    required this.trustedHost,
    this.earlyRefreshWindow = const Duration(minutes: 1),
  });

  final SessionStorage storage;
  final TokenRefreshCoordinator refreshCoordinator;

  /// The only host allowed to receive the bearer token.
  final String trustedHost;

  /// Refresh when the access token expires within this window.
  final Duration earlyRefreshWindow;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[ApiOptionKeys.skipAuthentication] == true ||
        !_isTrusted(options)) {
      handler.next(options);
      return;
    }
    try {
      if (refreshCoordinator.canRefresh &&
          options.extra[ApiOptionKeys.skipTokenRefresh] != true) {
        final expiresAt = await storage.readAccessTokenExpiresAt();
        final refreshFrom = DateTime.now().toUtc().add(earlyRefreshWindow);
        if (expiresAt != null && !expiresAt.isAfter(refreshFrom)) {
          await refreshCoordinator.refresh();
        }
      }
      final token = await storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } catch (_) {
      handler.reject(
        DioException(requestOptions: options, type: DioExceptionType.unknown),
      );
    }
  }

  bool _isTrusted(RequestOptions options) {
    final host = options.uri.host;
    if (host.isEmpty) return false;
    return host.toLowerCase() == trustedHost.toLowerCase();
  }
}
