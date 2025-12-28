import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final bool isExpense;
  final String? receiptUrl;
  final String? location;
  final String? tags;

  Transaction({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.isExpense,
    this.receiptUrl,
    this.location,
    this.tags,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? 'Autre',
      date: (map['date'] as Timestamp).toDate(),
      isExpense: map['isExpense'] ?? true,
      receiptUrl: map['receiptUrl'],
      location: map['location'],
      tags: map['tags'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'isExpense': isExpense,
      'receiptUrl': receiptUrl,
      'location': location,
      'tags': tags,
    };
  }

  double get signedAmount => isExpense ? -amount : amount;
}
