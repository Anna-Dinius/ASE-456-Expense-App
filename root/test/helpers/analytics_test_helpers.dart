import 'package:p5_expense/model/transaction.dart';
import 'package:p5_expense/model/budget.dart';

/// Test helper functions for AnalyticsService testing
/// These helpers allow testing calculation logic without Firestore dependencies
class AnalyticsTestHelpers {
  /// Creates a test transaction
  static Transaction createTestTransaction({
    String id = 'test-tx-1',
    String title = 'Test Transaction',
    double amount = 100.0,
    DateTime? date,
    String categoryId = 'food',
    bool recurring = false,
    String interval = '',
  }) {
    return Transaction(
      id: id,
      title: title,
      amount: amount,
      date: date ?? DateTime.now(),
      categoryId: categoryId,
      recurring: recurring,
      interval: interval,
    );
  }

  /// Creates a test budget
  static Budget createTestBudget({
    String id = 'test-budget-1',
    String name = 'Test Budget',
    double amount = 500.0,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    BudgetType type = BudgetType.OVERALL,
    BudgetPeriod period = BudgetPeriod.MONTHLY,
  }) {
    final now = DateTime.now();
    return Budget(
      id: id,
      name: name,
      amount: amount,
      startDate: startDate ?? DateTime(now.year, now.month, 1),
      endDate: endDate ?? DateTime(now.year, now.month + 1, 0),
      categoryId: categoryId,
      type: type,
      period: period,
      isActive: true,
      alertThresholds: [0.5, 0.75, 0.9],
      createdAt: now,
      lastUpdatedAt: now,
    );
  }

  /// Calculates total spent from transactions (mirrors AnalyticsService logic)
  static double calculateTotalSpent(List<Transaction> transactions) {
    return transactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  /// Calculates category breakdown (mirrors AnalyticsService logic)
  static Map<String, double> calculateCategoryBreakdown(List<Transaction> transactions) {
    final breakdown = <String, double>{};
    for (final transaction in transactions) {
      breakdown[transaction.categoryId] = 
          (breakdown[transaction.categoryId] ?? 0.0) + transaction.amount;
    }
    return breakdown;
  }

  /// Calculates category analysis with percentages
  static Map<String, Map<String, dynamic>> calculateCategoryAnalysis(List<Transaction> transactions) {
    final categoryTotals = <String, double>{};
    double totalSpent = 0.0;

    for (final transaction in transactions) {
      final categoryId = transaction.categoryId;
      categoryTotals[categoryId] = (categoryTotals[categoryId] ?? 0.0) + transaction.amount;
      totalSpent += transaction.amount;
    }

    final analysis = <String, Map<String, dynamic>>{};
    for (final entry in categoryTotals.entries) {
      final percentage = totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0.0;
      analysis[entry.key] = {
        'amount': entry.value,
        'percentage': percentage,
        'transactionCount': transactions.where((t) => t.categoryId == entry.key).length,
      };
    }

    return analysis;
  }

  /// Calculates spending trends by date
  static Map<DateTime, double> calculateSpendingTrends(
    List<Transaction> transactions, {
    String? categoryId,
  }) {
    final trends = <DateTime, double>{};

    for (final transaction in transactions) {
      if (categoryId != null && transaction.categoryId != categoryId) {
        continue;
      }

      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      trends[date] = (trends[date] ?? 0.0) + transaction.amount;
    }

    return trends;
  }

  /// Calculates budget utilization
  static double calculateBudgetUtilization(Budget budget, List<Transaction> transactions) {
    double spent = 0.0;

    for (final transaction in transactions) {
      if (transaction.date.isAfter(budget.startDate.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(budget.endDate.add(const Duration(days: 1)))) {
        if (budget.type == BudgetType.OVERALL) {
          spent += transaction.amount;
        } else if (budget.type == BudgetType.CATEGORY && 
                   budget.categoryId == transaction.categoryId) {
          spent += transaction.amount;
        }
      }
    }

    return budget.amount > 0 ? spent / budget.amount : 0.0;
  }
}

