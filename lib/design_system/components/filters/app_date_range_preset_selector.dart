import 'package:flutter/material.dart';
import 'app_filters.dart';
import '../../theme/app_spacing.dart';

class AppDateRangePresetSelector<T extends Object> extends StatelessWidget {
  const AppDateRangePresetSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });
  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onChanged;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [
      for (final (value, label) in options)
        AppFilterChip(
          label: label,
          selected: value == selected,
          onSelected: (_) => onChanged(value),
        ),
    ],
  );
}
