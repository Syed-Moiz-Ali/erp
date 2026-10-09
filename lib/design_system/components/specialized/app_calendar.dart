import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/components/status/app_status_badge.dart';
import 'package:modular_erp/design_system/theme/app_colors.dart';
import 'package:modular_erp/design_system/theme/app_dimensions.dart';
import 'package:modular_erp/design_system/theme/app_radius.dart';
import 'package:modular_erp/design_system/theme/app_spacing.dart';
import 'package:modular_erp/design_system/theme/app_typography.dart';

/// UI-7 shared calendar foundation.
///
/// One polished month grid + selected-day agenda used by the Leave Calendar and
/// (visually) holiday management. It is presentation-only: the caller resolves
/// which events are permitted at the current scope and passes them in. The
/// component never queries data and never decides visibility.

/// A single event shown in a day cell and/or the agenda.
class AppCalendarEvent {
  const AppCalendarEvent({
    required this.id,
    required this.title,
    this.shortLabel,
    this.subtitle,
    this.statusLabel,
    this.status = AppStatus.brand,
    this.color = AppColors.brandPrimary,
    this.onTap,
  });

  final String id;

  /// Full title shown in the agenda.
  final String title;

  /// Very short cell chip label (e.g. a first name or holiday name). Falls
  /// back to [title] when omitted.
  final String? shortLabel;
  final String? subtitle;
  final String? statusLabel;
  final AppStatus status;
  final Color color;
  final VoidCallback? onTap;

  String get cellLabel => shortLabel ?? title;
}

/// Month/Year navigation used by the calendar. Prev/Today/Next only — view
/// controls are rendered by the caller only when multiple views truly exist.
class AppCalendarHeader extends StatelessWidget {
  const AppCalendarHeader({
    super.key,
    required this.label,
    this.onPrevious,
    this.onToday,
    this.onNext,
    this.previousTooltip,
    this.todayLabel,
    this.nextTooltip,
    this.trailing,
  });

  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onToday;
  final VoidCallback? onNext;
  final String? previousTooltip;
  final String? todayLabel;
  final String? nextTooltip;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final labelWidget = Text(
      label,
      style: AppTypography.of(context).sectionTitle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final controls = <Widget>[
      if (trailing != null) trailing!,
      _NavIconButton(
        icon: rtl ? Icons.chevron_right : Icons.chevron_left,
        tooltip: previousTooltip,
        onPressed: onPrevious,
      ),
      if (onToday != null)
        OutlinedButton(
          onPressed: onToday,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, AppDimensions.controlSm + 4),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
          ),
          child: Text(todayLabel ?? ''),
        ),
      _NavIconButton(
        icon: rtl ? Icons.chevron_left : Icons.chevron_right,
        tooltip: nextTooltip,
        onPressed: onNext,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        // Narrow widths stack the period label above Wrapping controls so a
        // long translated label/action can never overflow horizontally.
        if (constraints.maxWidth < 340) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              labelWidget,
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: controls,
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: labelWidget),
            for (final control in controls) ...[
              const SizedBox(width: AppSpacing.sm),
              control,
            ],
          ],
        );
      },
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      icon: Icon(icon, size: AppDimensions.iconMd),
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// A single month day cell. States are layered: outside-month, today, holiday
/// and selected can coexist. Meaning is always text-bearing (day number plus
/// an optional holiday marker), never colour-only.
class AppCalendarDayCell extends StatelessWidget {
  const AppCalendarDayCell({
    super.key,
    required this.dayNumber,
    this.inMonth = true,
    this.isToday = false,
    this.isSelected = false,
    this.holidayLabel,
    this.events = const [],
    this.maxEvents = 2,
    this.onTap,
    this.daySemanticsLabel,
    this.accentColor = AppColors.brandPrimary,
    this.holidayColor = AppColors.success,
  });

  final int? dayNumber;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final String? holidayLabel;
  final List<AppCalendarEvent> events;
  final int maxEvents;
  final VoidCallback? onTap;
  final String? daySemanticsLabel;
  final Color accentColor;
  final Color holidayColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typography = AppTypography.of(context);
    if (dayNumber == null) {
      return const SizedBox.shrink();
    }
    final visible = events.take(maxEvents).toList();
    final overflow = events.length - visible.length;
    final overflowLabel = '+$overflow';
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final selectedSurface = isDark
        ? AppColors.darkSurfaceSelected
        : AppColors.surfaceSelected;
    final border = isSelected
        ? accentColor
        : (isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle);

