export 'package:modular_erp/shared/workflows/record_list_bloc.dart';
import 'package:modular_erp/platform/access/presentation/permission_master_configuration_repository.dart';
import 'package:modular_erp/shared/workflows/record_list_bloc.dart';

class PermissionCatalogListBloc
    extends RecordListBloc<PermissionMasterRecord, PermissionMasterDraft> {
  PermissionCatalogListBloc(
    PermissionMasterConfigurationRepository super.repository,
    super.context,
  );
}

typedef PermissionCatalogListState = RecordListState<PermissionMasterRecord>;
