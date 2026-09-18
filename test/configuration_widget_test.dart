import 'package:modular_erp/features/employees/presentation/pages/employee_details_page.dart';
import 'package:modular_erp/features/employees/presentation/bloc/employee_details_bloc.dart';
import 'package:modular_erp/features/shifts/data/local_shift_repository.dart';
import 'employee_test.dart' show unwrap;
import 'package:modular_erp/features/shifts/presentation/bloc/shift_list_bloc.dart';
import 'package:modular_erp/core/utils/local_time.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geolocator/geolocator.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/features/auth/domain/entities/auth_context.dart';
import 'employee_test.dart' show employeeContext;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/app/shell/pages/route_status_pages.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/features/employees/presentation/pages/employee_form_page.dart';
import 'package:modular_erp/features/employees/presentation/bloc/employee_form_bloc.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'auth_widget_test.dart' as h;
import 'employee_widget_test.dart' show settleDb;
import 'configuration_test.dart'
    show shiftDraft, locationDraft, MockLocationService;
import 'package:modular_erp/features/shifts/domain/shift.dart';
import 'package:modular_erp/features/shifts/presentation/pages/shift_list_page.dart';
import 'package:modular_erp/features/shifts/presentation/pages/shift_form_page.dart';
import 'package:modular_erp/features/shifts/presentation/bloc/shift_form_bloc.dart';
import 'package:modular_erp/features/shifts/presentation/pages/shift_details_page.dart';
import 'package:modular_erp/features/shifts/presentation/bloc/shift_details_bloc.dart';
import 'package:modular_erp/features/work_locations/domain/work_location.dart';
import 'package:modular_erp/features/work_locations/presentation/pages/work_location_list_page.dart';
import 'package:modular_erp/features/work_locations/presentation/pages/work_location_form_page.dart';
import 'package:modular_erp/features/work_locations/presentation/bloc/work_location_form_bloc.dart';
import 'package:modular_erp/features/work_locations/presentation/pages/work_location_details_page.dart';
import 'package:modular_erp/features/work_locations/presentation/bloc/work_location_details_bloc.dart';
import 'package:modular_erp/features/attendance_policies/domain/attendance_policy.dart';
import 'package:modular_erp/features/attendance_policies/presentation/pages/attendance_policy_list_page.dart';
import 'package:modular_erp/features/attendance_policies/presentation/pages/attendance_policy_form_page.dart';
import 'package:modular_erp/features/attendance_policies/presentation/bloc/attendance_policy_form_bloc.dart';
import 'package:modular_erp/features/attendance_policies/presentation/pages/attendance_policy_details_page.dart';
import 'package:modular_erp/features/attendance_policies/presentation/bloc/attendance_policy_details_bloc.dart';

