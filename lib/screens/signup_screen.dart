import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:budget_manager/screens/login_screen.dart';
import 'package:budget_manager/screens/security_pin_screen.dart';
import 'package:budget_manager/services/auth_service.dart';
import 'package:budget_manager/theme/auth_palette.dart';
import 'package:budget_manager/widgets/auth/auth_background.dart';
import 'package:budget_manager/widgets/auth/soft_card.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      gradient: AuthPalette.onboardingGradient(1),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CircleButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                Text(
                  'Créer un compte',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AuthPalette.ink,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Let’s go ✨',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AuthPalette.ink,
                    fontWeight: FontWeight.w900,
                    height: 0.95,
                    letterSpacing: -0.6,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crée ton espace, et commence à suivre ton budget en douceur.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AuthPalette.inkSoft,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            SoftCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(context, 'Nom complet'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _fullNameController,
                      style: _fieldTextStyle(context),
                      decoration: _fieldDecoration(
                        hint: 'John Doe',
                        icon: Icons.person_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer votre nom complet';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _label(context, 'Adresse email'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: _fieldTextStyle(context),
                      decoration: _fieldDecoration(
                        hint: 'example@example.com',
                        icon: Icons.alternate_email_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _label(context, 'Mot de passe'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: _fieldTextStyle(context),
                      decoration: _fieldDecoration(
                        hint: 'Au moins 6 caractères',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un mot de passe';
                        }
                        if (value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _label(context, 'Confirmer'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: _fieldTextStyle(context),
                      decoration: _fieldDecoration(
                        hint: 'Répétez votre mot de passe',
                        icon: Icons.lock_outline_rounded,
                        suffix: IconButton(
                          onPressed: () => setState(() =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword),
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: AuthPalette.inkSoft,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez confirmer votre mot de passe';
                        }
                        if (value != _passwordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _termsRow(context),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: _PrimaryButton(
                        label: 'Créer mon compte',
                        isLoading: _isLoading,
                        onTap: _isLoading ? null : _signUp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Déjà un compte ? ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AuthPalette.inkSoft,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    'Se connecter',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AuthPalette.ink,
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _termsRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (v) => setState(() => _acceptTerms = v ?? false),
          activeColor: AuthPalette.ink,
          checkColor: AuthPalette.cloud,
          side: BorderSide(color: AuthPalette.ink.withOpacity(0.25)),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _acceptTerms = !_acceptTerms),
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text.rich(
                TextSpan(
                  text: "J'accepte les ",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AuthPalette.ink,
                        fontWeight: FontWeight.w700,
                      ),
                  children: const [
                    TextSpan(
                      text: "conditions d'utilisation",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(text: ' et la '),
                    TextSpan(
                      text: 'politique de confidentialité',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Veuillez accepter les conditions d'utilisation")),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() => _isLoading = true);

    try {
      await authService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _fullNameController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SecurityPinScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'inscription: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
