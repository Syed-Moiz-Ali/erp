export 'package:modular_erp/shared/workflows/record_list_bloc.dart';
import 'package:modular_erp/shared/workflows/record_list_bloc.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';
import 'package:modular_erp/modules/hr/branches/presentation/branch_configuration_repository.dart';

class BranchListBloc extends RecordListBloc<BranchRecord, BranchDraft> {
  BranchListBloc(BranchConfigurationRepository super.repository, super.context);
}

typedef BranchListState = RecordListState<BranchRecord>;
