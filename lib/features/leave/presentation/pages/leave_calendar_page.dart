import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/security/app_permission.dart';
import '../../../../design_system/design_system.dart';
import '../../../../design_system/theme/app_breakpoints.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/presentation/configuration_localization.dart';
import '../../domain/leave_models.dart';
import '../bloc/leave_blocs.dart';
import '../leave_localization.dart';
import '../widgets/leave_operations_widgets.dart';

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
        final anchor = s.from ?? bloc.repository.companyToday(bloc.context);
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
              AppIconButton(
                icon: Icons.chevron_left,
                tooltip: MaterialLocalizations.of(c).previousMonthTooltip,
                onPressed: () => _shift(bloc, anchor, -1),
              ),
              AppSecondaryButton(
                label: l.viewToday,
                onPressed: () {
                  final today = bloc.repository.companyToday(bloc.context);
                  setState(() => _selected = today);
                  bloc.load(
                    from: DateTime.utc(today.year, today.month, 1),
                    to: DateTime.utc(today.year, today.month + 1, 0),
                  );
                },
              ),
              AppIconButton(
                icon: Icons.chevron_right,
                tooltip: MaterialLocalizations.of(c).nextMonthTooltip,
                onPressed: () => _shift(bloc, anchor, 1),
              ),
            ],
          ),
          child: s.loading
              ? const AppLoadingState()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
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
                    const SizedBox(height: AppSpacing.lg),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact =
                            AppBreakpoints.classify(constraints.maxWidth) ==
                            AppSize.compact;
                        final grid = _MonthGrid(
                          anchor: anchor,
                          entries: visible,
                          selected: selected,
                          onSelect: (day) => setState(() => _selected = day),
                        );
                        final agenda = _Agenda(
                          date: selected,
                          entries: visible
                              .where((e) => _sameDay(e.date, selected))
                              .toList(),
                        );
                        if (compact) {
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
                            Expanded(flex: 3, child: grid),
                            const SizedBox(width: AppSpacing.xl),
                            Expanded(flex: 2, child: agenda),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (canManageHolidays && s.entries.isEmpty)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.noHolidaysConfigured,
                              style: AppTypography.of(context).body,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.sm,
                              children: [
                                AppPrimaryButton(
                                  label: l.addHoliday,
                                  onPressed: () =>
                                      context.push(AppRoutes.holidaysNew),
                                ),
                                AppSecondaryButton(
                                  label: l.setUpHolidayCalendar,
                                  onPressed: () =>
                                      context.push(AppRoutes.holidays),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }

  void _shift(LeaveCalendarCubit bloc, DateTime anchor, int months) {
    final from = DateTime.utc(anchor.year, anchor.month + months, 1);
    final to = DateTime.utc(from.year, from.month + 1, 0);
    setState(() => _selected = from);
    bloc.load(from: from, to: to);
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.anchor,
    required this.entries,
    required this.selected,
    required this.onSelect,
  });
  final DateTime anchor;
  final List<LeaveCalendarEntry> entries;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final daysInMonth = DateTime.utc(anchor.year, anchor.month + 1, 0).day;
    final leading = DateTime.utc(anchor.year, anchor.month, 1).weekday - 1;
    final weekdays = [
      l.cfgMon,
      l.cfgTue,
      l.cfgWed,
      l.cfgThu,
      l.cfgFri,
      l.cfgSat,
      l.cfgSun,
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            MaterialLocalizations.of(context).formatMonthYear(anchor),
            style: AppTypography.of(context).sectionTitle,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (final weekday in weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      weekday,
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
            childAspectRatio: 0.9,
            children: [
              for (var i = 0; i < leading; i++) const SizedBox.shrink(),
              for (var day = 1; day <= daysInMonth; day++)
                _DayCell(
                  date: DateTime.utc(anchor.year, anchor.month, day),
                  events: entries
                      .where(
                        (e) =>
                            e.date.year == anchor.year &&
                            e.date.month == anchor.month &&
                            e.date.day == day,
                      )
                      .toList(),
                  selected:
                      selected.year == anchor.year &&
                      selected.month == anchor.month &&
                      selected.day == day,
                  onTap: () =>
                      onSelect(DateTime.utc(anchor.year, anchor.month, day)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.events,
    required this.selected,
    required this.onTap,
  });
  final DateTime date;
  final List<LeaveCalendarEntry> events;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final dayText = '${date.day}';
    final semanticsLabel = '$dayText, ${events.length}';
    final moreLabel = '+${events.length - 1}';
    return Padding(
      padding: const EdgeInsets.all(3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radiusSm),
        child: Semantics(
          label: semanticsLabel,
          button: true,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: selected ? AppColors.surfaceSelected : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.radiusSm),
              border: Border.all(
                color: selected
                    ? AppColors.brandPrimary
                    : AppColors.borderSubtle,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayText,
                  style: AppTypography.of(context).caption.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                for (final event in events.take(1)) _EventChip(event: event),
                if (events.length > 1)
                  Text(
                    moreLabel,
                    style: AppTypography.of(
                      context,
                    ).caption.copyWith(color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventChip extends StatelessWidget {
  const _EventChip({required this.event});
  final LeaveCalendarEntry event;
  @override
  Widget build(BuildContext context) {
    final holiday = event.kind == LeaveCalendarKind.holiday;
    final color = holiday ? AppColors.success : AppColors.brandPrimary;
    final label = holiday ? event.title : (event.employeeName ?? event.title);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.of(
          context,
        ).caption.copyWith(color: color, fontSize: 9),
      ),
    );
  }
}

class _Agenda extends StatelessWidget {
  const _Agenda({required this.date, required this.entries});
  final DateTime date;
  final List<LeaveCalendarEntry> entries;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final holidays = entries
        .where((e) => e.kind == LeaveCalendarKind.holiday)
        .toList();
    final leave = entries
        .where((e) => e.kind == LeaveCalendarKind.leave)
        .toList();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            configurationDate(context, date),
            style: AppTypography.of(context).sectionTitle,
          ),
          const SizedBox(height: AppSpacing.md),
          if (entries.isEmpty)
            Text(
              l.noEventsOnDay,
              style: AppTypography.of(
                context,
              ).bodySmall.copyWith(color: AppColors.textMuted),
            ),
          if (holidays.isNotEmpty) ...[
            Text(
              l.leaveCalendarLegendHoliday,
              style: AppTypography.of(context).label,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final holiday in holidays)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _AgendaRow(
                  title: holiday.title,
                  label: l.holiday,
                  status: AppStatus.success,
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (leave.isNotEmpty) ...[
            Text(
              l.leaveCalendarLegendLeave,
              style: AppTypography.of(context).label,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final item in leave)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InkWell(
                  onTap: item.requestId == null
                      ? null
                      : () => context.push(
                          AppRoutes.leaveRequestDetails(item.requestId!),
                        ),
                  child: _AgendaRow(
                    title: item.employeeName ?? item.title,
                    subtitle: item.leaveTypeName,
                    label: item.status == null
                        ? l.leaveCalendarLegendLeave
                        : leaveRequestStatusLabel(item.status!, l),
                    status: item.status == null
                        ? AppStatus.neutral
                        : leaveStatusAppStatus(item.status!),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({
    required this.title,
    required this.label,
    required this.status,
    this.subtitle,
  });
  final String title, label;
  final String? subtitle;
  final AppStatus status;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.of(context).body),
            if (subtitle != null && subtitle!.isNotEmpty)
              Text(
                subtitle!,
                style: AppTypography.of(
                  context,
                ).caption.copyWith(color: AppColors.textMuted),
              ),
          ],
        ),
      ),
      AppStatusBadge(label: label, status: status),
    ],
  );
}
