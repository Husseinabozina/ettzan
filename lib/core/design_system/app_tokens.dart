import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

abstract final class AppRadii {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 26;
  static const double xl = 34;
  static const double pill = 999;
}

abstract final class AppDurations {
  static const fast = Duration(milliseconds: 160);
  static const normal = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 480);
}

abstract final class AppBreakpoints {
  static const double phone = 600;
  static const double tablet = 1024;
  static const double contentMax = 1180;
}

abstract final class AppShadows {
  static const soft = [
    BoxShadow(
      color: Color(0x14102A47),
      blurRadius: 30,
      offset: Offset(0, 14),
    ),
  ];

  static const card = [
    BoxShadow(
      color: Color(0x10102A47),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];
}
