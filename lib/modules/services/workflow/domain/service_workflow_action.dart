import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// The kind of workflow-level action available to the signed-in user.
///
/// Presentation maps a kind to a route/button; it never decides availability.
enum ServiceWorkflowActionType {
  create,
  view,
  edit,
  complete,
  cancel,
  print,
  perform,
}

/// A single centrally-resolved next action (Phase 7 §18).
///
/// [pageStage] is the detail screen the action is offered on; [targetStage] is
/// the transaction it opens/creates. Widgets render exactly what the resolver
/// returns so workflow-state rules never leak into UI code.
class ServiceWorkflowAction {
  const ServiceWorkflowAction({
    required this.pageStage,
    required this.targetStage,
    required this.type,
    this.targetId,
    this.sourceId,
    this.permission,
  });

  final ServiceWorkflowStage pageStage;
  final ServiceWorkflowStage targetStage;
  final ServiceWorkflowActionType type;

  /// The existing record id (for view/edit/complete/cancel/print/perform).
  final String? targetId;

  /// The source id used when creating the next transaction.
  final String? sourceId;

  /// The permission that authorized this action (for auditing/testing).
  final AppPermission? permission;
}

/// Centralized, typed next-action resolution for the Services workflow.
///
/// The rules below encode the current established behaviour only. In particular
/// the conditional path is preserved: Material Request is **never** required
/// before Work Execution. When an Inspection has waiting material requirements
/// both *Create Material Request* and *Create Work Execution* are offered, and
/// the client must decide (the ordering is a documented open question, §22).
class ServiceWorkflowActionResolver {
  const ServiceWorkflowActionResolver();

  bool _enabled(AuthContext context) =>
      context.user.status == AccountStatus.active &&
      context.user.companyId == context.company.id &&
      context.company.enabledModules.contains('services');

  bool _can(AuthContext context, AppPermission permission) =>
      context.user.permissions.contains(permission);

  bool _canAny(AuthContext context, Iterable<AppPermission> permissions) =>
      permissions.any((p) => _can(context, p));

  /// All next actions currently available for the whole chain.
  List<ServiceWorkflowAction> resolve(
    AuthContext context,
    ServiceWorkflowChain chain,
  ) {
    if (!_enabled(context)) return const [];
    return [
      ..._enquiryActions(context, chain),
      ..._assignmentActions(context, chain),
      ..._inspectionActions(context, chain),
      ..._materialRequestActions(context, chain),
      ..._workExecutionActions(context, chain),
    ];
  }

  /// The actions offered on one detail page (matched by [pageStage]).
  List<ServiceWorkflowAction> resolveForStage(
    AuthContext context,
    ServiceWorkflowChain chain,
    ServiceWorkflowStage stage,
  ) => [
    for (final action in resolve(context, chain))
      if (action.pageStage == stage) action,
  ];

  List<ServiceWorkflowAction> _enquiryActions(
    AuthContext context,
    ServiceWorkflowChain chain,
  ) {
    final enquiry = chain.nodeFor(ServiceWorkflowStage.enquiry);
    final assignment = chain.nodeFor(ServiceWorkflowStage.jobAssignment);
    final actions = <ServiceWorkflowAction>[];
    final hasActiveAssignment =
        assignment.hasRecord && !assignment.cancelled && assignment.id != null;
    if (!hasActiveAssignment &&
        !enquiry.cancelled &&
        _can(context, AppPermission.serviceJobAssignmentCreate)) {
      actions.add(
        ServiceWorkflowAction(
          pageStage: ServiceWorkflowStage.enquiry,
          targetStage: ServiceWorkflowStage.jobAssignment,
          type: ServiceWorkflowActionType.create,
          sourceId: chain.enquiryId,
          permission: AppPermission.serviceJobAssignmentCreate,
        ),
      );
    }
    if (assignment.hasRecord &&
        _canAny(context, {
          AppPermission.serviceJobAssignmentViewAssigned,
          AppPermission.serviceJobAssignmentViewTeam,
          AppPermission.serviceJobAssignmentViewAll,
        })) {
      actions.add(
        ServiceWorkflowAction(
          pageStage: ServiceWorkflowStage.enquiry,
          targetStage: ServiceWorkflowStage.jobAssignment,
          type: ServiceWorkflowActionType.view,
          targetId: assignment.id,
        ),
      );
    }
    return actions;
  }

