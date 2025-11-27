import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/material.dart';
import 'package:p5_expense/model/budget.dart';
import 'package:p5_expense/model/report.dart';
import 'package:p5_expense/model/transaction.dart';
import 'package:p5_expense/service/budget_service.dart';

/// Service class for analytics and report generation
/// Handles budget calculations, spending analysis, and report generation
/// Integrates with existing transaction and budget data
class AnalyticsService {
  static final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;

  /// Generates a comprehensive financial report for a specific period
  /// Returns a Report object with all financial metrics
  static Future<Report> generateReport({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required String period,
  }) async {
    try {
      // Get all transactions in the period
      final transactions =
          await _getTransactionsInPeriod(userId, startDate, endDate);

      // Get all budgets that overlap with the period
      final budgets = await _getBudgetsInPeriod(userId, startDate, endDate);

      // Calculate basic spending metrics
      final totalSpent = _calculateTotalSpent(transactions);
      final averageDailySpending =
          _calculateAverageDailySpending(transactions, startDate, endDate);
      final averageWeeklySpending =
          _calculateAverageWeeklySpending(transactions, startDate, endDate);
      final averageMonthlySpending =
          _calculateAverageMonthlySpending(transactions, startDate, endDate);

      // Calculate budget performance
      final budgetPerformance = await _calculateBudgetPerformance(
          userId, budgets, transactions, startDate, endDate);

      // Calculate recurring transaction impact
      final recurringImpact =
          _calculateRecurringTransactionImpact(transactions);

      // Calculate category breakdown
      final categoryBreakdown = _calculateCategoryBreakdown(transactions);

      // Create report
      final now = DateTime.now();
      final report = Report(
        id: '', // Will be set when saved
        period: period,
        startDate: startDate,
        endDate: endDate,
        totalSpent: totalSpent,
        averageDailySpending: averageDailySpending,
        averageWeeklySpending: averageWeeklySpending,
        averageMonthlySpending: averageMonthlySpending,
        budgetPerformance: budgetPerformance,
        recurringTransactionImpact: recurringImpact,
        categoryBreakdown: categoryBreakdown,
        transactionCount: transactions.length,
        generatedAt: now,
        lastUpdatedAt: now,
      );

      return report;
    } catch (e) {
      debugPrint('Error generating report: $e');
      rethrow;
    }
  }

  /// Calculates budget performance metrics for a specific period
  /// Returns BudgetPerformance object with detailed metrics
  static Future<BudgetPerformance> calculateBudgetPerformance({
    required String userId,
    required List<Budget> budgets,
    required List<Transaction> transactions,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      double totalBudgetAmount = 0.0;
      double totalSpentAgainstBudgets = 0.0;
      int exceededBudgets = 0;
      int metBudgets = 0;
      int underUtilizedBudgets = 0;
      final categoryPerformance = <String, double>{};

      for (final budget in budgets) {
        totalBudgetAmount += budget.amount;

        // Calculate spent amount for this budget
        final spentAmount = await _calculateSpentForBudget(
            transactions, budget, startDate, endDate);
        totalSpentAgainstBudgets += spentAmount;

        // Calculate utilization percentage
        final utilization = spentAmount / budget.amount;

        // Categorize budget performance
        if (utilization > 1.0) {
          exceededBudgets++;
        } else if (utilization >= 0.9 && utilization <= 1.0) {
          metBudgets++;
        } else {
          underUtilizedBudgets++;
        }

        // Track category performance
        if (budget.categoryId != null) {
          categoryPerformance[budget.categoryId!] = utilization;
        }
      }

      final utilizationPercentage = totalBudgetAmount > 0
          ? totalSpentAgainstBudgets / totalBudgetAmount
          : 0.0;

      return BudgetPerformance(
        totalBudgetAmount: totalBudgetAmount,
        totalSpentAgainstBudgets: totalSpentAgainstBudgets,
        utilizationPercentage: utilizationPercentage,
        exceededBudgets: exceededBudgets,
        metBudgets: metBudgets,
        underUtilizedBudgets: underUtilizedBudgets,
        categoryPerformance: categoryPerformance,
      );
    } catch (e) {
      debugPrint('Error calculating budget performance: $e');
      rethrow;
    }
  }

  /// Calculates spending trends over time
  /// Returns a map of dates to spending amounts
  static Future<Map<DateTime, double>> calculateSpendingTrends({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? categoryId,
  }) async {
    try {
      final transactions =
          await _getTransactionsInPeriod(userId, startDate, endDate);
      final trends = <DateTime, double>{};

      for (final transaction in transactions) {
        // Filter by category if specified
        if (categoryId != null && transaction.categoryId != categoryId) {
          continue;
        }

        final date = DateTime(transaction.date.year, transaction.date.month,
            transaction.date.day);
        trends[date] = (trends[date] ?? 0.0) + transaction.amount;
      }

      return trends;
    } catch (e) {
      debugPrint('Error calculating spending trends: $e');
      return {};
    }
  }

