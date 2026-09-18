import '../../../core/utils/local_time.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/generated/app_localizations.dart';

enum PreviewLocation { office, remote }

extension PreviewLocationLocalization on PreviewLocation {
  String label(AppLocalizations l10n) => switch (this) {
    PreviewLocation.office => l10n.office,
    PreviewLocation.remote => l10n.remote,
  };
}

enum PreviewRecordStatus { active, draft }

extension PreviewStatusLocalization on PreviewRecordStatus {
  String label(AppLocalizations l10n) => switch (this) {
    PreviewRecordStatus.active => l10n.active,
    PreviewRecordStatus.draft => l10n.draft,
  };
}

class PreviewState {
  const PreviewState({
    this.activeOnly = false,
    this.location = PreviewLocation.office,
    this.date,
    this.timeMinutes,
    this.days = const {
      WorkingDay.monday,
      WorkingDay.tuesday,
      WorkingDay.wednesday,
    },
  });
  final Set<WorkingDay> days;
  final bool activeOnly;
  final PreviewLocation location;
  final DateTime? date;
  final int? timeMinutes;
  PreviewState copyWith({
    bool? activeOnly,
    PreviewLocation? location,
    DateTime? date,
    int? timeMinutes,
    Set<WorkingDay>? days,
  }) => PreviewState(
    activeOnly: activeOnly ?? this.activeOnly,
    location: location ?? this.location,
    date: date ?? this.date,
    timeMinutes: timeMinutes ?? this.timeMinutes,
    days: days ?? this.days,
  );
}

class PreviewCubit extends Cubit<PreviewState> {
  PreviewCubit() : super(const PreviewState());
  void days(Set<WorkingDay> value) =>
      emit(state.copyWith(days: Set.unmodifiable(value)));
  void filter(bool value) => emit(state.copyWith(activeOnly: value));
  void location(PreviewLocation value) => emit(state.copyWith(location: value));
  void date(DateTime value) => emit(state.copyWith(date: value));
  void time(int value) => emit(state.copyWith(timeMinutes: value));
}
