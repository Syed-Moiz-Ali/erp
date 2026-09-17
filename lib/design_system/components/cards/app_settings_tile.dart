import 'package:flutter/material.dart';
import '../../design_system.dart';

class AppSettingsTile extends StatelessWidget {
  const AppSettingsTile({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
    this.count,
  });
  final String title, description;
  final String? count;
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon),
        title: Text(title, style: AppTypography.of(context).cardTitle),
        subtitle: Text(description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (count != null)
              Text(count!, style: AppTypography.of(context).sectionTitle),
            const SizedBox(width: AppSpacing.md),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onPressed,
      ),
    ),
  );
}
