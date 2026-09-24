import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master_repository.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/job_assignments/application/service_job_assignment_use_cases.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment_repository.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';

class ServiceJobAssignmentFilter {
  const ServiceJobAssignmentFilter({
    this.status,
    this.priorityId,
    this.visitFrom,
    this.visitTo,
  });
  final ServiceJobAssignmentStatus? status;
  final String? priorityId;
  final DateTime? visitFrom, visitTo;

  int get activeCount =>
      [status, priorityId, visitFrom, visitTo].where((v) => v != null).length;

  ServiceJobAssignmentFilter copyWith({
    ServiceJobAssignmentStatus? status,
    bool clearStatus = false,
    String? priorityId,
    bool clearPriority = false,
    DateTime? visitFrom,
    bool clearVisitFrom = false,
    DateTime? visitTo,
    bool clearVisitTo = false,
  }) => ServiceJobAssignmentFilter(
    status: clearStatus ? null : (status ?? this.status),
    priorityId: clearPriority ? null : (priorityId ?? this.priorityId),
    visitFrom: clearVisitFrom ? null : (visitFrom ?? this.visitFrom),
    visitTo: clearVisitTo ? null : (visitTo ?? this.visitTo),
  );
}

class ServiceJobAssignmentListState {
  const ServiceJobAssignmentListState({
    this.loading = true,
    this.referencesLoading = true,
    this.page,
    this.failure,
    this.query = '',
    this.filter = const ServiceJobAssignmentFilter(),
    this.priorities = const [],
  });
  final bool loading, referencesLoading;
  final ServiceJobAssignmentPage? page;
  final String? failure;
  final String query;
  final ServiceJobAssignmentFilter filter;
  final List<ServiceMasterRecord> priorities;

  ServiceJobAssignmentListState copyWith({
    bool? loading,
    bool? referencesLoading,
    ServiceJobAssignmentPage? page,
    String? failure,
    bool clearFailure = false,
    String? query,
    ServiceJobAssignmentFilter? filter,
    List<ServiceMasterRecord>? priorities,
  }) => ServiceJobAssignmentListState(
    loading: loading ?? this.loading,
    referencesLoading: referencesLoading ?? this.referencesLoading,
    page: page ?? this.page,
    failure: clearFailure ? null : (failure ?? this.failure),
    query: query ?? this.query,
    filter: filter ?? this.filter,
    priorities: priorities ?? this.priorities,
  );
}

