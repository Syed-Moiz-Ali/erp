import '../../../l10n/l10n.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/app_formatters.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_typography.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.errorText,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.autofillHints,
    this.onFieldSubmitted,
    this.enabled = true,
    this.autocorrect = true,
    this.maxLines = 1,
    this.labelAbove = false,
    this.labelTrailing,
    this.prefixIconSize = 20,
    this.contentPadding,
  });
  final String label;
  final String? hint, errorText, initialValue;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled, autocorrect;
  final int? maxLines;

  /// Renders a persistent label above the field instead of a floating label.
  final bool labelAbove;
  final Widget? labelTrailing;
  final double prefixIconSize;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    if (!labelAbove) {
      return _LocalizedValidationField<String>(
        builder: (fieldKey) => TextFormField(
          key: fieldKey,
          controller: controller,
          initialValue: controller == null ? initialValue : null,
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
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: prefixIconSize),
            suffixIcon: suffixIcon,
            contentPadding: contentPadding,
          ),
        ),
      );
    }
    return AppFieldLabelGroup(
      label: label,
      trailing: labelTrailing,
      child: AppFieldShell(
        focusNode: focusNode,
        enabled: enabled,
        builder: (node, hovered, focused) => _LocalizedValidationField<String>(
          builder: (fieldKey) => TextFormField(
            key: fieldKey,
            controller: controller,
            initialValue: controller == null ? initialValue : null,
            focusNode: node,
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
            maxLines: maxLines,
            decoration: appCustomInputDecoration(
              context,
              hint: hint ?? label,
              errorText: errorText,
              hovered: hovered,
              focused: focused,
              enabled: enabled,
              prefixIcon: prefixIcon,
              prefixIconSize: prefixIconSize,
              suffixIcon: suffixIcon,
              contentPadding: contentPadding,
            ),
          ),
        ),
      ),
    );
  }
}

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    this.controller,
    this.validator,
    this.label,
    this.hint,
    this.prefixIcon,
    this.focusNode,
    this.textInputAction,
    this.autofillHints,
    this.onFieldSubmitted,
    this.enabled = true,
    this.labelAbove = false,
    this.labelTrailing,
    this.prefixIconSize = 20,
    this.suffixIconSize = 20,
    this.contentPadding,
  });
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;
  final bool labelAbove;
  final Widget? labelTrailing;
  final double prefixIconSize;
  final double suffixIconSize;
  final EdgeInsetsGeometry? contentPadding;
  @override
  State<AppPasswordField> createState() => _PasswordState();
}

class _PasswordState extends State<AppPasswordField> {
  bool hidden = true;

  Widget _reveal(BuildContext context) => IconButton(
    tooltip: hidden ? context.l10n.showPassword : context.l10n.hidePassword,
    onPressed: widget.enabled ? () => setState(() => hidden = !hidden) : null,
    iconSize: widget.suffixIconSize,
    splashRadius: 18,
    visualDensity: VisualDensity.compact,
    style: IconButton.styleFrom(
      foregroundColor: AppColors.textMuted,
      overlayColor: AppColors.brandSubtle,
      hoverColor: AppColors.brandSubtle,
    ),
    icon: Icon(
      hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final label = widget.label ?? context.l10n.password;
    if (!widget.labelAbove) {
      return _LocalizedValidationField<String>(
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
            labelText: label,
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, size: widget.prefixIconSize),
            suffixIcon: _reveal(context),
            contentPadding: widget.contentPadding,
          ),
        ),
      );
    }
    return AppFieldLabelGroup(
      label: label,
      trailing: widget.labelTrailing,
      child: AppFieldShell(
        focusNode: widget.focusNode,
        enabled: widget.enabled,
        builder: (node, hovered, focused) => _LocalizedValidationField<String>(
          builder: (fieldKey) => TextFormField(
            key: fieldKey,
            controller: widget.controller,
            focusNode: node,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            onFieldSubmitted: widget.onFieldSubmitted,
            enabled: widget.enabled,
            validator: widget.validator,
            obscureText: hidden,
            enableSuggestions: false,
            autocorrect: false,
            decoration: appCustomInputDecoration(
              context,
              hint: widget.hint,
              hovered: hovered,
              focused: focused,
              enabled: widget.enabled,
              prefixIcon: widget.prefixIcon,
              prefixIconSize: widget.prefixIconSize,
              suffixIcon: _reveal(context),
              contentPadding: widget.contentPadding,
            ),
          ),
        ),
      ),
    );
  }
}

