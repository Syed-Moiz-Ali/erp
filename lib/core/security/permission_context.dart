import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import 'app_permission.dart';
export 'app_permission.dart';

extension PermissionContext on BuildContext {
  /// Reactive: rebuilding widgets subscribe to current explicit session grants.
  bool can(AppPermission permission) =>
      watch<AuthBloc>().state.context?.user.permissions.contains(permission) ??
      false;
  PermissionChecker get permissionChecker => PermissionChecker(
    watch<AuthBloc>().state.context?.user.permissions ??
        PermissionSet(const []),
  );
}
