import '../app/app_config.dart';
import '../core/database/app_database.dart';
import '../features/auth/data/datasources/local/demo_auth_source.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../app/erp_app.dart';
import '../core/logging/app_logger.dart';
import '../core/localization/locale_cubit.dart';
import 'dependencies.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  final logger = services<AppLogger>();
  Bloc.observer = AppBlocObserver(logger);
  FlutterError.onError = (details) {
    logger.error(details.exception, details.stack ?? StackTrace.current);
    FlutterError.presentError(details);
  };
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    logger.error(error, stack);
    return true;
  };
  await initializeDateFormatting();
  // Force Drift to open and run migrations before session restoration.
  await services<AppDatabase>().customSelect('SELECT 1').get();
  final localeCubit = services<LocaleCubit>();
  await localeCubit.restore(WidgetsBinding.instance.platformDispatcher.locales);
  final authBloc = services<AuthBloc>();
  runApp(
    ErpApp(
      localeCubit: localeCubit,
      authBloc: authBloc,
      demoAccounts: AppConfig.demoAuthEnabled
          ? services<DemoAuthSource>().credentials
          : const [],
    ),
  );
  authBloc.add(const AuthBootstrapRequested());
}
