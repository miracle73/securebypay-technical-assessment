import 'package:flutter/material.dart';

/// Design tokens pulled from the Figma file (variables + component styles).
/// Every colour, radius and spacing used by widgets should come from here.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF5A65AB); // buttons, links, auth side panel
  static const navy = Color(0xFF262A48); // banner, active nav item, "Pay Now"
  static const primary50 = Color(0xFFEBFFE2); // Primary/50 – button label
  static const success = Color(0xFF0A7D00); // Primary/800 (Base) – positive trend

  // Text
  static const textPrimary = Color(0xFF171717); // Text-Primary / Neutral/900
  static const textSecondary = Color(0xFF525252); // Text-Secondary
  static const gray800 = Color(0xFF1D2939); // Neutral/Gray-800
  static const gray500 = Color(0xFF667085); // Neutral/Gray-500
  static const gray400 = Color(0xFF98A2B3); // Neutral/Gray-400

  // Surfaces & borders
  static const white = Color(0xFFFFFFFF);
  static const neutral50 = Color(0xFFFAFAFA); // page background
  static const neutral100 = Color(0xFFF5F5F5);
  static const gray100 = Color(0xFFF2F4F7);
  static const gray200 = Color(0xFFE4E7EC);
  static const neutral200 = Color(0xFFE5E5E5);
  static const neutral300 = Color(0xFFD4D4D4); // input border
  static const neutral400 = Color(0xFFA3A3A3); // placeholder

  // Status
  static const error = Color(0xFFD92D20);
  static const transitBg = Color(0xFFFFEDD5);
  static const transitFg = Color(0xFFF97316);
  static const delayedBg = Color(0xFFCFFAFE);
  static const delayedFg = Color(0xFF0E7490);
  static const deliveredBg = Color(0xFFEBFFE2);
}

abstract final class AppRadius {
  static const sm = 6.0;
  static const md = 8.0; // inputs, buttons
  static const lg = 12.0; // cards
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 44.0;
}

/// Layout breakpoints (logical px).
abstract final class Breakpoints {
  static const tablet = 600.0;
  static const desktop = 1024.0;

  static bool isMobile(double w) => w < tablet;
  static bool isDesktop(double w) => w >= desktop;
}
