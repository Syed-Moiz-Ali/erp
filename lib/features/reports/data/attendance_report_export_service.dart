import 'dart:convert';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/errors/result.dart';
import '../../../core/localization/app_formatters.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/attendance_report_models.dart';
import '../domain/attendance_report_repository.dart';

enum ReportExportFormat { csv, pdf }

class ReportExportRequest {
  const ReportExportRequest({
    required this.type,
    required this.filter,
    required this.sort,
    required this.format,
    required this.locale,
    required this.companyName,
    required this.generatedAt,
  });
  final AttendanceReportType type;
  final AttendanceReportFilter filter;
  final AttendanceReportSort sort;
  final ReportExportFormat format;
  final Locale locale;
  final String companyName;
  final DateTime generatedAt;
}

class ReportExportResult {
  const ReportExportResult({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.createdAt,
  });
  final Uint8List bytes;
  final String fileName, mimeType;
  final DateTime createdAt;
}

abstract interface class ReportFileSaver {
  Future<void> save(ReportExportResult result);
}

/// Bytes-based saver works on mobile, desktop and web without dart:io in UI.
class PlatformReportFileSaver implements ReportFileSaver {
  const PlatformReportFileSaver();
  @override
  Future<void> save(ReportExportResult result) async {
    final extension = result.mimeType == 'text/csv' ? 'csv' : 'pdf';
    await FileSaver.instance.saveFile(
      name: result.fileName.substring(0, result.fileName.length - 4),
      bytes: result.bytes,
      fileExtension: extension,
      mimeType: extension == 'csv' ? MimeType.csv : MimeType.pdf,
    );
  }
}

class AttendanceReportExportService {
  const AttendanceReportExportService(this.repository, this.saver);
  final AttendanceReportRepository repository;
  final ReportFileSaver saver;

  Future<Result<ReportExportResult>> export(ReportExportRequest request) async {
    final result = await repository.exportData(
      request.filter,
      request.type,
      sort: request.sort,
    );
    if (result is Failed<AttendanceReportData>) return Failed(result.failure);
    final data = (result as Success<AttendanceReportData>).value;
    final l = lookupAppLocalizations(request.locale);
    final stem = _filename(request);
    try {
      await initializeDateFormatting(request.locale.languageCode);
      final bytes = request.format == ReportExportFormat.csv
          ? _csv(data, request.locale, l)
          : await _pdf(data, request, l);
      final exported = ReportExportResult(
        bytes: bytes,
        fileName: '$stem.${request.format.name}',
        mimeType: request.format == ReportExportFormat.csv
            ? 'text/csv'
            : 'application/pdf',
        createdAt: request.generatedAt,
      );
      await saver.save(exported);
      return Success(exported);
    } catch (_) {
      return const Failed(Failure(code: 'reportExportFailed', retryable: true));
    }
  }

