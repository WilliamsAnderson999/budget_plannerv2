import 'package:flutter/material.dart';
import 'package:budget_manager/theme/app_theme.dart';
import 'package:budget_manager/theme/auth_palette.dart';
import 'package:budget_manager/widgets/auth/auth_background.dart';
import 'package:budget_manager/screens/home_screen.dart';
import 'package:budget_manager/screens/security_pin_screen.dart';

class SecurityFingerprintScreen extends StatefulWidget {
  const SecurityFingerprintScreen({super.key});

  @override
  State<SecurityFingerprintScreen> createState() =>
      _SecurityFingerprintScreenState();
}

class _SecurityFingerprintScreenState extends State<SecurityFingerprintScreen> {
  bool _isAuthenticating = false;
  bool _useFingerprint = false;

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      gradient: AuthPalette.onboardingGradient(1),
      child: Scaffold(
        backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          // Add to prevent overflow
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Titre
              Text(
                'Authentification biométrique',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Utilisez votre empreinte digitale pour un accès rapide et sécurisé',
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),

              // Illustration
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: AppTheme.accentGold.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.fingerprint,
                    size: 100,
                    color: AppTheme.primaryBlack,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Switch d'activation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBlack,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusLarge),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: AppTheme.accentBronze.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fingerprint_outlined,
                        color: AppTheme.accentBronze,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Utiliser l\'empreinte digitale',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Déverrouillez rapidement l\'application',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _useFingerprint,
                      onChanged: (value) {
                        setState(() {
                          _useFingerprint = value;
                        });
                      },
                      activeThumbColor: AppTheme.accentBronze,
                      // ignore: deprecated_member_use
                      activeTrackColor: AppTheme.accentBronze.withOpacity(0.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceBlack,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.accentBronze,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vos données biométriques sont stockées de manière sécurisée sur votre appareil et ne sont jamais partagées.',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Bouton principal
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _useFingerprint ? _authenticate : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusMedium),
                    ),
                  ),
                  child: _isAuthenticating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryBlack),
                          ),
                        )
                      : Text(
                          'Configurer l\'empreinte',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Alternative
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecurityPinScreen(),
                    ),
                  );
                },
                child: Text.rich(
                  TextSpan(
                    text: 'Préférer utiliser un ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: 'code PIN',
                        style: TextStyle(
                          color: AppTheme.accentGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' ?'),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Lien de connexion alternative
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: Text(
                  'Passer pour l\'instant',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
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

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
    });

    // Simuler l'authentification biométrique
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isAuthenticating = false;
    });

    // Naviguer vers l'accueil
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}
