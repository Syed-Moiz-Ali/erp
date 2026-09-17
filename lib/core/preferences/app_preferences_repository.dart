import 'package:shared_preferences/shared_preferences.dart';
import '../errors/result.dart';
import '../localization/app_language.dart';

abstract interface class AppPreferencesLocalDataSource {
  Future<String?> readLanguageCode();
  Future<bool?> readSidebarCollapsed();
  Future<void> writeSidebarCollapsed(bool value);
  Future<void> writeLanguageCode(String code);
}

class SharedPreferencesLocalDataSource
    implements AppPreferencesLocalDataSource {
  SharedPreferencesLocalDataSource(this.preferences);
  final SharedPreferencesAsync preferences;
  static const _localeKey = 'app.preferences.language';

  @override
  Future<bool?> readSidebarCollapsed() =>
      preferences.getBool('app.preferences.sidebarCollapsed');
  @override
  Future<void> writeSidebarCollapsed(bool value) =>
      preferences.setBool('app.preferences.sidebarCollapsed', value);
  @override
  Future<String?> readLanguageCode() => preferences.getString(_localeKey);

  @override
  Future<void> writeLanguageCode(String code) =>
      preferences.setString(_localeKey, code);
}

abstract interface class AppPreferencesRepository {
  Future<Result<AppLanguage?>> readLanguage();
  Future<Result<bool?>> readSidebarCollapsed();
  Future<Result<void>> saveSidebarCollapsed(bool value);
  Future<Result<void>> saveLanguage(AppLanguage language);
}

class LocalAppPreferencesRepository implements AppPreferencesRepository {
  LocalAppPreferencesRepository(this.local);
  final AppPreferencesLocalDataSource local;

  @override
  Future<Result<bool?>> readSidebarCollapsed() async {
    try {
      return Success(
        await local.readSidebarCollapsed().timeout(const Duration(seconds: 2)),
      );
    } catch (_) {
      return const Failed(
        Failure(
          code: 'shell_preferences_read',
          kind: FailureKind.preferencesRead,
        ),
      );
    }
  }

  @override
  Future<Result<void>> saveSidebarCollapsed(bool value) async {
    try {
      await local.writeSidebarCollapsed(value);
      return const Success(null);
    } catch (_) {
      return const Failed(
        Failure(
          code: 'shell_preferences_write',
          kind: FailureKind.preferencesWrite,
        ),
      );
    }
  }

  @override
  Future<Result<AppLanguage?>> readLanguage() async {
    try {
      final code = await local.readLanguageCode().timeout(
        const Duration(seconds: 2),
      );
      return Success(AppLanguage.fromCode(code));
    } catch (_) {
      return const Failed(
        Failure(code: 'preferences_read', kind: FailureKind.preferencesRead),
      );
    }
  }

  @override
  Future<Result<void>> saveLanguage(AppLanguage language) async {
    try {
      await local.writeLanguageCode(language.locale.languageCode);
      return const Success(null);
    } catch (_) {
      return const Failed(
        Failure(code: 'preferences_write', kind: FailureKind.preferencesWrite),
      );
    }
  }
}
