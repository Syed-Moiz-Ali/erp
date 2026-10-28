import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/app_config.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/core/errors/result.dart';

import 'package:modular_erp/platform/auth/data/repositories/disabled_auth_repository.dart';

void main() {
  group('auth mode selection', () {
    test('unconfigured builds are disabled (live-only)', () {
      expect(AppConfig.authMode, AuthMode.disabled);
      expect(AppConfig.realApiEnabled, isFalse);
    });
  });

  group('DisabledAuthRepository', () {
    const repository = DisabledAuthRepository();

    test('login fails with an explicit configuration error', () async {
      final result = await repository.login(
        AuthIdentifier.parse('Admin')!,
        'secret',
      );
      expect(result, isA<Failed>());
      final failure = (result as Failed).failure;
      expect(failure.code, 'auth_not_configured');
      expect(failure.kind, FailureKind.notConfigured);
    });

    test('never restores or checks a session', () async {
      expect(await repository.restoreSession(), isA<Success>());
      expect((await repository.restoreSession() as Success).value, isNull);
      expect((await repository.checkSession() as Success).value, isNull);
    });

    test('logout is a safe no-op', () async {
      expect(await repository.logout(), isA<Success>());
    });

    test('password operations fail explicitly', () async {
      expect(
        await repository.requestPasswordReset(AuthIdentifier.parse('Admin')!),
        isA<Failed>(),
      );
      expect(await repository.changePassword('a', 'b'), isA<Failed>());
    });

    test('emits no session changes', () async {
      expect(await repository.sessionChanges.isEmpty, isTrue);
    });
  });
}

