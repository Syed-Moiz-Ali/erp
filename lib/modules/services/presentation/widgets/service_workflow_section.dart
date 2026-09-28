import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_workflow_actions.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_workflow_timeline.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow_action.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow_repository.dart';
import 'package:modular_erp/modules/services/workflow/presentation/service_workflow_localization.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

/// Shared workflow section for every transaction detail page (Phase 7 §13–17).
///
/// It resolves the whole chain through the workflow read model (which re-checks
/// permission/scope for every node), renders the timeline, the centrally
/// resolved next actions for [focus], and the merged workflow activity feed.
class ServiceWorkflowSection extends StatelessWidget {
  const ServiceWorkflowSection({
    super.key,
    required this.repository,
    required this.enquiryId,
    required this.focus,
    this.showActivity = true,
    this.onAction,
  });

  final ServiceWorkflowRepository repository;
  final String enquiryId;
  final ServiceWorkflowStage focus;
  final bool showActivity;
  final void Function(ServiceWorkflowAction action)? onAction;

  @override
  Widget build(BuildContext context) {
    final account = context.read<AuthBloc>().state.context;
    if (account == null) return const SizedBox.shrink();
    final l = context.l10n;
    return StreamBuilder<Result<ServiceWorkflowChain?>>(
      stream: repository.watchChain(account, enquiryId, focus: focus),
      builder: (context, snapshot) {
        final result = snapshot.data;
        if (result == null) {
          return const AppCard(child: AppConfigurationSkeleton());
        }
        if (result is Failed<ServiceWorkflowChain?>) {
          return AppFormSection(
            title: l.servicesWorkflowTitle,
            child: Text(l.servicesEnquiryStorageError),
          );
        }
        final chain = (result as Success<ServiceWorkflowChain?>).value;
        if (chain == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppFormSection(
              title: l.servicesWorkflowTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      AppStatusBadge(
                        label: serviceWorkflowStatusLabel(chain.status, l),
                        status: serviceWorkflowStatusAppStatus(chain.status),
                        isPill: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ServiceWorkflowTimeline(
                    chain: chain,
                    onOpenStage: (stage, id) => _openStage(context, stage, id),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ServiceWorkflowActions(
                    chain: chain,
                    stage: focus,
                    onAction: onAction,
                  ),
                ],
              ),
            ),
            if (showActivity) ...[
              const SizedBox(height: AppSpacing.xxl),
              _WorkflowActivityFeed(
                repository: repository,
                enquiryId: enquiryId,
              ),
            ],
          ],
        );
      },
    );
  }

  void _openStage(BuildContext context, ServiceWorkflowStage stage, String id) {
    final route = switch (stage) {
      ServiceWorkflowStage.enquiry => ServicesRoutes.enquiry(id),
      ServiceWorkflowStage.jobAssignment => ServicesRoutes.assignment(id),
      ServiceWorkflowStage.inspection => ServicesRoutes.inspection(id),
      ServiceWorkflowStage.materialRequest => ServicesRoutes.materialRequest(
        id,
      ),
      ServiceWorkflowStage.workExecution => ServicesRoutes.workExecution(id),
    };
    context.go(route);
  }
}

class _WorkflowActivityFeed extends StatelessWidget {
  const _WorkflowActivityFeed({
    required this.repository,
    required this.enquiryId,
  });

  final ServiceWorkflowRepository repository;
  final String enquiryId;

  @override
  Widget build(BuildContext context) {
    final account = context.read<AuthBloc>().state.context;
    if (account == null) return const SizedBox.shrink();
    final l = context.l10n;
    final dates = AppDateFormatter(Localizations.localeOf(context));
    return StreamBuilder<Result<List<ServiceWorkflowActivityEntry>>>(
      stream: repository.watchActivity(account, enquiryId),
      builder: (context, snapshot) {
        final entries = switch (snapshot.data) {
          Success<List<ServiceWorkflowActivityEntry>>(:final value) => value,
          _ => const <ServiceWorkflowActivityEntry>[],
        };
        return AppSettingsSection(
          title: l.servicesWorkflowActivityTitle,
          children: [
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(l.servicesWorkflowNoActivity),
              )
            else
              for (final entry in entries.take(30))
                AppActivityItem(
                  icon: serviceWorkflowStageIcon(
                    entry.stage ?? ServiceWorkflowStage.enquiry,
                  ),
                  title: serviceActivityEventLabel(entry.eventType, l),
                  description: [
                    serviceActivityEntityTypeLabel(entry.entityType, l),
                    if (entry.reference != null) entry.reference!,
                  ].join(' · '),
                  timestamp: dates.date(entry.occurredAt),
                ),
          ],
        );
      },
    );
  }
}
