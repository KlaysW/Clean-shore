import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryGreenStart = Color(0xFF2ECC71);
  static const Color primaryGreenEnd = Color(0xFF27AE60);

  static const Color background = Color(0xFFF7F9F8);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1A1F1D);
  static const Color textSecondary = Color(0xFF6B7570);

  static const Color dangerRed = Color(0xFFE74C3C);
  static const Color successGreen = Color(0xFF27AE60);
  static const Color warningAmber = Color(0xFFF39C12);

  static const Color crimsonScore = Color(0xFFC0392B);

  static const Color goldPodium = Color(0xFFFFD700);
  static const Color silverPodium = Color(0xFFC0C0C0);
  static const Color bronzePodium = Color(0xFFCD7F32);

  static const Color divider = Color(0xFFE0E4E2);
  static const Color chipBackground = Color(0xFFEFF3F1);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreenStart, primaryGreenEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}