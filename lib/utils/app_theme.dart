import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme configuration with support for dark/light modes and accent colors
class AppTheme {
  // Primary Colors
  static const Color primaryPurple = Color(0xFFA855F7);
  static const Color primaryIndigo = Color(0xFF6366F1);

  // Accent Color Options
  static const Map<String, Color> accentColors = {
    'purple': Color(0xFFA855F7),
    'indigo': Color(0xFF6366F1),
    'teal': Color(0xFF14B8A6),
    'rose': Color(0xFFF43F5E),
    'amber': Color(0xFFF59E0B),
  };

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F0A1F);
  static const Color darkBackgroundEnd = Color(0xFF1E1B4B);
  static const Color darkSurface = Color(0xFF1A1625);
  static const Color darkCard = Color(0x1AFFFFFF); // 10% white
  static const Color darkCardBorder = Color(0x33FFFFFF); // 20% white

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0x1A000000); // 10% black

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color favorite = Color(0xFFEC4899);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkBackground, darkBackgroundEnd],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryPurple, primaryIndigo],
  );

  static LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightBackground, Colors.white],
  );

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 30.0;

  // Text Styles (default for dark theme - use themed variants for light mode support)
  static TextStyle get quoteTextStyle => GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get authorTextStyle => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: 0.5,
  );

  static TextStyle get headingStyle => GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get subheadingStyle => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static TextStyle get bodyStyle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle get labelStyle => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static TextStyle get buttonStyle => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get navigationLabelStyle =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500);

  static TextStyle get uiTextStyle =>
      GoogleFonts.inter(fontSize: 16, color: textPrimary);

  static TextStyle get emptyStateTextStyle => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  // Theme-aware text styles
  static TextStyle quoteTextStyleThemed(bool isDark) =>
      GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        color: isDark ? textPrimary : textPrimaryLight,
        height: 1.5,
      );

  static TextStyle headingStyleThemed(bool isDark) =>
      GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: isDark ? textPrimary : textPrimaryLight,
      );

  static TextStyle subheadingStyleThemed(bool isDark) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: isDark ? textSecondary : textSecondaryLight,
  );

  static TextStyle bodyStyleThemed(bool isDark) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: isDark ? textPrimary : textPrimaryLight,
  );

  static TextStyle labelStyleThemed(bool isDark) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: isDark ? textSecondary : textSecondaryLight,
  );

  static TextStyle authorTextStyleThemed(bool isDark) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: isDark ? textSecondary : textSecondaryLight,
    letterSpacing: 0.5,
  );

  static LinearGradient backgroundGradientThemed(bool isDark) =>
      isDark ? backgroundGradient : lightBackgroundGradient;

  // Glassmorphism Decoration
  static BoxDecoration glassDecoration({
    bool isDark = true,
    double opacity = 0.1,
    double borderOpacity = 0.2,
    double borderRadius = radiusLarge,
  }) {
    return BoxDecoration(
      color: isDark
          ? Colors.white.withValues(alpha: opacity)
          : Colors.black.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: borderOpacity)
            : Colors.black.withValues(alpha: 0.1),
      ),
    );
  }

  // Theme Data Builders
  static ThemeData darkTheme({Color accentColor = primaryPurple}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: accentColor,
        secondary: primaryIndigo,
        surface: darkSurface,
        error: error,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: headingStyle.copyWith(fontSize: 20),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: darkCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: darkCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        hintStyle: subheadingStyle,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: buttonStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: buttonStyle.copyWith(fontSize: 14),
        ),
      ),
    );
  }

  static ThemeData lightTheme({Color accentColor = primaryPurple}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: accentColor,
        secondary: primaryIndigo,
        surface: lightSurface,
        error: error,
      ),
      scaffoldBackgroundColor: lightBackground,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: headingStyle.copyWith(
          fontSize: 20,
          color: textPrimaryLight,
        ),
        iconTheme: const IconThemeData(color: textPrimaryLight),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: lightCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: lightCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        hintStyle: subheadingStyle.copyWith(color: textSecondaryLight),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: buttonStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: buttonStyle.copyWith(fontSize: 14),
        ),
      ),
    );
  }
}
