import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150),
      normal = Duration(milliseconds: 220),
      slow = Duration(milliseconds: 300);
  static Widget entrance(BuildContext context, Widget child) =>
      MediaQuery.disableAnimationsOf(context)
      ? child
      : child
            .animate()
            .fadeIn(duration: normal)
            .slideY(begin: .015, end: 0, duration: normal);
}
