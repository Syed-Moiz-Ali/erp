import 'dart:async';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';
import 'package:modular_erp/shared/transactions/domain/document_number.dart';
import 'package:modular_erp/shared/transactions/domain/document_number_service.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team_repository.dart';

class LocalServiceTeamRepository implements ServiceTeamRepository {
  LocalServiceTeamRepository(
    this.db,
    this.clock,
    this.numbers,
    this.activity,
    this.directory, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();
  final AppDatabase db;
  final AppClock clock;
  final DocumentNumberService numbers;
  final ActivityRepository activity;
  final WorkforceDirectory directory;
  final Uuid _uuid;

  Failure? _access(AuthContext context, {bool manage = false}) {
    final permission = manage
        ? AppPermission.serviceTeamManage
        : AppPermission.serviceTeamView;
    if (context.user.status != AccountStatus.active ||
        context.user.companyId != context.company.id ||
        !context.company.enabledModules.contains('services') ||
        !context.user.permissions.contains(permission)) {
      return const Failure(code: 'servicesTeamDenied');
    }
    return null;
  }

  ServiceTeam _record(QueryRow row) => ServiceTeam(
    id: row.read<String>('id'),
    companyId: row.read<String>('company_id'),
    teamCode: row.read<String>('team_code'),
    name: row.read<String>('name'),
    description: row.readNullable<String>('description'),
    leadEmployeeId: row.readNullable<String>('lead_employee_id'),
    status: ConfigurationStatus.values.byName(row.read<String>('status')),
    syncStatus: RecordSyncStatus.values.byName(row.read<String>('sync_status')),
    createdAt: row.read<DateTime>('created_at').toUtc(),
    updatedAt: row.read<DateTime>('updated_at').toUtc(),
    createdByUserId: row.read<String>('created_by_user_id'),
    updatedByUserId: row.read<String>('updated_by_user_id'),
  );

  @override
  Stream<Result<ServiceTeamPage>> watchTeams(
    AuthContext context, {
    String query = '',
    ConfigurationStatus? status,
    int page = 0,
    int pageSize = 10,
  }) {
    final failure = _access(context);
    if (failure != null) return Stream.value(Failed(failure));
    final parts = <String>['t.company_id=?'];
    final variables = <Variable>[Variable(context.company.id)];
    if (status != null) {
      parts.add('t.status=?');
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
        "(lower(t.name) LIKE ? ESCAPE '\\' OR lower(t.team_code) LIKE ? ESCAPE '\\')",
      );
      variables.addAll([for (var i = 0; i < 2; i++) Variable('%$escaped%')]);
    }
    return db
        .customSelect(
          'SELECT t.*, (SELECT COUNT(*) FROM service_team_members m WHERE m.company_id=t.company_id AND m.team_id=t.id AND m.status=\'active\') AS member_count '
          'FROM service_teams t WHERE ${parts.join(' AND ')} ORDER BY lower(t.name), t.id LIMIT ? OFFSET ?',
          variables: [
            ...variables,
            Variable(pageSize.clamp(1, 100)),
            Variable(page.clamp(0, 1000000) * pageSize.clamp(1, 100)),
          ],
          readsFrom: {db.serviceTeams, db.serviceTeamMembers},
        )
        .watch()
        .asyncMap<Result<ServiceTeamPage>>((rows) async {
          final leadIds = <String>{
            for (final row in rows)
              if (row.readNullable<String>('lead_employee_id') != null)
                row.readNullable<String>('lead_employee_id')!,
          };
          final leads = {
            for (final ref in await directory.getEmployees(leadIds))
              ref.id: ref,
          };
          final items = [
            for (final row in rows)
              ServiceTeamListItem(
                id: row.read<String>('id'),
                teamCode: row.read<String>('team_code'),
                name: row.read<String>('name'),
                leadName:
                    leads[row.readNullable<String>('lead_employee_id')]?.name,
                memberCount: row.read<int>('member_count'),
                status: ConfigurationStatus.values.byName(
                  row.read<String>('status'),
                ),
                updatedAt: row.read<DateTime>('updated_at').toUtc(),
              ),
          ];
          return Success(ServiceTeamPage(items, items.length, items.length));
        })
        .transform(
          StreamTransformer<
            Result<ServiceTeamPage>,
            Result<ServiceTeamPage>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceTeamPage>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  Future<ServiceTeam?> _raw(AuthContext context, String id) async {
    final row = await db
        .customSelect(
          'SELECT * FROM service_teams WHERE company_id=? AND id=?',
          variables: [Variable(context.company.id), Variable(id)],
        )
        .getSingleOrNull();
    return row == null ? null : _record(row);
  }

  @override
  Stream<Result<ServiceTeam?>> watchTeam(AuthContext context, String id) {
    final failure = _access(context);
    if (failure != null) return Stream.value(Failed(failure));
    return db
        .customSelect(
          'SELECT * FROM service_teams WHERE company_id=? AND id=?',
          variables: [Variable(context.company.id), Variable(id)],
          readsFrom: {db.serviceTeams},
        )
        .watchSingleOrNull()
        .map<Result<ServiceTeam?>>(
          (row) => Success(row == null ? null : _record(row)),
        )
        .transform(
          StreamTransformer<
            Result<ServiceTeam?>,
            Result<ServiceTeam?>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<ServiceTeam?>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  @override
  Future<Result<ServiceTeam?>> getTeam(AuthContext context, String id) async {
    final failure = _access(context);
    if (failure != null) return Failed(failure);
    try {
      return Success(await _raw(context, id));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Future<Result<ServiceTeam>> saveTeam(
    AuthContext context,
    ServiceTeamDraft draft, {
    String? id,
  }) async {
    final failure = _access(context, manage: true);
    if (failure != null) return Failed(failure);
    final name = draft.name.trim();
    if (name.isEmpty) {
      return const Failed(Failure(code: 'servicesTeamRequired'));
    }
    final members = {...draft.memberIds};
    final lead = draft.leadEmployeeId;
    if (lead != null && lead.isNotEmpty) members.add(lead);
    try {
      return Success(
        await db.transaction(() async {
          final now = clock.now();
          final previous = id == null ? null : await _raw(context, id);
          if (id != null && previous == null) {
            throw const _TeamException('servicesTeamNotFound');
          }
          final code =
              previous?.teamCode ?? await _nextCode(context.company.id);
          final teamId = id ?? _uuid.v4();
          final record = ServiceTeam(
            id: teamId,
            companyId: context.company.id,
            teamCode: code,
            name: name,
            description: _nullable(draft.description),
            leadEmployeeId: (lead == null || lead.isEmpty) ? null : lead,
            status: previous?.status ?? ConfigurationStatus.active,
            syncStatus: RecordSyncStatus.pending,
            createdAt: previous?.createdAt ?? now,
            updatedAt: now,
            createdByUserId: previous?.createdByUserId ?? context.user.id,
            updatedByUserId: context.user.id,
          );
          await db
              .into(db.serviceTeams)
              .insertOnConflictUpdate(
                ServiceTeamsCompanion.insert(
                  id: record.id,
                  companyId: record.companyId,
                  teamCode: record.teamCode,
                  name: record.name,
                  description: Value(record.description),
                  leadEmployeeId: Value(record.leadEmployeeId),
                  status: record.status.name,
                  createdAt: record.createdAt,
                  updatedAt: record.updatedAt,
                  createdByUserId: record.createdByUserId,
                  updatedByUserId: record.updatedByUserId,
                  syncStatus: record.syncStatus.name,
                ),
              );
          await (db.delete(db.serviceTeamMembers)..where(
                (t) =>
                    t.companyId.equals(context.company.id) &
                    t.teamId.equals(teamId),
              ))
              .go();
          for (final employeeId in members) {
            await db
                .into(db.serviceTeamMembers)
                .insert(
                  ServiceTeamMembersCompanion.insert(
                    id: _uuid.v4(),
                    companyId: context.company.id,
                    teamId: teamId,
                    employeeId: employeeId,
                    status: ConfigurationStatus.active.name,
                    createdAt: now,
                    createdByUserId: context.user.id,
                  ),
                  mode: InsertMode.insertOrIgnore,
                );
          }
          await _recordActivity(
            context,
            record,
            id == null
                ? 'services.team.created'
                : 'services.team.members.updated',
          );
          await _enqueue(
            context,
            record,
            id == null
                ? 'SERVICES_TEAM_CREATE'
                : 'SERVICES_TEAM_MEMBERS_UPDATE',
          );
          return record;
        }),
      );
    } on _TeamException catch (e) {
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
          throw const _TeamException('servicesTeamNotFound');
        }
        final status = active
            ? ConfigurationStatus.active
            : ConfigurationStatus.inactive;
        if (previous.status == status) return;
        final now = clock.now();
        await (db.update(db.serviceTeams)..where(
              (t) => t.id.equals(id) & t.companyId.equals(context.company.id),
            ))
            .write(
              ServiceTeamsCompanion(
                status: Value(status.name),
                updatedAt: Value(now),
                updatedByUserId: Value(context.user.id),
                syncStatus: const Value('pending'),
              ),
            );
        await _recordActivity(
          context,
          previous,
          active ? 'services.team.activated' : 'services.team.deactivated',
        );
        await _enqueue(context, previous, 'SERVICES_TEAM_UPDATE');
      });
      return const Success(null);
    } on _TeamException catch (e) {
      return Failed(Failure(code: e.code));
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Stream<Result<List<ServiceTeamMemberView>>> watchMembers(
    AuthContext context,
    String teamId,
  ) {
    final failure = _access(context);
    if (failure != null) return Stream.value(Failed(failure));
    return db
        .customSelect(
          "SELECT employee_id FROM service_team_members WHERE company_id=? AND team_id=? AND status='active' ORDER BY created_at",
          variables: [Variable(context.company.id), Variable(teamId)],
          readsFrom: {db.serviceTeamMembers},
        )
        .watch()
        .asyncMap<Result<List<ServiceTeamMemberView>>>((rows) async {
          final ids = [for (final row in rows) row.read<String>('employee_id')];
          final refs = await directory.getEmployees(ids);
          final byId = {for (final ref in refs) ref.id: ref};
          return Success([
            for (final id in ids)
              if (byId[id] case final ref?) memberView(ref),
          ]);
        })
        .transform(
          StreamTransformer<
            Result<List<ServiceTeamMemberView>>,
            Result<List<ServiceTeamMemberView>>
          >.fromHandlers(
            handleError:
                (
                  Object _,
                  StackTrace __,
                  EventSink<Result<List<ServiceTeamMemberView>>> sink,
                ) => sink.add(const Failed(Failure(code: 'servicesStorage'))),
          ),
        );
  }

  @override
  Future<Result<List<ServiceTeamRef>>> searchReferences(
    AuthContext context, {
    String query = '',
    int limit = 50,
  }) async {
    final failure = _access(context);
    if (failure != null) return Failed(failure);
    try {
      final rows = await db
          .customSelect(
            "SELECT id, team_code, name FROM service_teams WHERE company_id=? AND status='active' AND (lower(name) LIKE ? ESCAPE '\\' OR lower(team_code) LIKE ? ESCAPE '\\') ORDER BY lower(name) LIMIT ?",
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
          ServiceTeamRef(
            id: row.read<String>('id'),
            teamCode: row.read<String>('team_code'),
            displayName: row.read<String>('name'),
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

  Future<String> _nextCode(String companyId) async {
    final result = await numbers.nextNumber(
      companyId: companyId,
      type: DocumentSequenceType.serviceTeam,
    );
    return switch (result) {
      Success<String>(:final value) => value,
      Failed<String>() => throw const _TeamException('servicesStorage'),
    };
  }

  Future<void> _recordActivity(
    AuthContext context,
    ServiceTeam team,
    String eventType,
  ) => activity.append(
    BusinessActivityEvent(
      id: _uuid.v4(),
      companyId: context.company.id,
      moduleKey: 'services',
      entityType: 'serviceTeam',
      entityId: team.id,
      eventType: eventType,
      occurredAt: clock.now(),
      actorUserId: context.user.id,
      actorEmployeeId: context.employeeReference?.id,
      syncStatus: 'pending',
      metadata: {'teamCode': team.teamCode, 'name': team.name},
    ),
  );

  Future<void> _enqueue(
    AuthContext context,
    ServiceTeam team,
    String operation,
  ) => db
      .into(db.syncOutbox)
      .insert(
        SyncOutboxCompanion.insert(
          id: _uuid.v4(),
          moduleId: 'services',
          entityId: team.id,
          entityType: const Value('serviceTeam'),
          operation: operation,
          payload:
              '{"id":"${team.id}","code":"${team.teamCode}","name":"${team.name}"}',
          createdAt: team.updatedAt,
          companyId: Value(context.company.id),
        ),
        mode: InsertMode.insertOrIgnore,
      );
}

class _TeamException implements Exception {
  const _TeamException(this.code);
  final String code;
}
