import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Attaches a correlation id to every outgoing request for tracing.
class RequestIdInterceptor extends Interceptor {
  static const header = 'X-Request-ID';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent(header, () => const Uuid().v4());
    handler.next(options);
  }
}
