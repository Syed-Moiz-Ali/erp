import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/location/location_service.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location_repository.dart';
import 'package:modular_erp/shared/workflows/record_form_bloc.dart';
export 'package:modular_erp/shared/workflows/record_form_bloc.dart';

sealed class WorkLocationAction extends RecordFormEvent<WorkLocationDraft> {
  const WorkLocationAction();
}

class CaptureCurrentLocation extends WorkLocationAction {
  const CaptureCurrentLocation();
}

class OpenLocationSettings extends WorkLocationAction {
  const OpenLocationSettings();
}

class WorkLocationFormState extends RecordFormState<WorkLocationDraft> {
  const WorkLocationFormState({
    required super.draft,
    required super.original,
    super.loading,
    super.ready,
    super.assignedEmployees,
    super.saving,
    super.validationRequested,
    super.failure,
    super.savedId,
    super.fieldErrors,
    this.locating = false,
    this.capturedAccuracy,
    this.captureVersion = 0,
    this.locationFailure,
  });
  final bool locating;
  final double? capturedAccuracy;
  final int captureVersion;
  final Failure? locationFailure;
}

/// Capture and configuration submission share one serialized workflow. Location
/// permission is requested exclusively for CaptureCurrentLocation user actions.
class WorkLocationFormBloc
    extends Bloc<RecordFormEvent<WorkLocationDraft>, WorkLocationFormState> {
  WorkLocationFormBloc(
    this.repository,
    this.context,
    this.locationService, {
    this.id,
  }) : super(
         const WorkLocationFormState(
           draft: WorkLocationDraft(),
           original: WorkLocationDraft(),
         ),
       ) {
    on<RecordFormEvent<WorkLocationDraft>>(
      _handle,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }
  final WorkLocationRepository repository;
  final AuthContext context;
  final LocationService locationService;
  final String? id;
  bool _submitQueued = false, _captureQueued = false;
  @override
  void add(RecordFormEvent<WorkLocationDraft> event) {
    if (isClosed) return;
    if (event is RecordSubmitted<WorkLocationDraft>) {
      if (_submitQueued) return;
      _submitQueued = true;
    }
    if (event is CaptureCurrentLocation) {
      if (_captureQueued) return;
      _captureQueued = true;
    }
    super.add(event);
  }

  WorkLocationFormState next({
    WorkLocationDraft? draft,
    WorkLocationDraft? original,
    bool? loading,
    bool? ready,
    int? assignedEmployees,
    bool? saving,
    bool? locating,
    bool? validationRequested,
    Failure? failure,
    Failure? locationFailure,
    String? savedId,
    Map<String, String>? errors,
    double? accuracy,
    int? captureVersion,
  }) => WorkLocationFormState(
    draft: draft ?? state.draft,
    original: original ?? state.original,
    loading: loading ?? state.loading,
    ready: ready ?? state.ready,
    assignedEmployees: assignedEmployees ?? state.assignedEmployees,
    saving: saving ?? state.saving,
    locating: locating ?? state.locating,
    validationRequested: validationRequested ?? state.validationRequested,
    failure: failure,
    locationFailure: locationFailure,
    savedId: savedId,
    fieldErrors: errors ?? state.fieldErrors,
    capturedAccuracy: accuracy ?? state.capturedAccuracy,
    captureVersion: captureVersion ?? state.captureVersion,
  );
  Future<void> _handle(
    RecordFormEvent<WorkLocationDraft> event,
    Emitter<WorkLocationFormState> emit,
  ) async {
    switch (event) {
      case RecordFormInitialized<WorkLocationDraft>():
        emit(next(loading: true));
        if (id == null) {
          emit(next(loading: false, ready: true));
          return;
        }
        final result = await repository.getById(context, id!, forEditing: true);
        if (result is Success<WorkLocation?> && result.value != null) {
          final count = await repository.assignedEmployeeCount(context, id!);
          if (count is Failed<int>) {
            emit(next(loading: false, failure: count.failure));
            return;
          }
          final draft = WorkLocationDraft.fromLocation(result.value!);
          emit(
            next(
              draft: draft,
              original: draft,
              loading: false,
              ready: true,
              assignedEmployees: (count as Success<int>).value,
            ),
          );
        } else {
          emit(
            next(
              loading: false,
              failure: result is Failed<WorkLocation?>
                  ? result.failure
                  : const Failure(code: 'notFound'),
            ),
          );
        }
      case RecordDraftChanged<WorkLocationDraft>(:final update):
        if (state.loading || state.saving || !state.ready) return;
        final draft = update(state.draft).normalized();
        emit(
          next(
            draft: draft,
            errors: state.validationRequested ? draft.validate() : const {},
          ),
        );
      case RecordSubmitted<WorkLocationDraft>():
        if (state.loading || !state.ready || state.savedId != null) {
          _submitQueued = false;
          return;
        }
        final draft = state.draft.normalized(), errors = draft.validate();
        if (errors.isNotEmpty) {
          emit(
            next(
              validationRequested: true,
              errors: errors,
              failure: const Failure(code: 'validation'),
            ),
          );
          _submitQueued = false;
          return;
        }
        emit(next(saving: true, validationRequested: true));
        final result = await repository.save(context, draft, id: id);
        emit(
          next(
            saving: false,
            savedId: result is Success<WorkLocation> ? result.value.id : null,
            failure: result is Failed<WorkLocation> ? result.failure : null,
            errors:
                result is Failed<WorkLocation> &&
                    result.failure.code == 'duplicateName'
                ? const {'name': 'duplicateName'}
                : const {},
          ),
        );
        _submitQueued = false;
      case CaptureCurrentLocation():
        if (state.loading || state.saving) {
          _captureQueued = false;
          return;
        }
        emit(next(locating: true));
        final result = await locationService.currentPosition(
          requestPermission: true,
        );
        if (result is Success<Position> &&
            result.value.latitude.isFinite &&
            result.value.longitude.isFinite &&
            result.value.latitude.abs() <= 90 &&
            result.value.longitude.abs() <= 180 &&
            result.value.accuracy.isFinite &&
            result.value.accuracy >= 0) {
          final draft = state.draft.copyWith(
            latitude: result.value.latitude,
            longitude: result.value.longitude,
          );
          emit(
            next(
              draft: draft,
              locating: false,
              accuracy: result.value.accuracy,
              captureVersion: state.captureVersion + 1,
              errors: state.validationRequested ? draft.validate() : const {},
            ),
          );
        } else {
          emit(
            next(
              locating: false,
              locationFailure: result is Failed<Position>
                  ? result.failure
                  : const Failure(
                      code: 'location_unavailable',
                      kind: FailureKind.locationUnavailable,
                    ),
            ),
          );
        }
        _captureQueued = false;
      case OpenLocationSettings():
        final result = await locationService.openSettings(
          locationSettings:
              state.locationFailure?.kind == FailureKind.locationDisabled,
        );
        if (result is Failed<bool>) emit(next(locationFailure: result.failure));
      default:
        break;
    }
  }
}
