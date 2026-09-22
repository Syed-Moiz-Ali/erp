import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'app_cards.dart';

/// Reusable labeled before/after comparison for approval workflows.
class AppChangeComparison extends StatelessWidget {
  const AppChangeComparison({
    super.key,
    required this.title,
    required this.beforeLabel,
    required this.before,
    required this.afterLabel,
    required this.after,
  });
  final String title, beforeLabel, before, afterLabel, after;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.of(context).cardTitle),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.xxl,
          runSpacing: AppSpacing.md,
          children: [
            _Value(label: beforeLabel, value: before),
            Icon(
              Icons.arrow_forward,
              size: 18,
              textDirection: Directionality.of(context),
            ),
            _Value(label: afterLabel, value: after),
          ],
        ),
      ],
    ),
  );
}

class _Value extends StatelessWidget {
  const _Value({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTypography.of(context).caption),
      const SizedBox(height: AppSpacing.xs),
      Text(value, style: AppTypography.of(context).body),
    ],
  );
}
