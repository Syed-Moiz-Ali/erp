import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/api_error_codes.dart';
import 'package:modular_erp/core/api/api_option_keys.dart';
import 'package:modular_erp/core/api/session_endpoint.dart';

/// Reports definitively session-ending authentication responses to the
/// [SessionEndpoint] so the authentication layer can invalidate the session.
///
/// Only codes that mean "this session is gone" are reported; `AUTH_TOKEN_EXPIRED`
/// is deliberately excluded because it is handled by refresh, not invalidation.
/// Authentication-free requests (login/refresh) are never reported.
class SessionGuardInterceptor extends Interceptor {
  SessionGuardInterceptor(this.endpoint);

  final SessionEndpoint endpoint;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    if (options.extra[ApiOptionKeys.skipAuthentication] != true &&
        err.response?.statusCode == 401) {
      final code = _sessionEndingCode(err.response?.data);
      if (code != null) endpoint.notify(code);
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
