import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../domain/app_notification.dart';
import 'bloc/notifications_bloc.dart';
import 'notification_presentation.dart';
import 'widgets/notification_tile.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          final l = context.l10n;
          final bloc = context.read<NotificationsBloc>();
          final today = <AppNotification>[];
          final earlier = <AppNotification>[];
          final now = DateTime.now();
          for (final item in state.items) {
            final local = item.createdAt.toLocal();
            (local.year == now.year &&
                        local.month == now.month &&
                        local.day == now.day
                    ? today
                    : earlier)
                .add(item);
          }
          return AppPage(
            header: AppPageHeader(
              title: l.notificationsTitle,
              actions: [
                if (state.unread > 0)
                  AppTextButton(
                    label: l.notificationsMarkAllRead,
                    onPressed: () =>
                        bloc.add(const NotificationsMarkAllReadRequested()),
                  ),
              ],
            ),
            child: state.loading
                ? const AppSkeleton(height: 200)
                : state.items.isEmpty
                ? AppEmptyState(
                    title: l.notificationsNoItems,
                    message: l.notificationsNoItemsMessage,
                    icon: Icons.notifications_none_outlined,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (today.isNotEmpty) ...[
                        AppSectionHeader(title: l.notificationsToday),
                        const SizedBox(height: AppSpacing.sm),
                        _section(context, bloc, today),
                      ],
                      if (earlier.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        AppSectionHeader(title: l.notificationsEarlier),
                        const SizedBox(height: AppSpacing.sm),
                        _section(context, bloc, earlier),
                      ],
                    ],
                  ),
          );
        },
      );

  Widget _section(
    BuildContext context,
    NotificationsBloc bloc,
    List<AppNotification> items,
  ) => Column(
    children: [
      for (final item in items)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: NotificationTile(
            notification: item,
            onTap: () {
              bloc.add(NotificationReadRequested(item.id));
              final route = notificationRoute(item);
              if (route != null) context.go(route);
            },
          ),
        ),
    ],
  );
}
