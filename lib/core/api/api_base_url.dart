import 'package:flutter/foundation.dart';

/// Validates and normalises the API base URL.
///
/// HTTPS is mandatory. A plain-HTTP base URL is accepted only when
/// [allowInsecureHttp] is explicitly enabled **and** the app is a debug build
/// **and** the host is a loopback address. This keeps the development exception
/// explicit and environment-restricted; release builds always require HTTPS.
abstract final class ApiBaseUrl {
  const ApiBaseUrl._();

  static Uri parse(String baseUrl, {bool allowInsecureHttp = false}) {
    final uri = Uri.tryParse(baseUrl.trim());
    if (uri == null ||
        !uri.isAbsolute ||
        uri.host.isEmpty ||
        uri.scheme.isEmpty) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'An absolute API base URL is required',
      );
    }
    if (uri.scheme == 'https') return uri;
    if (uri.scheme == 'http' &&
        allowInsecureHttp &&
        kDebugMode &&
        _isLoopback(uri.host)) {
      return uri;
    }
    throw ArgumentError.value(
      baseUrl,
      'baseUrl',
      'The API base URL must use HTTPS',
    );
  }

  static bool _isLoopback(String host) {
    final normalised = host.toLowerCase();
    return normalised == 'localhost' ||
        normalised == '127.0.0.1' ||
        normalised == '::1' ||
        normalised == '[::1]';
  }
}
