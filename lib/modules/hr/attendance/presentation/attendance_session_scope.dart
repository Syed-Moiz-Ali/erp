import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'bloc/attendance_bloc.dart';

/// One business owner per authenticated account/company; display tickers remain page-local.
class AttendanceSessionScope extends StatelessWidget {
  const AttendanceSessionScope({
    super.key,
    required this.create,
    required this.clock,
    required this.time,
    required this.child,
  });
  final AttendanceBloc Function() create;
  final AppClock clock;
  final CompanyTimeService time;
  final Widget child;
  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<AppClock>.value(value: clock),
      RepositoryProvider<CompanyTimeService>.value(value: time),
    ],
    child: BlocSelector<AuthBloc, AuthState, AuthContext?>(
      selector: (s) => s.context,
      builder: (context, a) {
        if (a == null ||
            !a.user.permissions.contains(AppPermission.attendanceViewSelf) ||
            !a.company.enabledModules.contains('attendance')) {
          return child;
        }
        return BlocProvider<AttendanceBloc>(
          key: ValueKey((a.user.id, a.company.id)),
          create: (_) => create()..add(const AttendanceStarted()),
          child: child,
        );
      },
    ),
  );
}
