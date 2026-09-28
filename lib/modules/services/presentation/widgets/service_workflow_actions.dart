import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow_action.dart';
import 'package:modular_erp/modules/services/workflow/presentation/service_workflow_localization.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

/// Renders the centrally-resolved next actions for one workflow stage.
///
/// Widgets never decide availability: they only translate a resolved
/// [ServiceWorkflowAction] into a route or a caller-supplied handler. Navigation
/// actions are always live; operational actions render only when the caller
/// supplies a handler, so no dead buttons are produced (Phase 7 §32).
class ServiceWorkflowActions extends StatelessWidget {
  const ServiceWorkflowActions({
    super.key,
    required this.chain,
    required this.stage,
    this.onAction,
  });

  final ServiceWorkflowChain chain;
  final ServiceWorkflowStage stage;

  /// Handles non-navigation actions (perform/complete/cancel/edit). When null,
  /// those actions are not rendered.
  final void Function(ServiceWorkflowAction action)? onAction;

  @override
  Widget build(BuildContext context) {
    final account = context.read<AuthBloc>().state.context;
    if (account == null) return const SizedBox.shrink();
    final actions = const ServiceWorkflowActionResolver().resolveForStage(
      account,
      chain,
      stage,
    );
    final widgets = <Widget>[];
    for (final action in actions) {
      final route = _routeFor(action);
      if (route == null && onAction == null) continue;
      widgets.add(
        AppSecondaryButton(
          label: serviceWorkflowActionLabel(action, context.l10n),
          icon: serviceWorkflowActionIcon(action),
          onPressed: route != null
              ? () => context.go(route)
              : () => onAction!(action),
        ),
      );
    }
    if (widgets.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: widgets,
    );
  }

  String? _routeFor(ServiceWorkflowAction action) {
    switch (action.type) {
      case ServiceWorkflowActionType.create:
        final source = action.sourceId;
        if (source == null) return null;
        return switch (action.targetStage) {
          ServiceWorkflowStage.jobAssignment =>
            '${ServicesRoutes.assignmentsNew}?enquiryId=${Uri.encodeQueryComponent(source)}',
          ServiceWorkflowStage.inspection =>
            '${ServicesRoutes.inspectionsNew}?assignmentId=${Uri.encodeQueryComponent(source)}',
          ServiceWorkflowStage.materialRequest =>
            '${ServicesRoutes.materialRequestsNew}?inspectionId=${Uri.encodeQueryComponent(source)}',
          ServiceWorkflowStage.workExecution =>
            '${ServicesRoutes.workExecutionsNew}?inspectionId=${Uri.encodeQueryComponent(source)}',
          ServiceWorkflowStage.enquiry => null,
        };
      case ServiceWorkflowActionType.view:
        final id = action.targetId;
        if (id == null) return null;
        return switch (action.targetStage) {
          ServiceWorkflowStage.jobAssignment => ServicesRoutes.assignment(id),
          ServiceWorkflowStage.inspection => ServicesRoutes.inspection(id),
          ServiceWorkflowStage.materialRequest =>
            ServicesRoutes.materialRequest(id),
          ServiceWorkflowStage.workExecution => ServicesRoutes.workExecution(
            id,
          ),
          ServiceWorkflowStage.enquiry => ServicesRoutes.enquiry(id),
        };
      case ServiceWorkflowActionType.edit:
        final id = action.targetId;
        if (id == null) return null;
        return switch (action.targetStage) {
          ServiceWorkflowStage.inspection => ServicesRoutes.inspectionEdit(id),
          ServiceWorkflowStage.materialRequest =>
            ServicesRoutes.materialRequestEdit(id),
          ServiceWorkflowStage.workExecution =>
            ServicesRoutes.workExecutionEdit(id),
          _ => null,
        };
      case ServiceWorkflowActionType.print:
        final id = action.targetId;
        return id == null ? null : ServicesRoutes.materialRequestPrint(id);
      case ServiceWorkflowActionType.complete:
      case ServiceWorkflowActionType.cancel:
      case ServiceWorkflowActionType.perform:
        return null;
    }
  }
}
