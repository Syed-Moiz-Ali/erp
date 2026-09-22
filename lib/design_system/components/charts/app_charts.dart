import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../cards/app_cards.dart';
import '../skeletons/app_skeleton.dart';

/// Centralized, semantic chart palette. Feature widgets must not hardcode
/// chart colors; future modules (Services/Finance) reuse these too.
abstract final class AppChartColors {
  static const List<Color> categorical = [
    AppColors.brandPrimary,
    AppColors.success,
    AppColors.warning,
    AppColors.accentLavender,
    AppColors.danger,
    AppColors.neutral,
  ];
  static const completed = AppColors.success;
  static const working = AppColors.brandPrimary;
  static const late = AppColors.warning;
  static const issues = AppColors.danger;
  static const breakTime = AppColors.accentLavender;
  static Color series(int index) => categorical[index % categorical.length];
}

class AppChartSeries {
  const AppChartSeries({
    required this.label,
    required this.color,
    required this.values,
  });
  final String label;
  final Color color;
  final List<double> values;
}

class AppDonutSlice {
  const AppDonutSlice({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;
}

class AppChartLegendItem {
  const AppChartLegendItem(this.label, this.color);
  final String label;
  final Color color;
}

/// Compact chart legend. Wrap-friendly so it stays readable on mobile/RTL.
class AppChartLegend extends StatelessWidget {
  const AppChartLegend({super.key, required this.items});
  final List<AppChartLegendItem> items;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.lg,
    runSpacing: AppSpacing.xs,
    children: [
      for (final item in items)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(item.label, style: AppTypography.of(context).caption),
          ],
        ),
    ],
  );
}

class AppChartEmptyState extends StatelessWidget {
  const AppChartEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.insights_outlined,
  });
  final String message;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: AppColors.textMuted),
        const SizedBox(height: AppSpacing.sm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.of(
            context,
          ).caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    ),
  );
}

