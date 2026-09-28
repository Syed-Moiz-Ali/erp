import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution_repository.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

/// Enquiry workflow context: shows the Work Execution stage(s) linked through
/// the Enquiry → Job Assignment → Inspection lineage, when accessible.
class EnquiryWorkExecutionSection extends StatefulWidget {
  const EnquiryWorkExecutionSection({
    super.key,
    required this.repository,
    required this.enquiryId,
  });
  final ServiceWorkExecutionRepository repository;
  final String enquiryId;

  @override
  State<EnquiryWorkExecutionSection> createState() =>
      _EnquiryWorkExecutionSectionState();
}

class _EnquiryWorkExecutionSectionState
    extends State<EnquiryWorkExecutionSection> {
  List<ServiceWorkExecutionRef> _refs = const [];
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    final account = context.read<AuthBloc>().state.context;
    if (account == null) return;
    final result = await widget.repository.getExecutionsForEnquiry(
      account,
      widget.enquiryId,
    );
    if (!mounted) return;
    setState(() {
      _shown = true;
      _refs = result is Success<List<ServiceWorkExecutionRef>>
          ? result.value
          : const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    bool can(AppPermission p) => permissions?.contains(p) ?? false;
    final canView =
        can(AppPermission.serviceWorkExecutionViewAssigned) ||
        can(AppPermission.serviceWorkExecutionViewTeam) ||
        can(AppPermission.serviceWorkExecutionViewAll);
    if (!canView) return const SizedBox.shrink();
    final l = context.l10n;
    if (!_shown) return const SizedBox.shrink();
    final dates = AppDateFormatter(Localizations.localeOf(context));
    return AppSettingsSection(
      title: l.servicesEnquiryWorkExecutionSection,
      children: [
        if (_refs.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(l.servicesInspectionNoWorkExecution),
          )
        else
          for (final ref in _refs)
            AppSettingsRow(
              title: ref.executionNumber,
              description: [
                serviceWorkExecutionStatusLabel(ref.status, l),
                dates.date(ref.executionDate),
              ].join(' · '),
              icon: Icons.engineering_outlined,
              onPressed: () => context.go(ServicesRoutes.workExecution(ref.id)),
            ),
      ],
    );
  }
}
