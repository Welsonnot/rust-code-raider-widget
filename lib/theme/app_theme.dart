// Copyright (c) 2026 Wilhelm San Pedro (https://minristudio.com).
// Licensed under the PolyForm Noncommercial License 1.0.0.
// See LICENSE in the project root for full license terms.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Mode (Default — Pixel-Sampled from "London / Paris / Mobile View")
  static const Color lightBg = Color(0xFFE8E8E8);
  static const Color lightHeaderBg = Color(0xFFE2E2E2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightControlBg = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFD8D8D8);
  static const Color lightDivider = Color(0xFFDEDEDE);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF3A3A3C);
  static const Color lightTextMuted = Color(0xFF707070);

  // Dark Mode (Pixel-Sampled from "Los Angeles" Pitch Black Tile)
  static const Color darkBg = Color(0xFF000000);
  static const Color darkHeaderBg = Color(0xFF0C0C0E);
  static const Color darkSurface = Color(0xFF121214);
  static const Color darkControlBg = Color(0xFF161618);
  static const Color darkBorder = Color(0xFF222225);
  static const Color darkDivider = Color(0xFF1A1A1D);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFC7C7CC);
  static const Color darkTextMuted = Color(0xFF959595);

  // Editorial Accents (Sampled from "Day ☀️" warm amber & high-contrast pills)
  static const Color warmSun = Color(0xFFF5C438);
  static const Color accentRust = Color(0xFFF5C438);
  static const Color statusActive = Color(0xFF28CD41);
  static const Color statusPaused = Color(0xFFF5C438);
  static const Color statusDanger = Color(0xFFFF3B30);

  static Color bg(bool isDark) => isDark ? darkBg : lightBg;
  static Color headerBg(bool isDark) => isDark ? darkHeaderBg : lightHeaderBg;
  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color controlBg(bool isDark) => isDark ? darkControlBg : lightControlBg;
  static Color border(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color divider(bool isDark) => isDark ? darkDivider : lightDivider;
  static Color textPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;
  static Color textMuted(bool isDark) =>
      isDark ? darkTextMuted : lightTextMuted;

  /// Active capsule fill (Solid #000000 on Light Mode, Solid #FFFFFF on Dark Mode — matches "24h" pill)
  static Color activePillBg(bool isDark) =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);

  /// Active capsule text (Solid #FFFFFF on Light Mode, Solid #000000 on Dark Mode — matches "24h" pill)
  static Color activePillText(bool isDark) =>
      isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);

  /// Swiss neo-grotesque sans-serif (Instrument Sans — matches "London" / "Los Angeles, California, USA")
  static TextStyle sans({
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.instrumentSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing ?? -0.2,
      height: height,
    );
  }

  /// Tall, flat-sided superelliptical tabular numerals (Instrument Sans — matches "08 40" and "16:40:15")
  static TextStyle mono({
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.instrumentSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing ?? -0.4,
      height: height,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
