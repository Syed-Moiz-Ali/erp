import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/services/overview/domain/services_dashboard.dart';
import 'package:modular_erp/modules/services/overview/domain/services_dashboard_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

class ServiceDashboardState {
  const ServiceDashboardState({
    this.loading = true,
    this.snapshot,
    this.failureCode,
  });
  final bool loading;
  final ServicesDashboardSnapshot? snapshot;
  final String? failureCode;

  bool get hasError => failureCode != null && snapshot == null;
}

/// Drives the Services operational dashboard from the read-only projection.
///
/// It holds exactly one subscription (the repository itself batches every
/// projection), and resubscribes when the company or the effective permission
/// set changes — so a company switch or a live grant/revoke recomputes the
/// whole dashboard without a re-login.
class ServiceDashboardCubit extends Cubit<ServiceDashboardState> {
  ServiceDashboardCubit(this.repository, AuthContext context)
    : _context = context,
      super(const ServiceDashboardState());

  final ServicesDashboardRepository repository;
  AuthContext _context;
  StreamSubscription<Result<ServicesDashboardSnapshot>>? _subscription;

  AuthContext get context => _context;

  void start() => _resubscribe();

  /// Recomputes only when the active company or the effective permissions
  /// actually changed (cheap identity check on a shared permission snapshot).
  void updateContext(AuthContext context) {
    final changed =
        context.company.id != _context.company.id ||
        context.user.id != _context.user.id ||
        !setEquals(
          context.user.permissions.values,
          _context.user.permissions.values,
        );
    if (!changed) return;
    _context = context;
    _resubscribe();
  }

  void retry() => _resubscribe();

  void _resubscribe() {
    unawaited(_subscription?.cancel());
    emit(const ServiceDashboardState(loading: true));
    _subscription = repository
        .watch(_context)
        .listen(
          (result) {
            if (isClosed) return;
            switch (result) {
              case Success<ServicesDashboardSnapshot>(:final value):
                emit(ServiceDashboardState(loading: false, snapshot: value));
              case Failed<ServicesDashboardSnapshot>(:final failure):
                emit(
                  ServiceDashboardState(
                    loading: false,
                    failureCode: failure.code,
                  ),
                );
            }
          },
          onError: (Object _) {
            if (isClosed) return;
            emit(const ServiceDashboardState(failureCode: 'servicesStorage'));
          },
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
