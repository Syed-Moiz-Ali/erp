import 'package:flutter/semantics.dart';
import 'package:flutter/material.dart';
import '../../design_system.dart';

class AppTimelineItem {
  const AppTimelineItem({
    required this.id,
    required this.title,
    required this.time,
    required this.icon,
    this.detail,
    this.trailing,
    this.status = AppStatus.neutral,
  });
  final String id, title, time;
  final String? detail;
  final IconData icon;
  final Widget? trailing;
  final AppStatus status;
}

class AppTimeline extends StatelessWidget {
  const AppTimeline({super.key, required this.items});
  final List<AppTimelineItem> items;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < items.length; i++)
        Semantics(
          sortKey: OrdinalSortKey(i.toDouble()),
          child: Padding(
            key: ValueKey(items[i].id),
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(items[i].icon, size: 20, color: items[i].status.color),
                    if (i < items.length - 1)
                      Container(
                        width: 1,
                        height: AppSpacing.xxl,
                        margin: const EdgeInsets.only(top: AppSpacing.sm),
                        color: AppColors.border,
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            items[i].title,
                            style: AppTypography.of(context).label,
                          ),
                          Text(
                            items[i].time,
                            style: AppTypography.of(context).caption,
                          ),
                          if (items[i].trailing != null) items[i].trailing!,
                        ],
                      ),
                      if (items[i].detail != null)
                        Text(
                          items[i].detail!,
                          style: AppTypography.of(context).bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}
