import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

enum AppButtonSize { small, medium, large }

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.size = AppButtonSize.medium,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final AppButtonSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final (height, padding, iconSize, textStyle) = _buttonSizeProps(
      context,
      size,
    );
    final isEnabled = onPressed != null && !loading;
    final borderRadius = BorderRadius.circular(AppRadius.control);
    final button = Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: isEnabled
            ? AppColors.brandPrimary
            : AppColors.brandPrimary.withValues(alpha: .5),
        boxShadow: isEnabled
            ? const [
                BoxShadow(
                  color: Color(0x0F14111E),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.white.withValues(alpha: .7),
          minimumSize: Size(fullWidth ? double.infinity : 0, height),
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: _ButtonContent(
          label: label,
          icon: icon,
          loading: loading,
          iconSize: iconSize,
          textStyle: textStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          loadingColor: Colors.white,
        ),
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.size = AppButtonSize.medium,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final AppButtonSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final (height, padding, iconSize, textStyle) = _buttonSizeProps(
      context,
      size,
    );
    final button = OutlinedButton(
      onPressed: loading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        disabledForegroundColor: AppColors.textDisabled,
        minimumSize: Size(fullWidth ? double.infinity : 0, height),
        padding: padding,
        side: const BorderSide(color: AppColors.borderDefault),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
      child: _ButtonContent(
        label: label,
        icon: icon,
        loading: loading,
        iconSize: iconSize,
        textStyle: textStyle.copyWith(
          color: onPressed != null
              ? AppColors.textPrimary
              : AppColors.textDisabled,
        ),
        loadingColor: AppColors.textSecondary,
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class AppDestructiveButton extends StatelessWidget {
  const AppDestructiveButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.size = AppButtonSize.medium,
    this.fullWidth = false,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final AppButtonSize size;
  final bool fullWidth;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final (height, padding, iconSize, textStyle) = _buttonSizeProps(
      context,
      size,
    );
    final button = outlined
        ? OutlinedButton(
            onPressed: loading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.danger,
              disabledForegroundColor: AppColors.textDisabled,
              minimumSize: Size(fullWidth ? double.infinity : 0, height),
              padding: padding,
              side: const BorderSide(color: AppColors.danger),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
            ),
            child: _ButtonContent(
              label: label,
              icon: icon,
              loading: loading,
              iconSize: iconSize,
              textStyle: textStyle.copyWith(color: AppColors.danger),
              loadingColor: AppColors.danger,
            ),
          )
        : FilledButton(
            onPressed: loading ? null : onPressed,
            style: FilledButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.danger.withValues(alpha: .5),
              disabledForegroundColor: Colors.white.withValues(alpha: .7),
              minimumSize: Size(fullWidth ? double.infinity : 0, height),
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
            ),
            child: _ButtonContent(
              label: label,
              icon: icon,
              loading: loading,
              iconSize: iconSize,
              textStyle: textStyle.copyWith(color: Colors.white),
              loadingColor: Colors.white,
            ),
          );
    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.size = AppButtonSize.medium,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final (height, padding, iconSize, textStyle) = _buttonSizeProps(
      context,
      size,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondary;
    final disabledColor = isDark
        ? const Color(0xFF475569)
        : AppColors.textDisabled;
    return TextButton(
      onPressed: loading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        disabledForegroundColor: disabledColor,
        minimumSize: Size(0, height),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
      child: _ButtonContent(
        label: label,
        icon: icon,
        loading: loading,
        iconSize: iconSize,
        textStyle: textStyle.copyWith(
          color: onPressed != null ? textColor : disabledColor,
        ),
        loadingColor: textColor,
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.size = AppButtonSize.medium,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final (targetSize, iconSize) = switch (size) {
      AppButtonSize.small => (32.0, 16.0),
      AppButtonSize.medium => (40.0, 20.0),
      AppButtonSize.large => (44.0, 22.0),
    };
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: Size(targetSize, targetSize),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
      icon: Icon(icon, size: iconSize),
    );
  }
}

(double, EdgeInsetsGeometry, double, TextStyle) _buttonSizeProps(
  BuildContext context,
  AppButtonSize size,
) {
  final typo = AppTypography.of(context);
  return switch (size) {
    AppButtonSize.small => (
      36.0,
      const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      16.0,
      typo.caption.copyWith(fontWeight: FontWeight.w600),
    ),
    AppButtonSize.medium => (
      46.0,
      const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      18.0,
      typo.label,
    ),
    AppButtonSize.large => (
      48.0,
      const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      20.0,
      typo.labelLarge,
    ),
  };
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.loading,
    required this.iconSize,
    required this.textStyle,
    required this.loadingColor,
  });

  final String label;
  final IconData? icon;
  final bool loading;
  final double iconSize;
  final TextStyle textStyle;
  final Color loadingColor;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (loading)
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
          ),
        )
      else if (icon != null)
        Icon(icon, size: iconSize),
      if (loading || icon != null) const SizedBox(width: AppSpacing.sm),
      Flexible(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: textStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
