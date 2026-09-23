import 'package:drift/drift.dart';

/// Company-scoped, document-type-scoped sequence counters used to generate
/// human-readable business numbers (`ENQ-000042`).
///
/// The counter is infrastructure only; the generated display number is never a
/// primary key. A future backend can become authoritative and reconcile values.
class DocumentSequences extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get sequenceKey => text()();
  TextColumn get prefix => text()();
  IntColumn get nextValue => integer().withDefault(const Constant(0))();
  IntColumn get padding => integer().withDefault(const Constant(6))();
  TextColumn get separator => text().withDefault(const Constant('-'))();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Generic attachment/media **metadata**. File bytes are never stored here; only
/// a local path and/or future remote storage reference.
class AttachmentRecords extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get ownerType => text()();
  TextColumn get ownerId => text()();
  TextColumn get category => text()();
  TextColumn get fileName => text()();
  TextColumn get displayName => text()();
  TextColumn get mimeType => text()();
  IntColumn get sizeBytes => integer()();
  TextColumn get localPath => text().nullable()();
  TextColumn get remoteUrl => text().nullable()();
  TextColumn get storageKey => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  TextColumn get checksum => text().nullable()();
  TextColumn get uploadStatus => text()();
  TextColumn get syncStatus => text()();
  TextColumn get createdByUserId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Append-only structured business activity/audit events. Presentation maps
/// `eventType`/`metadata` to localized text; English sentences are never stored.
@DataClassName('BusinessActivityEventRow')
class BusinessActivityEvents extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get moduleKey => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get eventType => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get actorUserId => text()();
  TextColumn get actorEmployeeId => text().nullable()();
  TextColumn get summaryKey => text().nullable()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  TextColumn get requestId => text().nullable()();
  TextColumn get syncStatus => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}
