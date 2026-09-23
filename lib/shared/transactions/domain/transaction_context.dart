import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Minimal actor/company context for a future transaction mutation.
///
/// Actor identity is always derived from the authenticated session — never
/// supplied by editable UI fields. Deliberately small: not a god object.
class TransactionContext {
  const TransactionContext({
    required this.companyId,
    required this.actorUserId,
    required this.requestId,
    required this.occurredAt,
    this.actorEmployeeId,
  });
  final String companyId, actorUserId, requestId;
  final String? actorEmployeeId;
  final DateTime occurredAt;

  /// Builds the context from the authenticated session.
  factory TransactionContext.fromAuth(
    AuthContext context, {
    required String requestId,
    required DateTime occurredAt,
  }) => TransactionContext(
    companyId: context.company.id,
    actorUserId: context.user.id,
    actorEmployeeId: context.employeeReference?.id,
    requestId: requestId,
    occurredAt: occurredAt,
  );
}
