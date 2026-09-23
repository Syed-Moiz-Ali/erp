import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';

/// Signature Bitlogix motif: three layered diamonds. Reused in the brand
/// mark, the workspace object and as a low-contrast background element.
class BitlogixMark extends StatelessWidget {
  const BitlogixMark({
    super.key,
    this.size = 32,
    this.accent = AppColors.brandPrimary,
    this.highlight = AppColors.accentLavender,
  });

  final double size;
  final Color accent;
  final Color highlight;

  Widget _diamond(double side, Color color, double radius) => Transform.rotate(
    angle: math.pi / 4,
    child: Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      alignment: Alignment.center,
      children: [
        _diamond(size * 0.74, accent.withValues(alpha: 0.26), size * 0.14),
        _diamond(size * 0.52, accent, size * 0.11),
        _diamond(size * 0.28, highlight, size * 0.08),
      ],
    ),
  );
}

class AppProductIdentity extends StatelessWidget {
  const AppProductIdentity({super.key, this.isDark = false});
  final bool isDark;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: isDark
                ? const [Color(0xFF6B234C), Color(0xFF4E1736)]
                : const [AppColors.brandSecondary, AppColors.brandPrimary],
          ),
          borderRadius: BorderRadius.circular(11),
          boxShadow: const [
            BoxShadow(
              color: Color(0x244E1736),
              offset: Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: BitlogixMark(
            size: 23,
            accent: Colors.white,
            highlight: const Color(0xFFE6D2E2),
          ),
        ),
      ),
      const SizedBox(width: AppSpacing.md),
      Flexible(
        child: Text(
          context.l10n.appName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.of(context).bodyLarge.copyWith(
            fontSize: 16.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    ],
  );
}

/// Recomposed authentication presentation.
///
/// Desktop and mobile/tablet are intentionally different compositions that
/// share one brand system and one form. No fake tenant data is shown.
class AppAuthLayout extends StatelessWidget {
  const AppAuthLayout({
    super.key,
    required this.child,
    this.showBrandPanel = true,
    this.developerAccess,
  });

  final Widget child;
  final bool showBrandPanel;

  /// Development-only control. Rendered unobtrusively, never in the primary
  /// hierarchy. Production should pass null.
  final Widget? developerAccess;

