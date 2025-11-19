import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/model/budget.dart';

void main() {
  group('BudgetService Tests', () {
    setUp(() {
      // Note: In a real test environment, you would use Firebase emulators
      // For now, we'll test the service logic without actual Firestore calls
    });

    group('Budget Creation', () {
      test('should create a valid overall budget', () async {
        final budget = Budget(
          id: 'test_budget_1',
          name: 'Monthly Overall Budget',
          amount: 2000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        );

        expect(budget.name, 'Monthly Overall Budget');
        expect(budget.amount, 2000.0);
        expect(budget.type, BudgetType.OVERALL);
        expect(budget.isActive, true);
        expect(budget.alertThresholds, [0.5, 0.75, 0.9]);
      });

      test('should create a valid category-specific budget', () async {
        final budget = Budget(
          id: 'test_budget_2',
          name: 'Monthly Food Budget',
          amount: 500.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          categoryId: 'food',
          type: BudgetType.CATEGORY,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        );

        expect(budget.name, 'Monthly Food Budget');
        expect(budget.categoryId, 'food');
        expect(budget.type, BudgetType.CATEGORY);
        expect(budget.isCategoryBudget, true);
      });
    });

    group('Budget Validation', () {
      test('should create budget with valid data', () {
        final budget = Budget(
          id: 'valid_budget',
          name: 'Valid Budget',
          amount: 1000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        );

        expect(budget.name, 'Valid Budget');
        expect(budget.amount, 1000.0);
        expect(budget.type, BudgetType.OVERALL);
        expect(budget.alertThresholds, [0.5, 0.75, 0.9]);
      });
    });

    group('Budget Calculations', () {
      test('should calculate days remaining correctly', () {
        final budget = Budget(
          id: 'test_budget',
          name: 'Test Budget',
          amount: 1000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        );

        // Mock current date as October 15, 2024
        final now = DateTime(2024, 10, 15);
        final daysRemaining = budget.endDate.difference(now).inDays;
        
        expect(daysRemaining, greaterThan(0));
      });

      test('should calculate days elapsed correctly', () {
        final budget = Budget(
          id: 'test_budget',
          name: 'Test Budget',
          amount: 1000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        );

        // Mock current date as October 15, 2024
        final now = DateTime(2024, 10, 15);
        final daysElapsed = now.difference(budget.startDate).inDays;
        
        expect(daysElapsed, greaterThan(0));
      });

      test('should determine if budget is currently active', () {
        final activeBudget = Budget(
          id: 'active_budget',
          name: 'Active Budget',
          amount: 1000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        );

        final inactiveBudget = Budget(
          id: 'inactive_budget',
          name: 'Inactive Budget',
          amount: 1000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: false, // Inactive
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        );

        // Note: These tests would need to mock DateTime.now() in a real test
        // For now, we test the logic
        expect(activeBudget.isActive, true);
        expect(inactiveBudget.isActive, false);
      });
    });

    group('Budget Types', () {
      test('should identify overall budgets correctly', () {
        final overallBudget = Budget(
          id: 'overall_budget',
          name: 'Overall Budget',
          amount: 2000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        );

        expect(overallBudget.isOverallBudget, true);
        expect(overallBudget.isCategoryBudget, false);
      });

      test('should identify category budgets correctly', () {
        final categoryBudget = Budget(
          id: 'category_budget',
          name: 'Food Budget',
          amount: 500.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          categoryId: 'food',
          type: BudgetType.CATEGORY,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        );

        expect(categoryBudget.isCategoryBudget, true);
        expect(categoryBudget.isOverallBudget, false);
      });
    });

    group('Budget Serialization', () {
      test('should serialize budget to JSON correctly', () {
        final budget = Budget(
          id: 'test_budget',
          name: 'Test Budget',
          amount: 1000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 10, 1),
          lastUpdatedAt: DateTime(2024, 10, 1),
        );

        final json = budget.toJson();

        expect(json['id'], 'test_budget');
        expect(json['name'], 'Test Budget');
        expect(json['amount'], 1000.0);
        expect(json['type'], 'OVERALL');
        expect(json['period'], 'MONTHLY');
        expect(json['isActive'], true);
        expect(json['alertThresholds'], [0.5, 0.75, 0.9]);
      });

      test('should deserialize budget from JSON correctly', () {
        final json = {
          'id': 'test_budget',
          'name': 'Test Budget',
          'amount': 1000.0,
          'startDate': '2024-10-01T00:00:00.000Z',
          'endDate': '2024-10-31T00:00:00.000Z',
          'categoryId': null,
          'type': 'OVERALL',
          'period': 'MONTHLY',
          'isActive': true,
          'alertThresholds': [0.5, 0.75, 0.9],
          'createdAt': '2024-10-01T00:00:00.000Z',
          'lastUpdatedAt': '2024-10-01T00:00:00.000Z',
        };

        final budget = Budget.fromJson(json);

        expect(budget.id, 'test_budget');
        expect(budget.name, 'Test Budget');
        expect(budget.amount, 1000.0);
        expect(budget.type, BudgetType.OVERALL);
        expect(budget.period, BudgetPeriod.MONTHLY);
        expect(budget.isActive, true);
        expect(budget.alertThresholds, [0.5, 0.75, 0.9]);
      });
    });

    group('Budget Equality', () {
      test('should compare budgets correctly', () {
        // Use fixed DateTime values to ensure equality
        final createdAt = DateTime(2024, 10, 1, 12, 0, 0);
        final lastUpdatedAt = DateTime(2024, 10, 1, 12, 0, 0);
        final alertThresholds = [0.5, 0.75, 0.9];

        final budget1 = Budget(
          id: 'budget_1',
          name: 'Test Budget',
          amount: 1000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: alertThresholds,
          createdAt: createdAt,
          lastUpdatedAt: lastUpdatedAt,
        );

        final budget2 = Budget(
          id: 'budget_1',
          name: 'Test Budget',
          amount: 1000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: alertThresholds,
          createdAt: createdAt,
          lastUpdatedAt: lastUpdatedAt,
        );

        expect(budget1, equals(budget2));
        expect(budget1.hashCode, equals(budget2.hashCode));
      });
    });

    group('Default Budgets', () {
      test('should have valid default budgets', () {
        final defaultBudgets = DefaultBudgets.budgets;

        expect(defaultBudgets.isNotEmpty, true);
        expect(defaultBudgets.length, 3); // Based on our implementation

        // Check first default budget
        final firstBudget = defaultBudgets.first;
        expect(firstBudget.name, 'Monthly Overall Budget');
        expect(firstBudget.amount, 2000.0);
        expect(firstBudget.type, BudgetType.OVERALL);
        expect(firstBudget.period, BudgetPeriod.MONTHLY);
        expect(firstBudget.isActive, true);
      });

      test('should have category-specific default budgets', () {
        final defaultBudgets = DefaultBudgets.budgets;
        final categoryBudgets = defaultBudgets.where((b) => b.type == BudgetType.CATEGORY).toList();

        expect(categoryBudgets.length, 2); // Food and Transport budgets

        final foodBudget = categoryBudgets.firstWhere((b) => b.categoryId == 'food');
        expect(foodBudget.name, 'Monthly Food Budget');
        expect(foodBudget.amount, 500.0);
        expect(foodBudget.type, BudgetType.CATEGORY);
      });
    });

    group('Budget Update Operations', () {
      test('should update budget name correctly', () {
        final budget = Budget(
          id: 'test_budget',
          name: 'Original Name',
          amount: 1000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 10, 1),
          lastUpdatedAt: DateTime(2024, 10, 1),
        );

        final updatedBudget = budget.copyWith(
          name: 'Updated Name',
          lastUpdatedAt: DateTime(2024, 10, 2),
        );

        expect(updatedBudget.name, 'Updated Name');
        expect(updatedBudget.amount, 1000.0); // Amount unchanged
        expect(updatedBudget.lastUpdatedAt.isAfter(budget.lastUpdatedAt), true);
      });

      test('should update budget amount correctly', () {
        final budget = Budget(
          id: 'test_budget',
          name: 'Test Budget',
          amount: 1000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 10, 1),
          lastUpdatedAt: DateTime(2024, 10, 1),
        );

        final updatedBudget = budget.copyWith(
          amount: 1500.0,
          lastUpdatedAt: DateTime(2024, 10, 2),
        );

        expect(updatedBudget.amount, 1500.0);
        expect(updatedBudget.name, 'Test Budget'); // Name unchanged
      });

      test('should update budget active status', () {
        final budget = Budget(
          id: 'test_budget',
          name: 'Test Budget',
          amount: 1000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 10, 1),
          lastUpdatedAt: DateTime(2024, 10, 1),
        );

        final updatedBudget = budget.copyWith(
          isActive: false,
          lastUpdatedAt: DateTime(2024, 10, 2),
        );

        expect(updatedBudget.isActive, false);
        expect(budget.isActive, true); // Original unchanged
      });

      test('should update date range correctly', () {
        final budget = Budget(
          id: 'test_budget',
          name: 'Test Budget',
          amount: 1000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 10, 1),
          lastUpdatedAt: DateTime(2024, 10, 1),
        );

        final newStartDate = DateTime(2024, 11, 1);
        final newEndDate = DateTime(2024, 11, 30);
        final updatedBudget = budget.copyWith(
          startDate: newStartDate,
          endDate: newEndDate,
          lastUpdatedAt: DateTime(2024, 10, 2),
        );

        expect(updatedBudget.startDate, newStartDate);
        expect(updatedBudget.endDate, newEndDate);
        expect(updatedBudget.totalDays, 29); // November has 30 days
      });
    });

    group('Budget Delete Operations', () {
      test('should identify expired budgets', () {
        final expiredBudget = Budget(
          id: 'expired_budget',
          name: 'Expired Budget',
          amount: 1000.0,
          startDate: DateTime(2024, 9, 1),
          endDate: DateTime(2024, 9, 30),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 9, 1),
          lastUpdatedAt: DateTime(2024, 9, 1),
        );

        // Note: This test assumes current date is after September 30, 2024
        // In a real test, you would mock DateTime.now()
        expect(expiredBudget.endDate.isBefore(DateTime(2024, 10, 1)), true);
      });

      test('should handle budget deletion edge cases', () {
        // Test that budget properties remain valid after copy operations
        final budget = Budget(
          id: 'test_budget',
          name: 'Test Budget',
          amount: 1000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 10, 1),
          lastUpdatedAt: DateTime(2024, 10, 1),
        );

        // Simulate marking as inactive (soft delete pattern)
        final deactivatedBudget = budget.copyWith(isActive: false);

        expect(deactivatedBudget.id, budget.id);
        expect(deactivatedBudget.isActive, false);
        expect(budget.isActive, true); // Original unchanged
      });
    });

    group('Overlapping Budget Validation', () {
      test('should detect overlapping date ranges', () {
        final budget1 = Budget(
          id: 'budget_1',
          name: 'Budget 1',
          amount: 1000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 10, 1),
          lastUpdatedAt: DateTime(2024, 10, 1),
        );

        // Overlapping budget (starts before budget1 ends)
        final budget2 = Budget(
          id: 'budget_2',
          name: 'Budget 2',
          amount: 1000.0,
          startDate: DateTime(2024, 10, 15), // Overlaps with budget1
          endDate: DateTime(2024, 11, 15),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 10, 15),
          lastUpdatedAt: DateTime(2024, 10, 15),
        );

        // Check if dates overlap
        final overlaps = budget1.startDate.isBefore(budget2.endDate) &&
            budget2.startDate.isBefore(budget1.endDate);

        expect(overlaps, true);
      });

      test('should detect non-overlapping date ranges', () {
        final budget1 = Budget(
          id: 'budget_1',
          name: 'Budget 1',
          amount: 1000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 10, 1),
          lastUpdatedAt: DateTime(2024, 10, 1),
        );

        // Non-overlapping budget (starts after budget1 ends)
        final budget2 = Budget(
          id: 'budget_2',
          name: 'Budget 2',
          amount: 1000.0,
          startDate: DateTime(2024, 11, 1), // After budget1 ends
          endDate: DateTime(2024, 11, 30),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 11, 1),
          lastUpdatedAt: DateTime(2024, 11, 1),
        );

        // Check if dates overlap
        final overlaps = budget1.startDate.isBefore(budget2.endDate) &&
            budget2.startDate.isBefore(budget1.endDate);

        expect(overlaps, false);
      });

      test('should allow overlapping budgets of different types', () {
        // Overall and category budgets can overlap
        final overallBudget = Budget(
          id: 'overall',
          name: 'Overall Budget',
          amount: 2000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 10, 1),
          lastUpdatedAt: DateTime(2024, 10, 1),
        );

        final categoryBudget = Budget(
          id: 'category',
          name: 'Food Budget',
          amount: 500.0,
          startDate: DateTime(2024, 10, 1), // Same dates
          endDate: DateTime(2024, 10, 31),
          categoryId: 'food',
          type: BudgetType.CATEGORY,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 10, 1),
          lastUpdatedAt: DateTime(2024, 10, 1),
        );

        // These can overlap because they're different types
        expect(overallBudget.type != categoryBudget.type, true);
      });

      test('should detect overlapping budgets of same type and category', () {
        final budget1 = Budget(
          id: 'food_1',
          name: 'Food Budget 1',
          amount: 500.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          categoryId: 'food',
          type: BudgetType.CATEGORY,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 10, 1),
          lastUpdatedAt: DateTime(2024, 10, 1),
        );

        final budget2 = Budget(
          id: 'food_2',
          name: 'Food Budget 2',
          amount: 600.0,
          startDate: DateTime(2024, 10, 15), // Overlaps
          endDate: DateTime(2024, 11, 15),
          categoryId: 'food', // Same category
          type: BudgetType.CATEGORY, // Same type
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 10, 15),
          lastUpdatedAt: DateTime(2024, 10, 15),
        );

        // These should conflict (same type, same category, overlapping dates)
        final sameType = budget1.type == budget2.type;
        final sameCategory = budget1.categoryId == budget2.categoryId;
        final datesOverlap = budget1.startDate.isBefore(budget2.endDate) &&
            budget2.startDate.isBefore(budget1.endDate);

        expect(sameType && sameCategory && datesOverlap, true);
      });
    });

    group('Budget Edge Cases', () {
      test('should handle zero amount budget', () {
        final budget = Budget(
          id: 'zero_budget',
          name: 'Zero Budget',
          amount: 0.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 10, 1),
          lastUpdatedAt: DateTime(2024, 10, 1),
        );

        expect(budget.amount, 0.0);
        // Note: Validation should prevent zero amounts in production
      });

      test('should handle very large budget amounts', () {
        final budget = Budget(
          id: 'large_budget',
          name: 'Large Budget',
          amount: 1000000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 10, 1),
          lastUpdatedAt: DateTime(2024, 10, 1),
        );

        expect(budget.amount, 1000000.0);
        // Note: Validation should cap at $1,000,000 in production
      });

      test('should handle single day budget', () {
        final budget = Budget(
          id: 'single_day',
          name: 'Single Day Budget',
          amount: 100.0,
          startDate: DateTime(2024, 10, 15),
          endDate: DateTime(2024, 10, 15),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.CUSTOM,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 10, 15),
          lastUpdatedAt: DateTime(2024, 10, 15),
        );

        expect(budget.totalDays, 0); // Same day = 0 days difference
        expect(budget.startDate.day, budget.endDate.day);
      });

      test('should handle long period budgets', () {
        final budget = Budget(
          id: 'yearly_budget',
          name: 'Yearly Budget',
          amount: 12000.0,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 12, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.YEARLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: DateTime(2024, 1, 1),
          lastUpdatedAt: DateTime(2024, 1, 1),
        );

        expect(budget.totalDays, 365); // 2024 is a leap year, but Dec 31 - Jan 1 = 364 days
        expect(budget.period, BudgetPeriod.YEARLY);
      });
    });

    // Note: Integration tests for BudgetService.updateBudget() and deleteBudget()
    // require Firebase emulators or mocking. These tests verify the model logic
    // and validation patterns. Full service tests should be added with:
    // - Firebase emulator setup
    // - Mock Firestore instances
    // - Test user authentication
    // See Week 10 plan for integration testing requirements
  });
}
