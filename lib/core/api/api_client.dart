import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/access_endpoint.dart';
import 'package:modular_erp/core/api/api_base_url.dart';
import 'package:modular_erp/core/api/api_error_codes.dart';
import 'package:modular_erp/core/api/api_option_keys.dart';
import 'package:modular_erp/core/api/interceptors/auth_retry_interceptor.dart';
import 'package:modular_erp/core/api/interceptors/authentication_interceptor.dart';
import 'package:modular_erp/core/api/interceptors/client_platform_interceptor.dart';
import 'package:modular_erp/core/api/interceptors/idempotency_interceptor.dart';
import 'package:modular_erp/core/api/interceptors/ngrok_dev_interceptor.dart';
import 'package:modular_erp/core/api/interceptors/request_id_interceptor.dart';
import 'package:modular_erp/core/api/interceptors/session_guard_interceptor.dart';
import 'package:modular_erp/core/api/models/api_envelope.dart';
import 'package:modular_erp/core/api/session_endpoint.dart';
import 'package:modular_erp/core/api/token_refresh_coordinator.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/storage/secure_session_storage.dart';

/// Raw transport result: the decoded body plus the HTTP status code.
typedef _Raw = ({dynamic data, int? status});

/// Maps transport failures to safe [Failure]s. Raw bodies never escape.
class ApiErrorMapper {
  static Failure map(DioException error) => switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => const Failure(
      code: 'timeout',
      kind: FailureKind.timeout,
      retryable: true,
    ),
    DioExceptionType.connectionError => const Failure(
      code: 'offline',
      kind: FailureKind.offline,
      retryable: true,
    ),
    DioExceptionType.cancel => const Failure(
      code: 'cancelled',
      kind: FailureKind.cancelled,
    ),
    DioExceptionType.badCertificate => const Failure(
      code: 'bad_certificate',
      kind: FailureKind.request,
    ),
    DioExceptionType.badResponse => ApiErrorCodes.fromResponse(
      error.response?.data,
      error.response?.statusCode,
    ),
    _ =>
      error.error is FormatException || error.error is TypeError
          ? const Failure(code: 'invalid_data', kind: FailureKind.invalidData)
          : ApiErrorCodes.fromStatus(error.response?.statusCode),
  };
}

/// Thin, module-agnostic HTTP client over Dio.
///
/// Every backend response uses the `{ success, message, data, errors }`
/// envelope. The request helpers unwrap `data`, decode it through a caller
/// supplied `fromJson`, and never leak transport shapes into features.
///
/// Interceptor order is deterministic:
/// `RequestId â†’ ClientPlatform â†’ Idempotency â†’ Authentication â†’ AuthRetry`.
class ApiClient {
  ApiClient({
    required String baseUrl,
    required SessionStorage storage,
    TokenRefreshCoordinator? refreshCoordinator,
    SessionEndpoint? sessionEndpoint,
    AccessEndpoint? accessEndpoint,
    Dio? dio,
    bool allowInsecureHttp = false,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration sendTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
  }) : dio = dio ?? Dio(),
       _refreshCoordinator = refreshCoordinator ?? TokenRefreshCoordinator() {
    final uri = ApiBaseUrl.parse(baseUrl, allowInsecureHttp: allowInsecureHttp);
    _trustedHost = uri.host;
    final ngrokDev = ngrokDevHeaderEnabled(_trustedHost);
    this.dio.options = this.dio.options.copyWith(
      baseUrl: uri.toString(),
      connectTimeout: connectTimeout,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: {
        ...this.dio.options.headers,
        Headers.acceptHeader: Headers.jsonContentType,
      },
    );
    this.dio.interceptors.addAll([
      if (ngrokDev) const NgrokDevInterceptor(enabled: true),
      RequestIdInterceptor(),
      ClientPlatformInterceptor(),
      IdempotencyInterceptor(),
      AuthenticationInterceptor(
        storage: storage,
        refreshCoordinator: _refreshCoordinator,
        trustedHost: _trustedHost,
      ),
      AuthRetryInterceptor(
        dio: this.dio,
        storage: storage,
        refreshCoordinator: _refreshCoordinator,
      ),
      SessionGuardInterceptor(
        sessionEndpoint ?? SessionEndpoint(),
        accessEndpoint,
      ),
    ]);
  }

