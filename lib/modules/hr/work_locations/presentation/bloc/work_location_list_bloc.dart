export 'package:modular_erp/shared/workflows/record_list_bloc.dart';
import 'package:modular_erp/shared/workflows/record_list_bloc.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location_repository.dart';

class WorkLocationListBloc
    extends RecordListBloc<WorkLocation, WorkLocationDraft> {
  WorkLocationListBloc(WorkLocationRepository super.repository, super.context);
}

typedef WorkLocationListState = RecordListState<WorkLocation>;
