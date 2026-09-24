import 'package:get_it/get_it.dart';
import 'package:modular_erp/modules/services/configuration/data/local_service_master_repository.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master_repository.dart';
import 'package:modular_erp/modules/services/customers/data/local_service_customer_repository.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer_repository.dart';
import 'package:modular_erp/modules/services/enquiries/data/local_service_enquiry_repository.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry_repository.dart';
import 'package:modular_erp/modules/services/job_assignments/data/local_service_job_assignment_repository.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment_repository.dart';
import 'package:modular_erp/modules/services/sites/data/local_service_site_repository.dart';
import 'package:modular_erp/modules/services/sites/domain/service_site_repository.dart';
import 'package:modular_erp/modules/services/teams/data/local_service_team_repository.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team_repository.dart';

/// Services module dependency composition. Services owns its repositories; the
/// core bootstrap stays free of Services internals.
void configureServicesDependencies(GetIt services) {
  services.registerLazySingleton<ServiceCustomerRepository>(
    () => LocalServiceCustomerRepository(
      services(),
      services(),
      services(),
      services(),
    ),
  );
  services.registerLazySingleton<ServiceSiteRepository>(
    () => LocalServiceSiteRepository(
      services(),
      services(),
      services(),
      services(),
    ),
  );
  services.registerLazySingleton<ServiceTeamRepository>(
    () => LocalServiceTeamRepository(
      services(),
      services(),
      services(),
      services(),
      services(),
    ),
  );
  services.registerLazySingleton<ServiceMasterRepository>(
    () => LocalServiceMasterRepository(services(), services(), services()),
  );
  services.registerLazySingleton<ServiceEnquiryRepository>(
    () => LocalServiceEnquiryRepository(
      services(),
      services(),
      services(),
      services(),
      services(),
    ),
  );
  services.registerLazySingleton<ServiceJobAssignmentRepository>(
    () => LocalServiceJobAssignmentRepository(
      services(),
      services(),
      services(),
      services(),
      services(),
      services(),
      services(),
      notifications: services(),
    ),
  );
}
