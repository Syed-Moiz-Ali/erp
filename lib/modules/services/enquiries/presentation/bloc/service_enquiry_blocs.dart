import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master_repository.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer.dart';
import 'package:modular_erp/modules/services/enquiries/application/service_enquiry_use_cases.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';

class ServiceEnquiryFilter {
  const ServiceEnquiryFilter({
    this.status,
    this.serviceTypeId,
    this.complaintTypeId,
    this.priorityId,
    this.ticketTypeId,
    this.createdFrom,
    this.createdTo,
  });
  final ServiceEnquiryStatus? status;
  final String? serviceTypeId, complaintTypeId, priorityId, ticketTypeId;
  final DateTime? createdFrom, createdTo;

  int get activeCount => [
    status,
    serviceTypeId,
    complaintTypeId,
    priorityId,
    ticketTypeId,
    createdFrom,
    createdTo,
  ].where((v) => v != null).length;

  ServiceEnquiryFilter copyWith({
    ServiceEnquiryStatus? status,
    bool clearStatus = false,
    String? serviceTypeId,
    bool clearServiceType = false,
    String? complaintTypeId,
    bool clearComplaintType = false,
    String? priorityId,
    bool clearPriority = false,
    String? ticketTypeId,
    bool clearTicketType = false,
    DateTime? createdFrom,
    bool clearCreatedFrom = false,
    DateTime? createdTo,
    bool clearCreatedTo = false,
  }) => ServiceEnquiryFilter(
    status: clearStatus ? null : (status ?? this.status),
    serviceTypeId: clearServiceType
        ? null
        : (serviceTypeId ?? this.serviceTypeId),
    complaintTypeId: clearComplaintType
        ? null
        : (complaintTypeId ?? this.complaintTypeId),
    priorityId: clearPriority ? null : (priorityId ?? this.priorityId),
    ticketTypeId: clearTicketType ? null : (ticketTypeId ?? this.ticketTypeId),
    createdFrom: clearCreatedFrom ? null : (createdFrom ?? this.createdFrom),
    createdTo: clearCreatedTo ? null : (createdTo ?? this.createdTo),
  );
}

class ServiceEnquiryListState {
  const ServiceEnquiryListState({
    this.loading = true,
    this.page,
    this.failure,
    this.query = '',
    this.filter = const ServiceEnquiryFilter(),
    this.serviceTypes = const [],
    this.complaintTypes = const [],
    this.priorities = const [],
    this.ticketTypes = const [],
    this.referencesLoading = true,
  });
  final bool loading, referencesLoading;
  final ServiceEnquiryPage? page;
  final String? failure;
  final String query;
  final ServiceEnquiryFilter filter;
  final List<ServiceMasterRecord> serviceTypes,
      complaintTypes,
      priorities,
      ticketTypes;

  ServiceEnquiryListState copyWith({
    bool? loading,
    bool? referencesLoading,
    ServiceEnquiryPage? page,
    String? failure,
    bool clearFailure = false,
    String? query,
    ServiceEnquiryFilter? filter,
    List<ServiceMasterRecord>? serviceTypes,
    List<ServiceMasterRecord>? complaintTypes,
    List<ServiceMasterRecord>? priorities,
    List<ServiceMasterRecord>? ticketTypes,
  }) => ServiceEnquiryListState(
    loading: loading ?? this.loading,
    referencesLoading: referencesLoading ?? this.referencesLoading,
    page: page ?? this.page,
    failure: clearFailure ? null : (failure ?? this.failure),
    query: query ?? this.query,
    filter: filter ?? this.filter,
    serviceTypes: serviceTypes ?? this.serviceTypes,
    complaintTypes: complaintTypes ?? this.complaintTypes,
    priorities: priorities ?? this.priorities,
    ticketTypes: ticketTypes ?? this.ticketTypes,
  );
}