  final Dio dio;
  final TokenRefreshCoordinator _refreshCoordinator;
  final Map<String, Future<Result<_Raw>>> _inFlightMutations = {};
  late final String _trustedHost;

  void close() => dio.close(force: true);

  /// Generic typed request. Prefer the verb helpers below for readability.
  Future<Result<T>> request<T>(
    String method, {
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool requiresAuth = true,
    bool idempotent = false,
    bool deduplicate = true,
    bool skipPermissionRefresh = false,
    CancelToken? cancelToken,
    required T Function(Object? json) fromJson,
  }) => _decode(
    _send(
      method,
      path,
      body: body,
      query: query,
      headers: headers,
      requiresAuth: requiresAuth,
      idempotent: idempotent,
      deduplicate: deduplicate,
      skipPermissionRefresh: skipPermissionRefresh,
      cancelToken: cancelToken,
    ),
    fromJson,
  );

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool requiresAuth = true,
    bool skipPermissionRefresh = false,
    CancelToken? cancelToken,
    required T Function(Object? json) fromJson,
  }) => request<T>(
    'GET',
    path: path,
    query: query,
    headers: headers,
    requiresAuth: requiresAuth,
    deduplicate: false,
    skipPermissionRefresh: skipPermissionRefresh,
    cancelToken: cancelToken,
    fromJson: fromJson,
  );

  Future<Result<T>> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool requiresAuth = true,
    bool idempotent = false,
    bool deduplicate = true,
    CancelToken? cancelToken,
    required T Function(Object? json) fromJson,
  }) => request<T>(
    'POST',
    path: path,
    body: body,
    query: query,
    headers: headers,
    requiresAuth: requiresAuth,
    idempotent: idempotent,
    deduplicate: deduplicate,
    cancelToken: cancelToken,
    fromJson: fromJson,
  );

  Future<Result<T>> put<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool requiresAuth = true,
    bool idempotent = false,
    bool deduplicate = true,
    CancelToken? cancelToken,
    required T Function(Object? json) fromJson,
  }) => request<T>(
    'PUT',
    path: path,
    body: body,
    query: query,
    headers: headers,
    requiresAuth: requiresAuth,
    idempotent: idempotent,
    deduplicate: deduplicate,
    cancelToken: cancelToken,
    fromJson: fromJson,
  );

  Future<Result<T>> patch<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool requiresAuth = true,
    bool idempotent = false,
    bool deduplicate = true,
    CancelToken? cancelToken,
    required T Function(Object? json) fromJson,
  }) => request<T>(
    'PATCH',
    path: path,
    body: body,
    query: query,
    headers: headers,
    requiresAuth: requiresAuth,
    idempotent: idempotent,
    deduplicate: deduplicate,
    cancelToken: cancelToken,
    fromJson: fromJson,
  );

  Future<Result<T>> delete<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool requiresAuth = true,
    bool idempotent = false,
    bool deduplicate = true,
    CancelToken? cancelToken,
    required T Function(Object? json) fromJson,
  }) => request<T>(
    'DELETE',
    path: path,
    body: body,
    query: query,
    headers: headers,
    requiresAuth: requiresAuth,
    idempotent: idempotent,
    deduplicate: deduplicate,
    cancelToken: cancelToken,
    fromJson: fromJson,
  );

  /// For endpoints whose `data` payload is irrelevant (e.g. logout/delete).
  Future<Result<void>> requestVoid(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool requiresAuth = true,
    bool idempotent = false,
    bool deduplicate = true,
    CancelToken? cancelToken,
  }) async {
    final result = await _send(
      method,
      path,
      body: body,
      query: query,
      headers: headers,
      requiresAuth: requiresAuth,
      idempotent: idempotent,
      deduplicate: deduplicate,
      cancelToken: cancelToken,
    );
    return switch (result) {
      Failed(:final failure) => Failed<void>(failure),
      Success(:final value) => _decodeVoid(value),
    };
  }

  Future<Result<_Raw>> _send(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool requiresAuth = true,
    bool idempotent = false,
    bool deduplicate = true,
    bool skipPermissionRefresh = false,
    CancelToken? cancelToken,
  }) {
    final isMutation = !_isSafeMethod(method);
    final key = (deduplicate && isMutation)
        ? _mutationKey(method, path, body, query)
        : null;
    if (key != null) {
      final existing = _inFlightMutations[key];
      if (existing != null) return existing;
    }
    final future = _perform(
      method,
      path,
      body: body,
      query: query,
      headers: headers,
      requiresAuth: requiresAuth,
      idempotent: idempotent,
      skipPermissionRefresh: skipPermissionRefresh,
      cancelToken: cancelToken,
    );
    if (key != null) {
      _inFlightMutations[key] = future;
      future.whenComplete(() {
        if (identical(_inFlightMutations[key], future)) {
          _inFlightMutations.remove(key);
        }
      });
    }
    return future;
  }

  Future<Result<_Raw>> _perform(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool requiresAuth = true,
    bool idempotent = false,
    bool skipPermissionRefresh = false,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        cancelToken: cancelToken,
        options: Options(
          method: method,
          headers: headers,
          extra: {
            if (!requiresAuth) ApiOptionKeys.skipAuthentication: true,
            if (!requiresAuth) ApiOptionKeys.skipTokenRefresh: true,
            if (idempotent) ApiOptionKeys.idempotent: true,
            if (skipPermissionRefresh)
              ApiOptionKeys.skipPermissionRefresh: true,
          },
        ),
      );
      return Success((data: response.data, status: response.statusCode));
    } on DioException catch (error) {
      return Failed(ApiErrorMapper.map(error));
    } on FormatException {
      return const Failed(
        Failure(code: 'invalid_data', kind: FailureKind.invalidData),
      );
    } catch (_) {
      return const Failed(
        Failure(code: 'invalid_data', kind: FailureKind.invalidData),
      );
    }
  }

  Future<Result<T>> _decode<T>(
    Future<Result<_Raw>> future,
    T Function(Object? json) fromJson,
  ) async {
    final result = await future;
    return switch (result) {
      Failed(:final failure) => Failed<T>(failure),
      Success(:final value) => _decodeEnvelope<T>(value, fromJson),
    };
  }

  Result<T> _decodeEnvelope<T>(_Raw raw, T Function(Object? json) fromJson) {
    final body = raw.data;
    if (body is! Map) {
      return const Failed(
        Failure(code: 'unexpected_response', kind: FailureKind.invalidData),
      );
    }
    try {
      final envelope = ApiEnvelope<Object?>.fromJson(
        body.cast<String, dynamic>(),
        (json) => json,
      );
      if (!envelope.success) {
        return Failed(ApiErrorCodes.fromErrors(envelope.errors, raw.status));
      }
      return Success<T>(fromJson(envelope.data));
    } catch (_) {
      return const Failed(
        Failure(code: 'invalid_data', kind: FailureKind.invalidData),
      );
    }
  }

  Result<void> _decodeVoid(_Raw raw) {
    final body = raw.data;
    if (body is! Map) {
      return const Failed(
        Failure(code: 'unexpected_response', kind: FailureKind.invalidData),
      );
    }
    try {
      final envelope = ApiEnvelope<Object?>.fromJson(
        body.cast<String, dynamic>(),
        (json) => json,
      );
      if (!envelope.success) {
        return Failed<void>(
          ApiErrorCodes.fromErrors(envelope.errors, raw.status),
        );
      }
      return const Success<void>(null);
    } catch (_) {
      return const Failed(
        Failure(code: 'invalid_data', kind: FailureKind.invalidData),
      );
    }
  }

  static bool _isSafeMethod(String method) {
    final upper = method.toUpperCase();
    return upper == 'GET' || upper == 'HEAD' || upper == 'OPTIONS';
  }

  static String _mutationKey(
    String method,
    String path,
    Object? body,
    Map<String, dynamic>? query,
  ) {
    final encodedBody = _encodeBody(body);
    final encodedQuery = query == null ? '' : _encodeBody(query);
    return '${method.toUpperCase()}|$path|$encodedQuery|$encodedBody';
  }

  static String _encodeBody(Object? body) {
    if (body == null) return '';
    try {
      return jsonEncode(body);
    } catch (_) {
      return body.toString();
    }
  }
}
