import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/api_option_keys.dart';
import 'package:uuid/uuid.dart';

/// Adds an `Idempotency-Key` header to opted-in unsafe requests so a retried
/// mutation is not applied twice by the backend. The key is generated once and
/// stored on the request `extra`, so an automatic retry (e.g. after a token
/// refresh) reuses the same key instead of producing a new mutation identity.
class IdempotencyInterceptor extends Interceptor {
  static const header = 'Idempotency-Key';

  static const Set<String> _unsafeMethods = {'POST', 'PUT', 'PATCH', 'DELETE'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final optedIn = options.extra[ApiOptionKeys.idempotent] == true;
    final unsafe = _unsafeMethods.contains(options.method.toUpperCase());
    if (optedIn && unsafe) {
      final existing = options.extra[ApiOptionKeys.idempotencyKey];
      final key = existing is String && existing.isNotEmpty
          ? existing
          : const Uuid().v4();
      options.extra[ApiOptionKeys.idempotencyKey] = key;
      options.headers.putIfAbsent(header, () => key);
    }
    handler.next(options);
  }
}
