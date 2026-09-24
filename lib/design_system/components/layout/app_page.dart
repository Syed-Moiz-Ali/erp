import 'package:modular_erp/design_system/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/design_system/theme/app_spacing.dart';
import 'package:modular_erp/design_system/theme/app_motion.dart';
import 'package:modular_erp/design_system/components/cards/app_cards.dart';
import 'package:modular_erp/design_system/components/headers/app_headers.dart';

/// The single, global ERP page content width.
///
/// Every feature screen (HR, Services, Settings, future modules) shares this
/// exact width and is horizontally centered inside the main workspace, so the
/// left and right free space are always equal. There are deliberately **no**
/// per-screen width modes: the page itself always has one width. Internal
/// components may still use their own grids/columns.
///
/// Do not place another scrollable (`ListView`) directly inside [child]; use a
/// `Column` or provide a dedicated sliver body.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.child,
    this.header,
    this.filters,
    this.animateEntrance = true,
    this.scrollPhysics,
  });
  final Widget child;
  final Widget? header, filters;
  final bool animateEntrance;
  final ScrollPhysics? scrollPhysics;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: scrollPhysics,
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.contentMaxWidth,
        ),
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
    this.card = true,
  });
  final String title;
  final String? subtitle;
  final Widget child;
  final bool card;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: title, subtitle: subtitle),
        const SizedBox(height: AppSpacing.xl),
        child,
      ],
    );

    if (!card) return content;

    return AppCard(child: content);
  }
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
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
