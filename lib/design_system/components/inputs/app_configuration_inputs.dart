import 'package:flutter/material.dart';
import '../../../core/utils/local_time.dart';
import '../../../l10n/l10n.dart';
import '../../design_system.dart';

/// Numeric entry accepts Latin, Arabic-Indic and Persian digits. Empty and
/// invalid input remain distinct so repositories cannot silently accept zero.
class AppNumericInput {
  const AppNumericInput(this.raw);
  final String raw;
  bool get isEmpty => raw.trim().isEmpty;
  double? get value {
    var text = raw.trim();
    const arabic = '٠١٢٣٤٥٦٧٨٩', persian = '۰۱۲۳۴۵۶۷۸۹';
    for (var i = 0; i < 10; i++) {
      text = text
          .replaceAll(arabic[i], i.toString())
          .replaceAll(persian[i], i.toString());
    }
    text = text.replaceAll('٫', '.').replaceAll('٬', '').replaceAll('−', '-');
    final value = double.tryParse(text);
    return value != null && value.isFinite ? value : null;
  }

  double? get optional => isEmpty ? null : value ?? double.nan;
  int? get optionalInteger => isEmpty
      ? null
      : value != null && value == value!.truncateToDouble()
      ? value!.toInt()
      : -1;
  int get integer => optionalInteger ?? 0;
}

class AppNumberField extends StatelessWidget {
  const AppNumberField({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialValue,
    this.errorText,
    this.suffix,
    this.enabled = true,
    this.integerOnly = false,
  });
  final String label;
  final num? initialValue;
  final String? errorText, suffix;
  final bool enabled, integerOnly;
  final ValueChanged<AppNumericInput> onChanged;
  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: initialValue?.toString(),
    enabled: enabled,
    textDirection: TextDirection.ltr,
    keyboardType: TextInputType.numberWithOptions(
      decimal: !integerOnly,
      signed: true,
    ),
    onChanged: (v) => onChanged(AppNumericInput(v)),
    decoration: InputDecoration(
      labelText: label,
      errorText: errorText,
      suffixText: suffix,
    ),
  );
}

String appWeekdayLabel(WorkingDay day, AppLocalizations l) => switch (day) {
  WorkingDay.monday => l.cfgMon,
  WorkingDay.tuesday => l.cfgTue,
  WorkingDay.wednesday => l.cfgWed,
  WorkingDay.thursday => l.cfgThu,
  WorkingDay.friday => l.cfgFri,
  WorkingDay.saturday => l.cfgSat,
  WorkingDay.sunday => l.cfgSun,
};

class AppWeekdaySelector extends StatelessWidget {
  const AppWeekdaySelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
  });
  final Set<WorkingDay> value;
  final ValueChanged<Set<WorkingDay>> onChanged;
  final bool enabled;
  final String? errorText;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(context.l10n.cfgDays, style: AppTypography.of(context).label),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final day in WorkingDay.values)
            FilterChip(
              label: Text(appWeekdayLabel(day, context.l10n)),
              selected: value.contains(day),
              onSelected: !enabled
                  ? null
                  : (selected) =>
                        onChanged({...value}..toggleDay(day, selected)),
            ),
        ],
      ),
      if (errorText != null)
        Text(
          errorText!,
          style: AppTypography.of(
            context,
          ).caption.copyWith(color: Theme.of(context).colorScheme.error),
        ),
    ],
  );
}

extension on Set<WorkingDay> {
  void toggleDay(WorkingDay day, bool selected) {
    selected ? add(day) : remove(day);
  }
}

class AppLocationPreview extends StatelessWidget {
  const AppLocationPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.address = '',
  });
  final double? latitude, longitude, radius;
  final String address;
  @override
  Widget build(BuildContext context) => AppFormSection(
    title: context.l10n.cfgPreview,
    subtitle: context.l10n.cfgPreviewNote,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.location_on_outlined),
        if (address.isNotEmpty) Text(address),
        AppDetailsGrid(
          fields: [
            AppDetailField(
              label: context.l10n.cfgLatitude,
              value: latitude?.toStringAsFixed(6) ?? context.l10n.noSelection,
              identifier: true,
            ),
            AppDetailField(
              label: context.l10n.cfgLongitude,
              value: longitude?.toStringAsFixed(6) ?? context.l10n.noSelection,
              identifier: true,
            ),
            AppDetailField(
              label: context.l10n.cfgRadius,
              value: radius == null
                  ? context.l10n.noSelection
                  : [radius!.toString(), context.l10n.cfgMeters].join(' '),
            ),
          ],
        ),
      ],
    ),
  );
}