class ServiceEnquiryListCubit extends Cubit<ServiceEnquiryListState> {
  ServiceEnquiryListCubit(this.repository, this.masters, this.context)
    : super(const ServiceEnquiryListState());
  final ServiceEnquiryRepository repository;
  final ServiceMasterRepository masters;
  final AuthContext context;
  StreamSubscription<Result<ServiceEnquiryPage>>? _sub;

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
      load(ServiceMasterKind.serviceType),
      load(ServiceMasterKind.complaintType),
      load(ServiceMasterKind.priority),
      load(ServiceMasterKind.ticketType),
    ]);
    if (isClosed) return;
    emit(
      state.copyWith(
        referencesLoading: false,
        serviceTypes: results[0],
        complaintTypes: results[1],
        priorities: results[2],
        ticketTypes: results[3],
      ),
    );
  }

  void search(String query) {
    emit(state.copyWith(loading: true, query: query, clearFailure: true));
    _subscribe();
  }

  void applyFilter(ServiceEnquiryFilter filter) {
    emit(state.copyWith(loading: true, filter: filter, clearFailure: true));
    _subscribe();
  }

  void clearFilters() => applyFilter(const ServiceEnquiryFilter());

  Future<Result<void>> cancel(String id) =>
      CancelServiceEnquiry(repository)(context, id);

  void _subscribe() {
    unawaited(_sub?.cancel());
    final filter = state.filter;
    _sub = repository
        .watchEnquiries(
          context,
          query: state.query,
          status: filter.status,
          serviceTypeId: filter.serviceTypeId,
          complaintTypeId: filter.complaintTypeId,
          priorityId: filter.priorityId,
          ticketTypeId: filter.ticketTypeId,
          createdFrom: filter.createdFrom,
          createdTo: filter.createdTo,
        )
        .listen((result) {
          switch (result) {
            case Success<ServiceEnquiryPage>(:final value):
              emit(
                state.copyWith(loading: false, page: value, clearFailure: true),
              );
            case Failed<ServiceEnquiryPage>(:final failure):
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

class ServiceEnquiryDetailState {
  const ServiceEnquiryDetailState({
    this.loading = true,
    this.detail,
    this.activity = const [],
    this.failure,
  });
  final bool loading;
  final ServiceEnquiryView? detail;
  final List<BusinessActivityEvent> activity;
  final String? failure;
}

class ServiceEnquiryDetailCubit extends Cubit<ServiceEnquiryDetailState> {
  ServiceEnquiryDetailCubit(
    this.repository,
    this.activityRepository,
    this.context,
    this.id,
  ) : super(const ServiceEnquiryDetailState());
  final ServiceEnquiryRepository repository;
  final ActivityRepository activityRepository;
  final AuthContext context;
  final String id;

  StreamSubscription<Result<ServiceEnquiryView?>>? _sub;
  StreamSubscription<List<BusinessActivityEvent>>? _activity;

  void start() {
    _sub = repository.watchEnquiry(context, id).listen((result) {
      switch (result) {
        case Success<ServiceEnquiryView?>(:final value):
          emit(
            ServiceEnquiryDetailState(
              loading: false,
              detail: value,
              activity: state.activity,
            ),
          );
        case Failed<ServiceEnquiryView?>(:final failure):
          emit(
            ServiceEnquiryDetailState(
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
          entityType: 'serviceEnquiry',
          entityId: id,
        )
        .listen(
          (events) => emit(
            ServiceEnquiryDetailState(
              loading: false,
              detail: state.detail,
              activity: events,
              failure: state.failure,
            ),
          ),
        );
  }

  Future<Result<void>> cancel({String? reason, String? requestId}) =>
      CancelServiceEnquiry(repository)(
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

class ServiceEnquiryFormState {
  const ServiceEnquiryFormState({
    this.loading = false,
    this.saving = false,
    this.saved = false,
    this.savedId,
    this.failure,
    this.draft = const ServiceEnquiryDraft(),
    this.customerRef,
    this.siteRef,
    this.serviceTypes = const [],
    this.complaintTypes = const [],
    this.priorities = const [],
    this.ticketTypes = const [],
    this.referencesLoading = true,
  });
  final bool loading, saving, saved, referencesLoading;
  final String? savedId, failure;
  final ServiceEnquiryDraft draft;
  final ServiceCustomerRef? customerRef;
  final ServiceEnquirySiteRef? siteRef;
  final List<ServiceMasterRecord> serviceTypes,
      complaintTypes,
      priorities,
      ticketTypes;

  List<ServiceEnquiryDraftDetail> get details => draft.details;

  List<ServiceMasterRecord> get complaintTypesForSelection {
    final selected = draft.serviceTypeId;
    return [
      for (final c in complaintTypes)
        if (c.serviceTypeId == null || c.serviceTypeId == selected) c,
    ];
  }

  ServiceEnquiryFormState copyWith({
    bool? loading,
    bool? saving,
    bool? saved,
    bool? referencesLoading,
    String? savedId,
    String? failure,
    bool clearFailure = false,
    ServiceEnquiryDraft? draft,
    ServiceCustomerRef? customerRef,
    bool clearCustomerRef = false,
    ServiceEnquirySiteRef? siteRef,
    bool clearSiteRef = false,
    List<ServiceMasterRecord>? serviceTypes,
    List<ServiceMasterRecord>? complaintTypes,
    List<ServiceMasterRecord>? priorities,
    List<ServiceMasterRecord>? ticketTypes,
  }) => ServiceEnquiryFormState(
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
    referencesLoading: referencesLoading ?? this.referencesLoading,
    savedId: savedId ?? this.savedId,
    failure: clearFailure ? null : (failure ?? this.failure),
    draft: draft ?? this.draft,
    customerRef: clearCustomerRef ? null : (customerRef ?? this.customerRef),
    siteRef: clearSiteRef ? null : (siteRef ?? this.siteRef),
    serviceTypes: serviceTypes ?? this.serviceTypes,
    complaintTypes: complaintTypes ?? this.complaintTypes,
    priorities: priorities ?? this.priorities,
    ticketTypes: ticketTypes ?? this.ticketTypes,
  );
}

class ServiceEnquiryFormCubit extends Cubit<ServiceEnquiryFormState> {
  ServiceEnquiryFormCubit(
    this.repository,
    this.masters,
    this.context,
    this.id, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid(),
       super(ServiceEnquiryFormState(loading: id != null));

  final ServiceEnquiryRepository repository;
  final ServiceMasterRepository masters;
  final AuthContext context;
  final String? id;
  final Uuid _uuid;

  ServiceEnquiryDraftDetail _newDetail() =>
      ServiceEnquiryDraftDetail(id: _uuid.v4());

  Future<void> init() async {
    await _loadReferences();
    if (id == null) {
      emit(
        state.copyWith(
          loading: false,
          draft: state.draft.details.isEmpty
              ? state.draft.copyWith(details: [_newDetail()])
              : state.draft,
        ),
      );
      return;
    }
    final result = await repository.getEnquiry(context, id!);
    switch (result) {
      case Success<ServiceEnquiryView?>(:final value):
        if (value == null) {
          emit(
            state.copyWith(loading: false, failure: 'servicesEnquiryNotFound'),
          );
          return;
        }
        final e = value.enquiry;
        final snapshot = e.partySnapshot;
        emit(
          state.copyWith(
            loading: false,
            clearFailure: true,
            draft: ServiceEnquiryDraft(
              customerId: e.customerId,
              siteId: e.siteId,
              serviceTypeId: e.serviceTypeId,
              complaintTypeId: e.complaintTypeId,
              priorityId: e.priorityId,
              ticketTypeId: e.ticketTypeId,
              materialReceived: e.materialReceived,
              details: [
                for (final line in e.details)
                  ServiceEnquiryDraftDetail(
                    id: line.id,
                    description: line.description,
                    status: line.status,
                    attachments: line.attachments,
                  ),
              ],
            ),
            customerRef: ServiceCustomerRef(
              id: e.customerId,
              customerCode: snapshot.customerCode ?? '',
              displayName: snapshot.customerName ?? '',
              mobile: snapshot.customerMobile,
            ),
            siteRef: ServiceEnquirySiteRef(
              id: e.siteId,
              siteCode: '',
              siteName: snapshot.siteName ?? '',
              customerId: e.customerId,
              tenantName: snapshot.tenantName,
              buildingName: snapshot.buildingName,
              unitNumber: snapshot.unitNumber,
              addressSummary: snapshot.addressSummary,
              contactName: snapshot.siteContactName,
              contactMobile: snapshot.siteContactMobile,
            ),
          ),
        );
      case Failed<ServiceEnquiryView?>():
        emit(state.copyWith(loading: false, failure: 'servicesStorage'));
    }
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
      load(ServiceMasterKind.serviceType),
      load(ServiceMasterKind.complaintType),
      load(ServiceMasterKind.priority),
      load(ServiceMasterKind.ticketType),
    ]);
    if (isClosed) return;
    emit(
      state.copyWith(
        referencesLoading: false,
        serviceTypes: results[0],
        complaintTypes: results[1],
        priorities: results[2],
        ticketTypes: results[3],
      ),
    );
  }

  Future<List<ServiceCustomerRef>> searchCustomers(String query) async {
    final result = await repository.searchCustomerRefsForEnquiry(
      context,
      query: query,
    );
    return result is Success<List<ServiceCustomerRef>>
        ? result.value
        : const [];
  }

  Future<List<ServiceEnquirySiteRef>> searchSites(String query) async {
    final customerId = state.draft.customerId;
    if (customerId == null) return const [];
    final result = await repository.searchSiteRefsForEnquiry(
      context,
      customerId: customerId,
      query: query,
    );
    return result is Success<List<ServiceEnquirySiteRef>>
        ? result.value
        : const [];
  }

  void selectCustomer(ServiceCustomerRef ref) => emit(
    state.copyWith(
      draft: state.draft.copyWith(customerId: ref.id, clearSite: true),
      customerRef: ref,
      clearSiteRef: true,
      clearFailure: true,
    ),
  );

  void clearCustomer() => emit(
    state.copyWith(
      draft: state.draft.copyWith(clearCustomer: true, clearSite: true),
      clearCustomerRef: true,
      clearSiteRef: true,
    ),
  );

  void selectSite(ServiceEnquirySiteRef ref) => emit(
    state.copyWith(
      draft: state.draft.copyWith(siteId: ref.id),
      siteRef: ref,
      clearFailure: true,
    ),
  );

  Future<void> selectCustomerById(String id) async {
    final result = await repository.getCustomerRefForEnquiry(context, id);
    if (result case Success<ServiceCustomerRef?>(:final value)) {
      if (value != null && !isClosed) selectCustomer(value);
    }
  }

  Future<void> selectSiteById(String id) async {
    final result = await repository.getSiteRefForEnquiry(context, id);
    if (result case Success<ServiceEnquirySiteRef?>(:final value)) {
      if (value != null && !isClosed) selectSite(value);
    }
  }

  void clearSite() => emit(
    state.copyWith(
      draft: state.draft.copyWith(clearSite: true),
      clearSiteRef: true,
    ),
  );

  void selectServiceType(String id) => emit(
    state.copyWith(
      draft: state.draft.copyWith(serviceTypeId: id, clearComplaintType: true),
      clearFailure: true,
    ),
  );

  void selectComplaintType(String id) =>
      emit(state.copyWith(draft: state.draft.copyWith(complaintTypeId: id)));

  void selectPriority(String id) =>
      emit(state.copyWith(draft: state.draft.copyWith(priorityId: id)));

  void selectTicketType(String id) =>
      emit(state.copyWith(draft: state.draft.copyWith(ticketTypeId: id)));

  void selectMaterialReceived(MaterialReceived value) => emit(
    state.copyWith(draft: state.draft.copyWith(materialReceived: value)),
  );

  void addDetail() => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        details: [...state.draft.details, _newDetail()],
      ),
    ),
  );

  void removeDetail(String detailId) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        details: [
          for (final detail in state.draft.details)
            if (detail.id != detailId) detail,
        ],
      ),
    ),
  );

  void updateDetailDescription(String detailId, String value) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        details: [
          for (final detail in state.draft.details)
            if (detail.id == detailId)
              detail.copyWith(description: value)
            else
              detail,
        ],
      ),
    ),
  );

  void updateDetailStatus(String detailId, ServiceEnquiryDetailStatus status) =>
      emit(
        state.copyWith(
          draft: state.draft.copyWith(
            details: [
              for (final detail in state.draft.details)
                if (detail.id == detailId)
                  detail.copyWith(status: status)
                else
                  detail,
            ],
          ),
        ),
      );

  void addDetailAttachments(String detailId, List<AttachmentRef> refs) {
    if (refs.isEmpty) return;
    emit(
      state.copyWith(
        draft: state.draft.copyWith(
          details: [
            for (final detail in state.draft.details)
              if (detail.id == detailId)
                detail.copyWith(attachments: [...detail.attachments, ...refs])
              else
                detail,
          ],
        ),
      ),
    );
  }

  void removeDetailAttachment(String detailId, String attachmentId) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        details: [
          for (final detail in state.draft.details)
            if (detail.id == detailId)
              detail.copyWith(
                attachments: [
                  for (final attachment in detail.attachments)
                    if (attachment.id != attachmentId) attachment,
                ],
              )
            else
              detail,
        ],
      ),
    ),
  );

  Future<void> save() async {
    emit(state.copyWith(saving: true, clearFailure: true));
    final draft = state.draft;
    final result = id == null
        ? await CreateServiceEnquiry(repository)(context, draft)
        : await UpdateServiceEnquiry(repository)(context, id!, draft);
    switch (result) {
      case Success<ServiceEnquiry>(:final value):
        emit(state.copyWith(saving: false, saved: true, savedId: value.id));
      case Failed<ServiceEnquiry>(:final failure):
        emit(state.copyWith(saving: false, failure: failure.code));
    }
  }
}
