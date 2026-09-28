import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/l10n/generated/app_localizations.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request_repository.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Structured printable document for a Material Request. Built from the detail
/// read model so it can be asserted without rendering a PDF.
class MaterialRequestPrintDocument {
  const MaterialRequestPrintDocument({
    required this.companyName,
    required this.requestNumber,
    required this.requestDate,
    required this.inspectionNumber,
    required this.assignmentNumber,
    required this.enquiryNumber,
    required this.customerName,
    required this.siteSummary,
    required this.preparedByUserId,
    required this.lines,
    required this.totalQuantity,
    this.jobOrderReference,
    this.purposeName,
    this.acknowledgement,
    this.receivedBy,
    this.remarks,
    this.customerMobile,
    this.materialReceived,
  });
  final String companyName, requestNumber;
  final DateTime requestDate;
  final String inspectionNumber, assignmentNumber, enquiryNumber;
  final String customerName, siteSummary, preparedByUserId;
  final String? customerMobile, jobOrderReference, purposeName;
  final String? acknowledgement, receivedBy, remarks;
  final MaterialReceived? materialReceived;
  final List<ServiceMaterialRequestLine> lines;
  final double totalQuantity;
}

MaterialRequestPrintDocument buildMaterialRequestPrintDocument(
  ServiceMaterialRequestView view, {
  required String companyName,
  required AppLocalizations l,
}) {
  final request = view.request;
  final snapshot = view.partySnapshot;
  final site = [
    snapshot.siteName,
    snapshot.buildingName,
    snapshot.unitNumber,
  ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' / ');
  return MaterialRequestPrintDocument(
    companyName: companyName,
    requestNumber: request.requestNumber,
    requestDate: request.requestDate,
    inspectionNumber: view.inspectionNumber,
    assignmentNumber: view.assignmentNumber,
    enquiryNumber: view.enquiryNumber,
    customerName: view.customerName,
    customerMobile: view.customerMobile,
    siteSummary: site,
    preparedByUserId: request.createdByUserId,
    jobOrderReference: request.jobOrderReference,
    purposeName: view.purposeName,
    acknowledgement: request.acknowledgement,
    receivedBy: request.receivedBy,
    remarks: request.remarks,
    materialReceived: view.materialReceived,
    lines: request.lines,
    totalQuantity: request.totalQuantity,
  );
}

abstract interface class MaterialRequestFileSaver {
  Future<void> save({required String name, required Uint8List bytes});
}

class PlatformMaterialRequestFileSaver implements MaterialRequestFileSaver {
  const PlatformMaterialRequestFileSaver();
  @override
  Future<void> save({required String name, required Uint8List bytes}) async {
    await FileSaver.instance.saveFile(
      name: name,
      bytes: bytes,
      fileExtension: 'pdf',
      mimeType: MimeType.pdf,
    );
  }
}

/// Generates and saves the printable Material Request document.
///
/// Direct invocation also enforces the Print permission; the read itself is
/// authorized by `services.materialRequests.view` + object scope inside the
/// repository, so View + Print + scope are all required.
class MaterialRequestPrintService {
  const MaterialRequestPrintService(this.repository, this.saver);
  final ServiceMaterialRequestRepository repository;
  final MaterialRequestFileSaver saver;

  Future<Result<MaterialRequestPrintDocument>> print(
    AuthContext context,
    String id, {
    required Locale locale,
    required String companyName,
    AppLocalizations? l10n,
  }) async {
    if (!context.user.permissions.contains(
      AppPermission.serviceMaterialRequestPrint,
    )) {
      return const Failed(Failure(code: 'servicesMaterialRequestDenied'));
    }
    final fetched = await repository.getRequest(context, id);
    if (fetched is Failed<ServiceMaterialRequestView?>) {
      return Failed(fetched.failure);
    }
    final view = (fetched as Success<ServiceMaterialRequestView?>).value;
    if (view == null) {
      return const Failed(Failure(code: 'servicesMaterialRequestNotFound'));
    }
    final l = l10n ?? lookupAppLocalizations(locale);
    final document = buildMaterialRequestPrintDocument(
      view,
      companyName: companyName,
      l: l,
    );
    try {
      final bytes = await _render(document, locale, l);
      await saver.save(name: '${document.requestNumber}.pdf', bytes: bytes);
      return Success(document);
    } catch (_) {
      return const Failed(Failure(code: 'servicesMaterialRequestPrintFailed'));
    }
  }

