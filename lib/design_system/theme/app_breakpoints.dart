import 'package:flutter/widgets.dart';

enum AppSize { compact, medium, expanded, large }

abstract final class AppBreakpoints {
  static const double medium = 600, expanded = 1000, large = 1440;
  static AppSize classify(double width) => width < medium
      ? AppSize.compact
      : width < expanded
      ? AppSize.medium
      : width < large
      ? AppSize.expanded
      : AppSize.large;
  static AppSize of(BuildContext context) =>
      classify(MediaQuery.sizeOf(context).width);
}
