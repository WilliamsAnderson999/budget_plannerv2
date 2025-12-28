import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:budget_manager/theme/auth_palette.dart';

enum MonsterMood { happy, calm, focused }

/// A lightweight illustration (no assets) inspired by the playful onboarding
/// references.
class MonsterHero extends StatelessWidget {
  final Color bodyColor;
  final MonsterMood mood;
  final double size;

  const MonsterHero({
    super.key,
    required this.bodyColor,
    this.mood = MonsterMood.happy,
    this.size = 300,
  });

  @override
  Widget build(BuildContext context) {
    final eye = _Eyes(mood: mood);
    final mouth = _Mouth(mood: mood);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bodyColor,
              borderRadius: BorderRadius.circular(size * 0.34),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                )
              ],
            ),
          ),

          // Cute "cloud" cap / band for variety.
          if (mood == MonsterMood.focused)
            Positioned(
              top: size * 0.08,
              child: Container(
                width: size * 0.72,
                height: size * 0.16,
                decoration: BoxDecoration(
                  color: AuthPalette.cloud.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: size * 0.64,
                    height: size * 0.05,
                    decoration: BoxDecoration(
                      color: AuthPalette.tangerine.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),

          // Sweat drops for "focused"
          if (mood == MonsterMood.focused)
            Positioned(
              right: size * 0.18,
              top: size * 0.26,
              child: _Sweat(color: AuthPalette.sea, scale: size / 300),
            ),

          Positioned(
            top: size * 0.40,
            child: eye,
          ),
          Positioned(
            top: size * 0.62,
            child: mouth,
          ),
        ],
      ),
    );
  }
}

class _Eyes extends StatelessWidget {
  final MonsterMood mood;
  const _Eyes({required this.mood});

  @override
  Widget build(BuildContext context) {
    final double gap = mood == MonsterMood.calm ? 30 : 38;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Eye(look: mood == MonsterMood.calm ? -0.15 : 0.05),
        SizedBox(width: gap),
        _Eye(look: mood == MonsterMood.calm ? 0.15 : -0.05),
      ],
    );
  }
}

class _Eye extends StatelessWidget {
  final double look;
  const _Eye({required this.look});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: AuthPalette.cloud,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Transform.translate(
          offset: Offset(look * 12, 0),
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _Mouth extends StatelessWidget {
  final MonsterMood mood;
  const _Mouth({required this.mood});

  @override
  Widget build(BuildContext context) {
    if (mood == MonsterMood.happy) {
      return Container(
        width: 84,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 44,
            height: 18,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AuthPalette.cloud,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }

    // calm/focused: minimal mouth
    return Container(
      width: mood == MonsterMood.calm ? 64 : 52,
      height: 14,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _Sweat extends StatelessWidget {
  final Color color;
  final double scale;
  const _Sweat({required this.color, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 8,
      child: Column(
        children: [
          _drop(1.0),
          SizedBox(height: 6 * scale),
          _drop(0.75),
        ],
      ),
    );
  }

  Widget _drop(double s) {
    return Container(
      width: 18 * scale * s,
      height: 26 * scale * s,
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
