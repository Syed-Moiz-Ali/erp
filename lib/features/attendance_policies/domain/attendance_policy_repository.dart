import '../../../shared/domain/configuration_repository.dart';
import 'attendance_policy.dart';

abstract interface class AttendancePolicyRepository
    implements
        ConfigurationRepository<AttendancePolicy, AttendancePolicyDraft> {}