    return Semantics(
      button: onTap != null,
      selected: isSelected,
      label: daySemanticsLabel,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Material(
            color: isSelected ? selectedSurface : surface,
            borderRadius: BorderRadius.circular(AppRadius.radiusSm),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppRadius.radiusSm),
              hoverColor: isDark
                  ? AppColors.darkSurfaceHover
                  : AppColors.surfaceHover,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.radiusSm),
                  border: Border.all(
                    color: border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DayNumber(
                      day: dayNumber!,
                      inMonth: inMonth,
                      isToday: isToday,
                      accent: accentColor,
                      typography: typography,
                    ),
                    if (holidayLabel != null) ...[
                      const SizedBox(height: 1),
                      Tooltip(
                        message: holidayLabel!,
                        child: Text(
                          holidayLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typography.caption.copyWith(
                            fontSize: 9.5,
                            height: 1.15,
                            color: holidayColor,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    for (final event in visible)
                      _EventChip(event: event, isDark: isDark),
                    if (overflow > 0)
                      Text(
                        overflowLabel,
                        maxLines: 1,
                        style: typography.caption.copyWith(
                          fontSize: 9.5,
                          height: 1.15,
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayNumber extends StatelessWidget {
  const _DayNumber({
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.accent,
    required this.typography,
  });

  final int day;
  final bool inMonth;
  final bool isToday;
  final Color accent;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final color = !inMonth
        ? AppColors.textDisabled
        : isToday
        ? accent
        : AppColors.textPrimary;
    final dayLabel = day.toString();
    final text = Text(
      dayLabel,
      style: typography.caption.copyWith(
        fontWeight: isToday ? AppTypography.weightBold : FontWeight.w600,
        color: color,
        height: 1.1,
      ),
    );
    if (!isToday) return text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(AppRadius.radiusXs),
      ),
      child: text,
    );
  }
}

class _EventChip extends StatelessWidget {
  const _EventChip({required this.event, required this.isDark});
  final AppCalendarEvent event;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1.5),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
        decoration: BoxDecoration(
          color: event.color.withValues(alpha: isDark ? .22 : .12),
          borderRadius: BorderRadius.circular(AppRadius.radiusXs),
        ),
        child: Text(
          event.cellLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.of(context).caption.copyWith(
            fontSize: 9.5,
            height: 1.15,
            color: isDark
                ? event.color.withValues(alpha: .95)
                : _readable(event.color),
          ),
        ),
      ),
    );
  }

  Color _readable(Color color) => color;
}

/// A polished month grid. Weekday labels are supplied by the caller so the
/// first day of week and locale wording stay owned by the feature layer.
class AppCalendar extends StatelessWidget {
  const AppCalendar({
    super.key,
    required this.month,
    required this.weekdays,
    this.eventsForDay,
    this.holidayForDay,
    this.today,
    this.selectedDay,
    this.onSelectDay,
    this.maxEventsPerCell = 2,
    this.daySemanticsLabel,
    this.accentColor = AppColors.brandPrimary,
    this.holidayColor = AppColors.success,
  });

  final DateTime month;
  final List<String> weekdays;
  final List<AppCalendarEvent> Function(DateTime day)? eventsForDay;
  final String? Function(DateTime day)? holidayForDay;
  final DateTime? today;
  final DateTime? selectedDay;
  final ValueChanged<DateTime>? onSelectDay;
  final int maxEventsPerCell;

  /// Builds a fully localized, screen-reader friendly label for a day.
  final String Function(DateTime day, int eventCount, String? holiday)?
  daySemanticsLabel;

  final Color accentColor;
  final Color holidayColor;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final year = month.year;
    final monthNumber = month.month;
    final daysInMonth = DateTime.utc(year, monthNumber + 1, 0).day;
    final leading = DateTime.utc(year, monthNumber, 1).weekday - 1;

    // Compute a uniform, guaranteed-to-fit cell height from the busiest day so
    // no cell ever overflows its grid slot.
    var maxEvents = 0;
    var hasHoliday = false;
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime.utc(year, monthNumber, day);
      final count = eventsForDay?.call(date).length ?? 0;
      if (count > maxEvents) maxEvents = count;
      if (holidayForDay?.call(date) != null) hasHoliday = true;
    }
    maxEvents = maxEvents.clamp(0, maxEventsPerCell);

