import 'package:flutter/material.dart';
import 'package:budget_manager/theme/app_theme.dart';
import 'package:budget_manager/theme/auth_palette.dart';
import 'package:budget_manager/widgets/auth/auth_background.dart';
import 'package:budget_manager/screens/login_screen.dart';
import 'package:budget_manager/app.dart';

class NewPasswordScreen extends StatefulWidget {
  final bool isInitialSetup;

  const NewPasswordScreen({
    super.key,
    this.isInitialSetup = false,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Critères de mot de passe
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumbers = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    // ✅ FIX: remove the comma + extra parenthesis
    _newPasswordController.addListener(_validatePassword);
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      gradient: AuthPalette.onboardingGradient(2),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),

                // Bouton retour
                if (!widget.isInitialSetup)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    color: AppTheme.accentGold,
                  ),

                SizedBox(height: widget.isInitialSetup ? 60 : 20),

                // Titre
                Text(
                  widget.isInitialSetup
                      ? 'Nouveau mot de passe'
                      : 'Mot de passe modifié',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.isInitialSetup
                      ? 'Créez un mot de passe sécurisé pour protéger votre compte'
                      : 'Votre mot de passe a été modifié avec succès',
                  style: Theme.of(context).textTheme.titleSmall,
                ),

                const SizedBox(height: 40),

                if (!widget.isInitialSetup)
                  // Illustration de succès
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withAlpha((0.10 * 255).round()),
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusLarge),
                      border: Border.all(
                        color: AppTheme.successColor.withAlpha((0.30 * 255).round()),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: AppTheme.successColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Mot de passe modifié',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.successColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 40),

                // Formulaire de mot de passe
                if (widget.isInitialSetup)
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildNewPasswordField(),
                        const SizedBox(height: 20),
                        _buildConfirmPasswordField(),
                        const SizedBox(height: 24),
                        _buildPasswordCriteria(),
                      ],
                    ),
                  ),

                const SizedBox(height: 40),

                // Bouton principal
                if (widget.isInitialSetup)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryBlack,
                                ),
                              ),
                            )
                          : Text(
                              'Changer le mot de passe',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                      ),
                      child: Text(
                        'Se connecter',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Lien de connexion
                if (widget.isInitialSetup)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: Text(
                        'Revenir à la connexion',
                        style: TextStyle(
                          color: AppTheme.accentGold,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nouveau mot de passe', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          controller: _newPasswordController,
          obscureText: _obscureNewPassword,
          decoration: InputDecoration(
            hintText: 'Entrez votre nouveau mot de passe',
            prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSecondary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.textSecondary,
              ),
              onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Veuillez entrer un mot de passe';
            if (!_isPasswordValid(value)) return 'Le mot de passe ne respecte pas les critères';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confirmer le mot de passe', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            hintText: 'Répétez votre nouveau mot de passe',
            prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSecondary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.textSecondary,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Veuillez confirmer votre mot de passe';
            if (value != _newPasswordController.text) return 'Les mots de passe ne correspondent pas';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordCriteria() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBlack,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Critères de sécurité', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _buildCriterion('Au moins 8 caractères', _hasMinLength),
          _buildCriterion('Une majuscule', _hasUpperCase),
          _buildCriterion('Une minuscule', _hasLowerCase),
          _buildCriterion('Un chiffre', _hasNumbers),
          _buildCriterion('Un caractère spécial', _hasSpecialChar),
        ],
      ),
    );
  }

  Widget _buildCriterion(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? AppTheme.successColor : AppTheme.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isMet ? AppTheme.successColor : AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  void _validatePassword() {
    final password = _newPasswordController.text;

    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasNumbers = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool _isPasswordValid(String password) {
    return _hasMinLength &&
        _hasUpperCase &&
        _hasLowerCase &&
        _hasNumbers &&
        _hasSpecialChar;
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simuler le changement de mot de passe
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() => _isLoading = false);

    // Naviguer
    if (widget.isInitialSetup) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const App()),
        (route) => false,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const NewPasswordScreen(isInitialSetup: false),
        ),
      );
    }
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_validatePassword);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
