import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/design_system/theme/app_motion.dart';

abstract final class AppRouteTransitions {
  /// Indexed branch switches are instant; nested route entries use a short nondirectional fade.
  static Page<void> page(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) => CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.fast,
    reverseTransitionDuration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.fast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}