  List<ServiceWorkflowAction> _assignmentActions(
    AuthContext context,
    ServiceWorkflowChain chain,
  ) {
    final assignment = chain.nodeFor(ServiceWorkflowStage.jobAssignment);
    final inspection = chain.nodeFor(ServiceWorkflowStage.inspection);
    final actions = <ServiceWorkflowAction>[];
    if (!assignment.hasRecord || assignment.cancelled) return actions;
    final hasInspection = inspection.hasRecord && !inspection.cancelled;
    if (!hasInspection &&
        _can(context, AppPermission.serviceInspectionCreate)) {
      actions.add(
        ServiceWorkflowAction(
          pageStage: ServiceWorkflowStage.jobAssignment,
          targetStage: ServiceWorkflowStage.inspection,
          type: ServiceWorkflowActionType.create,
          sourceId: assignment.id,
          permission: AppPermission.serviceInspectionCreate,
        ),
      );
    }
    if (inspection.hasRecord &&
        _canAny(context, {
          AppPermission.serviceInspectionViewAssigned,
          AppPermission.serviceInspectionViewTeam,
          AppPermission.serviceInspectionViewAll,
        })) {
      actions.add(
        ServiceWorkflowAction(
          pageStage: ServiceWorkflowStage.jobAssignment,
          targetStage: ServiceWorkflowStage.inspection,
          type: ServiceWorkflowActionType.view,
          targetId: inspection.id,
        ),
      );
    }
    return actions;
  }

  List<ServiceWorkflowAction> _inspectionActions(
    AuthContext context,
    ServiceWorkflowChain chain,
  ) {
    final inspection = chain.nodeFor(ServiceWorkflowStage.inspection);
    final materialRequest = chain.nodeFor(ServiceWorkflowStage.materialRequest);
    final workExecution = chain.nodeFor(ServiceWorkflowStage.workExecution);
    final actions = <ServiceWorkflowAction>[];
    if (!inspection.hasRecord) return actions;
    final inspectionStatus = inspection.statusKey;
    if (inspectionStatus == 'pending') {
      if (_can(context, AppPermission.serviceInspectionEdit)) {
        actions.add(
          ServiceWorkflowAction(
            pageStage: ServiceWorkflowStage.inspection,
            targetStage: ServiceWorkflowStage.inspection,
            type: ServiceWorkflowActionType.edit,
            targetId: inspection.id,
            permission: AppPermission.serviceInspectionEdit,
          ),
        );
      }
      if (_can(context, AppPermission.serviceInspectionComplete)) {
        actions.add(
          ServiceWorkflowAction(
            pageStage: ServiceWorkflowStage.inspection,
            targetStage: ServiceWorkflowStage.inspection,
            type: ServiceWorkflowActionType.complete,
            targetId: inspection.id,
            permission: AppPermission.serviceInspectionComplete,
          ),
        );
      }
      if (_can(context, AppPermission.serviceInspectionCancel)) {
        actions.add(
          ServiceWorkflowAction(
            pageStage: ServiceWorkflowStage.inspection,
            targetStage: ServiceWorkflowStage.inspection,
            type: ServiceWorkflowActionType.cancel,
            targetId: inspection.id,
            permission: AppPermission.serviceInspectionCancel,
          ),
        );
      }
    }
    if (inspectionStatus == 'completed') {
      final hasActiveMaterialRequest =
          materialRequest.hasRecord && !materialRequest.cancelled;
      // Only offer a new Material Request while requirements are unresolved.
      if (inspection.waitingMaterialCount > 0 &&
          !hasActiveMaterialRequest &&
          _can(context, AppPermission.serviceMaterialRequestCreate)) {
        actions.add(
          ServiceWorkflowAction(
            pageStage: ServiceWorkflowStage.inspection,
            targetStage: ServiceWorkflowStage.materialRequest,
            type: ServiceWorkflowActionType.create,
            sourceId: inspection.id,
            permission: AppPermission.serviceMaterialRequestCreate,
          ),
        );
      }
      if (materialRequest.hasRecord &&
          _canAny(context, {
            AppPermission.serviceMaterialRequestViewAssigned,
            AppPermission.serviceMaterialRequestViewTeam,
            AppPermission.serviceMaterialRequestViewAll,
          })) {
        actions.add(
          ServiceWorkflowAction(
            pageStage: ServiceWorkflowStage.inspection,
            targetStage: ServiceWorkflowStage.materialRequest,
            type: ServiceWorkflowActionType.view,
            targetId: materialRequest.id,
          ),
        );
      }
      final hasActiveWorkExecution =
          workExecution.hasRecord && !workExecution.cancelled;
      // Work Execution is offered whether or not materials are required (§22).
      if (!hasActiveWorkExecution &&
          _can(context, AppPermission.serviceWorkExecutionCreate)) {
        actions.add(
          ServiceWorkflowAction(
            pageStage: ServiceWorkflowStage.inspection,
            targetStage: ServiceWorkflowStage.workExecution,
            type: ServiceWorkflowActionType.create,
            sourceId: inspection.id,
            permission: AppPermission.serviceWorkExecutionCreate,
          ),
        );
      }
      if (workExecution.hasRecord &&
          _canAny(context, {
            AppPermission.serviceWorkExecutionViewAssigned,
            AppPermission.serviceWorkExecutionViewTeam,
            AppPermission.serviceWorkExecutionViewAll,
          })) {
        actions.add(
          ServiceWorkflowAction(
            pageStage: ServiceWorkflowStage.inspection,
            targetStage: ServiceWorkflowStage.workExecution,
            type: ServiceWorkflowActionType.view,
            targetId: workExecution.id,
          ),
        );
      }
    }
    return actions;
  }

