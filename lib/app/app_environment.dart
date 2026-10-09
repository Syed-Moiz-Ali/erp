import 'package:flutter/foundation.dart';

/// Authentication source selection. Kept here so the environment model owns the
/// full configuration vocabulary.
enum AuthMode { demo, backend, disabled }

/// A loaded, validated environment configuration.
///
/// This is a plain value object so tests can construct any configuration without
/// touching real `.env` files or the filesystem.
class AppEnvironment {
  const AppEnvironment({
    required this.name,
    required this.apiBaseUrl,
    required this.authMode,
    required this.allowInsecureHttp,
    this.configurationError,
  });

  /// Filesystem-free default used before the loader runs and by tests.
  ///
  /// Debug defaults to demo (existing local-first developer experience);
  /// profile/release default to a disabled configuration so an unloaded build
  /// can never silently authenticate through demo.
  factory AppEnvironment.unconfigured() => kDebugMode
      ? const AppEnvironment(
          name: EnvironmentConfig.developmentName,
          apiBaseUrl: '',
          authMode: AuthMode.demo,
          allowInsecureHttp: true,
        )
      : const AppEnvironment(
          name: EnvironmentConfig.productionName,
          apiBaseUrl: '',
          authMode: AuthMode.disabled,
          allowInsecureHttp: false,
        );

  /// `development` or `production`.
  final String name;

  /// Normalized backend origin (no trailing slash). Empty when unset/invalid.
  final String apiBaseUrl;

  final AuthMode authMode;

  /// Whether a plain-HTTP loopback URL may be accepted (development only).
  final bool allowInsecureHttp;

  /// Safe, non-secret description of the first configuration problem, or null.
  final String? configurationError;

  bool get isValid => configurationError == null;
  bool get isProduction => name == EnvironmentConfig.productionName;
  bool get isDevelopment => name == EnvironmentConfig.developmentName;

  @override
  String toString() =>
      'AppEnvironment($name, mode=${authMode.name}, '
      'valid=$isValid, host=${safeHost()})';

  /// Host only, for safe diagnostic logging (never the full URL or query).
  String safeHost() {
    final uri = Uri.tryParse(apiBaseUrl);
    return uri?.host ?? '';
  }
}

/// Environment files, build-mode selection and validation rules.
abstract final class EnvironmentConfig {
  const EnvironmentConfig._();

  static const developmentFile = '.env.development';
  static const productionFile = '.env.production';
  static const developmentName = 'development';
  static const productionName = 'production';

  static const apiBaseUrlKey = 'API_BASE_URL';
  static const authModeKey = 'AUTH_MODE';

  /// Profile and release both use the production file.
  static String fileNameForMode(FlutterBuildMode mode) =>
      mode == FlutterBuildMode.debug ? developmentFile : productionFile;

  static FlutterBuildMode currentBuildMode() => kDebugMode
      ? FlutterBuildMode.debug
      : (kProfileMode ? FlutterBuildMode.profile : FlutterBuildMode.release);

  static String nameForFile(String fileName) =>
      fileName == developmentFile ? developmentName : productionName;

  /// Parses and validates raw environment values. Never throws: any problem is
  /// reported through [AppEnvironment.configurationError] and forces the safe
  /// `disabled` mode (never a demo fallback).
  static AppEnvironment parse({
    required String fileName,
    required Map<String, String> values,
  }) {
    final name = nameForFile(fileName);
    final isProduction = name == productionName;
    final rawUrl = (values[apiBaseUrlKey] ?? '').trim();
    final rawMode = (values[authModeKey] ?? '').trim().toLowerCase();

    final errors = <String>[];

    AuthMode mode = AuthMode.disabled;
    if (rawMode.isEmpty) {
      errors.add('$authModeKey is missing');
    } else {
      switch (rawMode) {
        case 'backend':
          mode = AuthMode.backend;
        case 'demo':
          mode = AuthMode.demo;
        case 'disabled':
          mode = AuthMode.disabled;
        default:
          errors.add('$authModeKey "$rawMode" is invalid');
      }
    }

    var apiBaseUrl = '';
    if (rawUrl.isEmpty) {
      // Demo and disabled modes do not need a backend URL.
      if (mode == AuthMode.backend) errors.add('$apiBaseUrlKey is missing');
    } else {
      final uri = Uri.tryParse(rawUrl);
      if (uri == null ||
          !uri.isAbsolute ||
          uri.host.isEmpty ||
          uri.hasQuery ||
          uri.hasFragment) {
        errors.add('$apiBaseUrlKey is not a valid absolute URL');
      } else {
        apiBaseUrl = _normalizeBase(uri);
        if (uri.scheme != 'https') {
          final loopbackHttp =
              !isProduction && uri.scheme == 'http' && _isLoopback(uri.host);
          if (!loopbackHttp) errors.add('$apiBaseUrlKey must use HTTPS');
        }
        if (isProduction && _isForbiddenProductionHost(uri.host)) {
          errors.add(
            '$apiBaseUrlKey must not be a placeholder, loopback or private '
            'address in production',
          );
        }
      }
    }

    if (isProduction && mode == AuthMode.demo) {
      errors.add('$authModeKey demo is not allowed in production');
    }

    if (errors.isNotEmpty) {
      return AppEnvironment(
        name: name,
        apiBaseUrl: '',
        authMode: AuthMode.disabled,
        allowInsecureHttp: false,
        configurationError: errors.join('; '),
      );
    }
    return AppEnvironment(
      name: name,
      apiBaseUrl: apiBaseUrl,
      authMode: mode,
      allowInsecureHttp: !isProduction && kDebugMode,
    );
  }

  static String _normalizeBase(Uri uri) {
    final buffer = StringBuffer('${uri.scheme}://${uri.host}');
    final defaultPort =
        (uri.scheme == 'https' && uri.port == 443) ||
        (uri.scheme == 'http' && uri.port == 80);
    if (uri.hasPort && !defaultPort) buffer.write(':${uri.port}');
    final path = uri.path == '/' ? '' : uri.path;
    if (path.isNotEmpty) {
      buffer.write(
        path.endsWith('/') ? path.substring(0, path.length - 1) : path,
      );
    }
    return buffer.toString();
  }

  static bool _isLoopback(String host) {
    final value = host.toLowerCase();
    return value == 'localhost' ||
        value == '127.0.0.1' ||
        value == '::1' ||
        value == '[::1]' ||
        value == '0.0.0.0';
  }

  static bool _isForbiddenProductionHost(String host) {
    final value = host.toLowerCase();
    if (_isLoopback(value)) return true;
    if (value.endsWith('.local') || value.endsWith('.internal')) return true;
    const placeholders = [
      'example.com',
      'example.org',
      'yourdomain',
      'your-domain',
      'your-dev-tunnel',
      'changeme',
      'placeholder',
      'ngrok',
    ];
    for (final marker in placeholders) {
      if (value.contains(marker)) return true;
    }
    // Private IPv4 ranges.
    final ipv4 = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');
    final match = ipv4.firstMatch(value);
    if (match != null) {
      final first = int.parse(match.group(1)!);
      final second = int.parse(match.group(2)!);
      if (first == 10) return true;
      if (first == 192 && second == 168) return true;
      if (first == 172 && second >= 16 && second <= 31) return true;
      if (first == 169 && second == 254) return true;
    }
    return false;
  }
}

enum FlutterBuildMode { debug, profile, release }
