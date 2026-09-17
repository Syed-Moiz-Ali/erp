import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, required this.name, this.radius = 18});
  final String name;
  final double radius;
  @override
  Widget build(BuildContext context) => Semantics(
    label: name,
    child: CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.brand.withValues(alpha: .1),
      foregroundColor: AppColors.brand,
      child: Text(
        name
            .trim()
            .split(RegExp(r'\s+'))
            .where((s) => s.isNotEmpty)
            .take(2)
            .map((s) => s.characters.first)
            .join()
            .toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
