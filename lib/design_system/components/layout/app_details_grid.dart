import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/design_system.dart';

import '../../theme/app_breakpoints.dart';

class AppDetailField extends StatelessWidget {
  const AppDetailField({
    super.key,
    required this.label,
    required this.value,
    this.identifier = false,
  });
  final String label, value;
  final bool identifier;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTypography.of(context).caption),
      const SizedBox(height: AppSpacing.xs),
      Text(
        value,
        style: AppTypography.of(context).body,
        textDirection: identifier ? TextDirection.ltr : null,
      ),
    ],
  );
}

class AppDetailsGrid extends StatelessWidget {
  const AppDetailsGrid({super.key, required this.fields, this.compact = false});
  final List<AppDetailField> fields;
  final bool compact;
  @override
  Widget build(BuildContext context) => AppResponsiveGrid(
    minItemWidth: compact
        ? AppDimensions.compactDetailField
        : AppDimensions.detailField,
    maxColumns: 2,
    children: fields,
  );
}

/// A 12-column responsive form grid.
///
/// Each child occupies [spans] units out of 12 (default 6, i.e. two per row on
/// desktop). Compact (mobile) always collapses to a single column, medium
/// (tablet) adapts to two columns, and expanded/large keep the requested
/// spans. Widths are derived from the shared [AppSpacing.lg] gutter so every
/// field aligns to one system.
class AppFormGrid extends StatelessWidget {
  const AppFormGrid({super.key, required this.children, this.spans});
  final List<Widget> children;

  /// Optional 12-column span per child (clamped to 1..12). Defaults to 6.
  final List<int>? spans;

  static const int _columns = 12;

  @override
  Widget build(BuildContext context) {
    assert(
      spans == null || spans!.length == children.length,
      'AppFormGrid spans must match children length',
    );
    if (children.isEmpty) return const SizedBox.shrink();
    final size = AppBreakpoints.of(context);
    const gap = AppSpacing.lg;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final unit = (width - gap * (_columns - 1)) / _columns;
        double fieldWidth(int span) => unit * span + gap * (span - 1);
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < children.length; i++)
              SizedBox(
                width: fieldWidth(_effectiveSpan(spans?[i] ?? 6, size)),
                child: children[i],
              ),
          ],
        );
      },
    );
  }

  int _effectiveSpan(int span, AppSize size) {
    final clamped = span.clamp(1, _columns);
    return switch (size) {
      AppSize.compact => _columns,
      AppSize.medium => clamped >= 9 ? _columns : (clamped <= 6 ? 6 : clamped),
      AppSize.expanded || AppSize.large => clamped,
    };
  }
}

/// Standard span weights for Services/ERP forms. Use with [AppFormGrid.spans].
abstract final class AppFormSpan {
  static const int quarter = 3;
  static const int third = 4;
  static const int half = 6;
  static const int twoThirds = 8;
  static const int threeQuarters = 9;
  static const int full = 12;
}

/// Read-only inherited context (key/value), never disabled inputs.
class AppReadOnlyContextSection extends StatelessWidget {
  const AppReadOnlyContextSection({
    super.key,
    required this.title,
    required this.fields,
    this.subtitle,
  });
  final String title;
  final String? subtitle;
  final List<AppDetailField> fields;
  @override
  Widget build(BuildContext context) => AppFormSection(
    title: title,
    subtitle: subtitle,
    child: AppDetailsGrid(fields: fields),
  );
}

/// Small metadata/value display for a system-generated value (for example a
/// document number that is minted on save). Never an editable input.
class AppGeneratedValueField extends StatelessWidget {
  const AppGeneratedValueField({
    super.key,
    required this.label,
    this.value,
    this.generatedFallback,
    this.identifier = false,
  });
  final String label;
  final String? value, generatedFallback;
  final bool identifier;
  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return AppDetailField(
      label: label,
      value: hasValue ? value! : (generatedFallback ?? ''),
      identifier: identifier && hasValue,
    );
  }
}

/// Audit/system metadata (created/updated by and timestamps) for detail or edit
/// pages. Renders as read-only key/value context, never as editable inputs.
class AppAuditMetadataBlock extends StatelessWidget {
  const AppAuditMetadataBlock({
    super.key,
    required this.title,
    required this.createdByLabel,
    required this.createdAtLabel,
    required this.updatedByLabel,
    required this.updatedAtLabel,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });
  final String title;
  final String createdByLabel, createdAtLabel, updatedByLabel, updatedAtLabel;
  final String? createdBy, createdAt, updatedBy, updatedAt;
  @override
  Widget build(BuildContext context) {
    final fields = <AppDetailField>[
      if (createdBy != null)
        AppDetailField(label: createdByLabel, value: createdBy!),
      if (createdAt != null)
        AppDetailField(
          label: createdAtLabel,
          value: createdAt!,
          identifier: true,
        ),
      if (updatedBy != null)
        AppDetailField(label: updatedByLabel, value: updatedBy!),
      if (updatedAt != null)
        AppDetailField(
          label: updatedAtLabel,
          value: updatedAt!,
          identifier: true,
        ),
    ];
    if (fields.isEmpty) return const SizedBox.shrink();
    return AppReadOnlyContextSection(title: title, fields: fields);
  }
}

class AppRelatedAction extends StatelessWidget {
  const AppRelatedAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) =>
      AppSecondaryButton(label: label, icon: icon, onPressed: onPressed);
}
