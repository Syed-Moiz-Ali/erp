import 'package:flutter/material.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';

class ModulePlaceholderPage extends StatelessWidget {
  const ModulePlaceholderPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });
  final LocalizedText title, description;
  final IconData icon;
  @override
  Widget build(BuildContext context) => AppPage(
    header: AppPageHeader(
      title: title(context.l10n),
      subtitle: description(context.l10n),
    ),
    child: AppCard(
      child: AppEmptyState(
        title: context.l10n.shellPlaceholderTitle,
        message: context.l10n.shellPlaceholderMessage,
        icon: icon,
      ),
    ),
  );
}

class AttendancePlaceholderPage extends StatelessWidget {
  const AttendancePlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => ModulePlaceholderPage(
    title: (l) => l.shellAttendance,
    description: (l) => l.shellAttendanceDescription,
    icon: Icons.schedule_outlined,
  );
}

class ReportsPlaceholderPage extends StatelessWidget {
  const ReportsPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => ModulePlaceholderPage(
    title: (l) => l.shellReports,
    description: (l) => l.shellReportsDescription,
    icon: Icons.assessment_outlined,
  );
}

