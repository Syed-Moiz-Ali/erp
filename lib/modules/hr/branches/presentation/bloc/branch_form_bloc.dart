export 'package:modular_erp/shared/workflows/record_form_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/shared/workflows/record_form_bloc.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';
import 'package:modular_erp/modules/hr/branches/presentation/branch_configuration_repository.dart';

class BranchFormBloc extends RecordFormBloc<BranchRecord, BranchDraft> {
  BranchFormBloc(
    BranchConfigurationRepository super.repository,
    super.context, {
    super.id,
  }) : super(
         emptyDraft: const BranchDraft(status: BranchStatus.active),
         fromRecord: (record) => BranchDraft.fromBranch(record.branch),
         normalize: (d) => d.normalized(),
         validate: (d) => d.validate(),
         serverFieldErrors: _serverFieldErrors,
       );

  static Map<String, String> _serverFieldErrors(Failure failure) {
    final message = failure.serverMessage?.toLowerCase() ?? '';
    if (failure.code == 'BRANCH_DUPLICATE_NAME' ||
        failure.code == 'duplicateName') {
      return const {'branchName': 'duplicateName'};
    }
    if (failure.code == 'VALIDATION_ERROR' || failure.code == 'validation') {
      return switch (failure.field) {
        'timeZoneId' => const {'timeZoneId': 'invalidTimeZone'},
        'branchName' => {
          'branchName': message.contains('100') || message.contains('character')
              ? 'tooLong'
              : 'required',
        },
        _ => const {},
      };
    }
    return switch (failure.field) {
      'branchName' => {'branchName': failure.code},
      'timeZoneId' => {
        'timeZoneId': failure.code == 'required'
            ? 'required'
            : 'invalidTimeZone',
      },
      _ => const {},
    };
  }
}

typedef BranchFormState = RecordFormState<BranchDraft>;
