import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_colors.dart';

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
    required this.detail,
    this.icon = Icons.insights_outlined,
  });
  final String label, value, detail;
  final IconData icon;
  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: AppTypography.of(context).caption),
            ),
            Icon(icon, size: 20, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: 12),
        Text(value, style: AppTypography.of(context).pageTitle),
        const SizedBox(height: 4),
        Text(detail, style: AppTypography.of(context).caption),
      ],
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
