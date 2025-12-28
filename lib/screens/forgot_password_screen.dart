import 'package:flutter/material.dart';
import 'package:budget_manager/screens/security_pin_screen.dart';
import 'package:budget_manager/theme/auth_palette.dart';
import 'package:budget_manager/widgets/auth/auth_background.dart';
import 'package:budget_manager/widgets/auth/soft_card.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez entrer votre adresse email'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SecurityPinScreen(
          email: _emailController.text.trim(),
          isPasswordReset: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      gradient: AuthPalette.onboardingGradient(3),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.pop(context),
                  color: AuthPalette.ink,
                ),
                const SizedBox(height: 8),
                Text(
                  'Mot de passe oublié',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AuthPalette.ink,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Réinitialisez votre mot de passe en quelques étapes.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AuthPalette.inkSoft,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),

                SoftCard(
                  child: Row(
                    children: const [
                      Icon(Icons.lock_reset_rounded, color: AuthPalette.ink),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Entrez l'email associé à votre compte. Nous vous enverrons un code.",
                          style: TextStyle(
                            color: AuthPalette.inkSoft,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Adresse email',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AuthPalette.inkSoft,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'example@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Envoyer le code'),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Revenir à la connexion',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AuthPalette.ink,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
