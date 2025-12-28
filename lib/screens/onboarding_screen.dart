import 'package:flutter/material.dart';

import 'package:budget_manager/screens/login_screen.dart';
import 'package:budget_manager/theme/auth_palette.dart';
import 'package:budget_manager/widgets/auth/auth_background.dart';
import 'package:budget_manager/widgets/auth/monster_hero.dart';
import 'package:budget_manager/widgets/auth/pill_chip.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      monsterColor: AuthPalette.tangerine,
      mood: MonsterMood.happy,
      headline: "WHAT'S YOUR\nBUDGET LIKE\nTODAY",
      subline: "Suivez vos dépenses en un coup d'œil.",
      chips: ["Spending", "Savings", "Goals", "Calm"],
    ),
    _OnboardingPage(
      monsterColor: AuthPalette.mint,
      mood: MonsterMood.focused,
      headline: "MAKE IT\nSIMPLE",
      subline: "Catégorisez, planifiez, et gardez le contrôle.",
      chips: ["Categories", "Trends", "Alerts", "Smart"],
    ),
    _OnboardingPage(
      monsterColor: AuthPalette.violet,
      mood: MonsterMood.calm,
      headline: "INSIGHTS\nTHAT FEEL\nHUMAN",
      subline: "Des conseils IA, sans prise de tête.",
      chips: ["AI Tips", "Recaps", "Budget", "Peace"],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final gradient = AuthPalette.onboardingGradient(_page);

    return AuthBackground(
      gradient: gradient,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Budget Manager',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AuthPalette.ink,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const Spacer(),
                _CircleIconButton(
                  icon: Icons.apps_rounded,
                  onTap: _skipToEnd,
                ),
              ],
            ),
          ),

          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, index) {
                final p = _pages[index];
                // IMPORTANT: The yellow/black stripe you saw is Flutter's
                // "RenderFlex overflow" debug warning. It happens when the
                // Column below is taller than the available height on some
                // screens (smaller devices / larger font scale).
                //
                // We make the layout responsive and scroll-safe.
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final maxH = constraints.maxHeight;
                    final heroSize = (maxH * 0.42).clamp(220.0, 320.0);
                    final headlineFont = (maxH * 0.10).clamp(34.0, 54.0);

                    return SingleChildScrollView(
                      // If everything fits, this won't scroll; if not, it
                      // prevents overflow on smaller heights.
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: maxH),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              MonsterHero(
                                bodyColor: p.monsterColor,
                                mood: p.mood,
                                size: heroSize,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                p.headline,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                      fontSize: headlineFont,
                                      color: AuthPalette.cloud,
                                      fontWeight: FontWeight.w900,
                                      height: 0.95,
                                      letterSpacing: -0.8,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.10),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        )
                                      ],
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _prettyDate(DateTime.now()),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AuthPalette.cloud.withOpacity(0.95),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                p.subline,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AuthPalette.ink,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 22),
                              _chipsRow(index),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
            child: Column(
              children: [
                _pageIndicator(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    TextButton(
                      onPressed: _goToLogin,
                      child: Text(
                        'Se connecter',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AuthPalette.ink,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    const Spacer(),
                    _PrimaryPillButton(
                      label: _page == _pages.length - 1 ? 'Commencer' : 'Suivant',
                      onTap: _page == _pages.length - 1 ? _goToLogin : _next,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipsRow(int index) {
    final palette = AuthPalette.chipPalettes[index % AuthPalette.chipPalettes.length];
    final chips = _pages[index].chips;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: List.generate(chips.length, (i) {
        return PillChip(
          label: chips[i],
          color: palette[i % palette.length],
          onTap: () {},
        );
      }),
    );
  }

  Widget _pageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (i) {
        final active = i == _page;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: active ? 26 : 8,
          decoration: BoxDecoration(
            color: active
                ? AuthPalette.ink.withOpacity(0.85)
                : AuthPalette.cloud.withOpacity(0.55),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }

  void _next() {
    final next = (_page + 1).clamp(0, _pages.length - 1);
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
    setState(() => _page = next);
  }

  void _skipToEnd() {
    _controller.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _OnboardingPage {
  final Color monsterColor;
  final MonsterMood mood;
  final String headline;
  final String subline;
  final List<String> chips;

  const _OnboardingPage({
    required this.monsterColor,
    required this.mood,
    required this.headline,
    required this.subline,
    required this.chips,
  });
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

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

class _PrimaryPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryPillButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AuthPalette.ink,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AuthPalette.cloud,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: AuthPalette.cloud, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

String _prettyDate(DateTime d) {
  const months = [
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
  ];
  final m = months[(d.month - 1).clamp(0, 11)];
  return '${d.day} $m';
}
