import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/core/validation/app_validation.dart';

void main() {
  test('accepts a backend login id verbatim', () {
    final identifier = AuthIdentifier.parse('Admin');
    expect(identifier, isNotNull);
    expect(identifier!.type, AuthIdentifierType.loginId);
    expect(identifier.value, 'Admin');
  });

  test('login ids are case-sensitive and preserve dots/dashes', () {
    expect(AuthIdentifier.parse('Admin.User-1')!.value, 'Admin.User-1');
  });

  test('still normalizes email and phone', () {
    expect(AuthIdentifier.parse(' HR@ERP.DEMO ')!.value, 'hr@erp.demo');
    expect(
      AuthIdentifier.parse(' HR@ERP.DEMO ')!.type,
      AuthIdentifierType.email,
    );
    expect(AuthIdentifier.parse('+1 (555) 000-1003')!.value, '+15550001003');
    expect(
      AuthIdentifier.parse('+1 (555) 000-1003')!.type,
      AuthIdentifierType.phone,
    );
  });

  test('rejects whitespace and too-short input', () {
    expect(AuthIdentifier.parse('not a phone'), isNull);
    expect(AuthIdentifier.parse('+12'), isNull);
    expect(AuthIdentifier.parse('ab'), isNull);
    expect(AuthIdentifier.parse(''), isNull);
  });

  test('the login form validation accepts a login id', () {
    expect(AppValidation.identifier('Admin'), isNull);
    expect(AppValidation.identifier(''), ValidationIssue.identifierRequired);
    expect(
      AppValidation.identifier('not a phone'),
      ValidationIssue.identifierInvalid,
    );
  });
}