void main() {
  setUpAll(() async {
    for (final f in {
      'Inter': 'assets/fonts/InterVariable.ttf',
      'NotoSansArabic': 'assets/fonts/NotoSansArabicVariable.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      await (FontLoader(f.key)..addFont(rootBundle.load(f.value))).load();
    }
  });
  for (final language in AppLanguage.values) {
    for (final width in [
      360.0,
      390.0,
      430.0,
      600.0,
      768.0,
      900.0,
      1024.0,
      1280.0,
      1440.0,
      1920.0,
    ]) {
      testWidgets(
        '${language.name} configuration pages and employee selectors fit $width',
        (t) async {
          h.viewport(t, width);
          final app = await h.mount(t, language);
          app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
          await h.pump(t);
          final router = h.router(t);
          router.go(AppRoutes.shifts);
          await settleDb(t);
          expect(find.byType(ShiftListPage), findsOneWidget);
          if (width >= 1280) {
            final selected = t
                .widgetList<AppSidebarItem>(find.byType(AppSidebarItem))
                .where((item) => item.selected);
            expect(selected.length, 1);
            expect(selected.single.item.id, 'shifts');
          }
          expect(t.takeException(), isNull);
          if (width == 390 || width == 1440) {
            await h.screenshot(
              t,
              app.key,
              'phase5_shift_list_${language.name}_${width.toInt()}',
            );
          }
          router.go(AppRoutes.shiftsDetails('shift-night'));
          await settleDb(t);
          expect(find.byType(ShiftDetailsPage), findsOneWidget);
          expect(t.takeException(), isNull);
          if (width == 390 || width == 1440) {
            await h.screenshot(
              t,
              app.key,
              'phase5_shift_details_${language.name}_${width.toInt()}',
            );
          }
          router.go(AppRoutes.shiftsEdit('shift-night'));
          await settleDb(t);
          expect(find.byType(ShiftFormPage), findsOneWidget);
          expect(
            t
                .element(find.byType(ShiftFormPage))
                .read<ShiftFormBloc>()
                .state
                .draft
                .name,
            isNotEmpty,
          );
          expect(t.takeException(), isNull);
          router.go(AppRoutes.shiftsNew);
          await settleDb(t);
          expect(find.byType(ShiftFormPage), findsOneWidget);
          expect(t.takeException(), isNull);
          if (width == 390 || width == 1440) {
            await h.screenshot(
              t,
              app.key,
              'phase5_shift_form_${language.name}_${width.toInt()}',
            );
          }
          router.go(AppRoutes.workLocations);
          await settleDb(t);
          expect(find.byType(WorkLocationListPage), findsOneWidget);
          expect(t.takeException(), isNull);
          if (width == 390 || width == 1440) {
            await h.screenshot(
              t,
              app.key,
              'phase5_work_location_list_${language.name}_${width.toInt()}',
            );
          }
          router.go(AppRoutes.workLocationsDetails('location-hyderabad'));
          await settleDb(t);
          expect(find.byType(WorkLocationDetailsPage), findsOneWidget);
          expect(t.takeException(), isNull);
          if (width == 390 || width == 1440) {
            await h.screenshot(
              t,
              app.key,
              'phase5_work_location_details_${language.name}_${width.toInt()}',
            );
          }
          router.go(AppRoutes.workLocationsEdit('location-hyderabad'));
          await settleDb(t);
          expect(find.byType(WorkLocationFormPage), findsOneWidget);
          expect(
            t
                .element(find.byType(WorkLocationFormPage))
                .read<WorkLocationFormBloc>()
                .state
                .draft
                .name,
            isNotEmpty,
          );
          expect(t.takeException(), isNull);
          router.go(AppRoutes.workLocationsNew);
          await settleDb(t);
          expect(find.byType(WorkLocationFormPage), findsOneWidget);
          expect(t.takeException(), isNull);
          if (width == 390 || width == 1440) {
            await h.screenshot(
              t,
              app.key,
              'phase5_work_location_form_${language.name}_${width.toInt()}',
            );
          }
          router.go(AppRoutes.attendancePolicies);
          await settleDb(t);
          expect(find.byType(AttendancePolicyListPage), findsOneWidget);
          expect(t.takeException(), isNull);
          if (width == 390 || width == 1440) {
            await h.screenshot(
              t,
              app.key,
              'phase5_attendance_policy_list_${language.name}_${width.toInt()}',
            );
          }
          router.go(AppRoutes.attendancePoliciesDetails('policy-office'));
          await settleDb(t);
          expect(find.byType(AttendancePolicyDetailsPage), findsOneWidget);
          expect(t.takeException(), isNull);
          if (width == 390 || width == 1440) {
            await h.screenshot(
              t,
              app.key,
              'phase5_attendance_policy_details_${language.name}_${width.toInt()}',
            );
          }
          router.go(AppRoutes.attendancePoliciesEdit('policy-office'));
          await settleDb(t);
          expect(find.byType(AttendancePolicyFormPage), findsOneWidget);
          expect(
            t
                .element(find.byType(AttendancePolicyFormPage))
                .read<AttendancePolicyFormBloc>()
                .state
                .draft
                .name,
            isNotEmpty,
          );
          expect(t.takeException(), isNull);
          router.go(AppRoutes.attendancePoliciesNew);
          await settleDb(t);
          expect(find.byType(AttendancePolicyFormPage), findsOneWidget);
          expect(t.takeException(), isNull);
          if (width == 390 || width == 1440) {
            await h.screenshot(
              t,
              app.key,
              'phase5_attendance_policy_form_${language.name}_${width.toInt()}',
            );
          }
          router.go(AppRoutes.employeeEdit('employee-employee'));
          await settleDb(t);
          expect(find.byType(EmployeeFormPage), findsOneWidget);
          final refs = t
              .element(find.byType(EmployeeFormPage))
              .read<EmployeeFormBloc>()
              .state
              .references!;
          expect(refs.shifts.length, 4);
          expect(refs.workLocations.length, 2);
          expect(refs.attendancePolicies.length, 3);
          expect(t.takeException(), isNull);
          await h.unmount(t, app);
        },
      );
    }
  }
  testWidgets('Shift actual form creation, edit and status confirmation', (
    t,
  ) async {
    h.viewport(t, 390);
    final app = await h.mount(t, AppLanguage.english);
    app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await h.pump(t);
    final router = h.router(t);
    router.go(AppRoutes.shiftsNew);
    await settleDb(t);
    var c = t.element(find.byType(ShiftFormPage));
    var bloc = c.read<ShiftFormBloc>();
    bloc.add(RecordDraftChanged<ShiftDraft>((_) => shiftDraft()));
    await settleDb(t);
    await h.tapVisible(t, find.widgetWithText(AppPrimaryButton, c.l10n.save));
    await settleDb(t);
    expect(find.byType(ShiftDetailsPage), findsOneWidget);
    final detail = t
        .element(find.byType(ShiftDetailsPage))
        .read<ShiftDetailsBloc>();
    final recordId = detail.state.detail!.record.id;
    router.go(AppRoutes.shiftsEdit(recordId));
    await settleDb(t);
    c = t.element(find.byType(ShiftFormPage));
    bloc = c.read<ShiftFormBloc>();
    bloc.add(
      RecordDraftChanged<ShiftDraft>((d) => d.copyWith(name: 'Edited record')),
    );
    await settleDb(t);
    await h.tapVisible(t, find.widgetWithText(AppPrimaryButton, c.l10n.save));
    await settleDb(t);
    expect(find.text('Edited record'), findsOneWidget);
    c = t.element(find.byType(ShiftDetailsPage));
    await h.tapVisible(
      t,
      find.widgetWithText(AppSecondaryButton, c.l10n.cfgDeactivate),
    );
    await h.pump(t);
    expect(find.byType(AppDialog), findsOneWidget);
    await t.tap(find.widgetWithText(AppPrimaryButton, c.l10n.cfgDeactivate));
    await settleDb(t);
    expect(
      t
          .element(find.byType(ShiftDetailsPage))
          .read<ShiftDetailsBloc>()
          .state
          .detail!
          .record
          .status,
      ConfigurationStatus.inactive,
    );
    expect(t.takeException(), isNull);
    await h.unmount(t, app);
  });
  testWidgets(
    'WorkLocation actual form creation, edit and status confirmation',
    (t) async {
      h.viewport(t, 390);
      final app = await h.mount(t, AppLanguage.english);
      app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await h.pump(t);
      final router = h.router(t);
      router.go(AppRoutes.workLocationsNew);
      await settleDb(t);
      var c = t.element(find.byType(WorkLocationFormPage));
      var bloc = c.read<WorkLocationFormBloc>();
      bloc.add(RecordDraftChanged<WorkLocationDraft>((_) => locationDraft()));
      await settleDb(t);
      await h.tapVisible(t, find.widgetWithText(AppPrimaryButton, c.l10n.save));
      await settleDb(t);
      expect(find.byType(WorkLocationDetailsPage), findsOneWidget);
      final detail = t
          .element(find.byType(WorkLocationDetailsPage))
          .read<WorkLocationDetailsBloc>();
      final recordId = detail.state.detail!.record.id;
      router.go(AppRoutes.workLocationsEdit(recordId));
      await settleDb(t);
      c = t.element(find.byType(WorkLocationFormPage));
      bloc = c.read<WorkLocationFormBloc>();
      bloc.add(
        RecordDraftChanged<WorkLocationDraft>(
          (d) => d.copyWith(name: 'Edited record'),
        ),
      );
      await settleDb(t);
      await h.tapVisible(t, find.widgetWithText(AppPrimaryButton, c.l10n.save));
      await settleDb(t);
      expect(find.text('Edited record'), findsOneWidget);
      c = t.element(find.byType(WorkLocationDetailsPage));
      await h.tapVisible(
        t,
        find.widgetWithText(AppSecondaryButton, c.l10n.cfgDeactivate),
      );
      await h.pump(t);
      expect(find.byType(AppDialog), findsOneWidget);
      await t.tap(find.widgetWithText(AppPrimaryButton, c.l10n.cfgDeactivate));
      await settleDb(t);
      expect(
        t
            .element(find.byType(WorkLocationDetailsPage))
            .read<WorkLocationDetailsBloc>()
            .state
            .detail!
            .record
            .status,
        ConfigurationStatus.inactive,
      );
      expect(t.takeException(), isNull);
      await h.unmount(t, app);
    },
  );
  testWidgets(
    'AttendancePolicy actual form creation, edit and status confirmation',
    (t) async {
      h.viewport(t, 390);
      final app = await h.mount(t, AppLanguage.english);
      app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await h.pump(t);
      final router = h.router(t);
      router.go(AppRoutes.attendancePoliciesNew);
      await settleDb(t);
      var c = t.element(find.byType(AttendancePolicyFormPage));
      var bloc = c.read<AttendancePolicyFormBloc>();
      bloc.add(
        RecordDraftChanged<AttendancePolicyDraft>(
          (_) => const AttendancePolicyDraft(name: 'New policy'),
        ),
      );
      await settleDb(t);
      await h.tapVisible(t, find.widgetWithText(AppPrimaryButton, c.l10n.save));
      await settleDb(t);
      expect(find.byType(AttendancePolicyDetailsPage), findsOneWidget);
      final detail = t
          .element(find.byType(AttendancePolicyDetailsPage))
          .read<AttendancePolicyDetailsBloc>();
      final recordId = detail.state.detail!.record.id;
      router.go(AppRoutes.attendancePoliciesEdit(recordId));
      await settleDb(t);
      c = t.element(find.byType(AttendancePolicyFormPage));
      bloc = c.read<AttendancePolicyFormBloc>();
      bloc.add(
        RecordDraftChanged<AttendancePolicyDraft>(
          (d) => d.copyWith(name: 'Edited record'),
        ),
      );
      await settleDb(t);
      await h.tapVisible(t, find.widgetWithText(AppPrimaryButton, c.l10n.save));
      await settleDb(t);
      expect(find.text('Edited record'), findsOneWidget);
      c = t.element(find.byType(AttendancePolicyDetailsPage));
      await h.tapVisible(
        t,
        find.widgetWithText(AppSecondaryButton, c.l10n.cfgDeactivate),
      );
      await h.pump(t);
      expect(find.byType(AppDialog), findsOneWidget);
      await t.tap(find.widgetWithText(AppPrimaryButton, c.l10n.cfgDeactivate));
      await settleDb(t);
      expect(
        t
            .element(find.byType(AttendancePolicyDetailsPage))
            .read<AttendancePolicyDetailsBloc>()
            .state
            .detail!
            .record
            .status,
        ConfigurationStatus.inactive,
      );
      expect(t.takeException(), isNull);
      await h.unmount(t, app);
    },
  );
  testWidgets('configuration dirty guard retains or discards edits', (t) async {
    h.viewport(t, 390);
    final app = await h.mount(t, AppLanguage.arabic);
    app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await h.pump(t);
    h.router(t).go(AppRoutes.shiftsNew);
    await settleDb(t);
    final c = t.element(find.byType(ShiftFormPage));
    await t.enterText(
      find.descendant(
        of: find.widgetWithText(AppTextField, c.l10n.cfgName),
        matching: find.byType(TextFormField),
      ),
      'Draft',
    );
    await h.pump(t);
    h.router(t).go(AppRoutes.shifts);
    await h.pump(t);
    expect(find.byType(AppDialog), findsOneWidget);
    await t.tap(find.widgetWithText(AppTextButton, c.l10n.cfgKeepEditing));
    await h.pump(t);
    expect(find.byType(ShiftFormPage), findsOneWidget);
    h.router(t).go(AppRoutes.shifts);
    await h.pump(t);
    await t.tap(find.widgetWithText(AppPrimaryButton, c.l10n.cfgDiscardAction));
    await settleDb(t);
    expect(find.byType(ShiftListPage), findsOneWidget);
    expect(t.takeException(), isNull);
    await h.unmount(t, app);
  });
  testWidgets('configuration direct routes deny employees and managers', (
    t,
  ) async {
    final app = await h.mount(t, AppLanguage.english);
    app.auth.add(const AuthLoginRequested('employee@erp.demo', 'Employee@123'));
    await h.pump(t);
    for (final path in [
      AppRoutes.shifts,
      AppRoutes.shiftsNew,
      AppRoutes.workLocationsDetails('location-hyderabad'),
      AppRoutes.attendancePoliciesEdit('policy-office'),
    ]) {
      h.router(t).go(path);
      await settleDb(t);
      expect(find.byType(UnauthorizedPage), findsOneWidget);
    }
    expect(t.takeException(), isNull);
    await h.unmount(t, app);
  });
  testWidgets('Arabic configuration forms support enlarged text and keyboard', (
    t,
  ) async {
    h.viewport(t, 360);
    t.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    t.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(t.view.resetViewInsets);
    final app = await h.mount(t, AppLanguage.arabic);
    app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await h.pump(t);
    for (final path in [
      AppRoutes.shiftsNew,
      AppRoutes.workLocationsNew,
      AppRoutes.attendancePoliciesNew,
    ]) {
      h.router(t).go(path);
      await settleDb(t);
      expect(t.takeException(), isNull);
    }
    await h.unmount(t, app);
  });
  testWidgets('real shift controls save a weekday and two picked times', (
    t,
  ) async {
    h.viewport(t, 390);
    final app = await h.mount(t, AppLanguage.english);
    app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await h.pump(t);
    h.router(t).go(AppRoutes.shiftsNew);
    await settleDb(t);
    final c = t.element(find.byType(ShiftFormPage)), l = c.l10n;
    await t.enterText(
      find.descendant(
        of: find.widgetWithText(AppTextField, l.cfgName),
        matching: find.byType(TextFormField),
      ),
      'Interactive shift',
    );
    await h.pump(t);
    for (final entry in [
      (label: l.cfgStart, hour: '3'),
      (label: l.cfgEnd, hour: '4'),
    ]) {
      await h.tapVisible(t, find.widgetWithText(AppTimeField, entry.label));
      await h.pump(t);
      await t.tap(find.byIcon(Icons.keyboard_outlined));
      await h.pump(t);
      final fields = find.descendant(
        of: find.byType(TimePickerDialog),
        matching: find.byType(TextFormField),
      );
      await t.enterText(fields.at(0), entry.hour);
      await t.enterText(fields.at(1), '00');
      await t.tap(find.text(l.confirm).last);
      await h.pump(t);
    }
    await h.tapVisible(t, find.widgetWithText(FilterChip, l.cfgFri));
    await h.pump(t);
    await h.tapVisible(t, find.widgetWithText(AppPrimaryButton, l.save));
    await settleDb(t);
    expect(find.byType(ShiftDetailsPage), findsOneWidget);
    final record = t
        .element(find.byType(ShiftDetailsPage))
        .read<ShiftDetailsBloc>()
        .state
        .detail!
        .record;
    expect(record.name, 'Interactive shift');
    expect(record.workingDays, {WorkingDay.friday});
    expect(record.durationMinutes, 60);
    expect(t.takeException(), isNull);
    await h.unmount(t, app);
  });
  testWidgets('policy toggles normalize dependent rules in the real form', (
    t,
  ) async {
    h.viewport(t, 390);
    final app = await h.mount(t, AppLanguage.arabic);
    app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await h.pump(t);
    h.router(t).go(AppRoutes.attendancePoliciesEdit('policy-office'));
    await settleDb(t);
    final c = t.element(find.byType(AttendancePolicyFormPage)),
        bloc = c.read<AttendancePolicyFormBloc>();
    await h.tapVisible(
      t,
      find.widgetWithText(AppSwitchField, c.l10n.cfgRequireLocation),
    );
    await h.pump(t);
    expect(bloc.state.draft.requireLocation, false);
    expect(bloc.state.draft.maximumAcceptedAccuracyMeters, null);
    expect(bloc.state.draft.requireLocationOnBreak, false);
    expect(
      find.widgetWithText(AppSwitchField, c.l10n.cfgLocationIn),
      findsNothing,
    );
    await h.tapVisible(
      t,
      find.widgetWithText(AppSwitchField, c.l10n.cfgTrackBreaks),
    );
    await h.pump(t);
    expect(bloc.state.draft.allowMultipleBreaks, false);
    expect(
      find.widgetWithText(AppSwitchField, c.l10n.cfgMultipleBreaks),
      findsNothing,
    );
    await h.tapVisible(t, find.widgetWithText(AppPrimaryButton, c.l10n.save));
    await settleDb(t);
    expect(find.byType(AttendancePolicyDetailsPage), findsOneWidget);
    expect(t.takeException(), isNull);
    await h.unmount(t, app);
  });
  testWidgets(
    'list search/status controls show filtered empty and retain query',
    (t) async {
      h.viewport(t, 1440);
      final app = await h.mount(t, AppLanguage.english);
      app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await h.pump(t);
      h.router(t).go(AppRoutes.shifts);
      await settleDb(t);
      final c = t.element(find.byType(ShiftListPage));
      await t.enterText(
        find.descendant(
          of: find.widgetWithText(AppTextField, c.l10n.search),
          matching: find.byType(TextFormField),
        ),
        'night',
      );
      await settleDb(t);
      expect(c.read<ShiftListBloc>().state.data!.filtered, 1);
      await t.tap(find.widgetWithText(AppFilterChip, c.l10n.cfgInactive));
      await settleDb(t);
      expect(find.text(c.l10n.cfgNoResults), findsOneWidget);
      expect(find.text(c.l10n.cfgEmpty), findsNothing);
      expect(t.takeException(), isNull);
      await h.unmount(t, app);
    },
  );
  testWidgets(
    'location helper requests permission only on tap and exposes settings',
    (t) async {
      h.viewport(t, 390);
      final service = MockLocationService();
      when(() => service.currentPosition(requestPermission: true)).thenAnswer(
        (_) async => const Failed(
          Failure(
            code: 'location_permanent',
            kind: FailureKind.locationPermission,
          ),
        ),
      );
      when(
        () => service.openSettings(locationSettings: false),
      ).thenAnswer((_) async => const Success(true));
      final app = await h.mount(
        t,
        AppLanguage.english,
        locationService: service,
      );
      app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await h.pump(t);
      h.router(t).go(AppRoutes.workLocationsNew);
      await settleDb(t);
      verifyNever(
        () => service.currentPosition(
          requestPermission: any(named: 'requestPermission'),
        ),
      );
      final c = t.element(find.byType(WorkLocationFormPage));
      await h.tapVisible(
        t,
        find.widgetWithText(AppSecondaryButton, c.l10n.cfgCurrentLocation),
      );
      await settleDb(t);
      expect(find.text(c.l10n.cfgLocationPermanent), findsOneWidget);
      await h.tapVisible(
        t,
        find.widgetWithText(AppTextButton, c.l10n.cfgOpenSettings),
      );
      await settleDb(t);
      verify(() => service.openSettings(locationSettings: false)).called(1);
      expect(t.takeException(), isNull);
      await h.unmount(t, app);
    },
  );
  testWidgets(
    'location capture refreshes numeric inputs even with unchanged accuracy',
    (t) async {
      h.viewport(t, 390);
      final service = MockLocationService();
      var count = 0;
      when(() => service.currentPosition(requestPermission: true)).thenAnswer(
        (_) async => Success(
          Position(
            latitude: 17.5 + (count++),
            longitude: 78.5,
            timestamp: DateTime.now(),
            accuracy: 120,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          ),
        ),
      );
      final app = await h.mount(
        t,
        AppLanguage.english,
        locationService: service,
      );
      app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await h.pump(t);
      h.router(t).go(AppRoutes.workLocationsNew);
      await settleDb(t);
      final c = t.element(find.byType(WorkLocationFormPage));
      for (var n = 0; n < 2; n++) {
        await h.tapVisible(
          t,
          find.widgetWithText(AppSecondaryButton, c.l10n.cfgCurrentLocation),
        );
        await settleDb(t);
        expect(
          t
              .widgetList<TextFormField>(find.byType(TextFormField))
              .any((f) => f.initialValue == (17.5 + n).toString()),
          true,
        );
      }
      expect(find.text(c.l10n.cfgPoorAccuracy), findsOneWidget);
      expect(t.takeException(), isNull);
      await h.unmount(t, app);
    },
  );
  for (final manageOnly in [false, true]) {
    testWidgets(
      '${manageOnly ? 'manage' : 'view'} only configuration grants protect direct routes',
      (t) async {
        registerFallbackValue(AuthIdentifier.parse('hr@erp.demo')!);
        final mock = h.MockAuth();
        final ctx = employeeContext(AppRole.hr).copyWith(
          user: employeeContext(AppRole.hr).user.copyWith(
            permissions: PermissionSet([
              manageOnly ? AppPermission.shiftManage : AppPermission.shiftView,
            ]),
          ),
        );
        when(() => mock.sessionChanges).thenAnswer((_) => const Stream.empty());
        when(
          () => mock.restoreSession(),
        ).thenAnswer((_) async => const Success(null));
        when(
          () => mock.login(any(), any()),
        ).thenAnswer((_) async => Success(ctx));
        when(() => mock.dispose()).thenAnswer((_) async {});
        final app = await h.mount(t, AppLanguage.english, repository: mock);
        app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
        await h.pump(t);
        h.router(t).go(manageOnly ? AppRoutes.shiftsNew : AppRoutes.shifts);
        await settleDb(t);
        if (manageOnly) {
          expect(find.byType(ShiftFormPage), findsOneWidget);
          final bloc = t
              .element(find.byType(ShiftFormPage))
              .read<ShiftFormBloc>();
          bloc.add(RecordDraftChanged<ShiftDraft>((_) => shiftDraft()));
          await settleDb(t);
          await h.tapVisible(
            t,
            find.widgetWithText(
              AppPrimaryButton,
              t.element(find.byType(ShiftFormPage)).l10n.save,
            ),
          );
          await settleDb(t);
          expect(
            h.router(t).routeInformationProvider.value.uri.path,
            AppRoutes.dashboard,
          );
        } else {
          expect(find.byType(ShiftListPage), findsOneWidget);
          expect(
            find.widgetWithText(
              AppPrimaryButton,
              t.element(find.byType(ShiftListPage)).l10n.cfgNew,
            ),
            findsNothing,
          );
          h.router(t).go(AppRoutes.shiftsNew);
          await settleDb(t);
          expect(find.byType(UnauthorizedPage), findsOneWidget);
        }
        expect(t.takeException(), isNull);
        await h.unmount(t, app);
      },
    );
  }
  testWidgets(
    'unknown configuration details and edits distinguish missing records',
    (t) async {
      final app = await h.mount(t, AppLanguage.english);
      app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await h.pump(t);
      h.router(t).go(AppRoutes.shiftsDetails('missing'));
      await settleDb(t);
      expect(
        find.text(t.element(find.byType(ShiftDetailsPage)).l10n.cfgNotFound),
        findsOneWidget,
      );
      h.router(t).go(AppRoutes.workLocationsEdit('missing'));
      await settleDb(t);
      expect(
        t
            .element(find.byType(WorkLocationFormPage))
            .read<WorkLocationFormBloc>()
            .state
            .ready,
        false,
      );
      expect(find.byType(AppPrimaryButton), findsNothing);
      expect(t.takeException(), isNull);
      await h.unmount(t, app);
    },
  );
  testWidgets(
    'employee selectors save actual configurations and retain inactive assignments',
    (t) async {
      h.viewport(t, 390);
      final app = await h.mount(t, AppLanguage.arabic);
      app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await h.pump(t);
      final router = h.router(t);
      router.go(AppRoutes.employeeEdit('employee-employee'));
      await settleDb(t);
      var c = t.element(find.byType(EmployeeFormPage));
      final l = c.l10n;
      for (final choice in [
        (label: l.dashboardShift, name: 'Night Shift'),
        (label: l.dashboardLocation, name: 'Hyderabad HQ'),
        (label: l.empPolicy, name: 'Office Staff Policy'),
      ]) {
        await h.tapVisible(
          t,
          find.widgetWithText(AppSelectField<String>, choice.label),
        );
        await h.pump(t);
        await t.enterText(
          find.descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(TextFormField),
          ),
          choice.name,
        );
        await h.pump(t);
        await t.tap(find.text(choice.name).last);
        await h.pump(t);
      }
      var form = c.read<EmployeeFormBloc>();
      expect(form.state.draft.shiftId, 'shift-night');
      expect(form.state.draft.workLocationId, 'location-hyderabad');
      expect(form.state.draft.attendancePolicyId, 'policy-office');
      await h.tapVisible(
        t,
        find.widgetWithText(AppPrimaryButton, l.empSave).last,
      );
      await settleDb(t);
      expect(find.byType(EmployeeDetailsPage), findsOneWidget);
      var detail = t
          .element(find.byType(EmployeeDetailsPage))
          .read<EmployeeDetailsBloc>();
      expect(detail.state.employee!.shiftId, 'shift-night');
      expect(find.text('Night Shift'), findsOneWidget);
      await t.runAsync(() async {
        unwrap(
          await LocalShiftRepository(
            app.database!,
          ).setActive(employeeContext(AppRole.hr), 'shift-night', false),
        );
      });
      await settleDb(t);
      router.go(AppRoutes.employeeEdit('employee-employee'));
      await settleDb(t);
      c = t.element(find.byType(EmployeeFormPage));
      form = c.read<EmployeeFormBloc>();
      expect(
        form.state.references!.shifts
            .firstWhere((s) => s.id == 'shift-night')
            .status,
        ConfigurationStatus.inactive,
      );
      await h.tapVisible(
        t,
        find.widgetWithText(AppSelectField<String>, l.dashboardShift),
      );
      await h.pump(t);
      expect(
        t
            .widget<ListTile>(find.widgetWithText(ListTile, 'Night Shift'))
            .enabled,
        false,
      );
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await h.pump(t);
      await t.enterText(
        find.descendant(
          of: find.widgetWithText(AppTextField, l.empFirst),
          matching: find.byType(TextFormField),
        ),
        'Noor updated',
      );
      await h.pump(t);
      await h.tapVisible(
        t,
        find.widgetWithText(AppPrimaryButton, l.empSave).last,
      );
      await settleDb(t);
      detail = t
          .element(find.byType(EmployeeDetailsPage))
          .read<EmployeeDetailsBloc>();
      expect(detail.state.employee!.shiftId, 'shift-night');
      expect(t.takeException(), isNull);
      await h.unmount(t, app);
    },
  );
  testWidgets(
    'form status deactivation requires a retained-assignment confirmation',
    (t) async {
      h.viewport(t, 390);
      final app = await h.mount(t, AppLanguage.english);
      app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await h.pump(t);
      h.router(t).go(AppRoutes.shiftsEdit('shift-night'));
      await settleDb(t);
      final c = t.element(find.byType(ShiftFormPage));
      await h.tapVisible(
        t,
        find.widgetWithText(AppSwitchField, c.l10n.cfgActive),
      );
      await h.pump(t);
      await h.tapVisible(t, find.widgetWithText(AppPrimaryButton, c.l10n.save));
      expect(find.byType(AppDialog), findsOneWidget);
      expect(find.textContaining(c.l10n.cfgDeactivateMessage), findsOneWidget);
      await t.tap(find.widgetWithText(AppTextButton, c.l10n.cancel));
      await h.pump(t);
      expect(find.byType(ShiftFormPage), findsOneWidget);
      await h.tapVisible(t, find.widgetWithText(AppPrimaryButton, c.l10n.save));
      await t.tap(find.widgetWithText(AppPrimaryButton, c.l10n.cfgDeactivate));
      await settleDb(t);
      expect(
        t
            .element(find.byType(ShiftDetailsPage))
            .read<ShiftDetailsBloc>()
            .state
            .detail!
            .record
            .status,
        ConfigurationStatus.inactive,
      );
      expect(t.takeException(), isNull);
      await h.unmount(t, app);
    },
  );
}
