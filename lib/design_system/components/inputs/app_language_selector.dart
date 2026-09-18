import '../../theme/app_typography.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../l10n/l10n.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';

/// Reusable in the preview, login, profile and settings. No storage logic here.
///
/// The [compact] variant is a restrained utility control intended for an
/// application header: no idle outline, subtle hover surface.
class AppLanguageSelector extends StatefulWidget {
  const AppLanguageSelector({super.key, this.compact = false});
  final bool compact;

  @override
  State<AppLanguageSelector> createState() => _AppLanguageSelectorState();
}

class _AppLanguageSelectorState extends State<AppLanguageSelector> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) => PopupMenuButton<AppLanguage>(
        tooltip: context.l10n.language,
        initialValue: state.language,
        position: PopupMenuPosition.under,
        offset: const Offset(0, AppSpacing.xs),
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        constraints: const BoxConstraints(minWidth: 200, maxWidth: 240),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusLg),
          side: const BorderSide(color: AppColors.borderDefault),
        ),
        onSelected: (language) =>
            unawaited(context.read<LocaleCubit>().changeLanguage(language)),
        itemBuilder: (context) {
          final theme = AppTypography.of(context);
          return context
              .read<LocaleCubit>()
              .supportedLanguages
              .map(
                (language) => PopupMenuItem<AppLanguage>(
                  value: language,
                  height: 44,
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          label: language.displayName(context.l10n),
                          child: Text(
                            language.nativeName(context.l10n),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.bodySmall.copyWith(
                              fontWeight: language == state.language
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      if (language == state.language)
                        const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: AppColors.brandPrimary,
                        ),
                    ],
                  ),
                ),
              )
              .toList();
        },
        child: Semantics(
          button: true,
          label: context.l10n.language,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: AppMotion.fast,
              curve: AppMotion.curveStandard,
              constraints: BoxConstraints(minHeight: widget.compact ? 36 : 40),
              padding: EdgeInsets.symmetric(
                horizontal: widget.compact ? AppSpacing.sm : AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: widget.compact
                    ? (_hovered
                          ? (isDark
                                ? const Color(0x1FFFFFFF)
                                : AppColors.surfaceHover)
                          : Colors.transparent)
                    : (isDark ? const Color(0x14FFFFFF) : AppColors.surface),
                border: widget.compact
                    ? null
                    : Border.all(
                        color: isDark
                            ? const Color(0x26FFFFFF)
                            : AppColors.border,
                      ),
                borderRadius: BorderRadius.circular(
                  widget.compact ? AppRadius.radiusSm : AppRadius.radiusFull,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.language_outlined,
                    size: widget.compact ? 15 : 16,
                    color: isDark
                        ? const Color(0xFF38BDF8)
                        : AppColors.textSecondary,
                  ),
                  SizedBox(
                    width: widget.compact ? AppSpacing.xs + 2 : AppSpacing.sm,
                  ),
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
                    size: widget.compact ? 15 : 16,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
