import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:budget_manager/theme/auth_palette.dart';

/// A playful pastel background (gradient + decorative blobs) used by
/// onboarding/auth screens.
class AuthBackground extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final bool safeAreaTop;
  final bool safeAreaBottom;

  const AuthBackground({
    super.key,
    required this.child,
    required this.gradient,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Stack(
          children: [
            const _Blobs(),
            SafeArea(
              top: safeAreaTop,
              bottom: safeAreaBottom,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _Blobs extends StatelessWidget {
  const _Blobs();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    // Soft, translucent blobs like the inspiration references.
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -w * 0.25,
            top: -h * 0.10,
            child: _blob(
              diameter: w * 0.75,
              color: AuthPalette.cloud.withOpacity(0.22),
            ),
          ),
          Positioned(
            right: -w * 0.22,
            top: h * 0.18,
            child: _blob(
              diameter: w * 0.62,
              color: AuthPalette.cloud.withOpacity(0.18),
            ),
          ),
          Positioned(
            left: -w * 0.15,
            bottom: -h * 0.12,
            child: Transform.rotate(
              angle: -math.pi / 12,
              child: _blob(
                diameter: w * 0.70,
                color: AuthPalette.cloud.withOpacity(0.16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob({required double diameter, required Color color}) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
