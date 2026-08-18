import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF08AFA4);
  static const primaryDark = Color(0xFF08766F);
  static const primaryDeep = Color(0xFF075E59);
  static const secondary = Color(0xFFA7E3D9);
  static const mintSoft = Color(0xFFE7F8F5);
  static const lavender = Color(0xFFCDB4F7);
  static const lavenderSoft = Color(0xFFF1ECFC);
  static const background = Color(0xFFF7F9FC);
  static const surface = Color(0xFFFFFFFF);
  static const card = Color(0xFFEFF9F4);
  static const ink = Color(0xFF102A47);
  static const inkMuted = Color(0xFF60708A);
  static const inkSubtle = Color(0xFF8793A7);
  static const success = Color(0xFF1FB982);
  static const warning = Color(0xFFF29A55);
  static const danger = Color(0xFFFF5B7D);
  static const info = Color(0xFF5F8FF7);
  static const divider = Color(0xFFE3E9F1);
  static const shadow = Color(0x1A102A47);

  static const primaryGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFF12BDB1), Color(0xFF08AFA4)],
  );

  static const calmGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFFF3EEFF), Color(0xFFE8F8F5)],
  );

  static const heroGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFFF6F1FF), Color(0xFFDFF6F2)],
  );
}
