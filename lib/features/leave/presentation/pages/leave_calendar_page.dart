import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/presentation/configuration_localization.dart';
import '../../domain/leave_models.dart';
import '../bloc/leave_blocs.dart';
import '../leave_localization.dart';
import 'leave_request_list_page.dart';

class LeaveCalendarPage extends StatelessWidget {
  const LeaveCalendarPage({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<LeaveCalendarCubit, LeaveCalendarState>(
        listener: (c, s) {
          if (s.failure != null) {
            AppFeedback.showMessage(
              c,
              message: (l) => configurationFailure(s.failure!, l),
            );
          }
        },
        builder: (c, s) {
          final l = c.l10n, cubit = c.read<LeaveCalendarCubit>();
          return AppPage(
            header: AppPageHeader(
              title: l.leaveCalendarTitle,
              actions: [
                AppIconButton(
                  icon: Icons.chevron_left,
                  tooltip: MaterialLocalizations.of(c).previousMonthTooltip,
                  onPressed: () => _shift(cubit, s, -1),
                ),
                AppIconButton(
                  icon: Icons.chevron_right,
                  tooltip: MaterialLocalizations.of(c).nextMonthTooltip,
                  onPressed: () => _shift(cubit, s, 1),
                ),
              ],
            ),
            child: s.loading
                ? const AppLoadingState()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        MaterialLocalizations.of(c).formatMonthYear(s.from),
                        style: AppTypography.of(c).sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        spacing: AppSpacing.lg,
                        children: [
                          AppStatusBadge(
                            label: l.leaveCalendarLegendLeave,
                            status: AppStatus.brand,
                            showDot: true,
                          ),
                          AppStatusBadge(
                            label: l.leaveCalendarLegendHoliday,
                            status: AppStatus.success,
                            showDot: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _MonthGrid(state: s),
                      const SizedBox(height: AppSpacing.xl),
                      if (s.entries.isEmpty)
                        AppEmptyState(
                          title: l.leaveCalendarEmpty,
                          message: l.leaveCalendarEmpty,
                        )
                      else
                        for (final entry in s.entries)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _EntryRow(entry: entry),
                          ),
                    ],
                  ),
          );
        },
      );

  void _shift(LeaveCalendarCubit cubit, LeaveCalendarState state, int months) {
    final from = DateTime.utc(state.from.year, state.from.month + months, 1);
    final to = DateTime.utc(from.year, from.month + 1, 0);
    cubit.load(from: from, to: to);
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.state});
  final LeaveCalendarState state;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final first = state.from;
    final daysInMonth = DateTime.utc(first.year, first.month + 1, 0).day;
    final leading = first.weekday - 1;
    final leaveDays = <int>{};
    final holidayDays = <int>{};
    for (final entry in state.entries) {
      if (entry.date.year != first.year || entry.date.month != first.month) {
        continue;
      }
      if (entry.kind == LeaveCalendarKind.leave) {
        leaveDays.add(entry.date.day);
      } else {
        holidayDays.add(entry.date.day);
      }
    }
    final cells = <Widget>[
      for (var i = 0; i < leading; i++) const SizedBox.shrink(),
      for (var day = 1; day <= daysInMonth; day++)
        _DayCell(
          day: day,
          leave: leaveDays.contains(day),
          holiday: holidayDays.contains(day),
        ),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (final weekday in const [
                'cfgMon',
                'cfgTue',
                'cfgWed',
                'cfgThu',
                'cfgFri',
                'cfgSat',
                'cfgSun',
              ])
                Expanded(
                  child: Center(
                    child: Text(
                      _weekdayLabel(weekday, l),
                      style: AppTypography.of(context).caption.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: cells,
          ),
        ],
      ),
    );
  }

  String _weekdayLabel(String key, AppLocalizations l) => switch (key) {
    'cfgMon' => l.cfgMon,
    'cfgTue' => l.cfgTue,
    'cfgWed' => l.cfgWed,
    'cfgThu' => l.cfgThu,
    'cfgFri' => l.cfgFri,
    'cfgSat' => l.cfgSat,
    _ => l.cfgSun,
  };
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.leave,
    required this.holiday,
  });
  final int day;
  final bool leave, holiday;
  @override
  Widget build(BuildContext context) {
    final color = leave
        ? AppColors.brandPrimary
        : holiday
        ? AppColors.success
        : null;
    final dayText = '$day';
    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color == null ? AppColors.surfaceSubtle : color.withAlpha(30),
        borderRadius: BorderRadius.circular(AppRadius.radiusSm),
        border: color == null ? null : Border.all(color: color),
      ),
      child: Center(
        child: Text(
          dayText,
          style: AppTypography.of(context).caption.copyWith(
            color: color ?? AppColors.textSecondary,
            fontWeight: color == null ? FontWeight.w400 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});
  final LeaveCalendarEntry entry;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      child: Row(
        children: [
          AppStatusBadge(
            label: entry.kind == LeaveCalendarKind.leave
                ? l.leaveCalendarLegendLeave
                : l.leaveCalendarLegendHoliday,
            status: entry.kind == LeaveCalendarKind.leave
                ? AppStatus.brand
                : AppStatus.success,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: AppTypography.of(context).body),
                if (entry.leaveTypeName != null)
                  Text(
                    entry.leaveTypeName!,
                    style: AppTypography.of(
                      context,
                    ).caption.copyWith(color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          if (entry.status != null)
            AppStatusBadge(
              label: leaveRequestStatusLabel(entry.status!, l),
              status: leaveStatusColor(entry.status!),
            ),
          const SizedBox(width: AppSpacing.md),
          Text(
            configurationDate(context, entry.date),
            style: AppTypography.of(
              context,
            ).caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
