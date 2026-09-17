import 'package:freezed_annotation/freezed_annotation.dart';
part 'local_time.freezed.dart';
part 'local_time.g.dart';

@freezed
abstract class LocalTime with _$LocalTime {
  const LocalTime._();
  const factory LocalTime({required int hour, required int minute}) =
      _LocalTime;
  bool get isValid => hour >= 0 && hour < 24 && minute >= 0 && minute < 60;
  int get minutes => hour * 60 + minute;
  factory LocalTime.fromMinutes(int value) =>
      LocalTime(hour: value ~/ 60, minute: value % 60);
  factory LocalTime.fromJson(Map<String, dynamic> json) =>
      _$LocalTimeFromJson(json);
}

enum WorkingDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

extension WorkingDayIso on WorkingDay {
  int get isoWeekday => switch (this) {
    WorkingDay.monday => 1,
    WorkingDay.tuesday => 2,
    WorkingDay.wednesday => 3,
    WorkingDay.thursday => 4,
    WorkingDay.friday => 5,
    WorkingDay.saturday => 6,
    WorkingDay.sunday => 7,
  };
}
