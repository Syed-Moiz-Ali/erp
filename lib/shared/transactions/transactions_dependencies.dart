import 'package:get_it/get_it.dart';
import 'package:modular_erp/shared/transactions/data/local_activity_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_attachment_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_document_number_service.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';
import 'package:modular_erp/shared/transactions/domain/attachment_repository.dart';
import 'package:modular_erp/shared/transactions/domain/document_number_service.dart';
import 'package:modular_erp/shared/transactions/domain/transaction_runner.dart';

/// Shared transaction infrastructure (numbering, attachments, activity).
/// Consumed by future business modules; registered once, not in global
/// bootstrap feature code.
void configureTransactionDependencies(GetIt services) {
  services.registerLazySingleton<DocumentNumberService>(
    () => LocalDocumentNumberService(services(), services()),
  );
  services.registerLazySingleton<AttachmentRepository>(
    () => LocalAttachmentRepository(services(), services()),
  );
  services.registerLazySingleton<ActivityRepository>(
    () => LocalActivityRepository(services()),
  );
  services.registerLazySingleton<TransactionRunner>(
    () => LocalTransactionRunner(services()),
  );
}
