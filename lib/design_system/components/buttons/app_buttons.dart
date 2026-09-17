import 'package:flutter/material.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: loading ? null : onPressed,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (loading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (icon != null)
          Icon(icon, size: 18),
        if (loading || icon != null) const SizedBox(width: 8),
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    ),
  );
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({super.key, required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) =>
      OutlinedButton(onPressed: onPressed, child: Text(label));
}

class AppTextButton extends StatelessWidget {
  const AppTextButton({super.key, required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) =>
      TextButton(onPressed: onPressed, child: Text(label));
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: Icon(icon, size: 20),
  );
}
