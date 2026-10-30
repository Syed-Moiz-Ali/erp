import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/access/data/dto/permission_dtos.dart';
import 'package:modular_erp/platform/access/data/repositories/remote_permission_master_repository.dart';
import 'package:modular_erp/platform/access/presentation/pages/permission_catalog_details_page.dart';
import 'package:modular_erp/platform/access/presentation/pages/permission_catalog_form_page.dart';
import 'package:modular_erp/platform/access/presentation/pages/permission_catalog_list_page.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

import 'auth_widget_test.dart' as h;
import 'employee_widget_test.dart' show settleDb;
import 'support/access_admin_fake.dart';

PermissionDto _dto({
  int id = 18,
  String key = 'company.access.users.view',
  String name = 'View access users',
  String? description = 'See company users and their access.',
}) => PermissionDto(
  permissionId: id,
  permissionKey: key,
  permissionName: name,
  statusId: 1,
  description: description,
  status: 'Active',
  createdOn: DateTime.utc(2026, 1, 2),
  modifiedOn: DateTime.utc(2026, 1, 3),
);

Future<(FakeAccessAdminRemoteDataSource, h.Harness)> _login(
  WidgetTester t,
  double width,
) async {
  h.viewport(t, width);
  final data = FakeAccessAdminRemoteDataSource()
    ..permissionsCatalog = [
      _dto(),
      _dto(
        id: 19,
        key: 'company.access.users.edit',
        name: 'Edit access users',
        description: 'Change user access.',
      ),
    ];
  final repository = RemotePermissionMasterRepository(data);
  final app = await h.mount(
    t,
    AppLanguage.english,
    registryFactory: (auth) =>
        createErpRegistry(auth, permissionMasterRepository: repository),
  );
  app.auth.add(const AuthLoginRequested('admin@erp.demo', 'Admin@123'));
  await h.pump(t);
  return (data, app);
}

void main() {
  testWidgets('permission catalog list, detail and form render and validate', (
    t,
  ) async {
    final (_, app) = await _login(t, 390);

    h.router(t).go(AppRoutes.settings);
    await settleDb(t);
    final row = find.text('Permission catalog');
    expect(row, findsOneWidget);
    await t.ensureVisible(row);
    await t.tap(row);
    await settleDb(t);
    expect(find.byType(PermissionCatalogListPage), findsOneWidget);
    expect(find.text('View access users'), findsOneWidget);
    expect(find.text('company.access.users.view'), findsOneWidget);
    expect(find.text('See company users and their access.'), findsOneWidget);

    h.router(t).go(AppRoutes.permissionCatalogDetails('18'));
    await settleDb(t);
    expect(find.byType(PermissionCatalogDetailsPage), findsOneWidget);
    expect(find.text('View access users'), findsWidgets);
    expect(find.text('company.access.users.view'), findsOneWidget);
    expect(find.text('See company users and their access.'), findsOneWidget);

    h.router(t).go(AppRoutes.permissionCatalogNew);
    await settleDb(t);
    final form = t.element(find.byType(PermissionCatalogFormPage));
    expect(find.text(form.l10n.permissionCatalogKey), findsOneWidget);
    expect(find.text(form.l10n.permissionCatalogKeyHelper), findsOneWidget);

    final save = find.widgetWithText(AppPrimaryButton, form.l10n.save);
    await t.ensureVisible(save);
    await settleDb(t);
    await t.tap(save);
    await settleDb(t);
    expect(find.text(form.l10n.cfgRequired), findsNWidgets(2));
    await h.unmount(t, app);
  });

  for (final width in [390.0, 1440.0]) {
    testWidgets('permission catalog screens fit at $width', (t) async {
      final (data, app) = await _login(t, width);
      data.createResult = Success(_dto());

      h.router(t).go(AppRoutes.permissionCatalog);
      await settleDb(t);
      expect(find.byType(PermissionCatalogListPage), findsOneWidget);
      expect(t.takeException(), isNull);

      h.router(t).go(AppRoutes.permissionCatalogDetails('18'));
      await settleDb(t);
      expect(find.byType(PermissionCatalogDetailsPage), findsOneWidget);
      expect(t.takeException(), isNull);

      h.router(t).go(AppRoutes.permissionCatalogEdit('18'));
      await settleDb(t);
      expect(find.byType(PermissionCatalogFormPage), findsOneWidget);
      expect(t.takeException(), isNull);
      await h.unmount(t, app);
    });
  }
}
