import 'app_spacing.dart';

abstract final class AppDimensions {
  /// The single global ERP page content width. Every feature page is centered
  /// inside the main workspace at this width (see `AppPage`).
  static const double contentMaxWidth = 1200.0;

  /// One deliberate expanded desktop sidebar width for the whole product.
  /// Both named desktop steps share the same value: the shell never scales the
  /// rail, it scales the workspace. Kept inside the 240–280 enterprise band so
  /// normal ERP labels never truncate but the content area stays dominant.
  static const sidebar = 264.0,
      sidebarLarge = 264.0,
      sidebarCollapsed = 80.0,
      rail = 84.0,
      topBar = 64.0,
      navigationTarget = 42.0,
      content = 1200.0,
      dashboard = 1440.0,
      wideContent = 1600.0,
      details = 820.0,
      formContent = 1040.0,
      form = 560.0,
      dialog = 480.0,
      detailField = 240.0,
      compactDetailField = 130.0;

  // Centralized icon scale. One family, one stroke weight, four sizes.
  static const double iconXs = 12, iconSm = 16, iconMd = 20, iconLg = 22;

  /// Semantic icon aliases used by controls and headers.
  static const double iconInline = iconSm,
      iconControl = iconMd,
      iconLeading = iconMd,
      iconHeader = iconLg;

  // Centralized control (tap target) scale; never below 40 for icon actions.
  static const double controlSm = 32, controlMd = 40, controlLg = 44;

  /// One standard input/control height, with a single compact variant.
  static const double inputHeight = 42, inputHeightCompact = 34;

  /// Standard control heights shared by all buttons.
  static const double buttonHeightSm = controlSm,
      buttonHeightMd = controlMd,
      buttonHeightLg = 48;

  // Dense data row / header heights for enterprise tables.
  static const double tableRowHeight = 50, tableHeaderHeight = 44;

  /// Standard horizontal cell padding for the shared table foundation.
  static const double tableCellPaddingH = AppSpacing.lg;

  /// Standard gap between a label and its control.
  static const double labelGap = 8;

  /// Standard gap between stacked form rows.
  static const double formRowGap = 20;
}
