import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/components/inputs/app_inputs.dart';
import 'package:modular_erp/design_system/theme/app_colors.dart';
import 'package:modular_erp/design_system/theme/app_radius.dart';
import 'package:modular_erp/design_system/theme/app_spacing.dart';
import 'package:modular_erp/design_system/theme/app_typography.dart';

/// Standard checkbox row: shared size, border, selected color and label
/// spacing, with an optional supporting line and disabled state.
class AppCheckboxField extends StatelessWidget {
  const AppCheckboxField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
    this.enabled = true,
  });

  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disabledColor = isDark
        ? AppColors.darkTextDisabled
        : AppColors.textDisabled;
    final cb = onChanged;
    final canToggle = enabled && cb != null;
    return Semantics(
      checked: value,
      enabled: enabled,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: canToggle ? (v) => cb(v ?? false) : null,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: InkWell(
              onTap: canToggle ? () => cb(!value) : null,
              borderRadius: BorderRadius.circular(AppRadius.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: typography.body.copyWith(
                        color: enabled ? null : disabledColor,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(description!, style: typography.caption),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single radio option for [AppRadioGroup].
class AppRadioOption<T> {
  const AppRadioOption(this.value, this.label);
  final T value;
  final String label;
}

/// Standard radio group: consistent size, spacing and selected color.
class AppRadioGroup<T> extends StatelessWidget {
  const AppRadioGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final List<AppRadioOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disabledColor = isDark
        ? AppColors.darkTextDisabled
        : AppColors.textDisabled;
    final cb = onChanged;
    final canSelect = enabled && cb != null;
    return RadioGroup<T>(
      groupValue: value,
      onChanged: canSelect
          ? (v) {
              if (v != null) cb(v);
            }
          : (_) {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final option in options)
            Row(
              children: [
                Radio<T>(value: option.value, enabled: enabled),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: InkWell(
                    onTap: canSelect ? () => cb(option.value) : null,
                    borderRadius: BorderRadius.circular(AppRadius.radiusSm),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      child: Text(
                        option.label,
                        style: typography.body.copyWith(
                          color: enabled ? null : disabledColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Read-only business context. Uses a neutral read-only surface rather than a
/// disabled form field, so non-editable information never looks broken.
class AppReadOnlyField extends StatelessWidget {
  const AppReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.labelTrailing,
    this.fullWidth = true,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Widget? labelTrailing;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final field = Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.field),
        border: Border.all(
          color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.textTertiary,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              value,
              style: typography.inputValue.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
    return AppFieldLabelGroup(
      label: label,
      trailing: labelTrailing,
      child: field,
    );
  }
}
