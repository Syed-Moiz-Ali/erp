import 'package:flutter/widgets.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Semantic tone shared by every dashboard presentation model.
///
/// Neutral platform enum: contributors map their own domain status to a tone so
/// the universal page never imports a module-specific status type.
enum DashboardTone { neutral, info, success, warning, danger, brand }

/// A compact, permission/scope-gated metric card.
class DashboardKpi {
  const DashboardKpi({
    required this.id,
    required this.moduleId,
    required this.label,
    required this.value,
    required this.icon,
    this.detail = '',
    this.route,
    this.tone = DashboardTone.neutral,
    this.rank = 100,
  });

  final String id, moduleId, label, value, detail;

  /// Already-localized context line (may be empty).
  final IconData icon;
  final String? route;
  final DashboardTone tone;

  /// Lower rank wins when the capped KPI row must prioritise domains.
  final int rank;
}

/// A generic cross-module "needs attention" row.
class DashboardAttentionItem {
  const DashboardAttentionItem({
    required this.id,
    required this.moduleId,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.priority,
    this.date,
    this.route,
    this.actionText = '',
    this.tone = DashboardTone.neutral,
  });

  final String id, moduleId, type, title, subtitle;
  final IconData icon;

  /// Higher is more urgent. Sorting is urgency, then business date, then [id].
  final int priority;
  final DateTime? date;
  final String? route;
  final String actionText;
  final DashboardTone tone;
}

/// A generic chronological schedule row (HR shift/leave + Services visits).
class DashboardScheduleItem {
  const DashboardScheduleItem({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.icon,
    this.time,
    this.dateOnly = false,
    this.route,
    this.tone = DashboardTone.neutral,
  });

  final String id, moduleId, title, subtitle, statusLabel;
  final IconData icon;

  /// Company-local instant; when [dateOnly] this is the business date.
  final DateTime? time;

  /// True when the row has no clock time (e.g. a visit date day).
  final bool dateOnly;
  final String? route;
  final DashboardTone tone;
}

/// A generic "assigned to me" work row.
class DashboardWorkItem {
  const DashboardWorkItem({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.icon,
    this.route,
    this.actionText = '',
    this.tone = DashboardTone.neutral,
  });

  final String id, moduleId, title, subtitle, statusLabel, actionText;
  final IconData icon;
  final String? route;
  final DashboardTone tone;
}

/// A compact team/company overview row.
class DashboardTeamRow {
  const DashboardTeamRow({
    required this.id,
    required this.moduleId,
    required this.label,
    required this.detail,
  });

  final String id, moduleId, label, detail;
}

class DashboardBreakdownRow {
  const DashboardBreakdownRow({required this.label, required this.value});
  final String label;
  final int value;
}

/// A titled distribution/overview block (e.g. Services workflow stages).
class DashboardBreakdown {
  const DashboardBreakdown({
    required this.moduleId,
    required this.title,
    required this.rows,
  });

  final String moduleId, title;
  final List<DashboardBreakdownRow> rows;
}

/// Canonical dashboard sections contributors may expose a "view all" for.
enum DashboardSection {
  myDay,
  attention,
  kpis,
  schedule,
  myWork,
  team,
  activity,
}

/// A generic recent-activity row with a subtle owning-module tag.
class DashboardActivityItem {
  const DashboardActivityItem({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.description,
    required this.icon,
    required this.occurredAt,
    this.tone = DashboardTone.neutral,
  });

  final String id, moduleId, title, description;
  final IconData icon;
  final DateTime occurredAt;
  final DashboardTone tone;
}

/// A capability-driven quick action (3-6 shown at most).
class DashboardQuickAction {
  const DashboardQuickAction({
    required this.id,
    required this.moduleId,
    required this.label,
    required this.icon,
    required this.route,
  });

  final String id, moduleId, label;
  final IconData icon;
  final String route;
}

/// The typed, presentation-ready result of a single module contributor.
class DashboardContribution {
  const DashboardContribution({
    required this.moduleId,
    this.order = 0,
    this.scopeLabel = '',
    this.kpis = const [],
    this.attention = const [],
    this.schedule = const [],
    this.myWork = const [],
    this.team = const [],
    this.breakdowns = const [],
    this.activity = const [],
    this.quickActions = const [],
    this.myDay = const [],
    this.viewAll = const {},
  });

  final String moduleId;
  final int order;

  /// Already-localized scope context (e.g. "Viewing: Team scope").
  final String scopeLabel;
  final List<DashboardKpi> kpis;
  final List<DashboardAttentionItem> attention;
  final List<DashboardScheduleItem> schedule;
  final List<DashboardWorkItem> myWork;
  final List<DashboardTeamRow> team;
  final List<DashboardBreakdown> breakdowns;
  final List<DashboardActivityItem> activity;
  final List<DashboardQuickAction> quickActions;

  /// Module-owned personal widgets (attendance punch card, leave banner, ...).
  final List<Widget> myDay;

  /// Section -> module list route, exposed only when the user may open it.
  final Map<DashboardSection, String> viewAll;

  bool get hasData =>
      kpis.isNotEmpty ||
      attention.isNotEmpty ||
      schedule.isNotEmpty ||
      myWork.isNotEmpty ||
      team.isNotEmpty ||
      breakdowns.isNotEmpty ||
      activity.isNotEmpty ||
      quickActions.isNotEmpty ||
      myDay.isNotEmpty;

