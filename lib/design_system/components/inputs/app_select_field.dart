import 'package:flutter/material.dart';
import '../../design_system.dart';
import '../../theme/app_breakpoints.dart';
import '../../../l10n/l10n.dart';

class AppSelectOption<T> {
  const AppSelectOption(this.value, this.label);
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
  });
  final String label;
  final List<AppSelectOption<T>> options;
  final T? value;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final String? errorText;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      OutlinedButton(
        onPressed: enabled
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
                          AppSearchField(
                            onChanged: (v) => set(() => query = v),
                          ),
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
                                    onTap: () =>
                                        Navigator.pop(c, <T?>[option.value]),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.of(context).caption),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      options
                              .where((o) => o.value == value)
                              .firstOrNull
                              ?.label ??
                          context.l10n.selectOption,
                      style: AppTypography.of(context).body,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.expand_more, size: 20),
            ],
          ),
        ),
      ),
      if (errorText != null)
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Semantics(
            liveRegion: true,
            child: Text(
              errorText!,
              style: AppTypography.of(
                context,
              ).caption.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
    ],
  );
}
