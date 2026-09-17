import '../../theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import '../../theme/app_breakpoints.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_motion.dart';
import '../cards/app_cards.dart';
import '../headers/app_headers.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.child,
    this.header,
    this.filters,
    this.maxWidth = AppDimensions.content,
    this.animateEntrance = true,
    this.scrollPhysics,
  });
  final Widget child;
  final Widget? header, filters;
  final double maxWidth;
  final bool animateEntrance;
  final ScrollPhysics? scrollPhysics;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: scrollPhysics,
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.all(
            AppBreakpoints.of(context) == AppSize.compact
                ? AppSpacing.lg
                : AppSpacing.section,
          ),
          child: Builder(
            builder: (context) {
              final body = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (header != null) ...[
                    header!,
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                  if (filters != null) ...[
                    filters!,
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  child,
                ],
              );
              return animateEntrance ? AppMotion.entrance(context, body) : body;
            },
          ),
        ),
      ),
    ),
  );
}

class AppFormSection extends StatelessWidget {
  const AppFormSection({
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: title, subtitle: subtitle),
        const SizedBox(height: 24),
        child,
      ],
    ),
  );
}

class AppDetailsSection extends StatelessWidget {
  const AppDetailsSection({
    super.key,
    required this.title,
    required this.details,
  });
  final String title;
  final Map<String, String> details;
  @override
  Widget build(BuildContext context) => AppFormSection(
    title: title,
    child: Column(
      children: details.entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text(e.key)),
                  Expanded(child: Text(e.value)),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );
}

class AppResponsiveGrid extends StatelessWidget {
  const AppResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 260,
    this.maxColumns = 4,
    this.equalRowHeights = false,
    this.balanceRows = false,
  });
  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  final bool equalRowHeights, balanceRows;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (children.isEmpty) return const SizedBox.shrink();
      var count =
          ((constraints.maxWidth + AppSpacing.lg) /
                  (minItemWidth + AppSpacing.lg))
              .floor()
              .clamp(1, maxColumns);
      if (balanceRows) {
        final rows = (children.length / count).ceil();
        count = (children.length / rows).ceil();
      }
      final width =
          (constraints.maxWidth - AppSpacing.lg * (count - 1)) / count;
      if (equalRowHeights) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var start = 0; start < children.length; start += count) ...[
              if (start > 0) const SizedBox(height: AppSpacing.lg),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (
                      var i = start;
                      i < children.length && i < start + count;
                      i++
                    ) ...[
                      if (i > start) const SizedBox(width: AppSpacing.lg),
                      SizedBox(width: width, child: children[i]),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      }
      return Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.lg,
        children: children
            .map((c) => SizedBox(width: width, child: c))
            .toList(),
      );
    },
  );
}
