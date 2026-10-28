import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/permission_catalog.dart';
import 'package:modular_erp/core/security/permission_definition.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/grant_authority.dart';
import 'package:modular_erp/platform/access/domain/user_permission_grant.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';

class UserAccessState {
  const UserAccessState({
    this.loading = true,
    this.failureCode,
    this.failureMessage,
    this.user,
    this.grants = const [],
    this.draft = const [],
    this.history = const [],
    this.orphans = const [],
    this.saving = false,
    this.saved = false,
    this.isLastAccessAdmin = false,
  });
  final bool loading, saving, saved, isLastAccessAdmin;
  final String? failureCode;
  final String? failureMessage;
  final AccessUserListItem? user;
  final List<PermissionGrantInput> grants, draft;
  final List<BusinessActivityEvent> history;
  final List<UserPermissionGrant> orphans;

  bool get dirty => !setEquals(grants.toSet(), draft.toSet());
  bool get hasEmployeeLink =>
      user?.employeeId != null && user!.isEmployeeActive;

  PermissionGrantInput? grantFor(String key) =>
      draft.where((g) => g.key == key).firstOrNull;

  UserAccessState copyWith({
    bool? loading,
    String? failureCode,
    String? failureMessage,
    bool clearFailure = false,
    AccessUserListItem? user,
    List<PermissionGrantInput>? grants,
    List<PermissionGrantInput>? draft,
    List<BusinessActivityEvent>? history,
    List<UserPermissionGrant>? orphans,
    bool? saving,
    bool? saved,
    bool? isLastAccessAdmin,
  }) => UserAccessState(
    loading: loading ?? this.loading,
    failureCode: clearFailure ? null : (failureCode ?? this.failureCode),
    failureMessage: clearFailure
        ? null
        : (failureMessage ?? this.failureMessage),
    user: user ?? this.user,
    grants: grants ?? this.grants,
    draft: draft ?? this.draft,
    history: history ?? this.history,
    orphans: orphans ?? this.orphans,
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
    isLastAccessAdmin: isLastAccessAdmin ?? this.isLastAccessAdmin,
  );
}

