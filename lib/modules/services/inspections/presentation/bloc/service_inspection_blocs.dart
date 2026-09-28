import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master_repository.dart';
import 'package:modular_erp/modules/services/inspections/application/service_inspection_use_cases.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';

class ServiceInspectionFilter {
  const ServiceInspectionFilter({
    this.status,
    this.priorityId,
    this.rootCauseId,
    this.visitFrom,
    this.visitTo,
  });
  final ServiceInspectionStatus? status;
  final String? priorityId, rootCauseId;
  final DateTime? visitFrom, visitTo;
  int get activeCount => [
    status,
    priorityId,
    rootCauseId,
    visitFrom,
    visitTo,
  ].where((v) => v != null).length;

  ServiceInspectionFilter copyWith({
    ServiceInspectionStatus? status,
    bool clearStatus = false,
    String? priorityId,
    bool clearPriority = false,
    String? rootCauseId,
    bool clearRootCause = false,
    DateTime? visitFrom,
    bool clearVisitFrom = false,
    DateTime? visitTo,
    bool clearVisitTo = false,
  }) => ServiceInspectionFilter(
    status: clearStatus ? null : (status ?? this.status),
    priorityId: clearPriority ? null : (priorityId ?? this.priorityId),
    rootCauseId: clearRootCause ? null : (rootCauseId ?? this.rootCauseId),
    visitFrom: clearVisitFrom ? null : (visitFrom ?? this.visitFrom),
    visitTo: clearVisitTo ? null : (visitTo ?? this.visitTo),
  );
}

class ServiceInspectionListState {
  const ServiceInspectionListState({
    this.loading = true,
    this.page,
    this.failure,
    this.query = '',
    this.filter = const ServiceInspectionFilter(),
    this.priorities = const [],
    this.rootCauses = const [],
  });
  final bool loading;
  final ServiceInspectionPage? page;
  final String? failure;
  final String query;
  final ServiceInspectionFilter filter;
  final List<ServiceMasterRecord> priorities, rootCauses;

  ServiceInspectionListState copyWith({
    bool? loading,
    ServiceInspectionPage? page,
    String? failure,
    bool clearFailure = false,
    String? query,
    ServiceInspectionFilter? filter,
    List<ServiceMasterRecord>? priorities,
    List<ServiceMasterRecord>? rootCauses,
  }) => ServiceInspectionListState(
    loading: loading ?? this.loading,
    page: page ?? this.page,
    failure: clearFailure ? null : (failure ?? this.failure),
    query: query ?? this.query,
    filter: filter ?? this.filter,
    priorities: priorities ?? this.priorities,
    rootCauses: rootCauses ?? this.rootCauses,
  );
}

class ServiceInspectionListCubit extends Cubit<ServiceInspectionListState> {
  ServiceInspectionListCubit(this.repository, this.masters, this.context)
    : super(const ServiceInspectionListState());
  final ServiceInspectionRepository repository;
  final ServiceMasterRepository masters;
  final AuthContext context;
  StreamSubscription<Result<ServiceInspectionPage>>? _sub;

  void start() {
    _loadReferences();
    _subscribe();
  }

  Future<void> _loadReferences() async {
    Future<List<ServiceMasterRecord>> load(ServiceMasterKind kind) async {
      final result = await masters
          .watchList(
            kind,
            context,
            status: ConfigurationStatus.active,
            pageSize: 100,
          )
          .first;
      return result is Success<ServiceMasterPage>
          ? result.value.items
          : const [];
    }

    final results = await Future.wait([
      load(ServiceMasterKind.priority),
      load(ServiceMasterKind.rootCause),
    ]);
    if (isClosed) return;
    emit(state.copyWith(priorities: results[0], rootCauses: results[1]));
  }

  void search(String query) {
    emit(state.copyWith(loading: true, query: query, clearFailure: true));
    _subscribe();
  }

  void applyFilter(ServiceInspectionFilter filter) {
    emit(state.copyWith(loading: true, filter: filter, clearFailure: true));
    _subscribe();
  }

  void clearFilters() => applyFilter(const ServiceInspectionFilter());

  Future<Result<void>> cancel(String id) =>
      CancelServiceInspection(repository)(context, id);

