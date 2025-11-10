import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/model/report.dart';

void main() {
  group('ReportService Tests', () {
    setUp(() {
      // Note: In a real test environment, you would use Firebase emulators
      // For now, we'll test the Report model serialization and logic
    });

    group('Report Model Serialization', () {
      test('should create a valid report with all fields', () {
        final report = Report(
          id: 'test_report_1',
          period: 'Weekly Report - Nov 2024',
          startDate: DateTime(2024, 11, 1),
          endDate: DateTime(2024, 11, 7),
          totalSpent: 500.0,
          averageDailySpending: 71.43,
          averageWeeklySpending: 500.0,
          averageMonthlySpending: 2142.86,
          budgetPerformance: BudgetPerformance(
            totalBudgetAmount: 1000.0,
            totalSpentAgainstBudgets: 500.0,
            utilizationPercentage: 0.5,
            exceededBudgets: 0,
            metBudgets: 0,
            underUtilizedBudgets: 1,
            categoryPerformance: {'food': 0.5},
          ),
          recurringTransactionImpact: RecurringTransactionImpact(
            totalRecurringAmount: 200.0,
            recurringTransactionCount: 5,
            recurringPercentage: 0.4,
            recurringByCategory: {'food': 200.0},
            contributingRecurringIds: ['tx1', 'tx2'],
          ),
          categoryBreakdown: {'food': 300.0, 'transport': 200.0},
          transactionCount: 10,
          generatedAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        );

        expect(report.id, 'test_report_1');
        expect(report.period, 'Weekly Report - Nov 2024');
        expect(report.totalSpent, 500.0);
        expect(report.transactionCount, 10);
        expect(report.budgetPerformance.utilizationPercentage, 0.5);
        expect(report.recurringTransactionImpact.recurringPercentage, 0.4);
        expect(report.categoryBreakdown.length, 2);
      });

      test('should serialize and deserialize report to/from map', () {
        final originalReport = Report(
          id: 'test_report_2',
          period: 'Monthly Report - Oct 2024',
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          totalSpent: 2000.0,
          averageDailySpending: 64.52,
          averageWeeklySpending: 451.61,
          averageMonthlySpending: 2000.0,
          budgetPerformance: BudgetPerformance(
            totalBudgetAmount: 2500.0,
            totalSpentAgainstBudgets: 2000.0,
            utilizationPercentage: 0.8,
            exceededBudgets: 0,
            metBudgets: 1,
            underUtilizedBudgets: 0,
            categoryPerformance: {'food': 0.8},
          ),
          recurringTransactionImpact: RecurringTransactionImpact(
            totalRecurringAmount: 800.0,
            recurringTransactionCount: 10,
            recurringPercentage: 0.4,
            recurringByCategory: {'food': 800.0},
            contributingRecurringIds: ['tx1', 'tx2', 'tx3'],
          ),
          categoryBreakdown: {'food': 1200.0, 'transport': 500.0, 'bills': 300.0},
          transactionCount: 25,
          generatedAt: DateTime(2024, 11, 1, 10, 0),
          lastUpdatedAt: DateTime(2024, 11, 1, 10, 0),
        );

        // Convert to map (simulating Firestore serialization)
        final reportMap = originalReport.toMap();

        // Convert back from map (simulating Firestore deserialization)
        final deserializedReport = Report.fromMap(reportMap, 'test_report_2');

        expect(deserializedReport.id, originalReport.id);
        expect(deserializedReport.period, originalReport.period);
        expect(deserializedReport.totalSpent, originalReport.totalSpent);
        expect(deserializedReport.transactionCount, originalReport.transactionCount);
        expect(deserializedReport.budgetPerformance.utilizationPercentage,
            originalReport.budgetPerformance.utilizationPercentage);
        expect(deserializedReport.recurringTransactionImpact.recurringPercentage,
            originalReport.recurringTransactionImpact.recurringPercentage);
        expect(deserializedReport.categoryBreakdown, originalReport.categoryBreakdown);
      });

      test('should serialize and deserialize BudgetPerformance to/from map', () {
        final budgetPerformance = BudgetPerformance(
          totalBudgetAmount: 1000.0,
          totalSpentAgainstBudgets: 750.0,
          utilizationPercentage: 0.75,
          exceededBudgets: 0,
          metBudgets: 1,
          underUtilizedBudgets: 0,
          categoryPerformance: {'food': 0.75, 'transport': 0.5},
        );

        final map = budgetPerformance.toMap();
        final deserialized = BudgetPerformance.fromMap(map);

        expect(deserialized.totalBudgetAmount, budgetPerformance.totalBudgetAmount);
        expect(deserialized.totalSpentAgainstBudgets, budgetPerformance.totalSpentAgainstBudgets);
        expect(deserialized.utilizationPercentage, budgetPerformance.utilizationPercentage);
        expect(deserialized.exceededBudgets, budgetPerformance.exceededBudgets);
        expect(deserialized.metBudgets, budgetPerformance.metBudgets);
        expect(deserialized.underUtilizedBudgets, budgetPerformance.underUtilizedBudgets);
        expect(deserialized.categoryPerformance, budgetPerformance.categoryPerformance);
      });

      test('should serialize and deserialize RecurringTransactionImpact to/from map', () {
        final impact = RecurringTransactionImpact(
          totalRecurringAmount: 500.0,
          recurringTransactionCount: 8,
          recurringPercentage: 0.5,
          recurringByCategory: {'food': 300.0, 'bills': 200.0},
          contributingRecurringIds: ['tx1', 'tx2', 'tx3', 'tx4'],
        );

        final map = impact.toMap();
        final deserialized = RecurringTransactionImpact.fromMap(map);

        expect(deserialized.totalRecurringAmount, impact.totalRecurringAmount);
        expect(deserialized.recurringTransactionCount, impact.recurringTransactionCount);
        expect(deserialized.recurringPercentage, impact.recurringPercentage);
        expect(deserialized.recurringByCategory, impact.recurringByCategory);
        expect(deserialized.contributingRecurringIds, impact.contributingRecurringIds);
      });
    });

    group('Report Calculations', () {
      test('should calculate days in period correctly', () {
        final report = Report(
          id: 'test_report',
          period: 'Weekly Report',
          startDate: DateTime(2024, 11, 1),
          endDate: DateTime(2024, 11, 7),
          totalSpent: 500.0,
          averageDailySpending: 71.43,
          averageWeeklySpending: 500.0,
          averageMonthlySpending: 2142.86,
          budgetPerformance: BudgetPerformance(
            totalBudgetAmount: 1000.0,
            totalSpentAgainstBudgets: 500.0,
            utilizationPercentage: 0.5,
            exceededBudgets: 0,
            metBudgets: 0,
            underUtilizedBudgets: 1,
            categoryPerformance: {},
          ),
          recurringTransactionImpact: RecurringTransactionImpact(
            totalRecurringAmount: 200.0,
            recurringTransactionCount: 5,
            recurringPercentage: 0.4,
            recurringByCategory: {},
            contributingRecurringIds: [],
          ),
          categoryBreakdown: {},
          transactionCount: 10,
          generatedAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        );

        expect(report.daysInPeriod, 7);
        expect(report.weeksInPeriod, 1);
      });

      test('should calculate weeks in period correctly for multi-week period', () {
        final report = Report(
          id: 'test_report',
          period: 'Monthly Report',
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          totalSpent: 2000.0,
          averageDailySpending: 64.52,
          averageWeeklySpending: 451.61,
          averageMonthlySpending: 2000.0,
          budgetPerformance: BudgetPerformance(
            totalBudgetAmount: 2500.0,
            totalSpentAgainstBudgets: 2000.0,
            utilizationPercentage: 0.8,
            exceededBudgets: 0,
            metBudgets: 1,
            underUtilizedBudgets: 0,
            categoryPerformance: {},
          ),
          recurringTransactionImpact: RecurringTransactionImpact(
            totalRecurringAmount: 800.0,
            recurringTransactionCount: 10,
            recurringPercentage: 0.4,
            recurringByCategory: {},
            contributingRecurringIds: [],
          ),
          categoryBreakdown: {},
          transactionCount: 25,
          generatedAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        );

        expect(report.daysInPeriod, 31);
        expect(report.weeksInPeriod, 5); // 31 days / 7 = 5 weeks (rounded up)
        expect(report.monthsInPeriod, 1);
      });

      test('should calculate months in period correctly', () {
        final report = Report(
          id: 'test_report',
          period: 'Quarterly Report',
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 12, 31),
          totalSpent: 6000.0,
          averageDailySpending: 65.57,
          averageWeeklySpending: 459.02,
          averageMonthlySpending: 2000.0,
          budgetPerformance: BudgetPerformance(
            totalBudgetAmount: 7500.0,
            totalSpentAgainstBudgets: 6000.0,
            utilizationPercentage: 0.8,
            exceededBudgets: 0,
            metBudgets: 1,
            underUtilizedBudgets: 0,
            categoryPerformance: {},
          ),
          recurringTransactionImpact: RecurringTransactionImpact(
            totalRecurringAmount: 2400.0,
            recurringTransactionCount: 30,
            recurringPercentage: 0.4,
            recurringByCategory: {},
            contributingRecurringIds: [],
          ),
          categoryBreakdown: {},
          transactionCount: 75,
          generatedAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        );

        expect(report.monthsInPeriod, 3);
      });
    });

    group('Report Edge Cases', () {
      test('should handle report with zero spending', () {
        final report = Report(
          id: 'test_report',
          period: 'Empty Report',
          startDate: DateTime(2024, 11, 1),
          endDate: DateTime(2024, 11, 7),
          totalSpent: 0.0,
          averageDailySpending: 0.0,
          averageWeeklySpending: 0.0,
          averageMonthlySpending: 0.0,
          budgetPerformance: BudgetPerformance(
            totalBudgetAmount: 1000.0,
            totalSpentAgainstBudgets: 0.0,
            utilizationPercentage: 0.0,
            exceededBudgets: 0,
            metBudgets: 0,
            underUtilizedBudgets: 1,
            categoryPerformance: {},
          ),
          recurringTransactionImpact: RecurringTransactionImpact(
            totalRecurringAmount: 0.0,
            recurringTransactionCount: 0,
            recurringPercentage: 0.0,
            recurringByCategory: {},
            contributingRecurringIds: [],
          ),
          categoryBreakdown: {},
          transactionCount: 0,
          generatedAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        );

        expect(report.totalSpent, 0.0);
        expect(report.transactionCount, 0);
        expect(report.budgetPerformance.utilizationPercentage, 0.0);
        expect(report.categoryBreakdown.isEmpty, true);
      });

      test('should handle report with exceeded budget', () {
        final report = Report(
          id: 'test_report',
          period: 'Exceeded Budget Report',
          startDate: DateTime(2024, 11, 1),
          endDate: DateTime(2024, 11, 7),
          totalSpent: 1200.0,
          averageDailySpending: 171.43,
          averageWeeklySpending: 1200.0,
          averageMonthlySpending: 5142.86,
          budgetPerformance: BudgetPerformance(
            totalBudgetAmount: 1000.0,
            totalSpentAgainstBudgets: 1200.0,
            utilizationPercentage: 1.2, // 120% utilization
            exceededBudgets: 1,
            metBudgets: 0,
            underUtilizedBudgets: 0,
            categoryPerformance: {'food': 1.2},
          ),
          recurringTransactionImpact: RecurringTransactionImpact(
            totalRecurringAmount: 400.0,
            recurringTransactionCount: 8,
            recurringPercentage: 0.33,
            recurringByCategory: {'food': 400.0},
            contributingRecurringIds: ['tx1', 'tx2'],
          ),
          categoryBreakdown: {'food': 800.0, 'transport': 400.0},
          transactionCount: 15,
          generatedAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        );

        expect(report.budgetPerformance.utilizationPercentage, greaterThan(1.0));
        expect(report.budgetPerformance.exceededBudgets, 1);
        expect(report.budgetPerformance.metBudgets, 0);
        expect(report.budgetPerformance.underUtilizedBudgets, 0);
      });

      test('should handle report with no budgets', () {
        final report = Report(
          id: 'test_report',
          period: 'No Budget Report',
          startDate: DateTime(2024, 11, 1),
          endDate: DateTime(2024, 11, 7),
          totalSpent: 500.0,
          averageDailySpending: 71.43,
          averageWeeklySpending: 500.0,
          averageMonthlySpending: 2142.86,
          budgetPerformance: BudgetPerformance(
            totalBudgetAmount: 0.0,
            totalSpentAgainstBudgets: 0.0,
            utilizationPercentage: 0.0,
            exceededBudgets: 0,
            metBudgets: 0,
            underUtilizedBudgets: 0,
            categoryPerformance: {},
          ),
          recurringTransactionImpact: RecurringTransactionImpact(
            totalRecurringAmount: 200.0,
            recurringTransactionCount: 5,
            recurringPercentage: 0.4,
            recurringByCategory: {},
            contributingRecurringIds: [],
          ),
          categoryBreakdown: {'food': 300.0, 'transport': 200.0},
          transactionCount: 10,
          generatedAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        );

        expect(report.budgetPerformance.totalBudgetAmount, 0.0);
        expect(report.budgetPerformance.utilizationPercentage, 0.0);
      });
    });

    group('Report Equality', () {
      test('should correctly compare two reports for equality', () {
        final report1 = Report(
          id: 'test_report_1',
          period: 'Test Report',
          startDate: DateTime(2024, 11, 1),
          endDate: DateTime(2024, 11, 7),
          totalSpent: 500.0,
          averageDailySpending: 71.43,
          averageWeeklySpending: 500.0,
          averageMonthlySpending: 2142.86,
          budgetPerformance: BudgetPerformance(
            totalBudgetAmount: 1000.0,
            totalSpentAgainstBudgets: 500.0,
            utilizationPercentage: 0.5,
            exceededBudgets: 0,
            metBudgets: 0,
            underUtilizedBudgets: 1,
            categoryPerformance: {},
          ),
          recurringTransactionImpact: RecurringTransactionImpact(
            totalRecurringAmount: 200.0,
            recurringTransactionCount: 5,
            recurringPercentage: 0.4,
            recurringByCategory: {},
            contributingRecurringIds: [],
          ),
          categoryBreakdown: {},
          transactionCount: 10,
          generatedAt: DateTime(2024, 11, 8, 10, 0),
          lastUpdatedAt: DateTime(2024, 11, 8, 10, 0),
        );

        final report2 = Report(
          id: 'test_report_1',
          period: 'Test Report',
          startDate: DateTime(2024, 11, 1),
          endDate: DateTime(2024, 11, 7),
          totalSpent: 500.0,
          averageDailySpending: 71.43,
          averageWeeklySpending: 500.0,
          averageMonthlySpending: 2142.86,
          budgetPerformance: BudgetPerformance(
            totalBudgetAmount: 1000.0,
            totalSpentAgainstBudgets: 500.0,
            utilizationPercentage: 0.5,
            exceededBudgets: 0,
            metBudgets: 0,
            underUtilizedBudgets: 1,
            categoryPerformance: {},
          ),
          recurringTransactionImpact: RecurringTransactionImpact(
            totalRecurringAmount: 200.0,
            recurringTransactionCount: 5,
            recurringPercentage: 0.4,
            recurringByCategory: {},
            contributingRecurringIds: [],
          ),
          categoryBreakdown: {},
          transactionCount: 10,
          generatedAt: DateTime(2024, 11, 8, 10, 0),
          lastUpdatedAt: DateTime(2024, 11, 8, 10, 0),
        );

        expect(report1, equals(report2));
        expect(report1.hashCode, equals(report2.hashCode));
      });
    });
  });
}

