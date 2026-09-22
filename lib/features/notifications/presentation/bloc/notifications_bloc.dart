import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/app_clock.dart';
import '../../../auth/domain/entities/auth_context.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/app_notification.dart';
import '../../domain/notification_repository.dart';

sealed class NotificationsEvent {
  const NotificationsEvent();
}

final class NotificationsStarted extends NotificationsEvent {
  const NotificationsStarted();
}

final class NotificationsUpdated extends NotificationsEvent {
  const NotificationsUpdated(this.items);
  final List<AppNotification> items;
}

final class NotificationsFailed extends NotificationsEvent {
  const NotificationsFailed();
}

final class NotificationReadRequested extends NotificationsEvent {
  const NotificationReadRequested(this.id);
  final String id;
}

final class NotificationsMarkAllReadRequested extends NotificationsEvent {
  const NotificationsMarkAllReadRequested();
}

class NotificationsState {
  const NotificationsState({
    this.loading = true,
    this.items = const [],
    this.unread = 0,
    this.failure,
  });
  final bool loading;
  final List<AppNotification> items;
  final int unread;
  final Failure? failure;
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc(
    this.repository,
    this.auth, {
    this.clock = const SystemAppClock(),
  }) : super(const NotificationsState()) {
    // The repository stream is bridged into events so emits stay inside
    // handlers; a bare listener would emit after the handler completed.
    on<NotificationsStarted>((event, emit) => _bind(emit));
    on<NotificationsUpdated>((event, emit) {
      emit(
        NotificationsState(
          loading: false,
          items: event.items,
          unread: event.items.where((n) => !n.isRead).length,
        ),
      );
    });
    on<NotificationsFailed>((event, emit) {
      emit(
        const NotificationsState(
          loading: false,
          failure: Failure(code: 'notificationsFailed'),
        ),
      );
    });
    on<NotificationReadRequested>((event, emit) async {
      final context = await _context();
      if (context == null || isClosed) return;
      await repository.markRead(
        companyId: context.company.id,
        userId: context.user.id,
        id: event.id,
        at: clock.now().toUtc(),
      );
    });
    on<NotificationsMarkAllReadRequested>((event, emit) async {
      final context = await _context();
      if (context == null || isClosed) return;
      await repository.markAllRead(
        companyId: context.company.id,
        userId: context.user.id,
        at: clock.now().toUtc(),
      );
    });
  }

  final NotificationRepository repository;
  final AuthRepository auth;
  final AppClock clock;
  StreamSubscription<List<AppNotification>>? _subscription;

  Future<AuthContext?> _context() async {
    final result = await auth.checkSession();
    return result is Success<AuthContext?> ? result.value : null;
  }

  Future<void> _bind(Emitter<NotificationsState> emit) async {
    await _subscription?.cancel();
    if (emit.isDone) return;
    final context = await _context();
    if (emit.isDone) return;
    if (context == null) {
      emit(const NotificationsState(loading: false));
      return;
    }
    _subscription = repository
        .watchNotifications(
          companyId: context.company.id,
          userId: context.user.id,
        )
        .listen(
          (items) {
            if (!isClosed) add(NotificationsUpdated(items));
          },
          onError: (_) {
            if (!isClosed) add(const NotificationsFailed());
          },
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
