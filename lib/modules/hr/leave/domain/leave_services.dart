import 'leave_models.dart';

/// Leave year definition, centralized so a company-defined leave year can be
/// introduced later. V1: Gregorian year (Jan 1 – Dec 31).
class LeaveYearResolver {
  const LeaveYearResolver();
  int yearFor(DateTime date) => date.year;
  (DateTime, DateTime) span(int year) =>
      (DateTime.utc(year, 1, 1), DateTime.utc(year, 12, 31));
}

class LeaveDayCalculation {
  const LeaveDayCalculation({
    required this.quantityDays,
    required this.workingDays,
    required this.excludedWeekends,
    required this.excludedHolidays,
    this.leaveDates = const [],
  });
  final double quantityDays;
  final int workingDays, excludedWeekends, excludedHolidays;
  final List<DateTime> leaveDates;
  bool get hasWorkingDays => quantityDays > 0;
}

/// Pure leave-day calculator. Counts only scheduled working days, excludes
/// non-working weekdays and applicable holidays, and supports a single-day
/// half day. Never uses `end - start + 1`.
class LeaveDayCalculator {
  const LeaveDayCalculator();

  LeaveDayCalculation calculate({
    required DateTime startDate,
    required DateTime endDate,
    required Set<int> workingWeekdays,
    Set<String> holidayDates = const {},
    LeaveDayPortion startPortion = LeaveDayPortion.fullDay,
    LeaveDayPortion endPortion = LeaveDayPortion.fullDay,
    bool allowHalfDay = true,
  }) {
    final start = leaveDate(startDate);
    final end = leaveDate(endDate);
    if (end.isBefore(start)) {
      return const LeaveDayCalculation(
        quantityDays: 0,
        workingDays: 0,
        excludedWeekends: 0,
        excludedHolidays: 0,
      );
    }
    var quantity = 0.0;
    var workingDays = 0;
    var weekends = 0;
    var holidays = 0;
    final leaveDates = <DateTime>[];
    final single = start == end;
    for (
      var day = start;
      !day.isAfter(end);
      day = day.add(const Duration(days: 1))
    ) {
      if (!workingWeekdays.contains(day.weekday)) {
        weekends++;
        continue;
      }
      if (holidayDates.contains(_key(day))) {
        holidays++;
        continue;
      }
      workingDays++;
      leaveDates.add(day);
      final half =
          single &&
          allowHalfDay &&
          (startPortion != LeaveDayPortion.fullDay ||
              endPortion != LeaveDayPortion.fullDay);
      quantity += half ? 0.5 : 1;
    }
    return LeaveDayCalculation(
      quantityDays: quantity,
      workingDays: workingDays,
      excludedWeekends: weekends,
      excludedHolidays: holidays,
      leaveDates: leaveDates,
    );
  }

  String _key(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String keyFor(DateTime date) => _key(leaveDate(date));
}