class ServiceJobAssignmentListCubit
    extends Cubit<ServiceJobAssignmentListState> {
  ServiceJobAssignmentListCubit(this.repository, this.masters, this.context)
    : super(const ServiceJobAssignmentListState());
  final ServiceJobAssignmentRepository repository;
  final ServiceMasterRepository masters;
  final AuthContext context;
  StreamSubscription<Result<ServiceJobAssignmentPage>>? _sub;

  void start() {
    _loadReferences();
    _subscribe();
  }

  Future<void> _loadReferences() async {
    final result = await masters
        .watchList(
          ServiceMasterKind.priority,
          context,
          status: ConfigurationStatus.active,
          pageSize: 100,
        )
        .first;
    if (isClosed) return;
    emit(
      state.copyWith(
        referencesLoading: false,
        priorities: result is Success<ServiceMasterPage>
            ? result.value.items
            : const [],
      ),
    );
  }

  void search(String query) {
    emit(state.copyWith(loading: true, query: query, clearFailure: true));
    _subscribe();
  }

  void applyFilter(ServiceJobAssignmentFilter filter) {
    emit(state.copyWith(loading: true, filter: filter, clearFailure: true));
    _subscribe();
  }

  void clearFilters() => applyFilter(const ServiceJobAssignmentFilter());

  Future<Result<void>> cancel(String id) =>
      CancelServiceJobAssignment(repository)(context, id);

  void _subscribe() {
    unawaited(_sub?.cancel());
    final filter = state.filter;
    _sub = repository
        .watchAssignments(
          context,
          query: state.query,
          status: filter.status,
          priorityId: filter.priorityId,
          visitFrom: filter.visitFrom,
          visitTo: filter.visitTo,
        )
        .listen((result) {
          switch (result) {
            case Success<ServiceJobAssignmentPage>(:final value):
              emit(
                state.copyWith(loading: false, page: value, clearFailure: true),
              );
            case Failed<ServiceJobAssignmentPage>(:final failure):
              emit(state.copyWith(loading: false, failure: failure.code));
          }
        });
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}

class ServiceJobAssignmentDetailState {
  const ServiceJobAssignmentDetailState({
    this.loading = true,
    this.view,
    this.activity = const [],
    this.failure,
  });
  final bool loading;
  final ServiceJobAssignmentView? view;
  final List<BusinessActivityEvent> activity;
  final String? failure;
}

class ServiceJobAssignmentDetailCubit
    extends Cubit<ServiceJobAssignmentDetailState> {
  ServiceJobAssignmentDetailCubit(
    this.repository,
    this.activityRepository,
    this.context,
    this.id,
  ) : super(const ServiceJobAssignmentDetailState());
  final ServiceJobAssignmentRepository repository;
  final ActivityRepository activityRepository;
  final AuthContext context;
  final String id;

  StreamSubscription<Result<ServiceJobAssignmentView?>>? _sub;
  StreamSubscription<List<BusinessActivityEvent>>? _activity;

  void start() {
    _sub = repository.watchAssignment(context, id).listen((result) {
      switch (result) {
        case Success<ServiceJobAssignmentView?>(:final value):
          emit(
            ServiceJobAssignmentDetailState(
              loading: false,
              view: value,
              activity: state.activity,
            ),
          );
        case Failed<ServiceJobAssignmentView?>(:final failure):
          emit(
            ServiceJobAssignmentDetailState(
              loading: false,
              failure: failure.code,
              activity: state.activity,
            ),
          );
      }
    });
    _activity = activityRepository
        .watchForEntity(
          companyId: context.company.id,
          entityType: 'serviceJobAssignment',
          entityId: id,
        )
        .listen(
          (events) => emit(
            ServiceJobAssignmentDetailState(
              loading: false,
              view: state.view,
              activity: events,
              failure: state.failure,
            ),
          ),
        );
  }

  Future<Result<void>> cancel({String? reason, String? requestId}) =>
      CancelServiceJobAssignment(repository)(
        context,
        id,
        reason: reason,
        requestId: requestId,
      );

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _activity?.cancel();
    return super.close();
  }
}

class ServiceJobAssignmentFormState {
  const ServiceJobAssignmentFormState({
    this.loading = false,
    this.saving = false,
    this.saved = false,
    this.savedId,
    this.failure,
    this.draft = const ServiceJobAssignmentDraft(),
    this.enquiryContext,
    this.employeeNames = const {},
    this.teamNames = const {},
    this.assignmentNumber,
    this.assignmentDate,
  });
  final bool loading, saving, saved;
  final String? savedId, failure;
  final ServiceJobAssignmentDraft draft;
  final ServiceAssignableEnquiryContext? enquiryContext;
  final Map<String, String> employeeNames, teamNames;
  final String? assignmentNumber;
  final DateTime? assignmentDate;

  List<ServiceJobAssignmentLineDraft> get lines => draft.lines;

  ServiceJobAssignmentFormState copyWith({
    bool? loading,
    bool? saving,
    bool? saved,
    String? savedId,
    String? failure,
    bool clearFailure = false,
    ServiceJobAssignmentDraft? draft,
    ServiceAssignableEnquiryContext? enquiryContext,
    bool clearEnquiryContext = false,
    Map<String, String>? employeeNames,
    Map<String, String>? teamNames,
    String? assignmentNumber,
    DateTime? assignmentDate,
  }) => ServiceJobAssignmentFormState(
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
    savedId: savedId ?? this.savedId,
    failure: clearFailure ? null : (failure ?? this.failure),
    draft: draft ?? this.draft,
    enquiryContext: clearEnquiryContext
        ? null
        : (enquiryContext ?? this.enquiryContext),
    employeeNames: employeeNames ?? this.employeeNames,
    teamNames: teamNames ?? this.teamNames,
    assignmentNumber: assignmentNumber ?? this.assignmentNumber,
    assignmentDate: assignmentDate ?? this.assignmentDate,
  );
}

