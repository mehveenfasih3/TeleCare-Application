import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPurple = Color(0xFF6A5ACD);
  static const Color lightPurple = Color(0xFF9B8FD9);
  static const Color darkPurple = Color(0xFF483D8B);
  static const Color accentPurple = Color(0xFF8A7FCC);
  
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F8FF);
  static const Color lightGray = Color(0xFFE8E8F0);
  static const Color darkGray = Color(0xFF6B6B80);
  
  static const Color textPrimary = Color(0xFF2D2D3A);
  static const Color textSecondary = Color(0xFF6B6B80);
  static const Color textLight = Color(0xFF9B9BAF);
  
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);
  
  static const Color cardBackground = Color(0xFFFAFAFF);
  static const Color divider = Color(0xFFE0E0E8);
  
  static LinearGradient purpleGradient = const LinearGradient(
    colors: [primaryPurple, lightPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient darkPurpleGradient = const LinearGradient(
    colors: [darkPurple, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}