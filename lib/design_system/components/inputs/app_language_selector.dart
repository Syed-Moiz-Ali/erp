import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../l10n/l10n.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_colors.dart';

/// Reusable in the preview, login, profile and settings. No storage logic here.
class AppLanguageSelector extends StatelessWidget {
  const AppLanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) => PopupMenuButton<AppLanguage>(
        tooltip: context.l10n.language,
        initialValue: state.language,
        onSelected: (language) =>
            unawaited(context.read<LocaleCubit>().changeLanguage(language)),
        itemBuilder: (context) => context
            .read<LocaleCubit>()
            .supportedLanguages
            .map(
              (language) => CheckedPopupMenuItem(
                value: language,
                checked: language == state.language,
                child: Semantics(
                  label: language.displayName(context.l10n),
                  child: Text(language.nativeName(context.l10n)),
                ),
              ),
            )
            .toList(),
        child: Semantics(
          button: true,
          label: context.l10n.language,
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0x14FFFFFF) : AppColors.surface,
              border: Border.all(
                color: isDark ? const Color(0x26FFFFFF) : AppColors.border,
              ),
              borderRadius: BorderRadius.circular(AppRadius.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language_outlined,
                  size: 16,
                  color: isDark
                      ? const Color(0xFF38BDF8)
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    state.language.nativeName(context.l10n),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.expand_more,
                  size: 16,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