  void _subscribe() {
    unawaited(_sub?.cancel());
    final filter = state.filter;
    _sub = repository
        .watchInspections(
          context,
          query: state.query,
          status: filter.status,
          priorityId: filter.priorityId,
          rootCauseId: filter.rootCauseId,
          visitFrom: filter.visitFrom,
          visitTo: filter.visitTo,
        )
        .listen((result) {
          switch (result) {
            case Success<ServiceInspectionPage>(:final value):
              emit(
                state.copyWith(loading: false, page: value, clearFailure: true),
              );
            case Failed<ServiceInspectionPage>(:final failure):
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

class ServiceInspectionDetailState {
  const ServiceInspectionDetailState({
    this.loading = true,
    this.view,
    this.activity = const [],
    this.failure,
  });
  final bool loading;
  final ServiceInspectionView? view;
  final List<BusinessActivityEvent> activity;
  final String? failure;
}

class ServiceInspectionDetailCubit extends Cubit<ServiceInspectionDetailState> {
  ServiceInspectionDetailCubit(
    this.repository,
    this.activityRepository,
    this.context,
    this.id,
  ) : super(const ServiceInspectionDetailState());
  final ServiceInspectionRepository repository;
  final ActivityRepository activityRepository;
  final AuthContext context;
  final String id;
  StreamSubscription<Result<ServiceInspectionView?>>? _sub;
  StreamSubscription<List<BusinessActivityEvent>>? _activity;

  void start() {
    _sub = repository.watchInspection(context, id).listen((result) {
      switch (result) {
        case Success<ServiceInspectionView?>(:final value):
          emit(
            ServiceInspectionDetailState(
              loading: false,
              view: value,
              activity: state.activity,
            ),
          );
        case Failed<ServiceInspectionView?>(:final failure):
          emit(
            ServiceInspectionDetailState(
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
          entityType: 'serviceInspection',
          entityId: id,
        )
        .listen(
          (events) => emit(
            ServiceInspectionDetailState(
              loading: false,
              view: state.view,
              activity: events,
              failure: state.failure,
            ),
          ),
        );
  }

  Future<Result<ServiceInspection>> complete({String? requestId}) =>
      CompleteServiceInspection(repository)(context, id, requestId: requestId);

  Future<Result<void>> cancel({String? requestId}) =>
      CancelServiceInspection(repository)(context, id, requestId: requestId);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _activity?.cancel();
    return super.close();
  }
}

class ServiceInspectionFormState {
  const ServiceInspectionFormState({
    this.loading = false,
    this.saving = false,
    this.saved = false,
    this.savedId,
    this.failure,
    this.draft = const ServiceInspectionDraft(),
    this.sourceContext,
    this.rootCauses = const [],
    this.chargeResponsibilities = const [],
  });
  final bool loading, saving, saved;
  final String? savedId, failure;
  final ServiceInspectionDraft draft;
  final ServiceInspectionSourceContext? sourceContext;
  final List<ServiceMasterRecord> rootCauses, chargeResponsibilities;

  ServiceInspectionFormState copyWith({
    bool? loading,
    bool? saving,
    bool? saved,
    String? savedId,
    String? failure,
    bool clearFailure = false,
    ServiceInspectionDraft? draft,
    ServiceInspectionSourceContext? sourceContext,
    bool clearSourceContext = false,
    List<ServiceMasterRecord>? rootCauses,
    List<ServiceMasterRecord>? chargeResponsibilities,
  }) => ServiceInspectionFormState(
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
    savedId: savedId ?? this.savedId,
    failure: clearFailure ? null : (failure ?? this.failure),
    draft: draft ?? this.draft,
    sourceContext: clearSourceContext
        ? null
        : (sourceContext ?? this.sourceContext),
    rootCauses: rootCauses ?? this.rootCauses,
    chargeResponsibilities:
        chargeResponsibilities ?? this.chargeResponsibilities,
  );
}

class ServiceInspectionFormCubit extends Cubit<ServiceInspectionFormState> {
  ServiceInspectionFormCubit(
    this.repository,
    this.masters,
    this.context,
    this.id, {
    this.initialJobAssignmentId,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid(),
       super(ServiceInspectionFormState(loading: id != null));
  final ServiceInspectionRepository repository;
  final ServiceMasterRepository masters;
  final AuthContext context;
  final String? id;
  final String? initialJobAssignmentId;
  final Uuid _uuid;

  Future<void> init() async {
    await _loadMasters();
    if (id == null) {
      if (initialJobAssignmentId != null) {
        await _loadSource(initialJobAssignmentId!, prefill: true);
      }
      if (isClosed) return;
      emit(state.copyWith(loading: false));
      return;
    }
    final result = await repository.getInspection(context, id!);
    switch (result) {
      case Success<ServiceInspectionView?>(:final value):
        if (value == null) {
          emit(
            state.copyWith(
              loading: false,
              failure: 'servicesInspectionNotFound',
            ),
          );
          return;
        }
        final i = value.inspection;
        final source = await repository.getSourceContext(
          context,
          i.sourceJobAssignmentId,
        );
        if (isClosed) return;
        emit(
          state.copyWith(
            loading: false,
            clearFailure: true,
            draft: ServiceInspectionDraft(
              sourceJobAssignmentId: i.sourceJobAssignmentId,
              visitDate: i.visitDate,
              visitMinutes: i.visitMinutes,
              technicianEmployeeId: i.technicianEmployeeId,
              rootCauseId: i.rootCauseId,
              chargeResponsibilityId: i.chargeResponsibilityId,
              checklistItems: [
                for (final c in i.checklistItems)
                  ServiceInspectionChecklistItemDraft(
                    id: c.id,
                    sourceJobAssignmentLineId: c.sourceJobAssignmentLineId,
                    workType: c.workType,
                    descriptionForWork: c.descriptionForWork,
                    status: c.status,
                    attachments: c.attachments,
                  ),
              ],
              inspectedPoints: [
                for (final p in i.inspectedPoints)
                  ServiceInspectionPointDraft(
                    id: p.id,
                    description: p.description,
                  ),
              ],
              materialRequirements: [
                for (final m in i.materialRequirements)
                  ServiceInspectionMaterialRequirementDraft(
                    id: m.id,
                    code: m.code,
                    description: m.description,
                    status: m.status,
                  ),
              ],
            ),
            sourceContext: source is Success<ServiceInspectionSourceContext?>
                ? source.value
                : null,
          ),
        );
      case Failed<ServiceInspectionView?>():
        emit(state.copyWith(loading: false, failure: 'servicesStorage'));
    }
  }

  Future<void> _loadMasters() async {
    Future<List<ServiceMasterRecord>> load(ServiceMasterKind kind) async {
      final result = await masters
          .watchList(
            kind,
            context,
            status: ConfigurationStatus.active,
            pageSize: 100,
          )
          .first;
      return result is Success<ServiceMasterPage>
          ? result.value.items
          : const [];
    }

    final results = await Future.wait([
      load(ServiceMasterKind.rootCause),
      load(ServiceMasterKind.chargeResponsibility),
    ]);
    if (isClosed) return;
    emit(
      state.copyWith(
        rootCauses: results[0],
        chargeResponsibilities: results[1],
      ),
    );
  }

  Future<List<ServiceAssignableJobAssignmentRef>> searchAssignments(
    String query,
  ) async {
    final result = await repository.searchEligibleJobAssignments(
      context,
      query: query,
    );
    return result is Success<List<ServiceAssignableJobAssignmentRef>>
        ? result.value
        : const [];
  }

  Future<void> _loadSource(
    String jobAssignmentId, {
    bool prefill = false,
  }) async {
    final result = await repository.getSourceContext(context, jobAssignmentId);
    if (isClosed) return;
    final source = result is Success<ServiceInspectionSourceContext?>
        ? result.value
        : null;
    emit(
      state.copyWith(
        sourceContext: source,
        draft: state.draft.copyWith(
          sourceJobAssignmentId: jobAssignmentId,
          visitDate: source?.scheduledVisitDate,
          checklistItems: prefill && source != null
              ? [
                  for (final line in source.workLines)
                    ServiceInspectionChecklistItemDraft(
                      id: _uuid.v4(),
                      sourceJobAssignmentLineId: line.id,
                      workType: line.work,
                      descriptionForWork: line.descriptionForWork,
                    ),
                ]
              : state.draft.checklistItems,
        ),
        clearFailure: true,
      ),
    );
  }

  Future<void> selectAssignment(ServiceAssignableJobAssignmentRef ref) =>
      _loadSource(ref.id, prefill: true);

  void clearAssignment() => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        clearSourceAssignment: true,
        clearTechnician: true,
        checklistItems: const [],
      ),
      clearSourceContext: true,
    ),
  );

  void setVisitDate(DateTime value) =>
      emit(state.copyWith(draft: state.draft.copyWith(visitDate: value)));

  void setVisitMinutes(int minutes) =>
      emit(state.copyWith(draft: state.draft.copyWith(visitMinutes: minutes)));

  void selectTechnician(String id) => emit(
    state.copyWith(
      draft: state.draft.copyWith(technicianEmployeeId: id),
      clearFailure: true,
    ),
  );

  void clearTechnician() =>
      emit(state.copyWith(draft: state.draft.copyWith(clearTechnician: true)));

  void selectRootCause(String id) =>
      emit(state.copyWith(draft: state.draft.copyWith(rootCauseId: id)));

  void clearRootCause() =>
      emit(state.copyWith(draft: state.draft.copyWith(clearRootCause: true)));

  void selectChargeResponsibility(String id) => emit(
    state.copyWith(draft: state.draft.copyWith(chargeResponsibilityId: id)),
  );

  void clearChargeResponsibility() => emit(
    state.copyWith(
      draft: state.draft.copyWith(clearChargeResponsibility: true),
    ),
  );

  // Checklist.
  void addChecklistItem() => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        checklistItems: [
          ...state.draft.checklistItems,
          ServiceInspectionChecklistItemDraft(id: _uuid.v4()),
        ],
      ),
    ),
  );

  void removeChecklistItem(String itemId) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        checklistItems: [
          for (final c in state.draft.checklistItems)
            if (c.id != itemId) c,
        ],
      ),
    ),
  );

  void updateWorkType(String itemId, String value) =>
      _patchChecklist(itemId, (c) => c.copyWith(workType: value));

  void updateDescriptionForWork(String itemId, String value) =>
      _patchChecklist(itemId, (c) => c.copyWith(descriptionForWork: value));

  void updateChecklistStatus(
    String itemId,
    ServiceInspectionChecklistStatus status,
  ) => _patchChecklist(itemId, (c) => c.copyWith(status: status));

  void addChecklistAttachments(String itemId, List<AttachmentRef> refs) {
    if (refs.isEmpty) return;
    _patchChecklist(
      itemId,
      (c) => c.copyWith(attachments: [...c.attachments, ...refs]),
    );
  }

  void removeChecklistAttachment(String itemId, String attachmentId) =>
      _patchChecklist(
        itemId,
        (c) => c.copyWith(
          attachments: [
            for (final a in c.attachments)
              if (a.id != attachmentId) a,
          ],
        ),
      );

  void _patchChecklist(
    String itemId,
    ServiceInspectionChecklistItemDraft? Function(
      ServiceInspectionChecklistItemDraft,
    )
    fn,
  ) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        checklistItems: [
          for (final c in state.draft.checklistItems)
            if (c.id == itemId)
              if (fn(c) case final next?) next else c,
        ],
      ),
      clearFailure: true,
    ),
  );

  // Points.
  void addPoint() => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        inspectedPoints: [
          ...state.draft.inspectedPoints,
          ServiceInspectionPointDraft(id: _uuid.v4()),
        ],
      ),
    ),
  );

  void removePoint(String pointId) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        inspectedPoints: [
          for (final p in state.draft.inspectedPoints)
            if (p.id != pointId) p,
        ],
      ),
    ),
  );

  void updatePointDescription(String pointId, String value) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        inspectedPoints: [
          for (final p in state.draft.inspectedPoints)
            if (p.id == pointId) p.copyWith(description: value) else p,
        ],
      ),
      clearFailure: true,
    ),
  );

  // Materials.
  void addMaterial() => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        materialRequirements: [
          ...state.draft.materialRequirements,
          ServiceInspectionMaterialRequirementDraft(id: _uuid.v4()),
        ],
      ),
    ),
  );

  void removeMaterial(String materialId) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        materialRequirements: [
          for (final m in state.draft.materialRequirements)
            if (m.id != materialId) m,
        ],
      ),
    ),
  );

  void updateMaterialCode(String materialId, String value) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        materialRequirements: [
          for (final m in state.draft.materialRequirements)
            if (m.id == materialId) m.copyWith(code: value) else m,
        ],
      ),
      clearFailure: true,
    ),
  );

  void updateMaterialDescription(String materialId, String value) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        materialRequirements: [
          for (final m in state.draft.materialRequirements)
            if (m.id == materialId) m.copyWith(description: value) else m,
        ],
      ),
      clearFailure: true,
    ),
  );

  Future<void> save() async {
    emit(state.copyWith(saving: true, clearFailure: true));
    final draft = state.draft;
    final result = id == null
        ? await CreateServiceInspection(repository)(context, draft)
        : await UpdateServiceInspection(repository)(context, id!, draft);
    switch (result) {
      case Success<ServiceInspection>(:final value):
        emit(state.copyWith(saving: false, saved: true, savedId: value.id));
      case Failed<ServiceInspection>(:final failure):
        emit(state.copyWith(saving: false, failure: failure.code));
    }
  }
}