    final typography = AppTypography.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const spacing = 2.0;
    // Total cell extent: the day-number row plus the cell padding, then the
    // optional holiday label and the visible event chips.
    final double cellHeight =
        40 + (hasHoliday ? 14 : 0) + maxEvents * 16 + (maxEvents > 0 ? 4 : 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (final weekday in weekdays)
              Expanded(
                child: Center(
                  child: Text(
                    weekday,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.caption.copyWith(
                      fontSize: 10.5,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                      fontWeight: AppTypography.weightSemibold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            mainAxisExtent: cellHeight,
          ),
          itemCount: (leading + daysInMonth + 6) ~/ 7 * 7,
          itemBuilder: (context, index) {
            // DateTime.utc rolls day 0/negative and day > daysInMonth into
            // the neighbouring months, so the grid can render a truthful
            // outside-month (muted) leading/trailing state.
            final date = DateTime.utc(year, monthNumber, index - leading + 1);
            final events = eventsForDay?.call(date) ?? const [];
            final holiday = holidayForDay?.call(date);
            return AppCalendarDayCell(
              dayNumber: date.day,
              inMonth: date.month == monthNumber,
              isToday: today != null && _sameDay(date, today!),
              isSelected: selectedDay != null && _sameDay(date, selectedDay!),
              holidayLabel: holiday,
              events: events,
              maxEvents: maxEventsPerCell,
              onTap: onSelectDay == null ? null : () => onSelectDay!(date),
              daySemanticsLabel: daySemanticsLabel?.call(
                date,
                events.length,
                holiday,
              ),
              accentColor: accentColor,
              holidayColor: holidayColor,
            );
          },
        ),
      ],
    );
  }
}

/// One row inside the selected-day agenda.
class AppCalendarAgendaEntry {
  const AppCalendarAgendaEntry({
    required this.title,
    required this.label,
    this.subtitle,
    this.status = AppStatus.neutral,
    this.onTap,
  });

  final String title;
  final String label;
  final String? subtitle;
  final AppStatus status;
  final VoidCallback? onTap;
}

/// Selected-day agenda: holiday context first, then leave/event rows with a
/// status badge and an optional detail action. Never exposes data the caller
/// did not already resolve for the current scope.
class AppCalendarAgenda extends StatelessWidget {
  const AppCalendarAgenda({
    super.key,
    required this.dateLabel,
    this.holidays = const [],
    this.events = const [],
    this.holidaySectionLabel,
    this.eventSectionLabel,
    this.emptyMessage,
  });

  final String dateLabel;
  final List<AppCalendarAgendaEntry> holidays;
  final List<AppCalendarAgendaEntry> events;
  final String? holidaySectionLabel;
  final String? eventSectionLabel;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    final isEmpty = holidays.isEmpty && events.isEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            dateLabel,
            style: typography.cardTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          if (isEmpty)
            Text(
              emptyMessage ?? '',
              style: typography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          if (holidays.isNotEmpty) ...[
            if (holidaySectionLabel != null)
              Text(holidaySectionLabel!, style: typography.label),
            const SizedBox(height: AppSpacing.sm),
            for (final entry in holidays)
              _AgendaRow(entry: entry, typography: typography),
            if (events.isNotEmpty) const SizedBox(height: AppSpacing.md),
          ],
          if (events.isNotEmpty) ...[
            if (eventSectionLabel != null)
              Text(eventSectionLabel!, style: typography.label),
            const SizedBox(height: AppSpacing.sm),
            for (final entry in events)
              _AgendaRow(entry: entry, typography: typography),
          ],
        ],
      ),
    );
  }
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({required this.entry, required this.typography});
  final AppCalendarAgendaEntry entry;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: typography.bodySmall.copyWith(
                    fontWeight: AppTypography.weightSemibold,
                  ),
                ),
                if (entry.subtitle != null && entry.subtitle!.isNotEmpty)
                  Text(
                    entry.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppStatusBadge(
            label: entry.label,
            status: entry.status,
            isPill: true,
          ),
        ],
      ),
    );
    if (entry.onTap == null) return content;
    return InkWell(
      onTap: entry.onTap,
      borderRadius: BorderRadius.circular(AppRadius.radiusSm),
      child: content,
    );
  }
}
