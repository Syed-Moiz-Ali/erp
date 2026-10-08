import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/presentation/bloc/leave_blocs.dart';
import 'package:modular_erp/modules/hr/leave/presentation/leave_localization.dart';
import 'package:modular_erp/modules/hr/leave/presentation/widgets/leave_operations_widgets.dart';

/// UI-7 Leave Calendar workspace.
///
/// Presentation only: the calendar renders the entries the [LeaveCalendarCubit]
/// already resolved at the caller's SELF/TEAM/ALL scope. It never queries data,
/// never widens scope and never changes which leave statuses appear.
class LeaveCalendarPage extends StatefulWidget {
  const LeaveCalendarPage({super.key});

  @override
  State<LeaveCalendarPage> createState() => _LeaveCalendarPageState();
}

class _LeaveCalendarPageState extends State<LeaveCalendarPage> {
  DateTime? _selected;
  bool _showLeave = true;
  bool _showHolidays = true;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bloc = context.read<LeaveCalendarCubit>();
    final canManageHolidays = PermissionChecker(
      bloc.context.user.permissions,
    ).can(AppPermission.holidayManage);
    return BlocConsumer<LeaveCalendarCubit, LeaveCalendarState>(
      listener: (c, s) {
        if (s.failure != null) {
          AppFeedback.showMessage(
            c,
            message: (l) => configurationFailure(s.failure!, l),
          );
        }
      },
      builder: (c, s) {
        final today = bloc.repository.companyToday(bloc.context);
        final anchor = s.from ?? today;
        final selected = _selected ?? anchor;
        final visible = s.entries
            .where(
              (e) =>
                  (e.kind == LeaveCalendarKind.holiday && _showHolidays) ||
                  (e.kind == LeaveCalendarKind.leave && _showLeave),
            )
            .toList();
        return AppPage(
          header: AppPageHeader(
            title: l.leaveAndHolidayCalendar,
            actions: [
              if (canManageHolidays) ...[
                AppPrimaryButton(
                  icon: Icons.add_rounded,
                  label: l.addHoliday,
                  onPressed: () => context.push(AppRoutes.holidaysNew),
                ),
                AppSecondaryButton(
                  icon: Icons.event_note_outlined,
                  label: l.manageHolidays,
                  onPressed: () => context.push(AppRoutes.holidays),
                ),
              ],
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _navCard(context, bloc, anchor, l),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppFilterChip(
                    label: l.leaveCalendarLegendLeave,
                    selected: _showLeave,
                    onSelected: (v) => setState(() => _showLeave = v),
                  ),
                  AppFilterChip(
                    label: l.leaveCalendarLegendHoliday,
                    selected: _showHolidays,
                    onSelected: (v) => setState(() => _showHolidays = v),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppLegend(
                items: [
                  AppLegendItem(
                    l.leaveCalendarLegendLeave,
                    AppColors.brandPrimary,
                  ),
                  AppLegendItem(l.leaveStatusPending, AppColors.warning),
                  AppLegendItem(
                    l.leaveCalendarLegendHoliday,
                    AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (s.loading)
                const AppSkeleton(height: 420)
              else
                _calendarBody(c, bloc, anchor, selected, visible, today, l),
              if (canManageHolidays && s.entries.isEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                _setUpHolidays(context, l),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _navCard(
    BuildContext context,
    LeaveCalendarCubit bloc,
    DateTime anchor,
    AppLocalizations l,
  ) => AppCard(
    child: AppCalendarHeader(
      label: MaterialLocalizations.of(context).formatMonthYear(anchor),
      previousTooltip: MaterialLocalizations.of(context).previousMonthTooltip,
      nextTooltip: MaterialLocalizations.of(context).nextMonthTooltip,
      todayLabel: l.viewToday,
      onPrevious: () => _shift(bloc, anchor, -1),
      onNext: () => _shift(bloc, anchor, 1),
      onToday: () {
        final today = bloc.repository.companyToday(bloc.context);
        setState(() => _selected = today);
        bloc.load(
          from: DateTime.utc(today.year, today.month, 1),
          to: DateTime.utc(today.year, today.month + 1, 0),
        );
      },
    ),
  );

  Widget _calendarBody(
    BuildContext context,
    LeaveCalendarCubit bloc,
    DateTime anchor,
    DateTime selected,
    List<LeaveCalendarEntry> visible,
    DateTime today,
    AppLocalizations l,
  ) {
    final byDay = <String, List<AppCalendarEvent>>{};
    final holidayByDay = <String, String>{};
    for (final entry in visible) {
      final key = _dayKey(entry.date);
      final isHoliday = entry.kind == LeaveCalendarKind.holiday;
      byDay
          .putIfAbsent(key, () => [])
          .add(
            AppCalendarEvent(
              id: '$key-${entry.requestId ?? entry.title}',
              title: isHoliday
                  ? entry.title
                  : (entry.employeeName ?? entry.title),
              shortLabel: _cellLabel(entry),
              color: isHoliday ? AppColors.success : _leaveColor(entry.status),
              onTap: entry.requestId == null
                  ? null
                  : () => context.push(
                      AppRoutes.leaveRequestDetails(entry.requestId!),
                    ),
            ),
          );
      if (isHoliday) {
        holidayByDay.putIfAbsent(key, () => entry.title);
      }
    }

    final grid = AppCard(
      child: AppCalendar(
        month: anchor,
        today: today,
        selectedDay: selected,
        weekdays: [
          l.cfgMon,
          l.cfgTue,
          l.cfgWed,
          l.cfgThu,
          l.cfgFri,
          l.cfgSat,
          l.cfgSun,
        ],
        eventsForDay: (day) => byDay[_dayKey(day)] ?? const [],
        holidayForDay: (day) => holidayByDay[_dayKey(day)],
        onSelectDay: (day) => setState(() => _selected = day),
        maxEventsPerCell: 2,
        daySemanticsLabel: (day, count, holiday) {
          final parts = <String>[
            MaterialLocalizations.of(context).formatFullDate(day),
          ];
          if (count > 0) parts.add('$count ${l.leaveCalendarEventsLabel}');
          if (holiday != null) parts.add(holiday);
          if (_sameDay(day, selected)) parts.add(l.leaveCalendarSelected);
          return parts.join(', ');
        },
        holidayColor: AppColors.success,
      ),
    );

    final entries = visible.where((e) => _sameDay(e.date, selected)).toList();
    final holidays = entries
        .where((e) => e.kind == LeaveCalendarKind.holiday)
        .toList();
    final leave = entries
        .where((e) => e.kind == LeaveCalendarKind.leave)
        .toList();
    final agenda = AppCalendarAgenda(
      dateLabel: configurationDate(context, selected),
      holidaySectionLabel: l.leaveCalendarLegendHoliday,
      eventSectionLabel: l.leaveCalendarLegendLeave,
      emptyMessage: l.noEventsOnDay,
      holidays: [
        for (final holiday in holidays)
          AppCalendarAgendaEntry(
            title: holiday.title,
            label: l.holiday,
            status: AppStatus.success,
          ),
      ],
      events: [
        for (final item in leave)
          AppCalendarAgendaEntry(
            title: item.employeeName ?? item.title,
            label: item.status == null
                ? l.leaveCalendarLegendLeave
                : leaveRequestStatusLabel(item.status!, l),
            subtitle: item.leaveTypeName,
            status: item.status == null
                ? AppStatus.neutral
                : leaveStatusAppStatus(item.status!),
            onTap: item.requestId == null
                ? null
                : () => context.push(
                    AppRoutes.leaveRequestDetails(item.requestId!),
                  ),
          ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = AppBreakpoints.classify(constraints.maxWidth);
        final wide = size == AppSize.expanded || size == AppSize.large;
        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              grid,
              const SizedBox(height: AppSpacing.xl),
              agenda,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 8, child: grid),
            const SizedBox(width: AppSpacing.xl),
            Expanded(flex: 4, child: agenda),
          ],
        );
      },
    );
  }

  Widget _setUpHolidays(BuildContext context, AppLocalizations l) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.noHolidaysConfigured, style: AppTypography.of(context).body),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppPrimaryButton(
              label: l.addHoliday,
              onPressed: () => context.push(AppRoutes.holidaysNew),
            ),
            AppSecondaryButton(
              label: l.setUpHolidayCalendar,
              onPressed: () => context.push(AppRoutes.holidays),
            ),
          ],
        ),
      ],
    ),
  );

  String _dayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Compact cell chip: first name + leave type ("Ahmed · Annual"), never a
  /// full name squeezed into a tiny day cell.
  String _cellLabel(LeaveCalendarEntry entry) {
    if (entry.kind == LeaveCalendarKind.holiday) return entry.title;
    final parts = [
      if (_firstName(entry.employeeName).isNotEmpty)
        _firstName(entry.employeeName),
      if (_firstName(entry.leaveTypeName).isNotEmpty)
        _firstName(entry.leaveTypeName),
    ];
    return parts.isEmpty ? entry.title : parts.join(' · ');
  }

  String _firstName(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  Color _leaveColor(LeaveRequestStatus? status) => switch (status) {
    LeaveRequestStatus.approved => AppColors.brandPrimary,
    LeaveRequestStatus.pending => AppColors.warning,
    _ => AppColors.neutral,
  };

  void _shift(LeaveCalendarCubit bloc, DateTime anchor, int months) {
    final from = DateTime.utc(anchor.year, anchor.month + months, 1);
    final to = DateTime.utc(from.year, from.month + 1, 0);
    setState(() => _selected = from);
    bloc.load(from: from, to: to);
  }
}
