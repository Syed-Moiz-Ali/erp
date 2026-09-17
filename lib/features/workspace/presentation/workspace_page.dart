import '../../../l10n/l10n.dart';
import '../../../design_system/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import '../../../design_system/components/layout/app_page.dart';
import '../../../design_system/components/headers/app_headers.dart';
import '../../../design_system/components/cards/app_cards.dart';
import '../../../design_system/components/status/app_status_badge.dart';

class WorkspacePage extends StatelessWidget {
  const WorkspacePage({super.key});
  @override
  Widget build(BuildContext context) => AppPage(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppPageHeader(
          title: context.l10n.workspaceTitle,
          subtitle: context.l10n.workspaceSubtitle,
        ),
        SizedBox(height: AppSpacing.xxl),
        AppInfoCard(
          title: context.l10n.workspaceInfoTitle,
          message: context.l10n.workspaceInfoMessage,
        ),
        SizedBox(height: AppSpacing.xxl),
        AppStatusBadge(
          label: context.l10n.phaseReady,
          status: AppStatus.success,
        ),
      ],
    ),
  );
}
