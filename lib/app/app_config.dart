import 'app_environment.dart';

export 'app_environment.dart' show AuthMode, AppEnvironment;

/// Centralized runtime configuration.
///
/// The active [AppEnvironment] is loaded once at startup by
/// `loadEnvironment()` (from `.env.development` / `.env.production`, selected by
/// Flutter build mode) and can be injected in tests via [configure]. No feature
/// module reads `.env` files directly and no `--dart-define` is required.
abstract final class AppConfig {
  static AppEnvironment _environment = AppEnvironment.unconfigured();

  /// The active environment.
  static AppEnvironment get environment => _environment;

  /// Replaces the active environment. Used by the startup loader and by tests.
  static void configure(AppEnvironment environment) {
    _environment = environment;
  }

  /// Restores the filesystem-free default (used between tests).
  static void reset() {
    _environment = AppEnvironment.unconfigured();
  }

  static String get environmentName => _environment.name;
  static String get apiBaseUrl => _environment.apiBaseUrl;
  static AuthMode get authMode => _environment.authMode;

  /// True when the selected mode is demo. Gates demo fixtures, seeds and
  /// local-authoritative behavior so a real backend build never mixes in demo
  /// records or demo-local authority.
  static bool get demoMode => _environment.authMode == AuthMode.demo;

  /// Backwards-compatible alias for the pre-backend flag.
  ///
  /// Kept so existing presentation call sites stay untouched; it is true only
  /// when the active environment is demo.
  static bool get demoAuthEnabled => demoMode;

  /// True only when a backend is configured with a non-empty URL.
  static bool get realApiEnabled =>
      _environment.authMode == AuthMode.backend &&
      _environment.apiBaseUrl.isNotEmpty;

  /// Explicit, environment-restricted development exception that permits a
  /// plain-HTTP loopback URL in debug builds only.
  static bool get allowInsecureHttp => _environment.allowInsecureHttp;

  static bool get configurationValid => _environment.isValid;

  /// Safe, non-secret description of the configuration problem, or null.
  static String? get configurationError => _environment.configurationError;
}
