import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master.dart';
import 'package:modular_erp/modules/services/configuration/presentation/bloc/service_master_blocs.dart';
import 'package:modular_erp/modules/services/configuration/presentation/pages/service_master_list_page.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';

class ServiceMasterFormPage extends StatelessWidget {
  const ServiceMasterFormPage({super.key, required this.kind, this.id});
  final ServiceMasterKind kind;
  final String? id;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final listRoute = switch (kind) {
      ServiceMasterKind.serviceType => ServicesRoutes.serviceTypes,
      ServiceMasterKind.complaintType => ServicesRoutes.complaintTypes,
      ServiceMasterKind.priority => ServicesRoutes.priorities,
      ServiceMasterKind.ticketType => ServicesRoutes.ticketTypes,
    };
    return BlocConsumer<ServiceMasterFormCubit, ServiceMasterFormState>(
      listenWhen: (p, c) =>
          (c.saved && !p.saved) ||
          (c.failure != null && c.failure != p.failure),
      listener: (context, state) {
        if (state.saved) {
          AppFeedback.showMessage(
            context,
            message: (l) => l.servicesMasterSaved,
          );
          context.go(listRoute);
        } else if (state.failure != null) {
          AppFeedback.showMessage(
            context,
            message: (l) => l.servicesMasterStorageError,
          );
        }
      },
      builder: (context, state) {
        final d = state.draft;
        final cubit = context.read<ServiceMasterFormCubit>();
        return AppPage(
          maxWidth: AppDimensions.details,
          header: AppPageHeader(
            title: id == null
                ? serviceMasterTitle(l, kind)
                : l.servicesEditMaster,
            actions: [
              AppTextButton(
                label: l.cancel,
                onPressed: state.saving ? null : () => context.go(listRoute),
              ),
              AppPrimaryButton(
                label: l.save,
                loading: state.saving,
                onPressed: cubit.save,
              ),
            ],
          ),
          child: AppFormSection(
            title: serviceMasterTitle(l, kind),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: l.servicesMasterCode,
                  initialValue: d.code,
                  enabled: !state.saving,
                  onChanged: (v) => cubit.change(d.copyWith(code: v)),
                ),
                AppTextField(
                  label: l.servicesMasterName,
                  initialValue: d.name,
                  enabled: !state.saving,
                  onChanged: (v) => cubit.change(d.copyWith(name: v)),
                ),
                AppTextField(
                  label: l.servicesMasterDescription,
                  initialValue: d.description,
                  enabled: !state.saving,
                  maxLines: 2,
                  onChanged: (v) => cubit.change(d.copyWith(description: v)),
                ),
                AppTextField(
                  label: l.servicesMasterSortOrder,
                  initialValue: d.sortOrder,
                  enabled: !state.saving,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => cubit.change(d.copyWith(sortOrder: v)),
                ),
                if (kind == ServiceMasterKind.priority) ...[
                  AppTextField(
                    label: l.servicesMasterRank,
                    initialValue: d.rank,
                    enabled: !state.saving,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => cubit.change(d.copyWith(rank: v)),
                  ),
                  AppSwitchField(
                    label: l.servicesMasterDefault,
                    value: d.isDefault,
                    onChanged: state.saving
                        ? null
                        : (v) => cubit.change(d.copyWith(isDefault: v)),
                  ),
                ],
                if (kind == ServiceMasterKind.complaintType &&
                    state.serviceTypes.isNotEmpty)
                  AppSelectField<String>(
                    label: l.servicesMasterServiceType,
                    value: d.serviceTypeId ?? '',
                    onChanged: (v) => cubit.change(
                      d.copyWith(
                        serviceTypeId: (v == null || v.isEmpty) ? null : v,
                        clearServiceType: v == null || v.isEmpty,
                      ),
                    ),
                    options: [
                      AppSelectOption('', l.servicesMasterGeneric),
                      for (final type in state.serviceTypes)
                        AppSelectOption(type.id, type.name),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
