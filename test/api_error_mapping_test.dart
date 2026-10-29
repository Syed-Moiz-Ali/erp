import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/api_error_codes.dart';
import 'package:modular_erp/core/errors/result.dart';

import 'support/api_test_harness.dart';
import 'support/memory_session_storage.dart';

void main() {
  group('status-code mapping', () {
    final cases = <int, FailureKind>{
      400: FailureKind.validation,
      401: FailureKind.sessionExpired,
      403: FailureKind.forbidden,
      404: FailureKind.notFound,
      409: FailureKind.conflict,
      422: FailureKind.validation,
      429: FailureKind.rateLimited,
      500: FailureKind.server,
      503: FailureKind.server,
    };

    cases.forEach((status, kind) {
      test('HTTP $status maps to ${kind.name}', () async {
        final adapter = FakeDioAdapter(
          (_) =>
              jsonResponse(envelope(success: false, errors: const []), status),
        );
        final client = buildClient(
          adapter: adapter,
          storage: MemorySessionStorage(),
        );
        final result = await client.get<Object?>(
          '/api/thing',
          fromJson: (json) => json,
        );
        final failure = (result as Failed).failure;
        expect(failure.kind, kind);
        if (status >= 500) expect(failure.retryable, isTrue);
      });
    });
  });

  group('backend error codes', () {
    final cases = <String, FailureKind>{
      'AUTH_INVALID_CREDENTIALS': FailureKind.invalidCredentials,
      'AUTH_ACCOUNT_INACTIVE': FailureKind.accountInactive,
      'AUTH_RATE_LIMITED': FailureKind.rateLimited,
      'AUTH_TOKEN_EXPIRED': FailureKind.sessionExpired,
      'AUTH_UNAUTHORIZED': FailureKind.sessionExpired,
      'ACCESS_DENIED': FailureKind.forbidden,
      'VALIDATION_ERROR': FailureKind.validation,
      'SERVICE_UNAVAILABLE': FailureKind.server,
    };

    cases.forEach((code, kind) {
      test('$code maps to ${kind.name} and preserves the code', () async {
        final adapter = FakeDioAdapter(
          (_) => jsonResponse(
            envelope(success: false, errors: [errorEntry(code)]),
            400,
          ),
        );
        final client = buildClient(
          adapter: adapter,
          storage: MemorySessionStorage(),
        );
        final result = await client.get<Object?>(
          '/api/thing',
          fromJson: (json) => json,
        );
        final failure = (result as Failed).failure;
        expect(failure.kind, kind);
        expect(failure.code, code);
      });
    });
  });

  group('field-level validation', () {
    test('preserves the field name and the backend message', () async {
      final adapter = FakeDioAdapter(
        (_) => jsonResponse(
          envelope(
            success: false,
            errors: [
              errorEntry(
                'VALIDATION_ERROR',
                field: 'departmentName',
                message: 'A department with this name already exists.',
              ),
            ],
          ),
          409,
        ),
      );
      final client = buildClient(
        adapter: adapter,
        storage: MemorySessionStorage(),
      );
      final result = await client.get<Object?>(
        '/api/thing',
        fromJson: (json) => json,
      );
      final failure = (result as Failed).failure;
      expect(failure.field, 'departmentName');
      expect(
        failure.serverMessage,
        'A department with this name already exists.',
      );
      // An explicit backend code wins over the HTTP status.
      expect(failure.kind, FailureKind.validation);
    });
  });

  group('transport failures', () {
    test('timeouts are retryable', () {
      final failure = ApiErrorMapper.map(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      expect(failure.code, 'timeout');
      expect(failure.kind, FailureKind.timeout);
      expect(failure.retryable, isTrue);
    });

    test('connection errors are offline and retryable', () {
      final failure = ApiErrorMapper.map(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(failure.kind, FailureKind.offline);
      expect(failure.retryable, isTrue);
    });

    test('cancellation is not retryable', () {
      final failure = ApiErrorMapper.map(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.cancel,
        ),
      );
      expect(failure.kind, FailureKind.cancelled);
      expect(failure.retryable, isFalse);
    });

    test('malformed JSON surfaces as invalidData', () {
      final failure = ApiErrorMapper.map(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.unknown,
          error: const FormatException('bad json'),
        ),
      );
      expect(failure.kind, FailureKind.invalidData);
    });
  });

  group('ApiErrorCodes helpers', () {
    test('fromStatus falls back to the HTTP status', () {
      expect(ApiErrorCodes.fromStatus(404).kind, FailureKind.notFound);
      expect(ApiErrorCodes.fromStatus(409).kind, FailureKind.conflict);
    });
    test('unknown code falls back to status', () {
      expect(
        ApiErrorCodes.fromCode('SOMETHING_NEW', statusCode: 403).kind,
        FailureKind.forbidden,
      );
    });
  });
}
