import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String fullName;
  final DateTime createdAt;
  final String currency;
  final double monthlyBudget;
  final bool biometricEnabled;
  final bool notificationsEnabled;
  final List<String> categories;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.createdAt,
    this.currency = 'USD',
    this.monthlyBudget = 2000.00,
    this.biometricEnabled = false,
    this.notificationsEnabled = true,
    this.categories = const [],
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      currency: map['currency'] ?? 'USD',
      monthlyBudget: (map['monthlyBudget'] ?? 2000).toDouble(),
      biometricEnabled: map['biometricEnabled'] ?? false,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      categories: List<String>.from(map['categories'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'createdAt': Timestamp.fromDate(createdAt),
      'currency': currency,
      'monthlyBudget': monthlyBudget,
      'biometricEnabled': biometricEnabled,
      'notificationsEnabled': notificationsEnabled,
      'categories': categories,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    DateTime? createdAt,
    String? currency,
    double? monthlyBudget,
    bool? biometricEnabled,
    bool? notificationsEnabled,
    List<String>? categories,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      createdAt: createdAt ?? this.createdAt,
      currency: currency ?? this.currency,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      categories: categories ?? this.categories,
    );
  }
}
