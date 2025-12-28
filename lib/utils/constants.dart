class AppConstants {
  static const String appName = 'Budget Manager';
  static const String appVersion = '1.0.0';

  // Routes
  static const String routeHome = '/home';
  static const String routeLogin = '/login';
  static const String routeSignup = '/signup';
  static const String routeAnalysis = '/analysis';
  static const String routeTransactions = '/transactions';

  // Collections Firestore
  static const String collectionUsers = 'users';
  static const String collectionTransactions = 'transactions';
  static const String collectionCategories = 'categories';
  static const String collectionBudgets = 'budgets';
  static const String collectionGoals = 'goals';

  // Catégories par défaut
  static const List<Map<String, dynamic>> defaultCategories = [
    {
      'name': 'Alimentation',
      'icon': 0xe53a, // Icons.food_bank
      'color': 0xFFFF9800, // Orange
      'budget': 400.00,
    },
    {
      'name': 'Transport',
      'icon': 0xe1d7, // Icons.directions_car
      'color': 0xFF2196F3, // Blue
      'budget': 200.00,
    },
    {
      'name': 'Logement',
      'icon': 0xe88a, // Icons.home
      'color': 0xFF795548, // Brown
      'budget': 800.00,
    },
    {
      'name': 'Divertissement',
      'icon': 0xe02c, // Icons.movie
      'color': 0xFFE91E63, // Pink
      'budget': 150.00,
    },
    {
      'name': 'Santé',
      'icon': 0xe103, // Icons.health_and_safety
      'color': 0xFF4CAF50, // Green
      'budget': 100.00,
    },
    {
      'name': 'Shopping',
      'icon': 0xe8cc, // Icons.shopping_cart
      'color': 0xFF9C27B0, // Purple
      'budget': 200.00,
    },
    {
      'name': 'Éducation',
      'icon': 0xe80c, // Icons.school
      'color': 0xFF00BCD4, // Cyan
      'budget': 100.00,
    },
    {
      'name': 'Autre',
      'icon': 0xe574, // Icons.category
      'color': 0xFF607D8B, // Blue Grey
      'budget': 50.00,
    },
  ];

  // Couleurs de catégories
  static const Map<String, int> categoryColors = {
    'Alimentation': 0xFFFF9800,
    'Transport': 0xFF2196F3,
    'Logement': 0xFF795548,
    'Divertissement': 0xFFE91E63,
    'Santé': 0xFF4CAF50,
    'Shopping': 0xFF9C27B0,
    'Éducation': 0xFF00BCD4,
    'Autre': 0xFF607D8B,
  };

  // Devises supportées
  static const List<String> supportedCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'CAD',
    'AUD',
    'JPY',
    'CHF',
  ];

  // Formatters
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = '$dateFormat $timeFormat';

  // Limites
  static const int maxTransactionsPerPage = 20;
  static const int maxCategories = 20;
  static const double minTransactionAmount = 0.01;
  static const double maxTransactionAmount = 1000000.00;

  // Messages
  static const String loginSuccess = 'Connexion réussie !';
  static const String logoutSuccess = 'Déconnexion réussie';
  static const String transactionAdded = 'Transaction ajoutée';
  static const String transactionUpdated = 'Transaction mise à jour';
  static const String transactionDeleted = 'Transaction supprimée';
  static const String budgetUpdated = 'Budget mis à jour';
  static const String profileUpdated = 'Profil mis à jour';

  // Erreurs
  static const String errorNetwork = 'Erreur de connexion réseau';
  static const String errorInvalidEmail = 'Email invalide';
  static const String errorWeakPassword = 'Mot de passe trop faible';
  static const String errorWrongPassword = 'Mot de passe incorrect';
  static const String errorUserNotFound = 'Utilisateur non trouvé';
  static const String errorEmailAlreadyInUse = 'Email déjà utilisé';
  static const String errorInvalidCredentials = 'Identifiants invalides';
  static const String errorUnknown = 'Une erreur est survenue';
}
