import '../../theme/app_spacing.dart';
import '../../../l10n/l10n.dart';
import 'package:flutter/material.dart';
import '../buttons/app_buttons.dart';
import '../../../core/localization/app_formatters.dart';

class AppDataTable extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.showCheckboxColumn = false,
  });
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final int? sortColumnIndex;
  final bool sortAscending, showCheckboxColumn;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: constraints.maxWidth),
        child: DataTable(
          showCheckboxColumn: showCheckboxColumn,
          columnSpacing: AppSpacing.lg,
          horizontalMargin: AppSpacing.lg,
          dataRowMinHeight: 64,
          dataRowMaxHeight:
              64 * MediaQuery.textScalerOf(context).scale(1).clamp(1, 2),
          columns: columns,
          rows: rows,
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortAscending,
        ),
      ),
    ),
  );
}

class AppTablePagination extends StatelessWidget {
  const AppTablePagination({
    super.key,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.onPageChanged,
  });
  final int page, pageSize, total;
  final ValueChanged<int> onPageChanged;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          total == 0
              ? context.l10n.noRecords
              : context.l10n.paginationSummary(
                  AppNumberFormatter(
                    Localizations.localeOf(context),
                  ).integer(page * pageSize + 1),
                  AppNumberFormatter(
                    Localizations.localeOf(context),
                  ).integer(((page + 1) * pageSize).clamp(0, total)),
                  AppNumberFormatter(
                    Localizations.localeOf(context),
                  ).integer(total),
                ),
        ),
      ),
      AppIconButton(
        icon: Icons.chevron_left,
        tooltip: context.l10n.previousPage,
        onPressed: page > 0 ? () => onPageChanged(page - 1) : null,
      ),
      AppIconButton(
        icon: Icons.chevron_right,
        tooltip: context.l10n.nextPage,
        onPressed: (page + 1) * pageSize < total
            ? () => onPageChanged(page + 1)
            : null,
      ),
    ],
  );
}
