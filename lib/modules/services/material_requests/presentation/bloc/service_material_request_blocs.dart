import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master_repository.dart';
import 'package:modular_erp/modules/services/material_requests/application/service_material_request_use_cases.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';

class ServiceMaterialRequestFilter {
  const ServiceMaterialRequestFilter({
    this.status,
    this.purposeId,
    this.dateFrom,
    this.dateTo,
  });
  final ServiceMaterialRequestStatus? status;
  final String? purposeId;
  final DateTime? dateFrom, dateTo;
  int get activeCount =>
      [status, purposeId, dateFrom, dateTo].where((v) => v != null).length;

  ServiceMaterialRequestFilter copyWith({
    ServiceMaterialRequestStatus? status,
    bool clearStatus = false,
    String? purposeId,
    bool clearPurpose = false,
    DateTime? dateFrom,
    bool clearDateFrom = false,
    DateTime? dateTo,
    bool clearDateTo = false,
  }) => ServiceMaterialRequestFilter(
    status: clearStatus ? null : (status ?? this.status),
    purposeId: clearPurpose ? null : (purposeId ?? this.purposeId),
    dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
    dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
  );
}

class ServiceMaterialRequestListState {
  const ServiceMaterialRequestListState({
    this.loading = true,
    this.page,
    this.failure,
    this.query = '',
    this.filter = const ServiceMaterialRequestFilter(),
    this.purposes = const [],
  });
  final bool loading;
  final ServiceMaterialRequestPage? page;
  final String? failure;
  final String query;
  final ServiceMaterialRequestFilter filter;
  final List<ServiceMasterRecord> purposes;

  ServiceMaterialRequestListState copyWith({
    bool? loading,
    ServiceMaterialRequestPage? page,
    String? failure,
    bool clearFailure = false,
    String? query,
    ServiceMaterialRequestFilter? filter,
    List<ServiceMasterRecord>? purposes,
  }) => ServiceMaterialRequestListState(
    loading: loading ?? this.loading,
    page: page ?? this.page,
    failure: clearFailure ? null : (failure ?? this.failure),
    query: query ?? this.query,
    filter: filter ?? this.filter,
    purposes: purposes ?? this.purposes,
  );
}

