import 'package:flutter/material.dart';

/// Centralized color palette and semantic tokens for Bitlogix ERP.
///
/// Follows 2026 enterprise SaaS standards with a deep plum/burgundy identity,
/// warm neutral workspace canvas, crisp white surfaces, and high-clarity borders.
abstract final class AppColors {
  // Brand (Deep Plum / Burgundy enterprise identity). The identity is
  // preserved; the semantic aliases below express *how* it is used so feature
  // code never reaches for a raw branded value.
  static const brandPrimary = Color(0xFF4E1736);
  static const brandSecondary = Color(0xFF6B234C);
  static const brandDark = Color(0xFF2C0A17);
  static const brandSubtle = Color(0xFFF7EFF5);
  static const brandSoft = Color(0xFFF9F0F4);
  static const brandHover = Color(0xFF5C1D41);
  static const brandPressed = Color(0xFF3B0F28);
  static const brandBorder = Color(0xFF7E395F);
  static const accentLavender = Color(0xFF8B5CF6);

  // Semantic brand aliases (preferred API for new code).
  static const brandPrimaryHover = brandHover;
  static const brandPrimaryPressed = brandPressed;
  static const brandPrimarySubtle = brandSubtle;
  static const brandPrimaryBorder = brandBorder;
  static const brandOnPrimary = Color(0xFFFFFFFF);

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

  // Semantic text hierarchy. `textTertiary` is the preferred name for the
  // prompt/placeholder/meta tier; `textMuted` remains as a compatibility alias.
  static const textTertiary = textMuted;
  static const textOnAccent = Color(0xFFFFFFFF);
  static const textOnBrand = Color(0xFFFFFFFF);
  static const textLink = brandPrimary;
  static const textDanger = danger;
  static const textSuccess = success;
  static const textWarning = warning;
  static const textInfo = info;

  // Status & Feedback (semantic; one source of truth for all module statuses)
  static const success = Color(0xFF0D7A53);
  static const successSubtle = Color(0xFFEBF7F2);
  static const warning = Color(0xFF975B00);
  static const warningSubtle = Color(0xFFFFF8EB);
  static const danger = Color(0xFFC5283D);
  static const dangerSubtle = Color(0xFFFDF0F2);
  static const info = Color(0xFF2A5A78);
  static const infoSubtle = Color(0xFFEEF5F8);
  static const neutral = Color(0xFF5E5868);
  static const neutralSubtle = Color(0xFFF5F4F7);

  // Dividers reuse the border palette to keep containers visually related.
  static const divider = borderSubtle;
  static const dividerStrong = borderDefault;

  // Focus & Accessibility
  static const focusRing = brandPrimary;
  static const focusHalo = Color(0x294E1736);
  static const hoverNeutral = surfaceHover;

  // Deliberate dark palette. Dark mode is authored, not an inversion of light:
  // surfaces step upward in luminance, borders stay visible, text keeps its
  // four-tier hierarchy.
  static const darkBackground = Color(0xFF100D12);
  static const darkSurfaceLow = Color(0xFF140F17);
  static const darkSurface = Color(0xFF1A151F);
  static const darkSurfaceRaised = Color(0xFF221C29);
  static const darkSurfaceMuted = Color(0xFF2A2332);
  static const darkSurfaceHover = Color(0xFF2E2736);
  static const darkSurfaceSelected = Color(0xFF3B2136);
  static const darkSurfaceDisabled = Color(0xFF241E2B);
  static const darkBorderSubtle = Color(0xFF2C2535);
  static const darkBorder = Color(0xFF3A3342);
  static const darkBorderStrong = Color(0xFF544A60);
  static const darkTextPrimary = Color(0xFFF2EFF5);
  static const darkTextSecondary = Color(0xFFB0A9BA);
  static const darkTextTertiary = Color(0xFF8A839A);
  static const darkTextDisabled = Color(0xFF615A6C);
  static const darkBrand = Color(0xFFE5A9CE);
  static const darkBrandOn = Color(0xFF3B0F28);
  static const darkSuccess = Color(0xFF45C08D);
  static const darkWarning = Color(0xFFE0A64B);
  static const darkDanger = Color(0xFFF0718A);
  static const darkInfo = Color(0xFF79B4D8);
  static const darkNeutral = Color(0xFF9A93A6);

  // Backward-compatible aliases for existing codebase
  static const brand = brandPrimary;
  static const border = borderDefault;
}
