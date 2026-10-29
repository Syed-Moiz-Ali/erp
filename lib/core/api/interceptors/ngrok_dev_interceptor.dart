import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Adds the ngrok browser-warning bypass header for development tunnels only.
///
/// Enabled exclusively in debug builds whose configured host is an ngrok
/// domain. It never runs for production hosts and never logs the URL or token.
class NgrokDevInterceptor extends Interceptor {
  const NgrokDevInterceptor({required this.enabled});

  final bool enabled;

  static bool isNgrokHost(String host) {
    final value = host.toLowerCase();
    return value == 'ngrok.io' ||
        value == 'ngrok-free.app' ||
        value == 'ngrok-free.dev' ||
        value.endsWith('.ngrok.io') ||
        value.endsWith('.ngrok-free.app') ||
        value.endsWith('.ngrok-free.dev');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      options.headers.putIfAbsent('ngrok-skip-browser-warning', () => 'true');
    }
    handler.next(options);
  }
}

/// True only for a debug build pointed at an ngrok tunnel.
bool ngrokDevHeaderEnabled(String host) =>
    kDebugMode && NgrokDevInterceptor.isNgrokHost(host);