class ServiceJobAssignmentFormCubit
    extends Cubit<ServiceJobAssignmentFormState> {
  ServiceJobAssignmentFormCubit(
    this.repository,
    this.workforce,
    this.teams,
    this.context,
    this.id, {
    this.initialEnquiryId,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid(),
       super(ServiceJobAssignmentFormState(loading: id != null));
  final ServiceJobAssignmentRepository repository;
  final WorkforceDirectory workforce;
  final ServiceTeamRepository teams;
  final AuthContext context;
  final String? id;
  final String? initialEnquiryId;
  final Uuid _uuid;

  ServiceJobAssignmentLineDraft _newLine() =>
      ServiceJobAssignmentLineDraft(id: _uuid.v4());

  Future<void> init() async {
    if (id == null) {
      if (initialEnquiryId != null) {
        await _loadEnquiry(initialEnquiryId!);
      }
      if (isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          draft: state.draft.lines.isEmpty
              ? state.draft.copyWith(lines: [_newLine()])
              : state.draft,
        ),
      );
      return;
    }
    final result = await repository.getAssignment(context, id!);
    switch (result) {
      case Success<ServiceJobAssignmentView?>(:final value):
        if (value == null) {
          emit(
            state.copyWith(
              loading: false,
              failure: 'servicesJobAssignmentNotFound',
            ),
          );
          return;
        }
        final employeeIds = [
          for (final line in value.assignment.lines)
            if (line.assignedEmployeeId != null) line.assignedEmployeeId!,
        ];
        final teamIds = [
          for (final line in value.assignment.lines)
            if (line.assignedTeamId != null) line.assignedTeamId!,
        ];
        final employeeRefs = await workforce.getEmployees(employeeIds);
        final teamRefs = await teams.getReferences(context, teamIds);
        if (isClosed) return;
        emit(
          state.copyWith(
            loading: false,
            clearFailure: true,
            assignmentNumber: value.assignment.assignmentNumber,
            assignmentDate: value.assignment.assignmentDate,
            draft: ServiceJobAssignmentDraft(
              sourceEnquiryId: value.assignment.sourceEnquiryId,
              scheduledVisitDate: value.assignment.scheduledVisitDate,
              lines: [
                for (final line in value.assignment.lines)
                  ServiceJobAssignmentLineDraft(
                    id: line.id,
                    work: line.work,
                    assignedEmployeeId: line.assignedEmployeeId,
                    assignedTeamId: line.assignedTeamId,
                    status: line.status,
                    descriptionForWork: line.descriptionForWork,
                  ),
              ],
            ),
            enquiryContext: await _contextFor(value.assignment.sourceEnquiryId),
            employeeNames: {for (final ref in employeeRefs) ref.id: ref.name},
            teamNames: {
              if (teamRefs is Success<List<ServiceTeamRef>>)
                for (final ref in teamRefs.value) ref.id: ref.displayName,
            },
          ),
        );
      case Failed<ServiceJobAssignmentView?>():
        emit(state.copyWith(loading: false, failure: 'servicesStorage'));
    }
  }

  Future<ServiceAssignableEnquiryContext?> _contextFor(String enquiryId) async {
    final result = await repository.getAssignableEnquiryContext(
      context,
      enquiryId,
    );
    return result is Success<ServiceAssignableEnquiryContext?>
        ? result.value
        : null;
  }

  Future<void> _loadEnquiry(String enquiryId) async {
    final context = await _contextFor(enquiryId);
    if (isClosed) return;
    emit(
      state.copyWith(
        draft: state.draft.copyWith(sourceEnquiryId: enquiryId),
        enquiryContext: context,
        clearFailure: true,
      ),
    );
  }

  Future<List<ServiceAssignableEnquiryRef>> searchEnquiries(
    String query,
  ) async {
    final result = await repository.searchAssignableEnquiries(
      context,
      query: query,
    );
    return result is Success<List<ServiceAssignableEnquiryRef>>
        ? result.value
        : const [];
  }

  Future<List<WorkforcePersonRef>> searchEmployees(String query) =>
      workforce.searchAssignable(query: query, limit: 30);

  Future<List<ServiceTeamRef>> searchTeams(String query) async {
    final result = await teams.searchReferences(context, query: query);
    return result is Success<List<ServiceTeamRef>> ? result.value : const [];
  }

  Future<void> selectEnquiry(ServiceAssignableEnquiryRef ref) async {
    await _loadEnquiry(ref.id);
  }

  void clearEnquiry() => emit(
    state.copyWith(
      draft: state.draft.copyWith(clearSourceEnquiry: true),
      clearEnquiryContext: true,
    ),
  );

  void setVisitDate(DateTime value) => emit(
    state.copyWith(draft: state.draft.copyWith(scheduledVisitDate: value)),
  );

  void addLine() => emit(
    state.copyWith(
      draft: state.draft.copyWith(lines: [...state.draft.lines, _newLine()]),
    ),
  );

  void removeLine(String lineId) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        lines: [
          for (final line in state.draft.lines)
            if (line.id != lineId) line,
        ],
      ),
    ),
  );

  void updateWork(String lineId, String value) =>
      _patch(lineId, (line) => line.copyWith(work: value));

  void updateDescription(String lineId, String value) =>
      _patch(lineId, (line) => line.copyWith(descriptionForWork: value));

  void updateLineStatus(String lineId, ServiceJobAssignmentLineStatus status) =>
      _patch(lineId, (line) => line.copyWith(status: status));

  void selectEmployee(String lineId, WorkforcePersonRef ref) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        lines: [
          for (final line in state.draft.lines)
            if (line.id == lineId)
              line.copyWith(assignedEmployeeId: ref.id)
            else
              line,
        ],
      ),
      employeeNames: {...state.employeeNames, ref.id: ref.name},
      clearFailure: true,
    ),
  );

  void clearEmployee(String lineId) =>
      _patch(lineId, (line) => line.copyWith(clearEmployee: true));

  void selectTeam(String lineId, ServiceTeamRef ref) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        lines: [
          for (final line in state.draft.lines)
            if (line.id == lineId)
              line.copyWith(assignedTeamId: ref.id)
            else
              line,
        ],
      ),
      teamNames: {...state.teamNames, ref.id: ref.displayName},
      clearFailure: true,
    ),
  );

  void clearTeam(String lineId) =>
      _patch(lineId, (line) => line.copyWith(clearTeam: true));

  void _patch(
    String lineId,
    ServiceJobAssignmentLineDraft Function(ServiceJobAssignmentLineDraft) fn,
  ) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        lines: [
          for (final line in state.draft.lines)
            if (line.id == lineId) fn(line) else line,
        ],
      ),
      clearFailure: true,
    ),
  );

  Future<void> save() async {
    emit(state.copyWith(saving: true, clearFailure: true));
    final draft = state.draft;
    final result = id == null
        ? await CreateServiceJobAssignment(repository)(context, draft)
        : await UpdateServiceJobAssignment(repository)(context, id!, draft);
    switch (result) {
      case Success<ServiceJobAssignment>(:final value):
        emit(state.copyWith(saving: false, saved: true, savedId: value.id));
      case Failed<ServiceJobAssignment>(:final failure):
        emit(state.copyWith(saving: false, failure: failure.code));
    }
  }
}
