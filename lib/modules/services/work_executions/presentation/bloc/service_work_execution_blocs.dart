import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/services/work_executions/application/service_work_execution_use_cases.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';

class ServiceWorkExecutionFilter {
  const ServiceWorkExecutionFilter({
    this.status,
    this.employeeId,
    this.teamId,
    this.dateFrom,
    this.dateTo,
  });
  final ServiceWorkExecutionStatus? status;
  final String? employeeId, teamId;
  final DateTime? dateFrom, dateTo;
  int get activeCount => [
    status,
    employeeId,
    teamId,
    dateFrom,
    dateTo,
  ].where((v) => v != null).length;

  ServiceWorkExecutionFilter copyWith({
    ServiceWorkExecutionStatus? status,
    bool clearStatus = false,
    String? employeeId,
    bool clearEmployee = false,
    String? teamId,
    bool clearTeam = false,
    DateTime? dateFrom,
    bool clearDateFrom = false,
    DateTime? dateTo,
    bool clearDateTo = false,
  }) => ServiceWorkExecutionFilter(
    status: clearStatus ? null : (status ?? this.status),
    employeeId: clearEmployee ? null : (employeeId ?? this.employeeId),
    teamId: clearTeam ? null : (teamId ?? this.teamId),
    dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
    dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
  );
}

class ServiceWorkExecutionListState {
  const ServiceWorkExecutionListState({
    this.loading = true,
    this.page,
    this.failure,
    this.query = '',
    this.filter = const ServiceWorkExecutionFilter(),
  });
  final bool loading;
  final ServiceWorkExecutionPage? page;
  final String? failure;
  final String query;
  final ServiceWorkExecutionFilter filter;

  ServiceWorkExecutionListState copyWith({
    bool? loading,
    ServiceWorkExecutionPage? page,
    String? failure,
    bool clearFailure = false,
    String? query,
    ServiceWorkExecutionFilter? filter,
  }) => ServiceWorkExecutionListState(
    loading: loading ?? this.loading,
    page: page ?? this.page,
    failure: clearFailure ? null : (failure ?? this.failure),
    query: query ?? this.query,
    filter: filter ?? this.filter,
  );
}

