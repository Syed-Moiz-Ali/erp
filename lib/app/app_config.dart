import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  /// Release builds disable fixtures unless deliberately opted into demo mode.
  static const demoAuthEnabled = bool.fromEnvironment(
    'DEMO_AUTH',
    defaultValue: !kReleaseMode,
  );
}
