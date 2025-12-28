import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:budget_manager/models/transaction.dart';

class TransactionService extends ChangeNotifier {
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> fetchTransactions(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(50)
          .get();

      _transactions = querySnapshot.docs
          .map((doc) => Transaction.fromMap(doc.data()))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toMap());

      _transactions.insert(0, transaction);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .update(transaction.toMap());

      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection('transactions').doc(transactionId).delete();

      _transactions.removeWhere((t) => t.id == transactionId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  double get totalBalance {
    double total = 0;
    for (var transaction in _transactions) {
      total += transaction.signedAmount;
    }
    return total;
  }

  double get totalExpenses {
    return _transactions
        .where((t) => t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get totalIncome {
    return _transactions
        .where((t) => !t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};

    for (var transaction in _transactions) {
      if (transaction.isExpense) {
        totals.update(
          transaction.category,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    return totals;
  }

  List<Transaction> getRecentTransactions(int count) {
    return _transactions.take(count).toList();
  }

  List<Transaction> getTransactionsByDate(DateTime date) {
    return _transactions.where((t) {
      return t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day;
    }).toList();
  }

  List<Transaction> searchTransactions(String query) {
    if (query.isEmpty) return _transactions;

    return _transactions.where((t) {
      return t.title.toLowerCase().contains(query.toLowerCase()) ||
          t.description.toLowerCase().contains(query.toLowerCase()) ||
          t.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