  List<ServiceWorkflowAction> _materialRequestActions(
    AuthContext context,
    ServiceWorkflowChain chain,
  ) {
    final materialRequest = chain.nodeFor(ServiceWorkflowStage.materialRequest);
    final actions = <ServiceWorkflowAction>[];
    if (!materialRequest.hasRecord || materialRequest.cancelled) return actions;
    if (_can(context, AppPermission.serviceMaterialRequestEdit)) {
      actions.add(
        ServiceWorkflowAction(
          pageStage: ServiceWorkflowStage.materialRequest,
          targetStage: ServiceWorkflowStage.materialRequest,
          type: ServiceWorkflowActionType.edit,
          targetId: materialRequest.id,
          permission: AppPermission.serviceMaterialRequestEdit,
        ),
      );
    }
    if (_can(context, AppPermission.serviceMaterialRequestPrint)) {
      actions.add(
        ServiceWorkflowAction(
          pageStage: ServiceWorkflowStage.materialRequest,
          targetStage: ServiceWorkflowStage.materialRequest,
          type: ServiceWorkflowActionType.print,
          targetId: materialRequest.id,
          permission: AppPermission.serviceMaterialRequestPrint,
        ),
      );
    }
    if (_can(context, AppPermission.serviceMaterialRequestCancel)) {
      actions.add(
        ServiceWorkflowAction(
          pageStage: ServiceWorkflowStage.materialRequest,
          targetStage: ServiceWorkflowStage.materialRequest,
          type: ServiceWorkflowActionType.cancel,
          targetId: materialRequest.id,
          permission: AppPermission.serviceMaterialRequestCancel,
        ),
      );
    }
    return actions;
  }

  List<ServiceWorkflowAction> _workExecutionActions(
    AuthContext context,
    ServiceWorkflowChain chain,
  ) {
    final workExecution = chain.nodeFor(ServiceWorkflowStage.workExecution);
    final actions = <ServiceWorkflowAction>[];
    if (!workExecution.hasRecord || workExecution.cancelled) return actions;
    final statusKey = workExecution.statusKey;
    final open = statusKey == 'pending' || statusKey == 'inProgress';
    if (open && _can(context, AppPermission.serviceWorkExecutionEdit)) {
      actions.add(
        ServiceWorkflowAction(
          pageStage: ServiceWorkflowStage.workExecution,
          targetStage: ServiceWorkflowStage.workExecution,
          type: ServiceWorkflowActionType.edit,
          targetId: workExecution.id,
          permission: AppPermission.serviceWorkExecutionEdit,
        ),
      );
    }
    if (open && _can(context, AppPermission.serviceWorkExecutionPerform)) {
      actions.add(
        ServiceWorkflowAction(
          pageStage: ServiceWorkflowStage.workExecution,
          targetStage: ServiceWorkflowStage.workExecution,
          type: ServiceWorkflowActionType.perform,
          targetId: workExecution.id,
          permission: AppPermission.serviceWorkExecutionPerform,
        ),
      );
    }
    if (open &&
        workExecution.allLinesComplete &&
        _can(context, AppPermission.serviceWorkExecutionComplete)) {
      actions.add(
        ServiceWorkflowAction(
          pageStage: ServiceWorkflowStage.workExecution,
          targetStage: ServiceWorkflowStage.workExecution,
          type: ServiceWorkflowActionType.complete,
          targetId: workExecution.id,
          permission: AppPermission.serviceWorkExecutionComplete,
        ),
      );
    }
    if (open && _can(context, AppPermission.serviceWorkExecutionCancel)) {
      actions.add(
        ServiceWorkflowAction(
          pageStage: ServiceWorkflowStage.workExecution,
          targetStage: ServiceWorkflowStage.workExecution,
          type: ServiceWorkflowActionType.cancel,
          targetId: workExecution.id,
          permission: AppPermission.serviceWorkExecutionCancel,
        ),
      );
    }
    return actions;
  }
}
