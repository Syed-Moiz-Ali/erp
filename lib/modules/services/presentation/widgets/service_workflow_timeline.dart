import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';
import 'package:modular_erp/modules/services/workflow/presentation/service_workflow_localization.dart';

/// Shared, modern Services workflow timeline (Phase 7 §13–16).
///
/// It renders **real records only**. A node that is not visible to the signed-in
/// user (absent or restricted) shows no reference number, so restricted
/// transactions cannot leak through the timeline. The optional Material Request
/// node is shown as "not required / none created" rather than a broken step.
class ServiceWorkflowTimeline extends StatelessWidget {
  const ServiceWorkflowTimeline({
    super.key,
    required this.chain,
    this.onOpenStage,
  });

  final ServiceWorkflowChain chain;

  /// Invoked when the user taps a visible node; re-checks nothing itself because
  /// the node is only tappable when a visible record exists.
  final void Function(ServiceWorkflowStage stage, String recordId)? onOpenStage;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < chain.nodes.length; i++)
            _WorkflowNodeRow(
              node: chain.nodes[i],
              isFirst: i == 0,
              isLast: i == chain.nodes.length - 1,
              onTap: chain.nodes[i].hasRecord && onOpenStage != null
                  ? () => onOpenStage!(chain.nodes[i].stage, chain.nodes[i].id!)
                  : null,
              optionalLabel: l.servicesWorkflowOptional,
              notCreatedLabel: l.servicesWorkflowNotCreated,
              waitingLabel: l.servicesWorkflowMaterialWaiting(
                '${chain.nodes[i].waitingMaterialCount}',
              ),
            ),
        ],
      ),
    );
  }
}

class _WorkflowNodeRow extends StatelessWidget {
  const _WorkflowNodeRow({
    required this.node,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    required this.optionalLabel,
    required this.notCreatedLabel,
    required this.waitingLabel,
  });

  final ServiceWorkflowNode node;
  final bool isFirst, isLast;
  final VoidCallback? onTap;
  final String optionalLabel, notCreatedLabel, waitingLabel;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final typography = AppTypography.of(context);
    final stageLabel = serviceWorkflowStageLabel(node.stage, l);
    final subtitle = node.hasRecord
        ? node.reference ?? ''
        : (node.stage.isOptional
              ? notCreatedLabel
              : l.servicesWorkflowNotAvailable);
    final showWaiting =
        node.stage == ServiceWorkflowStage.inspection &&
        node.waitingMaterialCount > 0;
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NodeMarker(
          present: node.hasRecord,
          cancelled: node.cancelled,
          optional: node.stage.isOptional,
          isFirst: isFirst,
          isLast: isLast,
          icon: serviceWorkflowStageIcon(node.stage),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(stageLabel, style: typography.label)),
                    if (node.stage.isOptional)
                      AppStatusBadge(
                        label: optionalLabel,
                        status: AppStatus.neutral,
                        isPill: true,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: node.hasRecord ? typography.body : typography.caption,
                ),
                if (showWaiting) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(waitingLabel, style: typography.caption),
                ],
              ],
            ),
          ),
        ),
        if (onTap != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
    final tappable = onTap == null
        ? content
        : InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.radiusMd),
            child: content,
          );
    return Semantics(
      button: onTap != null,
      label: node.hasRecord
          ? '$stageLabel ${node.reference ?? ''}'
          : stageLabel,
      child: tappable,
    );
  }
}

class _NodeMarker extends StatelessWidget {
  const _NodeMarker({
    required this.present,
    required this.cancelled,
    required this.optional,
    required this.isFirst,
    required this.isLast,
    required this.icon,
  });

  final bool present, cancelled, optional, isFirst, isLast;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color color;
    if (!present) {
      color = scheme.outlineVariant;
    } else if (cancelled) {
      color = scheme.outline;
    } else {
      color = scheme.primary;
    }
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: present ? color.withValues(alpha: 0.12) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: present ? 0 : 1),
          ),
          child: Icon(
            present ? (cancelled ? Icons.cancel_outlined : icon) : icon,
            size: 20,
            color: color,
          ),
        ),
        if (!isLast)
          Container(width: 2, height: 24, color: scheme.outlineVariant),
      ],
    );
  }
}
