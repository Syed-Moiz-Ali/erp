import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../../l10n/l10n.dart';
import '../buttons/app_buttons.dart';
import '../../../core/localization/app_formatters.dart';

/// Enterprise data table with centralized density (compact header/row heights),
/// typed header styling and horizontal-scroll fallback on narrow widths.
///
/// Pair with [AppTablePagination] for paging and use [AppMobileRecordCard]
/// lists instead of this table on compact layouts.
class AppDataTable extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.showCheckboxColumn = false,
    this.dataRowMinHeight = AppDimensions.tableRowHeight,
    this.headingRowHeight = AppDimensions.tableHeaderHeight,
  });
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final int? sortColumnIndex;
  final bool sortAscending, showCheckboxColumn;
  final double dataRowMinHeight;
  final double headingRowHeight;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            showCheckboxColumn: showCheckboxColumn,
            columnSpacing: AppSpacing.lg,
            horizontalMargin: AppSpacing.lg,
            headingRowHeight: headingRowHeight * scale,
            dataRowMinHeight: dataRowMinHeight,
            dataRowMaxHeight: dataRowMinHeight * scale,
            headingTextStyle: AppTypography.of(context).tableHeader,
            columns: columns,
            rows: rows,
            sortColumnIndex: sortColumnIndex,
            sortAscending: sortAscending,
          ),
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Row(
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
            style: AppTypography.of(
              context,
            ).caption.copyWith(color: AppColors.textSecondary),
          ),
        ),
        AppIconButton(
          icon: isRtl ? Icons.chevron_right : Icons.chevron_left,
          tooltip: context.l10n.previousPage,
          onPressed: page > 0 ? () => onPageChanged(page - 1) : null,
        ),
        const SizedBox(width: AppSpacing.xs),
        AppIconButton(
          icon: isRtl ? Icons.chevron_left : Icons.chevron_right,
          tooltip: context.l10n.nextPage,
          onPressed: (page + 1) * pageSize < total
              ? () => onPageChanged(page + 1)
              : null,
        ),
      ],
    );
  }
}
