import 'package:flutter/material.dart';

/// Spingo Brand Design System & Color Palette
/// Perfectly tuned to match the official SPiNGO brand logo
class AppColors {
  // Brand Green (from SPiNGO Logo 'GO')
  static const Color primary = Color(0xFF65A30D);
  static const Color primaryDark = Color(0xFF4D7C0F);
  static const Color primaryLight = Color(0xFFF7FEE7);
  static const Color primarySurface = Color(0xFFECFCCB);
  
  // Electric Lime & Green Accents
  static const Color accentLime = Color(0xFF84CC16);
  static const Color greenLive = Color(0xFF16A34A);
  static const Color greenTagBg = Color(0xFFDCFCE7);

  // Midnight Slate / Navy (from SPiNGO Logo 'SPIN')
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color navyMuted = Color(0xFF1E293B);
  static const Color slateLight = Color(0xFF334155);

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color inputBg = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Accents
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color redDiscount = Color(0xFFE11D48);
  static const Color blueInfo = Color(0xFF0284C7);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF65A30D), Color(0xFF84CC16)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