  @override
  Widget build(BuildContext context) {
    final size = AppBreakpoints.classify(MediaQuery.sizeOf(context).width);
    final body = switch (size) {
      AppSize.compact => MobileAuthLayout(
        showBrandPanel: showBrandPanel,
        developerAccess: developerAccess,
        child: child,
      ),
      AppSize.medium => TabletAuthLayout(
        showBrandPanel: showBrandPanel,
        developerAccess: developerAccess,
        child: child,
      ),
      AppSize.expanded || AppSize.large => DesktopAuthLayout(
        showBrandPanel: showBrandPanel,
        developerAccess: developerAccess,
        child: child,
      ),
    };
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(child: body),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop: product storytelling + calm authentication panel
// ---------------------------------------------------------------------------

class DesktopAuthLayout extends StatelessWidget {
  const DesktopAuthLayout({
    super.key,
    required this.child,
    this.showBrandPanel = true,
    this.developerAccess,
  });

  final Widget child;
  final bool showBrandPanel;
  final Widget? developerAccess;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final maxW = constraints.maxWidth;
      final maxH = constraints.maxHeight;
      final margin = (maxW * 0.02).clamp(24.0, 36.0);
      final stageW = maxW - margin * 2;
      final stageH = (maxH - margin * 2).clamp(560.0, 1200.0);

      return SingleChildScrollView(
        key: const ValueKey('auth-scroll'),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: margin, vertical: margin),
          child: Center(
            child: AppMotion.fadeIn(
              context,
              SizedBox(
                width: stageW,
                height: stageH,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.appSurface,
                    borderRadius: BorderRadius.circular(AppRadius.frame),
                    border: Border.all(color: AppColors.borderDefault),
                    boxShadow: AppElevation.applicationFrame,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      const _AppHeader(),
                      const _Hairline(color: AppColors.borderSubtle),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 58,
                              child: showBrandPanel
                                  ? const _ProductStage()
                                  : const _BrandBackdrop(),
                            ),
                            Expanded(
                              flex: 42,
                              child: _AuthPanel(
                                developerAccess: developerAccess,
                                child: child,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _AuthPanel extends StatelessWidget {
  const _AuthPanel({required this.child, this.developerAccess});
  final Widget child;
  final Widget? developerAccess;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.authSurface,
            gradient: RadialGradient(
              center: const AlignmentDirectional(0.9, -0.95),
              radius: 1.15,
              colors: [
                AppColors.accentLavender.withValues(alpha: 0.055),
                AppColors.accentLavender.withValues(alpha: 0),
              ],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Align(
                  alignment: const Alignment(0, -0.02),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.wide,
                      vertical: AppSpacing.section,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: AppMotion.entrance(context, child),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      if (developerAccess != null)
        PositionedDirectional(
          end: AppSpacing.md,
          bottom: AppSpacing.md,
          child: developerAccess!,
        ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tablet / mobile: one continuous branded composition
// ---------------------------------------------------------------------------

class TabletAuthLayout extends StatelessWidget {
  const TabletAuthLayout({
    super.key,
    required this.child,
    this.showBrandPanel = true,
    this.developerAccess,
  });

  final Widget child;
  final bool showBrandPanel;
  final Widget? developerAccess;

  @override
  Widget build(BuildContext context) {
    return _NarrowScaffold(
      showBackdrop: showBrandPanel,
      horizontalPadding: AppSpacing.section,
      contentMaxWidth: 440,
      topPadding: AppSpacing.xxl,
      developerAccess: developerAccess,
      child: child,
    );
  }
}

class MobileAuthLayout extends StatelessWidget {
  const MobileAuthLayout({
    super.key,
    required this.child,
    this.showBrandPanel = true,
    this.developerAccess,
  });

  final Widget child;
  final bool showBrandPanel;
  final Widget? developerAccess;

  @override
  Widget build(BuildContext context) {
    return _NarrowScaffold(
      showBackdrop: showBrandPanel,
      horizontalPadding: AppSpacing.xl,
      contentMaxWidth: 460,
      topPadding: AppSpacing.xl,
      developerAccess: developerAccess,
      child: child,
    );
  }
}

/// Continuous mobile / tablet composition: pinned brand header, then the
/// authentication form directly below so login is immediate. The backdrop
/// motif carries brand identity without consuming layout height.
class _NarrowScaffold extends StatelessWidget {
  const _NarrowScaffold({
    required this.child,
    required this.horizontalPadding,
    required this.contentMaxWidth,
    required this.topPadding,
    required this.showBackdrop,
    this.developerAccess,
  });

  final Widget child;
  final double horizontalPadding;
  final double contentMaxWidth;
  final double topPadding;
  final bool showBackdrop;
  final Widget? developerAccess;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: AlignmentDirectional.topCenter,
        end: AlignmentDirectional.bottomCenter,
        colors: [AppColors.mobileCanvasTop, AppColors.mobileCanvasBottom],
      ),
    ),
    child: Stack(
      children: [
        if (showBackdrop) const Positioned.fill(child: _NarrowBackdrop()),
        Positioned.fill(
          child: SingleChildScrollView(
            key: const ValueKey('auth-scroll'),
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: horizontalPadding,
                end: horizontalPadding,
                top: topPadding,
                bottom: AppSpacing.xxl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppMotion.fadeIn(
                        context,
                        _AppHeader(
                          horizontalPadding: 0,
                          height: 48,
                          developerAccess: developerAccess,
                        ),
                      ),
                      const SizedBox(
                        height: AppSpacing.section + AppSpacing.xs,
                      ),
                      AppMotion.entrance(context, child),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Internal application header
// ---------------------------------------------------------------------------

class _AppHeader extends StatelessWidget {
  const _AppHeader({
    this.horizontalPadding = AppSpacing.wide,
    this.height = 68,
    this.developerAccess,
  });
  final double horizontalPadding;
  final double height;
  final Widget? developerAccess;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          const Expanded(child: AppProductIdentity()),
          const AppLanguageSelector(compact: true),
          if (developerAccess != null) ...[
            const SizedBox(width: AppSpacing.xs),
            developerAccess!,
          ],
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Product experience: editorial copy + connected module scene
// ---------------------------------------------------------------------------

class _ProductStage extends StatelessWidget {
  const _ProductStage();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: [AppColors.productTint, AppColors.productTintAlt],
      ),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final panelW = constraints.maxWidth;
        final startPad = (panelW * 0.11).clamp(40.0, 150.0);
        final contentW = (panelW * 0.78).clamp(400.0, 700.0);
        return Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: const _BackdropPainter()),
              ),
            ),
            PositionedDirectional(
              bottom: -96,
              start: -76,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.05,
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: BitlogixMark(
                      size: 330,
                      accent: AppColors.brandPrimary,
                    ),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: -60,
              end: -40,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.06,
                  child: BitlogixMark(
                    size: 200,
                    accent: AppColors.accentLavender,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: startPad,
                end: AppSpacing.section,
                top: AppSpacing.xxl,
                bottom: AppSpacing.xxl,
              ),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - AppSpacing.page).clamp(
                      0.0,
                      double.infinity,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Reveal(delayMs: 0, child: const _ProductEyebrow()),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: contentW * 0.96,
                        child: _Reveal(
                          delayMs: 40,
                          child: Text(
                            context.l10n.productHeadline,
                            style: AppTypography.of(context).displaySmall
                                .copyWith(
                                  fontSize: panelW < 700 ? 28 : 34,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.section + 4),
                      SizedBox(width: contentW, child: const _ModuleScene()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _ProductEyebrow extends StatelessWidget {
  const _ProductEyebrow();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const BitlogixMark(size: 13),
      const SizedBox(width: AppSpacing.sm),
      Text(
        context.l10n.productEyebrow,
        style: AppTypography.of(context).caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.brandPrimary,
        ),
      ),
    ],
  );
}

/// Connected module scene: foreground workspace object, midground module
/// chips and background connection paths. Purely symbolic branding.
class _ModuleScene extends StatelessWidget {
  const _ModuleScene();

  static const _sceneH = 420.0;
  static const _fragApproxH = 62.0;

  /// Intentionally asymmetric placement with varied scale so the scene reads
  /// as an editorial composition rather than a symmetric flow diagram.
  static const _specs = <_FragmentSpec>[
    _FragmentSpec(
      icon: Icons.handyman_outlined,
      labelKey: _ModuleLabel.services,
      width: 160,
      fromStart: true,
      x: 0.015,
      fromTop: true,
      y: 0.05,
    ),
    _FragmentSpec(
      icon: Icons.inventory_2_outlined,
      labelKey: _ModuleLabel.inventory,
      width: 132,
      fromStart: false,
      x: 0.20,
      fromTop: true,
      y: -0.02,
      connect: false,
    ),
    _FragmentSpec(
      icon: Icons.account_tree_outlined,
      labelKey: _ModuleLabel.operations,
      width: 154,
      fromStart: false,
      x: -0.01,
      fromTop: true,
      y: 0.40,
    ),
    _FragmentSpec(
      icon: Icons.insights_outlined,
      labelKey: _ModuleLabel.insights,
      width: 128,
      fromStart: false,
      x: 0.05,
      fromTop: false,
      y: -0.02,
      connect: false,
    ),
  ];

  /// Reduced scene for narrower desktop panels: tertiary fragments are
  /// dropped first (kept: Services / Operations / Customers).
  static const _compactSpecs = <_FragmentSpec>[
    _FragmentSpec(
      icon: Icons.handyman_outlined,
      labelKey: _ModuleLabel.services,
      width: 164,
      fromStart: true,
      x: 0.01,
      fromTop: true,
      y: 0.05,
    ),
    _FragmentSpec(
      icon: Icons.account_tree_outlined,
      labelKey: _ModuleLabel.operations,
      width: 152,
      fromStart: false,
      x: 0.01,
      fromTop: true,
      y: 0.05,
    ),
    _FragmentSpec(
      icon: Icons.inventory_2_outlined,
      labelKey: _ModuleLabel.inventory,
      width: 138,
      fromStart: true,
      x: 0.0,
      fromTop: false,
      y: 0.10,
      connect: false,
    ),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final w = constraints.maxWidth;
      const h = _sceneH;
      final rtl = Directionality.of(context) == TextDirection.rtl;
      final compact = w < 540;
      final specs = compact ? _compactSpecs : _specs;
      final centralW = (w * 0.60).clamp(250.0, 360.0);
      final targets = <Offset>[];
      final chips = <Widget>[];
      var delay = 80;
      for (final spec in specs) {
        final left = spec.fromStart
            ? (rtl ? w - spec.x * w - spec.width : spec.x * w)
            : (rtl ? spec.x * w : w - spec.x * w - spec.width);
        final top = spec.fromTop ? spec.y * h : h - spec.y * h - _fragApproxH;
        chips.add(
          Positioned(
            left: left,
            top: top,
            width: spec.width,
            child: _Reveal(
              delayMs: delay,
              child: _ModuleChip(
                icon: spec.icon,
                labelKey: spec.labelKey,
                muted: !spec.connect,
              ),
            ),
          ),
        );
        if (spec.connect) {
          targets.add(
            Offset((left + spec.width / 2) / w, (top + _fragApproxH / 2) / h),
          );
        }
        delay += 40;
      }
      return SizedBox(
        height: h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: _Reveal(
                delayMs: 120,
                child: CustomPaint(
                  painter: _ConnectionPainter(targets: targets),
                ),
              ),
            ),
            ...chips,
            Align(
              alignment: const AlignmentDirectional(-0.06, -0.03),
              child: SizedBox(
                width: centralW,
                child: const _Reveal(
                  delayMs: 0,
                  rise: true,
                  child: _WorkspaceObject(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _FragmentSpec {
  const _FragmentSpec({
    required this.icon,
    required this.labelKey,
    required this.width,
    required this.fromStart,
    required this.x,
    required this.fromTop,
    required this.y,
    this.connect = true,
  });

  final IconData icon;
  final _ModuleLabel labelKey;
  final double width;
  final bool fromStart;
  final double x;
  final bool fromTop;
  final double y;
  final bool connect;
}

enum _ModuleLabel { services, operations, inventory, insights }

class _ModuleChip extends StatelessWidget {
  const _ModuleChip({
    required this.icon,
    required this.labelKey,
    this.muted = false,
  });
  final IconData icon;
  final _ModuleLabel labelKey;

  /// Tertiary nodes: lighter surface, no elevation, softer icon.
  final bool muted;

  (String, String) _copy(BuildContext context) => switch (labelKey) {
    _ModuleLabel.services => (
      context.l10n.moduleServices,
      context.l10n.moduleServicesDesc,
    ),
    _ModuleLabel.operations => (
      context.l10n.moduleOperations,
      context.l10n.moduleOperationsDesc,
    ),
    _ModuleLabel.inventory => (
      context.l10n.moduleInventory,
      context.l10n.moduleInventoryDesc,
    ),
    _ModuleLabel.insights => (
      context.l10n.moduleInsights,
      context.l10n.moduleInsightsDesc,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = _copy(context);
    final theme = AppTypography.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: muted
            ? AppColors.surface.withValues(alpha: 0.82)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusMd + 1),
        border: Border.all(
          color: muted ? AppColors.borderSubtle : AppColors.borderDefault,
        ),
        boxShadow: muted ? null : AppElevation.subtle,
      ),
      child: Row(
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: muted
                  ? AppColors.brandSubtle.withValues(alpha: 0.7)
                  : AppColors.brandSubtle,
              borderRadius: BorderRadius.circular(AppRadius.radiusSm),
            ),
            child: Icon(
              icon,
              size: 15,
              color: muted
                  ? AppColors.brandPrimary.withValues(alpha: 0.8)
                  : AppColors.brandPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodySmall.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.caption.copyWith(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceObject extends StatelessWidget {
  const _WorkspaceObject();

  @override
  Widget build(BuildContext context) {
    final theme = AppTypography.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg + 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [AppColors.surface, AppColors.productTint],
        ),
        borderRadius: BorderRadius.circular(AppRadius.radiusLg + 2),
        border: Border.all(
          color: AppColors.brandPrimary.withValues(alpha: 0.10),
        ),
        boxShadow: AppElevation.workspace,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const BitlogixMark(size: 20),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.productWorkspaceTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodySmall.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      context.l10n.productWorkspaceSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.caption.copyWith(
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _Hairline(color: AppColors.borderSubtle),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              Expanded(
                child: _CoreModule(
                  icon: Icons.groups_2_outlined,
                  labelKey: _CoreLabel.people,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _CoreModule(
                  icon: Icons.schedule_outlined,
                  labelKey: _CoreLabel.attendance,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          const Row(
            children: [
              Expanded(
                child: _CoreModule(
                  icon: Icons.apartment_outlined,
                  labelKey: _CoreLabel.customers,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _CoreModule(
                  icon: Icons.account_balance_wallet_outlined,
                  labelKey: _CoreLabel.finance,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _Hairline(color: AppColors.borderSubtle),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const BitlogixMark(size: 13),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.productWorkspaceFooter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.caption.copyWith(
                    fontSize: 10.5,
                    letterSpacing: 0.1,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _CoreLabel { people, attendance, customers, finance }

class _CoreModule extends StatelessWidget {
  const _CoreModule({required this.icon, required this.labelKey});
  final IconData icon;
  final _CoreLabel labelKey;

  String _label(BuildContext context) => switch (labelKey) {
    _CoreLabel.people => context.l10n.modulePeople,
    _CoreLabel.attendance => context.l10n.attendance,
    _CoreLabel.customers => context.l10n.moduleCustomers,
    _CoreLabel.finance => context.l10n.moduleFinance,
  };

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.brandSubtle,
          borderRadius: BorderRadius.circular(AppRadius.radiusSm),
        ),
        child: Icon(icon, size: 14, color: AppColors.brandPrimary),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Text(
          _label(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.of(context).bodySmall.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    ],
  );
}

/// Subtle, fading relationship paths. Only some nodes connect, and each
/// stroke fades in and out so the scene reads as spatial rather than a
/// schematic network.
class _ConnectionPainter extends CustomPainter {
  const _ConnectionPainter({required this.targets});
  final List<Offset> targets;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final node = Paint()
      ..color = AppColors.brandPrimary.withValues(alpha: 0.20);
    for (final t in targets) {
      final target = Offset(t.dx * size.width, t.dy * size.height);
      final start = Offset.lerp(center, target, 0.40)!;
      final end = Offset.lerp(center, target, 0.82)!;
      final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
      final control = Offset(
        mid.dx + (target.dy - center.dy) * 0.06,
        mid.dy - (target.dx - center.dx) * 0.06,
      );
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = ui.Gradient.linear(
          start,
          end,
          [
            AppColors.brandPrimary.withValues(alpha: 0),
            AppColors.brandPrimary.withValues(alpha: 0.22),
            AppColors.brandPrimary.withValues(alpha: 0),
          ],
          const [0.0, 0.5, 1.0],
        );
      canvas.drawPath(path, stroke);
      canvas.drawCircle(end, 2.2, node);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionPainter oldDelegate) => true;
}

class _BrandBackdrop extends StatelessWidget {
  const _BrandBackdrop();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: [AppColors.productTint, AppColors.productTintAlt],
      ),
    ),
    child: Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: const _BackdropPainter()),
          ),
        ),
        Align(
          child: Opacity(
            opacity: 0.07,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: BitlogixMark(size: 300, accent: AppColors.brandPrimary),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Extremely restrained ambient structure: a faint grid and soft bloom.
class _BackdropPainter extends CustomPainter {
  const _BackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppColors.brandPrimary.withValues(alpha: 0.018)
      ..strokeWidth = 1;
    const spacing = 56.0;
    for (var x = spacing; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (var y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
    final bloom = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.accentLavender.withValues(alpha: 0.09),
              AppColors.accentLavender.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.84, size.height * 0.12),
              radius: size.shortestSide * 0.75,
            ),
          );
    canvas.drawRect(Offset.zero & size, bloom);

    final lower = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.brandPrimary.withValues(alpha: 0.04),
              AppColors.brandPrimary.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.12, size.height * 0.92),
              radius: size.shortestSide * 0.9,
            ),
          );
    canvas.drawRect(Offset.zero & size, lower);
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Mobile / tablet atmosphere: background-only brand motif (no layout height)
// ---------------------------------------------------------------------------

class _NarrowBackdrop extends StatelessWidget {
  const _NarrowBackdrop();

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const AlignmentDirectional(0.85, -0.95),
                radius: 1.0,
                colors: [
                  AppColors.accentLavender.withValues(alpha: 0.10),
                  AppColors.accentLavender.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        // Nestled Bitlogix signature, cropped against the logical end edge.
        PositionedDirectional(
          top: 30,
          end: -82,
          child: Opacity(
            opacity: 0.045,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: BitlogixMark(size: 280, accent: AppColors.brandPrimary),
            ),
          ),
        ),
        PositionedDirectional(
          top: 56,
          end: -42,
          child: Opacity(
            opacity: 0.09,
            child: BitlogixMark(size: 192, accent: AppColors.accentLavender),
          ),
        ),
        PositionedDirectional(
          top: 82,
          end: -8,
          child: Opacity(
            opacity: 0.15,
            child: BitlogixMark(size: 112, accent: AppColors.brandPrimary),
          ),
        ),
        // Small counterweight motif near the lower logical start.
        PositionedDirectional(
          bottom: -70,
          start: -62,
          child: Opacity(
            opacity: 0.05,
            child: BitlogixMark(size: 190, accent: AppColors.accentLavender),
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _Reveal extends StatelessWidget {
  const _Reveal({required this.child, this.delayMs = 0, this.rise = false});
  final Widget child;
  final int delayMs;
  final bool rise;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final delay = Duration(milliseconds: delayMs);
    final animated = child.animate().fadeIn(
      duration: AppMotion.normal,
      delay: delay,
      curve: AppMotion.curveEntrance,
    );
    return rise
        ? animated.slideY(
            begin: .02,
            end: 0,
            duration: AppMotion.normal,
            delay: delay,
            curve: AppMotion.curveEntrance,
          )
        : animated;
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(height: 1, color: color);
}
