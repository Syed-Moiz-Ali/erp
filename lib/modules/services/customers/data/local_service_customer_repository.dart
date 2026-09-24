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
import 'package:modular_erp/shared/transactions/domain/document_number.dart';
import 'package:modular_erp/shared/transactions/domain/document_number_service.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer_repository.dart';

class LocalServiceCustomerRepository implements ServiceCustomerRepository {
  LocalServiceCustomerRepository(
    this.db,
    this.clock,
    this.numbers,
    this.activity, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();
  final AppDatabase db;
  final AppClock clock;
  final DocumentNumberService numbers;
  final ActivityRepository activity;
  final Uuid _uuid;

  Failure? _access(AuthContext context, {bool manage = false}) {
    final permission = manage
        ? AppPermission.serviceCustomerCreate
        : AppPermission.serviceCustomerView;
    if (context.user.status != AccountStatus.active ||
        context.user.companyId != context.company.id ||
        !context.company.enabledModules.contains('services') ||
        !context.user.permissions.contains(permission)) {
      return const Failure(code: 'servicesCustomerDenied');
    }
    return null;
  }

  static const _table = 'service_customers';

  ServiceCustomerListItem _listItem(QueryRow row) => ServiceCustomerListItem(
    id: row.read<String>('id'),
    customerCode: row.read<String>('customer_code'),
    name: row.read<String>('name'),
    mobile: row.read<String>('mobile'),
    status: ConfigurationStatus.values.byName(row.read<String>('status')),
    siteCount: row.read<int>('site_count'),
    updatedAt: row.read<DateTime>('updated_at').toUtc(),
  );

  ServiceCustomer _record(QueryRow row) => ServiceCustomer(
    id: row.read<String>('id'),
    companyId: row.read<String>('company_id'),
    customerCode: row.read<String>('customer_code'),
    name: row.read<String>('name'),
    kind: ServiceCustomerKind.values.byName(row.read<String>('kind')),
    mobile: row.read<String>('mobile'),
    alternateMobile: row.readNullable<String>('alternate_mobile'),
    email: row.readNullable<String>('email'),
    notes: row.readNullable<String>('notes'),
    status: ConfigurationStatus.values.byName(row.read<String>('status')),
    syncStatus: RecordSyncStatus.values.byName(row.read<String>('sync_status')),
    createdAt: row.read<DateTime>('created_at').toUtc(),
    updatedAt: row.read<DateTime>('updated_at').toUtc(),
    createdByUserId: row.read<String>('created_by_user_id'),
    updatedByUserId: row.read<String>('updated_by_user_id'),
  );

  ({String sql, List<Variable> variables}) _clause(
    AuthContext context,
    String query,
    ConfigurationStatus? status,
  ) {
    final parts = <String>['c.company_id=?'];
    final variables = <Variable>[Variable(context.company.id)];
    if (status != null) {
      parts.add('c.status=?');
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
        "(lower(c.name) LIKE ? ESCAPE '\\' OR lower(c.customer_code) LIKE ? ESCAPE '\\' OR lower(c.mobile) LIKE ? ESCAPE '\\')",
      );
      variables.addAll([for (var i = 0; i < 3; i++) Variable('%$escaped%')]);
    }
    return (sql: parts.join(' AND '), variables: variables);
  }

