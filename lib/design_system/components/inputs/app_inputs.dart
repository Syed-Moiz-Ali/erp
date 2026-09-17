import '../../../l10n/l10n.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/app_formatters.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.prefixIcon,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.autofillHints,
    this.onFieldSubmitted,
    this.enabled = true,
    this.autocorrect = true,
  });
  final String label;
  final String? hint, errorText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled, autocorrect;
  @override
  Widget build(BuildContext context) => _LocalizedValidationField<String>(
    builder: (fieldKey) => TextFormField(
      key: fieldKey,
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      autocorrect: autocorrect,
      enableSuggestions: autocorrect,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textDirection:
          keyboardType == TextInputType.emailAddress ||
              keyboardType == TextInputType.phone
          ? TextDirection.ltr
          : null,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
      ),
    ),
  );
}

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    this.controller,
    this.validator,
    this.label,
    this.focusNode,
    this.textInputAction,
    this.autofillHints,
    this.onFieldSubmitted,
    this.enabled = true,
  });
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final String? label;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;
  @override
  State<AppPasswordField> createState() => _PasswordState();
}

class _PasswordState extends State<AppPasswordField> {
  bool hidden = true;
  @override
  Widget build(BuildContext context) => _LocalizedValidationField<String>(
    builder: (fieldKey) => TextFormField(
      key: fieldKey,
      controller: widget.controller,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onFieldSubmitted: widget.onFieldSubmitted,
      enabled: widget.enabled,
      validator: widget.validator,
      obscureText: hidden,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: widget.label ?? context.l10n.password,
        suffixIcon: IconButton(
          tooltip: hidden
              ? context.l10n.showPassword
              : context.l10n.hidePassword,
          onPressed: widget.enabled
              ? () => setState(() => hidden = !hidden)
              : null,
          icon: Icon(
            hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
        ),
      ),
    ),
  );
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({super.key, this.controller, this.onChanged});
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) => AppTextField(
    label: context.l10n.search,
    hint: context.l10n.searchRecords,
    controller: controller,
    onChanged: onChanged,
    prefixIcon: Icons.search,
  );
}

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
  });
  final String label;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  @override
  Widget build(BuildContext context) => _LocalizedValidationField<T>(
    builder: (fieldKey) => DropdownButtonFormField<T>(
      key: fieldKey,
      initialValue: value,
      isExpanded: true,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    ),
  );
}

class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    this.value,
    required this.onChanged,
    this.lastDate,
    this.errorText,
    this.enabled = true,
  });
  final DateTime? lastDate;
  final bool enabled;
  final String label;
  final String? errorText;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: !enabled
        ? null
        : () async {
            final date = await showDatePicker(
              context: context,
              cancelText: context.l10n.cancel,
              confirmText: context.l10n.confirm,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: lastDate ?? DateTime(2100),
            );
            if (date != null) onChanged(date);
          },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
      ),
      child: Text(
        value == null
            ? context.l10n.selectDate
            : AppDateFormatter(Localizations.localeOf(context)).date(value!),
      ),
    ),
  );
}

class AppTimeField extends StatelessWidget {
  const AppTimeField({
    super.key,
    required this.label,
    this.value,
    required this.onChanged,
  });
  final String label;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onChanged;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () async {
      final time = await showTimePicker(
        context: context,
        cancelText: context.l10n.cancel,
        confirmText: context.l10n.confirm,
        initialTime: value ?? TimeOfDay.now(),
      );
      if (time != null) onChanged(time);
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(Icons.schedule, size: 18),
      ),
      child: Text(
        value == null
            ? context.l10n.selectTime
            : AppTimeFormatter(Localizations.localeOf(context)).timeOfDay(
                value!,
                use24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
              ),
      ),
    ),
  );
}

// Revalidate only previously invalid controls when locale changes. Text,
// selection and focus stay intact; untouched fields gain no new errors.
class _LocalizedValidationField<T> extends StatefulWidget {
  const _LocalizedValidationField({required this.builder});
  final Widget Function(GlobalKey<FormFieldState<T>>) builder;
  @override
  State<_LocalizedValidationField<T>> createState() =>
      _LocalizedValidationFieldState<T>();
}

class _LocalizedValidationFieldState<T>
    extends State<_LocalizedValidationField<T>> {
  final _fieldKey = GlobalKey<FormFieldState<T>>();
  Locale? _locale;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_locale != null && _locale != locale) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _fieldKey.currentState?.hasError == true) {
          _fieldKey.currentState!.validate();
        }
      });
    }
    _locale = locale;
  }

  @override
  Widget build(BuildContext context) => widget.builder(_fieldKey);
}

class AppSwitchField extends StatelessWidget {
  const AppSwitchField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
    title: Text(label),
    value: value,
    onChanged: onChanged,
    contentPadding: EdgeInsets.zero,
  );
}
