import 'package:flutter/material.dart';
import '../../theme/app_breakpoints.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_motion.dart';
import '../cards/app_cards.dart';
import '../headers/app_headers.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: Padding(
          padding: EdgeInsets.all(
            AppBreakpoints.of(context) == AppSize.compact
                ? AppSpacing.lg
                : AppSpacing.section,
          ),
          child: AppMotion.entrance(context, child),
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
  });
  final List<Widget> children;
  final double minItemWidth;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final count = ((constraints.maxWidth + 16) / (minItemWidth + 16))
          .floor()
          .clamp(1, 4);
      final width = (constraints.maxWidth - 16 * (count - 1)) / count;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: children
            .map((c) => SizedBox(width: width, child: c))
            .toList(),
      );
    },
  );
}
