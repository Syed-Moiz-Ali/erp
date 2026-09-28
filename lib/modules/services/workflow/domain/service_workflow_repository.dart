import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Application-level Services workflow read model.
///
/// This is deliberately **not** a persistence contract: it assembles the chain
/// from the five existing transaction repositories, each of which re-checks its
/// own permission/scope on every read. No aggregate/table stores the workflow
/// (Phase 7 §11–12, §95).
abstract interface class ServiceWorkflowRepository {
  /// Resolves the whole chain rooted at an Enquiry. [focus] only marks which
  /// node the calling screen is currently showing; it never changes access.
  Stream<Result<ServiceWorkflowChain?>> watchChain(
    AuthContext context,
    String enquiryId, {
    ServiceWorkflowStage? focus,
  });

  Future<Result<ServiceWorkflowChain?>> loadChain(
    AuthContext context,
    String enquiryId, {
    ServiceWorkflowStage? focus,
  });

  /// Permission/scope-aware operational counts for the Services dashboard.
  Future<Result<ServiceWorkflowSummary>> summary(AuthContext context);

  /// Merged workflow-level activity feed for the records the user may view,
  /// ordered by event timestamp (Phase 7 §54–56).
  Stream<Result<List<ServiceWorkflowActivityEntry>>> watchActivity(
    AuthContext context,
    String enquiryId,
  );
}