/// Consistent analytics surface: title, optional description/trailing, a
/// fixed-height chart area and an optional legend/footer. Handles loading,
/// empty and error states so charts never render empty axes.
class AppChartCard extends StatelessWidget {
  const AppChartCard({
    super.key,
    required this.title,
    this.description,
    this.child,
    this.legend,
    this.trailing,
    this.footer,
    this.loading = false,
    this.empty = false,
    this.emptyMessage,
    this.error = false,
    this.onRetry,
    this.height = 260,
    this.semanticLabel,
  });
  final String title;
  final String? description, emptyMessage, footer, semanticLabel;
  final Widget? child, legend, trailing;
  final bool loading, empty, error;
  final VoidCallback? onRetry;
  final double height;
  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: typography.cardTitle),
                    if (description != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(description!, style: typography.caption),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: height,
            child: loading
                ? const AppSkeleton(height: 240)
                : error
                ? Center(
                    child: AppChartEmptyState(
                      message: description ?? title,
                      icon: Icons.error_outline,
                    ),
                  )
                : empty
                ? AppChartEmptyState(message: emptyMessage ?? title)
                : Semantics(
                    label: semanticLabel ?? title,
                    container: true,
                    child: child ?? const SizedBox.shrink(),
                  ),
          ),
          if (legend != null) ...[
            const SizedBox(height: AppSpacing.md),
            legend!,
          ],
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              footer!,
              style: typography.caption.copyWith(color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

String _axisLabel(int index, List<String> labels) =>
    index >= 0 && index < labels.length ? labels[index] : '';

int _labelInterval(int count) => count <= 8 ? 1 : (count / 6).ceil();

/// Generic line chart. Caller provides localized x labels and typed series;
/// time order is preserved as given (never reversed for RTL).
class AppLineChart extends StatelessWidget {
  const AppLineChart({
    super.key,
    required this.labels,
    required this.series,
    this.formatY,
    this.curve = true,
  });
  final List<String> labels;
  final List<AppChartSeries> series;
  final String Function(double)? formatY;
  final bool curve;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final totalPoints = labels.length;
    if (totalPoints < 2 || series.isEmpty) {
      return const SizedBox.shrink();
    }
    var maxY = 0.0;
    for (final s in series) {
      for (var i = 0; i < s.values.length && i < totalPoints; i++) {
        if (s.values[i] > maxY) maxY = s.values[i];
      }
    }
    maxY = maxY <= 0 ? 1 : maxY * 1.2;
    final interval = _labelInterval(totalPoints);
    final gridColor = AppColors.borderSubtle;
    return LineChart(
      duration: reduceMotion ? Duration.zero : AppMotionChart.duration,
      LineChartData(
        minX: 0,
        maxX: (totalPoints - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: gridColor, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
                child: Text(
                  formatY?.call(value) ?? value.toInt().toString(),
                  style: AppTypography.of(context).caption,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: interval.toDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if ((value - index).abs() > 0.001) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    _axisLabel(index, labels),
                    style: AppTypography.of(context).caption,
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          for (final s in series)
            LineChartBarData(
              spots: [
                for (var i = 0; i < totalPoints && i < s.values.length; i++)
                  FlSpot(i.toDouble(), s.values[i]),
              ],
              color: s.color,
              barWidth: 2.5,
              isCurved: curve,
              dotData: FlDotData(show: totalPoints <= 14),
              belowBarData: BarAreaData(
                show: series.length == 1,
                color: s.color.withValues(alpha: .08),
              ),
            ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (_) => AppColors.textPrimary,
            getTooltipItems: (spots) => [
              for (final spot in spots)
                LineTooltipItem(
                  '${_axisLabel(spot.x.round(), labels)} · '
                  '${formatY?.call(spot.y) ?? spot.y.toInt().toString()}',
                  AppTypography.of(
                    context,
                  ).caption.copyWith(color: AppColors.surface),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Generic single-series bar chart (zero baseline).
class AppBarChart extends StatelessWidget {
  const AppBarChart({
    super.key,
    required this.labels,
    required this.values,
    required this.color,
    this.formatY,
  });
  final List<String> labels;
  final List<double> values;
  final Color color;
  final String Function(double)? formatY;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (values.isEmpty) return const SizedBox.shrink();
    var maxY = 0.0;
    for (final v in values) {
      if (v > maxY) maxY = v;
    }
    maxY = maxY <= 0 ? 1 : maxY * 1.2;
    final interval = _labelInterval(values.length);
    final gridColor = AppColors.borderSubtle;
    final barWidth = (180 / values.length).clamp(6, 26).toDouble();
    return BarChart(
      duration: reduceMotion ? Duration.zero : AppMotionChart.duration,
      BarChartData(
        minY: 0,
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: gridColor, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
                child: Text(
                  formatY?.call(value) ?? value.toInt().toString(),
                  style: AppTypography.of(context).caption,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: interval.toDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= values.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    labels[index],
                    style: AppTypography.of(context).caption,
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.textPrimary,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
                  '${_axisLabel(group.x, labels)} · '
                  '${formatY?.call(rod.toY) ?? rod.toY.toInt().toString()}',
                  AppTypography.of(
                    context,
                  ).caption.copyWith(color: AppColors.surface),
                ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  color: color,
                  width: barWidth,
                  borderRadius: BorderRadius.circular(AppRadius.radiusXs),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Generic donut chart with an optional center value. Only used where a
/// part-to-whole composition is semantically valid.
class AppDonutChart extends StatelessWidget {
  const AppDonutChart({
    super.key,
    required this.slices,
    this.centerTitle,
    this.centerValue,
  });
  final List<AppDonutSlice> slices;
  final String? centerTitle, centerValue;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);
    if (slices.isEmpty || total <= 0) return const SizedBox.shrink();
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          duration: reduceMotion ? Duration.zero : AppMotionChart.duration,
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 52,
            sections: [
              for (final slice in slices)
                PieChartSectionData(
                  value: slice.value,
                  color: slice.color,
                  radius: 22,
                ),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (centerValue != null)
              Text(centerValue!, style: AppTypography.of(context).metricValue),
            if (centerTitle != null)
              Text(centerTitle!, style: AppTypography.of(context).caption),
          ],
        ),
      ],
    );
  }
}

abstract final class AppMotionChart {
  static const duration = Duration(milliseconds: 220);
}
