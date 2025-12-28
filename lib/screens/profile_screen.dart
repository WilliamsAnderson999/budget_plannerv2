import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:budget_manager/theme/app_theme.dart';
import 'package:budget_manager/theme/auth_palette.dart';
import 'package:budget_manager/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:budget_manager/services/auth_service.dart';
import 'package:budget_manager/services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _userName;
  late String _userEmail;
  late String _userSince;

  double _monthlyBudget = 2000.00;
  String _currency = 'USD';
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _darkMode = true;
  String _language = 'Français';

  Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  double _bottomNavSpace(BuildContext context) {
    // nav bar height ~72 + outer padding 14 + breathing space
    return MediaQuery.of(context).padding.bottom + 72 + 24;
  }

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _userName = authService.currentUser?.displayName ?? 'User';
    _userEmail = authService.currentUser?.email ?? 'email@example.com';
    _userSince = 'Mai 2023'; // TODO: get from Firestore
  }

  @override
  Widget build(BuildContext context) {
    final bottomSpace = _bottomNavSpace(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          floating: true,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Text(
            'Profil',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _RoundIconButton(
                icon: Icons.edit_outlined,
                onTap: _editProfile,
              ),
            ),
          ],
        ),

        // ✅ Profile header (NO fixed height => no overflow stripe)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              child: Stack(
                children: [
                  // gradient always fills whatever height the content needs
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _a(AuthPalette.lavender, 0.70),
                            _a(AuthPalette.peach, 0.70),
                            _a(AuthPalette.lemon, 0.70),
                            _a(AuthPalette.mint, 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // blobs
                  Positioned(
                    left: -60,
                    top: -70,
                    child: _Blob(color: _a(Colors.white, 0.22), size: 200),
                  ),
                  Positioned(
                    right: -70,
                    top: 10,
                    child: _Blob(color: _a(Colors.white, 0.18), size: 220),
                  ),

                  // glass overlay (sizes itself to its child)
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _a(Colors.white, 0.28),
                        border: Border.all(color: _a(Colors.white, 0.45)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // avatar
                          Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.bronzeGradient,
                              border: Border.all(
                                color: _a(Colors.white, 0.55),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _initials(_userName),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: AuthPalette.ink,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // info
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: AuthPalette.ink,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _userEmail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AuthPalette.inkSoft,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 10),

                                // ✅ extra safety: never overflow
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _a(AuthPalette.tangerine, 0.18),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: _a(AuthPalette.tangerine, 0.25),
                                      ),
                                    ),
                                    child: Text(
                                      'Membre depuis $_userSince',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AuthPalette.tangerine,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // stats
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _GlassStatCard(
                    title: 'Transactions',
                    value: '127',
                    icon: Icons.receipt_long_outlined,
                    tint: AuthPalette.peach,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GlassStatCard(
                    title: 'Catégories',
                    value: '8',
                    icon: Icons.category_outlined,
                    tint: AuthPalette.lavender,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GlassStatCard(
                    title: 'Objectifs',
                    value: '3',
                    icon: Icons.flag_outlined,
                    tint: AuthPalette.mint,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 18)),

        // settings sections
        SliverList(
          delegate: SliverChildListDelegate([
            _buildSettingsSection('Préférences', [
              _buildSettingItem(
                icon: Icons.account_balance_wallet_outlined,
                iconTint: AuthPalette.lemon,
                title: 'Budget mensuel',
                subtitle: '\$$_monthlyBudget',
                trailing: Text(
                  _currency,
                  style: const TextStyle(
                    color: AuthPalette.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                onTap: _editBudget,
              ),
              _buildSettingItem(
                icon: Icons.notifications_outlined,
                iconTint: AuthPalette.peach,
                title: 'Notifications',
                subtitle: _notificationsEnabled ? 'Activées' : 'Désactivées',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) => setState(() {
                    _notificationsEnabled = value;
                  }),
                  activeColor: AuthPalette.tangerine,
                ),
              ),
              _buildSettingItem(
                icon: Icons.fingerprint_outlined,
                iconTint: AuthPalette.lavender,
                title: 'Authentification biométrique',
                subtitle: _biometricEnabled ? 'Activée' : 'Désactivée',
                trailing: Switch(
                  value: _biometricEnabled,
                  onChanged: (value) => setState(() {
                    _biometricEnabled = value;
                  }),
                  activeColor: AuthPalette.tangerine,
                ),
              ),
              _buildSettingItem(
                icon: Icons.credit_card_outlined,
                iconTint: AuthPalette.mint,
                title: 'Carte de crédit',
                subtitle: 'Connecter votre carte pour transactions automatiques',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fonctionnalité à venir')),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.dark_mode_outlined,
                iconTint: AuthPalette.sea,
                title: 'Mode sombre',
                subtitle: _darkMode ? 'Activé' : 'Désactivé',
                trailing: Switch(
                  value: _darkMode,
                  onChanged: (value) => setState(() {
                    _darkMode = value;
                  }),
                  activeColor: AuthPalette.tangerine,
                ),
              ),
              _buildSettingItem(
                icon: Icons.language_outlined,
                iconTint: AuthPalette.lemon,
                title: 'Langue',
                subtitle: _language,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: _a(Colors.white, 0.95),
                      title: const Text('Changer la langue'),
                      content: DropdownButton<String>(
                        value: _language,
                        items: ['Français', 'English'].map((lang) {
                          return DropdownMenuItem(
                            value: lang,
                            child: Text(lang),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _language = value!;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              ),
            ]),

            _buildSettingsSection('Support', [
              _buildSettingItem(
                icon: Icons.help_outline,
                iconTint: AuthPalette.lavender,
                title: 'Centre d\'aide',
                subtitle: 'FAQ et support',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: _a(Colors.white, 0.95),
                      title: const Text('Centre d\'aide'),
                      content: const Text('FAQ et support à venir.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        )
                      ],
                    ),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.security_outlined,
                iconTint: AuthPalette.peach,
                title: 'Politique de confidentialité',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: _a(Colors.white, 0.95),
                      title: const Text('Politique de confidentialité'),
                      content: const Text(
                        'Votre confidentialité est importante. Nous ne partageons pas vos données.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        )
                      ],
                    ),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.description_outlined,
                iconTint: AuthPalette.mint,
                title: 'Conditions d\'utilisation',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: _a(Colors.white, 0.95),
                      title: const Text('Conditions d\'utilisation'),
                      content: const Text('Conditions d\'utilisation de l\'app.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        )
                      ],
                    ),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.info_outline,
                iconTint: AuthPalette.lemon,
                title: 'À propos',
                subtitle: 'Version 1.0.0',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: _a(Colors.white, 0.95),
                      title: const Text('À propos'),
                      content: const Text(
                        'Budget Manager v1.0.0\nDéveloppé avec Flutter.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        )
                      ],
                    ),
                  );
                },
              ),
            ]),

            // logout card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                child: Container(
                  decoration: BoxDecoration(
                    color: _a(Colors.white, 0.55),
                    border: Border.all(color: _a(Colors.white, 0.50)),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _a(AppTheme.errorColor, 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.logout_rounded,
                          color: AppTheme.errorColor),
                    ),
                    title: const Text(
                      'Déconnexion',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AuthPalette.ink,
                      ),
                    ),
                    subtitle: const Text(
                      'Se déconnecter de votre compte',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AuthPalette.inkSoft,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _logout,
                  ),
                ),
              ),
            ),

            // bottom space so it never hides behind nav bar
            SizedBox(height: bottomSpace),
          ]),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    if (parts.isEmpty) return 'U';
    final letters = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return letters.isEmpty ? 'U' : letters;
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AuthPalette.ink,
                ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _a(Colors.white, 0.55),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            border: Border.all(color: _a(Colors.white, 0.45)),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconTint,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _a(Colors.black, 0.06),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _a(iconTint, 0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AuthPalette.tangerine, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AuthPalette.ink,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AuthPalette.inkSoft,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: AuthPalette.inkSoft,
                ),
          ],
        ),
      ),
    );
  }

  void _editProfile() {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Modifier le profil',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                final authService =
                    Provider.of<AuthService>(context, listen: false);
                final firestoreService =
                    Provider.of<FirestoreService>(context, listen: false);

                try {
                  if (authService.currentUser != null) {
                    await authService.currentUser!
                        .updateDisplayName(nameController.text);
                  }

                  await firestoreService
                      .updateUser(authService.currentUser!.uid, {
                    'fullName': nameController.text,
                    'email': emailController.text,
                  });

                  setState(() {
                    _userName = nameController.text;
                    _userEmail = emailController.text;
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil mis à jour')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  void _editBudget() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Modifier le budget',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Budget mensuel',
                  prefixText: '\$',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusMedium),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: Theme.of(context).textTheme.bodyLarge,
                onChanged: (value) {
                  final budget = double.tryParse(value) ?? 0;
                  setState(() => _monthlyBudget = budget);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _currency,
                decoration: InputDecoration(
                  labelText: 'Devise',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusMedium),
                  ),
                ),
                items: ['USD', 'EUR', 'GBP', 'CAD', 'AUD']
                    .map((currency) => DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _currency = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Budget mis à jour')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AuthPalette.ink,
                foregroundColor: Colors.white,
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Déconnexion',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            'Êtes-vous sûr de vouloir vous déconnecter ?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }
}

class _GlassStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color tint;

  const _GlassStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.tint,
  });

  Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _a(Colors.white, 0.55),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: _a(Colors.white, 0.45)),
        boxShadow: AppTheme.subtleShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _a(tint, 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AuthPalette.ink, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AuthPalette.ink,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AuthPalette.inkSoft,
                ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _a(Colors.white, 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: AuthPalette.ink, size: 20),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;

  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
