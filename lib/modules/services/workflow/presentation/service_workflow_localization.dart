import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow_action.dart';

/// Localization/status mapping for the Services workflow read model.
///
/// Presentation only: no English sentences are stored anywhere.

String serviceWorkflowStageLabel(
  ServiceWorkflowStage stage,
  AppLocalizations l,
) => switch (stage) {
  ServiceWorkflowStage.enquiry => l.servicesWorkflowStageEnquiry,
  ServiceWorkflowStage.jobAssignment => l.servicesWorkflowStageJobAssignment,
  ServiceWorkflowStage.inspection => l.servicesWorkflowStageInspection,
  ServiceWorkflowStage.materialRequest =>
    l.servicesWorkflowStageMaterialRequest,
  ServiceWorkflowStage.workExecution => l.servicesWorkflowStageWorkExecution,
};

String serviceWorkflowStatusLabel(
  ServiceWorkflowStatus status,
  AppLocalizations l,
) => switch (status) {
  ServiceWorkflowStatus.awaitingAssignment =>
    l.servicesWorkflowStatusAwaitingAssignment,
  ServiceWorkflowStatus.scheduled => l.servicesWorkflowStatusScheduled,
  ServiceWorkflowStatus.inspectionPending =>
    l.servicesWorkflowStatusInspectionPending,
  ServiceWorkflowStatus.inspectionCompleted =>
    l.servicesWorkflowStatusInspectionCompleted,
  ServiceWorkflowStatus.materialsRequested =>
    l.servicesWorkflowStatusMaterialsRequested,
  ServiceWorkflowStatus.workInProgress =>
    l.servicesWorkflowStatusWorkInProgress,
  ServiceWorkflowStatus.workCompleted => l.servicesWorkflowStatusWorkCompleted,
  ServiceWorkflowStatus.cancelled => l.servicesWorkflowStatusCancelled,
  ServiceWorkflowStatus.unknown => l.servicesWorkflowStatusUnknown,
};

AppStatus serviceWorkflowStatusAppStatus(ServiceWorkflowStatus status) =>
    switch (status) {
      ServiceWorkflowStatus.awaitingAssignment => AppStatus.warning,
      ServiceWorkflowStatus.scheduled => AppStatus.info,
      ServiceWorkflowStatus.inspectionPending => AppStatus.info,
      ServiceWorkflowStatus.inspectionCompleted => AppStatus.brand,
      ServiceWorkflowStatus.materialsRequested => AppStatus.warning,
      ServiceWorkflowStatus.workInProgress => AppStatus.brand,
      ServiceWorkflowStatus.workCompleted => AppStatus.success,
      ServiceWorkflowStatus.cancelled => AppStatus.neutral,
      ServiceWorkflowStatus.unknown => AppStatus.neutral,
    };

String serviceWorkflowActionLabel(
  ServiceWorkflowAction action,
  AppLocalizations l,
) => switch (action.type) {
  ServiceWorkflowActionType.create => switch (action.targetStage) {
    ServiceWorkflowStage.jobAssignment =>
      l.servicesWorkflowActionCreateAssignment,
    ServiceWorkflowStage.inspection => l.servicesWorkflowActionCreateInspection,
    ServiceWorkflowStage.materialRequest =>
      l.servicesWorkflowActionCreateMaterialRequest,
    ServiceWorkflowStage.workExecution =>
      l.servicesWorkflowActionCreateWorkExecution,
    ServiceWorkflowStage.enquiry => l.servicesWorkflowActionCreateAssignment,
  },
  ServiceWorkflowActionType.view => switch (action.targetStage) {
    ServiceWorkflowStage.enquiry => l.servicesWorkflowStageEnquiry,
    ServiceWorkflowStage.jobAssignment =>
      l.servicesWorkflowActionViewAssignment,
    ServiceWorkflowStage.inspection => l.servicesWorkflowActionViewInspection,
    ServiceWorkflowStage.materialRequest =>
      l.servicesWorkflowActionViewMaterialRequest,
    ServiceWorkflowStage.workExecution =>
      l.servicesWorkflowActionViewWorkExecution,
  },
  ServiceWorkflowActionType.edit => l.servicesWorkflowActionEdit,
  ServiceWorkflowActionType.complete => l.servicesWorkflowActionComplete,
  ServiceWorkflowActionType.cancel => l.servicesWorkflowActionCancel,
  ServiceWorkflowActionType.print => l.servicesWorkflowActionPrint,
  ServiceWorkflowActionType.perform => l.servicesWorkflowActionPerform,
};

IconData serviceWorkflowActionIcon(ServiceWorkflowAction action) =>
    switch (action.type) {
      ServiceWorkflowActionType.create => Icons.add,
      ServiceWorkflowActionType.view => Icons.arrow_forward,
      ServiceWorkflowActionType.edit => Icons.edit_outlined,
      ServiceWorkflowActionType.complete => Icons.task_alt_outlined,
      ServiceWorkflowActionType.cancel => Icons.cancel_outlined,
      ServiceWorkflowActionType.print => Icons.print_outlined,
      ServiceWorkflowActionType.perform => Icons.play_circle_outline,
    };

IconData serviceWorkflowStageIcon(ServiceWorkflowStage stage) =>
    switch (stage) {
      ServiceWorkflowStage.enquiry => Icons.support_agent_outlined,
      ServiceWorkflowStage.jobAssignment => Icons.assignment_ind_outlined,
      ServiceWorkflowStage.inspection => Icons.fact_check_outlined,
      ServiceWorkflowStage.materialRequest => Icons.request_quote_outlined,
      ServiceWorkflowStage.workExecution => Icons.engineering_outlined,
    };
