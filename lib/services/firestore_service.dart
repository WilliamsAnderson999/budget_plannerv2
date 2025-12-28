import 'package:cloud_firestore/cloud_firestore.dart' as firebase;
import 'package:budget_manager/models/transaction.dart';
import 'package:budget_manager/models/user.dart';
import 'package:budget_manager/models/category.dart';
import 'package:budget_manager/models/goal.dart';
import 'package:budget_manager/utils/constants.dart';

class FirestoreService {
  final firebase.FirebaseFirestore _firestore =
      firebase.FirebaseFirestore.instance;

  // Users
  Future<void> createUser(User user) async {
    await _firestore
        .collection(AppConstants.collectionUsers)
        .doc(user.id)
        .set(user.toMap());
  }

  Future<User?> getUser(String userId) async {
    final doc = await _firestore
        .collection(AppConstants.collectionUsers)
        .doc(userId)
        .get();

    if (doc.exists) {
      return User.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    await _firestore
        .collection(AppConstants.collectionUsers)
        .doc(userId)
        .update(updates);
  }

  // Transactions
  Stream<List<Transaction>> getTransactionsStream(String userId) {
    return _firestore
        .collection(AppConstants.collectionTransactions)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Transaction.fromMap(doc.data()))
          .toList();
    });
  }

  Future<List<Transaction>> getTransactionsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final query = await _firestore
        .collection(AppConstants.collectionTransactions)
        .where('userId', isEqualTo: userId)
        .where('date',
            isGreaterThanOrEqualTo: firebase.Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: firebase.Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .get();

    return query.docs.map((doc) => Transaction.fromMap(doc.data())).toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _firestore
        .collection(AppConstants.collectionTransactions)
        .doc(transaction.id)
        .set(transaction.toMap());
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _firestore
        .collection(AppConstants.collectionTransactions)
        .doc(transactionId)
        .delete();
  }

  // Categories
  Future<List<Category>> getUserCategories(String userId) async {
    final query = await _firestore
        .collection(AppConstants.collectionCategories)
        .where('userId', isEqualTo: userId)
        .get();

    return query.docs.map((doc) => Category.fromMap(doc.data())).toList();
  }

  Future<void> createCategory(Category category) async {
    await _firestore
        .collection(AppConstants.collectionCategories)
        .doc(category.id)
        .set(category.toMap());
  }

  Future<void> updateCategory(
      String categoryId, Map<String, dynamic> updates) async {
    await _firestore
        .collection(AppConstants.collectionCategories)
        .doc(categoryId)
        .update(updates);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _firestore
        .collection(AppConstants.collectionCategories)
        .doc(categoryId)
        .delete();
  }

  // Budgets
  Future<Map<String, double>> getMonthlyBudget(
      String userId, DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final transactions = await getTransactionsByDateRange(userId, start, end);

    final Map<String, double> categoryTotals = {};

    for (var transaction in transactions) {
      if (transaction.isExpense) {
        categoryTotals.update(
          transaction.category,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    return categoryTotals;
  }

  // Analytics
  Future<Map<String, dynamic>> getMonthlyAnalytics(
    String userId,
    DateTime month,
  ) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final transactions = await getTransactionsByDateRange(userId, start, end);

    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> categoryExpenses = {};

    for (var transaction in transactions) {
      if (transaction.isExpense) {
        totalExpense += transaction.amount;
        categoryExpenses.update(
          transaction.category,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      } else {
        totalIncome += transaction.amount;
      }
    }

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': totalIncome - totalExpense,
      'categoryExpenses': categoryExpenses,
      'transactionCount': transactions.length,
    };
  }

  Future<Map<String, dynamic>> getAnalyticsForPeriod(
    String userId,
    String period, {
    bool isPrevious = false,
  }) async {
    // Define date range based on period (e.g., 'Mensuel' for monthly)
    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (period.toLowerCase()) {
      case 'quotidien':
        startDate = isPrevious ? now.subtract(const Duration(days: 1)) : now;
        endDate = startDate.add(const Duration(days: 1));
        break;
      case 'hebdomadaire':
        startDate = isPrevious
            ? now.subtract(const Duration(days: 7))
            : now.subtract(Duration(days: now.weekday - 1));
        endDate = startDate.add(const Duration(days: 7));
        break;
      case 'mensuel':
        startDate = isPrevious
            ? DateTime(now.year, now.month - 1, 1)
            : DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + (isPrevious ? 0 : 1), 1);
        break;
      case 'annuel':
        startDate = isPrevious
            ? DateTime(now.year - 1, 1, 1)
            : DateTime(now.year, 1, 1);
        endDate = DateTime(now.year + (isPrevious ? 0 : 1), 1, 1);
        break;
      default:
        throw ArgumentError('Invalid period: $period');
    }

    // Query Firestore for transactions in the date range
    final querySnapshot = await _firestore
        .collection(AppConstants.collectionTransactions)
        .where('userId', isEqualTo: userId)
        .where('date',
            isGreaterThanOrEqualTo: firebase.Timestamp.fromDate(startDate))
        .where('date', isLessThan: firebase.Timestamp.fromDate(endDate))
        .get();

    double totalIncome = 0;
    double totalExpense = 0;
    Map<String, double> categoryExpenses = {};
    List<Map<String, dynamic>> dataPoints =
        []; // For chart data, e.g., daily/weekly points

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final amount = data['amount'] as double? ?? 0;
      final isExpense = data['isExpense'] as bool? ?? false;
      final category = data['category'] as String? ?? 'Other';

      if (isExpense) {
        totalExpense += amount;
        categoryExpenses[category] = (categoryExpenses[category] ?? 0) + amount;
      } else {
        totalIncome += amount;
      }

      // Aggregate data points (simplified: assume daily for chart)
      final date = (data['date'] as firebase.Timestamp).toDate();
      final dayKey = '${date.year}-${date.month}-${date.day}';
      final index = dataPoints.indexWhere((point) => point['label'] == dayKey);
      late Map<String, dynamic> existingPoint;
      if (index == -1) {
        existingPoint = {'label': dayKey, 'income': 0.0, 'expense': 0.0};
        dataPoints.add(existingPoint);
      } else {
        existingPoint = dataPoints[index];
      }
      if (isExpense) {
        existingPoint['expense'] += amount;
      } else {
        existingPoint['income'] += amount;
      }
    }

    final balance = totalIncome - totalExpense;

    return {
      'balance': balance,
      'totalExpense': totalExpense,
      'totalIncome': totalIncome,
      'categoryExpenses': categoryExpenses,
      'dataPoints': dataPoints,
    };
  }

  // Search
  Future<List<Transaction>> searchTransactions(
    String userId,
    String query,
    String? category,
    DateTime? date,
    bool? isExpense,
  ) async {
    firebase.CollectionReference ref =
        _firestore.collection(AppConstants.collectionTransactions);
    firebase.Query queryRef = ref.where('userId', isEqualTo: userId);

    if (query.isNotEmpty) {
      // Note: Firestore ne supporte pas la recherche par texte complet sans Algolia/ElasticSearch
      // Cette implémentation est basique
      queryRef = queryRef.where('title', isGreaterThanOrEqualTo: query);
      queryRef = queryRef.where('title', isLessThanOrEqualTo: '$query\uf8ff');
    }

    if (category != null && category != 'Toutes les catégories') {
      queryRef = queryRef.where('category', isEqualTo: category);
    }

    if (isExpense != null) {
      queryRef = queryRef.where('isExpense', isEqualTo: isExpense);
    }

    final snapshot = await queryRef.orderBy('date', descending: true).get();

    List<Transaction> results = snapshot.docs
        .map((doc) => Transaction.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    // Filtrage par date côté client (limitation Firestore)
    if (date != null) {
      results = results.where((transaction) {
        return transaction.date.year == date.year &&
            transaction.date.month == date.month &&
            transaction.date.day == date.day;
      }).toList();
    }

    return results;
  }

  // Goals
  Future<void> addGoal(Goal goal) async {
    await _firestore
        .collection(AppConstants.collectionGoals)
        .doc(goal.id)
        .set(goal.toMap());
  }

  Future<List<Goal>> getGoals(String userId) async {
    final query = await _firestore
        .collection(AppConstants.collectionGoals)
        .where('userId', isEqualTo: userId)
        .get();
    return query.docs.map((doc) => Goal.fromMap(doc.data())).toList();
  }

  Future<void> updateGoal(String goalId, Map<String, dynamic> updates) async {
    await _firestore
        .collection(AppConstants.collectionGoals)
        .doc(goalId)
        .update(updates);
  }
}
