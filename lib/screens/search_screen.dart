import 'package:flutter/material.dart';
import 'package:budget_manager/theme/app_theme.dart';
import 'package:budget_manager/widgets/transaction_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _selectedCategory = 'Toutes les catégories';
  DateTime _selectedDate = DateTime.now();
  String _selectedReportType = 'Toutes';

  final List<String> _categories = [
    'Toutes les catégories',
    'Alimentation',
    'Transport',
    'Logement',
    'Divertissement',
    'Santé',
    'Shopping',
    'Éducation',
    'Autre',
  ];

  final List<String> _reportTypes = [
    'Toutes',
    'Revenus',
    'Dépenses',
  ];

  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadInitialResults();
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
                      color: AppTheme.textPrimary,
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
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        Text(
                          transaction['category'] as String,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.textSecondary,
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
                'Details: ${transaction['subtitle'] as String}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
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
                      color: AppTheme.textPrimary,
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // AppBar avec recherche
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              title: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardBlack,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Rechercher des transactions...',
                    border: InputBorder.none,
                    prefixIcon:
                        Icon(Icons.search, color: AppTheme.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close,
                                color: AppTheme.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              _searchFocusNode.unfocus();
                            },
                          )
                        : null,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  autofocus: true,
                ),
              ),
            ),
          ),

          // Filtres
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildFilterSection(
                    title: 'Catégories',
                    value: _selectedCategory,
                    onTap: _showCategoryFilter,
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    title: 'Date',
                    value:
                        '${_selectedDate.day} / ${_getMonthName(_selectedDate.month)} / ${_selectedDate.year}',
                    onTap: _showDatePicker,
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    title: 'Type de rapport',
                    value: _selectedReportType,
                    onTap: _showReportTypeFilter,
                  ),
                ],
              ),
            ),
          ),

          // Bouton de recherche
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusMedium),
                  ),
                ),
                child: Text(
                  'Rechercher',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ),

          // Résultats
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Text(
                      'Résultats (${_searchResults.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  );
                }

                final resultIndex = index - 1;
                if (resultIndex >= _searchResults.length) {
                  return const SizedBox.shrink();
                }

                final transaction = _searchResults[resultIndex];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
              },
              childCount: _searchResults.length + 1,
            ),
          ),

          // Message vide
          if (_searchResults.isEmpty && _searchController.text.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 80,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Aucune recherche effectuée',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Utilisez la barre de recherche pour trouver des transactions',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBlack,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: AppTheme.subtleShadow,
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_drop_down,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _loadInitialResults() {
    // Données initiales
    _searchResults = [
      {
        'title': 'Dîner',
        'subtitle': '18:27 - 30 Avr | Restaurant',
        'category': 'Restaurant',
        'amount': 26.00,
        'isExpense': true,
        'icon': Icons.restaurant_outlined,
      },
    ];
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> _showCategoryFilter() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.cardBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 400,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Sélectionner une catégorie',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return ListTile(
                      title: Text(
                        category,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: category == _selectedCategory
                                  ? AppTheme.accentGold
                                  : AppTheme.textPrimary,
                            ),
                      ),
                      trailing: category == _selectedCategory
                          ? Icon(Icons.check, color: AppTheme.accentGold)
                          : null,
                      onTap: () {
                        Navigator.pop(context, category);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedCategory = result;
      });
    }
  }

  Future<void> _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.accentBronze,
              onPrimary: AppTheme.primaryBlack,
              surface: AppTheme.cardBlack,
              onSurface: AppTheme.textPrimary,
            ),
            dialogTheme: DialogThemeData(backgroundColor: AppTheme.cardBlack),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _showReportTypeFilter() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.cardBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Type de rapport',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _reportTypes.length,
                  itemBuilder: (context, index) {
                    final type = _reportTypes[index];
                    return ListTile(
                      title: Text(
                        type,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: type == _selectedReportType
                                  ? AppTheme.accentGold
                                  : AppTheme.textPrimary,
                            ),
                      ),
                      trailing: type == _selectedReportType
                          ? Icon(Icons.check, color: AppTheme.accentGold)
                          : null,
                      onTap: () {
                        Navigator.pop(context, type);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedReportType = result;
      });
    }
  }

  void _performSearch() {
    // Logique de recherche
    setState(() {
      // Ajouter plus de résultats pour la démo
      _searchResults = [
        {
          'title': 'Dîner',
          'subtitle': '18:27 - 30 Avr | Restaurant',
          'category': 'Restaurant',
          'amount': 26.00,
          'isExpense': true,
          'icon': Icons.restaurant_outlined,
        },
        {
          'title': 'Courses',
          'subtitle': '17:00 - 24 Avr | Épicerie',
          'category': 'Alimentation',
          'amount': 100.00,
          'isExpense': true,
          'icon': Icons.shopping_cart_outlined,
        },
        {
          'title': 'Salaire',
          'subtitle': '18:27 - 30 Avr | Mensuel',
          'category': 'Salaire',
          'amount': 4000.00,
          'isExpense': false,
          'icon': Icons.account_balance_wallet_outlined,
        },
      ];
    });
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc'
    ];
    return months[month - 1];
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
