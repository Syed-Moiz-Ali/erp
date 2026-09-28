import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_workflow_timeline.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';

ServiceWorkflowChain _chain({required bool withMaterialRequest}) =>
    ServiceWorkflowChain(
      enquiryId: 'e1',
      enquiryNumber: 'ENQ-000001',
      status: withMaterialRequest
          ? ServiceWorkflowStatus.materialsRequested
          : ServiceWorkflowStatus.workInProgress,
      nodes: [
        const ServiceWorkflowNode(
          stage: ServiceWorkflowStage.enquiry,
          present: true,
          id: 'e1',
          reference: 'ENQ-000001',
          statusKey: 'assigned',
        ),
        const ServiceWorkflowNode(
          stage: ServiceWorkflowStage.jobAssignment,
          present: true,
          id: 'j1',
          reference: 'JA-000001',
          statusKey: 'active',
        ),
        const ServiceWorkflowNode(
          stage: ServiceWorkflowStage.inspection,
          present: true,
          id: 'i1',
          reference: 'INS-000001',
          statusKey: 'completed',
          waitingMaterialCount: 1,
        ),
        if (withMaterialRequest)
          const ServiceWorkflowNode(
            stage: ServiceWorkflowStage.materialRequest,
            present: true,
            id: 'm1',
            reference: 'MR-000001',
            statusKey: 'open',
            recordCount: 1,
          )
        else
          const ServiceWorkflowNode(
            stage: ServiceWorkflowStage.materialRequest,
            present: false,
          ),
        const ServiceWorkflowNode(
          stage: ServiceWorkflowStage.workExecution,
          present: true,
          id: 'w1',
          reference: 'WE-000001',
          statusKey: 'inProgress',
        ),
      ],
    );

Future<void> _pump(
  WidgetTester tester,
  ServiceWorkflowChain chain, {
  Locale locale = const Locale('en'),
  void Function(ServiceWorkflowStage, String)? onOpenStage,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(locale: locale),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: ServiceWorkflowTimeline(
            chain: chain,
            onOpenStage: onOpenStage,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('renders every real transaction reference', (tester) async {
    await _pump(tester, _chain(withMaterialRequest: true));
    expect(find.text('ENQ-000001'), findsOneWidget);
    expect(find.text('JA-000001'), findsOneWidget);
    expect(find.text('INS-000001'), findsOneWidget);
    expect(find.text('MR-000001'), findsOneWidget);
    expect(find.text('WE-000001'), findsOneWidget);
  });

  testWidgets('optional material request is not shown as broken', (
    tester,
  ) async {
    await _pump(tester, _chain(withMaterialRequest: false));
    expect(find.text('Not required / none created'), findsOneWidget);
    expect(find.text('MR-000001'), findsNothing);
    // The workflow is not marked missing.
    expect(find.text('Not available'), findsNothing);
  });

  testWidgets('present nodes are tappable and absent nodes are not', (
    tester,
  ) async {
    final tapped = <String>[];
    await _pump(
      tester,
      _chain(withMaterialRequest: false),
      onOpenStage: (stage, id) => tapped.add('${stage.key}:$id'),
    );
    await tester.tap(find.text('WE-000001'));
    await tester.pump();
    expect(tapped, ['workExecution:w1']);
  });

  testWidgets('renders in Arabic RTL without error', (tester) async {
    await _pump(
      tester,
      _chain(withMaterialRequest: true),
      locale: const Locale('ar'),
    );
    expect(tester.takeException(), isNull);
    final context = tester.element(find.byType(ServiceWorkflowTimeline));
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
