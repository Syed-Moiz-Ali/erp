import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_clock.dart';
import '../../../../core/localization/app_formatters.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../attendance_presentation.dart';
import '../attendance_ticker_cubit.dart';
import '../bloc/attendance_bloc.dart';
import '../widgets/attendance_state_card.dart';
import '../widgets/attendance_context_panel.dart';
import '../widgets/attendance_duration_summary.dart';
import '../widgets/attendance_today_timeline.dart';
import '../widgets/attendance_sync_banner.dart';
import '../widgets/attendance_confirmation_sheet.dart';

class AttendanceTodayPage extends StatefulWidget {
  const AttendanceTodayPage({super.key});
  @override
  State<AttendanceTodayPage> createState() => _AttendanceTodayPageState();
}

class _AttendanceTodayPageState extends State<AttendanceTodayPage>
    with WidgetsBindingObserver {
  late final AttendanceTickerCubit ticker = AttendanceTickerCubit(
    context.read<AppClock?>() ?? const SystemAppClock(),
  );
  bool foreground = true;
  bool confirmationOpen = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ticker.bind(context.read<AttendanceBloc>().state.context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ticker.setActive(foreground && TickerMode.of(context));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    foreground = s == AppLifecycleState.resumed;
    ticker.setActive(foreground && TickerMode.of(context));
    if (foreground && TickerMode.of(context)) {
      context.read<AttendanceBloc>().add(const AttendanceRefreshRequested());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ticker.close();
    super.dispose();
  }

  Future<void> refresh() async {
    final bloc = context.read<AttendanceBloc>();
    if (bloc.state.refreshing || bloc.state.busy) return;
    final done = bloc.stream.firstWhere((s) => !s.refreshing);
    bloc.add(const AttendanceRefreshRequested());
    await done;
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: ticker,
    child: BlocListener<AttendanceBloc, AttendanceBlocState>(
      listener: (context, s) async {
        ticker.bind(s.context);
        if (s.actionStatus == AttendanceActionStatus.awaitingConfirmation &&
            s.preparedAction != null &&
            !confirmationOpen) {
          final bloc = context.read<AttendanceBloc>();
          if (!TickerMode.of(context)) {
            bloc.add(const AttendanceConfirmationCancelled());
            return;
          }
          confirmationOpen = true;
          bool? confirmed;
          try {
            confirmed = await AttendanceConfirmationSheet.show(
              context,
              s.preparedAction!,
            );
          } finally {
            confirmationOpen = false;
          }
          if (!bloc.isClosed) {
            bloc.add(
              confirmed == true
                  ? const AttendanceActionConfirmed()
                  : const AttendanceConfirmationCancelled(),
            );
          }
        }
      },
      listenWhen: (p, c) =>
          p.context != c.context ||
          (c.actionStatus == AttendanceActionStatus.awaitingConfirmation &&
              p.preparedAction != c.preparedAction),
      child: BlocBuilder<AttendanceBloc, AttendanceBlocState>(
        builder: (context, s) {
          final l = context.l10n, a = s.context;
          final header = AppPageHeader(
            title: l.attendanceTodayTitle,
            compactActionsInline: true,
            subtitle: a == null
                ? null
                : '${a.employee.firstName} · ${AppDateFormatter(Localizations.localeOf(context)).fullDate(a.workday)}',
            actions: [
              AppIconButton(
                icon: Icons.refresh,
                tooltip: l.dashboardRefresh,
                onPressed: s.busy || s.refreshing
                    ? null
                    : () => context.read<AttendanceBloc>().add(
                        const AttendanceRefreshRequested(),
                      ),
              ),
            ],
          );
          Widget body;
          if (a == null &&
              s.contextStatus != AttendanceContextStatus.unavailable) {
            body = Semantics(
              label: l.attendanceCheckingSetup,
              child: const Column(
                children: [
                  AppCard(child: AppSkeleton(height: 160)),
                  SizedBox(height: AppSpacing.xl),
                  AppCard(child: AppSkeleton(height: 100)),
                  SizedBox(height: AppSpacing.xl),
                  AppCard(child: AppSkeleton(height: 140)),
                ],
              ),
            );
          } else if (a == null) {
            final failureDetail = s.failure == null
                ? l.attendanceUnavailableTitle
                : AttendancePresentation.failure(context, s.failure!);
            final noticeMessage = '$failureDetail\n${l.attendanceContactHr}';
            body = AppNotice(
              title: l.attendanceNotConfigured,
              message: noticeMessage,
              status: AppStatus.warning,
              action: AppTextButton(
                label: l.attendanceTryAgain,
                onPressed: () => context.read<AttendanceBloc>().add(
                  const AttendanceRefreshRequested(),
                ),
              ),
            );
          } else {
            final notices = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (s.failure != null &&
                    !AttendancePresentation.isLocationFailure(s.failure)) ...[
                  AppNotice(
                    title: AttendancePresentation.failure(context, s.failure!),
                    status: AppStatus.warning,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (s.currentDay != null) ...[
                  AttendanceSyncBanner(state: s),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ],
            );
            final main = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppMotion.entrance(
                  context,
                  AttendanceStateCard(
                    key: ValueKey(s.summary!.currentState),
                    state: s,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                notices,
              ],
            );
            final support = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AttendanceContextPanel(state: s),
                const SizedBox(height: AppSpacing.xl),
                AttendanceDurationSummary(summary: s.summary!),
              ],
            );
            body = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (s.refreshing) const LinearProgressIndicator(),
                AppOperationalLayout(
                  main: main,
                  supporting: support,
                  trailingMain: AttendanceTodayTimeline(state: s),
                ),
              ],
            );
          }
          return RefreshIndicator(
            onRefresh: refresh,
            child: AppPage(
              header: header,
              animateEntrance: false,
              scrollPhysics: const AlwaysScrollableScrollPhysics(),
              child: body,
            ),
          );
        },
      ),
    ),
  );
}
