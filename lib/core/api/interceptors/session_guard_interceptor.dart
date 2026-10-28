import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/access_endpoint.dart';
import 'package:modular_erp/core/api/api_error_codes.dart';
import 'package:modular_erp/core/api/api_option_keys.dart';
import 'package:modular_erp/core/api/session_endpoint.dart';

/// Reports definitively session-ending authentication responses to the
/// [SessionEndpoint] and permission-denied responses to the [AccessEndpoint].
///
/// Only codes that mean "this session is gone" are reported; `AUTH_TOKEN_EXPIRED`
/// is deliberately excluded because it is handled by refresh, not invalidation.
/// Authentication-free requests (login/refresh) are never reported.
class SessionGuardInterceptor extends Interceptor {
  SessionGuardInterceptor(this.endpoint, [this.accessEndpoint]);

  final SessionEndpoint endpoint;
  final AccessEndpoint? accessEndpoint;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    if (options.extra[ApiOptionKeys.skipAuthentication] != true) {
      final status = err.response?.statusCode;
      if (status == 401) {
        final code = _sessionEndingCode(err.response?.data);
        if (code != null) endpoint.notify(code);
      } else if (status == 403 &&
          options.extra[ApiOptionKeys.skipPermissionRefresh] != true) {
        final denied = ApiErrorCodes.extract(
          err.response?.data,
        ).any((error) => error.code == ApiErrorCodes.accessDenied);
        if (denied) accessEndpoint?.notify(ApiErrorCodes.accessDenied);
      }
    }
    handler.next(err);
  }

  String? _sessionEndingCode(dynamic body) {
    for (final error in ApiErrorCodes.extract(body)) {
      if (ApiErrorCodes.sessionEndingCodes.contains(error.code)) {
        return error.code;
      }
    }
    return null;
  }
}
