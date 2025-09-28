import 'package:flutter/material.dart';

/// Represents a single expense transaction
/// This class stores all the information about one expense entry
class Transaction {
  // Unique identifier for this transaction (usually a timestamp)
  final String id;

  // Description of what the expense was for (e.g., "Lunch at McDonald's")
  final String title;

  // How much money was spent (in dollars)
  final double amount;

  // When this expense occurred
  final DateTime date;

  // NEW: Which category this expense belongs to (links to Category.id)
  final String categoryId;

  // NEW: Recurring Payments
  final bool recurring;
  final String interval;

  // These will be used for recurring payments
  List<DateTime> pastPayments;
  List<DateTime> futurePayments;


  /// Constructor for creating a new transaction
  /// All parameters are required to ensure every transaction has complete information
  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId, // NEW: Now required to categorize every expense
    //New: Now required recurring and interval
    required this.recurring,
    required this.interval,
    this.pastPayments = const [],
    this.futurePayments = const [],
  });

  /// Creates a copy of this transaction with some fields updated
  /// This is useful when editing a transaction - you can change only some properties
  /// while keeping the others the same
  ///
  /// Example: transaction.copyWith(amount: 25.50) keeps everything the same
  /// except the amount
  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? categoryId,
    bool? recurring,
    String? interval,
    List<DateTime>? pastPayments,
    List<DateTime>? futurePayments,
  }) {
    return Transaction(
      // If a new value is provided, use it; otherwise keep the original value
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      recurring: recurring ?? this.recurring,
      interval: interval ?? this.interval,
      pastPayments: pastPayments ?? this.pastPayments,
      futurePayments: futurePayments ?? this.futurePayments,
    );
  }

  /// Converts this transaction to a JSON format for saving to storage
  /// JSON is a text format that can be easily saved to files or databases
  ///
  /// Note: We convert the DateTime to a string because JSON can't directly store dates
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(), // Convert date to string format
      'categoryId': categoryId, // NEW: Include category information
      'recurring': recurring, // NEW: Include recurring and interval
      'interval': interval,
      'pastPayments': pastPayments.map((n) => n.toIso8601String()).toList(), //Convert dates to string format
      'futurePayments': futurePayments.map((n) => n.toIso8601String()).toList(), //Convert dates to string format
    };
  }

  /// Creates a Transaction object from JSON data
  /// This is the opposite of toJson() - it takes saved data and recreates the object
  ///
  /// factory constructor: A special type of constructor that can return different
  /// types of objects or create objects in different ways
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(), // Convert back to double
      date: DateTime.parse(json['date']), // Convert string back to DateTime
      categoryId: json['categoryId'], // NEW: Restore category information
      recurring: json['recurring'], // NEW: Include recurring and interval
      interval: json['interval'],
      //Casting the below fields as Lists if available, otherwise use empty list to parse.
      pastPayments: (json['pastPayments'] as List<dynamic>? ?? []).map((e) => DateTime.parse(e as String)).toList(),
      futurePayments: (json['pastPayments'] as List<dynamic>? ?? []).map((e) => DateTime.parse(e as String)).toList(),
    );
  }

  /// Creates a Transaction object from Firestore data
  /// This is used when loading transactions from Firebase Firestore
  factory Transaction.fromMap(Map<String, dynamic> data, String documentId) {
    return Transaction(
      id: documentId,
      title: data['title'],
      amount: (data['amount']).toDouble(),
      date: (data['date']).toDate(),
      categoryId: data['categoryId'] ??
          'other', // NEW: Include category, default to 'other'
      recurring: data['recurring'] ?? false, // NEW: Include recurring and interval
      interval: data['interval'] ?? '',
      pastPayments: data['pastPayments'] ?? [],
      futurePayments: data['futurePayments'] ?? [],
    );
  }

  /// Converts this transaction to a Map for Firestore storage
  /// This is used when saving transactions to Firebase Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': date,
      'categoryId': categoryId, // NEW: Include category information
      'recurring': recurring,
      'interval': interval,
      'pastPayments': pastPayments,
      'futurePayments': futurePayments,
    };
  }

  /// Checks if two transactions are the same
  /// This is important for comparing transactions and removing duplicates
  @override
  bool operator ==(Object other) {
    // If it's the exact same object in memory, they're equal
    if (identical(this, other)) return true;

    // Check if the other object is a Transaction and all properties match
    return other is Transaction &&
        other.id == id &&
        other.title == title &&
        other.amount == amount &&
        other.date == date &&
        other.categoryId == categoryId && // NEW: Also compare category
        other.recurring == recurring &&  // NEW: Include recurring and interval
        other.interval == interval &&
        other.pastPayments == pastPayments &&
        other.futurePayments == futurePayments;
  }

  /// Generates a unique number for this transaction
  /// This is used by Dart's internal systems for efficient storage and comparison
  @override
  int get hashCode {
    // Combine all the hash codes using XOR (^) operator
    return id.hashCode ^
        title.hashCode ^
        amount.hashCode ^
        date.hashCode ^
        categoryId.hashCode ^ // NEW: Include category in hash calculation
        recurring.hashCode ^  // NEW: Include recurring and interval
        interval.hashCode ^
        pastPayments.hashCode ^
        futurePayments.hashCode;
  }

  /// Returns a string representation of this transaction
  /// Useful for debugging - shows all the transaction's properties
  @override
  String toString() {
    return 'Transaction(id: $id, title: $title, amount: $amount, date: $date, categoryId: $categoryId, recurring: $recurring, interval: $interval)';
  }
}
