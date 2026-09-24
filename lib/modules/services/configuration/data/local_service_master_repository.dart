import 'dart:async';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master_repository.dart';

class LocalServiceMasterRepository implements ServiceMasterRepository {
  LocalServiceMasterRepository(this.db, this.clock, this.activity, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();
  final AppDatabase db;
  final AppClock clock;
  final ActivityRepository activity;
  final Uuid _uuid;

  AppPermission _viewPermission(ServiceMasterKind kind) => switch (kind) {
    ServiceMasterKind.serviceType => AppPermission.serviceTypeView,
    ServiceMasterKind.complaintType => AppPermission.complaintTypeView,
    ServiceMasterKind.priority => AppPermission.servicePriorityView,
    ServiceMasterKind.ticketType => AppPermission.serviceTicketTypeView,
  };

  AppPermission _managePermission(ServiceMasterKind kind) => switch (kind) {
    ServiceMasterKind.serviceType => AppPermission.serviceTypeManage,
    ServiceMasterKind.complaintType => AppPermission.complaintTypeManage,
    ServiceMasterKind.priority => AppPermission.servicePriorityManage,
    ServiceMasterKind.ticketType => AppPermission.serviceTicketTypeManage,
  };

  Failure? _access(
    ServiceMasterKind kind,
    AuthContext context, {
    bool manage = false,
  }) {
    if (context.user.status != AccountStatus.active ||
        context.user.companyId != context.company.id ||
        !context.company.enabledModules.contains('services') ||
        !context.user.permissions.contains(
          manage ? _managePermission(kind) : _viewPermission(kind),
        )) {
      return const Failure(code: 'servicesConfigDenied');
    }
    return null;
  }

  ServiceMasterRecord _record(ServiceMasterKind kind, QueryRow row) {
    final base = ServiceMasterRecord(
      id: row.read<String>('id'),
      companyId: row.read<String>('company_id'),
      code: row.read<String>('code'),
      name: row.read<String>('name'),
      description: row.readNullable<String>('description'),
      status: ConfigurationStatus.values.byName(row.read<String>('status')),
      syncStatus: RecordSyncStatus.values.byName(
        row.read<String>('sync_status'),
      ),
      sortOrder: row.read<int>('sort_order'),
      createdAt: row.read<DateTime>('created_at').toUtc(),
      updatedAt: row.read<DateTime>('updated_at').toUtc(),
      serviceTypeId: kind == ServiceMasterKind.complaintType
          ? row.readNullable<String>('service_type_id')
          : null,
      rank: kind == ServiceMasterKind.priority ? row.read<int>('rank') : 0,
      isDefault: kind == ServiceMasterKind.priority
          ? row.read<bool>('is_default')
          : false,
    );
    return base;
  }

  @override
  Stream<Result<ServiceMasterPage>> watchList(
    ServiceMasterKind kind,
    AuthContext context, {
    String query = '',
    ConfigurationStatus? status,
    int page = 0,
    int pageSize = 10,
  }) {
    final failure = _access(kind, context);
    if (failure != null) return Stream.value(Failed(failure));
    final parts = <String>['company_id=?'];
    final variables = <Variable>[Variable(context.company.id)];
    if (status != null) {
      parts.add('status=?');
      variables.add(Variable(status.name));
    }
    if (query.trim().isNotEmpty) {
      final escaped = query
          .trim()
          .toLowerCase()
          .replaceAll('\\', '\\\\')
          .replaceAll('%', '\\%')
          .replaceAll('_', '\\_');
      parts.add(
        "(lower(name) LIKE ? ESCAPE '\\' OR lower(code) LIKE ? ESCAPE '\\')",
      );
      variables.addAll([for (var i = 0; i < 2; i++) Variable('%$escaped%')]);
    }
    return db
        .customSelect(
          'SELECT * FROM ${kind.table} WHERE ${parts.join(' AND ')} ORDER BY sort_order, lower(name), id LIMIT ? OFFSET ?',
          variables: [
            ...variables,
            Variable(pageSize.clamp(1, 100)),
            Variable(page.clamp(0, 1000000) * pageSize.clamp(1, 100)),
          ],
          readsFrom: {_tableFor(kind)},
        )
        .watch()
        .map<Result<ServiceMasterPage>>((rows) {
          final items = [for (final row in rows) _record(kind, row)];
          return Success(ServiceMasterPage(items, items.length, items.length));
        })
        .transform(
          StreamTransformer<
            Result<ServiceMasterPage>,
            Result<ServiceMasterPage>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceMasterPage>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  ResultSetImplementation _tableFor(ServiceMasterKind kind) => switch (kind) {
    ServiceMasterKind.serviceType => db.serviceTypes,
    ServiceMasterKind.complaintType => db.complaintTypes,
    ServiceMasterKind.priority => db.servicePriorities,
    ServiceMasterKind.ticketType => db.serviceTicketTypes,
  };

  Future<ServiceMasterRecord?> _raw(
    ServiceMasterKind kind,
    AuthContext context,
    String id,
  ) async {
    final row = await db
        .customSelect(
          'SELECT * FROM ${kind.table} WHERE company_id=? AND id=?',
          variables: [Variable(context.company.id), Variable(id)],
        )
        .getSingleOrNull();
    return row == null ? null : _record(kind, row);
  }

  @override
  Stream<Result<ServiceMasterRecord?>> watchDetails(
    ServiceMasterKind kind,
    AuthContext context,
    String id,
  ) {
    final failure = _access(kind, context);
    if (failure != null) return Stream.value(Failed(failure));
    return db
        .customSelect(
          'SELECT * FROM ${kind.table} WHERE company_id=? AND id=?',
          variables: [Variable(context.company.id), Variable(id)],
          readsFrom: {_tableFor(kind)},
        )
        .watchSingleOrNull()
        .map<Result<ServiceMasterRecord?>>(
          (row) => Success(row == null ? null : _record(kind, row)),
        )
        .transform(
          StreamTransformer<
            Result<ServiceMasterRecord?>,
            Result<ServiceMasterRecord?>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceMasterRecord?>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  @override
  Future<Result<ServiceMasterRecord?>> getById(
    ServiceMasterKind kind,
    AuthContext context,
    String id,
  ) async {
    final failure = _access(kind, context);
    if (failure != null) return Failed(failure);
    try {
      return Success(await _raw(kind, context, id));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<ServiceMasterRecord>> save(
    ServiceMasterKind kind,
    AuthContext context,
    ServiceMasterDraft draft, {
    String? id,
  }) async {
    final failure = _access(kind, context, manage: true);
    if (failure != null) return Failed(failure);
    final code = draft.code.trim().toUpperCase();
    final name = draft.name.trim();
    if (code.isEmpty) {
      return const Failed(Failure(code: 'servicesMasterCodeRequired'));
    }
    if (name.isEmpty) {
      return const Failed(Failure(code: 'servicesMasterNameRequired'));
    }
    try {
      return Success(
        await db.transaction(() async {
          final now = clock.now();
          final previous = id == null ? null : await _raw(kind, context, id);
          if (id != null && previous == null) {
            throw const _MasterException('servicesMasterNotFound');
          }
          final duplicate = await db
              .customSelect(
                'SELECT id FROM ${kind.table} WHERE company_id=? AND id<>? AND (lower(code)=? OR lower(name)=?)',
                variables: [
                  Variable(context.company.id),
                  Variable(id ?? ''),
                  Variable(code.toLowerCase()),
                  Variable(name.toLowerCase()),
                ],
              )
              .get();
          if (duplicate.isNotEmpty) {
            throw const _MasterException('servicesMasterDuplicateCode');
          }
          final record = ServiceMasterRecord(
            id: id ?? _uuid.v4(),
            companyId: context.company.id,
            code: code,
            name: name,
            description: _nullable(draft.description),
            status: previous?.status ?? ConfigurationStatus.active,
            syncStatus: RecordSyncStatus.pending,
            sortOrder: int.tryParse(draft.sortOrder.trim()) ?? 0,
            rank: int.tryParse(draft.rank.trim()) ?? 0,
            isDefault: draft.isDefault,
            serviceTypeId: _nullable(draft.serviceTypeId),
            createdAt: previous?.createdAt ?? now,
            updatedAt: now,
          );
          await _insert(kind, record);
          await activity.append(
            BusinessActivityEvent(
              id: _uuid.v4(),
              companyId: context.company.id,
              moduleKey: 'services',
              entityType: kind.entityType,
              entityId: record.id,
              eventType: id == null
                  ? 'services.configuration.created'
                  : 'services.configuration.updated',
              occurredAt: now,
              actorUserId: context.user.id,
              actorEmployeeId: context.employeeReference?.id,
              syncStatus: 'pending',
              metadata: {'code': record.code, 'name': record.name},
            ),
          );
          await db
              .into(db.syncOutbox)
              .insert(
                SyncOutboxCompanion.insert(
                  id: _uuid.v4(),
                  moduleId: 'services',
                  entityId: record.id,
                  entityType: Value(kind.entityType),
                  operation: id == null
                      ? kind.createOperation
                      : 'SERVICES_CONFIG_UPDATE',
                  payload:
                      '{"id":"${record.id}","code":"${record.code}","name":"${record.name}"}',
                  createdAt: now,
                  companyId: Value(context.company.id),
                ),
                mode: InsertMode.insertOrIgnore,
              );
          return record;
        }),
      );
    } on _MasterException catch (e) {
      return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  Future<void> _insert(ServiceMasterKind kind, ServiceMasterRecord record) {
    final now = record.createdAt;
    return switch (kind) {
      ServiceMasterKind.serviceType =>
        db
            .into(db.serviceTypes)
            .insertOnConflictUpdate(
              ServiceTypesCompanion.insert(
                id: record.id,
                companyId: record.companyId,
                code: record.code,
                name: record.name,
                description: Value(record.description),
                status: record.status.name,
                sortOrder: Value(record.sortOrder),
                createdAt: record.createdAt,
                updatedAt: now,
                syncStatus: record.syncStatus.name,
              ),
            ),
      ServiceMasterKind.complaintType =>
        db
            .into(db.complaintTypes)
            .insertOnConflictUpdate(
              ComplaintTypesCompanion.insert(
                id: record.id,
                companyId: record.companyId,
                code: record.code,
                name: record.name,
                description: Value(record.description),
                serviceTypeId: Value(record.serviceTypeId),
                status: record.status.name,
                sortOrder: Value(record.sortOrder),
                createdAt: record.createdAt,
                updatedAt: now,
                syncStatus: record.syncStatus.name,
              ),
            ),
      ServiceMasterKind.priority =>
        db
            .into(db.servicePriorities)
            .insertOnConflictUpdate(
              ServicePrioritiesCompanion.insert(
                id: record.id,
                companyId: record.companyId,
                code: record.code,
                name: record.name,
                description: Value(record.description),
                rank: Value(record.rank),
                isDefault: Value(record.isDefault),
                status: record.status.name,
                sortOrder: Value(record.sortOrder),
                createdAt: record.createdAt,
                updatedAt: now,
                syncStatus: record.syncStatus.name,
              ),
            ),
      ServiceMasterKind.ticketType =>
        db
            .into(db.serviceTicketTypes)
            .insertOnConflictUpdate(
              ServiceTicketTypesCompanion.insert(
                id: record.id,
                companyId: record.companyId,
                code: record.code,
                name: record.name,
                description: Value(record.description),
                status: record.status.name,
                sortOrder: Value(record.sortOrder),
                createdAt: record.createdAt,
                updatedAt: now,
                syncStatus: record.syncStatus.name,
              ),
            ),
    };
  }

  @override
  Future<Result<void>> setActive(
    ServiceMasterKind kind,
    AuthContext context,
    String id,
    bool active,
  ) async {
    final failure = _access(kind, context, manage: true);
    if (failure != null) return Failed(failure);
    try {
      await db.transaction(() async {
        final previous = await _raw(kind, context, id);
        if (previous == null) {
          throw const _MasterException('servicesMasterNotFound');
        }
        final status = active
            ? ConfigurationStatus.active
            : ConfigurationStatus.inactive;
        if (previous.status == status) return;
        await db.customUpdate(
          'UPDATE ${kind.table} SET status=?, updated_at=?, sync_status=? WHERE company_id=? AND id=?',
          variables: [
            Variable(status.name),
            Variable(clock.now()),
            Variable('pending'),
            Variable(context.company.id),
            Variable(id),
          ],
        );
        await activity.append(
          BusinessActivityEvent(
            id: _uuid.v4(),
            companyId: context.company.id,
            moduleKey: 'services',
            entityType: kind.entityType,
            entityId: id,
            eventType: active
                ? 'services.configuration.activated'
                : 'services.configuration.deactivated',
            occurredAt: clock.now(),
            actorUserId: context.user.id,
            syncStatus: 'pending',
            metadata: {'code': previous.code, 'name': previous.name},
          ),
        );
      });
      return const Success(null);
    } on _MasterException catch (e) {
      return Failed(Failure(code: e.code));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  String? _nullable(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _MasterException implements Exception {
  const _MasterException(this.code);
  final String code;
}