  Future<Uint8List> _render(
    MaterialRequestPrintDocument document,
    Locale locale,
    AppLocalizations l,
  ) async {
    final arabic = locale.languageCode == 'ar';
    final arabicRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf'),
    );
    final arabicBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/IBMPlexSansArabic-Bold.ttf'),
    );
    final latinRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Manrope-Regular.ttf'),
    );
    final latinBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Manrope-Bold.ttf'),
    );
    final regular = arabic ? arabicRegular : latinRegular;
    final bold = arabic ? arabicBold : latinBold;
    final fallback = arabic
        ? <pw.Font>[latinRegular, latinBold]
        : <pw.Font>[arabicRegular, arabicBold];
    final pdf = pw.Document();
    final theme = pw.ThemeData.withFont(
      base: regular,
      bold: bold,
      italic: regular,
      boldItalic: bold,
      fontFallback: fallback,
    );
    pw.TextStyle style(pw.Font font, double size, PdfColor color) =>
        pw.TextStyle(
          font: font,
          fontSize: size,
          color: color,
          fontFallback: fallback,
        );
    final dates = AppDateFormatter(locale);
    final totalLabel = [
      l.servicesMaterialRequestTotalQuantity,
      formatMaterialQuantity(document.totalQuantity),
    ].join(': ');
    final ink = PdfColor.fromHex('#28242B');
    final muted = PdfColor.fromHex('#716B75');
    final line = PdfColor.fromHex('#E8E3E9');
    final body = style(regular, 9, muted);
    pw.Widget row(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(label, style: style(bold, 8, muted)),
          ),
          pw.Expanded(child: pw.Text(value, style: body)),
        ],
      ),
    );
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        textDirection: arabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(document.companyName, style: style(bold, 10, muted)),
            pw.SizedBox(height: 4),
            pw.Text(
              l.servicesMaterialRequestPrintTitle,
              style: style(bold, 20, ink),
            ),
            pw.Divider(color: line),
          ],
        ),
        build: (context) => [
          row(l.servicesMaterialRequestNo, document.requestNumber),
          row(l.servicesMaterialRequestDate, dates.date(document.requestDate)),
          row(l.servicesMaterialRequestInspection, document.inspectionNumber),
          row(
            l.servicesMaterialRequestJobAssignment,
            document.assignmentNumber,
          ),
          row(l.servicesMaterialRequestEnquiry, document.enquiryNumber),
          if ((document.jobOrderReference ?? '').isNotEmpty)
            row(
              l.servicesMaterialRequestJobOrderReference,
              document.jobOrderReference!,
            ),
          if ((document.purposeName ?? '').isNotEmpty)
            row(l.servicesMaterialRequestPurpose, document.purposeName!),
          row(l.servicesMaterialRequestCustomer, document.customerName),
          if ((document.customerMobile ?? '').isNotEmpty)
            row(l.servicesEnquiryCustomerMobile, document.customerMobile!),
          if (document.siteSummary.isNotEmpty)
            row(l.servicesMaterialRequestSite, document.siteSummary),
          if (document.materialReceived != null)
            row(
              l.servicesMaterialRequestMaterialReceived,
              serviceMaterialReceivedLabel(document.materialReceived!, l),
            ),
          if ((document.acknowledgement ?? '').isNotEmpty)
            row(
              l.servicesMaterialRequestAcknowledge,
              document.acknowledgement!,
            ),
          if ((document.receivedBy ?? '').isNotEmpty)
            row(l.servicesMaterialRequestReceivedBy, document.receivedBy!),
          if ((document.remarks ?? '').isNotEmpty)
            row(l.servicesMaterialRequestRemarks, document.remarks!),
          row(l.servicesMaterialRequestPreparedBy, document.preparedByUserId),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: [
              '#',
              l.servicesMaterialRequestCode,
              l.servicesMaterialRequestDescription,
              l.servicesMaterialRequestBatchNumber,
              l.servicesMaterialRequestQuantity,
              l.servicesMaterialRequestRemark,
            ],
            data: [
              for (var i = 0; i < document.lines.length; i++)
                [
                  '${i + 1}',
                  document.lines[i].code,
                  document.lines[i].description,
                  document.lines[i].batchNumber ?? '',
                  formatMaterialQuantity(document.lines[i].quantity),
                  document.lines[i].remark ?? '',
                ],
            ],
            headerStyle: style(bold, 8, ink),
            cellStyle: style(regular, 8, ink),
            headerDecoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F5F2F6'),
            ),
            cellPadding: const pw.EdgeInsets.all(4),
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(color: line),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Align(
            alignment: pw.Alignment(arabic ? 1 : -1, 0),
            child: pw.Text(totalLabel, style: style(bold, 11, ink)),
          ),
        ],
      ),
    );
    return pdf.save();
  }
}