  String _filename(ReportExportRequest request) {
    String day(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final kind = switch (request.type) {
      AttendanceReportType.overview => 'overview',
      AttendanceReportType.workHours => 'work_hours',
      AttendanceReportType.lateAttendance => 'late_attendance',
      AttendanceReportType.breakAnalysis => 'break_analysis',
      AttendanceReportType.issues => 'issues',
      AttendanceReportType.employeeSummary => 'employee_summary',
    };
    return 'attendance_${kind}_${day(request.filter.from)}_to_${day(request.filter.to)}';
  }

  String _title(AttendanceReportType type, AppLocalizations l) =>
      switch (type) {
        AttendanceReportType.overview => l.reportOverview,
        AttendanceReportType.workHours => l.reportWorkHours,
        AttendanceReportType.lateAttendance => l.reportLate,
        AttendanceReportType.breakAnalysis => l.reportBreaks,
        AttendanceReportType.issues => l.reportIssues,
        AttendanceReportType.employeeSummary => l.reportEmployees,
      };

  (List<String>, List<List<String>>) _table(
    AttendanceReportData data,
    Locale locale,
    AppLocalizations l,
  ) {
    final grouped =
        data.type == AttendanceReportType.workHours ||
        data.type == AttendanceReportType.breakAnalysis ||
        data.type == AttendanceReportType.employeeSummary;
    String duration(int ms) {
      final minutes = Duration(milliseconds: ms).inMinutes;
      return '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';
    }

    String iso(DateTime? value) => value == null
        ? ''
        : '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    final headers = grouped
        ? [
            l.reportEmployee,
            l.workforceCode,
            l.reportDepartment,
            l.reportRecorded,
            l.reportCompleted,
            l.reportLateCount,
            l.reportWorked,
            l.reportBreak,
            l.reportIssuesCount,
            l.reportPending,
          ]
        : [
            l.reportDate,
            l.reportEmployee,
            l.workforceCode,
            l.reportDepartment,
            l.workforceShift,
            l.reportLocation,
            l.reportStatus,
            l.reportPunchIn,
            l.reportWorked,
            l.reportBreak,
            l.reportLateBy,
            l.reportIssuesCount,
            l.reportPending,
          ];
    final rows = <List<String>>[
      for (final row in data.rows)
        if (grouped)
          [
            row.employeeName,
            row.employeeCode,
            row.department,
            '${row.recordedDays}',
            '${row.completedDays}',
            '${row.lateDays}',
            duration(row.workMilliseconds),
            duration(row.breakMilliseconds),
            '${row.issueDays}',
            '${row.pendingCorrections}',
          ]
        else
          [
            iso(row.date),
            row.employeeName,
            row.employeeCode,
            row.department,
            row.shift ?? '',
            row.location ?? '',
            row.status ?? '',
            row.punchIn == null
                ? ''
                : AppTimeFormatter(locale).time(row.punchIn!),
            duration(row.workMilliseconds),
            duration(row.breakMilliseconds),
            duration(row.lateBy.inMilliseconds),
            '${row.issueDays}',
            '${row.pendingCorrections}',
          ],
    ];
    return (headers, rows);
  }

  Uint8List _csv(AttendanceReportData data, Locale locale, AppLocalizations l) {
    final (headers, rows) = _table(data, locale, l);
    String cell(String value) {
      final safe = RegExp(r'^[=+@\-]').hasMatch(value) ? "'$value" : value;
      return '"${safe.replaceAll('"', '""')}"';
    }

    final content = [
      headers,
      ...rows,
    ].map((row) => row.map(cell).join(',')).join('\r\n');
    return Uint8List.fromList([
      0xef,
      0xbb,
      0xbf,
      ...utf8.encode('$content\r\n'),
    ]);
  }

  Future<Uint8List> _pdf(
    AttendanceReportData data,
    ReportExportRequest request,
    AppLocalizations l,
  ) async {
    final arabic = request.locale.languageCode == 'ar';
    final regular = pw.Font.ttf(
      await rootBundle.load(
        arabic
            ? 'assets/fonts/IBMPlexSansArabic-Regular.ttf'
            : 'assets/fonts/Manrope-Regular.ttf',
      ),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load(
        arabic
            ? 'assets/fonts/IBMPlexSansArabic-Bold.ttf'
            : 'assets/fonts/Manrope-Bold.ttf',
      ),
    );
    final pdf = pw.Document();
    final theme = pw.ThemeData.withFont(base: regular, bold: bold);
    final dates = AppDateFormatter(request.locale);
    final period =
        '${dates.date(request.filter.from)} – ${dates.date(request.filter.to)}';
    final (headers, rows) = _table(data, request.locale, l);
    final ink = PdfColor.fromHex('#28242B');
    final muted = PdfColor.fromHex('#716B75');
    final line = PdfColor.fromHex('#E8E3E9');
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        theme: theme,
        textDirection: arabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              request.companyName,
              style: pw.TextStyle(font: bold, fontSize: 10, color: muted),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              _title(request.type, l),
              style: pw.TextStyle(font: bold, fontSize: 20, color: ink),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '${l.reportPeriod}: $period',
              style: pw.TextStyle(fontSize: 9, color: muted),
            ),
            pw.Text(
              '${l.reportGenerated}: ${dates.date(request.generatedAt)}',
              style: pw.TextStyle(fontSize: 9, color: muted),
            ),
            pw.Divider(color: line),
          ],
        ),
        footer: (context) => pw.Align(
          alignment: arabic
              ? pw.Alignment.centerLeft
              : pw.Alignment.centerRight,
          child: pw.Text(
            '${l.reportPage} ${context.pageNumber} / ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 9, color: muted),
          ),
        ),
        build: (context) => [
          pw.Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _pdfMetric(
                l.reportRecordedDays,
                data.summary.recordedDays.toString(),
                bold,
              ),
              _pdfMetric(
                l.reportCompletedDays,
                data.summary.completedDays.toString(),
                bold,
              ),
              _pdfMetric(
                l.reportLateDays,
                data.summary.lateDays.toString(),
                bold,
              ),
              _pdfMetric(
                l.reportWorkTotal,
                AppTimeFormatter(
                  request.locale,
                ).duration(data.summary.totalWork, l),
                bold,
              ),
              _pdfMetric(
                l.reportBreakTotal,
                AppTimeFormatter(
                  request.locale,
                ).duration(data.summary.totalBreak, l),
                bold,
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          if (rows.isNotEmpty)
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: rows,
              headerStyle: pw.TextStyle(font: bold, fontSize: 8, color: ink),
              cellStyle: pw.TextStyle(font: regular, fontSize: 7.5, color: ink),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F5F2F6'),
              ),
              cellPadding: const pw.EdgeInsets.all(5),
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(color: line),
              ),
              oddRowDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FBFAFC'),
              ),
            )
          else
            pw.Text(l.reportNoData),
        ],
      ),
    );
    return pdf.save();
  }

  pw.Widget _pdfMetric(String label, String value, pw.Font bold) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
      pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 12)),
    ],
  );
}
