import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/result.dart';
import '../../../core/localization/app_formatters.dart';
import '../../../core/sync/app_sync_status_cubit.dart';
import '../../../core/sync/sync_diagnostics.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../auth/domain/entities/auth_context.dart';
import '../../auth/domain/repositories/auth_repository.dart';

/// Developer-only sync inspector. Never reachable from production navigation.
class SyncInspectorPage extends StatefulWidget {
  const SyncInspectorPage({
    super.key,
    required this.diagnostics,
    required this.auth,
  });
  final SyncDiagnosticsService diagnostics;
  final AuthRepository auth;
  @override
  State<SyncInspectorPage> createState() => _SyncInspectorPageState();
}

class _SyncInspectorPageState extends State<SyncInspectorPage> {
  SyncDiagnostics? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await widget.auth.checkSession();
    final context = result is Success<AuthContext?> ? result.value : null;
    if (context == null) return;
    final data = await widget.diagnostics.load(companyId: context.company.id);
    if (mounted) setState(() => _data = data);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final data = _data;
    final sync = _read<AppSyncStatusCubit>(context);
    return AppPage(
      maxWidth: AppDimensions.details,
      header: AppPageHeader(
        title: l.syncStatusTitle,
        actions: [
          if (sync != null)
            AppSecondaryButton(label: l.syncRetryNow, onPressed: sync.syncNow),
        ],
      ),
      child: data == null
          ? const AppSkeleton(height: 200)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row(
                        context,
                        l.syncPendingOperations,
                        data.counts.waiting,
                      ),
                      _row(
                        context,
                        l.syncFailedOperations,
                        data.counts.needsAttention,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final operation in data.operations)
                  _operationTile(context, operation),
              ],
            ),
    );
  }

  Widget _operationTile(
    BuildContext context,
    PendingOperationSummary operation,
  ) {
    final shortId = operation.operationId.length > 8
        ? operation.operationId.substring(0, 8)
        : operation.operationId;
    final heading = '${operation.moduleId} · ${operation.operation}';
    final meta = '${operation.status} · #$shortId';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(heading, style: AppTypography.of(context).cardTitle),
            Text(meta, style: AppTypography.of(context).caption),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, int value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          AppNumberFormatter(Localizations.localeOf(context)).integer(value),
        ),
      ],
    ),
  );

  T? _read<T>(BuildContext context) => kDebugMode ? _tryRead<T>(context) : null;

  T? _tryRead<T>(BuildContext context) {
    try {
      return context.read<T>();
    } catch (_) {
      return null;
    }
  }
}

/// Used by the router to only expose the inspector in debug builds.
bool get syncInspectorAvailable => kDebugMode;
