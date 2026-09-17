import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_colors.dart';
import '../status/app_status_badge.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xxl),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Card(
    child: SizedBox(
      width: double.infinity,
      child: Padding(padding: padding, child: child),
    ),
  );
}

class AppMetricCard extends StatelessWidget {
  const AppMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.detail = '',
    this.icon = Icons.insights_outlined,
    this.status = AppStatus.neutral,
  });
  final String label, value, detail;
  final IconData icon;
  final AppStatus status;
  @override
  Widget build(BuildContext context) => Semantics(
    label: [label, value, if (detail.isNotEmpty) detail].join(', '),
    child: ExcludeSemantics(
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(label, style: AppTypography.of(context).label),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(icon, size: 20, color: status.color),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(value, style: AppTypography.of(context).pageTitle),
            if (detail.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(detail, style: AppTypography.of(context).caption),
            ],
          ],
        ),
      ),
    ),
  );
}

class AppInfoCard extends StatelessWidget {
  const AppInfoCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline,
  });
  final String title, message;
  final IconData icon;
  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.info),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.of(context).cardTitle),
              const SizedBox(height: 4),
              Text(message, style: AppTypography.of(context).body),
            ],
          ),
        ),
      ],
    ),
  );
}
