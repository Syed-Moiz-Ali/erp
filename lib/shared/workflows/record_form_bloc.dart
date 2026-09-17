import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/errors/result.dart';
import '../../core/models/configuration_record.dart';
import '../../features/auth/domain/entities/auth_context.dart';
import '../domain/configuration_repository.dart';

abstract class RecordFormEvent<D> {
  const RecordFormEvent();
}

class RecordFormInitialized<D> extends RecordFormEvent<D> {
  const RecordFormInitialized();
}

class RecordDraftChanged<D> extends RecordFormEvent<D> {
  const RecordDraftChanged(this.update);
  final D Function(D) update;
}

class RecordSubmitted<D> extends RecordFormEvent<D> {
  const RecordSubmitted();
}

class RecordFormState<D> {
  const RecordFormState({
    required this.draft,
    required this.original,
    this.loading = true,
    this.saving = false,
    this.validationRequested = false,
    this.failure,
    this.savedId,
    this.fieldErrors = const {},
  });
  final D draft, original;
  final bool loading, saving, validationRequested;
  final Failure? failure;
  final String? savedId;
  final Map<String, String> fieldErrors;
  bool get dirty => draft != original && savedId == null;
}

class RecordFormBloc<T extends ConfigurationRecord, D>
    extends Bloc<RecordFormEvent<D>, RecordFormState<D>> {
  RecordFormBloc(
    this.repository,
    this.context, {
    required D emptyDraft,
    required this.fromRecord,
    required this.normalize,
    required this.validate,
    this.id,
  }) : super(RecordFormState(draft: emptyDraft, original: emptyDraft)) {
    on<RecordFormEvent<D>>(
      _handle,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }
  final ConfigurationRepository<T, D> repository;
  final AuthContext context;
  final String? id;
  final D Function(T) fromRecord;
  final D Function(D) normalize;
  final Map<String, String> Function(D) validate;
  bool _submissionQueued = false;
  @override
  void add(RecordFormEvent<D> event) {
    if (isClosed) return;
    if (event is RecordSubmitted<D>) {
      if (_submissionQueued) return;
      _submissionQueued = true;
    }
    super.add(event);
  }

  RecordFormState<D> next({
    D? draft,
    D? original,
    bool? loading,
    bool? saving,
    bool? validationRequested,
    Failure? failure,
    String? savedId,
    Map<String, String>? errors,
  }) => RecordFormState(
    draft: draft ?? state.draft,
    original: original ?? state.original,
    loading: loading ?? state.loading,
    saving: saving ?? state.saving,
    validationRequested: validationRequested ?? state.validationRequested,
    failure: failure,
    savedId: savedId,
    fieldErrors: errors ?? state.fieldErrors,
  );
  Future<void> _handle(
    RecordFormEvent<D> event,
    Emitter<RecordFormState<D>> emit,
  ) async {
    switch (event) {
      case RecordFormInitialized<D>():
        emit(next(loading: true));
        if (id == null) {
          emit(next(loading: false));
          return;
        }
        final result = await repository.getById(context, id!, forEditing: true);
        if (result is Success<T?> && result.value != null) {
          final draft = fromRecord(result.value!);
          emit(
            next(
              draft: draft,
              original: draft,
              loading: false,
              errors: const {},
            ),
          );
        } else {
          emit(
            next(
              loading: false,
              failure: result is Failed<T?>
                  ? result.failure
                  : const Failure(code: 'notFound'),
            ),
          );
        }
      case RecordDraftChanged<D>(:final update):
        if (state.saving || state.loading) return;
        final draft = normalize(update(state.draft));
        emit(
          next(
            draft: draft,
            errors: state.validationRequested ? validate(draft) : const {},
          ),
        );
      case RecordSubmitted<D>():
        if (state.loading || state.savedId != null) {
          _submissionQueued = false;
          return;
        }
        final draft = normalize(state.draft), errors = validate(draft);
        if (errors.isNotEmpty) {
          emit(
            next(
              draft: draft,
              validationRequested: true,
              errors: errors,
              failure: const Failure(code: 'validation'),
            ),
          );
          _submissionQueued = false;
          return;
        }
        emit(
          next(
            draft: draft,
            saving: true,
            validationRequested: true,
            errors: const {},
          ),
        );
        final result = await repository.save(context, draft, id: id);
        emit(
          next(
            saving: false,
            failure: result is Failed<T> ? result.failure : null,
            savedId: result is Success<T> ? result.value.id : null,
            errors:
                result is Failed<T> && result.failure.code == 'duplicateName'
                ? const {'name': 'duplicateName'}
                : const {},
          ),
        );
        _submissionQueued = false;
    }
  }
}
