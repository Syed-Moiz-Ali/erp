import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../bloc/notification_badge_cubit.dart';

/// Bell with a bounded unread badge. Renders quietly when no cubit is wired
/// (for example before the notification repository is available).
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key, required this.onPressed, this.cubit});
  final VoidCallback onPressed;
  final NotificationBadgeCubit? cubit;
  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  StreamSubscription<int>? _subscription;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _bind();
  }

  @override
  void didUpdateWidget(covariant NotificationBell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cubit != widget.cubit) _bind();
  }

  void _bind() {
    _subscription?.cancel();
    final cubit = widget.cubit;
    if (cubit == null) {
      _count = 0;
      return;
    }
    _count = cubit.state;
    _subscription = cubit.stream.listen((value) {
      if (mounted) setState(() => _count = value);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    alignment: AlignmentDirectional.center,
    children: [
      AppIconButton(
        icon: Icons.notifications_none_outlined,
        tooltip: context.l10n.shellNotifications,
        onPressed: widget.onPressed,
      ),
      if (_count > 0)
        PositionedDirectional(
          top: 4,
          end: 4,
          child: IgnorePointer(child: AppCountBadge(count: _count)),
        ),
    ],
  );
}