  @override
  Stream<Result<ServiceCustomerPage>> watchCustomers(
    AuthContext context, {
    String query = '',
    ConfigurationStatus? status,
    int page = 0,
    int pageSize = 10,
  }) {
    final failure = _access(context);
    if (failure != null) return Stream.value(Failed(failure));
    final where = _clause(context, query, status);
    return db
        .customSelect(
          'SELECT c.*, (SELECT COUNT(*) FROM service_sites s WHERE s.company_id=c.company_id AND s.customer_id=c.id AND s.status=\'active\') AS site_count '
          'FROM $_table c WHERE ${where.sql} ORDER BY lower(c.name), c.id LIMIT ? OFFSET ?',
          variables: [
            ...where.variables,
            Variable(pageSize.clamp(1, 100)),
            Variable(page.clamp(0, 1000000) * pageSize.clamp(1, 100)),
          ],
          readsFrom: {db.serviceCustomers, db.serviceSites},
        )
        .watch()
        .map<Result<ServiceCustomerPage>>((rows) {
          final items = rows.map(_listItem).toList();
          return Success(
            ServiceCustomerPage(items, items.length, items.length),
          );
        })
        .transform(
          StreamTransformer<
            Result<ServiceCustomerPage>,
            Result<ServiceCustomerPage>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceCustomerPage>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  @override
  Stream<Result<ServiceCustomer?>> watchCustomer(
    AuthContext context,
    String id,
  ) {
    final failure = _access(context);
    if (failure != null) return Stream.value(Failed(failure));
    return db
        .customSelect(
          'SELECT * FROM $_table WHERE company_id=? AND id=?',
          variables: [Variable(context.company.id), Variable(id)],
          readsFrom: {db.serviceCustomers},
        )
        .watchSingleOrNull()
        .map<Result<ServiceCustomer?>>(
          (row) => Success(row == null ? null : _record(row)),
        )
        .transform(
          StreamTransformer<
            Result<ServiceCustomer?>,
            Result<ServiceCustomer?>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceCustomer?>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  Future<ServiceCustomer?> _raw(AuthContext context, String id) async {
    final row = await db
        .customSelect(
          'SELECT * FROM $_table WHERE company_id=? AND id=?',
          variables: [Variable(context.company.id), Variable(id)],
        )
        .getSingleOrNull();
    return row == null ? null : _record(row);
  }

  @override
  Future<Result<ServiceCustomer?>> getCustomer(
    AuthContext context,
    String id,
  ) async {
    final failure = _access(context);
    if (failure != null) return Failed(failure);
    try {
      return Success(await _raw(context, id));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<ServiceCustomer>> saveCustomer(
    AuthContext context,
    ServiceCustomerDraft draft, {
    String? id,
  }) async {
    final failure = _access(context, manage: true);
    if (failure != null) return Failed(failure);
    final name = draft.name.trim();
    final mobile = draft.mobile.trim();
    final email = draft.email.trim();
    if (name.isEmpty) {
      return const Failed(Failure(code: 'servicesCustomerRequired'));
    }
    if (mobile.isEmpty) {
      return const Failed(Failure(code: 'servicesCustomerInvalidMobile'));
    }
    if (email.isNotEmpty && !email.contains('@')) {
      return const Failed(Failure(code: 'servicesCustomerInvalidEmail'));
    }
    try {
      return Success(
        await db.transaction(() async {
          final now = clock.now();
          final previous = id == null ? null : await _raw(context, id);
          if (id != null && previous == null) {
            throw const _CustomerException('servicesCustomerNotFound');
          }
          final duplicate = await _duplicate(
            context,
            mobile: mobile,
            email: email.isEmpty ? null : email,
            excludingId: id,
          );
          if (duplicate == 'mobile') {
            throw const _CustomerException('servicesCustomerDuplicateMobile');
          }
          if (duplicate == 'email') {
            throw const _CustomerException('servicesCustomerDuplicateEmail');
          }
          final code =
              previous?.customerCode ?? await _nextCode(context.company.id);
          final record = ServiceCustomer(
            id: id ?? _uuid.v4(),
            companyId: context.company.id,
            customerCode: code,
            name: name,
            kind: draft.kind,
            mobile: mobile,
            alternateMobile: _nullable(draft.alternateMobile),
            email: _nullable(email),
            notes: _nullable(draft.notes),
            status: previous?.status ?? ConfigurationStatus.active,
            syncStatus: RecordSyncStatus.pending,
            createdAt: previous?.createdAt ?? now,
            updatedAt: now,
            createdByUserId: previous?.createdByUserId ?? context.user.id,
            updatedByUserId: context.user.id,
          );
          await db
              .into(db.serviceCustomers)
              .insertOnConflictUpdate(
                ServiceCustomersCompanion.insert(
                  id: record.id,
                  companyId: record.companyId,
                  customerCode: record.customerCode,
                  name: record.name,
                  kind: Value(record.kind.name),
                  mobile: record.mobile,
                  alternateMobile: Value(record.alternateMobile),
                  email: Value(record.email),
                  notes: Value(record.notes),
                  status: record.status.name,
                  createdAt: record.createdAt,
                  updatedAt: record.updatedAt,
                  createdByUserId: record.createdByUserId,
                  updatedByUserId: record.updatedByUserId,
                  syncStatus: record.syncStatus.name,
                ),
              );
          await _recordActivity(
            context,
            record,
            id == null
                ? 'services.customer.created'
                : 'services.customer.updated',
          );
          await _enqueue(
            context,
            record,
            id == null
                ? 'SERVICES_CUSTOMER_CREATE'
                : 'SERVICES_CUSTOMER_UPDATE',
          );
          return record;
        }),
      );
    } on _CustomerException catch (e) {
      return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<void>> setActive(
    AuthContext context,
    String id,
    bool active,
  ) async {
    final failure = _access(context, manage: true);
    if (failure != null) return Failed(failure);
    try {
      await db.transaction(() async {
        final previous = await _raw(context, id);
        if (previous == null) {
          throw const _CustomerException('servicesCustomerNotFound');
        }
        final status = active
            ? ConfigurationStatus.active
            : ConfigurationStatus.inactive;
        if (previous.status == status) return;
        final now = clock.now();
        await (db.update(db.serviceCustomers)..where(
              (t) => t.id.equals(id) & t.companyId.equals(context.company.id),
            ))
            .write(
              ServiceCustomersCompanion(
                status: Value(status.name),
                updatedAt: Value(now),
                updatedByUserId: Value(context.user.id),
                syncStatus: const Value('pending'),
              ),
            );
        final updated = ServiceCustomer(
          id: previous.id,
          companyId: previous.companyId,
          customerCode: previous.customerCode,
          name: previous.name,
          kind: previous.kind,
          mobile: previous.mobile,
          alternateMobile: previous.alternateMobile,
          email: previous.email,
          notes: previous.notes,
          status: status,
          syncStatus: RecordSyncStatus.pending,
          createdAt: previous.createdAt,
          updatedAt: now,
          createdByUserId: previous.createdByUserId,
          updatedByUserId: context.user.id,
        );
        await _recordActivity(
          context,
          updated,
          active
              ? 'services.customer.activated'
              : 'services.customer.deactivated',
        );
        await _enqueue(context, updated, 'SERVICES_CUSTOMER_DEACTIVATE');
      });
      return const Success(null);
    } on _CustomerException catch (e) {
      return Failed(Failure(code: e.code));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<List<ServiceCustomerRef>>> searchReferences(
    AuthContext context, {
    String query = '',
    int limit = 50,
  }) async {
    final failure = _access(context);
    if (failure != null) return Failed(failure);
    try {
      final rows = await db
          .customSelect(
            "SELECT id, customer_code, name, mobile FROM $_table WHERE company_id=? AND status='active' AND (lower(name) LIKE ? ESCAPE '\\' OR lower(customer_code) LIKE ? ESCAPE '\\') ORDER BY lower(name) LIMIT ?",
            variables: [
              Variable(context.company.id),
              Variable('%${query.trim().toLowerCase()}%'),
              Variable('%${query.trim().toLowerCase()}%'),
              Variable(limit.clamp(1, 100)),
            ],
          )
          .get();
      return Success([
        for (final row in rows)
          ServiceCustomerRef(
            id: row.read<String>('id'),
            customerCode: row.read<String>('customer_code'),
            displayName: row.read<String>('name'),
            mobile: row.read<String>('mobile'),
          ),
      ]);
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<bool>> hasDuplicate(
    AuthContext context, {
    required String mobile,
    String? email,
    String? excludingId,
  }) async {
    final failure = _access(context);
    if (failure != null) return Failed(failure);
    try {
      final result = await _duplicate(
        context,
        mobile: mobile.trim(),
        email: email?.trim(),
        excludingId: excludingId,
      );
      return Success(result != null);
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  String? _nullable(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<String> _nextCode(String companyId) async {
    final result = await numbers.nextNumber(
      companyId: companyId,
      type: DocumentSequenceType.serviceCustomer,
    );
    return switch (result) {
      Success<String>(:final value) => value,
      Failed<String>() => throw const _CustomerException('servicesStorage'),
    };
  }

  Future<String?> _duplicate(
    AuthContext context, {
    required String mobile,
    String? email,
    String? excludingId,
  }) async {
    final rows = await db
        .customSelect(
          "SELECT mobile, email FROM $_table WHERE company_id=? AND status='active' AND id<>?",
          variables: [
            Variable(context.company.id),
            Variable(excludingId ?? ''),
          ],
        )
        .get();
    for (final row in rows) {
      if (row.read<String>('mobile') == mobile) return 'mobile';
      final existingEmail = row.readNullable<String>('email');
      if (email != null && existingEmail != null && existingEmail == email) {
        return 'email';
      }
    }
    return null;
  }

  Future<void> _recordActivity(
    AuthContext context,
    ServiceCustomer customer,
    String eventType,
  ) => activity.append(
    BusinessActivityEvent(
      id: _uuid.v4(),
      companyId: context.company.id,
      moduleKey: 'services',
      entityType: 'serviceCustomer',
      entityId: customer.id,
      eventType: eventType,
      occurredAt: clock.now(),
      actorUserId: context.user.id,
      actorEmployeeId: context.employeeReference?.id,
      syncStatus: 'pending',
      metadata: {'customerCode': customer.customerCode, 'name': customer.name},
    ),
  );

  Future<void> _enqueue(
    AuthContext context,
    ServiceCustomer customer,
    String operation,
  ) => db
      .into(db.syncOutbox)
      .insert(
        SyncOutboxCompanion.insert(
          id: _uuid.v4(),
          moduleId: 'services',
          entityId: customer.id,
          entityType: const Value('serviceCustomer'),
          operation: operation,
          payload:
              '{"id":"${customer.id}","code":"${customer.customerCode}","name":"${customer.name}"}',
          createdAt: customer.updatedAt,
          companyId: Value(context.company.id),
        ),
        mode: InsertMode.insertOrIgnore,
      );
}

class _CustomerException implements Exception {
  const _CustomerException(this.code);
  final String code;
}
