import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:modular_erp/app/app_config.dart';
import 'package:modular_erp/app/app_environment.dart';

import 'env_local_stub.dart'
    if (dart.library.io) 'env_local_io.dart' as env_local;

/// Loads and validates the environment file selected by Flutter's build mode:
///
/// * debug → `.env.development`
/// * profile / release → `.env.production`
///
/// Must run before dependency registration, [AppConfig] evaluation, Dio
/// initialization, session restoration and the initial route decision.
///
/// Debug builds also overlay an untracked `.env.local` (when present) on top of
/// the packaged file. That file is the only place real development endpoints or
/// tokens belong; it is ignored by git and never bundled as an asset. Tests and
/// callers can disable the overlay with [localOverrides].
///
/// This function never throws and never falls back between environments: any
/// failure (missing/empty/malformed file) yields an invalid, `disabled`
/// configuration so the app fails safely rather than silently using demo mode
/// or another environment.
Future<AppEnvironment> loadEnvironment({
  DotEnv? dotenv,
  String? fileName,
  FlutterBuildMode? buildMode,
  Future<Map<String, String>> Function()? localOverrides,
}) async {
  final resolvedFile =
      fileName ??
      EnvironmentConfig.fileNameForMode(
        buildMode ?? EnvironmentConfig.currentBuildMode(),
      );
  final source = dotenv ?? dotenvGlobal;
  AppEnvironment environment;
  try {
    await source.load(fileName: resolvedFile);
    final overrides = localOverrides != null
        ? await localOverrides()
        : (dotenv == null && kDebugMode
              ? await env_local.readEnvLocalOverrides()
              : const <String, String>{});
    environment = EnvironmentConfig.parse(
      fileName: resolvedFile,
      values: {...source.env, ...overrides},
    );
  } catch (error) {
    environment = AppEnvironment(
      name: EnvironmentConfig.nameForFile(resolvedFile),
      apiBaseUrl: '',
      authMode: AuthMode.disabled,
      allowInsecureHttp: false,
      configurationError: 'Could not load $resolvedFile (${error.runtimeType})',
    );
  }
  AppConfig.configure(environment);
  _logSafe(environment, resolvedFile);
  return environment;
}

/// The package-level `dotenv` instance, referenced through a named getter so the
/// loader stays injectable in tests.
DotEnv get dotenvGlobal => dotenv;

/// Debug-only, non-sensitive diagnostics. Never logs tokens, credentials or the
/// full URL (host only).
void _logSafe(AppEnvironment environment, String fileName) {
  if (!kDebugMode) return;
  debugPrint(
    '[env] file=$fileName name=${environment.name} '
    'mode=${environment.authMode.name} host=${environment.safeHost()} '
    'valid=${environment.isValid}',
  );
  final error = environment.configurationError;
  if (error != null) {
    debugPrint('[env] configuration error: $error');
  }
}
