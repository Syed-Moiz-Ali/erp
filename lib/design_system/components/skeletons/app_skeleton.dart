import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:flutter/material.dart';

class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.3,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceSubtle;
    final highlight = isDark
        ? AppColors.darkSurfaceHover
        : AppColors.borderSubtle;
    final radius =
        widget.borderRadius ?? BorderRadius.circular(AppRadius.radiusSm);

    if (disableAnimations) {
      return Semantics(
        label: context.l10n.loading,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(color: base, borderRadius: radius),
        ),
      );
    }

    return Semantics(
      label: context.l10n.loading,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(base, highlight, _animation.value),
            borderRadius: radius,
          ),
        ),
      ),
    );
  }
}

/// Geometry-aware skeleton for the shared data table: header row plus dense
/// data rows, so loading resembles the eventual table instead of a spinner.
class AppTableSkeleton extends StatelessWidget {
  const AppTableSkeleton({super.key, this.rows = 6, this.columns = 4});

  final int rows;
  final int columns;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          for (var c = 0; c < columns; c++) ...[
            if (c > 0) const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: AppSkeleton(width: c == 0 ? 120 : null, height: 12),
            ),
          ],
        ],
      ),
      const SizedBox(height: AppSpacing.lg),
      for (var r = 0; r < rows; r++) ...[
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            for (var c = 0; c < columns; c++) ...[
              if (c > 0) const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: AppSkeleton(width: c == 0 ? 140 : null, height: 14),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    ],
  );
}

/// Geometry-aware skeleton for detail pages (label/value pairs + sections).
class AppDetailSkeleton extends StatelessWidget {
  const AppDetailSkeleton({super.key, this.sections = 3});

  final int sections;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AppSkeleton(width: 220, height: 24),
      const SizedBox(height: AppSpacing.lg),
      for (var s = 0; s < sections; s++) ...[
        Row(
          children: const [
            Expanded(child: AppSkeleton(height: 14)),
            SizedBox(width: AppSpacing.xxl),
            Expanded(child: AppSkeleton(height: 14)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    ],
  );
}

class AppConfigurationSkeleton extends StatelessWidget {
  const AppConfigurationSkeleton({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < 3; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSkeleton(width: 160, height: 24),
                const SizedBox(height: AppSpacing.lg),
                const AppSkeleton(),
                const SizedBox(height: AppSpacing.md),
                const AppSkeleton(width: 220),
              ],
            ),
          ),
        ),
    ],
  );
}