  static const empty = DashboardContribution(moduleId: '');
}

/// The capability inputs a contributor uses to decide visibility and scope.
class DashboardCapabilityContext {
  const DashboardCapabilityContext({required this.auth, required this.l10n});

  final AuthContext auth;
  final AppLocalizations l10n;

  PermissionChecker get permissions => PermissionChecker(auth.user.permissions);

  bool can(AppPermission permission) =>
      auth.user.permissions.contains(permission);

  bool anyCan(Iterable<AppPermission> permissions) =>
      permissions.any(auth.user.permissions.contains);

  bool moduleEnabled(String moduleId) =>
      auth.company.enabledModules.contains(moduleId);

  String? get employeeId => auth.employeeReference?.id;
}

/// The merged cross-module dashboard projection the universal page renders.
class UniversalDashboardSnapshot {
  UniversalDashboardSnapshot({
    required this.contributions,
    required this.generatedAt,
    this.today,
    this.partialFailure = false,
    this.maxKpis = 6,
    this.maxAttention = 8,
    this.maxSchedule = 8,
    this.maxWork = 8,
    this.maxActivity = 8,
    this.maxQuickActions = 6,
  });

  final List<DashboardContribution> contributions;
  final DateTime generatedAt;

  /// Company-local business date (UTC midnight) resolved through AppClock +
  /// CompanyTimeService. Null when the composition root could not resolve a
  /// company timezone; the header then falls back to [generatedAt].
  final DateTime? today;
  final bool partialFailure;
  final int maxKpis, maxAttention, maxSchedule, maxWork, maxActivity;
  final int maxQuickActions;

  List<DashboardContribution> get _ordered {
    final sorted = [...contributions]
      ..sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }

  List<DashboardKpi> get kpis {
    final all = [for (final c in _ordered) ...c.kpis];
    all.sort((a, b) {
      final rank = a.rank.compareTo(b.rank);
      return rank != 0 ? rank : a.id.compareTo(b.id);
    });
    return all.take(maxKpis).toList(growable: false);
  }

  List<DashboardAttentionItem> get attention {
    final all = [for (final c in _ordered) ...c.attention];
    all.sort(_compareAttention);
    return all.take(maxAttention).toList(growable: false);
  }

  List<DashboardScheduleItem> get schedule {
    final all = [for (final c in _ordered) ...c.schedule];
    all.sort((a, b) {
      final at = a.time, bt = b.time;
      if (at == null && bt == null) return a.id.compareTo(b.id);
      if (at == null) return 1;
      if (bt == null) return -1;
      final time = at.compareTo(bt);
      return time != 0 ? time : a.id.compareTo(b.id);
    });
    return all.take(maxSchedule).toList(growable: false);
  }

  List<DashboardWorkItem> get myWork {
    final all = [for (final c in _ordered) ...c.myWork];
    return all.take(maxWork).toList(growable: false);
  }

  List<DashboardTeamRow> get team => [for (final c in _ordered) ...c.team];

  List<DashboardBreakdown> get breakdowns => [
    for (final c in _ordered) ...c.breakdowns,
  ];

  List<DashboardActivityItem> get activity {
    final all = [for (final c in _ordered) ...c.activity];
    all.sort((a, b) {
      final byDate = b.occurredAt.compareTo(a.occurredAt);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
    return all.take(maxActivity).toList(growable: false);
  }

  List<DashboardQuickAction> get quickActions {
    final seen = <String>{};
    final all = <DashboardQuickAction>[];
    for (final c in _ordered) {
      for (final action in c.quickActions) {
        if (seen.add(action.id)) all.add(action);
      }
    }
    return all.take(maxQuickActions).toList(growable: false);
  }

  List<Widget> get myDay => [for (final c in _ordered) ...c.myDay];

  /// First authorized "view all" route for [section], or null.
  String? viewAll(DashboardSection section) {
    for (final c in _ordered) {
      final route = c.viewAll[section];
      if (route != null) return route;
    }
    return null;
  }

  /// Distinct, non-empty, already-localized scope labels.
  List<String> get scopeLabels {
    final labels = <String>[];
    for (final c in _ordered) {
      if (c.scopeLabel.isNotEmpty && !labels.contains(c.scopeLabel)) {
        labels.add(c.scopeLabel);
      }
    }
    return labels;
  }

  bool get hasAnyData =>
      myDay.isNotEmpty ||
      kpis.isNotEmpty ||
      attention.isNotEmpty ||
      schedule.isNotEmpty ||
      myWork.isNotEmpty ||
      team.isNotEmpty ||
      breakdowns.isNotEmpty ||
      activity.isNotEmpty ||
      quickActions.isNotEmpty;

  static int _compareAttention(
    DashboardAttentionItem a,
    DashboardAttentionItem b,
  ) {
    final priority = b.priority.compareTo(a.priority);
    if (priority != 0) return priority;
    final ad = a.date, bd = b.date;
    if (ad == null && bd != null) return 1;
    if (ad != null && bd == null) return -1;
    if (ad != null && bd != null) {
      final date = ad.compareTo(bd);
      if (date != 0) return date;
    }
    return a.id.compareTo(b.id);
  }
}
