import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/connectivity/connectivity_service.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/preferences/app_preferences_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'outbox_repository.dart';

/// Global, quiet-by-default sync status surfaced by the shell indicator.
class AppSyncStatusState {
  const AppSyncStatusState({
    this.counts = const OutboxCounts(),
    this.offline = false,
    this.syncing = false,
    this.serverUnavailable = false,
    this.lastSyncedAt,
    this.lastErrorCategory,
  });

  final OutboxCounts counts;
  final bool offline;
  final bool syncing;
  final bool serverUnavailable;
  final DateTime? lastSyncedAt;
  final String? lastErrorCategory;

  bool get quiet => counts.quiet && !offline && !syncing && !serverUnavailable;

  AppSyncStatusState copyWith({
    OutboxCounts? counts,
    bool? offline,
    bool? syncing,
    bool? serverUnavailable,
    DateTime? lastSyncedAt,
    String? lastErrorCategory,
    bool clearError = false,
  }) => AppSyncStatusState(
    counts: counts ?? this.counts,
    offline: offline ?? this.offline,
    syncing: syncing ?? this.syncing,
    serverUnavailable: serverUnavailable ?? this.serverUnavailable,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    lastErrorCategory: clearError
        ? null
        : lastErrorCategory ?? this.lastErrorCategory,
  );
}

class AppSyncStatusCubit extends Cubit<AppSyncStatusState> {
  AppSyncStatusCubit({
    required this.outbox,
    required this.connectivity,
    required this.preferences,
    required this.auth,
    this.clock = DateTime.now,
  }) : super(const AppSyncStatusState());

  final OutboxLocalDataSource outbox;
  final ConnectivityService connectivity;
  final AppPreferencesRepository preferences;
  final AuthRepository auth;
  final DateTime Function() clock;

  StreamSubscription<AuthContext?>? _authSub;
  StreamSubscription<bool>? _connectivitySub;
  StreamSubscription<OutboxCounts>? _countsSub;

  Future<void> start() async {
    _authSub = auth.sessionChanges.listen((_) => unawaited(_rebind()));
    _connectivitySub = connectivity.changes.listen(
      (online) => emit(state.copyWith(offline: !online)),
    );
    final connected = await connectivity.isConnected;
    if (!isClosed) emit(state.copyWith(offline: !connected));
    await _rebind();
  }

  Future<void> _rebind() async {
    await _countsSub?.cancel();
    _countsSub = null;
    if (isClosed) return;
    final session = await auth.checkSession();
    if (isClosed) return;
    final context = session is Success<AuthContext?> ? session.value : null;
    if (context == null) {
      emit(const AppSyncStatusState());
      return;
    }
    final companyId = context.company.id;
    final last = await preferences.readLastSyncAt();
    if (isClosed) return;
    if (last is Success<DateTime?>) {
      emit(state.copyWith(lastSyncedAt: last.value));
    }
    _countsSub = outbox.watchCounts(companyId: companyId).listen((counts) {
      if (!isClosed) {
        emit(
          state.copyWith(
            counts: counts,
            syncing: counts.processing > 0,
            clearError: counts.quiet,
          ),
        );
      }
    });
  }

  void reportProgress({required bool syncing}) {
    if (!isClosed) emit(state.copyWith(syncing: syncing));
  }

  Future<void> reportSuccess(DateTime at) async {
    await preferences.saveLastSyncAt(at);
    if (!isClosed) {
      emit(state.copyWith(syncing: false, lastSyncedAt: at, clearError: true));
    }
  }

  void reportError(String category) {
    if (!isClosed) {
      emit(state.copyWith(syncing: false, lastErrorCategory: category));
    }
  }

  /// Wired by bootstrap to trigger eligible queue processing on demand.
  Future<void> Function()? onSyncNow;

  Future<void> syncNow() async {
    final trigger = onSyncNow;
    if (trigger == null) return;
    reportProgress(syncing: true);
    await trigger();
  }

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    await _connectivitySub?.cancel();
    await _countsSub?.cancel();
    return super.close();
  }
}
