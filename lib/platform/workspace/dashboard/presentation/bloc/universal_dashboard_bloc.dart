import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/workspace/dashboard/domain/dashboard_contribution.dart';
import 'package:modular_erp/platform/workspace/dashboard/domain/dashboard_contributor.dart';

sealed class UniversalDashboardEvent {
  const UniversalDashboardEvent();
}

final class UniversalDashboardStarted extends UniversalDashboardEvent {
  const UniversalDashboardStarted();
}

final class UniversalDashboardRefreshRequested extends UniversalDashboardEvent {
  const UniversalDashboardRefreshRequested();
}

enum UniversalDashboardStatus {
  initial,
  loading,
  ready,
  partial,
  refreshing,
  failure,
}

class UniversalDashboardState {
  const UniversalDashboardState({
    this.status = UniversalDashboardStatus.initial,
    this.snapshot,
    this.failure,
  });

  final UniversalDashboardStatus status;
  final UniversalDashboardSnapshot? snapshot;
  final Failure? failure;

  bool get isBusy =>
      status == UniversalDashboardStatus.loading ||
      status == UniversalDashboardStatus.refreshing;
}

/// Single dashboard bloc: loads every registered contributor through the
/// coordinator and exposes loading / ready / partial / refreshing / failure.
class UniversalDashboardBloc
    extends Bloc<UniversalDashboardEvent, UniversalDashboardState> {
  UniversalDashboardBloc(this.coordinator, this.context, this.l10n)
    : super(const UniversalDashboardState()) {
    on<UniversalDashboardStarted>(_load);
    on<UniversalDashboardRefreshRequested>(_load);
  }

  final UniversalDashboardCoordinator coordinator;
  final AuthContext context;
  final AppLocalizations l10n;

  Future<void> _load(
    UniversalDashboardEvent event,
    Emitter<UniversalDashboardState> emit,
  ) async {
    final previous = state.snapshot;
    emit(
      UniversalDashboardState(
        status: previous == null
            ? UniversalDashboardStatus.loading
            : UniversalDashboardStatus.refreshing,
        snapshot: previous,
      ),
    );
    UniversalDashboardSnapshot snapshot;
    try {
      snapshot = await coordinator.load(
        DashboardCapabilityContext(auth: context, l10n: l10n),
      );
    } catch (_) {
      if (emit.isDone) return;
      emit(
        UniversalDashboardState(
          status: previous == null
              ? UniversalDashboardStatus.failure
              : UniversalDashboardStatus.ready,
          snapshot: previous,
          failure: const Failure(code: 'dashboard.load', retryable: true),
        ),
      );
      return;
    }
    if (emit.isDone) return;
    emit(
      UniversalDashboardState(
        status: snapshot.partialFailure
            ? UniversalDashboardStatus.partial
            : UniversalDashboardStatus.ready,
        snapshot: snapshot,
      ),
    );
  }
}
