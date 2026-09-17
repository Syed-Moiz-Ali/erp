import '../../../shared/domain/configuration_repository.dart';
import 'shift.dart';

abstract interface class ShiftRepository
    implements ConfigurationRepository<Shift, ShiftDraft> {}
