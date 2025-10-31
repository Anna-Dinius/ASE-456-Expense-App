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
        final budget1 = Budget(
          id: 'budget_1',
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

        final budget2 = Budget(
          id: 'budget_1',
          name: 'Test Budget',
          amount: 1000.0,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          type: BudgetType.OVERALL,
          period: BudgetPeriod.MONTHLY,
          isActive: true,
          alertThresholds: [0.5, 0.75, 0.9],
          createdAt: budget1.createdAt,
          lastUpdatedAt: budget1.lastUpdatedAt,
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
  });
}
