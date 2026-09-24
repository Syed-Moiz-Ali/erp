/// Typed document sequence identity.
///
/// Using a typed value (rather than an arbitrary string in the UI) keeps
/// prefixes, padding and ownership consistent. Add a type only when a module
/// actually owns that transaction; do not add speculative Quotation/Job Order
/// types until ownership is confirmed.
class DocumentSequenceType {
  const DocumentSequenceType({
    required this.key,
    required this.prefix,
    this.padding = 6,
    this.separator = '-',
  });
  final String key;
  final String prefix;
  final int padding;
  final String separator;

  static const serviceEnquiry = DocumentSequenceType(
    key: 'serviceEnquiry',
    prefix: 'ENQ',
  );
  static const serviceJobAssignment = DocumentSequenceType(
    key: 'serviceJobAssignment',
    prefix: 'JA',
  );
  static const serviceJob = DocumentSequenceType(
    key: 'serviceJob',
    prefix: 'JOB',
  );
  static const serviceInspection = DocumentSequenceType(
    key: 'serviceInspection',
    prefix: 'INS',
  );
  static const materialRequest = DocumentSequenceType(
    key: 'materialRequest',
    prefix: 'MR',
  );
  static const workExecution = DocumentSequenceType(
    key: 'workExecution',
    prefix: 'EXEC',
  );

  // Services Phase 1 directory/team display codes.
  static const serviceCustomer = DocumentSequenceType(
    key: 'serviceCustomer',
    prefix: 'CUS',
  );
  static const serviceSite = DocumentSequenceType(
    key: 'serviceSite',
    prefix: 'SITE',
  );
  static const serviceTeam = DocumentSequenceType(
    key: 'serviceTeam',
    prefix: 'TEAM',
  );
}

/// Centralized display-number formatting. Never build `prefix + padded number`
/// strings in widgets.
abstract final class DocumentNumberFormatter {
  static String format({
    required String prefix,
    required int value,
    int padding = 6,
    String separator = '-',
  }) => '$prefix$separator${value.toString().padLeft(padding, '0')}';
}
