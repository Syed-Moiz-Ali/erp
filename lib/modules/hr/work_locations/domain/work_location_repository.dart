import 'package:modular_erp/shared/domain/configuration_repository.dart';
import 'work_location.dart';

abstract interface class WorkLocationRepository
    implements ConfigurationRepository<WorkLocation, WorkLocationDraft> {}
