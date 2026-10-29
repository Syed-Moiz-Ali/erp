import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/token_refresh_coordinator.dart';
import 'package:modular_erp/core/api/token_refresher.dart';
import 'package:modular_erp/core/storage/secure_session_storage.dart';

/// Deterministic in-memory Dio adapter. No test touches a live backend.
class FakeDioAdapter implements HttpClientAdapter {
  FakeDioAdapter(this.handler);

  ResponseBody Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];
  String? lastBody;

  RequestOptions get last => requests.last;
  int get callCount => requests.length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (requestStream != null) {
      final bytes = await requestStream.fold<List<int>>(
        <int>[],
        (previous, chunk) => previous..addAll(chunk),
      );
      lastBody = bytes.isEmpty ? null : utf8.decode(bytes);
    } else {
      lastBody = null;
    }
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ApiClient buildClient({
  required FakeDioAdapter adapter,
  required SessionStorage storage,
  String baseUrl = 'https://api.example.com',
  bool allowInsecureHttp = false,
  TokenRefreshCoordinator? coordinator,
}) => ApiClient(
  baseUrl: baseUrl,
  storage: storage,
  refreshCoordinator: coordinator,
  allowInsecureHttp: allowInsecureHttp,
  dio: Dio()..httpClientAdapter = adapter,
);

ResponseBody jsonResponse(Object body, int statusCode) =>
    ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

ResponseBody rawResponse(String body, int statusCode) =>
    ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

Map<String, dynamic> envelope({
  bool success = true,
  Object? data,
  String message = 'ok',
  List<Map<String, dynamic>> errors = const [],
}) => {'success': success, 'message': message, 'data': data, 'errors': errors};

Map<String, dynamic> errorEntry(
  String code, {
  String message = 'error',
  String? field,
}) => {'code': code, 'message': message, if (field != null) 'field': field};

class FakeTokenRefresher implements TokenRefresher {
  FakeTokenRefresher(this.outcome, {this.onRefresh});

  TokenRefreshOutcome outcome;
  final Future<void> Function()? onRefresh;
  int calls = 0;

  @override
  Future<TokenRefreshOutcome> refresh() async {
    calls++;
    await onRefresh?.call();
    return outcome;
  }
}

class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> store = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      store.remove(key);
    } else {
      store[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    store.remove(key);
  }
}
