import '../../theme/app_dimensions.dart';
import '../../../l10n/l10n.dart';
import 'package:flutter/material.dart';
import '../buttons/app_buttons.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
  });
  final String title;
  final Widget child;
  final List<Widget> actions;
  static Future<T?> show<T>(BuildContext context, WidgetBuilder builder) =>
      showDialog<T>(
        context: context,
        useRootNavigator: false,
        builder: builder,
      );
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    content: SizedBox(width: AppDimensions.dialog, child: child),
    actions: actions,
  );
}

class AppConfirmationDialog {
  static Future<bool> show(
    BuildContext context, {
    required LocalizedText title,
    required LocalizedText message,
    LocalizedText? confirmLabel,
  }) async =>
      await AppDialog.show<bool>(
        context,
        (dialogContext) => AppDialog(
          title: title(dialogContext.l10n),
          actions: [
            AppTextButton(
              label: dialogContext.l10n.cancel,
              onPressed: () => Navigator.pop(dialogContext, false),
            ),
            AppPrimaryButton(
              label:
                  confirmLabel?.call(dialogContext.l10n) ??
                  dialogContext.l10n.confirm,
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
          child: Text(message(dialogContext.l10n)),
        ),
      ) ??
      false;
}
