import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/dashboard/domain/dashboard_models.dart';
import 'package:modular_erp/platform/dashboard/domain/dashboard_repository.dart';

sealed class DashboardEvent {
  const DashboardEvent();
}

final class DashboardStarted extends DashboardEvent {
  const DashboardStarted();
}

final class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();
}

enum DashboardStatus { initial, loading, loaded, refreshing, failure }

class DashboardState {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.summary,
    this.failure,
  });
  final DashboardStatus status;
  final DashboardSummary? summary;
  final Failure? failure;
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this.repository, this.context) : super(const DashboardState()) {
    on<DashboardEvent>(
      _load,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }
  final DashboardRepository repository;
  final AuthContext context;
  bool _queued = false;
  @override
  void add(DashboardEvent event) {
    // Coalesce rapid refresh/start submissions. One local read at a time.
    if (isClosed || _queued) return;
    _queued = true;
    super.add(event);
  }

  Future<void> _load(DashboardEvent event, Emitter<DashboardState> emit) async {
    final previous = state.summary;
    emit(
      DashboardState(
        status: previous == null
            ? DashboardStatus.loading
            : DashboardStatus.refreshing,
        summary: previous,
      ),
    );
    Result<DashboardSummary> result;
    try {
      result = await repository.load(
        context,
        refresh: event is DashboardRefreshRequested,
      );
    } catch (_) {
      result = const Failed(Failure(code: 'dashboard.load', retryable: true));
    }
    if (emit.isDone) return;
    switch (result) {
      case Success<DashboardSummary>(:final value):
        emit(DashboardState(status: DashboardStatus.loaded, summary: value));
      case Failed<DashboardSummary>(:final failure):
        emit(
          DashboardState(
            status: previous == null
                ? DashboardStatus.failure
                : DashboardStatus.loaded,
            summary: previous,
            failure: failure,
          ),
        );
    }
    _queued = false;
  }
}
