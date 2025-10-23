import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a financial report with spending analysis
/// This class stores aggregated financial data for a specific period
class Report {
  // Unique identifier for this report
  final String id;

  // Period this report covers (e.g., "October 2024", "Q3 2024")
  final String period;

  // Start date of the report period
  final DateTime startDate;

  // End date of the report period
  final DateTime endDate;

  // Total amount spent in this period
  final double totalSpent;

  // Average daily spending
  final double averageDailySpending;

  // Average weekly spending
  final double averageWeeklySpending;

  // Average monthly spending (if period is longer than a month)
  final double averageMonthlySpending;

  // Budget performance metrics
  final BudgetPerformance budgetPerformance;

  // Impact of recurring transactions on spending
  final RecurringTransactionImpact recurringTransactionImpact;

  // Spending breakdown by category
  final Map<String, double> categoryBreakdown;

  // Number of transactions in this period
  final int transactionCount;

  // When this report was generated
  final DateTime generatedAt;

  // When this report was last updated
  final DateTime lastUpdatedAt;

  /// Constructor for creating a new report
  Report({
    required this.id,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalSpent,
    required this.averageDailySpending,
    required this.averageWeeklySpending,
    required this.averageMonthlySpending,
    required this.budgetPerformance,
    required this.recurringTransactionImpact,
    required this.categoryBreakdown,
    required this.transactionCount,
    required this.generatedAt,
    required this.lastUpdatedAt,
  });

  /// Creates a copy of this report with some fields updated
  Report copyWith({
    String? id,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    double? totalSpent,
    double? averageDailySpending,
    double? averageWeeklySpending,
    double? averageMonthlySpending,
    BudgetPerformance? budgetPerformance,
    RecurringTransactionImpact? recurringTransactionImpact,
    Map<String, double>? categoryBreakdown,
    int? transactionCount,
    DateTime? generatedAt,
    DateTime? lastUpdatedAt,
  }) {
    return Report(
      id: id ?? this.id,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalSpent: totalSpent ?? this.totalSpent,
      averageDailySpending: averageDailySpending ?? this.averageDailySpending,
      averageWeeklySpending: averageWeeklySpending ?? this.averageWeeklySpending,
      averageMonthlySpending: averageMonthlySpending ?? this.averageMonthlySpending,
      budgetPerformance: budgetPerformance ?? this.budgetPerformance,
      recurringTransactionImpact: recurringTransactionImpact ?? this.recurringTransactionImpact,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      transactionCount: transactionCount ?? this.transactionCount,
      generatedAt: generatedAt ?? this.generatedAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  /// Converts this report to a JSON format for saving to storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalSpent': totalSpent,
      'averageDailySpending': averageDailySpending,
      'averageWeeklySpending': averageWeeklySpending,
      'averageMonthlySpending': averageMonthlySpending,
      'budgetPerformance': budgetPerformance.toJson(),
      'recurringTransactionImpact': recurringTransactionImpact.toJson(),
      'categoryBreakdown': categoryBreakdown,
      'transactionCount': transactionCount,
      'generatedAt': generatedAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  /// Creates a Report object from JSON data
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      period: json['period'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalSpent: json['totalSpent'].toDouble(),
      averageDailySpending: json['averageDailySpending'].toDouble(),
      averageWeeklySpending: json['averageWeeklySpending'].toDouble(),
      averageMonthlySpending: json['averageMonthlySpending'].toDouble(),
      budgetPerformance: BudgetPerformance.fromJson(json['budgetPerformance']),
      recurringTransactionImpact: RecurringTransactionImpact.fromJson(json['recurringTransactionImpact']),
      categoryBreakdown: Map<String, double>.from(json['categoryBreakdown']),
      transactionCount: json['transactionCount'],
      generatedAt: DateTime.parse(json['generatedAt']),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt']),
    );
  }

  /// Creates a Report object from Firestore data
  factory Report.fromMap(Map<String, dynamic> data, String documentId) {
    return Report(
      id: documentId,
      period: data['period'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      totalSpent: (data['totalSpent'] as num).toDouble(),
      averageDailySpending: (data['averageDailySpending'] as num).toDouble(),
      averageWeeklySpending: (data['averageWeeklySpending'] as num).toDouble(),
      averageMonthlySpending: (data['averageMonthlySpending'] as num).toDouble(),
      budgetPerformance: BudgetPerformance.fromMap(data['budgetPerformance']),
      recurringTransactionImpact: RecurringTransactionImpact.fromMap(data['recurringTransactionImpact']),
      categoryBreakdown: Map<String, double>.from(data['categoryBreakdown']),
      transactionCount: data['transactionCount'],
      generatedAt: (data['generatedAt'] as Timestamp).toDate(),
      lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp).toDate(),
    );
  }

  /// Converts this report to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'period': period,
      'startDate': startDate,
      'endDate': endDate,
      'totalSpent': totalSpent,
      'averageDailySpending': averageDailySpending,
      'averageWeeklySpending': averageWeeklySpending,
      'averageMonthlySpending': averageMonthlySpending,
      'budgetPerformance': budgetPerformance.toMap(),
      'recurringTransactionImpact': recurringTransactionImpact.toMap(),
      'categoryBreakdown': categoryBreakdown,
      'transactionCount': transactionCount,
      'generatedAt': generatedAt,
      'lastUpdatedAt': lastUpdatedAt,
    };
  }

  /// Checks if two reports are the same
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Report &&
        other.id == id &&
        other.period == period &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.totalSpent == totalSpent &&
        other.averageDailySpending == averageDailySpending &&
        other.averageWeeklySpending == averageWeeklySpending &&
        other.averageMonthlySpending == averageMonthlySpending &&
        other.budgetPerformance == budgetPerformance &&
        other.recurringTransactionImpact == recurringTransactionImpact &&
        other.categoryBreakdown == categoryBreakdown &&
        other.transactionCount == transactionCount &&
        other.generatedAt == generatedAt &&
        other.lastUpdatedAt == lastUpdatedAt;
  }

  /// Generates a unique number for this report
  @override
  int get hashCode {
    return id.hashCode ^
        period.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        totalSpent.hashCode ^
        averageDailySpending.hashCode ^
        averageWeeklySpending.hashCode ^
        averageMonthlySpending.hashCode ^
        budgetPerformance.hashCode ^
        recurringTransactionImpact.hashCode ^
        categoryBreakdown.hashCode ^
        transactionCount.hashCode ^
        generatedAt.hashCode ^
        lastUpdatedAt.hashCode;
  }

  /// Returns a string representation of this report
  @override
  String toString() {
    return 'Report(id: $id, period: $period, totalSpent: $totalSpent, transactionCount: $transactionCount)';
  }

  /// Calculates the number of days in this report period
  int get daysInPeriod {
    return endDate.difference(startDate).inDays;
  }

  /// Calculates the number of weeks in this report period
  int get weeksInPeriod {
    return (daysInPeriod / 7).ceil();
  }

  /// Calculates the number of months in this report period
  int get monthsInPeriod {
    return ((endDate.year - startDate.year) * 12) + (endDate.month - startDate.month);
  }
}

