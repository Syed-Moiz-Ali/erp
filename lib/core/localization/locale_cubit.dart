import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../errors/result.dart';
import '../preferences/app_preferences_repository.dart';
import 'app_language.dart';

class LocaleState {
  const LocaleState({this.language = AppLanguage.english, this.failure});
  final AppLanguage language;
  final Failure? failure;
  Locale get locale => language.locale;
}

/// Application-scoped presentation state. Navigation and feature state are
/// deliberately independent from locale changes.
class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit(this.preferences) : super(const LocaleState());
  final AppPreferencesRepository preferences;
  List<AppLanguage> get supportedLanguages => AppLanguage.values;
  Future<void>? _writes;

  Future<void> restore(Iterable<Locale> deviceLocales) async {
    final result = await preferences.readLanguage();
    if (isClosed) return;
    switch (result) {
      case Success<AppLanguage?>(:final value):
        emit(
          LocaleState(language: value ?? AppLanguage.resolve(deviceLocales)),
        );
      case Failed<AppLanguage?>(:final failure):
        emit(
          LocaleState(
            language: AppLanguage.resolve(deviceLocales),
            failure: failure,
          ),
        );
    }
  }

  Future<void> changeLanguage(AppLanguage language) {
    if (isClosed || language == state.language && state.failure == null) {
      return _writes ?? Future.value();
    }
    emit(LocaleState(language: language));
    // Serialize rapid selections so the final stored preference matches the UI.
    _writes = (_writes ?? Future.value()).then((_) async {
      final result = await preferences.saveLanguage(language);
      if (!isClosed && state.language == language) {
        switch (result) {
          case Failed<void>(:final failure):
            emit(LocaleState(language: language, failure: failure));
          case Success<void>():
            if (state.failure != null) emit(LocaleState(language: language));
        }
      }
    });
    return _writes ?? Future.value();
  }

  @override
  Future<void> close() async {
    if (_writes != null) await _writes;
    return super.close();
  }
}
