import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry_repository.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

/// Read-only "recent enquiries" section for the Customer/Site detail screens.
///
/// Renders nothing unless the viewer has `services.enquiries.view`, so the host
/// screen never depends on Enquiry permission for its basic rendering. The
/// enquiry read model resolves only the labels needed for authorized enquiries.
class ServiceRecentEnquiriesSection extends StatelessWidget {
  const ServiceRecentEnquiriesSection({
    super.key,
    required this.repository,
    required this.title,
    required this.emptyText,
    this.customerId,
    this.siteId,
  });
  final ServiceEnquiryRepository repository;
  final String title, emptyText;
  final String? customerId, siteId;

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    if (permissions?.contains(AppPermission.serviceEnquiryView) != true) {
      return const SizedBox.shrink();
    }
    final account = context.read<AuthBloc>().state.context;
    if (account == null) return const SizedBox.shrink();
    return _Body(
      repository: repository,
      account: account,
      title: title,
      emptyText: emptyText,
      customerId: customerId,
      siteId: siteId,
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.repository,
    required this.account,
    required this.title,
    required this.emptyText,
    this.customerId,
    this.siteId,
  });
  final ServiceEnquiryRepository repository;
  final AuthContext account;
  final String title, emptyText;
  final String? customerId, siteId;

  @override
  Widget build(BuildContext context) {
    final stream = customerId != null
        ? repository.watchEnquiriesForCustomer(account, customerId!, limit: 5)
        : repository.watchEnquiriesForSite(account, siteId!, limit: 5);
    return StreamBuilder<Result<List<ServiceEnquiryListItem>>>(
      stream: stream,
      builder: (context, snapshot) {
        final l = context.l10n;
        final items = switch (snapshot.data) {
          Success<List<ServiceEnquiryListItem>>(:final value) => value,
          _ => const <ServiceEnquiryListItem>[],
        };
        return AppSettingsSection(
          title: title,
          children: [
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(emptyText),
              )
            else
              for (final item in items)
                AppSettingsRow(
                  title: item.enquiryNumber,
                  description: [
                    item.serviceTypeName,
                    item.complaintTypeName,
                  ].where((s) => s.isNotEmpty).join(' · '),
                  icon: Icons.support_agent_outlined,
                  trailing: serviceEnquiryStatusLabel(item.status, l),
                  onPressed: () => context.go(ServicesRoutes.enquiry(item.id)),
                ),
          ],
        );
      },
    );
  }
}
