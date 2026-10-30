import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch_repository.dart';
import 'package:modular_erp/modules/hr/branches/presentation/bloc/branch_form_bloc.dart';
import 'package:modular_erp/shared/navigation/form_navigation_guard.dart';
import 'package:modular_erp/shared/presentation/configuration_form_binding.dart';
import 'package:modular_erp/shared/presentation/configuration_layouts.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';

class BranchFormPage extends StatefulWidget {
  const BranchFormPage({
    super.key,
    required this.guard,
    required this.branchRepository,
  });
  final FormNavigationGuard guard;
  final BranchRepository branchRepository;

  @override
  State<BranchFormPage> createState() => _BranchFormPageState();
}

class _BranchFormPageState extends State<BranchFormPage> {
  late Future<Result<BranchLookups>> _lookups;

  @override
  void initState() {
    super.initState();
    _lookups = widget.branchRepository.lookups();
  }

  void _retryLookups() {
    setState(() => _lookups = widget.branchRepository.lookups());
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<BranchFormBloc, BranchFormState>(
        listener: (c, s) {
          if (s.savedId != null) {
            widget.guard.dirty = false;
            widget.guard.saving = false;
            AppFeedback.showMessage(c, message: (l) => l.cfgSaved);
            c.go(
              c.read<BranchFormBloc>().context.user.permissions.contains(
                    AppPermission.companyBranchView,
                  )
                  ? AppRoutes.branchesDetails(s.savedId!)
                  : AppRoutes.dashboard,
            );
          }
        },
        builder: (c, s) {
          final l = c.l10n, bloc = c.read<BranchFormBloc>(), d = s.draft;
          void change(BranchDraft Function(BranchDraft) update) =>
              bloc.add(RecordDraftChanged<BranchDraft>(update));
          String? error(String field) => s.fieldErrors[field] == null
              ? null
              : configurationFailure(Failure(code: s.fieldErrors[field]!), l);
          return ConfigurationFormBinding(
            guard: widget.guard,
            account: bloc.context,
            dirty: s.dirty,
            saving: s.saving,
            child: ConfigurationFormLayout(
              title: [
                l.cfgBranches,
                bloc.id == null ? l.cfgNew : l.cfgEdit,
              ].join(' · '),
              loading: s.loading,
              ready: s.ready,
              saving: s.saving,
              failure: s.failure,
              onSave: () async {
                if (bloc.id != null &&
                    s.original.status == BranchStatus.active &&
                    d.status == BranchStatus.inactive &&
                    !await confirmConfigurationStatus(
                      c,
                      false,
                      s.assignedEmployees,
                    )) {
                  return;
                }
                if (c.mounted) {
                  bloc.add(const RecordSubmitted<BranchDraft>());
                }
              },
              onCancel: () => c.go(
                bloc.context.user.permissions.contains(
                      AppPermission.companyBranchView,
                    )
                    ? AppRoutes.branches
                    : AppRoutes.dashboard,
              ),
              onRetry: () => bloc.add(
                s.validationRequested
                    ? const RecordSubmitted<BranchDraft>()
                    : const RecordFormInitialized<BranchDraft>(),
              ),
              content: FutureBuilder<Result<BranchLookups>>(
                future: _lookups,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const AppLoadingState();
                  }
                  final result = snapshot.data;
                  if (result is Failed<BranchLookups>) {
                    return AppErrorState(
                      message: configurationFailure(result.failure, l),
                      onRetry: _retryLookups,
                    );
                  }
                  final lookups = (result as Success<BranchLookups>).value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppFormSection(
                        title: l.cfgGeneralRules,
                        child: AppFormGrid(
                          children: [
                            AppTextField(
                              label: l.cfgName,
                              initialValue: d.branchName,
                              enabled: !s.saving,
                              required: true,
                              errorText: error('branchName'),
                              onChanged: (v) =>
                                  change((d) => d.copyWith(branchName: v)),
                            ),
                            AppTextField(
                              label: l.cfgBranchCode,
                              initialValue: d.branchCode,
                              enabled: !s.saving,
                              errorText: error('branchCode'),
                              onChanged: (v) =>
                                  change((d) => d.copyWith(branchCode: v)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      AppFormSection(
                        title: l.cfgBranchLocationSection,
                        child: AppFormGrid(
                          children: [
                            AppSelectField<String>(
                              label: l.cfgBranchTimeZone,
                              value: d.timeZoneId,
                              required: true,
                              enabled: !s.saving,
                              errorText: error('timeZoneId'),
                              options: [
                                for (final zone in lookups.timeZones)
                                  AppSelectOption(
                                    zone.id,
                                    zone.utcOffset.trim().isEmpty
                                        ? zone.name
                                        : '${zone.name} · ${zone.utcOffset}',
                                  ),
                              ],
                              onChanged: (v) => change(
                                (d) => d.copyWith(
                                  timeZoneId: v,
                                  clearTimeZoneId: v == null,
                                ),
                              ),
                            ),
                            AppSelectField<int>(
                              label: l.cfgBranchDivision,
                              value: d.divisionId,
                              enabled: !s.saving,
                              errorText: error('divisionId'),
                              options: [
                                for (final division in lookups.divisions)
                                  AppSelectOption(division.id, division.name),
                              ],
                              onChanged: (v) => change(
                                (d) => d.copyWith(
                                  divisionId: v,
                                  clearDivisionId: v == null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      AppFormSection(
                        title: l.cfgBranchContactSection,
                        child: AppFormGrid(
                          children: [
                            AppTextField(
                              label: l.cfgBranchContactPerson,
                              initialValue: d.contactPerson,
                              enabled: !s.saving,
                              errorText: error('contactPerson'),
                              onChanged: (v) =>
                                  change((d) => d.copyWith(contactPerson: v)),
                            ),
                            AppTextField(
                              label: l.cfgBranchMobile,
                              initialValue: d.mobileNo,
                              enabled: !s.saving,
                              keyboardType: TextInputType.phone,
                              errorText: error('mobileNo'),
                              onChanged: (v) =>
                                  change((d) => d.copyWith(mobileNo: v)),
                            ),
                            AppTextField(
                              label: l.cfgBranchLandLine,
                              initialValue: d.landLine,
                              enabled: !s.saving,
                              keyboardType: TextInputType.phone,
                              errorText: error('landLine'),
                              onChanged: (v) =>
                                  change((d) => d.copyWith(landLine: v)),
                            ),
                            AppTextField(
                              label: l.cfgBranchEmail,
                              initialValue: d.email,
                              enabled: !s.saving,
                              keyboardType: TextInputType.emailAddress,
                              errorText: error('email'),
                              onChanged: (v) =>
                                  change((d) => d.copyWith(email: v)),
                            ),
                            AppTextField(
                              label: l.cfgAddress,
                              initialValue: d.address,
                              enabled: !s.saving,
                              maxLines: 3,
                              errorText: error('address'),
                              onChanged: (v) =>
                                  change((d) => d.copyWith(address: v)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      AppFormSection(
                        title: l.cfgBranchInventorySection,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppBooleanSettingRow(
                              label: l.cfgBranchInventoryAlerts,
                              value: _isYes(d.inventoryAlerts),
                              onChanged: s.saving
                                  ? null
                                  : (value) => change(
                                      (d) => d.copyWith(
                                        inventoryAlerts: value ? 'Yes' : 'No',
                                      ),
                                    ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppBooleanSettingRow(
                              label: l.cfgBranchMultiInventory,
                              value: _isYes(d.multiInventory),
                              onChanged: s.saving
                                  ? null
                                  : (value) => change(
                                      (d) => d.copyWith(
                                        multiInventory: value ? 'Yes' : 'No',
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      AppFormSection(
                        title: l.cfgStatus,
                        child: AppBooleanSettingRow(
                          label: l.cfgActive,
                          value: d.status != BranchStatus.inactive,
                          onChanged: s.saving
                              ? null
                              : (value) => change(
                                  (d) => d.copyWith(
                                    status: value
                                        ? BranchStatus.active
                                        : BranchStatus.inactive,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  );
                },
              ),
            ),
          );
        },
      );

  static bool _isYes(String? value) => value?.trim().toLowerCase() == 'yes';
}
