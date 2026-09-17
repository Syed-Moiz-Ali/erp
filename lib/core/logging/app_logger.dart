import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';

class AppLogger {
  void event(String message) => developer.log(message, name: 'erp');
  void error(Object error, StackTrace stack) => developer.log(
    'Operation failed: ${error.runtimeType}',
    name: 'erp',
    stackTrace: stack,
  );
}

class AppBlocObserver extends BlocObserver {
  AppBlocObserver(this.logger);
  final AppLogger logger;
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    logger.error(error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    logger.event('${bloc.runtimeType}: ${event.runtimeType}');
    super.onEvent(bloc, event);
  }
}
