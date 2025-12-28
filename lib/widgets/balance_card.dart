import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:budget_manager/theme/auth_palette.dart';

class BalanceCard extends StatelessWidget {
  final double totalBalance;
  final double totalExpense;
  final double monthlyBudget;
  final int expensePercentage;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.totalExpense,
    required this.monthlyBudget,
    required this.expensePercentage,
  });

  static Color _alpha(Color c, double o) => c.withAlpha((o * 255).round());

  @override
  Widget build(BuildContext context) {
    final pct = (expensePercentage / 100).clamp(0.0, 1.0);

    final progressColor = expensePercentage >= 80
        ? const Color(0xFFEF4444)
        : expensePercentage >= 60
            ? const Color(0xFFF59E0B)
            : AuthPalette.ink;

    final onCard = AuthPalette.ink;
    final sub = _alpha(AuthPalette.inkSoft, 0.78);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          // ✅ FULL gradient fill (this fixes "not fully colored")
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AuthPalette.lavender,
                    AuthPalette.peach,
                    AuthPalette.lemon,
                    AuthPalette.mint, // ✅ added green
                  ],
                ),
              ),
            ),
          ),

          // Decorative blobs
          Positioned(
            left: -60,
            top: -70,
            child: _Blob(color: _alpha(Colors.white, 0.22), size: 180),
          ),
          Positioned(
            right: -70,
            top: 20,
            child: _Blob(color: _alpha(Colors.white, 0.18), size: 200),
          ),
          Positioned(
            right: 30,
            bottom: -90,
            child: _Blob(color: _alpha(Colors.white, 0.14), size: 220),
          ),

          // Glass overlay + content (slightly lighter so colors show more)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _alpha(Colors.white, 0.12),
              border: Border.all(color: _alpha(Colors.white, 0.28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Solde Total',
                      style: TextStyle(
                        color: sub,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    _RoundIconButton(
                      icon: Icons.grid_view_rounded,
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Big amount
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '\$${totalBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: onCard,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      height: 1.0,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Progress block
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Dépenses du mois',
                          style: TextStyle(
                            color: sub,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _alpha(Colors.white, 0.35),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _alpha(Colors.white, 0.35),
                            ),
                          ),
                          child: Text(
                            '$expensePercentage%',
                            style: const TextStyle(
                              color: AuthPalette.ink,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearPercentIndicator(
                        lineHeight: 12,
                        padding: EdgeInsets.zero,
                        percent: pct,
                        backgroundColor: _alpha(Colors.white, 0.40),
                        progressColor: progressColor,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${totalExpense.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AuthPalette.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Objectif: \$${monthlyBudget.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: sub,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Encouragement
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _alpha(Colors.white, 0.28),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _alpha(Colors.white, 0.30)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        expensePercentage >= 80
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_rounded,
                        color: onCard,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _message(expensePercentage),
                          style: const TextStyle(
                            color: AuthPalette.ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _message(int pct) {
    if (pct >= 80) return "Attention : vous approchez votre objectif mensuel.";
    if (pct >= 60) return "Vous gérez bien — gardez un œil sur les dépenses.";
    return "Super ! Vos dépenses sont sous contrôle. Continuez comme ça !";
    }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.45),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: AuthPalette.ink, size: 18),
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
