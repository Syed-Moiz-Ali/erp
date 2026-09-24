import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master_repository.dart';

class ServiceMasterListState {
  const ServiceMasterListState({
    this.loading = true,
    this.page,
    this.failure,
    this.query = '',
  });
  final bool loading;
  final ServiceMasterPage? page;
  final String? failure;
  final String query;
}

class ServiceMasterListCubit extends Cubit<ServiceMasterListState> {
  ServiceMasterListCubit(this.repository, this.kind, this.context)
    : super(const ServiceMasterListState());
  final ServiceMasterRepository repository;
  final ServiceMasterKind kind;
  final AuthContext context;
  StreamSubscription<Result<ServiceMasterPage>>? _sub;

  void start() => _subscribe();
  void search(String query) {
    emit(ServiceMasterListState(loading: true, query: query));
    _subscribe();
  }

  void _subscribe() {
    unawaited(_sub?.cancel());
    _sub = repository.watchList(kind, context, query: state.query).listen((
      result,
    ) {
      switch (result) {
        case Success<ServiceMasterPage>(:final value):
          emit(
            ServiceMasterListState(
              loading: false,
              page: value,
              query: state.query,
            ),
          );
        case Failed<ServiceMasterPage>(:final failure):
          emit(
            ServiceMasterListState(
              loading: false,
              failure: failure.code,
              query: state.query,
            ),
          );
      }
    });
  }

  Future<void> setActive(String id, bool active) =>
      repository.setActive(kind, context, id, active);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}

class ServiceMasterFormState {
  const ServiceMasterFormState({
    this.loading = false,
    this.saving = false,
    this.saved = false,
    this.failure,
    this.draft = const ServiceMasterDraft(),
    this.serviceTypes = const [],
  });
  final bool loading, saving, saved;
  final String? failure;
  final ServiceMasterDraft draft;
  final List<ServiceMasterRecord> serviceTypes;

  ServiceMasterFormState copyWith({
    bool? loading,
    bool? saving,
    bool? saved,
    String? failure,
    bool clearFailure = false,
    ServiceMasterDraft? draft,
    List<ServiceMasterRecord>? serviceTypes,
  }) => ServiceMasterFormState(
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
    failure: clearFailure ? null : (failure ?? this.failure),
    draft: draft ?? this.draft,
    serviceTypes: serviceTypes ?? this.serviceTypes,
  );
}

class ServiceMasterFormCubit extends Cubit<ServiceMasterFormState> {
  ServiceMasterFormCubit(this.repository, this.kind, this.context, this.id)
    : super(ServiceMasterFormState(loading: id != null));
  final ServiceMasterRepository repository;
  final ServiceMasterKind kind;
  final AuthContext context;
  final String? id;

  Future<void> init() async {
    var serviceTypes = const <ServiceMasterRecord>[];
    if (kind == ServiceMasterKind.complaintType) {
      final types = await repository
          .watchList(ServiceMasterKind.serviceType, context, pageSize: 100)
          .first;
      if (types case Success<ServiceMasterPage>(:final value)) {
        serviceTypes = value.items;
      }
    }
    if (id == null) {
      emit(ServiceMasterFormState(serviceTypes: serviceTypes));
      return;
    }
    final result = await repository.getById(kind, context, id!);
    if (result case Success<ServiceMasterRecord?>(:final value)) {
      if (value == null) {
        emit(
          ServiceMasterFormState(
            serviceTypes: serviceTypes,
            failure: 'servicesMasterNotFound',
          ),
        );
        return;
      }
      emit(
        ServiceMasterFormState(
          serviceTypes: serviceTypes,
          draft: ServiceMasterDraft(
            code: value.code,
            name: value.name,
            description: value.description ?? '',
            sortOrder: '${value.sortOrder}',
            rank: '${value.rank}',
            isDefault: value.isDefault,
            serviceTypeId: value.serviceTypeId,
          ),
        ),
      );
    } else {
      emit(
        ServiceMasterFormState(
          serviceTypes: serviceTypes,
          failure: 'servicesStorage',
        ),
      );
    }
  }

  void change(ServiceMasterDraft draft) =>
      emit(state.copyWith(draft: draft, clearFailure: true));

  Future<void> save() async {
    emit(state.copyWith(saving: true, clearFailure: true));
    final result = await repository.save(kind, context, state.draft, id: id);
    switch (result) {
      case Success<ServiceMasterRecord>():
        emit(state.copyWith(saving: false, saved: true));
      case Failed<ServiceMasterRecord>(:final failure):
        emit(state.copyWith(saving: false, failure: failure.code));
    }
  }
}
