import 'package:modular_erp/core/errors/result.dart';
import 'document_number.dart';

/// Generates human-readable, company-scoped, document-type-scoped business
/// numbers.
///
/// Local generation is deterministic and transactional, but distributed
/// uniqueness is ultimately a backend concern: [adoptServerNumber] is the seam
/// a future server can use to finalize/reconcile the authoritative value.
abstract interface class DocumentNumberService {
  Future<Result<String>> nextNumber({
    required String companyId,
    required DocumentSequenceType type,
  });

  /// Reconciles the local counter with a server-assigned number. If the number
  /// carries a trailing integer, the local counter is advanced past it so local
  /// generation cannot collide with the server value.
  Future<Result<void>> adoptServerNumber({
    required String companyId,
    required DocumentSequenceType type,
    required String displayNumber,
  });
}
