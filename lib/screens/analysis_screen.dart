import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import 'package:budget_manager/theme/app_theme.dart';
import 'package:budget_manager/theme/auth_palette.dart';
import 'package:budget_manager/services/transaction_service.dart';
import 'package:budget_manager/services/firestore_service.dart';
import 'package:budget_manager/services/auth_service.dart';
import 'package:budget_manager/models/transaction.dart' as budget_transaction;
import 'package:budget_manager/models/goal.dart';

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
  List<Goal> _goals = [];
  String? _selectedCategory;
  bool _showIncome = true;
  bool _showExpense = true;

  static Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);

    final user = authService.currentUser;
    if (user != null) {
      try {
        final goals = await firestoreService.getGoals(user.uid);
        if (mounted) {
          setState(() => _goals = goals);
        }
      } catch (e) {
        // Handle error silently
      }
    }
  }

  void _showAIChat() {
    showDialog(
      context: context,
      barrierColor: _a(Colors.black, 0.25),
      builder: (_) => const AIChatDialog(),
    );
  }

  void _openFilter() {
    final transactionService =
        Provider.of<TransactionService>(context, listen: false);
    final categories = transactionService.categoryTotals.keys.toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: _a(Colors.black, 0.18),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
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
                        "Filtres",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AuthPalette.ink,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Catégorie filter
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Catégorie",
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AuthPalette.ink,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String?>(
                        value: _selectedCategory,
                        hint: const Text("Toutes les catégories"),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text("Toutes les catégories"),
                          ),
                          ...categories.map((category) {
                            return DropdownMenuItem<String?>(
                              value: category,
                              child: Text(category),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                          this.setState(() => _selectedCategory = value);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Type filter
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Type de transaction",
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AuthPalette.ink,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text("Revenus"),
                              value: _showIncome,
                              onChanged: (value) {
                                setState(() => _showIncome = value ?? true);
                                this.setState(
                                    () => _showIncome = value ?? true);
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text("Dépenses"),
                              value: _showExpense,
                              onChanged: (value) {
                                setState(() => _showExpense = value ?? true);
                                this.setState(
                                    () => _showExpense = value ?? true);
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = null;
                                  _showIncome = true;
                                  _showExpense = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text("Réinitialiser"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AuthPalette.ink,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text("Appliquer"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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

  Map<String, double> _calculatePreviousPeriodData(
      List<budget_transaction.Transaction> all, _Period period) {
    DateTime now = DateTime.now();
    DateTime previousStart;
    DateTime previousEnd;

    switch (period) {
      case _Period.daily:
        previousStart = now.subtract(const Duration(days: 1));
        previousEnd = previousStart.add(const Duration(days: 1));
        break;
      case _Period.weekly:
        final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
        previousStart = currentWeekStart.subtract(const Duration(days: 7));
        previousEnd = previousStart.add(const Duration(days: 7));
        break;
      case _Period.monthly:
        previousStart = DateTime(now.year, now.month - 1, 1);
        previousEnd = DateTime(now.year, now.month, 1);
        break;
      case _Period.yearly:
        previousStart = DateTime(now.year - 1, 1, 1);
        previousEnd = DateTime(now.year, 1, 1);
        break;
    }

    final previousTransactions = all
        .where((t) =>
            t.date.isAfter(previousStart) && t.date.isBefore(previousEnd))
        .toList();

    final previousExpense = previousTransactions
        .where((t) => t.isExpense)
        .fold<double>(0, (s, t) => s + t.amount);

    final previousIncome = previousTransactions
        .where((t) => !t.isExpense)
        .fold<double>(0, (s, t) => s + t.amount);

    return {
      'expense': previousExpense,
      'income': previousIncome,
      'balance': previousIncome - previousExpense,
    };
  }

  double _calculateTrend(double current, double previous) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100;
  }

  Future<void> _showAddGoalDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            "Nouvel objectif",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AuthPalette.ink,
                ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nom de l'objectif",
                  hintText: "Ex: Voiture neuve, Vacances...",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetController,
                decoration: const InputDecoration(
                  labelText: "Montant cible (\$)",
                  hintText: "Ex: 5000",
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    "Échéance: ${selectedDate != null ? selectedDate!.toLocal().toString().split(' ')[0] : 'Optionnel'}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: const Text("Choisir une date"),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final targetAmount = double.tryParse(targetController.text);

                if (name.isEmpty || targetAmount == null || targetAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            "Veuillez remplir tous les champs correctement")),
                  );
                  return;
                }

                try {
                  final authService =
                      Provider.of<AuthService>(context, listen: false);
                  final firestoreService =
                      Provider.of<FirestoreService>(context, listen: false);
                  final user = authService.currentUser;

                  if (user != null) {
                    final goal = Goal(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: user.uid,
                      name: name,
                      targetAmount: targetAmount,
                      currentAmount: 0,
                      createdAt: DateTime.now(),
                      deadline: selectedDate,
                    );

                    await firestoreService.addGoal(goal);
                    await _loadGoals();

                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text("Objectif '$name' ajouté avec succès !")),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erreur lors de l'ajout: $e")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AuthPalette.tangerine,
                foregroundColor: Colors.white,
              ),
              child: const Text("Ajouter"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txService = Provider.of<TransactionService>(context);
    final all = txService.transactions;

    final start = _startForPeriod(_period);
    var filtered = all
        .where((t) => t.date.isAfter(start) || t.date.isAtSameMomentAs(start))
        .toList();

    // Apply filters
    if (_selectedCategory != null) {
      filtered =
          filtered.where((t) => t.category == _selectedCategory).toList();
    }

    if (!_showIncome) {
      filtered = filtered.where((t) => t.isExpense).toList();
    }

    if (!_showExpense) {
      filtered = filtered.where((t) => !t.isExpense).toList();
    }

    final totalIncome = filtered
        .where((t) => !t.isExpense)
        .fold<double>(0, (s, t) => s + t.amount);
    final totalExpense = filtered
        .where((t) => t.isExpense)
        .fold<double>(0, (s, t) => s + t.amount);
    final balance = totalIncome - totalExpense;

    // Calculate real trends by comparing with previous period
    final previousPeriodData = _calculatePreviousPeriodData(all, _period);
    final expenseTrend =
        _calculateTrend(totalExpense, previousPeriodData['expense'] ?? 0);
    final balanceTrend =
        _calculateTrend(balance, previousPeriodData['balance'] ?? 0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAIChat,
        backgroundColor: AuthPalette.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        child: const _AiBlobFabIcon(),
        heroTag: "analysis_ai_fab",
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
                      tint: AuthPalette.tangerine,
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
                      tint: AuthPalette.mint,
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
                    _RevenueExpenseChart(
                      period: _period,
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
                        onPressed: () => _showAddGoalDialog(context),
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
                    const SizedBox(height: 16),
                    if (_goals.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "Aucun objectif défini.\nAjoute ton premier objectif pour commencer à épargner !",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AuthPalette.inkSoft,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      )
                    else
                      ..._goals.map((goal) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _GoalCard(goal: goal, onUpdate: _loadGoals),
                          )),
                  ],
                ),
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
                      "Répartition par Catégories",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AuthPalette.ink,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _CategoryPieChart(transactions: filtered),
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

class _RevenueExpenseChart extends StatelessWidget {
  final _Period period;
  final List<budget_transaction.Transaction> transactions;

  const _RevenueExpenseChart({
    required this.period,
    required this.transactions,
  });

  static Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  List<_ChartData> _prepareChartData() {
    if (transactions.isEmpty) return [];

    final Map<String, Map<String, double>> groupedData = {};

    for (var transaction in transactions) {
      String key;
      switch (period) {
        case _Period.daily:
          key = '${transaction.date.day}/${transaction.date.month}';
          break;
        case _Period.weekly:
          final weekStart = transaction.date
              .subtract(Duration(days: transaction.date.weekday - 1));
          key = '${weekStart.day}/${weekStart.month}';
          break;
        case _Period.monthly:
          key = '${transaction.date.month}/${transaction.date.year}';
          break;
        case _Period.yearly:
          key = '${transaction.date.year}';
          break;
      }

      if (!groupedData.containsKey(key)) {
        groupedData[key] = {'income': 0, 'expense': 0};
      }

      if (transaction.isExpense) {
        groupedData[key]!['expense'] =
            groupedData[key]!['expense']! + transaction.amount;
      } else {
        groupedData[key]!['income'] =
            groupedData[key]!['income']! + transaction.amount;
      }
    }

    return groupedData.entries.map((entry) {
      return _ChartData(
        label: entry.key,
        income: entry.value['income']!,
        expense: entry.value['expense']!,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareChartData();

    if (chartData.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _a(Colors.black, 0.03),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            "Aucune donnée disponible.\nAjoute des transactions pour voir le graphique.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AuthPalette.inkSoft,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      );
    }

    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _a(Colors.white, 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _a(Colors.white, 0.6)),
      ),
      child: SfCartesianChart(
        margin: const EdgeInsets.all(16),
        primaryXAxis: CategoryAxis(
          labelStyle:
              TextStyle(color: AuthPalette.ink, fontWeight: FontWeight.w600),
          axisLine: AxisLine(color: _a(AuthPalette.ink, 0.3)),
          majorGridLines: MajorGridLines(color: _a(AuthPalette.ink, 0.1)),
        ),
        primaryYAxis: NumericAxis(
          labelStyle:
              TextStyle(color: AuthPalette.ink, fontWeight: FontWeight.w600),
          axisLine: AxisLine(color: _a(AuthPalette.ink, 0.3)),
          majorGridLines: MajorGridLines(color: _a(AuthPalette.ink, 0.1)),
          numberFormat: NumberFormat('\$#,##0'),
        ),
        legend: Legend(
          isVisible: true,
          position: LegendPosition.top,
          textStyle:
              TextStyle(color: AuthPalette.ink, fontWeight: FontWeight.w600),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'point.x : \$point.y',
          textStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          color: AuthPalette.ink,
        ),
        series: <CartesianSeries<_ChartData, String>>[
          ColumnSeries<_ChartData, String>(
            dataSource: chartData,
            xValueMapper: (_ChartData data, _) => data.label,
            yValueMapper: (_ChartData data, _) => data.income,
            name: 'Revenus',
            color: AppTheme.incomeColor,
            borderRadius: BorderRadius.circular(4),
          ),
          ColumnSeries<_ChartData, String>(
            dataSource: chartData,
            xValueMapper: (_ChartData data, _) => data.label,
            yValueMapper: (_ChartData data, _) => data.expense,
            name: 'Dépenses',
            color: AppTheme.expenseColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  final String label;
  final double income;
  final double expense;

  _ChartData({
    required this.label,
    required this.income,
    required this.expense,
  });
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onUpdate;

  const _GoalCard({
    required this.goal,
    required this.onUpdate,
  });

  static Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  @override
  Widget build(BuildContext context) {
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final remaining = goal.targetAmount - goal.currentAmount;
    final isCompleted = goal.currentAmount >= goal.targetAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _a(Colors.white, 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _a(Colors.white, 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AuthPalette.ink,
                      ),
                ),
              ),
              if (isCompleted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _a(const Color(0xFF22C55E), 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Terminé",
                    style: TextStyle(
                      color: const Color(0xFF16A34A),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "\$${goal.currentAmount.toStringAsFixed(2)} / \$${goal.targetAmount.toStringAsFixed(2)}",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AuthPalette.inkSoft,
                ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: _a(Colors.grey, 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? const Color(0xFF22C55E) : AuthPalette.tangerine,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${(progress * 100).toStringAsFixed(1)}% terminé",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AuthPalette.inkSoft,
                    ),
              ),
              if (remaining > 0)
                Text(
                  "\$${remaining.toStringAsFixed(2)} restant",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AuthPalette.inkSoft,
                      ),
                ),
            ],
          ),
          if (goal.deadline != null) ...[
            const SizedBox(height: 8),
            Text(
              "Échéance: ${goal.deadline!.toLocal().toString().split(' ')[0]}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AuthPalette.inkSoft,
                  ),
            ),
          ],
        ],
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
              color: Colors.black,
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

class _CategoryPieChart extends StatelessWidget {
  final List<budget_transaction.Transaction> transactions;

  const _CategoryPieChart({required this.transactions});

  static Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  List<_PieData> _preparePieData() {
    final Map<String, double> categoryTotals = {};
    for (var t in transactions.where((t) => t.isExpense)) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }

    final colors = [
      AuthPalette.tangerine,
      AuthPalette.mint,
      AuthPalette.violet,
      AuthPalette.peach,
      AuthPalette.lemon,
      AuthPalette.sea
    ];
    int colorIndex = 0;

    return categoryTotals.entries.map((entry) {
      return _PieData(
        category: entry.key,
        amount: entry.value,
        color: colors[colorIndex++ % colors.length],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pieData = _preparePieData();

    if (pieData.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _a(Colors.black, 0.03),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            "Aucune dépense à afficher.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AuthPalette.inkSoft,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _a(Colors.white, 0.8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _a(Colors.white, 0.6)),
          ),
          child: SfCircularChart(
            margin: const EdgeInsets.all(16),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              textStyle: TextStyle(
                  color: AuthPalette.ink, fontWeight: FontWeight.w600),
              overflowMode: LegendItemOverflowMode.wrap,
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              format: 'point.x : \$point.y',
              textStyle:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              color: AuthPalette.ink,
            ),
            series: <CircularSeries<_PieData, String>>[
              PieSeries<_PieData, String>(
                dataSource: pieData,
                xValueMapper: (_PieData data, _) => data.category,
                yValueMapper: (_PieData data, _) => data.amount,
                pointColorMapper: (_PieData data, _) => data.color,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                  labelPosition: ChartDataLabelPosition.outside,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _CategorySquares(transactions: transactions),
      ],
    );
  }
}

class _PieData {
  final String category;
  final double amount;
  final Color color;

  _PieData({required this.category, required this.amount, required this.color});
}

class _CategorySquares extends StatelessWidget {
  final List<budget_transaction.Transaction> transactions;

  const _CategorySquares({required this.transactions});

  static Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  List<_CategoryData> _prepareCategoryData() {
    final Map<String, double> categoryTotals = {};
    for (var t in transactions.where((t) => t.isExpense)) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }

    final colors = [
      AuthPalette.tangerine,
      AuthPalette.mint,
      AuthPalette.violet,
      AuthPalette.peach,
      AuthPalette.lemon,
      AuthPalette.sea
    ];
    int colorIndex = 0;

    return categoryTotals.entries.map((entry) {
      return _CategoryData(
        category: entry.key,
        amount: entry.value,
        color: colors[colorIndex++ % colors.length],
        icon: _getIconForCategory(entry.key),
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  static IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'alimentation':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'loisirs':
        return Icons.movie_rounded;
      case 'santé':
        return Icons.local_hospital_rounded;
      case 'éducation':
        return Icons.school_rounded;
      case 'logement':
        return Icons.home_rounded;
      case 'vêtements':
        return Icons.checkroom_rounded;
      case 'divers':
        return Icons.category_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryData = _prepareCategoryData();

    if (categoryData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categoryData.map((data) {
        return Container(
          width: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _a(data.color, 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _a(data.color, 0.3)),
            boxShadow: [
              BoxShadow(
                color: _a(Colors.black, 0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(data.icon, color: AuthPalette.ink, size: 24),
              const SizedBox(height: 8),
              Text(
                data.category,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AuthPalette.ink,
                      fontWeight: FontWeight.w800,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '\$${data.amount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AuthPalette.inkSoft,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryData {
  final String category;
  final double amount;
  final Color color;
  final IconData icon;

  _CategoryData({
    required this.category,
    required this.amount,
    required this.color,
    required this.icon,
  });
}
