export 'package:modular_erp/shared/workflows/record_details_bloc.dart';
import 'package:modular_erp/shared/workflows/record_details_bloc.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location_repository.dart';

class WorkLocationDetailsBloc
    extends RecordDetailsBloc<WorkLocation, WorkLocationDraft> {
  WorkLocationDetailsBloc(
    WorkLocationRepository super.repository,
    super.context,
    super.id,
  );
}

typedef WorkLocationDetailsState = RecordDetailsState<WorkLocation>;
