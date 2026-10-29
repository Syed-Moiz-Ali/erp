import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/app_config.dart';
import 'package:modular_erp/app/app_environment.dart';
import 'package:modular_erp/app/environment_loader.dart';

AppEnvironment parseDev(Map<String, String> values) => EnvironmentConfig.parse(
  fileName: EnvironmentConfig.developmentFile,
  values: values,
);

AppEnvironment parseProd(Map<String, String> values) => EnvironmentConfig.parse(
  fileName: EnvironmentConfig.productionFile,
  values: values,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(AppConfig.reset);
  tearDown(AppConfig.reset);

  group('build-mode selection', () {
    test('debug uses development, profile and release use production', () {
      expect(
        EnvironmentConfig.fileNameForMode(FlutterBuildMode.debug),
        '.env.development',
      );
      expect(
        EnvironmentConfig.fileNameForMode(FlutterBuildMode.profile),
        '.env.production',
      );
      expect(
        EnvironmentConfig.fileNameForMode(FlutterBuildMode.release),
        '.env.production',
      );
    });
  });

  group('development parsing', () {
    test('accepts a valid HTTPS backend', () {
      final env = parseDev({
        'API_BASE_URL': 'https://dev-tunnel.ngrok-free.app',
        'AUTH_MODE': 'backend',
      });
      expect(env.isValid, isTrue);
      expect(env.name, 'development');
      expect(env.authMode, AuthMode.backend);
      expect(env.apiBaseUrl, 'https://dev-tunnel.ngrok-free.app');
      expect(env.allowInsecureHttp, isTrue); // debug build
    });

    test('accepts loopback HTTP but rejects non-loopback HTTP', () {
      expect(
        parseDev({
          'API_BASE_URL': 'http://localhost:5257',
          'AUTH_MODE': 'backend',
        }).isValid,
        isTrue,
      );
      expect(
        parseDev({
          'API_BASE_URL': 'http://10.0.0.5:5257',
          'AUTH_MODE': 'backend',
        }).isValid,
        isFalse,
      );
    });

    test('allows explicit demo without a URL', () {
      final env = parseDev({'AUTH_MODE': 'demo'});
      expect(env.isValid, isTrue);
      expect(env.authMode, AuthMode.demo);
      expect(env.apiBaseUrl, '');
    });
  });

  group('production parsing', () {
    test('accepts a valid HTTPS backend', () {
      final env = parseProd({
        'API_BASE_URL': 'https://api.mass-erp.com',
        'AUTH_MODE': 'backend',
      });
      expect(env.isValid, isTrue);
      expect(env.name, 'production');
      expect(env.authMode, AuthMode.backend);
      expect(env.allowInsecureHttp, isFalse);
    });

    test('rejects placeholder, loopback, private and HTTP URLs', () {
      for (final url in [
        'https://api.yourdomain.com',
        'https://api.example.com',
        'https://localhost',
        'https://127.0.0.1',
        'https://10.0.0.5',
        'https://192.168.1.10',
        'https://172.16.4.4',
        'http://api.mass-erp.com',
        'https://some-tunnel.ngrok-free.app',
      ]) {
        final env = parseProd({'API_BASE_URL': url, 'AUTH_MODE': 'backend'});
        expect(env.isValid, isFalse, reason: url);
        expect(env.authMode, AuthMode.disabled, reason: url);
        expect(env.apiBaseUrl, '', reason: url);
        expect(env.configurationError, isNotNull, reason: url);
      }
    });

    test('rejects demo mode', () {
      final env = parseProd({
        'API_BASE_URL': 'https://api.mass-erp.com',
        'AUTH_MODE': 'demo',
      });
      expect(env.isValid, isFalse);
      expect(env.authMode, AuthMode.disabled);
    });
  });

  group('invalid configuration fails safely', () {
    test('backend without a URL is invalid and disabled', () {
      final env = parseDev({'AUTH_MODE': 'backend'});
      expect(env.isValid, isFalse);
      expect(env.authMode, AuthMode.disabled);
    });

    test('missing AUTH_MODE is invalid', () {
      final env = parseDev({
        'API_BASE_URL': 'https://dev-tunnel.ngrok-free.app',
      });
      expect(env.isValid, isFalse);
      expect(env.authMode, AuthMode.disabled);
    });

    test('malformed / relative / query URLs are rejected', () {
      for (final url in [
        'not-a-url',
        'https://',
        'https://host.test?x=1',
        'https://host.test#frag',
      ]) {
        final env = parseDev({'API_BASE_URL': url, 'AUTH_MODE': 'backend'});
        expect(env.isValid, isFalse, reason: url);
        expect(env.authMode, AuthMode.disabled, reason: url);
      }
    });

    test('an unknown AUTH_MODE is rejected', () {
      final env = parseDev({
        'API_BASE_URL': 'https://dev-tunnel.ngrok-free.app',
        'AUTH_MODE': 'production',
      });
      expect(env.isValid, isFalse);
    });
  });

  group('URL normalization', () {
    test('keeps the host, strips trailing slash and preserves a base path', () {
      expect(
        parseDev({
          'API_BASE_URL': 'https://dev-tunnel.ngrok-free.app/',
          'AUTH_MODE': 'backend',
        }).apiBaseUrl,
        'https://dev-tunnel.ngrok-free.app',
      );
      expect(
        parseDev({
          'API_BASE_URL': 'https://gateway.test/mass/',
          'AUTH_MODE': 'backend',
        }).apiBaseUrl,
        'https://gateway.test/mass',
      );
    });

    test('safeHost exposes only the host', () {
      final env = parseDev({
        'API_BASE_URL': 'https://dev-tunnel.ngrok-free.app',
        'AUTH_MODE': 'backend',
      });
      expect(env.safeHost(), 'dev-tunnel.ngrok-free.app');
      // Diagnostics expose only the host, never the full URL.
      expect(env.toString(), isNot(contains('https://')));
    });
  });

  group('AppConfig injection', () {
    test('configure exposes the environment, reset restores defaults', () {
      AppConfig.configure(
        const AppEnvironment(
          name: EnvironmentConfig.developmentName,
          apiBaseUrl: 'https://dev-tunnel.ngrok-free.app',
          authMode: AuthMode.backend,
          allowInsecureHttp: false,
        ),
      );
      expect(AppConfig.environmentName, 'development');
      expect(AppConfig.apiBaseUrl, 'https://dev-tunnel.ngrok-free.app');
      expect(AppConfig.authMode, AuthMode.backend);
      expect(AppConfig.realApiEnabled, isTrue);
      expect(AppConfig.demoMode, isFalse);
      expect(AppConfig.configurationValid, isTrue);

      AppConfig.reset();
      // Debug default is demo so existing local-first tests keep working.
      expect(AppConfig.authMode, AuthMode.demo);
      expect(AppConfig.realApiEnabled, isFalse);
    });
  });

  group('loadEnvironment', () {
    Future<Map<String, String>> noOverrides() async => const <String, String>{};

    test('committed development placeholders load in demo mode', () async {
      final env = await loadEnvironment(
        fileName: EnvironmentConfig.developmentFile,
        localOverrides: noOverrides,
      );
      expect(env.name, 'development');
      expect(env.authMode, AuthMode.demo);
      expect(env.isValid, isTrue);
      expect(env.apiBaseUrl, isEmpty);
      expect(AppConfig.realApiEnabled, isFalse);
    });

    test('an untracked .env.local overlay selects backend mode', () async {
      final env = await loadEnvironment(
        fileName: EnvironmentConfig.developmentFile,
        localOverrides: () async => const {
          'API_BASE_URL': 'https://dev-tunnel.ngrok-free.app',
          'AUTH_MODE': 'backend',
        },
      );
      expect(env.authMode, AuthMode.backend);
      expect(env.isValid, isTrue);
      expect(AppConfig.apiBaseUrl, 'https://dev-tunnel.ngrok-free.app');
      expect(AppConfig.realApiEnabled, isTrue);
    });

    test('committed production placeholders stay safely disabled', () async {
      final env = await loadEnvironment(
        fileName: EnvironmentConfig.productionFile,
        localOverrides: noOverrides,
      );
      expect(env.name, 'production');
      expect(env.isValid, isTrue);
      expect(env.authMode, AuthMode.disabled);
      expect(env.apiBaseUrl, isEmpty);
      expect(AppConfig.configurationValid, isTrue);
      expect(AppConfig.realApiEnabled, isFalse);
    });

    test('a missing file fails safely without demo fallback', () async {
      final env = await loadEnvironment(
        fileName: '.env.does-not-exist',
        localOverrides: noOverrides,
      );
      expect(env.isValid, isFalse);
      expect(env.authMode, AuthMode.disabled);
      expect(env.configurationError, isNotNull);
      expect(AppConfig.authMode, AuthMode.disabled);
    });
  });
}
