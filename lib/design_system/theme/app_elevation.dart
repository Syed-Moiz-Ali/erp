import 'package:flutter/material.dart';

/// Centralized elevation and shadow definitions for Bitlogix ERP.
///
/// Follows 2026 enterprise SaaS standards with restrained, low-opacity shadows
/// that give depth without muddying dark or light surfaces.
abstract final class AppElevation {
  static const double flat = 0;
  static const double raised = 1;
  static const double overlay = 4;

  // Semantic shadow levels
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> xs = [
    BoxShadow(color: Color(0x0614111E), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x0614111E), blurRadius: 12, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0614111E), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0314111E), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0614111E), blurRadius: 12, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0314111E), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> workspace = [
    BoxShadow(color: Color(0x0814111E), blurRadius: 36, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x0414111E), blurRadius: 8, offset: Offset(0, 2)),
  ];

  // Large, subtle shadow for framed desktop application stage
  static const List<BoxShadow> applicationFrame = [
    BoxShadow(color: Color(0x0A14111E), blurRadius: 52, offset: Offset(0, 22)),
    BoxShadow(color: Color(0x0514111E), blurRadius: 14, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> dropdown = [
    BoxShadow(color: Color(0x0A14111E), blurRadius: 16, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x0414111E), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> popover = dropdown;

  static const List<BoxShadow> dialog = [
    BoxShadow(color: Color(0x1214111E), blurRadius: 32, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x0614111E), blurRadius: 8, offset: Offset(0, 2)),
  ];
}
