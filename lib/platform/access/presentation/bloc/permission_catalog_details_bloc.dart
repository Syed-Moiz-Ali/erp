export 'package:modular_erp/shared/workflows/record_details_bloc.dart';
import 'package:modular_erp/platform/access/presentation/permission_master_configuration_repository.dart';
import 'package:modular_erp/shared/workflows/record_details_bloc.dart';

class PermissionCatalogDetailsBloc
    extends RecordDetailsBloc<PermissionMasterRecord, PermissionMasterDraft> {
  PermissionCatalogDetailsBloc(
    PermissionMasterConfigurationRepository super.repository,
    super.context,
    super.id,
  );
}

typedef PermissionCatalogDetailsState =
    RecordDetailsState<PermissionMasterRecord>;
