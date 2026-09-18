import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/attendance_models.dart';
import '../attendance_presentation.dart';
import '../bloc/attendance_bloc.dart';

class AttendanceLocationStatus extends StatelessWidget {
  const AttendanceLocationStatus({super.key, required this.state});
  final AttendanceBlocState state;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n, a = state.context!, preview = state.locationPreview;
    final type =
        state.operation ??
        state.actions!.decisions.entries
            .where((e) => e.value.allowed && e.value.requiresLocation)
            .map((e) => e.key)
            .firstOrNull ??
        AttendanceEventType.punchIn;
    final required = state.actions?.decisions[type]?.requiresLocation ?? false;
    final code = state.failure?.code;
    final locationFailure =
        code != null && code.startsWith('location') ||
        code == 'outsideAllowedLocation' ||
        code == 'staleLocationEvidence' ||
        code == 'invalidLocationEvidence';
    final checking =
        state.actionStatus == AttendanceActionStatus.checkingLocation;
    final validation = preview?.decision.locationValidation;
    String title;
    String? detail;
    var status = AppStatus.neutral;
    if (checking) {
      title = l.attendanceLocationChecking;
    } else if (locationFailure) {
      title = AttendancePresentation.failure(context, state.failure!);
      status = AppStatus.warning;
      if (code == 'locationServicesDisabled') detail = l.attendanceServicesNote;
    } else if (preview != null && validation != null) {
      title = switch (validation.state) {
        AttendanceLocationState.insideAllowedArea => l.attendanceInsideLocation,
        AttendanceLocationState.outsideAllowedAreaAllowed ||
        AttendanceLocationState.outsideAllowedAreaRejected =>
          l.attendanceOutsideLocation,
        AttendanceLocationState.captured ||
        AttendanceLocationState.remoteAllowed =>
          l.attendanceLocationCaptureReady,
        _ => l.attendanceLocationRequired,
      };
      status = preview.decision.allowed ? AppStatus.success : AppStatus.warning;
      detail =
          '${l.attendanceLastCheck}: ${AttendancePresentation.time(context, a, preview.evidence?.capturedAt)}';
    } else {
      title = required
          ? l.attendanceLocationRequired
          : l.attendanceLocationNotRequired;
      detail = required ? l.attendanceLocationRequiredNote : null;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (checking)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(Icons.location_on_outlined, size: 20, color: status.color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    liveRegion: true,
                    child: Text(title, style: AppTypography.of(context).label),
                  ),
                  if (detail != null)
                    Text(detail, style: AppTypography.of(context).bodySmall),
                ],
              ),
            ),
          ],
        ),
        if (preview?.evidence != null) ...[
          const SizedBox(height: AppSpacing.md),
          Builder(
            builder: (context) {
              final accuracyText =
                  '${l.attendanceAccuracy}: ${AttendancePresentation.meters(context, preview!.evidence!.accuracyMeters)}';
              return Text(
                accuracyText,
                style: AppTypography.of(context).caption,
              );
            },
          ),
          if (preview?.maximumAccuracyMeters != null)
            Builder(
              builder: (context) {
                final limitText =
                    '${l.attendanceAccuracyLimit}: ${AttendancePresentation.meters(context, preview!.maximumAccuracyMeters!)}';
                return Text(
                  limitText,
                  style: AppTypography.of(context).caption,
                );
              },
            ),
        ],
        if (validation?.distanceMeters != null)
          Builder(
            builder: (context) {
              final distanceText =
                  '${l.attendanceDistance}: ${AttendancePresentation.meters(context, validation!.distanceMeters!)}';
              return Text(
                distanceText,
                style: AppTypography.of(context).caption,
              );
            },
          ),
        if (required || locationFailure) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (code == 'locationPermissionPermanentlyDenied' ||
                  code == 'locationServicesDisabled')
                AppSecondaryButton(
                  label: l.attendanceOpenSettings,
                  icon: Icons.settings_outlined,
                  onPressed: state.busy
                      ? null
                      : () => context.read<AttendanceBloc>().add(
                          AttendanceLocationSettingsRequested(
                            locationSettings:
                                code == 'locationServicesDisabled',
                          ),
                        ),
                ),
              AppTextButton(
                label: code == 'locationPermissionDenied'
                    ? l.attendanceAllowLocation
                    : l.attendanceRefreshLocation,
                onPressed: state.busy
                    ? null
                    : () => context.read<AttendanceBloc>().add(
                        AttendanceLocationRefreshRequested(type),
                      ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