/// Owns the loaded catalog, current grants, draft grants, dirty state and save.
/// Widgets never compute effective grants.
class UserAccessCubit extends Cubit<UserAccessState> {
  UserAccessCubit({
    required this.catalog,
    required this.repository,
    required this.authority,
    required this.actor,
    required this.userId,
    this.onCurrentUserAccessChanged,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid(),
       super(const UserAccessState());
  final PermissionCatalog catalog;
  final AccessRepository repository;
  final GrantAuthorityResolver authority;
  final AuthContext actor;
  final String userId;
  final Future<void> Function()? onCurrentUserAccessChanged;
  final Uuid _uuid;

  StreamSubscription<List<UserPermissionGrant>>? _grantsSub;
  StreamSubscription<List<BusinessActivityEvent>>? _historySub;
  StreamSubscription<List<UserPermissionGrant>>? _companySub;
  StreamSubscription<List<AccessUserListItem>>? _usersSub;
  bool _initialized = false;

  String get companyId => actor.company.id;
  Set<String> get enabledModules => actor.company.enabledModules;

  /// View permission without manage permission renders a read-only editor.
  bool get canManage => authority.canManageAccess(actor).allowed;

  void start() {
    _usersSub = repository.watchUsers(companyId: companyId).listen((users) {
      final user = users.where((u) => u.userId == userId).firstOrNull;
      if (user != null) emit(state.copyWith(user: user));
    });
    _companySub = repository
        .watchCompanyGrants(companyId: companyId)
        .listen(_onCompanyGrants);
    _grantsSub = repository
        .watchGrants(companyId: companyId, userId: userId)
        .listen(_onGrants);
    _historySub = repository
        .watchHistory(companyId: companyId, userId: userId)
        .listen((history) => emit(state.copyWith(history: history)));
  }

  void _onCompanyGrants(List<UserPermissionGrant> grants) {
    final admins = grants
        .where((g) => g.permissionKey == 'company.access.permissions.manage')
        .map((g) => g.userId)
        .toSet();
    emit(
      state.copyWith(
        isLastAccessAdmin: admins.length == 1 && admins.contains(userId),
      ),
    );
  }

  void _onGrants(List<UserPermissionGrant> grants) {
    final active = grants.where((grant) => !grant.isOrphan);
    final inputs = [
      for (final grant in active)
        PermissionGrantInput(key: grant.permissionKey, scope: grant.scope),
    ];
    emit(
      state.copyWith(
        loading: false,
        grants: inputs,
        draft: _initialized ? state.draft : inputs,
        orphans: grants.where((grant) => grant.isOrphan).toList(),
      ),
    );
    _initialized = true;
  }

  void setUser(AccessUserListItem user) => emit(state.copyWith(user: user));

  void setScope(PermissionDefinition definition, PermissionScope scope) {
    final draft = [
      for (final grant in state.draft)
        if (grant.key != definition.key) grant,
      if (scope != PermissionScope.none || _isActionOnly(definition))
        PermissionGrantInput(key: definition.key, scope: scope),
    ];
    emit(state.copyWith(draft: draft, saved: false));
  }

  void toggleAction(PermissionDefinition definition, bool granted) {
    final scope = definition.supportedScopes.first;
    final draft = [
      for (final grant in state.draft)
        if (grant.key != definition.key) grant,
      if (granted) PermissionGrantInput(key: definition.key, scope: scope),
    ];
    emit(state.copyWith(draft: draft, saved: false));
  }

  bool _isActionOnly(PermissionDefinition definition) =>
      definition.supportedScopes.length == 1 &&
      definition.supportedScopes.first == PermissionScope.none;

  int grantedCount(String moduleId) => state.draft
      .where((grant) => catalog.byKey(grant.key)?.moduleId == moduleId)
      .length;

  PermissionScope _broadestScope(PermissionDefinition definition) {
    final scopes = definition.supportedScopes;
    if (scopes.contains(PermissionScope.all)) return PermissionScope.all;
    if (scopes.contains(PermissionScope.team)) return PermissionScope.team;
    if (scopes.contains(PermissionScope.self)) return PermissionScope.self;
    return PermissionScope.none;
  }

  PermissionScope _viewScope(PermissionDefinition definition) {
    final scopes = definition.supportedScopes;
    if (scopes.contains(PermissionScope.team)) return PermissionScope.team;
    if (scopes.contains(PermissionScope.self)) return PermissionScope.self;
    if (scopes.contains(PermissionScope.all)) return PermissionScope.all;
    return PermissionScope.none;
  }

  /// Quick module assignment: `full` grants every delegable permission, otherwise
  /// only read/view baseline permissions. Both respect the delegation ceiling.
  void grantModule(String moduleId, {required bool full}) {
    final module = catalog.modules.where((m) => m.id == moduleId).firstOrNull;
    if (module == null) return;
    final draft = [
      for (final grant in state.draft)
        if (catalog.byKey(grant.key)?.moduleId != moduleId) grant,
    ];
    for (final definition in module.definitions) {
      if (!canGrant(definition).allowed) continue;
      if (definition.requiresEmployeeLink && !state.hasEmployeeLink) continue;
      final isBaseline = definition.key.toLowerCase().endsWith('view');
      if (!full && !isBaseline) continue;
      draft.add(
        PermissionGrantInput(
          key: definition.key,
          scope: full ? _broadestScope(definition) : _viewScope(definition),
        ),
      );
    }
    emit(state.copyWith(draft: draft, saved: false));
  }

  void clearModule(String moduleId) {
    final draft = [
      for (final grant in state.draft)
        if (catalog.byKey(grant.key)?.moduleId != moduleId) grant,
    ];
    emit(state.copyWith(draft: draft, saved: false));
  }

  void reset() => emit(state.copyWith(draft: state.grants, saved: false));

  AccessDecision canGrant(PermissionDefinition definition) =>
      authority.canGrant(
        actor,
        definition,
        targetHasEmployeeLink: state.hasEmployeeLink,
        moduleEnabled:
            definition.moduleId == 'platform' ||
            enabledModules.contains(definition.requiredFeature),
      );

  Future<bool> save() async {
    final validation = authority.validateReplacement(
      actor,
      targetUserId: userId,
      grants: state.draft,
      catalog: catalog,
      enabledModules: enabledModules,
      targetHasEmployeeLink: state.hasEmployeeLink,
      targetIsLastAccessAdmin: state.isLastAccessAdmin,
    );
    if (validation is Failed<void>) {
      emit(state.copyWith(failureCode: validation.failure.code));
      return false;
    }
    emit(state.copyWith(saving: true, clearFailure: true));
    final result = await repository.replaceGrants(
      companyId: companyId,
      actorUserId: actor.user.id,
      targetUserId: userId,
      requestId: _uuid.v4(),
      grants: state.draft,
    );
    if (result is Success<void>) {
      emit(state.copyWith(saving: false, saved: true, grants: state.draft));
      await onCurrentUserAccessChanged?.call();
      return true;
    }
    emit(
      state.copyWith(
        saving: false,
        failureCode: result is Failed<void>
            ? result.failure.code
            : 'accessSaveFailed',
        failureMessage: result is Failed<void>
            ? result.failure.serverMessage
            : null,
      ),
    );
    return false;
  }

  /// Additive assignment (POST). Keeps existing grants.
  Future<bool> assignAdditive(List<PermissionGrantInput> grants) async {
    if (grants.isEmpty) return false;
    emit(state.copyWith(saving: true, clearFailure: true));
    final result = await repository.assignGrants(
      companyId: companyId,
      actorUserId: actor.user.id,
      targetUserId: userId,
      requestId: _uuid.v4(),
      grants: grants,
    );
    if (result is Success<void>) {
      emit(state.copyWith(saving: false, saved: true));
      await onCurrentUserAccessChanged?.call();
      return true;
    }
    emit(
      state.copyWith(
        saving: false,
        failureCode: result is Failed<void>
            ? result.failure.code
            : 'accessSaveFailed',
        failureMessage: result is Failed<void>
            ? result.failure.serverMessage
            : null,
      ),
    );
    return false;
  }

  Future<void> revokeOrphan(UserPermissionGrant grant) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true, clearFailure: true));
    final result = await repository.revokeGrant(
      companyId: companyId,
      targetUserId: userId,
      grantId: grant.id,
    );
    if (result is Success<void>) {
      emit(
        state.copyWith(
          saving: false,
          saved: true,
          orphans: state.orphans
              .where((row) => row.id != grant.id)
              .toList(growable: false),
        ),
      );
      await onCurrentUserAccessChanged?.call();
      return;
    }
    emit(
      state.copyWith(
        saving: false,
        failureCode: result is Failed<void>
            ? result.failure.code
            : 'accessSaveFailed',
        failureMessage: result is Failed<void>
            ? result.failure.serverMessage
            : null,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _usersSub?.cancel();
    await _grantsSub?.cancel();
    await _historySub?.cancel();
    await _companySub?.cancel();
    return super.close();
  }
}
