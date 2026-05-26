import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sketch/untils/app_colors.dart';

class AppStyles {
  AppStyles._();

  // Headings
  static TextStyle heading1({double? fontSize, Color? color}) =>
      GoogleFonts.playfairDisplay(
        fontSize: fontSize ?? 48,
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle heading2({double? fontSize, Color? color}) =>
      GoogleFonts.playfairDisplay(
        fontSize: fontSize ?? 24,
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle heading3({double? fontSize, Color? color}) =>
      GoogleFonts.playfairDisplay(
        fontSize: fontSize ?? 18,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  // Body
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        color: color ?? AppColors.textMuted,
      );

  // Labels
  static TextStyle label({Color? color, FontWeight? fontWeight}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: fontWeight ?? FontWeight.w600,
        color: color ?? AppColors.textSecondary,
        letterSpacing: 0.5,
      );

  static TextStyle caption({Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        color: color ?? AppColors.textMuted,
      );

  // Button
  static TextStyle button({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  // Nav
  static TextStyle navItem({Color? color, bool active = false}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
        color: color ?? (active ? AppColors.textPrimary : AppColors.textSecondary),
      );
}
