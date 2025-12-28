import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:budget_manager/theme/auth_palette.dart';

/// Unified "onboarding-style" theme used across the whole app.
/// Pastel backgrounds are drawn by AuthBackground; this theme focuses on
/// typography + component styling (glass cards, pills, etc.).
class AppTheme {
  // Keep legacy names used across the codebase, but map them to the new style.
  static const Color primaryBlack = AuthPalette.ink;
  static const Color surfaceBlack = Color(0xFFF7F6FF); // light lavender surface
  static const Color cardBlack = AuthPalette.glassSoft; // glassy surface
  static const Color outlineColor = Color(0x22FFFFFF);

  static const Color accentBronze = AuthPalette.tangerine; // primary accent
  static const Color accentGold = AuthPalette.ink; // used for icons/links
  static const Color deepGold = AuthPalette.inkSoft;

  static const Color textPrimary = AuthPalette.ink;
  static const Color textWhite = Colors.white;
  static const Color textSecondary = Color(0xFF3C3C46);

  static const Color successColor = Color(0xFF22C55E);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color incomeColor = Color(0xFF22C55E);
  static const Color expenseColor = Color(0xFFEF4444);

  // Radii
  static const double borderRadiusSmall = 12;
  static const double borderRadiusMedium = 16;
  static const double borderRadiusLarge = 20;
  static const double borderRadiusXLarge = 28;

  static const List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 14,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  // Legacy gradient name (used by a few widgets); now it's pastel.
  static const LinearGradient goldGradient = bronzeGradient;

  static const LinearGradient bronzeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AuthPalette.lavender,
      AuthPalette.peach,
      AuthPalette.lemon,
    ],
  );

  // Helper: avoid withOpacity() deprecation warnings
  static Color _alpha(Color c, double o) => c.withAlpha((o * 255).round());

  static ThemeData get pastelTheme {
    final base = ThemeData(
      // If your Flutter is older and doesn't like Material 3, set this to false.
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AuthPalette.violet,
        brightness: Brightness.light,
      ).copyWith(
        primary: AuthPalette.ink,
        secondary: AuthPalette.violet,
        surface: AuthPalette.glassSoft,
      ),
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 30,
        fontWeight: FontWeight.w900,
        height: 1.05,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        height: 1.08,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        height: 1.1,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: textSecondary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.transparent, // background drawn outside
      dividerColor: _alpha(Colors.white, 0.25),

      // ✅ Remove params not supported by your Flutter version
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AuthPalette.ink),
        titleTextStyle: textTheme.titleLarge,
      ),

      // ✅ Fix: CardThemeData (not CardTheme)
      cardTheme: CardThemeData(
        color: AuthPalette.glassSoft,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: _alpha(Colors.white, 0.35)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _alpha(Colors.white, 0.55),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: _alpha(Colors.white, 0.45)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: _alpha(Colors.white, 0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AuthPalette.ink, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthPalette.ink,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AuthPalette.ink,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // ✅ Use MaterialStateProperty for compatibility (instead of WidgetStateProperty)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: 70,
        labelTextStyle: MaterialStateProperty.all(
          GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 11),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          final selected = states.contains(MaterialState.selected);
          return IconThemeData(
            color: selected ? AuthPalette.ink : AuthPalette.inkSoft,
          );
        }),
      ),
    );
  }
}
