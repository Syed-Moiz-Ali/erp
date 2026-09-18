import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';

class BootstrapPage extends StatelessWidget {
  const BootstrapPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: AppMotion.entrance(
            context,
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppProductIdentity(),
                const SizedBox(height: AppSpacing.xxl),
                AppLoadingState(label: context.l10n.authInitializing),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
