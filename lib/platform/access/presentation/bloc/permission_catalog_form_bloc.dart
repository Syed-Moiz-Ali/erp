export 'package:modular_erp/shared/workflows/record_form_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/access/presentation/permission_master_configuration_repository.dart';
import 'package:modular_erp/shared/workflows/record_form_bloc.dart';

class PermissionCatalogFormBloc
    extends RecordFormBloc<PermissionMasterRecord, PermissionMasterDraft> {
  PermissionCatalogFormBloc(
    PermissionMasterConfigurationRepository super.repository,
    super.context, {
    super.id,
  }) : super(
         emptyDraft: const PermissionMasterDraft(),
         fromRecord: (record) => PermissionMasterDraft.fromRecord(record),
         normalize: (draft) => draft.normalized(),
         validate: (draft) => draft.validate(),
         serverFieldErrors: _serverFieldErrors,
       );

  static Map<String, String> _serverFieldErrors(Failure failure) {
    if (failure.code == 'PERMISSION_DUPLICATE_KEY') {
      return const {'permissionKey': 'duplicatePermissionKey'};
    }
    if (failure.code == 'PERMISSION_ALREADY_ACTIVE' ||
        failure.code == 'PERMISSION_ALREADY_INACTIVE') {
      return const {};
    }
    if (failure.code == 'VALIDATION_ERROR') {
      final field = failure.field;
      if (field == 'permissionKey') {
        return const {'permissionKey': 'invalidPermissionKey'};
      }
      if (field == 'permissionName') {
        return const {'permissionName': 'required'};
      }
      if (field != null) return {field: failure.code};
      return const {};
    }
    final field = failure.field;
    if (field != null) return {field: failure.code};
    return const {};
  }
}

typedef PermissionCatalogFormState = RecordFormState<PermissionMasterDraft>;
