import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:budget_manager/app.dart';
import 'package:budget_manager/screens/forgot_password_screen.dart';
import 'package:budget_manager/screens/security_fingerprint_screen.dart';
import 'package:budget_manager/screens/signup_screen.dart';
import 'package:budget_manager/services/auth_service.dart';
import 'package:budget_manager/theme/auth_palette.dart';
import 'package:budget_manager/widgets/auth/auth_background.dart';
import 'package:budget_manager/widgets/auth/soft_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _login() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() => _isLoading = true);
    try {
      await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const App()),
        (route) => false,
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la connexion : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      gradient: AuthPalette.onboardingGradient(2),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Budget Manager',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AuthPalette.ink,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const Spacer(),
                _CircleButton(
                  icon: Icons.fingerprint,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SecurityFingerprintScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'Bienvenue 👋',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AuthPalette.ink,
                    fontWeight: FontWeight.w900,
                    height: 0.95,
                    letterSpacing: -0.6,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connecte-toi pour retrouver tes transactions et tes insights.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AuthPalette.inkSoft,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 18),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(context, 'Email'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: _fieldTextStyle(context),
                    decoration: _fieldDecoration(
                      hint: 'example@example.com',
                      icon: Icons.alternate_email_rounded,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _label(context, 'Mot de passe'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: _fieldTextStyle(context),
                    decoration: _fieldDecoration(
                      hint: '••••••••',
                      icon: Icons.lock_rounded,
                      suffix: IconButton(
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: AuthPalette.inkSoft,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (v) =>
                            setState(() => _rememberMe = v ?? false),
                        activeColor: AuthPalette.ink,
                        checkColor: AuthPalette.cloud,
                        // ignore: deprecated_member_use
                        side: BorderSide(
                            color: AuthPalette.ink.withOpacity(0.25)),
                      ),
                      Text(
                        'Se souvenir',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AuthPalette.ink,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen()),
                          );
                        },
                        child: Text(
                          'Mot de passe oublié ?',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AuthPalette.ink,
                                    fontWeight: FontWeight.w800,
                                    decoration: TextDecoration.underline,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: _PrimaryButton(
                      label: 'Se connecter',
                      isLoading: _isLoading,
                      onTap: _isLoading ? null : _login,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pas de compte ? ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AuthPalette.inkSoft,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                  child: Text(
                    'Créer un compte',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AuthPalette.ink,
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  TextStyle _fieldTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AuthPalette.ink,
              fontWeight: FontWeight.w700,
            ) ??
        const TextStyle(color: AuthPalette.ink);
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
          color: AuthPalette.inkSoft, fontWeight: FontWeight.w600),
      prefixIcon: Icon(icon, color: AuthPalette.inkSoft),
      suffixIcon: suffix,
      filled: true,
      // ignore: deprecated_member_use
      fillColor: AuthPalette.cloud.withOpacity(0.75),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        // ignore: deprecated_member_use
        borderSide: BorderSide(color: AuthPalette.cloud.withOpacity(0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        // ignore: deprecated_member_use
        borderSide:
            BorderSide(color: AuthPalette.ink.withOpacity(0.35), width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AuthPalette.inkSoft,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AuthPalette.ink,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AuthPalette.cloud),
                    ),
                  )
                : Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AuthPalette.cloud,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      // ignore: deprecated_member_use
      color: AuthPalette.cloud.withOpacity(0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: AuthPalette.ink, size: 22),
        ),
      ),
    );
  }
}
