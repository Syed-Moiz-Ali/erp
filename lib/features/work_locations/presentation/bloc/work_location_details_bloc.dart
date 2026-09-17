export '../../../../shared/workflows/record_details_bloc.dart';
import '../../../../shared/workflows/record_details_bloc.dart';
import '../../domain/work_location.dart';
import '../../domain/work_location_repository.dart';

class WorkLocationDetailsBloc
    extends RecordDetailsBloc<WorkLocation, WorkLocationDraft> {
  WorkLocationDetailsBloc(
    WorkLocationRepository super.repository,
    super.context,
    super.id,
  );
}

typedef WorkLocationDetailsState = RecordDetailsState<WorkLocation>;
