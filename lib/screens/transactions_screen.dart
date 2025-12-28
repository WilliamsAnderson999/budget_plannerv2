import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:budget_manager/widgets/transaction_item.dart';
import 'package:budget_manager/theme/auth_palette.dart';
import 'package:budget_manager/services/auth_service.dart';
import 'package:budget_manager/services/transaction_service.dart';
import 'package:budget_manager/models/transaction.dart' as budget_transaction;

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const Center(
        child: Text(
          'User not logged in',
          style: TextStyle(color: AuthPalette.ink),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            title: Text(
              'Transactions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AuthPalette.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: isSmallScreen ? 20 : 22,
                  ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: () {},
                color: AuthPalette.ink,
              ),
              IconButton(
                icon: const Icon(Icons.sort_rounded),
                onPressed: () {},
                color: AuthPalette.ink,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Consumer<TransactionService>(
              builder: (context, transactionService, child) => Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16.0),
                child: Column(
                  children: [
                    _buildQuickFilters(context),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    ..._buildTransactionList(
                        context, authService, transactionService),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    final filters = [
      {'label': 'Tout', 'active': true},
      {'label': 'Revenus', 'active': false},
      {'label': 'Dépenses', 'active': false},
      {'label': 'Cette semaine', 'active': false},
      {'label': 'Ce mois', 'active': false},
    ];

    return SizedBox(
      height: isSmallScreen ? 44 : 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = filter['active'] as bool;

          return ChoiceChip(
            label: Text(filter['label'] as String),
            selected: selected,
            onSelected: (_) {},
            labelStyle: TextStyle(
              color: selected ? Colors.white : AuthPalette.ink,
              fontWeight: FontWeight.w900,
              fontSize: isSmallScreen ? 12 : 13,
            ),
            backgroundColor: Colors.white.withOpacity(0.55),
            selectedColor: AuthPalette.ink,
            shape: StadiumBorder(
              side: BorderSide(color: Colors.white.withOpacity(0.38)),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }

  List<Widget> _buildTransactionList(BuildContext context,
      AuthService authService, TransactionService transactionService) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    final transactions = transactionService.transactions;

    final groupedTransactions =
        _groupTransactionsByDate(transactions.reversed.toList());

    return groupedTransactions.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 14),
            child: Text(
              entry.key,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AuthPalette.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: isSmallScreen ? 16 : 18,
                  ),
            ),
          ),
          ...entry.value.map((transaction) {
            return Padding(
              padding: EdgeInsets.only(bottom: isSmallScreen ? 8 : 10),
              child: TransactionItem(
                title: transaction.title,
                subtitle:
                    '${transaction.date.day}/${transaction.date.month} • ${transaction.category}',
                category: transaction.category,
                amount: transaction.amount,
                isExpense: transaction.isExpense,
                icon: _getIconForCategory(transaction.category),
                onTap: () {},
              ),
            );
          }),
        ],
      );
    }).toList();
  }

  Map<String, List<budget_transaction.Transaction>> _groupTransactionsByDate(
      List<budget_transaction.Transaction> transactions) {
    final grouped = <String, List<budget_transaction.Transaction>>{};
    for (var t in transactions) {
      final key = '${t.date.day}/${t.date.month}/${t.date.year}';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(t);
    }
    return grouped;
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
}