class ServiceMaterialRequestListCubit
    extends Cubit<ServiceMaterialRequestListState> {
  ServiceMaterialRequestListCubit(this.repository, this.masters, this.context)
    : super(const ServiceMaterialRequestListState());
  final ServiceMaterialRequestRepository repository;
  final ServiceMasterRepository masters;
  final AuthContext context;
  StreamSubscription<Result<ServiceMaterialRequestPage>>? _sub;

  void start() {
    _loadPurposes();
    _subscribe();
  }

  Future<void> _loadPurposes() async {
    final result = await masters
        .watchList(
          ServiceMasterKind.materialRequestPurpose,
          context,
          status: ConfigurationStatus.active,
          pageSize: 100,
        )
        .first;
    if (isClosed) return;
    if (result case Success<ServiceMasterPage>(:final value)) {
      emit(state.copyWith(purposes: value.items));
    }
  }

  void search(String query) {
    emit(state.copyWith(loading: true, query: query, clearFailure: true));
    _subscribe();
  }

  void applyFilter(ServiceMaterialRequestFilter filter) {
    emit(state.copyWith(loading: true, filter: filter, clearFailure: true));
    _subscribe();
  }

  void clearFilters() => applyFilter(const ServiceMaterialRequestFilter());

  Future<Result<void>> cancel(String id) =>
      CancelServiceMaterialRequest(repository)(context, id);

  void _subscribe() {
    unawaited(_sub?.cancel());
    final filter = state.filter;
    _sub = repository
        .watchRequests(
          context,
          query: state.query,
          status: filter.status,
          purposeId: filter.purposeId,
          dateFrom: filter.dateFrom,
          dateTo: filter.dateTo,
        )
        .listen((result) {
          switch (result) {
            case Success<ServiceMaterialRequestPage>(:final value):
              emit(
                state.copyWith(loading: false, page: value, clearFailure: true),
              );
            case Failed<ServiceMaterialRequestPage>(:final failure):
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

class ServiceMaterialRequestDetailState {
  const ServiceMaterialRequestDetailState({
    this.loading = true,
    this.view,
    this.activity = const [],
    this.failure,
  });
  final bool loading;
  final ServiceMaterialRequestView? view;
  final List<BusinessActivityEvent> activity;
  final String? failure;
}

class ServiceMaterialRequestDetailCubit
    extends Cubit<ServiceMaterialRequestDetailState> {
  ServiceMaterialRequestDetailCubit(
    this.repository,
    this.activityRepository,
    this.context,
    this.id,
  ) : super(const ServiceMaterialRequestDetailState());
  final ServiceMaterialRequestRepository repository;
  final ActivityRepository activityRepository;
  final AuthContext context;
  final String id;
  StreamSubscription<Result<ServiceMaterialRequestView?>>? _sub;
  StreamSubscription<List<BusinessActivityEvent>>? _activity;

  void start() {
    _sub = repository.watchRequest(context, id).listen((result) {
      switch (result) {
        case Success<ServiceMaterialRequestView?>(:final value):
          emit(
            ServiceMaterialRequestDetailState(
              loading: false,
              view: value,
              activity: state.activity,
            ),
          );
        case Failed<ServiceMaterialRequestView?>(:final failure):
          emit(
            ServiceMaterialRequestDetailState(
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
          entityType: 'serviceMaterialRequest',
          entityId: id,
        )
        .listen(
          (events) => emit(
            ServiceMaterialRequestDetailState(
              loading: false,
              view: state.view,
              activity: events,
              failure: state.failure,
            ),
          ),
        );
  }

  Future<Result<void>> cancel({String? requestId}) =>
      CancelServiceMaterialRequest(repository)(
        context,
        id,
        requestId: requestId,
      );

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _activity?.cancel();
    return super.close();
  }
}

class ServiceMaterialRequestFormState {
  const ServiceMaterialRequestFormState({
    this.loading = false,
    this.saving = false,
    this.saved = false,
    this.savedId,
    this.failure,
    this.draft = const ServiceMaterialRequestDraft(),
    this.sourceContext,
    this.purposes = const [],
  });
  final bool loading, saving, saved;
  final String? savedId, failure;
  final ServiceMaterialRequestDraft draft;
  final ServiceMaterialRequestSourceContext? sourceContext;
  final List<ServiceMasterRecord> purposes;

  double get totalQuantity => materialRequestDraftTotal(draft.lines);

  ServiceMaterialRequestFormState copyWith({
    bool? loading,
    bool? saving,
    bool? saved,
    String? savedId,
    String? failure,
    bool clearFailure = false,
    ServiceMaterialRequestDraft? draft,
    ServiceMaterialRequestSourceContext? sourceContext,
    bool clearSourceContext = false,
    List<ServiceMasterRecord>? purposes,
  }) => ServiceMaterialRequestFormState(
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
    savedId: savedId ?? this.savedId,
    failure: clearFailure ? null : (failure ?? this.failure),
    draft: draft ?? this.draft,
    sourceContext: clearSourceContext
        ? null
        : (sourceContext ?? this.sourceContext),
    purposes: purposes ?? this.purposes,
  );
}

class ServiceMaterialRequestFormCubit
    extends Cubit<ServiceMaterialRequestFormState> {
  ServiceMaterialRequestFormCubit(
    this.repository,
    this.masters,
    this.context,
    this.id, {
    this.initialInspectionId,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid(),
       super(ServiceMaterialRequestFormState(loading: id != null));
  final ServiceMaterialRequestRepository repository;
  final ServiceMasterRepository masters;
  final AuthContext context;
  final String? id;
  final String? initialInspectionId;
  final Uuid _uuid;

  Future<void> init() async {
    await _loadPurposes();
    if (id == null) {
      if (initialInspectionId != null) {
        await _loadSource(initialInspectionId!, prefill: true);
      }
      if (isClosed) return;
      emit(state.copyWith(loading: false));
      return;
    }
    final result = await repository.getRequest(context, id!);
    switch (result) {
      case Success<ServiceMaterialRequestView?>(:final value):
        if (value == null) {
          emit(
            state.copyWith(
              loading: false,
              failure: 'servicesMaterialRequestNotFound',
            ),
          );
          return;
        }
        final request = value.request;
        final source = await repository.getSourceContext(
          context,
          request.sourceInspectionId,
        );
        if (isClosed) return;
        emit(
          state.copyWith(
            loading: false,
            clearFailure: true,
            draft: ServiceMaterialRequestDraft(
              sourceInspectionId: request.sourceInspectionId,
              jobOrderReference: request.jobOrderReference ?? '',
              purposeId: request.purposeId,
              acknowledgement: request.acknowledgement ?? '',
              receivedBy: request.receivedBy ?? '',
              remarks: request.remarks ?? '',
              lines: [
                for (final line in request.lines)
                  ServiceMaterialRequestLineDraft(
                    id: line.id,
                    sourceInspectionMaterialRequirementId:
                        line.sourceInspectionMaterialRequirementId,
                    code: line.code,
                    description: line.description,
                    batchNumber: line.batchNumber ?? '',
                    quantity: formatMaterialQuantity(line.quantity),
                    remark: line.remark ?? '',
                  ),
              ],
            ),
            sourceContext:
                source is Success<ServiceMaterialRequestSourceContext?>
                ? source.value
                : null,
          ),
        );
      case Failed<ServiceMaterialRequestView?>():
        emit(state.copyWith(loading: false, failure: 'servicesStorage'));
    }
  }

  Future<void> _loadPurposes() async {
    final result = await masters
        .watchList(
          ServiceMasterKind.materialRequestPurpose,
          context,
          status: ConfigurationStatus.active,
          pageSize: 100,
        )
        .first;
    if (isClosed) return;
    if (result case Success<ServiceMasterPage>(:final value)) {
      emit(state.copyWith(purposes: value.items));
    }
  }

  Future<List<ServiceEligibleInspectionRef>> searchInspections(
    String query,
  ) async {
    final result = await repository.searchEligibleInspections(
      context,
      query: query,
    );
    return result is Success<List<ServiceEligibleInspectionRef>>
        ? result.value
        : const [];
  }

  Future<void> _loadSource(String inspectionId, {bool prefill = false}) async {
    final result = await repository.getSourceContext(context, inspectionId);
    if (isClosed) return;
    final source = result is Success<ServiceMaterialRequestSourceContext?>
        ? result.value
        : null;
    emit(
      state.copyWith(
        sourceContext: source,
        draft: state.draft.copyWith(
          sourceInspectionId: inspectionId,
          lines: prefill && source != null
              ? [
                  for (final requirement in source.waitingRequirements)
                    ServiceMaterialRequestLineDraft(
                      id: _uuid.v4(),
                      sourceInspectionMaterialRequirementId: requirement.id,
                      code: requirement.code,
                      description: requirement.description,
                    ),
                ]
              : state.draft.lines,
        ),
        clearFailure: true,
      ),
    );
  }

  Future<void> selectInspection(ServiceEligibleInspectionRef ref) =>
      _loadSource(ref.id, prefill: true);

  void clearInspection() => emit(
    state.copyWith(
      draft: state.draft.copyWith(clearSourceInspection: true, lines: const []),
      clearSourceContext: true,
    ),
  );

  void setJobOrderReference(String value) => emit(
    state.copyWith(
      draft: state.draft.copyWith(jobOrderReference: value),
      clearFailure: true,
    ),
  );

  void selectPurpose(String id) => emit(
    state.copyWith(
      draft: state.draft.copyWith(purposeId: id),
      clearFailure: true,
    ),
  );

  void clearPurpose() =>
      emit(state.copyWith(draft: state.draft.copyWith(clearPurpose: true)));

  void setAcknowledgement(String value) => emit(
    state.copyWith(
      draft: state.draft.copyWith(acknowledgement: value),
      clearFailure: true,
    ),
  );

  void setReceivedBy(String value) => emit(
    state.copyWith(
      draft: state.draft.copyWith(receivedBy: value),
      clearFailure: true,
    ),
  );

  void setRemarks(String value) => emit(
    state.copyWith(
      draft: state.draft.copyWith(remarks: value),
      clearFailure: true,
    ),
  );

  // Material lines.
  void addLine() => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        lines: [
          ...state.draft.lines,
          ServiceMaterialRequestLineDraft(id: _uuid.v4()),
        ],
      ),
    ),
  );

  void removeLine(String lineId) {
    if (state.draft.lines.length <= 1) return;
    emit(
      state.copyWith(
        draft: state.draft.copyWith(
          lines: [
            for (final line in state.draft.lines)
              if (line.id != lineId) line,
          ],
        ),
      ),
    );
  }

  void _patchLine(
    String lineId,
    ServiceMaterialRequestLineDraft Function(ServiceMaterialRequestLineDraft)
    fn,
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

  void updateCode(String lineId, String value) =>
      _patchLine(lineId, (line) => line.copyWith(code: value));

  void updateDescription(String lineId, String value) =>
      _patchLine(lineId, (line) => line.copyWith(description: value));

  void updateBatchNumber(String lineId, String value) =>
      _patchLine(lineId, (line) => line.copyWith(batchNumber: value));

  void updateQuantity(String lineId, String value) =>
      _patchLine(lineId, (line) => line.copyWith(quantity: value));

  void updateRemark(String lineId, String value) =>
      _patchLine(lineId, (line) => line.copyWith(remark: value));

  void resetForm() => emit(
    ServiceMaterialRequestFormState(loading: false, purposes: state.purposes),
  );

  Future<void> save() async {
    emit(state.copyWith(saving: true, clearFailure: true));
    final draft = state.draft;
    final result = id == null
        ? await CreateServiceMaterialRequest(repository)(context, draft)
        : await UpdateServiceMaterialRequest(repository)(context, id!, draft);
    switch (result) {
      case Success<ServiceMaterialRequest>(:final value):
        emit(state.copyWith(saving: false, saved: true, savedId: value.id));
      case Failed<ServiceMaterialRequest>(:final failure):
        emit(state.copyWith(saving: false, failure: failure.code));
    }
  }
}
