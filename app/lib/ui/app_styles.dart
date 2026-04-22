import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF3F51B5);
  static const Color background = Color(0xFFF8F8FC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1E1E2C);
  static const Color textSecondary = Color(0xFF757585);
  static const Color inputFill = Color(0xFFEFEFF6);

  // Priority Colors
  static const Color lowPriority = Color(0xFF757575);
  static const Color mediumPriority = Color(0xFFFB8C00);
  static const Color highPriority = Color(0xFFE53935);
  
  // Status Colors
  static const Color success = Color(0xFF43A047);
  static const Color error = Color(0xFFD32F2F);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets screenPadding = EdgeInsets.all(l);
  static const EdgeInsets cardPadding = EdgeInsets.all(l);
}

class AppRadius {
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 24.0;
  static const double pill = 32.0;

  static BorderRadius radiusS = BorderRadius.circular(s);
  static BorderRadius radiusM = BorderRadius.circular(m);
  static BorderRadius radiusL = BorderRadius.circular(l);
  static BorderRadius radiusXL = BorderRadius.circular(xl);
  static BorderRadius radiusPill = BorderRadius.circular(pill);
}

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);
}
