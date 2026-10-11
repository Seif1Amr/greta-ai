import 'package:flutter/material.dart';

/// App color palette adhering to deep obsidian/navy, electric cyan glow, and slate cards.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color backgroundBase = Color(0xFF0B111A);
  static const Color surfaceBase = Color(0xFF0F172A);
  static const Color surfaceElevated = Color(0xFF162130);
  static const Color surfaceCard = Color(0xFF1E293B);
  static const Color surfaceCardHigh = Color(0xFF243347);

  // Borders
  static const Color borderSubtle = Color(0xFF1E293B);
  static const Color borderHighlight = Color(0xFF334155);

  // Accents & Glows
  static const Color cyanGlow = Color(0xFF00D2FF);
  static const Color cyanSoft = Color(0xFF38BDF8);
  static const Color blueElectric = Color(0xFF2563EB);
  static const Color blueLight = Color(0xFF60A5FA);

  // Status & Feedback
  static const Color success = Color(0xFF10B981);
  static const Color successGlow = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color heartRed = Color(0xFFF43F5E);
  static const Color heartGlow = Color(0xFFFB7185);

  // Text
  static const Color textHighEmphasis = Color(0xFFF8FAFC);
  static const Color textMediumEmphasis = Color(0xFF94A3B8);
  static const Color textLowEmphasis = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF475569);

  // Gradients
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [cyanGlow, cyanSoft],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surfaceElevated, surfaceBase],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glowRingGradient = LinearGradient(
    colors: [cyanGlow, blueElectric, cyanSoft],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
