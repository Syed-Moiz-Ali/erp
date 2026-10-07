import 'package:flutter/material.dart';

/// Centralized device text-scaling policy.
///
/// Accessibility scaling is **not** disabled: the user's system scale is
/// honored up to [maxScale]. Beyond that we clamp so extreme device settings
/// cannot destroy dense ERP layouts (tables, forms, toolbars). This is the one
/// place the cap is defined; screens must never apply local scaling hacks.
///
/// Default (1.0), moderate (~1.15) and large (>= [maxScale]) all render
/// without `RenderFlex` overflow in foundation components.
abstract final class AppTextScaling {
  /// Hard cap applied to any system text scale factor.
  static const double maxScale = 1.3;

  /// Lower bound keeps pathological values from shrinking text to nothing.
  static const double minScale = 0.8;

  /// Clamps an arbitrary [TextScaler] into the product's supported range.
  static TextScaler clamp(TextScaler scaler) =>
      scaler.clamp(minScaleFactor: minScale, maxScaleFactor: maxScale);

  /// Applies the policy to a [MediaQueryData] snapshot.
  static MediaQueryData resolve(MediaQueryData data) =>
      data.copyWith(textScaler: clamp(data.textScaler));
}

/// Applies [AppTextScaling] to everything below it. Place one high in the
/// widget tree (the application root) so every screen inherits the policy.
class AppTextScalePolicy extends StatelessWidget {
  const AppTextScalePolicy({super.key, required this.child, this.maxScale});

  final Widget child;

  /// Optional override used by the design-system preview to exercise larger
  /// scales inside the same cap.
  final double? maxScale;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: media.textScaler.clamp(
          minScaleFactor: AppTextScaling.minScale,
          maxScaleFactor: maxScale ?? AppTextScaling.maxScale,
        ),
      ),
      child: child,
    );
  }
}
