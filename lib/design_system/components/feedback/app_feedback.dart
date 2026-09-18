import '../../../l10n/l10n.dart';
import 'package:flutter/material.dart';
import '../../design_system.dart';

abstract final class AppFeedback {
  static void showMessage(
    BuildContext context, {
    required LocalizedText message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Builder(builder: (context) => Text(message(context.l10n))),
      ),
    );
  }
}

class AppAlert extends StatelessWidget {
  const AppAlert({
    super.key,
    required this.message,
    this.status = AppStatus.info,
  });
  final String message;
  final AppStatus status;
  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.all(16),
    child: Row(
      children: [
        Icon(Icons.info_outline, color: status.color, size: 20),
        SizedBox(width: 12),
        Expanded(child: Text(message)),
      ],
    ),
  );
}

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({super.key, this.label});
  final String? label;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Flexible(child: Text(label ?? context.l10n.loadingRecords)),
        ],
      ),
    ),
  );
}

class AppNotice extends StatelessWidget {
  const AppNotice({
    super.key,
    required this.title,
    this.message,
    this.action,
    this.status = AppStatus.info,
    this.icon = Icons.info_outline,
  });
  final String title;
  final String? message;
  final Widget? action;
  final AppStatus status;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: status.color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.of(context).label),
                if (message != null)
                  Text(message!, style: AppTypography.of(context).bodySmall),
                if (action != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
