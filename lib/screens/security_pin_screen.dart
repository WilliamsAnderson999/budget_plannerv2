import 'package:flutter/material.dart';
import 'package:budget_manager/theme/app_theme.dart';
import 'package:budget_manager/theme/auth_palette.dart';
import 'package:budget_manager/widgets/auth/auth_background.dart';
import 'package:budget_manager/widgets/pin_keypad.dart';
import 'package:budget_manager/screens/new_password_screen.dart';
import 'package:budget_manager/app.dart';

class SecurityPinScreen extends StatefulWidget {
  final String? email;
  final bool isPasswordReset;

  const SecurityPinScreen({
    super.key,
    this.email,
    this.isPasswordReset = false,
  });

  @override
  State<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends State<SecurityPinScreen> {
  String _pin = '';
  final int _pinLength = 6;

  int _attempts = 3; // ✅ made mutable so it actually works
  bool _isError = false;

  static Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      gradient: AuthPalette.onboardingGradient(4),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                Text(
                  widget.isPasswordReset
                      ? 'Code de vérification'
                      : 'Code PIN de sécurité',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                Text(
                  widget.isPasswordReset
                      ? 'Entrez le code à 6 chiffres envoyé à\n${widget.email ?? "votre email"}'
                      : 'Créez un code PIN à 6 chiffres pour sécuriser votre compte',
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                if (_attempts < 3 && !widget.isPasswordReset)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _a(AppTheme.errorColor, 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      border: Border.all(color: _a(AppTheme.errorColor, 0.30)),
                    ),
                    child: Text(
                      '$_attempts tentatives restantes',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 40),

                _buildPinIndicator(),

                const SizedBox(height: 40),

                if (_isError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      widget.isPasswordReset
                          ? 'Code incorrect. Veuillez réessayer.'
                          : 'Code PIN incorrect',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                Expanded(
                  child: PinKeypad(
                    onNumberPressed: _onNumberPressed,
                    onDeletePressed: _onDeletePressed,
                    onBiometricPressed: widget.isPasswordReset ? null : _onBiometricPressed,
                  ),
                ),

                const SizedBox(height: 20),

                if (widget.isPasswordReset)
                  TextButton(
                    onPressed: _resendCode,
                    child: Text(
                      'Renvoyer le code',
                      style: TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < _pin.length
                ? (_isError ? AppTheme.errorColor : AppTheme.accentGold)
                : AppTheme.surfaceBlack,
            border: Border.all(
              color: index < _pin.length ? Colors.transparent : _a(AppTheme.textSecondary, 0.30),
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  void _onNumberPressed(String number) {
    if (_pin.length >= _pinLength) return;

    setState(() {
      _pin += number;
      _isError = false;
    });

    if (_pin.length == _pinLength) {
      _verifyPin();
    }
  }

  void _onDeletePressed() {
    if (_pin.isEmpty) return;

    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _isError = false;
    });
  }

  void _onBiometricPressed() {
    // TODO
  }

  Future<void> _verifyPin() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    if (widget.isPasswordReset) {
      if (_pin == '123456') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NewPasswordScreen()),
        );
      } else {
        setState(() {
          _attempts = (_attempts - 1).clamp(0, 3);
          _isError = true;
          _pin = '';
        });
      }
      return;
    }

    // Creating PIN success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Code PIN créé avec succès !',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        backgroundColor: AppTheme.successColor,
      ),
    );

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const App()),
      (route) => false,
    );
  }

  void _resendCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Code envoyé à ${widget.email ?? "votre email"}',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}
