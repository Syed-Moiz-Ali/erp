import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer_repository.dart';
import 'package:modular_erp/modules/services/sites/domain/service_site.dart';
import 'package:modular_erp/modules/services/sites/domain/service_site_repository.dart';

class ServiceCustomerListState {
  const ServiceCustomerListState({
    this.loading = true,
    this.page,
    this.failure,
    this.query = '',
    this.status,
  });
  final bool loading;
  final ServiceCustomerPage? page;
  final String? failure;
  final String query;
  final ConfigurationStatus? status;
}

class ServiceCustomerListCubit extends Cubit<ServiceCustomerListState> {
  ServiceCustomerListCubit(this.repository, this.context)
    : super(const ServiceCustomerListState());
  final ServiceCustomerRepository repository;
  final AuthContext context;
  StreamSubscription<Result<ServiceCustomerPage>>? _sub;

  void start() => _subscribe();
  void search(String query) {
    emit(
      ServiceCustomerListState(
        loading: true,
        query: query,
        status: state.status,
      ),
    );
    _subscribe();
  }

  void setStatus(ConfigurationStatus? status) {
    emit(
      ServiceCustomerListState(
        loading: true,
        query: state.query,
        status: status,
      ),
    );
    _subscribe();
  }

  Future<Result<void>> setActive(String id, bool active) =>
      repository.setActive(context, id, active);

  void _subscribe() {
    unawaited(_sub?.cancel());
    _sub = repository
        .watchCustomers(context, query: state.query, status: state.status)
        .listen((result) {
          switch (result) {
            case Success<ServiceCustomerPage>(:final value):
              emit(
                ServiceCustomerListState(
                  loading: false,
                  page: value,
                  query: state.query,
                  status: state.status,
                ),
              );
            case Failed<ServiceCustomerPage>(:final failure):
              emit(
                ServiceCustomerListState(
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

class ServiceCustomerDetailState {
  const ServiceCustomerDetailState({
    this.loading = true,
    this.customer,
    this.sites = const [],
    this.activity = const [],
    this.failure,
  });
  final bool loading;
  final ServiceCustomer? customer;
  final List<ServiceSite> sites;
  final List<BusinessActivityEvent> activity;
  final String? failure;
}

class ServiceCustomerDetailCubit extends Cubit<ServiceCustomerDetailState> {
  ServiceCustomerDetailCubit(
    this.repository,
    this.siteRepository,
    this.activityRepository,
    this.context,
    this.id,
  ) : super(const ServiceCustomerDetailState());
  final ServiceCustomerRepository repository;
  final ServiceSiteRepository siteRepository;
  final ActivityRepository activityRepository;
  final AuthContext context;
  final String id;
  StreamSubscription<Result<ServiceCustomer?>>? _sub;
  StreamSubscription<Result<List<ServiceSite>>>? _sites;
  StreamSubscription<List<BusinessActivityEvent>>? _activity;

  void start() {
    _sub = repository.watchCustomer(context, id).listen((result) {
      switch (result) {
        case Success<ServiceCustomer?>(:final value):
          emit(
            ServiceCustomerDetailState(
              loading: false,
              customer: value,
              sites: state.sites,
              activity: state.activity,
            ),
          );
        case Failed<ServiceCustomer?>(:final failure):
          emit(
            ServiceCustomerDetailState(
              loading: false,
              failure: failure.code,
              sites: state.sites,
              activity: state.activity,
            ),
          );
      }
    });
    _sites = siteRepository.watchSitesForCustomer(context, id).listen((result) {
      if (result case Success<List<ServiceSite>>(:final value)) {
        emit(
          ServiceCustomerDetailState(
            loading: false,
            customer: state.customer,
            sites: value,
            activity: state.activity,
            failure: state.failure,
          ),
        );
      }
    });
    _activity = activityRepository
        .watchForEntity(
          companyId: context.company.id,
          entityType: 'serviceCustomer',
          entityId: id,
        )
        .listen(
          (events) => emit(
            ServiceCustomerDetailState(
              loading: false,
              customer: state.customer,
              sites: state.sites,
              activity: events,
              failure: state.failure,
            ),
          ),
        );
  }

  Future<Result<void>> setActive(bool active) =>
      repository.setActive(context, id, active);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _sites?.cancel();
    await _activity?.cancel();
    return super.close();
  }
}

class ServiceCustomerFormState {
  const ServiceCustomerFormState({
    this.loading = false,
    this.saving = false,
    this.saved = false,
    this.savedId,
    this.failure,
    this.fieldErrors = const {},
    this.draft = const ServiceCustomerDraft(),
  });
  final bool loading, saving, saved;
  final String? savedId, failure;
  final Map<String, String> fieldErrors;
  final ServiceCustomerDraft draft;

  ServiceCustomerFormState copyWith({
    bool? loading,
    bool? saving,
    bool? saved,
    String? savedId,
    String? failure,
    bool clearFailure = false,
    Map<String, String>? fieldErrors,
    ServiceCustomerDraft? draft,
  }) => ServiceCustomerFormState(
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
    savedId: savedId ?? this.savedId,
    failure: clearFailure ? null : (failure ?? this.failure),
    fieldErrors: fieldErrors ?? this.fieldErrors,
    draft: draft ?? this.draft,
  );
}

class ServiceCustomerFormCubit extends Cubit<ServiceCustomerFormState> {
  ServiceCustomerFormCubit(this.repository, this.context, this.id)
    : super(ServiceCustomerFormState(loading: id != null));
  final ServiceCustomerRepository repository;
  final AuthContext context;
  final String? id;

  Future<void> init() async {
    if (id == null) {
      emit(const ServiceCustomerFormState());
      return;
    }
    final result = await repository.getCustomer(context, id!);
    if (result case Success<ServiceCustomer?>(:final value)) {
      if (value == null) {
        emit(
          const ServiceCustomerFormState(failure: 'servicesCustomerNotFound'),
        );
        return;
      }
      emit(
        ServiceCustomerFormState(
          draft: ServiceCustomerDraft(
            name: value.name,
            kind: value.kind,
            mobile: value.mobile,
            alternateMobile: value.alternateMobile ?? '',
            email: value.email ?? '',
            notes: value.notes ?? '',
          ),
        ),
      );
    } else if (result case Failed<ServiceCustomer?>()) {
      emit(const ServiceCustomerFormState(failure: 'servicesStorage'));
    }
  }

  void change(ServiceCustomerDraft draft) =>
      emit(state.copyWith(draft: draft, clearFailure: true));

  Future<void> save() async {
    emit(state.copyWith(saving: true, clearFailure: true));
    final result = await repository.saveCustomer(context, state.draft, id: id);
    switch (result) {
      case Success<ServiceCustomer>(:final value):
        emit(state.copyWith(saving: false, saved: true, savedId: value.id));
      case Failed<ServiceCustomer>(:final failure):
        emit(state.copyWith(saving: false, failure: failure.code));
    }
  }
}
