import 'package:flutter/material.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/design_system/components/buttons/app_buttons.dart';
import 'package:modular_erp/design_system/components/status/app_count_badge.dart';

/// Presentational notification control for the shell top bar.
///
/// Icon + localized tooltip + optional real unread badge. It never invents a
/// count: callers pass the actual unread value. The count is bounded by
/// [AppCountBadge] so a large backlog never becomes a giant badge.
class AppNotificationButton extends StatelessWidget {
  const AppNotificationButton({
    super.key,
    required this.onPressed,
    this.unreadCount = 0,
  });
  final VoidCallback? onPressed;
  final int unreadCount;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: AlignmentDirectional.center,
    children: [
      AppIconButton(
        icon: Icons.notifications_none_outlined,
        tooltip: context.l10n.shellNotifications,
        onPressed: onPressed,
      ),
      if (unreadCount > 0)
        PositionedDirectional(
          top: 4,
          end: 4,
          child: IgnorePointer(child: AppCountBadge(count: unreadCount)),
        ),
    ],
  );
}
