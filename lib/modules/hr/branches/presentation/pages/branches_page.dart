import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';
import 'package:modular_erp/modules/hr/branches/presentation/bloc/branch_list_cubit.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class BranchesPage extends StatelessWidget {
  const BranchesPage({super.key, required this.cubit});
  final BranchListCubit cubit;

  @override
  Widget build(BuildContext context) =>
      BlocProvider.value(value: cubit..start(), child: const _BranchesBody());
}

class _BranchesBody extends StatelessWidget {
  const _BranchesBody();

  bool _can(AuthContext? account, AppPermission permission) =>
      account != null &&
      PermissionChecker(account.user.permissions).can(permission);

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthBloc, AuthState>(
    builder: (context, auth) {
      final account = auth.context;
      final canManage = _can(account, AppPermission.companyBranchManage);
      final canView =
          _can(account, AppPermission.companyBranchView) || canManage;
      if (!canView) {
        return AppPage(
          header: AppPageHeader(title: context.l10n.branchTitle),
          child: AppPermissionDeniedState(
            onGoBack: () => Navigator.of(context).maybePop(),
          ),
        );
      }
      return BlocBuilder<BranchListCubit, BranchListState>(
        builder: (context, state) {
          final l = context.l10n;
          final cubit = context.read<BranchListCubit>();
          return AppPage(
            header: AppPageHeader(
              title: l.branchTitle,
              actions: [
                if (canManage)
                  AppPrimaryButton(
                    label: l.branchAdd,
                    onPressed: () => _edit(context, cubit, null),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCollectionToolbar(
                  search: AppSearchField(
                    label: l.search,
                    hint: l.search,
                    onChanged: cubit.searchChanged,
                  ),
                  secondary: [
                    AppFilterBar(
                      children: [
                        AppFilterChip(
                          label: l.accessFilterAll,
                          selected: state.status == null,
                          onSelected: (_) => cubit.statusChanged(null),
                        ),
                        for (final status in ['Active', 'InActive'])
                          AppFilterChip(
                            label: status == 'Active' ? l.active : l.inactive,
                            selected: state.status == status,
                            onSelected: (_) => cubit.statusChanged(status),
                          ),
                      ],
                    ),
                  ],
                  resultCount: AppResultCount(
                    filtered: state.items.length,
                    total: state.totalItems,
                    label: state.totalItems.toString(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (state.loading)
                  const AppLoadingState()
                else if (state.failure != null)
                  AppErrorState(
                    message: state.failure!.serverMessage ?? l.failureRequest,
                    onRetry: cubit.load,
                  )
                else if (state.items.isEmpty)
                  AppEmptyState(
                    title: l.noRecords,
                    message: l.noRecords,
                    icon: Icons.business_outlined,
                  )
                else if (AppBreakpoints.of(context) == AppSize.compact)
                  Column(
                    children: [
                      for (final branch in state.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppMobileRecordCard(
                            title: branch.name,
                            subtitle: branch.code ?? branch.timeZoneId ?? '',
                            tertiary: branch.email,
                            status: branch.isActive
                                ? AppStatus.success
                                : AppStatus.neutral,
                            statusLabel: branch.isActive
                                ? l.active
                                : l.inactive,
                            trailing: _actions(
                              context,
                              cubit,
                              branch,
                              canManage,
                            ),
                          ),
                        ),
                    ],
                  )
                else
                  AppCollectionSurface(
                    child: AppDataTable(
                      columns: [
                        DataColumn(label: Text(l.cfgName)),
                        DataColumn(label: Text(l.branchCode)),
                        DataColumn(label: Text(l.branchTimeZone)),
                        DataColumn(label: Text(l.status)),
                        DataColumn(label: Text(l.actions)),
                      ],
                      rows: [
                        for (final branch in state.items)
                          DataRow(
                            cells: [
                              DataCell(Text(branch.name)),
                              DataCell(Text(branch.code ?? '')),
                              DataCell(Text(branch.timeZoneId ?? '')),
                              DataCell(
                                AppStatusBadge(
                                  label: branch.isActive
                                      ? l.active
                                      : l.inactive,
                                  status: branch.isActive
                                      ? AppStatus.success
                                      : AppStatus.neutral,
                                  isPill: true,
                                ),
                              ),
                              DataCell(
                                _actions(context, cubit, branch, canManage),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                if (state.totalPages > 1) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppPagination(
                    page: state.page - 1,
                    pageSize: state.pageSize,
                    total: state.totalItems,
                    onPageChanged: (page) => cubit.pageChanged(page + 1),
                  ),
                ],
              ],
            ),
          );
        },
      );
    },
  );

  Widget _actions(
    BuildContext context,
    BranchListCubit cubit,
    Branch branch,
    bool canManage,
  ) => AppActionMenu(
    tooltip: context.l10n.actions,
    actions: [
      AppMenuAction(
        label: (l) => l.branchDetails,
        onPressed: () => _details(context, branch),
      ),
      if (canManage)
        AppMenuAction(
          label: (l) => l.edit,
          onPressed: () => _edit(context, cubit, branch),
        ),
      if (canManage)
        AppMenuAction(
          label: (l) => branch.isActive ? l.inactive : l.active,
          onPressed: () async {
            final failure = await cubit.toggle(branch);
            if (failure != null && context.mounted) {
              AppFeedback.showMessage(
                context,
                message: (l) => failure.serverMessage ?? l.failureRequest,
              );
            }
          },
        ),
    ],
  );

  void _details(BuildContext context, Branch branch) {
    final l = context.l10n;
    AppDialog.show<void>(
      context,
      (dialogContext) => AppDialog(
        title: l.branchDetails,
        actions: [
          AppTextButton(
            label: l.close,
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
        child: AppDetailsSection(
          title: branch.name,
          details: {
            l.branchCode: branch.code ?? '',
            l.branchTimeZone: branch.timeZoneId ?? '',
            l.branchDivision: branch.divisionName ?? '',
            l.branchContact: branch.contactPerson ?? '',
            l.branchMobile: branch.mobileNo ?? '',
            l.email: branch.email ?? '',
            l.branchAddress: branch.address ?? '',
            l.status: branch.isActive ? l.active : l.inactive,
          },
        ),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    BranchListCubit cubit,
    Branch? branch,
  ) async {
    final lookups = cubit.state.lookups;
    if (lookups == null) return;
    final saved = await AppDialog.show<bool>(
      context,
      (dialogContext) => _BranchEditor(
        lookups: lookups,
        initial: branch == null
            ? BranchDraft(
                divisionId: lookups.divisions.isEmpty
                    ? null
                    : int.tryParse(lookups.divisions.first.id),
                timeZoneId: lookups.timeZones.isEmpty
                    ? null
                    : lookups.timeZones.first.id,
              )
            : BranchDraft(
                name: branch.name,
                code: branch.code ?? '',
                contactPerson: branch.contactPerson ?? '',
                mobileNo: branch.mobileNo ?? '',
                landLine: branch.landLine ?? '',
                address: branch.address ?? '',
                email: branch.email ?? '',
                inventoryAlerts: branch.inventoryAlerts ?? 'Yes',
                multiInventory: branch.multiInventory ?? 'No',
                divisionId: branch.divisionId,
                status: branch.status,
                timeZoneId: branch.timeZoneId,
              ),
        title: branch == null
            ? dialogContext.l10n.branchAdd
            : dialogContext.l10n.branchEdit,
        onSave: (draft) => cubit.save(branch?.id, draft),
      ),
    );
    if (saved == true && context.mounted) {
      AppFeedback.showMessage(context, message: (l) => l.branchSaved);
    }
  }
}

class _BranchEditor extends StatefulWidget {
  const _BranchEditor({
    required this.lookups,
    required this.initial,
    required this.title,
    required this.onSave,
  });
  final BranchLookups lookups;
  final BranchDraft initial;
  final String title;
  final Future<Failure?> Function(BranchDraft) onSave;

  @override
  State<_BranchEditor> createState() => _BranchEditorState();
}

class _BranchEditorState extends State<_BranchEditor> {
  late BranchDraft _draft = widget.initial;
  late final _name = TextEditingController(text: _draft.name);
  late final _code = TextEditingController(text: _draft.code);
  late final _contact = TextEditingController(text: _draft.contactPerson);
  late final _mobile = TextEditingController(text: _draft.mobileNo);
  late final _landLine = TextEditingController(text: _draft.landLine);
  late final _address = TextEditingController(text: _draft.address);
  late final _email = TextEditingController(text: _draft.email);
  Map<String, String> _errors = const {};
  bool _saving = false;
  String? _generalError;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _contact.dispose();
    _mobile.dispose();
    _landLine.dispose();
    _address.dispose();
    _email.dispose();
    super.dispose();
  }

  String? _errorText(String field) {
    final value = _errors[field];
    if (value == null) return null;
    if (value == 'required' || value == 'tooLong') {
      return context.l10n.fieldRequired;
    }
    return value;
  }

  Future<void> _submit() async {
    final draft = _draft.copyWith(
      name: _name.text,
      code: _code.text,
      contactPerson: _contact.text,
      mobileNo: _mobile.text,
      landLine: _landLine.text,
      address: _address.text,
      email: _email.text,
    );
    final local = draft.validate();
    if (local.isNotEmpty) {
      setState(() => _errors = local);
      return;
    }
    setState(() {
      _saving = true;
      _errors = const {};
      _generalError = null;
    });
    final failure = await widget.onSave(draft);
    if (!mounted) return;
    if (failure == null) {
      Navigator.pop(context, true);
      return;
    }
    final field = failure.field;
    setState(() {
      _saving = false;
      if (field != null) {
        _errors = {field: failure.serverMessage ?? failure.code};
      } else if (failure.code == 'BRANCH_DUPLICATE_NAME') {
        _errors = {
          field ?? 'branchName': failure.serverMessage ?? failure.code,
        };
      } else {
        _generalError = failure.serverMessage ?? context.l10n.failureRequest;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppDialog(
      title: widget.title,
      actions: [
        AppTextButton(
          label: l.cancel,
          onPressed: _saving ? null : () => Navigator.pop(context),
        ),
        AppPrimaryButton(
          label: l.save,
          loading: _saving,
          onPressed: _saving ? null : _submit,
        ),
      ],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_generalError != null) ...[
              Text(
                _generalError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            AppTextField(
              label: l.cfgName,
              controller: _name,
              required: true,
              enabled: !_saving,
              errorText: _errorText('branchName'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.branchCode,
              controller: _code,
              enabled: !_saving,
              errorText: _errorText('branchCode'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.branchContact,
              controller: _contact,
              enabled: !_saving,
              errorText: _errorText('contactPerson'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.branchMobile,
              controller: _mobile,
              enabled: !_saving,
              errorText: _errorText('mobileNo'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.branchLandLine,
              controller: _landLine,
              enabled: !_saving,
              errorText: _errorText('landLine'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.email,
              controller: _email,
              enabled: !_saving,
              errorText: _errorText('email'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.branchAddress,
              controller: _address,
              enabled: !_saving,
              errorText: _errorText('address'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSelectField<int>(
              label: l.branchDivision,
              enabled: !_saving,
              errorText: _errorText('divisionId'),
              value: _draft.divisionId,
              options: [
                for (final division in widget.lookups.divisions)
                  AppSelectOption(
                    int.tryParse(division.id) ?? 0,
                    division.name,
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _draft = _draft.copyWith(divisionId: value)),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSelectField<String>(
              label: l.branchTimeZone,
              required: true,
              enabled: !_saving,
              value: _draft.timeZoneId,
              errorText: _errorText('timeZoneId'),
              options: [
                for (final zone in widget.lookups.timeZones)
                  AppSelectOption(zone.id, zone.name, subtitle: zone.utcOffset),
              ],
              onChanged: (value) =>
                  setState(() => _draft = _draft.copyWith(timeZoneId: value)),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSelectField<String>(
              label: l.status,
              enabled: !_saving,
              errorText: _errorText('status'),
              value: _draft.status,
              options: [
                for (final status in widget.lookups.statuses)
                  AppSelectOption(status, status),
              ],
              onChanged: (value) =>
                  setState(() => _draft = _draft.copyWith(status: value)),
            ),
          ],
        ),
      ),
    );
  }
}
