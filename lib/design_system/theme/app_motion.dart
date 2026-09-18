import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150),
      normal = Duration(milliseconds: 220),
      slow = Duration(milliseconds: 300);

  // Standard enterprise easing curves
  static const curveEntrance = Curves.easeOutCubic;
  static const curveExit = Curves.easeInCubic;
  static const curveStandard = Curves.easeInOutCubic;

  static Widget entrance(BuildContext context, Widget child) =>
      MediaQuery.disableAnimationsOf(context)
      ? child
      : child
            .animate()
            .fadeIn(duration: normal, curve: curveEntrance)
            .slideY(
              begin: .015,
              end: 0,
              duration: normal,
              curve: curveEntrance,
            );

  static Widget fadeIn(
    BuildContext context,
    Widget child, {
    Duration? duration,
  }) => MediaQuery.disableAnimationsOf(context)
      ? child
      : child.animate().fadeIn(
          duration: duration ?? normal,
          curve: curveEntrance,
        );

  static Widget scaleIn(
    BuildContext context,
    Widget child, {
    Duration? duration,
  }) => MediaQuery.disableAnimationsOf(context)
      ? child
      : child
            .animate()
            .fadeIn(duration: duration ?? fast, curve: curveEntrance)
            .scaleXY(
              begin: .97,
              end: 1.0,
              duration: duration ?? fast,
              curve: curveEntrance,
            );
}
