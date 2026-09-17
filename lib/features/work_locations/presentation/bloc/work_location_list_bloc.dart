export '../../../../shared/workflows/record_list_bloc.dart';
import '../../../../shared/workflows/record_list_bloc.dart';
import '../../domain/work_location.dart';
import '../../domain/work_location_repository.dart';

class WorkLocationListBloc
    extends RecordListBloc<WorkLocation, WorkLocationDraft> {
  WorkLocationListBloc(WorkLocationRepository super.repository, super.context);
}

typedef WorkLocationListState = RecordListState<WorkLocation>;
