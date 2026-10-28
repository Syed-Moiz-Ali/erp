import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/access/domain/permission_master.dart';
import 'package:modular_erp/platform/access/domain/permission_master_repository.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

final _keyPattern = RegExp(r'^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+$');

class PermissionMastersPage extends StatefulWidget {
  const PermissionMastersPage({super.key, required this.repository});
  final PermissionMasterRepository repository;

  @override
  State<PermissionMastersPage> createState() => _PermissionMastersPageState();
}

class _PermissionMastersPageState extends State<PermissionMastersPage> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';
  int? _statusId;
  bool _loading = true;
  Failure? _failure;
  List<PermissionMaster> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failure = null;
    });
    final result = await widget.repository.list(
      search: _query,
      statusId: _statusId,
      pageSize: 100,
    );
    if (!mounted) return;
    switch (result) {
      case Success(:final value):
        setState(() {
          _items = value.items;
          _loading = false;
        });
      case Failed(:final failure):
        setState(() {
          _failure = failure;
          _loading = false;
        });
    }
  }

  void _searchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _query = value.trim());
      _load();
    });
  }

  bool _canManage(AuthBloc auth) => PermissionChecker(
    auth.state.context?.user.permissions ?? PermissionSet(const []),
  ).can(AppPermission.accessPermissionsManage);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, auth) {
        final canManage = _canManage(context.read<AuthBloc>());
        return AppPage(
          header: AppPageHeader(
            title: l.accessPermissionCatalog,
            subtitle: l.accessPermissionCatalogSubtitle,
            actions: [
              if (canManage)
                AppPrimaryButton(
                  label: l.accessNewPermission,
                  onPressed: () => _edit(context, null),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCollectionToolbar(
                search: AppSearchField(
                  controller: _search,
                  label: l.accessPermissionSearch,
                  hint: l.accessPermissionSearch,
                  onChanged: _searchChanged,
                  onClear: () {
                    _search.clear();
                    _searchChanged('');
                  },
                ),
                secondary: [
                  AppFilterBar(
                    children: [
                      AppFilterChip(
                        label: l.accessFilterAll,
                        selected: _statusId == null,
                        onSelected: (_) {
                          setState(() => _statusId = null);
                          _load();
                        },
                      ),
                      AppFilterChip(
                        label: l.accessPermissionActive,
                        selected: _statusId == 1,
                        onSelected: (_) {
                          setState(() => _statusId = 1);
                          _load();
                        },
                      ),
                      AppFilterChip(
                        label: l.accessPermissionInactive,
                        selected: _statusId == 2,
                        onSelected: (_) {
                          setState(() => _statusId = 2);
                          _load();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_loading)
                const AppLoadingState()
              else if (_failure != null)
                AppErrorState(
                  message: _failure!.serverMessage ?? l.failureRequest,
                  onRetry: _load,
                )
              else if (_items.isEmpty)
                AppEmptyState(
                  title: l.noRecords,
                  message: l.accessNoPermissionMatch,
                  icon: Icons.key_outlined,
                )
              else if (AppBreakpoints.of(context) == AppSize.compact)
                Column(
                  children: [
                    for (final item in _items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: AppMobileRecordCard(
                          title: item.name,
                          subtitle: item.key,
                          tertiary: item.description,
                          status: item.isActive
                              ? AppStatus.success
                              : AppStatus.neutral,
                          statusLabel: item.isActive
                              ? l.accessPermissionActive
                              : l.accessPermissionInactive,
                          trailing: canManage
                              ? _actions(context, item)
                              : null,
                        ),
                      ),
                  ],
                )
              else
                AppCollectionSurface(
                  child: AppDataTable(
                    columns: [
                      DataColumn(label: Text(l.accessPermissionKey)),
                      DataColumn(label: Text(l.accessPermissionName)),
                      DataColumn(label: Text(l.accessPermissionDescription)),
                      DataColumn(label: Text(l.status)),
                      DataColumn(label: Text(l.actions)),
                    ],
                    rows: [
                      for (final item in _items)
                        DataRow(
                          cells: [
                            DataCell(Text(item.key)),
                            DataCell(Text(item.name)),
                            DataCell(
                              Text(item.description ?? ''),
                            ),
                            DataCell(
                              AppStatusBadge(
                                label: item.isActive
                                    ? l.accessPermissionActive
                                    : l.accessPermissionInactive,
                                status: item.isActive
                                    ? AppStatus.success
                                    : AppStatus.neutral,
                                isPill: true,
                              ),
                            ),
                            DataCell(
                              canManage
                                  ? _actions(context, item)
                                  : const SizedBox.shrink(),
                            ),
                          ],
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

  Widget _actions(BuildContext context, PermissionMaster item) {
    final l = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextButton(
          label: l.edit,
          onPressed: () => _edit(context, item),
        ),
        AppTextButton(
          label: item.isActive ? l.accessPermissionInactive : l.accessPermissionActive,
          onPressed: () => _toggle(item),
        ),
      ],
    );
  }

  Future<void> _edit(BuildContext context, PermissionMaster? item) async {
    final saved = await AppDialog.show<bool>(
      context,
      (dialogContext) => _PermissionEditorDialog(
        repository: widget.repository,
        existing: _items,
        initial: item,
      ),
    );
    if (saved == true) {
      if (context.mounted) {
        AppFeedback.showMessage(
          context,
          message: (l) => item == null
              ? l.accessPermissionCreated
              : l.accessPermissionUpdated,
        );
      }
      await _load();
    }
  }

  Future<void> _toggle(PermissionMaster item) async {
    final result = await widget.repository.setActive(item.id, !item.isActive);
    if (!mounted) return;
    if (result case Failed(:final failure)) {
      AppFeedback.showMessage(
        context,
        message: (l) => failure.serverMessage ?? l.accessSaveFailed,
      );
    } else {
      await _load();
    }
  }
}

class _PermissionEditorDialog extends StatefulWidget {
  const _PermissionEditorDialog({
    required this.repository,
    required this.existing,
    this.initial,
  });

  final PermissionMasterRepository repository;
  final List<PermissionMaster> existing;
  final PermissionMaster? initial;

  @override
  State<_PermissionEditorDialog> createState() => _PermissionEditorDialogState();
}

class _PermissionEditorDialogState extends State<_PermissionEditorDialog> {
  late final _key = TextEditingController(text: widget.initial?.key ?? '');
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _description = TextEditingController(
    text: widget.initial?.description ?? '',
  );
  bool _saving = false;
  String? _keyError, _nameError, _generalError;

  @override
  void dispose() {
    _key.dispose();
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  String? _validate() {
    final key = _key.text.trim();
    final name = _name.text.trim();
    if (name.isEmpty) {
      _nameError = context.l10n.fieldRequired;
      return _nameError;
    }
    if (key.isEmpty) {
      _keyError = context.l10n.fieldRequired;
      return _keyError;
    }
    if (key.length > 100) {
      _keyError = context.l10n.accessKeyTooLong;
      return _keyError;
    }
    if (!_keyPattern.hasMatch(key)) {
      _keyError = context.l10n.accessKeyInvalid;
      return _keyError;
    }
    final duplicate = widget.existing.any(
      (item) =>
          item.id != widget.initial?.id &&
          item.key.toLowerCase() == key.toLowerCase(),
    );
    if (duplicate) {
      _keyError = context.l10n.accessKeyDuplicate;
      return _keyError;
    }
    return null;
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _keyError = null;
      _nameError = null;
      _generalError = null;
    });
    if (_validate() != null) {
      setState(() => _saving = false);
      return;
    }
    final key = _key.text.trim();
    final name = _name.text.trim();
    final description = _description.text.trim();
    final result = widget.initial == null
        ? await widget.repository.create(
            key: key,
            name: name,
            description: description,
          )
        : await widget.repository.update(
            widget.initial!.id,
            key: key,
            name: name,
            description: description,
          );
    if (!mounted) return;
    switch (result) {
      case Success():
        Navigator.pop(context, true);
      case Failed(:final failure):
        setState(() {
          _saving = false;
          if (failure.field == 'permissionKey') {
            _keyError = failure.code == 'PERMISSION_DUPLICATE_KEY'
                ? context.l10n.accessKeyDuplicate
                : context.l10n.accessKeyInvalid;
          } else if (failure.field == 'permissionName') {
            _nameError = failure.serverMessage ?? context.l10n.fieldRequired;
          } else if (failure.code == 'PERMISSION_DUPLICATE_KEY') {
            _keyError = context.l10n.accessKeyDuplicate;
          } else {
            _generalError = failure.serverMessage ?? context.l10n.accessSaveFailed;
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppDialog(
      title: widget.initial == null
          ? l.accessNewPermission
          : l.accessEditPermission,
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_generalError != null) ...[
              Text(
                _generalError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            AppTextField(
              label: l.accessPermissionKey,
              controller: _key,
              errorText: _keyError,
              enabled: !_saving,
              autocorrect: false,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.accessPermissionName,
              controller: _name,
              errorText: _nameError,
              enabled: !_saving,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.accessPermissionDescription,
              controller: _description,
              enabled: !_saving,
              maxLines: 3,
              minLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}


