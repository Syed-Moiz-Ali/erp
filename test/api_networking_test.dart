import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/api_base_url.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/api_path.dart';
import 'package:modular_erp/core/errors/result.dart';

import 'support/api_test_harness.dart';
import 'support/memory_session_storage.dart';

class _Body {
  const _Body(this.name, this.quantity);
  final String name;
  final int quantity;
  Map<String, dynamic> toJson() => {'name': name, 'quantity': quantity};
}

void main() {
  group('ApiBaseUrl', () {
    test('accepts HTTPS', () {
      expect(ApiBaseUrl.parse('https://api.example.com'), isA<Uri>());
    });
    test('rejects plain HTTP by default', () {
      expect(
        () => ApiBaseUrl.parse('http://api.example.com'),
        throwsArgumentError,
      );
    });
    test('rejects relative or empty URLs', () {
      expect(() => ApiBaseUrl.parse('api.example.com'), throwsArgumentError);
      expect(() => ApiBaseUrl.parse(''), throwsArgumentError);
    });
    test('allows loopback HTTP only with the explicit debug flag', () {
      expect(
        ApiBaseUrl.parse('http://localhost:5257', allowInsecureHttp: true),
        isA<Uri>(),
      );
      expect(
        () => ApiBaseUrl.parse('http://10.0.0.5:5257', allowInsecureHttp: true),
        throwsArgumentError,
      );
    });
  });

  group('ApiPath', () {
    test('resolves and URL-encodes path parameters', () {
      expect(
        ApiPath.resolve('/api/employees/{id}', {'id': 28}),
        '/api/employees/28',
      );
      expect(
        ApiPath.resolve('/api/employees/{id}', {'id': 'a b/c'}),
        '/api/employees/a%20b%2Fc',
      );
    });
    test('throws for missing parameters', () {
      expect(() => ApiPath.resolve('/api/employees/{id}'), throwsArgumentError);
    });
  });

  group('HTTP verbs', () {
    late FakeDioAdapter adapter;
    late MemorySessionStorage storage;
    late ApiClient client;

    setUp(() {
      adapter = FakeDioAdapter(
        (_) => jsonResponse(envelope(data: {'v': 1}), 200),
      );
      storage = MemorySessionStorage();
      client = buildClient(adapter: adapter, storage: storage);
    });

    for (final method in ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']) {
      test('$method issues the request and decodes typed data', () async {
        final result = await client.request<Object?>(
          method,
          path: '/api/thing',
          body: method == 'GET' ? null : {'x': 1},
          fromJson: (json) => json,
        );
        expect(result, isA<Success<Object?>>());
        expect(adapter.last.method, method);
        expect((result as Success).value, {'v': 1});
      });
    }

    test('sends query parameters', () async {
      await client.get<Object?>(
        '/api/employees',
        query: {'page': 1, 'sort': 'nameAsc'},
        fromJson: (json) => json,
      );
      expect(adapter.last.uri.queryParameters, {
        'page': '1',
        'sort': 'nameAsc',
      });
    });

    test('sends custom headers and correlation headers', () async {
      await client.get<Object?>(
        '/api/thing',
        headers: {'X-Custom': 'yes'},
        fromJson: (json) => json,
      );
      expect(adapter.last.headers['X-Custom'], 'yes');
      expect(adapter.last.headers['X-Request-ID'], isNotNull);
      expect(adapter.last.headers['X-Client-Platform'], isNotNull);
    });

    test('serializes a typed request body', () async {
      await client.post<Object?>(
        '/api/thing',
        body: const _Body('bolt', 4),
        fromJson: (json) => json,
      );
      expect(jsonDecode(adapter.lastBody!), {'name': 'bolt', 'quantity': 4});
    });

    test('returns null data for a nullable payload', () async {
      adapter.handler = (_) => jsonResponse(envelope(data: null), 200);
      final result = await client.get<Object?>(
        '/api/thing',
        fromJson: (json) => json,
      );
      expect(result, isA<Success<Object?>>());
      expect((result as Success).value, isNull);
    });

    test('maps malformed JSON to invalidData', () async {
      adapter.handler = (_) => rawResponse('{not json', 200);
      final result = await client.get<Object?>(
        '/api/thing',
        fromJson: (json) => json,
      );
      expect((result as Failed).failure.kind, FailureKind.invalidData);
    });

    test('maps an unexpected envelope to invalidData', () async {
      adapter.handler = (_) => jsonResponse([1, 2, 3], 200);
      final result = await client.get<Object?>(
        '/api/thing',
        fromJson: (json) => json,
      );
      expect((result as Failed).failure.code, 'unexpected_response');
    });

    test('maps a cancelled request to cancelled', () async {
      final token = CancelToken()..cancel();
      final result = await client.get<Object?>(
        '/api/thing',
        cancelToken: token,
        fromJson: (json) => json,
      );
      expect((result as Failed).failure.kind, FailureKind.cancelled);
    });

    test('coalesces concurrent identical mutations into one request', () async {
      final first = client.post<Object?>(
        '/api/departments',
        body: {'name': 'A'},
        fromJson: (json) => json,
      );
      final second = client.post<Object?>(
        '/api/departments',
        body: {'name': 'A'},
        fromJson: (json) => json,
      );
      await Future.wait([first, second]);
      expect(adapter.callCount, 1);
    });

    test('does not coalesce different mutations', () async {
      await Future.wait([
        client.post<Object?>(
          '/api/departments',
          body: {'name': 'A'},
          fromJson: (json) => json,
        ),
        client.post<Object?>(
          '/api/departments',
          body: {'name': 'B'},
          fromJson: (json) => json,
        ),
      ]);
      expect(adapter.callCount, 2);
    });

    test('adds an idempotency key when opted in', () async {
      await client.post<Object?>(
        '/api/departments',
        body: {'name': 'A'},
        idempotent: true,
        fromJson: (json) => json,
      );
      expect(adapter.last.headers['Idempotency-Key'], isA<String>());
    });

    test('omits the idempotency key by default', () async {
      await client.post<Object?>(
        '/api/departments',
        body: {'name': 'A'},
        fromJson: (json) => json,
      );
      expect(adapter.last.headers['Idempotency-Key'], isNull);
    });
  });
}
