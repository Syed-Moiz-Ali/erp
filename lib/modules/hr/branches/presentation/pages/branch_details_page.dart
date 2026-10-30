import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/branches/presentation/branch_configuration_repository.dart';
import 'package:modular_erp/modules/hr/branches/presentation/bloc/branch_details_bloc.dart';
import 'package:modular_erp/shared/presentation/configuration_layouts.dart';

class BranchDetailsPage extends StatelessWidget {
  const BranchDetailsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<BranchDetailsBloc, BranchDetailsState>(
        listener: (c, s) {
          if (s.statusSaved) {
            AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
          }
        },
        builder: (context, s) {
          final l = context.l10n, bloc = context.read<BranchDetailsBloc>();
          return ConfigurationDetailsLayout<BranchRecord>(
            title: l.cfgBranches,
            state: s,
            manage: bloc.context.user.permissions.contains(
              AppPermission.companyBranchManage,
            ),
            onRetry: () => bloc.add(const RecordDetailsStarted()),
            onEdit: () => context.push(AppRoutes.branchesEdit(bloc.id)),
            onActive: (v) => bloc.add(RecordDetailsStatusRequested(v)),
            content: (record) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFormSection(
                  title: l.cfgGeneralRules,
                  child: AppDetailsGrid(
                    fields: [
                      AppDetailField(
                        label: l.cfgName,
                        value: record.branchName,
                      ),
                      AppDetailField(
                        label: l.cfgBranchCode,
                        value: record.branchCode ?? l.noSelection,
                        identifier: true,
                      ),
                      AppDetailField(
                        label: l.cfgBranchTimeZone,
                        value: record.timeZoneId,
                      ),
                      AppDetailField(
                        label: l.cfgBranchDivision,
                        value: record.divisionName ?? l.noSelection,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppFormSection(
                  title: l.cfgBranchContactSection,
                  child: AppDetailsGrid(
                    fields: [
                      AppDetailField(
                        label: l.cfgBranchContactPerson,
                        value: record.contactPerson ?? l.noSelection,
                      ),
                      AppDetailField(
                        label: l.cfgBranchMobile,
                        value: record.mobileNo ?? l.noSelection,
                      ),
                      AppDetailField(
                        label: l.cfgBranchLandLine,
                        value: record.landLine ?? l.noSelection,
                      ),
                      AppDetailField(
                        label: l.cfgBranchEmail,
                        value: record.email ?? l.noSelection,
                      ),
                      AppDetailField(
                        label: l.cfgAddress,
                        value: record.address ?? l.noSelection,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppFormSection(
                  title: l.cfgBranchInventorySection,
                  child: AppDetailsGrid(
                    fields: [
                      AppDetailField(
                        label: l.cfgBranchInventoryAlerts,
                        value: record.inventoryAlerts ?? l.noSelection,
                      ),
                      AppDetailField(
                        label: l.cfgBranchMultiInventory,
                        value: record.multiInventory ?? l.noSelection,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
}
