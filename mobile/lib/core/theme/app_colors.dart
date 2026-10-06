import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand colors can be overridden at build time with ARGB hex values, e.g.
  // --dart-define=APP_PRIMARY_COLOR=0xFF1E3A8A --dart-define=APP_ACCENT_COLOR=0xFFF59E0B
  static const navy = Color(int.fromEnvironment('APP_PRIMARY_COLOR', defaultValue: 0xFF101B3D));
  static const navySoft = Color(int.fromEnvironment('APP_PRIMARY_SOFT_COLOR', defaultValue: 0xFF1A274B));
  static const red = Color(int.fromEnvironment('APP_ACCENT_COLOR', defaultValue: 0xFFE11D2E));
  static const redDark = Color(int.fromEnvironment('APP_ACCENT_DARK_COLOR', defaultValue: 0xFFBE1625));
  static const background = Color(0xFFF4F6F8);
  static const darkBackground = Color(0xFF0A1023);
  static const darkSurface = Color(0xFF121C36);
  static const success = Color(0xFF2EAF62);
  static const warning = Color(0xFFFF8A24);
  static const textMuted = Color(0xFF6B7280);
}
