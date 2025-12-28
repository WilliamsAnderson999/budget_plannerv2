import 'package:flutter/material.dart';
import 'package:budget_manager/theme/app_theme.dart';

class PinKeypad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final Function() onDeletePressed;
  final Function()? onBiometricPressed;

  const PinKeypad({
    super.key,
    required this.onNumberPressed,
    required this.onDeletePressed,
    this.onBiometricPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBlack,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Ligne 1
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('1'),
              _buildKey('2'),
              _buildKey('3'),
            ],
          ),
          const SizedBox(height: 20),

          // Ligne 2
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('4'),
              _buildKey('5'),
              _buildKey('6'),
            ],
          ),
          const SizedBox(height: 20),

          // Ligne 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('7'),
              _buildKey('8'),
              _buildKey('9'),
            ],
          ),
          const SizedBox(height: 20),

          // Ligne 4
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              onBiometricPressed != null
                  ? _buildBiometricKey()
                  : const SizedBox(width: 80),
              _buildKey('0'),
              _buildDeleteKey(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String number) {
    return GestureDetector(
      onTap: () => onNumberPressed(number),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppTheme.surfaceBlack,
          shape: BoxShape.circle,
          boxShadow: AppTheme.subtleShadow,
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey() {
    return GestureDetector(
      onTap: onDeletePressed,
      onLongPress: () {
        // Effacer tout
        for (int i = 0; i < 6; i++) {
          onDeletePressed();
        }
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppTheme.surfaceBlack,
          shape: BoxShape.circle,
          boxShadow: AppTheme.subtleShadow,
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 32,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricKey() {
    return GestureDetector(
      onTap: onBiometricPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppTheme.surfaceBlack,
          shape: BoxShape.circle,
          boxShadow: AppTheme.subtleShadow,
        ),
        child: const Center(
          child: Icon(
            Icons.fingerprint,
            size: 32,
            color: AppTheme.accentGold,
          ),
        ),
      ),
    );
  }
}
