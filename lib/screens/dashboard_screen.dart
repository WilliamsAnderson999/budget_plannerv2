import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:budget_manager/theme/app_theme.dart';
import 'package:budget_manager/theme/auth_palette.dart';
import 'package:budget_manager/widgets/transaction_item.dart';
import 'package:provider/provider.dart';
import 'package:budget_manager/services/transaction_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final Map<DateTime, List<Map<String, dynamic>>> _transactionsByDay = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  void _populateTransactionsByDay(List transactions) {
    _transactionsByDay.clear();
    for (var transaction in transactions) {
      final date = DateTime(
          transaction.date.year, transaction.date.month, transaction.date.day);
      if (_transactionsByDay[date] == null) {
        _transactionsByDay[date] = [];
      }
      _transactionsByDay[date]!.add({
        'title': transaction.title,
        'subtitle':
            '${transaction.date.hour}:${transaction.date.minute.toString().padLeft(2, '0')} - ${transaction.category}',
        'category': transaction.category,
        'amount': transaction.amount,
        'isExpense': transaction.isExpense,
        'icon': _getIconForCategory(transaction.category),
      });
    }
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
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
                      color: (transaction['isExpense'] as bool
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF22C55E))
                          .withOpacity(0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: (transaction['isExpense'] as bool
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF22C55E))
                              .withOpacity(0.25)),
                    ),
                    child: Icon(
                      transaction['icon'] as IconData,
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
                          transaction['title'] as String,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AuthPalette.ink,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        Text(
                          transaction['category'] as String,
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
                    '${transaction['isExpense'] as bool ? '-' : '+'}\$${(transaction['amount'] as double).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: transaction['isExpense'] as bool
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF22C55E),
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Time: ${transaction['subtitle'] as String}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AuthPalette.ink,
                      fontWeight: FontWeight.w700,
                    ),
              ),
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

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          floating: true,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AuthPalette.ink,
                  fontWeight: FontWeight.w900,
                ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.today),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime.now();
                  _selectedDay = DateTime.now();
                });
              },
              color: AppTheme.accentGold,
            ),
          ],
        ),

        // Summary
        SliverToBoxAdapter(
          child: Consumer<TransactionService>(
            builder: (context, transactionService, child) {
              final transactions = transactionService.transactions;
              _populateTransactionsByDay(transactions); // Update the map
              final totalIncome = transactions
                  .where((t) => !t.isExpense)
                  .fold(0.0, (sum, t) => sum + t.amount);
              final totalExpense = transactions
                  .where((t) => t.isExpense)
                  .fold(0.0, (sum, t) => sum + t.amount);
              final balance = totalIncome - totalExpense;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Solde',
                        '\$${balance.toStringAsFixed(2)}',
                        AppTheme.accentGold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Revenus',
                        '\$${totalIncome.toStringAsFixed(2)}',
                        AppTheme.incomeColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Dépenses',
                        '\$${totalExpense.toStringAsFixed(2)}',
                        AppTheme.expenseColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Calendrier
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBlack,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              boxShadow: AppTheme.cardShadow,
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },

              // Style du calendrier
              calendarStyle: CalendarStyle(
                defaultDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                weekendDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppTheme.accentBronze.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accentBronze),
                ),
                outsideDaysVisible: false,
                cellMargin: const EdgeInsets.all(4),
              ),

              // Style de l'en-tête
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: Theme.of(context).textTheme.titleLarge!,
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: AppTheme.accentGold,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: AppTheme.accentGold,
                ),
              ),

              // Style des jours
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                weekendStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),

              // Style du texte des jours
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: AppTheme.primaryBlack,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: AppTheme.accentBronze.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accentBronze),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: AppTheme.accentBronze,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
                markerBuilder: (context, day, events) {
                  if (_transactionsByDay.containsKey(_normalizeDate(day)) &&
                      _transactionsByDay[_normalizeDate(day)]!.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),

        // Transactions du jour sélectionné
        SliverToBoxAdapter(
          child: _buildSelectedDayTransactions(),
        ),
      ],
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  Widget _buildSelectedDayTransactions() {
    if (_selectedDay == null) {
      return const SizedBox.shrink();
    }

    final normalizedDate = _normalizeDate(_selectedDay!);
    final transactions = _transactionsByDay[normalizedDate] ?? [];
    final totalExpense = transactions
        .where((t) => t['isExpense'] as bool)
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du jour
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceBlack,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getFormattedDate(_selectedDay!),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transactions.length} transaction${transactions.length > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total des dépenses',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '\$${totalExpense.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: AppTheme.expenseColor,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Liste des transactions
          if (transactions.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...transactions.map((transaction) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TransactionItem(
                      title: transaction['title'] as String,
                      subtitle: transaction['subtitle'] as String,
                      category: transaction['category'] as String,
                      amount: transaction['amount'] as double,
                      isExpense: transaction['isExpense'] as bool,
                      icon: transaction['icon'] as IconData,
                      onTap: () => _showTransactionDetails(transaction),
                    ),
                  );
                }),
              ],
            )
          else
            // Message vide
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppTheme.surfaceBlack,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 60,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune transaction',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucune transaction enregistrée pour cette date',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'alimentation':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
      case 'achats':
        return Icons.shopping_bag;
      case 'entertainment':
      case 'loisirs':
        return Icons.movie;
      case 'health':
      case 'santé':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'bills':
      case 'factures':
        return Icons.receipt;
      case 'salary':
      case 'salaire':
        return Icons.account_balance_wallet;
      default:
        return Icons.category;
    }
  }

  String _getFormattedDate(DateTime date) {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final months = [
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
      'Décembre'
    ];

    final dayName = days[date.weekday - 1];
    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;

    return '$dayName $day $month $year';
  }

  Widget _buildSummaryCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBlack,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
