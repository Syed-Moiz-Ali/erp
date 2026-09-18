import 'package:flutter/material.dart';

abstract final class AppElevation {
  static const double flat = 0, raised = 1, overlay = 4;

  // Subtle enterprise shadow tokens (Large blur, ultra-low opacity)
  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x0614111E), blurRadius: 12, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0614111E), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0314111E), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> workspace = [
    BoxShadow(color: Color(0x0814111E), blurRadius: 36, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x0414111E), blurRadius: 8, offset: Offset(0, 2)),
  ];

  // Large, almost invisible shadow for the framed application stage.
  static const List<BoxShadow> applicationFrame = [
    BoxShadow(color: Color(0x0A14111E), blurRadius: 52, offset: Offset(0, 22)),
    BoxShadow(color: Color(0x0514111E), blurRadius: 14, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> dropdown = [
    BoxShadow(color: Color(0x0A14111E), blurRadius: 16, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x0414111E), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> dialog = [
    BoxShadow(color: Color(0x1214111E), blurRadius: 32, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x0614111E), blurRadius: 8, offset: Offset(0, 2)),
  ];
}
