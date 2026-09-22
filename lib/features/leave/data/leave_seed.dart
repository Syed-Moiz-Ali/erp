import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../auth/domain/entities/auth_context.dart';

/// Demo-only leave configuration and starting balances so the Leave module is
/// immediately usable. Idempotent: entries are skipped when they already exist.
Future<void> seedLeaveConfiguration(AppDatabase db, AuthContext context) async {
  final now = DateTime.utc(2026);
  final year = DateTime.now().toUtc().year;
  final effectiveDate = '${year.toString().padLeft(4, '0')}-01-01';

  await db.transaction(() async {
    final types =
        <
          ({
            String id,
            String name,
            String code,
            String compensation,
            bool requiresReason,
            String description,
          })
        >[
          (
            id: 'leave-type-annual',
            name: 'Annual Leave',
            code: 'ANNUAL',
            compensation: 'paid',
            requiresReason: false,
            description: 'Paid annual vacation entitlement.',
          ),
          (
            id: 'leave-type-sick',
            name: 'Sick Leave',
            code: 'SICK',
            compensation: 'paid',
            requiresReason: true,
            description: 'Paid leave for illness and recovery.',
          ),
          (
            id: 'leave-type-casual',
            name: 'Casual Leave',
            code: 'CASUAL',
            compensation: 'paid',
            requiresReason: true,
            description: 'Short-notice personal leave.',
          ),
          (
            id: 'leave-type-unpaid',
            name: 'Unpaid Leave',
            code: 'UNPAID',
            compensation: 'unpaid',
            requiresReason: true,
            description: 'Leave without pay.',
          ),
        ];
    for (final type in types) {
      final existing = await (db.select(
        db.leaveTypes,
      )..where((t) => t.id.equals(type.id))).getSingleOrNull();
      if (existing != null) continue;
      await db
          .into(db.leaveTypes)
          .insert(
            LeaveTypesCompanion.insert(
              id: type.id,
              companyId: context.company.id,
              name: type.name,
              code: type.code,
              description: Value(type.description),
              compensation: Value(type.compensation),
              requiresReason: Value(type.requiresReason),
              createdMilliseconds: now.millisecondsSinceEpoch,
              updatedMilliseconds: now.millisecondsSinceEpoch,
            ),
          );
    }

    final policies =
        <
          ({
            String id,
            String name,
            String code,
            String typeId,
            double entitlement,
            bool negative,
          })
        >[
          (
            id: 'leave-policy-annual',
            name: 'Annual Leave Policy',
            code: 'ANNUAL-1',
            typeId: 'leave-type-annual',
            entitlement: 30,
            negative: false,
          ),
          (
            id: 'leave-policy-sick',
            name: 'Sick Leave Policy',
            code: 'SICK-1',
            typeId: 'leave-type-sick',
            entitlement: 15,
            negative: false,
          ),
          (
            id: 'leave-policy-casual',
            name: 'Casual Leave Policy',
            code: 'CASUAL-1',
            typeId: 'leave-type-casual',
            entitlement: 10,
            negative: false,
          ),
          (
            id: 'leave-policy-unpaid',
            name: 'Unpaid Leave Policy',
            code: 'UNPAID-1',
            typeId: 'leave-type-unpaid',
            entitlement: 0,
            negative: true,
          ),
        ];
    for (final policy in policies) {
      final existing = await (db.select(
        db.leavePolicies,
      )..where((t) => t.id.equals(policy.id))).getSingleOrNull();
      if (existing != null) continue;
      await db
          .into(db.leavePolicies)
          .insert(
            LeavePoliciesCompanion.insert(
              id: policy.id,
              companyId: context.company.id,
              name: policy.name,
              code: policy.code,
              leaveTypeId: policy.typeId,
              annualEntitlementDays: Value(policy.entitlement),
              allowNegativeBalance: Value(policy.negative),
              createdMilliseconds: now.millisecondsSinceEpoch,
              updatedMilliseconds: now.millisecondsSinceEpoch,
            ),
          );
    }

    final holidays = <({String id, String name, String date, String type})>[
      (
        id: 'holiday-new-year',
        name: 'New Year',
        date: '$year-01-01',
        type: 'publicHoliday',
      ),
      (
        id: 'holiday-labour-day',
        name: 'Labour Day',
        date: '$year-05-01',
        type: 'publicHoliday',
      ),
      (
        id: 'holiday-company-day',
        name: 'Company Day',
        date: '$year-12-25',
        type: 'companyHoliday',
      ),
    ];
    for (final holiday in holidays) {
      final existing = await (db.select(
        db.holidays,
      )..where((t) => t.id.equals(holiday.id))).getSingleOrNull();
      if (existing != null) continue;
      await db
          .into(db.holidays)
          .insert(
            HolidaysCompanion.insert(
              id: holiday.id,
              companyId: context.company.id,
              name: holiday.name,
              date: holiday.date,
              type: Value(holiday.type),
              createdMilliseconds: now.millisecondsSinceEpoch,
              updatedMilliseconds: now.millisecondsSinceEpoch,
            ),
          );
    }

    final alreadySeeded =
        await (db.select(db.leaveBalanceTransactions)..where(
              (t) =>
                  t.companyId.equals(context.company.id) &
                  t.leaveYear.equals(year) &
                  t.type.equals('entitlement'),
            ))
            .get();
    if (alreadySeeded.isNotEmpty) return;

    final employees =
        await (db.select(db.workforceEmployees)..where(
              (t) =>
                  t.companyId.equals(context.company.id) &
                  t.status.equals('active'),
            ))
            .get();
    const balances = {
      'leave-type-annual': 30.0,
      'leave-type-sick': 15.0,
      'leave-type-casual': 10.0,
    };
    for (final employee in employees) {
      for (final entry in balances.entries) {
        await db
            .into(db.leaveBalanceTransactions)
            .insert(
              LeaveBalanceTransactionsCompanion.insert(
                id: const Uuid().v4(),
                companyId: context.company.id,
                employeeId: employee.id,
                leaveTypeId: entry.key,
                leaveYear: year,
                type: 'entitlement',
                quantityDays: entry.value,
                reason: const Value('Initial demo entitlement'),
                createdBy: context.user.id,
                effectiveDate: effectiveDate,
                createdMilliseconds: now.millisecondsSinceEpoch,
                requestId: const Uuid().v4(),
                syncStatus: const Value('synced'),
              ),
            );
      }
    }
  });
}
