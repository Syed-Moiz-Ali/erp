import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand (Deep Plum / Burgundy enterprise identity)
  static const brandPrimary = Color(0xFF4E1736);
  static const brandSecondary = Color(0xFF6B234C);
  static const brandSubtle = Color(0xFFF7EFF5);
  static const brandHover = Color(0xFF5C1D41);
  static const brandPressed = Color(0xFF3B0F28);
  static const accentLavender = Color(0xFF8B5CF6);

  // Surfaces (Soft neutral canvas + crisp white workspace)
  static const background = Color(0xFFF5F4F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSubtle = Color(0xFFF9F8FB);
  static const surfaceRaised = Color(0xFFFFFFFF);
  static const surfaceHover = Color(0xFFF3F1F7);
  static const surfaceSelected = Color(0xFFF5EFF5);

  // Borders (Ultra-subtle cool/lavender-gray)
  static const borderSubtle = Color(0xFFEFECE5);
  static const borderDefault = Color(0xFFE4E1E8);
  static const borderStrong = Color(0xFFB5AFBF);

  // Text (Deep ink & muted charcoal)
  static const textPrimary = Color(0xFF14111E);
  static const textSecondary = Color(0xFF5E5868);
  static const textMuted = Color(0xFF918B9C);
  static const textDisabled = Color(0xFFBDB7C6);

  // Status & Feedback
  static const success = Color(0xFF0D7A53);
  static const successSubtle = Color(0xFFEBF7F2);
  static const warning = Color(0xFF975B00);
  static const warningSubtle = Color(0xFFFFF8EB);
  static const danger = Color(0xFFC5283D);
  static const dangerSubtle = Color(0xFFFDF0F2);
  static const info = Color(0xFF4E1736);
  static const infoSubtle = Color(0xFFF7EFF5);
  static const neutral = Color(0xFF5E5868);
  static const neutralSubtle = Color(0xFFF5F4F7);

  // Focus & Accessibility
  static const focusRing = Color(0xFF4E1736);

  // Backward-compatible aliases for existing codebase
  static const brand = brandPrimary;
  static const border = borderDefault;
}
