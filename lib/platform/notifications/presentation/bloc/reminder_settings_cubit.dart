import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/preferences/app_preferences_repository.dart';
import 'package:modular_erp/platform/notifications/domain/device_notification_service.dart';

class ReminderSettingsState {
  const ReminderSettingsState({
    this.loading = true,
    this.saving = false,
    this.saved = false,
    this.preferences = const ReminderPreferences(),
    this.permission = DeviceNotificationPermission.unsupported,
    this.failure,
  });
  final bool loading, saving, saved;
  final ReminderPreferences preferences;
  final DeviceNotificationPermission permission;
  final Failure? failure;

  ReminderSettingsState copyWith({
    bool? loading,
    bool? saving,
    bool? saved,
    ReminderPreferences? preferences,
    DeviceNotificationPermission? permission,
    Failure? failure,
    bool clearFailure = false,
  }) => ReminderSettingsState(
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
    preferences: preferences ?? this.preferences,
    permission: permission ?? this.permission,
    failure: clearFailure ? null : failure ?? this.failure,
  );
}

class ReminderSettingsCubit extends Cubit<ReminderSettingsState> {
  ReminderSettingsCubit(this.preferences, this.device, {this.onChanged})
    : super(const ReminderSettingsState());

  final AppPreferencesRepository preferences;
  final DeviceNotificationService device;
  final Future<void> Function()? onChanged;

  Future<void> load() async {
    final result = await preferences.readReminderPreferences();
    final permission = await device.permissionStatus();
    if (isClosed) return;
    if (result is Failed<ReminderPreferences>) {
      emit(state.copyWith(loading: false, failure: result.failure));
      return;
    }
    emit(
      state.copyWith(
        loading: false,
        preferences: (result as Success<ReminderPreferences>).value,
        permission: permission,
        clearFailure: true,
      ),
    );
  }

  Future<void> setShiftEnabled(bool value) => _save(
    state.preferences.copyWith(shiftReminderEnabled: value),
    request: value,
  );

  Future<void> setMinutes(int value) =>
      _save(state.preferences.copyWith(shiftReminderMinutesBefore: value));

  Future<void> setPunchOutEnabled(bool value) => _save(
    state.preferences.copyWith(punchOutReminderEnabled: value),
    request: value,
  );

  Future<void> _save(ReminderPreferences next, {bool request = false}) async {
    // Request permission only at a sensible moment: when the user enables one.
    if (request &&
        state.permission != DeviceNotificationPermission.granted &&
        state.permission != DeviceNotificationPermission.unsupported) {
      final result = await device.requestPermission();
      if (isClosed) return;
      emit(state.copyWith(permission: result));
    }
    emit(state.copyWith(saving: true, clearFailure: true));
    final saved = await preferences.saveReminderPreferences(next);
    if (isClosed) return;
    if (saved is Failed<void>) {
      emit(state.copyWith(saving: false, failure: saved.failure));
      return;
    }
    emit(state.copyWith(saving: false, saved: true, preferences: next));
    await onChanged?.call();
  }

  Future<void> openSettings() => device.openSettings();
}
