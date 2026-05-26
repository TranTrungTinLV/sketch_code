import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color bgPrimary = Color(0xFF0D1117);
  static const Color bgSecondary = Color(0xFF161B22);
  static const Color bgTertiary = Color(0xFF1A1F2E);
  static const Color bgSidebar = Color(0xFF0D1117);
  static const Color bgCard = Color(0xFF1A1F2E);
  static const Color bgCanvas = Color(0xFFF5F5F0);
  static const Color bgInput = Color(0xFF21262D);

  // Accents
  static const Color accentCyan = Color(0xff00D2FF);
  static const Color accentPurple = Color(0xffBD00FF);
  static const Color accentGreen = Color(0xff00FF88);
  static const Color accentPink = Color(0xffFF006E);
  static const Color accentOrange = Color(0xffFF8C00);
  static const Color accentRed = Color(0xffFF4757);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF6B7280);

  // Borders
  static const Color border = Color(0xFF30363D);
  static const Color borderLight = Color(0x3DFFFFFF);
  static const Color borderActive = Color(0xff00D2FF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment(0.8, 1),
    colors: [accentCyan, accentPurple],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment(0.8, 1),
    colors: [Color(0xff00FF88), Color(0xff00D2FF)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment(0.8, 1),
    colors: [Color(0xffFF8C00), Color(0xffFF006E)],
  );
}
