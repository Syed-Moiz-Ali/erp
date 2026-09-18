import 'package:flutter/material.dart';
import '../../design_system.dart';

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

class AppFormGrid extends StatelessWidget {
  const AppFormGrid({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) =>
      AppResponsiveGrid(minItemWidth: 280, maxColumns: 2, children: children);
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
