import 'package:flutter/material.dart';

/// Centralized color palette and semantic tokens for Bitlogix ERP.
///
/// Follows 2026 enterprise SaaS standards with a deep plum/burgundy identity,
/// warm neutral workspace canvas, crisp white surfaces, and high-clarity borders.
abstract final class AppColors {
  // Brand (Deep Plum / Burgundy enterprise identity)
  static const brandPrimary = Color(0xFF4E1736);
  static const brandSecondary = Color(0xFF6B234C);
  static const brandDark = Color(0xFF2C0A17);
  static const brandSubtle = Color(0xFFF7EFF5);
  static const brandSoft = Color(0xFFF9F0F4);
  static const brandHover = Color(0xFF5C1D41);
  static const brandPressed = Color(0xFF3B0F28);
  static const brandBorder = Color(0xFF7E395F);
  static const accentLavender = Color(0xFF8B5CF6);

  // Surfaces (Soft neutral canvas + crisp white workspace)
  static const background = Color(0xFFF5F4F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSubtle = Color(0xFFF9F8FB);
  static const surfaceRaised = Color(0xFFFFFFFF);
  static const surfaceHover = Color(0xFFF3F1F7);
  static const surfaceSelected = Color(0xFFF5EFF5);
  static const surfacePrimary = Color(0xFFFFFFFF);
  static const surfaceSecondary = Color(0xFFF9F8FB);
  static const surfaceMuted = Color(0xFFF3F1F7);
  static const surfaceDisabled = Color(0xFFECE9EF);

  // Authentication environment (soft neutral canvas + composed application stage)
  static const canvas = Color(0xFFE9E8EC);
  static const frameBody = Color(0xFFF4F3F7);
  static const surfaceTint = Color(0xFFF7F3F6);
  static const appSurface = Color(0xFFFCFBFC);
  static const authSurface = Color(0xFFFCFBFD);
  static const productTint = Color(0xFFF4EFF6);
  static const productTintAlt = Color(0xFFEAE3F1);
  static const inputBackground = Color(0xFFF6F6F8);
  static const inputHover = Color(0xFFFBFBFD);
  static const inputBorder = Color(0xFFE1DEE7);
  static const inputBorderHover = Color(0xFFD3CEDC);

  // Mobile / tablet continuous canvas (extremely low-contrast tonal blend)
  static const mobileCanvasTop = Color(0xFFEEECF2);
  static const mobileCanvasBottom = Color(0xFFF6F5F7);

  // Borders (Disciplined cool/lavender-gray with clear container definition)
  static const borderSubtle = Color(0xFFE5E1EA);
  static const borderDefault = Color(0xFFD0CBD6);
  static const borderStrong = Color(0xFFA59EAE);
  static const borderInteractive = Color(0xFF8C8496);
  static const borderFocus = brandPrimary;
  static const borderSelected = brandPrimary;
  static const borderError = danger;
  static const borderSuccess = success;
  static const borderWarning = warning;

  // Text (Deep ink & muted charcoal)
  static const textPrimary = Color(0xFF14111E);
  static const textSecondary = Color(0xFF544F5E);
  static const textMuted = Color(0xFF7C7688);
  static const textDisabled = Color(0xFFB3ADBC);

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