/// Represents budget performance metrics for a report
class BudgetPerformance {
  // Total budget amount for this period
  final double totalBudgetAmount;

  // Total amount spent against budgets
  final double totalSpentAgainstBudgets;

  // Budget utilization percentage (0.0 to 1.0)
  final double utilizationPercentage;

  // Number of budgets that were exceeded
  final int exceededBudgets;

  // Number of budgets that were met (within 10% of limit)
  final int metBudgets;

  // Number of budgets that were under-utilized
  final int underUtilizedBudgets;

  // Budget performance by category
  final Map<String, double> categoryPerformance;

  BudgetPerformance({
    required this.totalBudgetAmount,
    required this.totalSpentAgainstBudgets,
    required this.utilizationPercentage,
    required this.exceededBudgets,
    required this.metBudgets,
    required this.underUtilizedBudgets,
    required this.categoryPerformance,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalBudgetAmount': totalBudgetAmount,
      'totalSpentAgainstBudgets': totalSpentAgainstBudgets,
      'utilizationPercentage': utilizationPercentage,
      'exceededBudgets': exceededBudgets,
      'metBudgets': metBudgets,
      'underUtilizedBudgets': underUtilizedBudgets,
      'categoryPerformance': categoryPerformance,
    };
  }

  factory BudgetPerformance.fromJson(Map<String, dynamic> json) {
    return BudgetPerformance(
      totalBudgetAmount: json['totalBudgetAmount'].toDouble(),
      totalSpentAgainstBudgets: json['totalSpentAgainstBudgets'].toDouble(),
      utilizationPercentage: json['utilizationPercentage'].toDouble(),
      exceededBudgets: json['exceededBudgets'],
      metBudgets: json['metBudgets'],
      underUtilizedBudgets: json['underUtilizedBudgets'],
      categoryPerformance: Map<String, double>.from(json['categoryPerformance']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalBudgetAmount': totalBudgetAmount,
      'totalSpentAgainstBudgets': totalSpentAgainstBudgets,
      'utilizationPercentage': utilizationPercentage,
      'exceededBudgets': exceededBudgets,
      'metBudgets': metBudgets,
      'underUtilizedBudgets': underUtilizedBudgets,
      'categoryPerformance': categoryPerformance,
    };
  }

  factory BudgetPerformance.fromMap(Map<String, dynamic> data) {
    return BudgetPerformance(
      totalBudgetAmount: (data['totalBudgetAmount'] as num).toDouble(),
      totalSpentAgainstBudgets: (data['totalSpentAgainstBudgets'] as num).toDouble(),
      utilizationPercentage: (data['utilizationPercentage'] as num).toDouble(),
      exceededBudgets: data['exceededBudgets'],
      metBudgets: data['metBudgets'],
      underUtilizedBudgets: data['underUtilizedBudgets'],
      categoryPerformance: Map<String, double>.from(data['categoryPerformance']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetPerformance &&
        other.totalBudgetAmount == totalBudgetAmount &&
        other.totalSpentAgainstBudgets == totalSpentAgainstBudgets &&
        other.utilizationPercentage == utilizationPercentage &&
        other.exceededBudgets == exceededBudgets &&
        other.metBudgets == metBudgets &&
        other.underUtilizedBudgets == underUtilizedBudgets &&
        other.categoryPerformance == categoryPerformance;
  }

  @override
  int get hashCode {
    return totalBudgetAmount.hashCode ^
        totalSpentAgainstBudgets.hashCode ^
        utilizationPercentage.hashCode ^
        exceededBudgets.hashCode ^
        metBudgets.hashCode ^
        underUtilizedBudgets.hashCode ^
        categoryPerformance.hashCode;
  }
}

/// Represents the impact of recurring transactions on spending
class RecurringTransactionImpact {
  // Total amount from recurring transactions in this period
  final double totalRecurringAmount;

  // Number of recurring transactions
  final int recurringTransactionCount;

  // Percentage of total spending that comes from recurring transactions
  final double recurringPercentage;

  // Breakdown of recurring transactions by category
  final Map<String, double> recurringByCategory;

  // List of recurring transaction IDs that contributed to this period
  final List<String> contributingRecurringIds;

  RecurringTransactionImpact({
    required this.totalRecurringAmount,
    required this.recurringTransactionCount,
    required this.recurringPercentage,
    required this.recurringByCategory,
    required this.contributingRecurringIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalRecurringAmount': totalRecurringAmount,
      'recurringTransactionCount': recurringTransactionCount,
      'recurringPercentage': recurringPercentage,
      'recurringByCategory': recurringByCategory,
      'contributingRecurringIds': contributingRecurringIds,
    };
  }

  factory RecurringTransactionImpact.fromJson(Map<String, dynamic> json) {
    return RecurringTransactionImpact(
      totalRecurringAmount: json['totalRecurringAmount'].toDouble(),
      recurringTransactionCount: json['recurringTransactionCount'],
      recurringPercentage: json['recurringPercentage'].toDouble(),
      recurringByCategory: Map<String, double>.from(json['recurringByCategory']),
      contributingRecurringIds: List<String>.from(json['contributingRecurringIds']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalRecurringAmount': totalRecurringAmount,
      'recurringTransactionCount': recurringTransactionCount,
      'recurringPercentage': recurringPercentage,
      'recurringByCategory': recurringByCategory,
      'contributingRecurringIds': contributingRecurringIds,
    };
  }

  factory RecurringTransactionImpact.fromMap(Map<String, dynamic> data) {
    return RecurringTransactionImpact(
      totalRecurringAmount: (data['totalRecurringAmount'] as num).toDouble(),
      recurringTransactionCount: data['recurringTransactionCount'],
      recurringPercentage: (data['recurringPercentage'] as num).toDouble(),
      recurringByCategory: Map<String, double>.from(data['recurringByCategory']),
      contributingRecurringIds: List<String>.from(data['contributingRecurringIds']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecurringTransactionImpact &&
        other.totalRecurringAmount == totalRecurringAmount &&
        other.recurringTransactionCount == recurringTransactionCount &&
        other.recurringPercentage == recurringPercentage &&
        other.recurringByCategory == recurringByCategory &&
        other.contributingRecurringIds == contributingRecurringIds;
  }

  @override
  int get hashCode {
    return totalRecurringAmount.hashCode ^
        recurringTransactionCount.hashCode ^
        recurringPercentage.hashCode ^
        recurringByCategory.hashCode ^
        contributingRecurringIds.hashCode;
  }
}
