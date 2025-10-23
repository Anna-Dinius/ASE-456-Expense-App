import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a budget for tracking spending limits
/// This class stores all the information about a budget entry
class Budget {
  // Unique identifier for this budget
  final String id;

  // Human-readable name of the budget (e.g., "Monthly Food Budget")
  final String name;

  // Total budget amount (in dollars)
  final double amount;

  // When this budget period starts
  final DateTime startDate;

  // When this budget period ends
  final DateTime endDate;

  // Which category this budget applies to (null for overall budgets)
  final String? categoryId;

  // Type of budget (OVERALL, CATEGORY, CUSTOM)
  final BudgetType type;

  // Period of the budget (MONTHLY, QUARTERLY, YEARLY, CUSTOM)
  final BudgetPeriod period;

  // Whether this budget is currently active
  final bool isActive;

  // Alert thresholds as percentages (e.g., [0.5, 0.75, 0.9] for 50%, 75%, 90%)
  final List<double> alertThresholds;

  // When this budget was created
  final DateTime createdAt;

  // When this budget was last updated
  final DateTime lastUpdatedAt;

  /// Constructor for creating a new budget
  /// All parameters are required to ensure every budget has complete information
  Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.startDate,
    required this.endDate,
    this.categoryId,
    required this.type,
    required this.period,
    required this.isActive,
    this.alertThresholds = const [0.5, 0.75, 0.9],
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  /// Creates a copy of this budget with some fields updated
  /// This is useful when editing a budget - you can change only some properties
  /// while keeping the others the same
  Budget copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    BudgetType? type,
    BudgetPeriod? period,
    bool? isActive,
    List<double>? alertThresholds,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      period: period ?? this.period,
      isActive: isActive ?? this.isActive,
      alertThresholds: alertThresholds ?? this.alertThresholds,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  /// Converts this budget to a JSON format for saving to storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'categoryId': categoryId,
      'type': type.name,
      'period': period.name,
      'isActive': isActive,
      'alertThresholds': alertThresholds,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  /// Creates a Budget object from JSON data
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      name: json['name'],
      amount: json['amount'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      categoryId: json['categoryId'],
      type: BudgetType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BudgetType.OVERALL,
      ),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => BudgetPeriod.MONTHLY,
      ),
      isActive: json['isActive'] ?? true,
      alertThresholds: (json['alertThresholds'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [0.5, 0.75, 0.9],
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt']),
    );
  }

  /// Creates a Budget object from Firestore data
  factory Budget.fromMap(Map<String, dynamic> data, String documentId) {
    return Budget(
      id: documentId,
      name: data['name'],
      amount: (data['amount'] as num).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      categoryId: data['categoryId'],
      type: BudgetType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => BudgetType.OVERALL,
      ),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == data['period'],
        orElse: () => BudgetPeriod.MONTHLY,
      ),
      isActive: data['isActive'] ?? true,
      alertThresholds: (data['alertThresholds'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [0.5, 0.75, 0.9],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp).toDate(),
    );
  }

  /// Converts this budget to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'startDate': startDate,
      'endDate': endDate,
      'categoryId': categoryId,
      'type': type.name,
      'period': period.name,
      'isActive': isActive,
      'alertThresholds': alertThresholds,
      'createdAt': createdAt,
      'lastUpdatedAt': lastUpdatedAt,
    };
  }

  /// Checks if two budgets are the same
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Budget &&
        other.id == id &&
        other.name == name &&
        other.amount == amount &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.categoryId == categoryId &&
        other.type == type &&
        other.period == period &&
        other.isActive == isActive &&
        other.alertThresholds == alertThresholds &&
        other.createdAt == createdAt &&
        other.lastUpdatedAt == lastUpdatedAt;
  }

  /// Generates a unique number for this budget
  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        amount.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        categoryId.hashCode ^
        type.hashCode ^
        period.hashCode ^
        isActive.hashCode ^
        alertThresholds.hashCode ^
        createdAt.hashCode ^
        lastUpdatedAt.hashCode;
  }

  /// Returns a string representation of this budget
  @override
  String toString() {
    return 'Budget(id: $id, name: $name, amount: $amount, startDate: $startDate, endDate: $endDate, categoryId: $categoryId, type: $type, period: $period, isActive: $isActive)';
  }

  /// Calculates the number of days remaining in this budget period
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  /// Calculates the number of days elapsed in this budget period
  int get daysElapsed {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    return now.difference(startDate).inDays;
  }

  /// Calculates the total number of days in this budget period
  int get totalDays {
    return endDate.difference(startDate).inDays;
  }

  /// Checks if this budget is currently active (within date range and isActive = true)
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && 
           now.isAfter(startDate) && 
           now.isBefore(endDate);
  }

  /// Checks if this budget has expired
  bool get isExpired {
    final now = DateTime.now();
    return now.isAfter(endDate);
  }

  /// Checks if this budget is for a specific category
  bool get isCategoryBudget => type == BudgetType.CATEGORY && categoryId != null;

  /// Checks if this budget is an overall budget
  bool get isOverallBudget => type == BudgetType.OVERALL;
}

/// Enum representing the type of budget
enum BudgetType {
  OVERALL,    // Overall spending budget
  CATEGORY,   // Category-specific budget
  CUSTOM,     // Custom period budget
}

/// Enum representing the period of the budget
enum BudgetPeriod {
  MONTHLY,    // Monthly budget
  QUARTERLY,  // Quarterly budget
  YEARLY,     // Yearly budget
  CUSTOM,     // Custom period budget
}

/// Contains a list of predefined budget templates that users can start with
class DefaultBudgets {
  static final List<Budget> budgets = [
    // Monthly overall budget
    Budget(
      id: 'monthly_overall',
      name: 'Monthly Overall Budget',
      amount: 2000.0,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 30)),
      type: BudgetType.OVERALL,
      period: BudgetPeriod.MONTHLY,
      isActive: true,
      alertThresholds: [0.5, 0.75, 0.9],
      createdAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
    ),

    // Monthly food budget
    Budget(
      id: 'monthly_food',
      name: 'Monthly Food Budget',
      amount: 500.0,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 30)),
      categoryId: 'food',
      type: BudgetType.CATEGORY,
      period: BudgetPeriod.MONTHLY,
      isActive: true,
      alertThresholds: [0.5, 0.75, 0.9],
      createdAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
    ),

    // Monthly transport budget
    Budget(
      id: 'monthly_transport',
      name: 'Monthly Transport Budget',
      amount: 300.0,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 30)),
      categoryId: 'transport',
      type: BudgetType.CATEGORY,
      period: BudgetPeriod.MONTHLY,
      isActive: true,
      alertThresholds: [0.5, 0.75, 0.9],
      createdAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
    ),
  ];
}
