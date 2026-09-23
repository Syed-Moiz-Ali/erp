import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';

class AppSelectOption<T> {
  const AppSelectOption(
    this.value,
    this.label, {
    this.subtitle,
    this.enabled = true,
  });
  final String? subtitle;
  final bool enabled;
  final T value;
  final String label;
}

class AppSelectField<T> extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.value,
    this.enabled = true,
    this.errorText,
    this.hint,
  });
  final String label;
  final List<AppSelectOption<T>> options;
  final T? value;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final String? errorText;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final selectedOption = options.where((o) => o.value == value).firstOrNull;
    final typography = AppTypography.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.control),
      onTap: enabled
          ? () async {
              Widget panel(BuildContext c) {
                String query = '';
                return StatefulBuilder(
                  builder: (c, set) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppSectionHeader(title: label),
                        const SizedBox(height: AppSpacing.lg),
                        AppSearchField(onChanged: (v) => set(() => query = v)),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          height: 280,
                          child: ListView(
                            children: [
                              ListTile(
                                title: Text(c.l10n.noSelection),
                                onTap: () => Navigator.pop(c, <T?>[null]),
                              ),
                              for (final option in options.where(
                                (o) => o.label.toLowerCase().contains(
                                  query.toLowerCase(),
                                ),
                              ))
                                ListTile(
                                  title: Text(option.label),
                                  selected: option.value == value,
                                  enabled: option.enabled,
                                  subtitle: option.subtitle == null
                                      ? null
                                      : Text(option.subtitle!),
                                  onTap: !option.enabled
                                      ? null
                                      : () => Navigator.pop(c, <T?>[
                                          option.value,
                                        ]),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              }

              final compact = AppBreakpoints.of(context) == AppSize.compact;
              final pending = compact
                  ? AppBottomSheet.show<List<T?>>(context, builder: panel)
                  : AppDialog.show<List<T?>>(
                      context,
                      (c) => AppDialog(title: label, child: panel(c)),
                    );
              final result = await pending;
              if (context.mounted && result != null) onChanged(result.single);
            }
          : null,
      child: InputDecorator(
        isEmpty: selectedOption == null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint ?? context.l10n.selectOption,
          errorText: errorText,
          enabled: enabled,
          suffixIcon: const Icon(Icons.expand_more, size: 20),
        ),
        child: selectedOption == null
            ? null
            : selectedOption.subtitle == null
            ? Text(selectedOption.label, style: typography.body)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(selectedOption.label, style: typography.body),
                  SizedBox(height: AppSpacing.xxs),
                  Text(selectedOption.subtitle!, style: typography.caption),
                ],
              ),
      ),
    );
  }
}
