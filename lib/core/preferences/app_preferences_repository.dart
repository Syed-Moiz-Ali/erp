import 'package:shared_preferences/shared_preferences.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_language.dart';

/// Non-sensitive reminder + sync metadata persisted as plain preferences.
/// Never store tokens, passwords or GPS here.
class ReminderPreferences {
  const ReminderPreferences({
    this.shiftReminderEnabled = false,
    this.shiftReminderMinutesBefore = 15,
    this.punchOutReminderEnabled = false,
  });
  final bool shiftReminderEnabled;
  final int shiftReminderMinutesBefore;
  final bool punchOutReminderEnabled;

  ReminderPreferences copyWith({
    bool? shiftReminderEnabled,
    int? shiftReminderMinutesBefore,
    bool? punchOutReminderEnabled,
  }) => ReminderPreferences(
    shiftReminderEnabled: shiftReminderEnabled ?? this.shiftReminderEnabled,
    shiftReminderMinutesBefore:
        shiftReminderMinutesBefore ?? this.shiftReminderMinutesBefore,
    punchOutReminderEnabled:
        punchOutReminderEnabled ?? this.punchOutReminderEnabled,
  );
}

abstract interface class AppPreferencesLocalDataSource {
  Future<String?> readLanguageCode();
  Future<bool?> readSidebarCollapsed();
  Future<void> writeSidebarCollapsed(bool value);
  Future<void> writeLanguageCode(String code);
  Future<bool?> readShiftReminderEnabled();
  Future<void> writeShiftReminderEnabled(bool value);
  Future<int?> readShiftReminderMinutesBefore();
  Future<void> writeShiftReminderMinutesBefore(int value);
  Future<bool?> readPunchOutReminderEnabled();
  Future<void> writePunchOutReminderEnabled(bool value);
  Future<String?> readLastSyncAt();
  Future<void> writeLastSyncAt(String value);
}

class SharedPreferencesLocalDataSource
    implements AppPreferencesLocalDataSource {
  SharedPreferencesLocalDataSource(this.preferences);
  final SharedPreferencesAsync preferences;
  static const _localeKey = 'app.preferences.language';
  static const _shiftReminderKey = 'app.preferences.reminder.shift';
  static const _shiftMinutesKey = 'app.preferences.reminder.shiftMinutes';
  static const _punchOutReminderKey = 'app.preferences.reminder.punchOut';
  static const _lastSyncKey = 'app.preferences.sync.lastAt';

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

  @override
  Future<bool?> readShiftReminderEnabled() =>
      preferences.getBool(_shiftReminderKey);
  @override
  Future<void> writeShiftReminderEnabled(bool value) =>
      preferences.setBool(_shiftReminderKey, value);
  @override
  Future<int?> readShiftReminderMinutesBefore() =>
      preferences.getInt(_shiftMinutesKey);
  @override
  Future<void> writeShiftReminderMinutesBefore(int value) =>
      preferences.setInt(_shiftMinutesKey, value);
  @override
  Future<bool?> readPunchOutReminderEnabled() =>
      preferences.getBool(_punchOutReminderKey);
  @override
  Future<void> writePunchOutReminderEnabled(bool value) =>
      preferences.setBool(_punchOutReminderKey, value);
  @override
  Future<String?> readLastSyncAt() => preferences.getString(_lastSyncKey);
  @override
  Future<void> writeLastSyncAt(String value) =>
      preferences.setString(_lastSyncKey, value);
}

abstract interface class AppPreferencesRepository {
  Future<Result<AppLanguage?>> readLanguage();
  Future<Result<bool?>> readSidebarCollapsed();
  Future<Result<void>> saveSidebarCollapsed(bool value);
  Future<Result<void>> saveLanguage(AppLanguage language);
  Future<Result<ReminderPreferences>> readReminderPreferences();
  Future<Result<void>> saveReminderPreferences(ReminderPreferences value);
  Future<Result<DateTime?>> readLastSyncAt();
  Future<Result<void>> saveLastSyncAt(DateTime value);
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

  @override
  Future<Result<ReminderPreferences>> readReminderPreferences() async {
    try {
      final enabled = await local.readShiftReminderEnabled();
      final minutes = await local.readShiftReminderMinutesBefore();
      final punchOut = await local.readPunchOutReminderEnabled();
      return Success(
        ReminderPreferences(
          shiftReminderEnabled: enabled ?? false,
          shiftReminderMinutesBefore: (minutes ?? 15).clamp(5, 120),
          punchOutReminderEnabled: punchOut ?? false,
        ),
      );
    } catch (_) {
      return const Failed(
        Failure(
          code: 'reminder_preferences_read',
          kind: FailureKind.preferencesRead,
        ),
      );
    }
  }

  @override
  Future<Result<void>> saveReminderPreferences(
    ReminderPreferences value,
  ) async {
    try {
      await local.writeShiftReminderEnabled(value.shiftReminderEnabled);
      await local.writeShiftReminderMinutesBefore(
        value.shiftReminderMinutesBefore.clamp(5, 120),
      );
      await local.writePunchOutReminderEnabled(value.punchOutReminderEnabled);
      return const Success(null);
    } catch (_) {
      return const Failed(
        Failure(
          code: 'reminder_preferences_write',
          kind: FailureKind.preferencesWrite,
        ),
      );
    }
  }

  @override
  Future<Result<DateTime?>> readLastSyncAt() async {
    try {
      final raw = await local.readLastSyncAt();
      return Success(raw == null ? null : DateTime.tryParse(raw)?.toUtc());
    } catch (_) {
      return const Failed(
        Failure(code: 'sync_meta_read', kind: FailureKind.preferencesRead),
      );
    }
  }

  @override
  Future<Result<void>> saveLastSyncAt(DateTime value) async {
    try {
      await local.writeLastSyncAt(value.toUtc().toIso8601String());
      return const Success(null);
    } catch (_) {
      return const Failed(
        Failure(code: 'sync_meta_write', kind: FailureKind.preferencesWrite),
      );
    }
  }
}
