import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import 'bloc/notifications_bloc.dart';
import 'notification_presentation.dart';
import 'widgets/notification_tile.dart';

/// Compact panel used by the shell bell. The full center lives at
/// [AppRoutes.notifications]; both share the same bloc.
class NotificationPanel {
  static Future<void> show(BuildContext context) => AppDialog.show<void>(
    context,
    (dialogContext) => AppDialog(
      title: dialogContext.l10n.notificationsTitle,
      actions: [
        AppTextButton(
          label: dialogContext.l10n.close,
          onPressed: () => Navigator.pop(dialogContext),
        ),
      ],
      child: Builder(
        builder: (panelContext) {
          final l = panelContext.l10n;
          final bloc = _maybeRead(panelContext);
          if (bloc == null) {
            return AppEmptyState(
              title: l.notificationsNoItems,
              message: l.notificationsNoItemsMessage,
              icon: Icons.notifications_none_outlined,
            );
          }
          return BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state.items.isEmpty) {
                return AppEmptyState(
                  title: l.notificationsNoItems,
                  message: l.notificationsNoItemsMessage,
                  icon: Icons.notifications_none_outlined,
                );
              }
              return SizedBox(
                width: AppDimensions.dialog,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 420),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final item in state.items.take(10))
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: NotificationTile(
                            notification: item,
                            onTap: () {
                              bloc.add(NotificationReadRequested(item.id));
                              Navigator.pop(dialogContext);
                              final route = notificationRoute(item);
                              if (route != null) context.go(route);
                            },
                          ),
                        ),
                      if (state.items.length > 10)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: AppTextButton(
                            label: l.notificationsOpen,
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              context.go(AppRoutes.notifications);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
  );

  static NotificationsBloc? _maybeRead(BuildContext context) {
    try {
      return context.read<NotificationsBloc>();
    } catch (_) {
      return null;
    }
  }
}