class ServiceWorkExecutionListCubit
    extends Cubit<ServiceWorkExecutionListState> {
  ServiceWorkExecutionListCubit(this.repository, this.context)
    : super(const ServiceWorkExecutionListState());
  final ServiceWorkExecutionRepository repository;
  final AuthContext context;
  StreamSubscription<Result<ServiceWorkExecutionPage>>? _sub;

  void start() => _subscribe();

  void search(String query) {
    emit(state.copyWith(loading: true, query: query, clearFailure: true));
    _subscribe();
  }

  void applyFilter(ServiceWorkExecutionFilter filter) {
    emit(state.copyWith(loading: true, filter: filter, clearFailure: true));
    _subscribe();
  }

  void clearFilters() => applyFilter(const ServiceWorkExecutionFilter());

  Future<Result<ServiceWorkExecution>> cancel(String id) =>
      CancelServiceWorkExecution(repository)(context, id);

  void _subscribe() {
    unawaited(_sub?.cancel());
    final filter = state.filter;
    _sub = repository
        .watchExecutions(
          context,
          query: state.query,
          status: filter.status,
          employeeId: filter.employeeId,
          teamId: filter.teamId,
          dateFrom: filter.dateFrom,
          dateTo: filter.dateTo,
        )
        .listen((result) {
          switch (result) {
            case Success<ServiceWorkExecutionPage>(:final value):
              emit(
                state.copyWith(loading: false, page: value, clearFailure: true),
              );
            case Failed<ServiceWorkExecutionPage>(:final failure):
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

class ServiceWorkExecutionDetailState {
  const ServiceWorkExecutionDetailState({
    this.loading = true,
    this.view,
    this.activity = const [],
    this.failure,
  });
  final bool loading;
  final ServiceWorkExecutionView? view;
  final List<BusinessActivityEvent> activity;
  final String? failure;
}

class ServiceWorkExecutionDetailCubit
    extends Cubit<ServiceWorkExecutionDetailState> {
  ServiceWorkExecutionDetailCubit(
    this.repository,
    this.activityRepository,
    this.context,
    this.id, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid(),
       super(const ServiceWorkExecutionDetailState());
  final ServiceWorkExecutionRepository repository;
  final ActivityRepository activityRepository;
  final AuthContext context;
  final String id;
  final Uuid _uuid;
  StreamSubscription<Result<ServiceWorkExecutionView?>>? _sub;
  StreamSubscription<List<BusinessActivityEvent>>? _activity;

  void start() {
    _sub = repository.watchExecution(context, id).listen((result) {
      switch (result) {
        case Success<ServiceWorkExecutionView?>(:final value):
          emit(
            ServiceWorkExecutionDetailState(
              loading: false,
              view: value,
              activity: state.activity,
            ),
          );
        case Failed<ServiceWorkExecutionView?>(:final failure):
          emit(
            ServiceWorkExecutionDetailState(
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
          entityType: 'serviceWorkExecution',
          entityId: id,
        )
        .listen(
          (events) => emit(
            ServiceWorkExecutionDetailState(
              loading: false,
              view: state.view,
              activity: events,
              failure: state.failure,
            ),
          ),
        );
  }

  Future<Result<ServiceWorkExecution>> startLine(String lineId) =>
      StartServiceWork(repository)(context, id, lineId);

  Future<Result<ServiceWorkExecution>> endLine(String lineId) =>
      EndServiceWork(repository)(context, id, lineId);

  Future<Result<ServiceWorkExecution>> addMaterialUsed({
    required String code,
    required String description,
    String? sourceMaterialRequestLineId,
  }) => repository.addMaterialUsed(
    context,
    id,
    ServiceWorkExecutionMaterialUsedDraft(
      id: _uuid.v4(),
      sourceMaterialRequestLineId: sourceMaterialRequestLineId,
      code: code,
      description: description,
    ),
  );

  Future<Result<ServiceWorkExecution>> removeMaterialUsed(String materialId) =>
      repository.removeMaterialUsed(context, id, materialId);

  Future<Result<ServiceWorkExecution>> addPhotoEntry({
    required String description,
    List<AttachmentRef> attachments = const [],
  }) => repository.addPhotoEntry(
    context,
    id,
    ServiceWorkExecutionPhotoEntryDraft(
      id: _uuid.v4(),
      description: description,
      attachments: attachments,
    ),
  );

  Future<Result<ServiceWorkExecution>> removePhotoEntry(String photoEntryId) =>
      repository.removePhotoEntry(context, id, photoEntryId);

  Future<Result<ServiceWorkExecution>> complete({String? requestId}) =>
      CompleteServiceWorkExecution(repository)(
        context,
        id,
        requestId: requestId,
      );

  Future<Result<ServiceWorkExecution>> cancel({String? requestId}) =>
      CancelServiceWorkExecution(repository)(context, id, requestId: requestId);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _activity?.cancel();
    return super.close();
  }
}

class ServiceWorkExecutionFormState {
  const ServiceWorkExecutionFormState({
    this.loading = false,
    this.saving = false,
    this.saved = false,
    this.savedId,
    this.failure,
    this.draft = const ServiceWorkExecutionDraft(),
    this.sourceContext,
  });
  final bool loading, saving, saved;
  final String? savedId, failure;
  final ServiceWorkExecutionDraft draft;
  final ServiceWorkExecutionSourceContext? sourceContext;

  ServiceWorkExecutionFormState copyWith({
    bool? loading,
    bool? saving,
    bool? saved,
    String? savedId,
    String? failure,
    bool clearFailure = false,
    ServiceWorkExecutionDraft? draft,
    ServiceWorkExecutionSourceContext? sourceContext,
    bool clearSourceContext = false,
  }) => ServiceWorkExecutionFormState(
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
    savedId: savedId ?? this.savedId,
    failure: clearFailure ? null : (failure ?? this.failure),
    draft: draft ?? this.draft,
    sourceContext: clearSourceContext
        ? null
        : (sourceContext ?? this.sourceContext),
  );
}

class ServiceWorkExecutionFormCubit
    extends Cubit<ServiceWorkExecutionFormState> {
  ServiceWorkExecutionFormCubit(
    this.repository,
    this.context,
    this.id, {
    this.initialInspectionId,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid(),
       super(ServiceWorkExecutionFormState(loading: id != null));
  final ServiceWorkExecutionRepository repository;
  final AuthContext context;
  final String? id;
  final String? initialInspectionId;
  final Uuid _uuid;

  Future<void> init() async {
    if (id == null) {
      if (initialInspectionId != null) {
        await _loadSource(initialInspectionId!, prefill: true);
      }
      if (isClosed) return;
      emit(state.copyWith(loading: false));
      return;
    }
    final result = await repository.getExecution(context, id!);
    switch (result) {
      case Success<ServiceWorkExecutionView?>(:final value):
        if (value == null) {
          emit(
            state.copyWith(
              loading: false,
              failure: 'servicesWorkExecutionNotFound',
            ),
          );
          return;
        }
        final e = value.execution;
        final source = await repository.getSourceContext(
          context,
          e.sourceInspectionId,
        );
        if (isClosed) return;
        emit(
          state.copyWith(
            loading: false,
            clearFailure: true,
            draft: ServiceWorkExecutionDraft(
              sourceInspectionId: e.sourceInspectionId,
              jobOrderReference: e.jobOrderReference ?? '',
              quotationReference: e.quotationReference ?? '',
              workLines: [
                for (final line in e.workLines)
                  ServiceWorkExecutionLineDraft(
                    id: line.id,
                    sourceJobAssignmentLineId: line.sourceJobAssignmentLineId,
                    work: line.work,
                    description: line.description,
                    serviceTeamId: line.serviceTeamId,
                    employeeId: line.employeeId,
                    startedAtUtc: line.startedAtUtc,
                    endedAtUtc: line.endedAtUtc,
                  ),
              ],
              materialsUsed: [
                for (final m in e.materialsUsed)
                  ServiceWorkExecutionMaterialUsedDraft(
                    id: m.id,
                    sourceMaterialRequestLineId: m.sourceMaterialRequestLineId,
                    code: m.code,
                    description: m.description,
                  ),
              ],
              afterWorkPhotoEntries: [
                for (final p in e.afterWorkPhotoEntries)
                  ServiceWorkExecutionPhotoEntryDraft(
                    id: p.id,
                    description: p.description,
                    attachments: p.attachments,
                  ),
              ],
            ),
            sourceContext: source is Success<ServiceWorkExecutionSourceContext?>
                ? source.value
                : null,
          ),
        );
      case Failed<ServiceWorkExecutionView?>():
        emit(state.copyWith(loading: false, failure: 'servicesStorage'));
    }
  }

  Future<List<ServiceWorkEligibleInspectionRef>> searchInspections(
    String query,
  ) async {
    final result = await repository.searchEligibleInspections(
      context,
      query: query,
    );
    return result is Success<List<ServiceWorkEligibleInspectionRef>>
        ? result.value
        : const [];
  }

  Future<void> _loadSource(String inspectionId, {bool prefill = false}) async {
    final result = await repository.getSourceContext(context, inspectionId);
    if (isClosed) return;
    final source = result is Success<ServiceWorkExecutionSourceContext?>
        ? result.value
        : null;
    emit(
      state.copyWith(
        sourceContext: source,
        draft: state.draft.copyWith(
          sourceInspectionId: inspectionId,
          workLines: prefill && source != null
              ? [
                  for (final line in source.jobAssignmentLines)
                    ServiceWorkExecutionLineDraft(
                      id: _uuid.v4(),
                      sourceJobAssignmentLineId: line.id,
                      work: line.work,
                      description: line.descriptionForWork,
                      serviceTeamId: line.assignedTeamId,
                      employeeId: line.assignedEmployeeId,
                    ),
                ]
              : state.draft.workLines,
        ),
        clearFailure: true,
      ),
    );
  }

  Future<void> selectInspection(ServiceWorkEligibleInspectionRef ref) =>
      _loadSource(ref.id, prefill: true);

  void clearInspection() => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        clearSourceInspection: true,
        workLines: const [],
      ),
      clearSourceContext: true,
    ),
  );

  void setJobOrderReference(String value) => emit(
    state.copyWith(
      draft: state.draft.copyWith(jobOrderReference: value),
      clearFailure: true,
    ),
  );

  void setQuotationReference(String value) => emit(
    state.copyWith(
      draft: state.draft.copyWith(quotationReference: value),
      clearFailure: true,
    ),
  );

  // Work lines.
  void addLine() => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        workLines: [
          ...state.draft.workLines,
          ServiceWorkExecutionLineDraft(id: _uuid.v4()),
        ],
      ),
    ),
  );

  bool _lineStarted(String lineId) {
    final line = id == null
        ? null
        : state.draft.workLines.where((l) => l.id == lineId).firstOrNull;
    return line?.startedAtUtc != null;
  }

  void removeLine(String lineId) {
    if (_lineStarted(lineId)) return;
    emit(
      state.copyWith(
        draft: state.draft.copyWith(
          workLines: [
            for (final line in state.draft.workLines)
              if (line.id != lineId) line,
          ],
        ),
      ),
    );
  }

  void _patchLine(
    String lineId,
    ServiceWorkExecutionLineDraft Function(ServiceWorkExecutionLineDraft) fn,
  ) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        workLines: [
          for (final line in state.draft.workLines)
            if (line.id == lineId) fn(line) else line,
        ],
      ),
      clearFailure: true,
    ),
  );

  void updateWork(String lineId, String value) =>
      _patchLine(lineId, (line) => line.copyWith(work: value));

  void updateDescription(String lineId, String value) =>
      _patchLine(lineId, (line) => line.copyWith(description: value));

  void selectLineTeam(String lineId, String teamId) =>
      _patchLine(lineId, (line) => line.copyWith(serviceTeamId: teamId));

  void clearLineTeam(String lineId) =>
      _patchLine(lineId, (line) => line.copyWith(clearTeam: true));

  void selectLineEmployee(String lineId, String employeeId) =>
      _patchLine(lineId, (line) => line.copyWith(employeeId: employeeId));

  void clearLineEmployee(String lineId) =>
      _patchLine(lineId, (line) => line.copyWith(clearEmployee: true));

  // Materials used.
  void addMaterial({String? sourceMaterialRequestLineId}) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        materialsUsed: [
          ...state.draft.materialsUsed,
          ServiceWorkExecutionMaterialUsedDraft(
            id: _uuid.v4(),
            sourceMaterialRequestLineId: sourceMaterialRequestLineId,
          ),
        ],
      ),
    ),
  );

  void addMaterialFromRequest(ServiceWorkMaterialRequestLineRef ref) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        materialsUsed: [
          ...state.draft.materialsUsed,
          ServiceWorkExecutionMaterialUsedDraft(
            id: _uuid.v4(),
            sourceMaterialRequestLineId: ref.id,
            code: ref.code,
            description: ref.description,
          ),
        ],
      ),
    ),
  );

  void removeMaterial(String materialId) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        materialsUsed: [
          for (final m in state.draft.materialsUsed)
            if (m.id != materialId) m,
        ],
      ),
    ),
  );

  void updateMaterialCode(String materialId, String value) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        materialsUsed: [
          for (final m in state.draft.materialsUsed)
            if (m.id == materialId) m.copyWith(code: value) else m,
        ],
      ),
      clearFailure: true,
    ),
  );

  void updateMaterialDescription(String materialId, String value) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        materialsUsed: [
          for (final m in state.draft.materialsUsed)
            if (m.id == materialId) m.copyWith(description: value) else m,
        ],
      ),
      clearFailure: true,
    ),
  );

  // After-work photos.
  void addPhotoEntry() => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        afterWorkPhotoEntries: [
          ...state.draft.afterWorkPhotoEntries,
          ServiceWorkExecutionPhotoEntryDraft(id: _uuid.v4()),
        ],
      ),
    ),
  );

  void removePhotoEntry(String entryId) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        afterWorkPhotoEntries: [
          for (final p in state.draft.afterWorkPhotoEntries)
            if (p.id != entryId) p,
        ],
      ),
    ),
  );

  void updatePhotoDescription(String entryId, String value) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        afterWorkPhotoEntries: [
          for (final p in state.draft.afterWorkPhotoEntries)
            if (p.id == entryId) p.copyWith(description: value) else p,
        ],
      ),
      clearFailure: true,
    ),
  );

  void addPhotoAttachments(String entryId, List<AttachmentRef> refs) {
    if (refs.isEmpty) return;
    emit(
      state.copyWith(
        draft: state.draft.copyWith(
          afterWorkPhotoEntries: [
            for (final p in state.draft.afterWorkPhotoEntries)
              if (p.id == entryId)
                p.copyWith(attachments: [...p.attachments, ...refs])
              else
                p,
          ],
        ),
      ),
    );
  }

  void removePhotoAttachment(String entryId, String attachmentId) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        afterWorkPhotoEntries: [
          for (final p in state.draft.afterWorkPhotoEntries)
            if (p.id == entryId)
              p.copyWith(
                attachments: [
                  for (final a in p.attachments)
                    if (a.id != attachmentId) a,
                ],
              )
            else
              p,
        ],
      ),
    ),
  );

  void resetForm() => emit(
    ServiceWorkExecutionFormState(
      loading: false,
      sourceContext: state.sourceContext,
    ),
  );

  Future<void> save() async {
    emit(state.copyWith(saving: true, clearFailure: true));
    final draft = state.draft;
    final result = id == null
        ? await CreateServiceWorkExecution(repository)(context, draft)
        : await UpdateServiceWorkExecution(repository)(context, id!, draft);
    switch (result) {
      case Success<ServiceWorkExecution>(:final value):
        emit(state.copyWith(saving: false, saved: true, savedId: value.id));
      case Failed<ServiceWorkExecution>(:final failure):
        emit(state.copyWith(saving: false, failure: failure.code));
    }
  }
}
