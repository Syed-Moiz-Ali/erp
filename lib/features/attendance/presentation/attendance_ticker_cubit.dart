import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_clock.dart';
import '../../../core/errors/result.dart';
import '../domain/attendance_engine.dart';
import '../domain/attendance_models.dart';
import '../domain/attendance_summary_calculator.dart';

class AttendanceTickerCubit extends Cubit<AttendanceSummary?> {
  AttendanceTickerCubit(this.clock) : super(null);
  final AppClock clock;
  AttendanceContext? _context;
  Timer? _timer;
  bool _active = true;
  bool get isRunning => _timer != null;
  void bind(AttendanceContext? context) {
    _context = context;
    _restart();
  }

  void setActive(bool active) {
    _active = active;
    _restart();
  }

  void refresh() {
    final c = _context;
    if (c == null) {
      emit(null);
      return;
    }
    final summary = const AttendanceSummaryCalculator().calculate(
      c.events,
      clock.now(),
    );
    if (summary case Success<AttendanceSummary>(:final value)) emit(value);
  }

  void _restart() {
    _timer?.cancel();
    _timer = null;
    refresh();
    final state = this.state?.currentState;
    if (_active &&
        (state == AttendanceWorkdayState.working ||
            state == AttendanceWorkdayState.onBreak)) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => refresh());
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
