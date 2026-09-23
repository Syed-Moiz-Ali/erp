import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/platform/notifications/domain/notification_repository.dart';

/// Unread notification count for the shell bell. Reacts to session changes.
class NotificationBadgeCubit extends Cubit<int> {
  NotificationBadgeCubit(this.repository, this.auth) : super(0);

  final NotificationRepository repository;
  final AuthRepository auth;
  StreamSubscription<AuthContext?>? _authSub;
  StreamSubscription<int>? _countSub;

  Future<void> start() async {
    _authSub = auth.sessionChanges.listen((_) => unawaited(_bind()));
    await _bind();
  }

  Future<void> _bind() async {
    await _countSub?.cancel();
    _countSub = null;
    if (isClosed) return;
    final result = await auth.checkSession();
    if (isClosed) return;
    final context = result is Success<AuthContext?> ? result.value : null;
    if (context == null) {
      emit(0);
      return;
    }
    _countSub = repository
        .watchUnreadCount(
          companyId: context.company.id,
          userId: context.user.id,
        )
        .listen((count) {
          if (!isClosed) emit(count);
        });
  }

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    await _countSub?.cancel();
    return super.close();
  }
}