class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.hint,
    this.label,
    this.onClear,
    this.enabled = true,
  });
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? hint;
  final String? label;
  final VoidCallback? onClear;
  final bool enabled;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  TextEditingController? _internalController;
  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _internalController)?.removeListener(
        _handleControllerChange,
      );
      _controller.addListener(_handleControllerChange);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    _internalController?.dispose();
    super.dispose();
  }

  void _handleControllerChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;
    return AppTextField(
      label: widget.label ?? context.l10n.search,
      hint: widget.hint ?? context.l10n.searchRecords,
      controller: _controller,
      onChanged: widget.onChanged,
      prefixIcon: Icons.search,
      enabled: widget.enabled,
      suffixIcon: hasText && widget.enabled
          ? IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                _controller.clear();
                widget.onChanged?.call('');
                widget.onClear?.call();
              },
            )
          : null,
    );
  }
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
    this.enabled = true,
    this.errorText,
  });
  final String label;
  final bool enabled;
  final String? errorText;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onChanged;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: !enabled
        ? null
        : () async {
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
        errorText: errorText,
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

/// Custom input surface shell. Tracks focus and pointer hover so the field
/// can render a plum focus halo and a subtle hover tone without falling back
/// to thick Material outlined fields.
class AppFieldShell extends StatefulWidget {
  const AppFieldShell({
    super.key,
    required this.builder,
    this.focusNode,
    this.enabled = true,
  });
  final FocusNode? focusNode;
  final bool enabled;
  final Widget Function(FocusNode focusNode, bool hovered, bool focused)
  builder;

  @override
  State<AppFieldShell> createState() => _AppFieldShellState();
}

class _AppFieldShellState extends State<AppFieldShell> {
  late final FocusNode _node = widget.focusNode ?? FocusNode();
  late final bool _ownsNode = widget.focusNode == null;
  bool _focused = false;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _node.addListener(_handleFocusChange);
    _focused = _node.hasFocus;
  }

  void _handleFocusChange() => setState(() => _focused = _node.hasFocus);

  @override
  void dispose() {
    _node.removeListener(_handleFocusChange);
    if (_ownsNode) _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: widget.enabled ? SystemMouseCursors.text : MouseCursor.defer,
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.curveStandard,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.field),
        boxShadow: _focused && widget.enabled
            ? [
                BoxShadow(
                  color: AppColors.brandPrimary.withValues(alpha: 0.16),
                  blurRadius: 0,
                  spreadRadius: 2.5,
                ),
              ]
            : const [],
      ),
      child: widget.builder(_node, _hovered && widget.enabled, _focused),
    ),
  );
}

/// Shared custom decoration for persistent-label inputs.
InputDecoration appCustomInputDecoration(
  BuildContext context, {
  String? hint,
  bool hovered = false,
  bool focused = false,
  bool enabled = true,
  String? errorText,
  IconData? prefixIcon,
  double prefixIconSize = 18,
  Widget? suffixIcon,
  EdgeInsetsGeometry? contentPadding,
}) {
  final typography = AppTypography.of(context);
  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.field),
    borderSide: BorderSide(color: color, width: width),
  );
  final borderColor = hovered
      ? AppColors.inputBorderHover
      : AppColors.inputBorder;
  return InputDecoration(
    hintText: hint,
    errorText: errorText,
    filled: true,
    fillColor: !enabled
        ? AppColors.surfaceSubtle
        : focused
        ? AppColors.surface
        : hovered
        ? AppColors.inputHover
        : AppColors.inputBackground,
    hintStyle: typography.body.copyWith(
      color: AppColors.textDisabled,
      fontSize: 14,
    ),
    errorStyle: typography.caption.copyWith(
      color: AppColors.danger,
      fontSize: 11.5,
    ),
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, size: prefixIconSize, color: AppColors.textDisabled),
    prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    suffixIconColor: AppColors.textMuted,
    suffixIcon: suffixIcon,
    contentPadding:
        contentPadding ??
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: border(borderColor, 1),
    enabledBorder: border(borderColor, 1),
    focusedBorder: border(AppColors.brandPrimary, 1.5),
    errorBorder: border(AppColors.danger, 1),
    focusedErrorBorder: border(AppColors.danger, 1.5),
  );
}

/// Persistent label rendered above a field, with an optional logical-end
/// trailing control (e.g. "Forgot password"). Keeps auth inputs label-led
/// rather than floating-label form controls.
class AppFieldLabelGroup extends StatelessWidget {
  const AppFieldLabelGroup({
    super.key,
    required this.label,
    required this.child,
    this.trailing,
  });
  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 2,
            end: 2,
            bottom: 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        child,
      ],
    );
  }
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
