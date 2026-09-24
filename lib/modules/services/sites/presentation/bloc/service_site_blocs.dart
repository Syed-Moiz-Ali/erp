import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer_repository.dart';
import 'package:modular_erp/modules/services/sites/domain/service_site.dart';
import 'package:modular_erp/modules/services/sites/domain/service_site_repository.dart';

class ServiceSiteListState {
  const ServiceSiteListState({
    this.loading = true,
    this.page,
    this.failure,
    this.query = '',
    this.status,
  });
  final bool loading;
  final ServiceSitePage? page;
  final String? failure;
  final String query;
  final ConfigurationStatus? status;
}

class ServiceSiteListCubit extends Cubit<ServiceSiteListState> {
  ServiceSiteListCubit(this.repository, this.context)
    : super(const ServiceSiteListState());
  final ServiceSiteRepository repository;
  final AuthContext context;
  StreamSubscription<Result<ServiceSitePage>>? _sub;

  void start() => _subscribe();
  void search(String query) {
    emit(
      ServiceSiteListState(loading: true, query: query, status: state.status),
    );
    _subscribe();
  }

  void setStatus(ConfigurationStatus? status) {
    emit(
      ServiceSiteListState(loading: true, query: state.query, status: status),
    );
    _subscribe();
  }

  Future<Result<void>> setActive(String id, bool active) =>
      repository.setActive(context, id, active);

  void _subscribe() {
    unawaited(_sub?.cancel());
    _sub = repository
        .watchSites(context, query: state.query, status: state.status)
        .listen((result) {
          switch (result) {
            case Success<ServiceSitePage>(:final value):
              emit(
                ServiceSiteListState(
                  loading: false,
                  page: value,
                  query: state.query,
                  status: state.status,
                ),
              );
            case Failed<ServiceSitePage>(:final failure):
              emit(
                ServiceSiteListState(
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

class ServiceSiteDetailState {
  const ServiceSiteDetailState({
    this.loading = true,
    this.site,
    this.customer,
    this.failure,
  });
  final bool loading;
  final ServiceSite? site;
  final ServiceCustomer? customer;
  final String? failure;
}

class ServiceSiteDetailCubit extends Cubit<ServiceSiteDetailState> {
  ServiceSiteDetailCubit(
    this.repository,
    this.customerRepository,
    this.context,
    this.id,
  ) : super(const ServiceSiteDetailState());
  final ServiceSiteRepository repository;
  final ServiceCustomerRepository customerRepository;
  final AuthContext context;
  final String id;
  StreamSubscription<Result<ServiceSite?>>? _sub;

  void start() {
    _sub = repository.watchSite(context, id).listen((result) async {
      switch (result) {
        case Success<ServiceSite?>(:final value):
          ServiceCustomer? customer;
          if (value != null) {
            final c = await customerRepository.getCustomer(
              context,
              value.customerId,
            );
            if (c case Success<ServiceCustomer?>(:final value)) {
              customer = value;
            }
          }
          emit(
            ServiceSiteDetailState(
              loading: false,
              site: value,
              customer: customer,
            ),
          );
        case Failed<ServiceSite?>(:final failure):
          emit(ServiceSiteDetailState(loading: false, failure: failure.code));
      }
    });
  }

  Future<Result<void>> setActive(bool active) =>
      repository.setActive(context, id, active);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}

class ServiceSiteFormState {
  const ServiceSiteFormState({
    this.loading = false,
    this.saving = false,
    this.saved = false,
    this.savedId,
    this.failure,
    this.customers = const [],
    this.draft = const ServiceSiteDraft(),
  });
  final bool loading, saving, saved;
  final String? savedId, failure;
  final List<ServiceCustomerRef> customers;
  final ServiceSiteDraft draft;

  ServiceSiteFormState copyWith({
    bool? loading,
    bool? saving,
    bool? saved,
    String? savedId,
    String? failure,
    bool clearFailure = false,
    List<ServiceCustomerRef>? customers,
    ServiceSiteDraft? draft,
  }) => ServiceSiteFormState(
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
    savedId: savedId ?? this.savedId,
    failure: clearFailure ? null : (failure ?? this.failure),
    customers: customers ?? this.customers,
    draft: draft ?? this.draft,
  );
}

class ServiceSiteFormCubit extends Cubit<ServiceSiteFormState> {
  ServiceSiteFormCubit(
    this.repository,
    this.customerRepository,
    this.context,
    this.id, {
    this.preselectedCustomerId,
  }) : super(ServiceSiteFormState(loading: id != null));
  final ServiceSiteRepository repository;
  final ServiceCustomerRepository customerRepository;
  final AuthContext context;
  final String? id;
  final String? preselectedCustomerId;

  Future<void> init() async {
    final refs = await customerRepository.searchReferences(context, limit: 100);
    final customers = refs is Success<List<ServiceCustomerRef>>
        ? refs.value
        : const <ServiceCustomerRef>[];
    if (id == null) {
      emit(
        ServiceSiteFormState(
          customers: customers,
          draft: ServiceSiteDraft(customerId: preselectedCustomerId),
        ),
      );
      return;
    }
    final result = await repository.getSite(context, id!);
    if (result case Success<ServiceSite?>(:final value)) {
      if (value == null) {
        emit(const ServiceSiteFormState(failure: 'servicesSiteNotFound'));
        return;
      }
      emit(
        ServiceSiteFormState(
          customers: customers,
          draft: ServiceSiteDraft(
            customerId: value.customerId,
            siteName: value.siteName,
            tenantName: value.tenantName ?? '',
            buildingName: value.buildingName ?? '',
            unitNumber: value.unitNumber ?? '',
            contactName: value.contactName ?? '',
            contactMobile: value.contactMobile ?? '',
            contactEmail: value.contactEmail ?? '',
            addressLine1: value.addressLine1,
            addressLine2: value.addressLine2 ?? '',
            area: value.area ?? '',
            city: value.city,
            state: value.state ?? '',
            postalCode: value.postalCode ?? '',
            countryCode: value.countryCode ?? '',
            latitude: value.latitude?.toString() ?? '',
            longitude: value.longitude?.toString() ?? '',
            notes: value.notes ?? '',
          ),
        ),
      );
    } else {
      emit(const ServiceSiteFormState(failure: 'servicesStorage'));
    }
  }

  void change(ServiceSiteDraft draft) =>
      emit(state.copyWith(draft: draft, clearFailure: true));

  Future<void> save() async {
    emit(state.copyWith(saving: true, clearFailure: true));
    final result = await repository.saveSite(context, state.draft, id: id);
    switch (result) {
      case Success<ServiceSite>(:final value):
        emit(state.copyWith(saving: false, saved: true, savedId: value.id));
      case Failed<ServiceSite>(:final failure):
        emit(state.copyWith(saving: false, failure: failure.code));
    }
  }
}