  /// Calculates category spending analysis
  /// Returns spending breakdown by category with percentages
  static Future<Map<String, Map<String, dynamic>>> calculateCategoryAnalysis({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final transactions =
          await _getTransactionsInPeriod(userId, startDate, endDate);
      final categoryTotals = <String, double>{};
      double totalSpent = 0.0;

      // Calculate totals by category
      for (final transaction in transactions) {
        final categoryId = transaction.categoryId;
        categoryTotals[categoryId] =
            (categoryTotals[categoryId] ?? 0.0) + transaction.amount;
        totalSpent += transaction.amount;
      }

      // Calculate percentages and create analysis
      final analysis = <String, Map<String, dynamic>>{};
      for (final entry in categoryTotals.entries) {
        final percentage =
            totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0.0;
        analysis[entry.key] = {
          'amount': entry.value,
          'percentage': percentage,
          'transactionCount':
              transactions.where((t) => t.categoryId == entry.key).length,
        };
      }

      return analysis;
    } catch (e) {
      debugPrint('Error calculating category analysis: $e');
      return {};
    }
  }

  /// Gets transactions within a specific period
  static Future<List<Transaction>> _getTransactionsInPeriod(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .get();

      return snapshot.docs
          .map((doc) => Transaction.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting transactions in period: $e');
      return [];
    }
  }

  /// Gets budgets that overlap with a specific period
  static Future<List<Budget>> _getBudgetsInPeriod(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allBudgets = await BudgetService.getAllBudgets(userId);
      return allBudgets.where((budget) {
        return budget.isActive &&
            budget.startDate.isBefore(endDate) &&
            budget.endDate.isAfter(startDate);
      }).toList();
    } catch (e) {
      debugPrint('Error getting budgets in period: $e');
      return [];
    }
  }

  /// Calculates total spent amount from transactions
  static double _calculateTotalSpent(List<Transaction> transactions) {
    return transactions.fold(
        0.0, (sum, transaction) => sum + transaction.amount);
  }

  /// Calculates average daily spending
  static double _calculateAverageDailySpending(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final totalSpent = _calculateTotalSpent(transactions);
    final days = endDate.difference(startDate).inDays + 1;
    return days > 0 ? totalSpent / days : 0.0;
  }

  /// Calculates average weekly spending
  static double _calculateAverageWeeklySpending(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final totalSpent = _calculateTotalSpent(transactions);
    final weeks = (endDate.difference(startDate).inDays + 1) / 7;
    return weeks > 0 ? totalSpent / weeks : 0.0;
  }

  /// Calculates average monthly spending
  static double _calculateAverageMonthlySpending(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final totalSpent = _calculateTotalSpent(transactions);
    final months = ((endDate.year - startDate.year) * 12) +
        (endDate.month - startDate.month) +
        1;
    return months > 0 ? totalSpent / months : 0.0;
  }

  /// Calculates budget performance for a specific period
  static Future<BudgetPerformance> _calculateBudgetPerformance(
    String userId,
    List<Budget> budgets,
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await calculateBudgetPerformance(
      userId: userId,
      budgets: budgets,
      transactions: transactions,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Calculates recurring transaction impact
  static RecurringTransactionImpact _calculateRecurringTransactionImpact(
    List<Transaction> transactions,
  ) {
    final recurringTransactions =
        transactions.where((t) => t.recurring).toList();
    final totalSpent = _calculateTotalSpent(transactions);
    final recurringAmount = _calculateTotalSpent(recurringTransactions);

    final recurringByCategory = <String, double>{};
    for (final transaction in recurringTransactions) {
      recurringByCategory[transaction.categoryId] =
          (recurringByCategory[transaction.categoryId] ?? 0.0) +
              transaction.amount;
    }

    return RecurringTransactionImpact(
      totalRecurringAmount: recurringAmount,
      recurringTransactionCount: recurringTransactions.length,
      recurringPercentage: totalSpent > 0 ? recurringAmount / totalSpent : 0.0,
      recurringByCategory: recurringByCategory,
      contributingRecurringIds:
          recurringTransactions.map<String>((t) => t.id).toList(),
    );
  }

  /// Calculates category breakdown
  static Map<String, double> _calculateCategoryBreakdown(
      List<Transaction> transactions) {
    final breakdown = <String, double>{};
    for (final transaction in transactions) {
      breakdown[transaction.categoryId] =
          (breakdown[transaction.categoryId] ?? 0.0) + transaction.amount;
    }
    return breakdown;
  }

  /// Calculates spent amount for a specific budget
  static Future<double> _calculateSpentForBudget(
    List<Transaction> transactions,
    Budget budget,
    DateTime startDate,
    DateTime endDate,
  ) async {
    double spent = 0.0;

    for (final transaction in transactions) {
      // Check if transaction is within budget period
      if (transaction.date
              .isAfter(budget.startDate.subtract(Duration(days: 1))) &&
          transaction.date.isBefore(budget.endDate.add(Duration(days: 1)))) {
        // Check if transaction matches budget criteria
        if (budget.type == BudgetType.OVERALL) {
          spent += transaction.amount;
        } else if (budget.type == BudgetType.CATEGORY &&
            budget.categoryId == transaction.categoryId) {
          spent += transaction.amount;
        }
      }
    }

    return spent;
  }
}
