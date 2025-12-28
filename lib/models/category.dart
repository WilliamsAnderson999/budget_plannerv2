import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Category {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final int color;
  final double budget;
  final double spent;
  final DateTime createdAt;
  final bool isDefault;

  Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.color,
    required this.budget,
    this.spent = 0.0,
    required this.createdAt,
    this.isDefault = false,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? 'category',
      color: map['color'] ?? 0xFF607D8B,
      budget: (map['budget'] ?? 0).toDouble(),
      spent: (map['spent'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'icon': icon,
      'color': color,
      'budget': budget,
      'spent': spent,
      'createdAt': Timestamp.fromDate(createdAt),
      'isDefault': isDefault,
    };
  }

  double get remaining => budget - spent;
  double get percentage =>
      budget > 0 ? (spent / budget * 100).clamp(0, 100).toDouble() : 0;

  Category copyWith({
    String? id,
    String? userId,
    String? name,
    String? icon,
    int? color,
    double? budget,
    double? spent,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Color get colorValue => Color(color);
}
