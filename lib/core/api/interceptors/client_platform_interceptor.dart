import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Sends `X-Client-Platform` (`android` | `ios` | `web` | `other`) so the
/// backend can tailor tokens and responses per client.
class ClientPlatformInterceptor extends Interceptor {
  static const header = 'X-Client-Platform';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent(header, () => _platform);
    handler.next(options);
  }

  String get _platform {
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => 'other',
    };
  }
}
