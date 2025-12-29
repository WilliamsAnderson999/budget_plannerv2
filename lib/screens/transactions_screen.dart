import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:budget_manager/widgets/transaction_item.dart';
import 'package:budget_manager/theme/auth_palette.dart';
import 'package:budget_manager/services/auth_service.dart';
import 'package:budget_manager/services/transaction_service.dart';
import 'package:budget_manager/models/transaction.dart' as budget_transaction;

enum TransactionFilter { all, income, expense, thisWeek, thisMonth }

class TransactionsScreen extends StatefulWidget {
  final TransactionFilter? initialFilter;

  const TransactionsScreen({super.key, this.initialFilter});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionFilter _selectedFilter = TransactionFilter.all;

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      _selectedFilter = widget.initialFilter!;
    }
  }

  void _showTransactionDetails(budget_transaction.Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (transaction.isExpense
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF22C55E))
                          .withOpacity(0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: (transaction.isExpense
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF22C55E))
                              .withOpacity(0.25)),
                    ),
                    child: Icon(
                      _getIconForCategory(transaction.category),
                      color: AuthPalette.ink,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AuthPalette.ink,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        Text(
                          transaction.category,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AuthPalette.inkSoft,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${transaction.isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: transaction.isExpense
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF22C55E),
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Date',
                  '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}'),
              _buildDetailRow('Time',
                  '${transaction.date.hour}:${transaction.date.minute.toString().padLeft(2, '0')}'),
              if (transaction.description.isNotEmpty)
                _buildDetailRow('Description', transaction.description),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Fermer',
                    style: TextStyle(
                      color: AuthPalette.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AuthPalette.inkSoft,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AuthPalette.ink,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }

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
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background
      body: Stack(
        children: [
          // Fixed top gradient background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height / 3, // Top 1/3
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AuthPalette.mint, AuthPalette.violet],
                ),
              ),
            ),
          ),
          // Content
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
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
                child: Container(
                  color: const Color(0xFFF5F5F5), // Light gray for the rest
                  padding: EdgeInsets.fromLTRB(
                    isSmallScreen ? 12 : 16.0,
                    10,
                    isSmallScreen ? 12 : 16.0,
                    28 + _bottomNavSpace(context),
                  ),
                  child: Consumer<TransactionService>(
                    builder: (context, transactionService, child) => Column(
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
        ],
      ),
    );
  }

  Widget _buildQuickFilters(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    final filters = [
      {'label': 'Tout', 'filter': TransactionFilter.all},
      {'label': 'Revenus', 'filter': TransactionFilter.income},
      {'label': 'Dépenses', 'filter': TransactionFilter.expense},
      {'label': 'Cette semaine', 'filter': TransactionFilter.thisWeek},
      {'label': 'Ce mois', 'filter': TransactionFilter.thisMonth},
    ];

    return SizedBox(
      height: isSmallScreen ? 44 : 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = _selectedFilter == filter['filter'];

          return ChoiceChip(
            label: Text(filter['label'] as String),
            selected: selected,
            onSelected: (isSelected) {
              if (isSelected) {
                setState(() {
                  _selectedFilter = filter['filter'] as TransactionFilter;
                });
              }
            },
            labelStyle: TextStyle(
              color: selected ? Colors.white : AuthPalette.ink,
              fontWeight: FontWeight.w900,
              fontSize: isSmallScreen ? 12 : 13,
            ),
            // ignore: deprecated_member_use
            backgroundColor: Colors.white.withOpacity(0.55),
            selectedColor: AuthPalette.ink,
            shape: StadiumBorder(
              // ignore: deprecated_member_use
              side: BorderSide(color: Colors.white.withOpacity(0.38)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

    List<budget_transaction.Transaction> transactions =
        transactionService.transactions;

    // Apply filter
    transactions = _filterTransactions(transactions);

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
                onTap: () => _showTransactionDetails(transaction),
              ),
            );
          }),
        ],
      );
    }).toList();
  }

  List<budget_transaction.Transaction> _filterTransactions(
      List<budget_transaction.Transaction> transactions) {
    final now = DateTime.now();

    switch (_selectedFilter) {
      case TransactionFilter.income:
        return transactions.where((t) => !t.isExpense).toList();
      case TransactionFilter.expense:
        return transactions.where((t) => t.isExpense).toList();
      case TransactionFilter.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return transactions.where((t) {
          final date = DateTime(t.date.year, t.date.month, t.date.day);
          return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
              date.isBefore(weekEnd.add(const Duration(days: 1)));
        }).toList();
      case TransactionFilter.thisMonth:
        return transactions
            .where((t) => t.date.month == now.month && t.date.year == now.year)
            .toList();
      case TransactionFilter.all:
        return transactions;
    }
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

  double _bottomNavSpace(BuildContext context) {
    // Return additional bottom space, e.g., for a navigation bar height
    // Default to 0.0 if no bottom navigation is present
    return 0.0;
  }
}
