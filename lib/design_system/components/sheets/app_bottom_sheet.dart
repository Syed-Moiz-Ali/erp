import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/theme/app_motion.dart';
import 'package:modular_erp/design_system/theme/app_spacing.dart';

class AppBottomSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
  }) => showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: AppMotion.normal,
            reverseDuration: AppMotion.fast,
          ),
    builder: (context) => Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(child: builder(context)),
    ),
  );
}
