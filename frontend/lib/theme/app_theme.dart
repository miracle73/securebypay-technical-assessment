import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Typography follows the Figma text styles: DM Sans for forms/headings,
/// Manrope for dashboard body/caption text.
abstract final class AppText {
  static TextStyle get h1 =>
      GoogleFonts.dmSans(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle get h2 =>
      GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.textPrimary);
  static TextStyle get body => GoogleFonts.dmSans(fontSize: 14, height: 22 / 14, color: AppColors.textSecondary);
  static TextStyle get label => GoogleFonts.dmSans(fontSize: 16, color: AppColors.textPrimary);
  static TextStyle get input =>
      GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w300, height: 1.5, color: AppColors.textPrimary);
  static TextStyle get button =>
      GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary50);
  static TextStyle get link => GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.primary);
  static TextStyle get bodySmall => GoogleFonts.manrope(fontSize: 14, height: 20 / 14, color: AppColors.gray800);
  static TextStyle get caption => GoogleFonts.manrope(fontSize: 12, height: 18 / 12, color: AppColors.gray500);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      error: AppColors.error,
      surface: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.white,
  );

  OutlineInputBorder border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: c),
      );

  return base.copyWith(
    textTheme: GoogleFonts.dmSansTextTheme(base.textTheme),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppText.input.copyWith(color: AppColors.neutral400),
      errorStyle: GoogleFonts.dmSans(fontSize: 12, color: AppColors.error),
      border: border(AppColors.neutral300),
      enabledBorder: border(AppColors.neutral300),
      focusedBorder: border(AppColors.primary),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error),
    ),
  );
}
