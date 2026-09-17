import '../../features/auth/domain/entities/auth_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../design_system/design_system.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

class FormNavigationGuard {
  bool dirty = false, saving = false;
  Object? owner;
  AuthContext? account;
  void attach(Object form, AuthContext context) {
    owner = form;
    account = context;
    dirty = false;
    saving = false;
  }

  void detach(Object form) {
    if (identical(owner, form)) {
      owner = null;
      account = null;
      dirty = false;
      saving = false;
    }
  }

  Future<bool> onExit(BuildContext context) async {
    final auth = context.read<AuthBloc>().state;
    if (!auth.isAuthenticated || account != null && auth.context != account) {
      return true;
    }
    if (saving) return false;
    if (!dirty) return true;
    return AppConfirmationDialog.show(
      context,
      title: (l) => l.empDiscard,
      message: (l) => l.empDiscardMessage,
      confirmLabel: (l) => l.empDiscardAction,
    );
  }
}
