import '../../design_system.dart';
import '../../../l10n/l10n.dart';
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
    final radius =
        widget.borderRadius ?? BorderRadius.circular(AppRadius.radiusSm);

    if (disableAnimations) {
      return Semantics(
        label: context.l10n.loading,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: radius,
          ),
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
            color: Color.lerp(
              AppColors.surfaceSubtle,
              AppColors.borderSubtle,
              _animation.value,
            ),
            borderRadius: radius,
          ),
        ),
      ),
    );
  }
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
