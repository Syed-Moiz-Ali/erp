import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';

/// Outcome of a reference picker: either a concrete selection or a request to
/// create a new record through the owning module's normal route.
sealed class ServiceReferenceResult<T> {
  const ServiceReferenceResult();
}

class ServiceReferenceSelected<T> extends ServiceReferenceResult<T> {
  const ServiceReferenceSelected(this.value);
  final T value;
}

class ServiceReferenceCreateRequested<T> extends ServiceReferenceResult<T> {
  const ServiceReferenceCreateRequested();
}

/// Read-only field that shows the current reference selection and opens a
/// scalable search picker. Never loads a full directory into a dropdown.
class ServiceReferenceField<T> extends StatelessWidget {
  const ServiceReferenceField({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.onPick,
    this.valueSubtitle,
    this.onClear,
    this.errorText,
    this.enabled = true,
    this.hint,
    this.pickIcon = Icons.search,
  });
  final String label;
  final String? valueLabel, valueSubtitle, errorText, hint;
  final VoidCallback onPick;
  final VoidCallback? onClear;
  final bool enabled;
  final IconData pickIcon;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    final hasValue = valueLabel != null && valueLabel!.isNotEmpty;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.control),
      onTap: enabled ? onPick : null,
      child: InputDecorator(
        isEmpty: !hasValue,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          enabled: enabled,
          suffixIcon: hasValue && onClear != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIconButton(
                      icon: Icons.close,
                      tooltip: context.l10n.clear,
                      onPressed: enabled ? onClear : null,
                    ),
                    const Icon(Icons.expand_more, size: 20),
                  ],
                )
              : Icon(pickIcon, size: 20),
        ),
        child: hasValue
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(valueLabel!, style: typography.body),
                  if (valueSubtitle != null && valueSubtitle!.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.xxs),
                    Text(valueSubtitle!, style: typography.caption),
                  ],
                ],
              )
            : null,
      ),
    );
  }
}

/// Opens the search picker. Returns `null` when dismissed without a choice.
Future<ServiceReferenceResult<T>?> showServiceReferencePicker<T>(
  BuildContext context, {
  required String title,
  required Future<List<T>> Function(String query) search,
  required String Function(T value) labelOf,
  required String Function(T value) idOf,
  String? Function(T value)? subtitleOf,
  String? selectedId,
  String? searchHint,
  String? emptyText,
  String? createLabel,
}) {
  final panel = _ServiceReferencePicker<T>(
    title: title,
    search: search,
    labelOf: labelOf,
    idOf: idOf,
    subtitleOf: subtitleOf,
    selectedId: selectedId,
    searchHint: searchHint,
    emptyText: emptyText,
    createLabel: createLabel,
  );
  return AppBreakpoints.of(context) == AppSize.compact
      ? AppBottomSheet.show<ServiceReferenceResult<T>>(
          context,
          builder: (_) => panel,
        )
      : AppDialog.show<ServiceReferenceResult<T>>(
          context,
          (c) => AppDialog(title: title, child: panel),
        );
}

class _ServiceReferencePicker<T> extends StatefulWidget {
  const _ServiceReferencePicker({
    required this.title,
    required this.search,
    required this.labelOf,
    required this.idOf,
    this.subtitleOf,
    this.selectedId,
    this.searchHint,
    this.emptyText,
    this.createLabel,
  });
  final String title;
  final Future<List<T>> Function(String query) search;
  final String Function(T value) labelOf;
  final String Function(T value) idOf;
  final String? Function(T value)? subtitleOf;
  final String? selectedId, searchHint, emptyText, createLabel;

  @override
  State<_ServiceReferencePicker<T>> createState() =>
      _ServiceReferencePickerState<T>();
}

class _ServiceReferencePickerState<T>
    extends State<_ServiceReferencePicker<T>> {
  List<T> _results = const [];
  bool _loading = true;
  int _token = 0;

  @override
  void initState() {
    super.initState();
    _run('');
  }

  Future<void> _run(String query) async {
    final token = ++_token;
    setState(() => _loading = true);
    final results = await widget.search(query);
    if (!mounted || token != _token) return;
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSearchField(hint: widget.searchHint, onChanged: _run),
        const SizedBox(height: AppSpacing.md),
        if (widget.createLabel != null) ...[
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(widget.createLabel!),
            onTap: () =>
                Navigator.pop(context, ServiceReferenceCreateRequested<T>()),
          ),
          const Divider(height: 1),
        ],
        SizedBox(
          height: 280,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      widget.emptyText ?? l.noRecords,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  children: [
                    for (final value in _results)
                      ListTile(
                        title: Text(widget.labelOf(value)),
                        subtitle: widget.subtitleOf == null
                            ? null
                            : Text(widget.subtitleOf!(value) ?? ''),
                        selected: widget.idOf(value) == widget.selectedId,
                        onTap: () => Navigator.pop(
                          context,
                          ServiceReferenceSelected<T>(value),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
