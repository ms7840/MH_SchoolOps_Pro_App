import 'package:flutter/material.dart';

/// Semantic design system color tokens with dark & light support.
class AppColors {
  const AppColors._();

  // Brand Primaries (MH SchoolOps Palette)
  static const Color primaryDarkNavy = Color(0xFF0F223D);
  static const Color primaryNavy = Color(0xFF1B365D);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryLightBlue = Color(0xFF3B82F6);
  static const Color primaryAccentCyan = Color(0xFF06B6D4);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoContainer = Color(0xFFDBEAFE);

  // Module Category Accents (For Dashboard Cards)
  static const Color moduleMessaging = Color(0xFF8B5CF6);
  static const Color moduleAttendance = Color(0xFF10B981);
  static const Color moduleHomework = Color(0xFFF59E0B);
  static const Color moduleExamination = Color(0xFFEC4899);
  static const Color moduleFee = Color(0xFF0EA5E9);
  static const Color moduleClassTest = Color(0xFFF97316);
  static const Color moduleActivity = Color(0xFF14B8A6);
  static const Color moduleTransport = Color(0xFF6366F1);

  // Light Mode Surfaces & Text
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Dark Mode Surfaces & Text
  static const Color darkBackground = Color(0xFF0B111E);
  static const Color darkSurface = Color(0xFF131D30);
  static const Color darkSurfaceVariant = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF27354A);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primaryDarkNavy, primaryNavy, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x332563EB), Color(0x002563EB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
