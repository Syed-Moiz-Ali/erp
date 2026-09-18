import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/errors/result.dart';
import '../../core/models/configuration_record.dart';
import '../../core/security/app_permission.dart';
import '../../features/auth/domain/entities/auth_context.dart';
import '../domain/configuration_repository.dart';

/// Shared tenant-safe mechanics only. Feature repositories own their schemas,
/// domain rules, drafts and entity/row mapping.
abstract class LocalConfigurationRepository<T extends ConfigurationRecord, D>
    implements ConfigurationRepository<T, D> {
  LocalConfigurationRepository(this.db);
  final AppDatabase db;
  String get tableName;
  String get featureId;
  String get employeeColumn;
  AppPermission get viewPermission;
  AppPermission get managePermission;
  ResultSetImplementation get table;
  List<String> get searchColumns;
  T readRow(QueryRow row);
  T createRecord(
    AuthContext context,
    D draft, {
    required String id,
    T? previous,
    required DateTime now,
  });
  T withStatus(T record, ConfigurationStatus status, DateTime now);
  D normalize(D draft);
  Map<String, String> validate(D draft);
  Future<void> put(T record);
  Future<void>? _writes;
  Future<R> serial<R>(Future<R> Function() work) {
    final next = (_writes ?? Future<void>.value()).then((_) => work());
    _writes = next.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return next;
  }

  Failure get storageFailure => const Failure(
    code: 'databaseFailure',
    kind: FailureKind.storageWrite,
    retryable: true,
  );
  Failure? access(AuthContext context, {bool manage = false}) {
    if (context.user.status != AccountStatus.active ||
        context.user.companyId != context.company.id ||
        !context.company.enabledModules.contains('settings') ||
        !PermissionChecker(
          context.user.permissions,
        ).can(manage ? managePermission : viewPermission)) {
      return const Failure(code: 'denied');
    }
    return null;
  }

  String normalizedName(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  ({String sql, List<Variable> variables}) clause(
    AuthContext context,
    String query,
    ConfigurationStatus? status,
  ) {
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
        '(${searchColumns.map((c) => "lower($c) LIKE ? ESCAPE '\\'").join(' OR ')})',
      );
      variables.addAll(searchColumns.map((_) => Variable('%$escaped%')));
    }
    return (sql: parts.join(' AND '), variables: variables);
  }

  Stream<void> changes(AuthContext context) => db
      .customSelect(
        'SELECT COUNT(*) AS n FROM $tableName WHERE company_id=?',
        variables: [Variable(context.company.id)],
        readsFrom: {table, db.workforceEmployees},
      )
      .watch()
      .map((_) {});
  Stream<Result<R>> safeStream<R>(Stream<Result<R>> source) => source.transform(
    StreamTransformer<Result<R>, Result<R>>.fromHandlers(
      handleError: (Object _, StackTrace __, EventSink<Result<R>> sink) =>
          sink.add(Failed(storageFailure)),
    ),
  );
  @override
  Stream<Result<ConfigurationPageData<T>>> watchList(
    AuthContext context, {
    String query = '',
    ConfigurationStatus? status,
    int page = 0,
    int pageSize = 10,
  }) {
    final failure = access(context);
    if (failure != null) return Stream.value(Failed(failure));
    return safeStream(
      changes(context).asyncMap((_) async {
        try {
          return Success(
            await db.transaction(() async {
              final where = clause(context, query, status);
              final count =
                  (await db
                          .customSelect(
                            'SELECT COUNT(*) AS n FROM $tableName WHERE company_id=?',
                            variables: [Variable(context.company.id)],
                          )
                          .getSingle())
                      .read<int>('n');
              final filtered =
                  (await db
                          .customSelect(
                            'SELECT COUNT(*) AS n FROM $tableName WHERE ${where.sql}',
                            variables: where.variables,
                          )
                          .getSingle())
                      .read<int>('n');
              final rows = await db
                  .customSelect(
                    'SELECT c.*, (SELECT COUNT(*) FROM workforce_employees e WHERE e.company_id=c.company_id AND e.$employeeColumn=c.id) AS assigned_count FROM $tableName c WHERE ${where.sql} ORDER BY normalized_name, id LIMIT ? OFFSET ?',
                    variables: [
                      ...where.variables,
                      Variable(pageSize.clamp(1, 100)),
                      Variable(page.clamp(0, 1000000) * pageSize.clamp(1, 100)),
                    ],
                  )
                  .get();
              return ConfigurationPageData(
                rows
                    .map(
                      (r) => ConfigurationItem(
                        readRow(r),
                        r.read<int>('assigned_count'),
                      ),
                    )
                    .toList(),
                count,
                filtered,
              );
            }),
          );
        } catch (_) {
          return Failed<ConfigurationPageData<T>>(storageFailure);
        }
      }),
    );
  }

  Future<T?> raw(AuthContext context, String id) async {
    final row = await db
        .customSelect(
          'SELECT * FROM $tableName WHERE company_id=? AND id=?',
          variables: [Variable(context.company.id), Variable(id)],
        )
        .getSingleOrNull();
    return row == null ? null : readRow(row);
  }

  @override
  Future<Result<T?>> getById(
    AuthContext context,
    String id, {
    bool forEditing = false,
  }) async {
    final failure = access(context, manage: forEditing);
    if (failure != null) return Failed(failure);
    try {
      return Success(await raw(context, id));
    } catch (_) {
      return Failed(storageFailure);
    }
  }

  @override
  Stream<Result<ConfigurationItem<T>?>> watchDetails(
    AuthContext context,
    String id,
  ) {
    final failure = access(context);
    if (failure != null) return Stream.value(Failed(failure));
    return safeStream(
      changes(context).asyncMap((_) async {
        try {
          final rows = await db
              .customSelect(
                'SELECT c.*, (SELECT COUNT(*) FROM workforce_employees e WHERE e.company_id=c.company_id AND e.$employeeColumn=c.id) AS assigned_count FROM $tableName c WHERE company_id=? AND id=?',
                variables: [Variable(context.company.id), Variable(id)],
              )
              .get();
          return Success<ConfigurationItem<T>?>(
            rows.isEmpty
                ? null
                : ConfigurationItem(
                    readRow(rows.single),
                    rows.single.read<int>('assigned_count'),
                  ),
          );
        } catch (_) {
          return Failed<ConfigurationItem<T>?>(storageFailure);
        }
      }),
    );
  }

  Future<void> unique(T record) async {
    if (record.status != ConfigurationStatus.active) return;
    final duplicate = await db
        .customSelect(
          "SELECT id FROM $tableName WHERE company_id=? AND normalized_name=? AND status='active' AND id<>? LIMIT 1",
          variables: [
            Variable(record.companyId),
            Variable(normalizedName(record.name)),
            Variable(record.id),
          ],
        )
        .get();
    if (duplicate.isNotEmpty) {
      throw const ConfigurationWriteException('duplicateName');
    }
  }

  Future<void> enqueue(T record, String operation) async {
    await db
        .into(db.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            id: const Uuid().v4(),
            moduleId: featureId,
            entityId: record.id,
            operation: operation,
            payload: jsonEncode(record.toJson()),
            createdAt: record.updatedAt,
          ),
        );
  }

  @override
  Future<Result<T>> save(AuthContext context, D draft, {String? id}) => serial(
    () async {
      final failure = access(context, manage: true);
      if (failure != null) return Failed(failure);
      try {
        return Success(
          await db.transaction(() async {
            final previous = id == null ? null : await raw(context, id);
            if (id != null && previous == null) {
              throw const ConfigurationWriteException('notFound');
            }
            final normalized = normalize(draft), errors = validate(normalized);
            if (errors.isNotEmpty) {
              throw ConfigurationWriteException(errors.values.first);
            }
            final record = createRecord(
              context,
              normalized,
              id: id ?? const Uuid().v4(),
              previous: previous,
              now: DateTime.fromMillisecondsSinceEpoch(
                (DateTime.now().millisecondsSinceEpoch ~/ 1000) * 1000,
                isUtc: true,
              ),
            );
            await unique(record);
            await put(record);
            await enqueue(record, id == null ? 'create' : 'update');
            return record;
          }),
        );
      } on ConfigurationWriteException catch (e) {
        return Failed(Failure(code: e.code, kind: FailureKind.invalidData));
      } catch (_) {
        return Failed(storageFailure);
      }
    },
  );
  @override
  Future<Result<void>> setActive(AuthContext context, String id, bool active) =>
      serial(() async {
        final failure = access(context, manage: true);
        if (failure != null) return Failed(failure);
        try {
          await db.transaction(() async {
            final previous = await raw(context, id);
            if (previous == null) {
              throw const ConfigurationWriteException('notFound');
            }
            final status = active
                ? ConfigurationStatus.active
                : ConfigurationStatus.inactive;
            if (previous.status == status) return;
            final updated = withStatus(
              previous,
              status,
              DateTime.fromMillisecondsSinceEpoch(
                (DateTime.now().millisecondsSinceEpoch ~/ 1000) * 1000,
                isUtc: true,
              ),
            );
            await unique(updated);
            await put(updated);
            await enqueue(updated, active ? 'activate' : 'deactivate');
          });
          return const Success(null);
        } on ConfigurationWriteException catch (e) {
          return Failed(Failure(code: e.code));
        } catch (_) {
          return Failed(storageFailure);
        }
      });
  @override
  Future<Result<int>> assignedEmployeeCount(
    AuthContext context,
    String id,
  ) async {
    final failure = access(context);
    if (failure != null && access(context, manage: true) != null) {
      return Failed(failure);
    }
    try {
      if (await raw(context, id) == null) {
        return const Failed(Failure(code: 'notFound'));
      }
      return Success(
        (await db
                .customSelect(
                  'SELECT COUNT(*) AS n FROM workforce_employees WHERE company_id=? AND $employeeColumn=?',
                  variables: [Variable(context.company.id), Variable(id)],
                )
                .getSingle())
            .read<int>('n'),
      );
    } catch (_) {
      return Failed(storageFailure);
    }
  }
}

class ConfigurationWriteException implements Exception {
  const ConfigurationWriteException(this.code);
  final String code;
}
