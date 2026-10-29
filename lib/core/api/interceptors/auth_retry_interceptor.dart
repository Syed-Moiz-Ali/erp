import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/api_error_codes.dart';
import 'package:modular_erp/core/api/api_option_keys.dart';
import 'package:modular_erp/core/api/token_refresh_coordinator.dart';
import 'package:modular_erp/core/api/token_refresher.dart';
import 'package:modular_erp/core/storage/secure_session_storage.dart';

/// On `401 AUTH_TOKEN_EXPIRED`, runs one shared refresh and retries the
/// original request exactly once with the new access token.
///
/// This is intentionally inert until the authentication data layer wires a
/// [TokenRefresher] into the coordinator (Phase 2): with no refresher,
/// `canRefresh` is false and no refresh/retry occurs. Cancelled requests are
/// never retried.
class AuthRetryInterceptor extends Interceptor {
  AuthRetryInterceptor({
    required this.dio,
    required this.storage,
    required this.refreshCoordinator,
  });

  final Dio dio;
  final SessionStorage storage;
  final TokenRefreshCoordinator refreshCoordinator;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }
    final outcome = await refreshCoordinator.refresh();
    if (outcome != TokenRefreshOutcome.refreshed) {
      handler.next(err);
      return;
    }
    final options = err.requestOptions;
    options.extra[ApiOptionKeys.authRetried] = true;
    try {
      final token = await storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (_) {
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.cancel) return false;
    final options = err.requestOptions;
    if (options.extra[ApiOptionKeys.skipTokenRefresh] == true) return false;
    if (options.extra[ApiOptionKeys.authRetried] == true) return false;
    if (!refreshCoordinator.canRefresh) return false;
    if (err.response?.statusCode != 401) return false;
    return ApiErrorCodes.extract(
      err.response?.data,
    ).any((error) => error.code == ApiErrorCodes.tokenExpired);
  }
}
