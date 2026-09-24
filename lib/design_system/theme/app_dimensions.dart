abstract final class AppDimensions {
  /// The single global ERP page content width. Every feature page is centered
  /// inside the main workspace at this width (see `AppPage`).
  static const double contentMaxWidth = 1200.0;

  static const sidebar = 248.0,
      sidebarLarge = 272.0,
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

  // Centralized icon scale.
  static const double iconXs = 12, iconSm = 16, iconMd = 20, iconLg = 22;

  // Centralized control (tap target) scale; never below 40 for icon actions.
  static const double controlSm = 32, controlMd = 40, controlLg = 44;

  // Dense data row / header heights for enterprise tables.
  static const double tableRowHeight = 50, tableHeaderHeight = 44;
}
