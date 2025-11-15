import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/model/transaction.dart';
import 'package:p5_expense/model/budget.dart';
import '../helpers/analytics_test_helpers.dart';

void main() {
  group('AnalyticsService Calculation Logic Tests', () {
    // Note: These tests focus on calculation logic that can be tested without Firestore
    // Integration tests with Firestore would require Firebase emulators or refactoring
    // AnalyticsService to support dependency injection

    group('Category Analysis Calculations', () {
      test('should calculate category breakdown correctly', () {
        final transactions = [
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx1',
            amount: 100.0,
            categoryId: 'food',
          ),
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx2',
            amount: 50.0,
            categoryId: 'transport',
          ),
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx3',
            amount: 75.0,
            categoryId: 'food',
          ),
        ];

        final breakdown = AnalyticsTestHelpers.calculateCategoryBreakdown(transactions);
        
        expect(breakdown['food'], 175.0);
        expect(breakdown['transport'], 50.0);
        expect(breakdown.length, 2);
      });

      test('should calculate category analysis with percentages', () {
        final transactions = [
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx1',
            amount: 100.0,
            categoryId: 'food',
          ),
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx2',
            amount: 50.0,
            categoryId: 'transport',
          ),
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx3',
            amount: 75.0,
            categoryId: 'food',
          ),
        ];

        final analysis = AnalyticsTestHelpers.calculateCategoryAnalysis(transactions);
        
        expect(analysis['food']!['amount'], 175.0);
        expect(analysis['transport']!['amount'], 50.0);
        expect(analysis['food']!['percentage'], closeTo(77.78, 0.01));
        expect(analysis['transport']!['percentage'], closeTo(22.22, 0.01));
        expect(analysis['food']!['transactionCount'], 2);
        expect(analysis['transport']!['transactionCount'], 1);
      });

      test('should handle empty transaction list', () {
        final transactions = <Transaction>[];
        final analysis = AnalyticsTestHelpers.calculateCategoryAnalysis(transactions);
        
        expect(analysis.isEmpty, true);
      });

      test('should calculate percentages that sum to 100%', () {
        final transactions = [
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx1',
            amount: 100.0,
            categoryId: 'food',
          ),
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx2',
            amount: 50.0,
            categoryId: 'transport',
          ),
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx3',
            amount: 75.0,
            categoryId: 'bills',
          ),
        ];

        final analysis = AnalyticsTestHelpers.calculateCategoryAnalysis(transactions);
        
        double totalPercentage = 0.0;
        for (final entry in analysis.values) {
          totalPercentage += entry['percentage'] as double;
        }
        
        expect(totalPercentage, closeTo(100.0, 0.01));
      });
    });

    group('Spending Trends Calculations', () {
      test('should group spending by date', () {
        final date1 = DateTime(2024, 10, 5);
        final date2 = DateTime(2024, 10, 10);
        final date3 = DateTime(2024, 10, 5); // Same day as date1

        final transactions = [
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx1',
            amount: 100.0,
            date: date1,
          ),
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx2',
            amount: 50.0,
            date: date2,
          ),
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx3',
            amount: 75.0,
            date: date3,
          ),
        ];

        final trends = AnalyticsTestHelpers.calculateSpendingTrends(transactions);
        
        expect(trends.length, 2);
        expect(trends[DateTime(2024, 10, 5)], 175.0); // Combined amount for same day
        expect(trends[DateTime(2024, 10, 10)], 50.0);
      });

      test('should filter by category when categoryId is provided', () {
        final transactions = [
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx1',
            amount: 100.0,
            categoryId: 'food',
          ),
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx2',
            amount: 50.0,
            categoryId: 'transport',
          ),
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx3',
            amount: 75.0,
            categoryId: 'food',
          ),
        ];

        final trends = AnalyticsTestHelpers.calculateSpendingTrends(
          transactions,
          categoryId: 'food',
        );
        
        // Should only include food transactions
        final total = trends.values.fold(0.0, (sum, amount) => sum + amount);
        expect(total, 175.0);
      });
    });

    group('Budget Utilization Calculations', () {
      test('should calculate budget utilization correctly', () {
        final budget = AnalyticsTestHelpers.createTestBudget(
          id: 'budget1',
          amount: 500.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
        );

        final transactions = [
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx1',
            amount: 250.0,
            date: DateTime(2024, 10, 5),
          ),
        ];

        final utilization = AnalyticsTestHelpers.calculateBudgetUtilization(budget, transactions);
        
        expect(utilization, 0.5); // 250 / 500 = 0.5
      });

      test('should handle exceeded budgets', () {
        final budget = AnalyticsTestHelpers.createTestBudget(
          id: 'budget1',
          amount: 100.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
        );

        final transactions = [
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx1',
            amount: 150.0,
            date: DateTime(2024, 10, 5),
          ),
        ];

        final utilization = AnalyticsTestHelpers.calculateBudgetUtilization(budget, transactions);
        
        expect(utilization, 1.5); // 150 / 100 = 1.5 (exceeded)
      });

      test('should filter transactions by date range', () {
        final budget = AnalyticsTestHelpers.createTestBudget(
          id: 'budget1',
          amount: 500.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
        );

        final transactions = [
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx1',
            amount: 100.0,
            date: DateTime(2024, 9, 30), // Before budget period
          ),
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx2',
            amount: 200.0,
            date: DateTime(2024, 10, 15), // Within budget period
          ),
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx3',
            amount: 50.0,
            date: DateTime(2024, 11, 1), // After budget period
          ),
        ];

        final utilization = AnalyticsTestHelpers.calculateBudgetUtilization(budget, transactions);
        
        // Should only count transaction within period (200.0)
        expect(utilization, 0.4); // 200 / 500 = 0.4
      });

      test('should filter by category for category-specific budgets', () {
        final budget = AnalyticsTestHelpers.createTestBudget(
          id: 'budget1',
          amount: 500.0,
          categoryId: 'food',
          type: BudgetType.CATEGORY,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
        );

        final transactions = [
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx1',
            amount: 100.0,
            categoryId: 'food',
            date: DateTime(2024, 10, 5),
          ),
          AnalyticsTestHelpers.createTestTransaction(
            id: 'tx2',
            amount: 200.0,
            categoryId: 'transport',
            date: DateTime(2024, 10, 10),
          ),
        ];

        final utilization = AnalyticsTestHelpers.calculateBudgetUtilization(budget, transactions);
        
        // Should only count food transactions (100.0)
        expect(utilization, 0.2); // 100 / 500 = 0.2
      });
    });

    group('Total Spent Calculations', () {
      test('should calculate total spent correctly', () {
        final transactions = [
          AnalyticsTestHelpers.createTestTransaction(id: 'tx1', amount: 100.0),
          AnalyticsTestHelpers.createTestTransaction(id: 'tx2', amount: 50.0),
          AnalyticsTestHelpers.createTestTransaction(id: 'tx3', amount: 75.0),
        ];

        final total = AnalyticsTestHelpers.calculateTotalSpent(transactions);
        
        expect(total, 225.0);
      });

      test('should handle empty transaction list', () {
        final transactions = <Transaction>[];
        final total = AnalyticsTestHelpers.calculateTotalSpent(transactions);
        
        expect(total, 0.0);
      });

      test('should handle single transaction', () {
        final transactions = [
          AnalyticsTestHelpers.createTestTransaction(id: 'tx1', amount: 100.0),
        ];

        final total = AnalyticsTestHelpers.calculateTotalSpent(transactions);
        
        expect(total, 100.0);
      });
    });

    group('Edge Cases', () {
      test('should handle zero amounts', () {
        final transactions = [
          AnalyticsTestHelpers.createTestTransaction(id: 'tx1', amount: 0.0),
          AnalyticsTestHelpers.createTestTransaction(id: 'tx2', amount: 100.0),
        ];

        final total = AnalyticsTestHelpers.calculateTotalSpent(transactions);
        expect(total, 100.0);
      });

      test('should handle single category', () {
        final transactions = [
          AnalyticsTestHelpers.createTestTransaction(id: 'tx1', amount: 100.0, categoryId: 'food'),
          AnalyticsTestHelpers.createTestTransaction(id: 'tx2', amount: 50.0, categoryId: 'food'),
        ];

        final analysis = AnalyticsTestHelpers.calculateCategoryAnalysis(transactions);
        
        expect(analysis.length, 1);
        expect(analysis['food']!['percentage'], 100.0);
      });

      test('should handle very large amounts', () {
        final transactions = [
          AnalyticsTestHelpers.createTestTransaction(id: 'tx1', amount: 999999.99),
        ];

        final total = AnalyticsTestHelpers.calculateTotalSpent(transactions);
        
        expect(total, 999999.99);
      });
    });

    group('Data Accuracy', () {
      test('category totals should match transaction sums', () {
        final transactions = [
          AnalyticsTestHelpers.createTestTransaction(id: 'tx1', amount: 100.0, categoryId: 'food'),
          AnalyticsTestHelpers.createTestTransaction(id: 'tx2', amount: 50.0, categoryId: 'transport'),
          AnalyticsTestHelpers.createTestTransaction(id: 'tx3', amount: 75.0, categoryId: 'food'),
        ];

        final breakdown = AnalyticsTestHelpers.calculateCategoryBreakdown(transactions);
        final total = AnalyticsTestHelpers.calculateTotalSpent(transactions);
        final sumOfBreakdown = breakdown.values.fold(0.0, (sum, amount) => sum + amount);
        
        expect(sumOfBreakdown, total);
      });

      test('percentages should sum to 100% for multiple categories', () {
        final transactions = [
          AnalyticsTestHelpers.createTestTransaction(id: 'tx1', amount: 100.0, categoryId: 'food'),
          AnalyticsTestHelpers.createTestTransaction(id: 'tx2', amount: 50.0, categoryId: 'transport'),
          AnalyticsTestHelpers.createTestTransaction(id: 'tx3', amount: 75.0, categoryId: 'bills'),
        ];

        final analysis = AnalyticsTestHelpers.calculateCategoryAnalysis(transactions);
        final totalPercentage = analysis.values.fold(
          0.0,
          (sum, data) => sum + (data['percentage'] as double),
        );
        
        expect(totalPercentage, closeTo(100.0, 0.01));
      });
    });
  });

  group('AnalyticsService Integration Tests', () {
    // Note: Full integration tests require Firebase emulators or refactoring
    // AnalyticsService to support dependency injection with fake_cloud_firestore
    // These tests would verify:
    // - Firestore query accuracy
    // - Date range filtering with Firestore
    // - Budget performance calculations with real Firestore data
    // - Error handling for Firestore failures
    
    test('Integration tests require Firebase emulators or service refactoring', () {
      // Placeholder test - actual integration tests would go here
      // To implement full integration tests:
      // 1. Refactor AnalyticsService to accept Firestore instance as parameter
      // 2. Use fake_cloud_firestore in tests
      // 3. Test end-to-end data flow with mocked Firestore
      expect(true, true);
    });
  });
}
