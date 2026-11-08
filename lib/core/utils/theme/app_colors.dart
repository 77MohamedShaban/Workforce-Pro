import 'package:flutter/material.dart';

abstract final class AppColors {
  // Workforce Pro Brand Colors
  static const Color navy = Color(0xFF172554); // Primary dark navy
  static const Color blue = Color(0xFF3B82F6); // Primary action blue
  static const Color teal = Color(0xFF14B8A6); // Accent teal

  // Background & Surface
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  // Status & Feedback Colors
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0284C7);

  // Activity Status Colors
  static const Color activityWork = Color(0xFF3B82F6);
  static const Color activityBreak = Color(0xFF14B8A6);
  static const Color activityLunch = Color(0xFFF59E0B);
  static const Color activityTraining = Color(0xFF8B5CF6);
  static const Color activityMeeting = Color(0xFFEC4899);

  // Legacy compatibility getters
  static const Color mainLight = navy;
  static const Color mainDark = blue;
}
