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
import 'package:modular_erp/modules/services/sites/domain/service_site.dart';
import 'package:modular_erp/modules/services/sites/domain/service_site_repository.dart';

class LocalServiceSiteRepository implements ServiceSiteRepository {
  LocalServiceSiteRepository(
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

  static const _table = 'service_sites';

  Failure? _access(AuthContext context, {bool manage = false}) {
    final permission = manage
        ? AppPermission.serviceSiteCreate
        : AppPermission.serviceSiteView;
    if (context.user.status != AccountStatus.active ||
        context.user.companyId != context.company.id ||
        !context.company.enabledModules.contains('services') ||
        !context.user.permissions.contains(permission)) {
      return const Failure(code: 'servicesSiteDenied');
    }
    return null;
  }

  ServiceSite _record(QueryRow row) => ServiceSite(
    id: row.read<String>('id'),
    companyId: row.read<String>('company_id'),
    customerId: row.read<String>('customer_id'),
    siteCode: row.read<String>('site_code'),
    siteName: row.read<String>('site_name'),
    tenantName: row.readNullable<String>('tenant_name'),
    buildingName: row.readNullable<String>('building_name'),
    unitNumber: row.readNullable<String>('unit_number'),
    contactName: row.readNullable<String>('contact_name'),
    contactMobile: row.readNullable<String>('contact_mobile'),
    contactEmail: row.readNullable<String>('contact_email'),
    addressLine1: row.read<String>('address_line1'),
    addressLine2: row.readNullable<String>('address_line2'),
    area: row.readNullable<String>('area'),
    city: row.read<String>('city'),
    state: row.readNullable<String>('state'),
    postalCode: row.readNullable<String>('postal_code'),
    countryCode: row.readNullable<String>('country_code'),
    latitude: row.readNullable<double>('latitude'),
    longitude: row.readNullable<double>('longitude'),
    notes: row.readNullable<String>('notes'),
    status: ConfigurationStatus.values.byName(row.read<String>('status')),
    syncStatus: RecordSyncStatus.values.byName(row.read<String>('sync_status')),
    createdAt: row.read<DateTime>('created_at').toUtc(),
    updatedAt: row.read<DateTime>('updated_at').toUtc(),
    createdByUserId: row.read<String>('created_by_user_id'),
    updatedByUserId: row.read<String>('updated_by_user_id'),
  );

  ServiceSiteListItem _listItem(QueryRow row) => ServiceSiteListItem(
    id: row.read<String>('id'),
    siteCode: row.read<String>('site_code'),
    siteName: row.read<String>('site_name'),
    customerId: row.read<String>('customer_id'),
    customerName: row.read<String>('customer_name'),
    buildingName: row.readNullable<String>('building_name'),
    unitNumber: row.readNullable<String>('unit_number'),
    contactName: row.readNullable<String>('contact_name'),
    city: row.read<String>('city'),
    status: ConfigurationStatus.values.byName(row.read<String>('status')),
    updatedAt: row.read<DateTime>('updated_at').toUtc(),
  );

  ({String sql, List<Variable> variables}) _clause(
    AuthContext context,
    String query,
    ConfigurationStatus? status,
    String? customerId,
  ) {
    final parts = <String>['s.company_id=?'];
    final variables = <Variable>[Variable(context.company.id)];
    if (status != null) {
      parts.add('s.status=?');
      variables.add(Variable(status.name));
    }
    if (customerId != null) {
      parts.add('s.customer_id=?');
      variables.add(Variable(customerId));
    }
    if (query.trim().isNotEmpty) {
      final escaped = query
          .trim()
          .toLowerCase()
          .replaceAll('\\', '\\\\')
          .replaceAll('%', '\\%')
          .replaceAll('_', '\\_');
      parts.add(
        "(lower(s.site_name) LIKE ? ESCAPE '\\' OR lower(s.site_code) LIKE ? ESCAPE '\\' OR lower(c.name) LIKE ? ESCAPE '\\')",
      );
      variables.addAll([for (var i = 0; i < 3; i++) Variable('%$escaped%')]);
    }
    return (sql: parts.join(' AND '), variables: variables);
  }

  Stream<Result<ServiceSitePage>> _listStream(
    AuthContext context,
    ({String sql, List<Variable> variables}) where,
    int page,
    int pageSize,
  ) => db
      .customSelect(
        'SELECT s.*, c.name AS customer_name FROM $_table s '
        'JOIN service_customers c ON c.id=s.customer_id AND c.company_id=s.company_id '
        'WHERE ${where.sql} ORDER BY lower(s.site_name), s.id LIMIT ? OFFSET ?',
        variables: [
          ...where.variables,
          Variable(pageSize.clamp(1, 100)),
          Variable(page.clamp(0, 1000000) * pageSize.clamp(1, 100)),
        ],
        readsFrom: {db.serviceSites, db.serviceCustomers},
      )
      .watch()
      .map<Result<ServiceSitePage>>((rows) {
        final items = rows.map(_listItem).toList();
        return Success(ServiceSitePage(items, items.length, items.length));
      })
      .transform(
        StreamTransformer<
          Result<ServiceSitePage>,
          Result<ServiceSitePage>
        >.fromHandlers(
          handleError:
              (
                Object _,
                StackTrace __,
                EventSink<Result<ServiceSitePage>> sink,
              ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
        ),
      );

  @override
  Stream<Result<ServiceSitePage>> watchSites(
    AuthContext context, {
    String query = '',
    ConfigurationStatus? status,
    String? customerId,
    int page = 0,
    int pageSize = 10,
  }) {
    final failure = _access(context);
    if (failure != null) return Stream.value(Failed(failure));
    return _listStream(
      context,
      _clause(context, query, status, customerId),
      page,
      pageSize,
    );
  }

  @override
  Stream<Result<List<ServiceSite>>> watchSitesForCustomer(
    AuthContext context,
    String customerId,
  ) {
    final failure = _access(context);
    if (failure != null) return Stream.value(Failed(failure));
    return db
        .customSelect(
          'SELECT * FROM $_table WHERE company_id=? AND customer_id=? ORDER BY lower(site_name)',
          variables: [Variable(context.company.id), Variable(customerId)],
          readsFrom: {db.serviceSites},
        )
        .watch()
        .map<Result<List<ServiceSite>>>(
          (rows) => Success(rows.map(_record).toList()),
        )
        .transform(
          StreamTransformer<
            Result<List<ServiceSite>>,
            Result<List<ServiceSite>>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<List<ServiceSite>>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  @override
  Stream<Result<ServiceSite?>> watchSite(AuthContext context, String id) {
    final failure = _access(context);
    if (failure != null) return Stream.value(Failed(failure));
    return db
        .customSelect(
          'SELECT * FROM $_table WHERE company_id=? AND id=?',
          variables: [Variable(context.company.id), Variable(id)],
          readsFrom: {db.serviceSites},
        )
        .watchSingleOrNull()
        .map<Result<ServiceSite?>>(
          (row) => Success(row == null ? null : _record(row)),
        )
        .transform(
          StreamTransformer<
            Result<ServiceSite?>,
            Result<ServiceSite?>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceSite?>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  Future<ServiceSite?> _raw(AuthContext context, String id) async {
    final row = await db
        .customSelect(
          'SELECT * FROM $_table WHERE company_id=? AND id=?',
          variables: [Variable(context.company.id), Variable(id)],
        )
        .getSingleOrNull();
    return row == null ? null : _record(row);
  }

  @override
  Future<Result<ServiceSite?>> getSite(AuthContext context, String id) async {
    final failure = _access(context);
    if (failure != null) return Failed(failure);
    try {
      return Success(await _raw(context, id));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<ServiceSite>> saveSite(
    AuthContext context,
    ServiceSiteDraft draft, {
    String? id,
  }) async {
    final failure = _access(context, manage: true);
    if (failure != null) return Failed(failure);
    final siteName = draft.siteName.trim();
    final address = draft.addressLine1.trim();
    final city = draft.city.trim();
    if (draft.customerId == null || draft.customerId!.isEmpty) {
      return const Failed(Failure(code: 'servicesSiteCustomerRequired'));
    }
    if (siteName.isEmpty || address.isEmpty || city.isEmpty) {
      return const Failed(Failure(code: 'servicesSiteRequired'));
    }
    try {
      return Success(
        await db.transaction(() async {
          final customer =
              await (db.select(db.serviceCustomers)..where(
                    (t) =>
                        t.id.equals(draft.customerId!) &
                        t.companyId.equals(context.company.id),
                  ))
                  .getSingleOrNull();
          if (customer == null) {
            throw const _SiteException('servicesSiteCustomerRequired');
          }
          final now = clock.now();
          final previous = id == null ? null : await _raw(context, id);
          if (id != null && previous == null) {
            throw const _SiteException('servicesSiteNotFound');
          }
          final code =
              previous?.siteCode ?? await _nextCode(context.company.id);
          final record = ServiceSite(
            id: id ?? _uuid.v4(),
            companyId: context.company.id,
            customerId: draft.customerId!,
            siteCode: code,
            siteName: siteName,
            tenantName: _nullable(draft.tenantName),
            buildingName: _nullable(draft.buildingName),
            unitNumber: _nullable(draft.unitNumber),
            contactName: _nullable(draft.contactName),
            contactMobile: _nullable(draft.contactMobile),
            contactEmail: _nullable(draft.contactEmail),
            addressLine1: address,
            addressLine2: _nullable(draft.addressLine2),
            area: _nullable(draft.area),
            city: city,
            state: _nullable(draft.state),
            postalCode: _nullable(draft.postalCode),
            countryCode: _nullable(draft.countryCode),
            latitude: _double(draft.latitude),
            longitude: _double(draft.longitude),
            notes: _nullable(draft.notes),
            status: previous?.status ?? ConfigurationStatus.active,
            syncStatus: RecordSyncStatus.pending,
            createdAt: previous?.createdAt ?? now,
            updatedAt: now,
            createdByUserId: previous?.createdByUserId ?? context.user.id,
            updatedByUserId: context.user.id,
          );
          await db
              .into(db.serviceSites)
              .insertOnConflictUpdate(
                ServiceSitesCompanion.insert(
                  id: record.id,
                  companyId: record.companyId,
                  customerId: record.customerId,
                  siteCode: record.siteCode,
                  siteName: record.siteName,
                  tenantName: Value(record.tenantName),
                  buildingName: Value(record.buildingName),
                  unitNumber: Value(record.unitNumber),
                  contactName: Value(record.contactName),
                  contactMobile: Value(record.contactMobile),
                  contactEmail: Value(record.contactEmail),
                  addressLine1: record.addressLine1,
                  addressLine2: Value(record.addressLine2),
                  area: Value(record.area),
                  city: record.city,
                  state: Value(record.state),
                  postalCode: Value(record.postalCode),
                  countryCode: Value(record.countryCode),
                  latitude: Value(record.latitude),
                  longitude: Value(record.longitude),
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
            id == null ? 'services.site.created' : 'services.site.updated',
          );
          await _enqueue(
            context,
            record,
            id == null ? 'SERVICES_SITE_CREATE' : 'SERVICES_SITE_UPDATE',
          );
          return record;
        }),
      );
    } on _SiteException catch (e) {
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
          throw const _SiteException('servicesSiteNotFound');
        }
        final status = active
            ? ConfigurationStatus.active
            : ConfigurationStatus.inactive;
        if (previous.status == status) return;
        final now = clock.now();
        await (db.update(db.serviceSites)..where(
              (t) => t.id.equals(id) & t.companyId.equals(context.company.id),
            ))
            .write(
              ServiceSitesCompanion(
                status: Value(status.name),
                updatedAt: Value(now),
                updatedByUserId: Value(context.user.id),
                syncStatus: const Value('pending'),
              ),
            );
        await _recordActivity(
          context,
          previous,
          active ? 'services.site.activated' : 'services.site.deactivated',
        );
        await _enqueue(context, previous, 'SERVICES_SITE_DEACTIVATE');
      });
      return const Success(null);
    } on _SiteException catch (e) {
      return Failed(Failure(code: e.code));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<List<ServiceSiteRef>>> searchReferences(
    AuthContext context, {
    String query = '',
    String? customerId,
    int limit = 50,
  }) async {
    final failure = _access(context);
    if (failure != null) return Failed(failure);
    try {
      final escaped = query.trim().toLowerCase();
      final rows = await db
          .customSelect(
            "SELECT s.id, s.site_code, s.site_name, s.customer_id, s.city, c.name AS customer_name FROM $_table s "
            "JOIN service_customers c ON c.id=s.customer_id AND c.company_id=s.company_id "
            "WHERE s.company_id=? AND s.status='active' "
            "${customerId == null ? '' : 'AND s.customer_id=? '}"
            "AND (lower(s.site_name) LIKE ? ESCAPE '\\' OR lower(s.site_code) LIKE ? ESCAPE '\\') "
            'ORDER BY lower(s.site_name) LIMIT ?',
            variables: [
              Variable(context.company.id),
              if (customerId != null) Variable(customerId),
              Variable('%$escaped%'),
              Variable('%$escaped%'),
              Variable(limit.clamp(1, 100)),
            ],
          )
          .get();
      return Success([
        for (final row in rows)
          ServiceSiteRef(
            id: row.read<String>('id'),
            siteCode: row.read<String>('site_code'),
            displayName: row.read<String>('site_name'),
            customerId: row.read<String>('customer_id'),
            customerName: row.read<String>('customer_name'),
            locationSummary: row.readNullable<String>('city'),
          ),
      ]);
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  String? _nullable(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  double? _double(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  Future<String> _nextCode(String companyId) async {
    final result = await numbers.nextNumber(
      companyId: companyId,
      type: DocumentSequenceType.serviceSite,
    );
    return switch (result) {
      Success<String>(:final value) => value,
      Failed<String>() => throw const _SiteException('servicesStorage'),
    };
  }

  Future<void> _recordActivity(
    AuthContext context,
    ServiceSite site,
    String eventType,
  ) => activity.append(
    BusinessActivityEvent(
      id: _uuid.v4(),
      companyId: context.company.id,
      moduleKey: 'services',
      entityType: 'serviceSite',
      entityId: site.id,
      eventType: eventType,
      occurredAt: clock.now(),
      actorUserId: context.user.id,
      actorEmployeeId: context.employeeReference?.id,
      syncStatus: 'pending',
      metadata: {'siteCode': site.siteCode, 'siteName': site.siteName},
    ),
  );

  Future<void> _enqueue(
    AuthContext context,
    ServiceSite site,
    String operation,
  ) => db
      .into(db.syncOutbox)
      .insert(
        SyncOutboxCompanion.insert(
          id: _uuid.v4(),
          moduleId: 'services',
          entityId: site.id,
          entityType: const Value('serviceSite'),
          operation: operation,
          payload:
              '{"id":"${site.id}","code":"${site.siteCode}","name":"${site.siteName}"}',
          createdAt: site.updatedAt,
          companyId: Value(context.company.id),
        ),
        mode: InsertMode.insertOrIgnore,
      );
}

class _SiteException implements Exception {
  const _SiteException(this.code);
  final String code;
}
