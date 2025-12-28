import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:budget_manager/theme/auth_palette.dart';

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final double blurSigma;

  /// Optional: pass your own pastel gradient per card/section
  final Gradient? gradient;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.blurSigma = 14,
    this.gradient,
  });

  static Color _alpha(Color c, double o) => c.withAlpha((o * 255).round());

  static final Gradient _defaultPastel = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      _alpha(AuthPalette.lavender, 0.18),
      _alpha(AuthPalette.peach, 0.16),
      _alpha(AuthPalette.lemon, 0.14),
      _alpha(AuthPalette.mint, 0.12),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final g = gradient ?? _defaultPastel;

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Stack(
            children: [
              // pastel tint
              Positioned.fill(
                child: DecoratedBox(decoration: BoxDecoration(gradient: g)),
              ),
              // glass layer for readability
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _alpha(Colors.white, 0.72),
                    border: Border.all(color: _alpha(Colors.white, 0.55)),
                  ),
                ),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}
