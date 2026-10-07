/// One 4px-derived spacing scale for the whole product. Keys are semantic and
/// deliberately limited; do not introduce one-off values (13, 17, 27…) unless
/// a component genuinely needs optical adjustment.
abstract final class AppSpacing {
  static const double none = 0,
      xxs = 2,
      xs = 4,
      sm = 8,
      md = 12,
      lg = 16,
      xl = 20,
      xxl = 24,
      section = 32,
      wide = 40,
      page = 48;
}
