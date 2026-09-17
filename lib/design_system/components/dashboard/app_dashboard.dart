import '../../theme/app_breakpoints.dart';
import 'package:flutter/material.dart';
import '../../design_system.dart';

/// Uses the existing responsive grid; text scaling increases minimum width.
class AppDashboardGrid extends StatelessWidget {
  const AppDashboardGrid({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => AppResponsiveGrid(
    minItemWidth: 148 * MediaQuery.textScalerOf(context).scale(1).clamp(1, 1.5),
    maxColumns: AppBreakpoints.of(context) == AppSize.large ? 6 : 4,
    balanceRows: true,
    equalRowHeights: true,
    children: children,
  );
}

class AppDashboardSection extends StatelessWidget {
  const AppDashboardSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });
  final String title;
  final String? subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: title, subtitle: subtitle),
        const SizedBox(height: AppSpacing.xl),
        child,
      ],
    ),
  );
}

class AppDashboardTwoColumn extends StatelessWidget {
  const AppDashboardTwoColumn({
    super.key,
    required this.primary,
    required this.secondary,
    this.primaryFlex = 2,
    this.secondaryFlex = 1,
  });
  final Widget primary, secondary;
  final int primaryFlex, secondaryFlex;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = AppBreakpoints.of(context);
      final available = AppBreakpoints.classify(constraints.maxWidth);
      if (available == AppSize.compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            primary,
            const SizedBox(height: AppSpacing.xxl),
            secondary,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: size == AppSize.medium ? 1 : primaryFlex,
            child: primary,
          ),
          const SizedBox(width: AppSpacing.xxl),
          Expanded(flex: secondaryFlex, child: secondary),
        ],
      );
    },
  );
}

class AppQuickActionCard extends StatelessWidget {
  const AppQuickActionCard({
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

class AppActivityItem extends StatelessWidget {
  const AppActivityItem({
    super.key,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    this.status = AppStatus.neutral,
  });
  final String title, description, timestamp;
  final IconData icon;
  final AppStatus status;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: status.color),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.of(context).label),
              const SizedBox(height: AppSpacing.xs),
              if (description.isNotEmpty)
                Text(description, style: AppTypography.of(context).caption),
              if (timestamp.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(timestamp, style: AppTypography.of(context).caption),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class AppStatusSummary extends StatelessWidget {
  const AppStatusSummary({super.key, required this.rows});
  final List<({String label, String value, AppStatus status})> rows;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final row in rows)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Icon(Icons.circle, size: 8, color: row.status.color),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(row.label, style: AppTypography.of(context).body),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  row.value,
                  textAlign: TextAlign.end,
                  style: AppTypography.of(context).label,
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class AppDashboardSkeleton extends StatelessWidget {
  const AppDashboardSkeleton({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppDashboardGrid(
        children: List.generate(
          4,
          (_) => const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(width: 100),
                SizedBox(height: AppSpacing.xl),
                AppSkeleton(width: 64, height: 32),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.xxl),
      const AppDashboardTwoColumn(
        primary: AppCard(child: AppSkeleton(height: 180)),
        secondary: AppCard(child: AppSkeleton(height: 180)),
      ),
    ],
  );
}
