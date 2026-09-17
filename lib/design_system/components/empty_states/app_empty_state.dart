import '../../../l10n/l10n.dart';
import 'package:flutter/material.dart';
import '../../theme/app_typography.dart';
import '../buttons/app_buttons.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });
  final String title, message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(32),
    child: Column(
      children: [
        Icon(icon, size: 32),
        SizedBox(height: 16),
        Text(
          title,
          style: AppTypography.of(context).cardTitle,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          message,
          style: AppTypography.of(context).caption,
          textAlign: TextAlign.center,
        ),
        if (actionLabel != null) ...[
          SizedBox(height: 16),
          AppSecondaryButton(label: actionLabel!, onPressed: onAction),
        ],
      ],
    ),
  );
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => AppEmptyState(
    title: context.l10n.unableToLoadRecords,
    message: message,
    icon: Icons.error_outline,
    actionLabel: onRetry == null ? null : context.l10n.retry,
    onAction: onRetry,
  );
}
