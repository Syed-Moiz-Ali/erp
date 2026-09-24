import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team_repository.dart';

class ServiceTeamListState {
  const ServiceTeamListState({
    this.loading = true,
    this.page,
    this.failure,
    this.query = '',
    this.status,
  });
  final bool loading;
  final ServiceTeamPage? page;
  final String? failure;
  final String query;
  final ConfigurationStatus? status;
}

class ServiceTeamListCubit extends Cubit<ServiceTeamListState> {
  ServiceTeamListCubit(this.repository, this.context)
    : super(const ServiceTeamListState());
  final ServiceTeamRepository repository;
  final AuthContext context;
  StreamSubscription<Result<ServiceTeamPage>>? _sub;

  void start() => _subscribe();
  void search(String query) {
    emit(
      ServiceTeamListState(loading: true, query: query, status: state.status),
    );
    _subscribe();
  }

  void setStatus(ConfigurationStatus? status) {
    emit(
      ServiceTeamListState(loading: true, query: state.query, status: status),
    );
    _subscribe();
  }

  Future<Result<void>> setActive(String id, bool active) =>
      repository.setActive(context, id, active);

  void _subscribe() {
    unawaited(_sub?.cancel());
    _sub = repository
        .watchTeams(context, query: state.query, status: state.status)
        .listen((result) {
          switch (result) {
            case Success<ServiceTeamPage>(:final value):
              emit(
                ServiceTeamListState(
                  loading: false,
                  page: value,
                  query: state.query,
                  status: state.status,
                ),
              );
            case Failed<ServiceTeamPage>(:final failure):
              emit(
                ServiceTeamListState(
                  loading: false,
                  failure: failure.code,
                  query: state.query,
                  status: state.status,
                ),
              );
          }
        });
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}

class ServiceTeamDetailState {
  const ServiceTeamDetailState({
    this.loading = true,
    this.team,
    this.members = const [],
    this.failure,
  });
  final bool loading;
  final ServiceTeam? team;
  final List<ServiceTeamMemberView> members;
  final String? failure;
}

class ServiceTeamDetailCubit extends Cubit<ServiceTeamDetailState> {
  ServiceTeamDetailCubit(this.repository, this.context, this.id)
    : super(const ServiceTeamDetailState());
  final ServiceTeamRepository repository;
  final AuthContext context;
  final String id;
  StreamSubscription<Result<ServiceTeam?>>? _sub;
  StreamSubscription<Result<List<ServiceTeamMemberView>>>? _members;

  void start() {
    _sub = repository.watchTeam(context, id).listen((result) {
      switch (result) {
        case Success<ServiceTeam?>(:final value):
          emit(
            ServiceTeamDetailState(
              loading: false,
              team: value,
              members: state.members,
            ),
          );
        case Failed<ServiceTeam?>(:final failure):
          emit(
            ServiceTeamDetailState(
              loading: false,
              failure: failure.code,
              members: state.members,
            ),
          );
      }
    });
    _members = repository.watchMembers(context, id).listen((result) {
      if (result case Success<List<ServiceTeamMemberView>>(:final value)) {
        emit(
          ServiceTeamDetailState(
            loading: false,
            team: state.team,
            members: value,
            failure: state.failure,
          ),
        );
      }
    });
  }

  Future<Result<void>> setActive(bool active) =>
      repository.setActive(context, id, active);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _members?.cancel();
    return super.close();
  }
}

class ServiceTeamFormState {
  const ServiceTeamFormState({
    this.loading = false,
    this.saving = false,
    this.saved = false,
    this.failure,
    this.draft = const ServiceTeamDraft(),
    this.selected = const [],
    this.results = const [],
    this.searching = false,
  });
  final bool loading, saving, saved, searching;
  final String? failure;
  final ServiceTeamDraft draft;
  final List<WorkforcePersonRef> selected, results;

  ServiceTeamFormState copyWith({
    bool? loading,
    bool? saving,
    bool? saved,
    bool? searching,
    String? failure,
    bool clearFailure = false,
    ServiceTeamDraft? draft,
    List<WorkforcePersonRef>? selected,
    List<WorkforcePersonRef>? results,
  }) => ServiceTeamFormState(
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
    searching: searching ?? this.searching,
    failure: clearFailure ? null : (failure ?? this.failure),
    draft: draft ?? this.draft,
    selected: selected ?? this.selected,
    results: results ?? this.results,
  );
}

class ServiceTeamFormCubit extends Cubit<ServiceTeamFormState> {
  ServiceTeamFormCubit(this.repository, this.directory, this.context, this.id)
    : super(ServiceTeamFormState(loading: id != null));
  final ServiceTeamRepository repository;
  final WorkforceDirectory directory;
  final AuthContext context;
  final String? id;

  Future<void> init() async {
    if (id == null) {
      emit(const ServiceTeamFormState());
      return;
    }
    final result = await repository.getTeam(context, id!);
    if (result case Success<ServiceTeam?>(:final value)) {
      if (value == null) {
        emit(const ServiceTeamFormState(failure: 'servicesTeamNotFound'));
        return;
      }
      final members = await repository.watchMembers(context, id!).first;
      final refs = members is Success<List<ServiceTeamMemberView>>
          ? members.value
          : const <ServiceTeamMemberView>[];
      emit(
        ServiceTeamFormState(
          draft: ServiceTeamDraft(
            name: value.name,
            description: value.description ?? '',
            leadEmployeeId: value.leadEmployeeId,
            memberIds: [for (final m in refs) m.employeeId],
          ),
          selected: [
            for (final m in refs)
              WorkforcePersonRef(
                id: m.employeeId,
                name: m.name,
                employeeCode: m.employeeCode,
                designationId: m.designationId,
                departmentId: m.departmentId,
                isActive: m.isActive,
              ),
          ],
        ),
      );
    } else {
      emit(const ServiceTeamFormState(failure: 'servicesStorage'));
    }
  }

  void change(ServiceTeamDraft draft) =>
      emit(state.copyWith(draft: draft, clearFailure: true));

  Future<void> search(String query) async {
    emit(state.copyWith(searching: true));
    final results = await directory.searchAssignable(query: query, limit: 30);
    final selectedIds = state.draft.memberIds.toSet();
    emit(
      state.copyWith(
        searching: false,
        results: [
          for (final ref in results)
            if (!selectedIds.contains(ref.id)) ref,
        ],
      ),
    );
  }

  void addMember(WorkforcePersonRef ref) {
    if (state.draft.memberIds.contains(ref.id)) return;
    emit(
      state.copyWith(
        draft: state.draft.copyWith(
          memberIds: [...state.draft.memberIds, ref.id],
        ),
        selected: [...state.selected, ref],
        results: [
          for (final r in state.results)
            if (r.id != ref.id) r,
        ],
      ),
    );
  }

  void removeMember(String employeeId) {
    final draft = state.draft;
    emit(
      state.copyWith(
        draft: draft.copyWith(
          memberIds: [
            for (final id in draft.memberIds)
              if (id != employeeId) id,
          ],
          clearLead: draft.leadEmployeeId == employeeId,
        ),
        selected: [
          for (final ref in state.selected)
            if (ref.id != employeeId) ref,
        ],
      ),
    );
  }

  Future<void> save() async {
    emit(state.copyWith(saving: true, clearFailure: true));
    final result = await repository.saveTeam(context, state.draft, id: id);
    switch (result) {
      case Success<ServiceTeam>():
        emit(state.copyWith(saving: false, saved: true));
      case Failed<ServiceTeam>(:final failure):
        emit(state.copyWith(saving: false, failure: failure.code));
    }
  }
}
