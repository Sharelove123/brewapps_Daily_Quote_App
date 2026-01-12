import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFA855F7);
  static const Color secondaryColor = Color(0xFF6366F1);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFA855F7), // Purple
      Color(0xFF6366F1), // Indigo
    ],
  );

  static TextStyle get quoteTextStyle => GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.3,
  );

  static TextStyle get authorTextStyle => GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontStyle: FontStyle.italic,
    color: Colors.white70,
    letterSpacing: 0.5,
  );

  static TextStyle get navigationLabelStyle =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500);

  static TextStyle get emptyStateTextStyle =>
      GoogleFonts.inter(fontSize: 16, color: Colors.white70, height: 1.5);

  static TextStyle get uiTextStyle => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}
