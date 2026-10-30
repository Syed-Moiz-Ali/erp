import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';
import 'package:modular_erp/modules/hr/branches/presentation/pages/branch_details_page.dart';
import 'package:modular_erp/modules/hr/branches/presentation/pages/branch_form_page.dart';
import 'package:modular_erp/modules/hr/branches/presentation/pages/branch_list_page.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

import 'auth_widget_test.dart' as h;
import 'employee_widget_test.dart' show settleDb;
import 'support/branch_test_doubles.dart';

Branch _branch({
  int id = 1,
  String name = 'Head Office',
  String? code = 'BR-1',
  int? divisionId = 1,
  String? divisionName = 'Division 1',
}) => Branch(
  branchId: id,
  branchName: name,
  branchCode: code,
  contactPerson: 'Contact Person',
  mobileNo: '0000000000',
  landLine: '1111111111',
  address: 'Office address',
  email: 'branch@example.test',
  inventoryAlerts: 'Yes',
  multiInventory: 'No',
  divisionId: divisionId,
  divisionName: divisionName,
  statusId: 1,
  status: BranchStatus.active.wire,
  timeZoneId: 'Asia/Dubai',
);

Future<(InMemoryBranchRepository, h.Harness)> _login(
  WidgetTester t,
  double width,
) async {
  h.viewport(t, width);
  final repository = InMemoryBranchRepository(
    branches: [
      _branch(id: 1),
      _branch(id: 2, name: 'Warehouse', code: 'BR-2', divisionId: 2),
    ],
  );
  final app = await h.mount(
    t,
    AppLanguage.english,
    registryFactory: (auth) =>
        createErpRegistry(auth, branchRepository: repository),
  );
  app.auth.add(const AuthLoginRequested('company@erp.demo', 'Company@123'));
  await h.pump(t);
  return (repository, app);
}

void main() {
  testWidgets('branch list, detail and form render and validate', (t) async {
    final (_, app) = await _login(t, 390);

    h.router(t).go(AppRoutes.branches);
    await settleDb(t);
    expect(find.byType(BranchListPage), findsOneWidget);
    expect(find.text('Head Office'), findsOneWidget);
    expect(find.text('BR-1 · Asia/Dubai'), findsOneWidget);

    h.router(t).go(AppRoutes.branchesDetails('1'));
    await settleDb(t);
    expect(find.byType(BranchDetailsPage), findsOneWidget);
    expect(find.text('BR-1'), findsOneWidget);
    expect(find.text('Asia/Dubai'), findsOneWidget);

    h.router(t).go(AppRoutes.branchesNew);
    await settleDb(t);
    final form = t.element(find.byType(BranchFormPage));
    expect(find.textContaining(form.l10n.cfgBranchTimeZone), findsOneWidget);
    expect(find.text(form.l10n.cfgBranchDivision), findsOneWidget);

    final save = find.widgetWithText(AppPrimaryButton, form.l10n.save);
    await t.ensureVisible(save);
    await settleDb(t);
    await t.tap(save);
    await settleDb(t);
    expect(find.text(form.l10n.cfgRequired), findsNWidgets(2));
    await h.unmount(t, app);
  });

  for (final width in [390.0, 1440.0]) {
    testWidgets('branch screens fit at $width', (t) async {
      final (_, app) = await _login(t, width);

      h.router(t).go(AppRoutes.branches);
      await settleDb(t);
      expect(find.byType(BranchListPage), findsOneWidget);
      expect(t.takeException(), isNull);

      h.router(t).go(AppRoutes.branchesDetails('1'));
      await settleDb(t);
      expect(find.byType(BranchDetailsPage), findsOneWidget);
      expect(t.takeException(), isNull);

      h.router(t).go(AppRoutes.branchesEdit('1'));
      await settleDb(t);
      expect(find.byType(BranchFormPage), findsOneWidget);
      expect(t.takeException(), isNull);
      await h.unmount(t, app);
    });
  }
}
