import 'package:flutter/material.dart';

/// Pastel / playful palette used for onboarding + auth screens.
///
/// Kept separate from [AppTheme] so the main app can keep its dark identity
/// while onboarding/auth follow the light, illustration-first style.
class AuthPalette {
  // Base text
  static const Color ink = Color(0xFF101014);
  static const Color inkSoft = Color(0xFF2A2A33);

  // Pastels
  static const Color lavender = Color(0xFFD8C9FF);
  static const Color peach = Color(0xFFFFB6A3);
  static const Color tangerine = Color(0xFFFF7A45);
  static const Color lemon = Color(0xFFFFE289);
  static const Color mint = Color(0xFF8EE5C3);
  static const Color sea = Color(0xFF4FC3C7);
  static const Color bubblegum = Color(0xFFFFB4D9);
  static const Color violet = Color(0xFFA28BFF);
  static const Color cloud = Color(0xFFFFFFFF);

  // Surfaces
  static const Color glass = Color(0xCCFFFFFF);
  static const Color glassSoft = Color(0xB3FFFFFF);

  static LinearGradient onboardingGradient(int index) {
    switch (index % 3) {
      case 0:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lavender, peach],
        );
      case 1:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lemon, mint],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bubblegum, violet],
        );
    }
  }

  static const List<List<Color>> chipPalettes = [
    [tangerine, sea, mint, lemon, lavender, bubblegum],
    [mint, sea, lemon, lavender, bubblegum, tangerine],
    [bubblegum, lavender, lemon, mint, sea, tangerine],
  ];
}
