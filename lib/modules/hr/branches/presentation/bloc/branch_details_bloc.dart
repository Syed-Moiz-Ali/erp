export 'package:modular_erp/shared/workflows/record_details_bloc.dart';
import 'package:modular_erp/shared/workflows/record_details_bloc.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';
import 'package:modular_erp/modules/hr/branches/presentation/branch_configuration_repository.dart';

class BranchDetailsBloc extends RecordDetailsBloc<BranchRecord, BranchDraft> {
  BranchDetailsBloc(
    BranchConfigurationRepository super.repository,
    super.context,
    super.id,
  );
}

typedef BranchDetailsState = RecordDetailsState<BranchRecord>;
