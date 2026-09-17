import '../../../l10n/l10n.dart';
import 'package:flutter/material.dart';
import '../cards/app_cards.dart';
import '../status/app_status_badge.dart';

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
