import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:budget_manager/services/auth_service.dart';
import 'package:budget_manager/services/transaction_service.dart';
import 'package:budget_manager/models/transaction.dart' as budget_transaction;
import 'package:budget_manager/screens/transactions_screen.dart';
import 'package:budget_manager/screens/search_screen.dart';

import 'package:budget_manager/widgets/balance_card.dart';
import 'package:budget_manager/widgets/transaction_item.dart';
import 'package:budget_manager/widgets/category_chip.dart';
import 'package:budget_manager/widgets/auth/soft_card.dart';
import 'package:budget_manager/theme/auth_palette.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double monthlyBudget = 20000.00; // Fetch from Firestore if stored
  List<budget_transaction.Transaction> recentTransactions = [];

  double _bottomNavSpace(BuildContext context) {
    // Your nav bar: height 72 + bottom padding 14 + some breathing space
    final safe = MediaQuery.of(context).padding.bottom;
    return safe + 72 + 24;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final transactionService =
          Provider.of<TransactionService>(context, listen: false);
      if (authService.currentUser != null) {
        transactionService.fetchTransactions(authService.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        Provider.of<AuthService>(context).currentUser?.displayName ??
            'Utilisateur';

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _HomeHeroHeader(
            name: displayName,
            onSearch: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            onNotifications: () {},
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 28 + _bottomNavSpace(context)),
            child: Consumer<TransactionService>(
              builder: (context, transactionService, child) {
                final transactions = transactionService.transactions;

                final totalIncome = transactions
                    .where((t) => !t.isExpense)
                    .fold(0.0, (sum, t) => sum + t.amount);

                final totalExpense = transactions
                    .where((t) => t.isExpense)
                    .fold(0.0, (sum, t) => sum + t.amount);

                final totalBalance = totalIncome - totalExpense;

                // Category expenses
                final categoryExpenses = <String, double>{};
                for (var t in transactions.where((t) => t.isExpense)) {
                  categoryExpenses[t.category] =
                      (categoryExpenses[t.category] ?? 0) + t.amount;
                }

                // Recent transactions (last 30 days)
                recentTransactions = transactions
                    .where((t) => t.date.isAfter(
                        DateTime.now().subtract(const Duration(days: 30))))
                    .toList()
                  ..sort((a, b) => b.date.compareTo(a.date));
                recentTransactions = recentTransactions.take(5).toList();

                return Column(
                  children: [
                    BalanceCard(
                      totalBalance: totalBalance,
                      totalExpense: totalExpense,
                      monthlyBudget: monthlyBudget,
                      expensePercentage: ((totalExpense / monthlyBudget * 100)
                              .clamp(0.0, 100.0))
                          .toInt(),
                    ),
                    const SizedBox(height: 18),

                    _SectionTitle(
                      title: 'Aperçu',
                      trailing: const _Pill(label: 'Aujourd\'hui'),
                      onTapTrailing: () {},
                    ),
                    const SizedBox(height: 10),
                    _buildQuickStats(context, totalIncome, totalExpense),
                    const SizedBox(height: 18),

                    _SectionTitle(title: 'Catégories Populaires'),
                    const SizedBox(height: 10),
                    _buildCategoriesSection(context, categoryExpenses),
                    const SizedBox(height: 18),

                    _SectionTitle(
                      title: 'Transactions Récentes',
                      trailing: const _Pill(label: 'Tout voir'),
                      onTapTrailing: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TransactionsScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildRecentTransactions(context),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(
      BuildContext context, double totalIncome, double totalExpense) {
    final weeklyIncome = totalIncome * 7 / 30; // Approximate weekly
    final weeklyExpense = totalExpense * 7 / 30;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Revenu Hebdo',
            value: '\$${weeklyIncome.toStringAsFixed(2)}',
            chip: '+12%',
            chipColor: const Color(0xFF22C55E),
            icon: Icons.arrow_upward_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Dépenses Hebdo',
            value: '\$${weeklyExpense.toStringAsFixed(2)}',
            chip: '-5%',
            chipColor: const Color(0xFFEF4444),
            icon: Icons.arrow_downward_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(
      BuildContext context, Map<String, double> categoryExpenses) {
    final topCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (topCategories.isEmpty) {
      return SoftCard(
        child: Row(
          children: const [
            Icon(Icons.auto_awesome_rounded, color: AuthPalette.ink),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ajoutez quelques transactions pour voir vos catégories ici.',
                style: TextStyle(
                  color: AuthPalette.inkSoft,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topCategories.length.clamp(0, 8),
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final entry = topCategories[i];
          return CategoryChip(
            icon: _getIconForCategory(entry.key),
            label: entry.key,
            amount: entry.value,
            color: _getColorForCategory(entry.key),
          );
        },
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    if (recentTransactions.isEmpty) {
      return SoftCard(
        child: Row(
          children: const [
            Icon(Icons.receipt_long_rounded, color: AuthPalette.ink),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Aucune transaction récente. Ajoutez-en une pour commencer.',
                style: TextStyle(
                  color: AuthPalette.inkSoft,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: recentTransactions.map((transaction) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TransactionItem(
            title: transaction.title,
            subtitle:
                '${transaction.date.day}/${transaction.date.month} • ${transaction.category}',
            category: transaction.category,
            amount: transaction.amount,
            isExpense: transaction.isExpense,
            icon: _getIconForCategory(transaction.category),
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'salaire':
      case 'income':
        return Icons.account_balance_wallet_outlined;
      case 'alimentation':
      case 'food':
        return Icons.shopping_cart_outlined;
      case 'loyer':
      case 'rent':
        return Icons.home_outlined;
      case 'transport':
        return Icons.directions_car_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'travail':
      case 'work':
        return Icons.computer_outlined;
      case 'divertissement':
      case 'entertainment':
        return Icons.movie_outlined;
      default:
        return Icons.attach_money_outlined;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'alimentation':
      case 'food':
        return AuthPalette.tangerine;
      case 'transport':
        return AuthPalette.sea;
      case 'shopping':
        return AuthPalette.violet;
      case 'santé':
      case 'health':
        return AuthPalette.mint;
      default:
        return AuthPalette.lavender;
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onTapTrailing;

  const _SectionTitle({
    required this.title,
    this.trailing,
    this.onTapTrailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AuthPalette.ink,
                fontWeight: FontWeight.w900,
              ),
        ),
        const Spacer(),
        if (trailing != null)
          GestureDetector(
            onTap: onTapTrailing,
            child: trailing!,
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String chip;
  final Color chipColor;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.chip,
    required this.chipColor,
    required this.icon,
  });

  Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _a(chipColor, 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: chipColor, size: 18),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _a(Colors.white, 0.45),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _a(Colors.white, 0.35)),
                ),
                child: Text(
                  chip,
                  style: const TextStyle(
                    color: AuthPalette.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AuthPalette.inkSoft,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AuthPalette.ink,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill({required this.label});

  Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _a(Colors.white, 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _a(Colors.white, 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AuthPalette.ink,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _HomeHeroHeader extends StatelessWidget {
  final String name;
  final VoidCallback onSearch;
  final VoidCallback onNotifications;

  const _HomeHeroHeader({
    required this.name,
    required this.onSearch,
    required this.onNotifications,
  });

  Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final headerHeight = (h * 0.25).clamp(180.0, 230.0);

    return SizedBox(
      height: headerHeight,
      child: Stack(
        children: [
          Positioned(
            left: -80,
            top: -70,
            child: _Blob(color: _a(Colors.white, 0.20), size: 220),
          ),
          Positioned(
            right: -70,
            top: 30,
            child: _Blob(color: _a(Colors.white, 0.16), size: 200),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Budget Manager',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AuthPalette.ink,
                                  fontWeight: FontWeight.w900,
                                ),
                      ),
                      const Spacer(),
                      _RoundIconButton(
                        icon: Icons.notifications_outlined,
                        onTap: onNotifications,
                      ),
                      const SizedBox(width: 10),
                      _RoundIconButton(
                        icon: Icons.search,
                        onTap: onSearch,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bonjour, $name',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: AuthPalette.inkSoft,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Gérez vos dépenses\naisément',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: AuthPalette.ink,
                                    fontWeight: FontWeight.w900,
                                    height: 1.05,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const _MiniMascot(),
                    ],
                  ),
                ],
              ),
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
        customBorder: const CircleBorder(),
        onTap: onTap,
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
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MiniMascot extends StatelessWidget {
  const _MiniMascot();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 78,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AuthPalette.tangerine,
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),
          const Positioned(left: 16, top: 22, child: _Eye()),
          const Positioned(right: 16, top: 22, child: _Eye()),
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            child: Center(
              child: Container(
                width: 34,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Container(
                    width: 18,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
