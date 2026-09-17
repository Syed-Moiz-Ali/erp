import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../errors/result.dart';
import '../storage/secure_session_storage.dart';

class AuthenticationInterceptor extends Interceptor {
  AuthenticationInterceptor(this.storage);
  final SessionStorage storage;
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await storage.readAccessToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    } catch (_) {
      handler.reject(
        DioException(requestOptions: options, type: DioExceptionType.unknown),
      );
    }
  }

  // Token refresh and session invalidation belong to the future auth repository.
}

class RequestIdInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent('X-Request-ID', () => const Uuid().v4());
    handler.next(options);
  }
}

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
    _ => Failure(
      code: 'http_${error.response?.statusCode ?? 'unknown'}',
      kind: error.response?.statusCode == 401
          ? FailureKind.sessionExpired
          : (error.response?.statusCode ?? 0) >= 500
          ? FailureKind.server
          : FailureKind.request,
      retryable: (error.response?.statusCode ?? 0) >= 500,
    ),
  };
}

class ApiClient {
  ApiClient({required String baseUrl, required SessionStorage storage})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
      ) {
    dio.interceptors.addAll([
      RequestIdInterceptor(),
      AuthenticationInterceptor(storage),
    ]);
  }
  final Dio dio;
  Future<Result<T>> get<T>(String path, T Function(dynamic) decode) async {
    try {
      final response = await dio.get<dynamic>(path);
      return Success(decode(response.data));
    } on DioException catch (e) {
      return Failed(ApiErrorMapper.map(e));
    } catch (_) {
      return const Failed(
        Failure(code: 'invalid_data', kind: FailureKind.invalidData),
      );
    }
  }
}
