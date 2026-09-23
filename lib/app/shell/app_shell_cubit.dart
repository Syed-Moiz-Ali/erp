import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/preferences/app_preferences_repository.dart';

class AppShellState {
  const AppShellState({this.collapsed = false, this.failure});
  final bool collapsed;
  final Failure? failure;
}

/// Presentation preferences only. Selection and branch history stay in GoRouter.
class AppShellCubit extends Cubit<AppShellState> {
  AppShellCubit([this.preferences]) : super(const AppShellState());
  final AppPreferencesRepository? preferences;
  Future<void>? _writes;
  Future<void> restore() async {
    if (preferences == null) return;
    switch (await preferences!.readSidebarCollapsed()) {
      case Success<bool?>(:final value):
        emit(AppShellState(collapsed: value ?? false));
      case Failed<bool?>(:final failure):
        emit(AppShellState(failure: failure));
    }
  }

  Future<void> toggle() {
    final collapsed = !state.collapsed;
    emit(AppShellState(collapsed: collapsed));
    if (preferences == null) return Future.value();
    _writes = (_writes ?? Future<void>.value()).then((_) async {
      final result = await preferences!.saveSidebarCollapsed(collapsed);
      if (!isClosed && state.collapsed == collapsed) {
        emit(
          AppShellState(
            collapsed: collapsed,
            failure: result is Failed<void> ? result.failure : null,
          ),
        );
      }
    });
    return _writes!;
  }

  @override
  Future<void> close() async {
    if (_writes != null) await _writes;
    await super.close();
  }
}
