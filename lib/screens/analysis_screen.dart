import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:budget_manager/theme/app_theme.dart';
import 'package:budget_manager/theme/auth_palette.dart';
import 'package:budget_manager/services/transaction_service.dart';
import 'package:budget_manager/models/transaction.dart' as budget_transaction;

// ✅ Update this import path to where AIChatDialog actually is
import 'package:budget_manager/widgets/ai_chat_dialog.dart';

enum _Period { daily, weekly, monthly, yearly }

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  _Period _period = _Period.monthly;

  static Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  void _showAIChat() {
    showDialog(
      context: context,
      barrierColor: _a(Colors.black, 0.25),
      builder: (_) => const AIChatDialog(),
    );
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: _a(Colors.black, 0.18),
      builder: (_) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
              decoration: BoxDecoration(
                color: _a(Colors.white, 0.80),
                border: Border.all(color: _a(Colors.white, 0.60)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: _a(Colors.black, 0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Filtres (à venir)",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AuthPalette.ink,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Tu peux ajouter ici des filtres par catégorie, date, type, etc.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AuthPalette.inkSoft,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AuthPalette.ink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("OK"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  DateTime _startForPeriod(_Period p) {
    final now = DateTime.now();
    switch (p) {
      case _Period.daily:
        return DateTime(now.year, now.month, now.day);
      case _Period.weekly:
        final weekday = now.weekday; // 1=Mon..7=Sun
        return DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: weekday - 1));
      case _Period.monthly:
        return DateTime(now.year, now.month, 1);
      case _Period.yearly:
        return DateTime(now.year, 1, 1);
    }
  }

  String _labelForPeriod(_Period p) {
    switch (p) {
      case _Period.daily:
        return "Quotidien";
      case _Period.weekly:
        return "Hebdomadaire";
      case _Period.monthly:
        return "Mensuel";
      case _Period.yearly:
        return "Annuel";
    }
  }

  @override
  Widget build(BuildContext context) {
    final txService = Provider.of<TransactionService>(context);
    final all = txService.transactions;

    final start = _startForPeriod(_period);
    final filtered = all
        .where((t) =>
            t.date.isAfter(start) || t.date.isAtSameMomentAs(start))
        .toList();

    final totalIncome =
        filtered.where((t) => !t.isExpense).fold<double>(0, (s, t) => s + t.amount);
    final totalExpense =
        filtered.where((t) => t.isExpense).fold<double>(0, (s, t) => s + t.amount);
    final balance = totalIncome - totalExpense;

    // placeholders (you can compute real trend later)
    final expenseTrend = totalExpense == 0 ? 0.0 : -5.2;
    final balanceTrend = (totalIncome == 0 && totalExpense == 0) ? 0.0 : 0.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAIChat,
        backgroundColor: AuthPalette.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        child: const _AiBlobFabIcon(),
      ),

      // ✅ FIX #1: Scaffold has NO child, it must be body:
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            title: Text(
              "Analyse Financière",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AuthPalette.ink,
                  ),
            ),
            actions: [
              IconButton(
                onPressed: _openFilter,
                icon: const Icon(Icons.filter_alt_outlined),
                color: AuthPalette.ink,
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: _PeriodTabs(
                value: _period,
                onChanged: (p) => setState(() => _period = p),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: "Solde Total",
                      value: "\$${balance.toStringAsFixed(2)}",
                      trendText: balanceTrend >= 0
                          ? "+${balanceTrend.toStringAsFixed(1)}%"
                          : "${balanceTrend.toStringAsFixed(1)}%",
                      trendPositive: balanceTrend >= 0,
                      icon: Icons.account_balance_wallet_outlined,
                      tint: AuthPalette.lavender,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: "Dépenses Totales",
                      value: "\$${totalExpense.toStringAsFixed(2)}",
                      trendText: "${expenseTrend.toStringAsFixed(1)}%",
                      trendPositive: expenseTrend >= 0,
                      icon: Icons.trending_down_rounded,
                      tint: AuthPalette.peach,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Revenus & Dépenses",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AuthPalette.ink,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _ChartPlaceholder(
                      periodLabel: _labelForPeriod(_period),
                      transactions: filtered,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
              child: _Card(
                child: Column(
                  children: [
                    Text(
                      "Mes Objectifs",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AuthPalette.ink,
                          ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Ajout d’objectif (à connecter)"),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text("Ajouter un objectif"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AuthPalette.tangerine,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
    );
  }
}

/* -------------------------- Widgets -------------------------- */

class _PeriodTabs extends StatelessWidget {
  final _Period value;
  final ValueChanged<_Period> onChanged;

  const _PeriodTabs({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _TabPill(
              label: "Quotidien",
              selected: value == _Period.daily,
              onTap: () => onChanged(_Period.daily),
            ),
          ),
          Expanded(
            child: _TabPill(
              label: "Hebdomadaire",
              selected: value == _Period.weekly,
              onTap: () => onChanged(_Period.weekly),
            ),
          ),
          Expanded(
            child: _TabPill(
              label: "Mensuel",
              selected: value == _Period.monthly,
              onTap: () => onChanged(_Period.monthly),
            ),
          ),
          Expanded(
            child: _TabPill(
              label: "Annuel",
              selected: value == _Period.yearly,
              onTap: () => onChanged(_Period.yearly),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _a(Colors.white, 0.85) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _a(Colors.white, 0.70) : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: AuthPalette.ink,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trendText;
  final bool trendPositive;
  final IconData icon;
  final Color tint;

  const _StatCard({
    required this.title,
    required this.value,
    required this.trendText,
    required this.trendPositive,
    required this.icon,
    required this.tint,
  });

  static Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _a(tint, 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AuthPalette.ink, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AuthPalette.inkSoft,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: trendPositive
                            ? _a(const Color(0xFF22C55E), 0.16)
                            : _a(const Color(0xFFEF4444), 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        trendText,
                        style: TextStyle(
                          color: trendPositive
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFEF4444),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AuthPalette.ink,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  final String periodLabel;
  final List<budget_transaction.Transaction> transactions;

  const _ChartPlaceholder({
    required this.periodLabel,
    required this.transactions,
  });

  static Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _a(Colors.black, 0.03),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
          transactions.isEmpty
              ? "Aucune donnée pour $periodLabel.\nAjoute des transactions pour voir le graphique."
              : "Graphique ($periodLabel)\n✅ Ici tu peux brancher Syncfusion / chart",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AuthPalette.inkSoft,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  static Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: _a(Colors.white, 0.62),
            border: Border.all(color: _a(Colors.white, 0.55)),
            boxShadow: AppTheme.subtleShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AiBlobFabIcon extends StatelessWidget {
  const _AiBlobFabIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AuthPalette.lavender.withAlpha(242),
                  AuthPalette.peach.withAlpha(242),
                  AuthPalette.lemon.withAlpha(235),
                  AuthPalette.mint.withAlpha(235),
                ],
              ),
            ),
          ),
          Positioned(
            top: 11,
            left: 9,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 11,
            right: 9,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
