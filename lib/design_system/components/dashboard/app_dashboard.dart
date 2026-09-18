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
    this.card = true,
    this.action,
  });
  final String title;
  final String? subtitle;
  final Widget child;

  /// Card-less sections let the dashboard breathe instead of stacking a card
  /// around every block.
  final bool card;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: title, subtitle: subtitle, action: action),
        SizedBox(height: card ? AppSpacing.xl : AppSpacing.lg),
        child,
      ],
    );
    return card ? AppCard(child: content) : content;
  }
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
  Widget build(BuildContext context) {
    final theme = AppTypography.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.radiusMd),
            ),
            child: Icon(icon, size: 15, color: status.color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(description, style: theme.caption),
                ],
              ],
            ),
          ),
          if (timestamp.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: Text(
                timestamp,
                style: theme.caption.copyWith(
                  color: AppColors.textMuted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact inline metric (muted label above a stronger value) used for the
/// dashboard "Today" and "This month" quick stats — no card chrome.
class AppMetricTile extends StatelessWidget {
  const AppMetricTile({super.key, required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    final theme = AppTypography.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.body.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// A single-row set of compact stats separated by subtle vertical dividers.
class AppInlineStats extends StatelessWidget {
  const AppInlineStats({super.key, required this.stats});
  final List<({String label, String value})> stats;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      for (var i = 0; i < stats.length; i++) ...[
        if (i > 0)
          Container(
            width: 1,
            height: 34,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            color: AppColors.borderSubtle,
          ),
        Expanded(
          child: AppMetricTile(label: stats[i].label, value: stats[i].value),
        ),
      ],
    ],
  );
}

/// Secondary statistic: deliberately lighter than [AppMetricCard] so the
/// dashboard has a clear primary → secondary hierarchy.
class AppSecondaryStat extends StatelessWidget {
  const AppSecondaryStat({
    super.key,
    required this.label,
    required this.value,
    this.status = AppStatus.neutral,
  });
  final String label, value;
  final AppStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = AppTypography.of(context);
    return Row(
      children: [
        if (status != AppStatus.neutral) ...[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.caption.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          value,
          maxLines: 1,
          style: theme.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// A compact horizontal strip of secondary statistics separated by hairlines.
class AppStatStrip extends StatelessWidget {
  const AppStatStrip({super.key, required this.stats});
  final List<Widget> stats;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(color: AppColors.borderDefault),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    child: Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0)
            Container(width: 1, height: 26, color: AppColors.borderSubtle),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: i == 0 ? 0 : AppSpacing.lg,
                end: i == stats.length - 1 ? 0 : AppSpacing.lg,
              ),
              child: stats[i],
            ),
          ),
        ],
      ],
    ),
  );
}

/// Actionable attention row with a semantic icon, context and chevron.
class AppAttentionItem extends StatelessWidget {
  const AppAttentionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.status = AppStatus.warning,
    this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final AppStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTypography.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.control),
      hoverColor: AppColors.surfaceHover,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.radiusMd),
              ),
              child: Icon(icon, size: 16, color: status.color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.caption,
                    ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                rtl ? Icons.chevron_left : Icons.chevron_right,
                size: 18,
                color: AppColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}

/// Groups attention rows with subtle hairline separation.
class AppAttentionList extends StatelessWidget {
  const AppAttentionList({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0)
          const Padding(
            padding: EdgeInsetsDirectional.only(start: AppSpacing.wide),
            child: Divider(height: 1),
          ),
        children[i],
      ],
    ],
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
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
          child: Row(
            children: [
              Icon(Icons.circle, size: 7, color: row.status.color),
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
        primary: AppCard(child: AppSkeleton(height: 140)),
        secondary: AppCard(child: AppSkeleton(height: 140)),
      ),
      const SizedBox(height: AppSpacing.xxl),
      const AppCard(child: AppSkeleton(height: 76)),
      const SizedBox(height: AppSpacing.xxl),
      const AppCard(child: AppSkeleton(height: 148)),
    ],
  );
}
