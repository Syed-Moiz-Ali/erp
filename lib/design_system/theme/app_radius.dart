/// Centralized corner radius scale for Bitlogix ERP.
///
/// Follows 2026 enterprise SaaS standards with disciplined, compact corner radii
/// that provide modern tactile softness while preserving dense information hierarchy.
abstract final class AppRadius {
  static const double radiusXs = 4;
  static const double radiusSm = 6;
  static const double radiusMd = 8;
  static const double radiusLg = 10;
  static const double radiusXl = 12;
  static const double radius2Xl = 16;
  static const double frame = 16;
  static const double field = 8;
  static const double radiusFull = 9999;

  // Semantic component aliases
  static const double badge = radiusSm;
  static const double button = radiusMd;
  static const double input = radiusMd;
  static const double chip = radiusMd;
  static const double small = radiusSm;
  static const double control = radiusMd;
  static const double card = radiusMd;
  static const double cardLg = radiusXl;
  static const double panel = radiusXl;
  static const double dialog = radiusXl;
  static const double bottomSheet = radiusXl;
}
