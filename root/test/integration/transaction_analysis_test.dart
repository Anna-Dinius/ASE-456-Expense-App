import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/model/transaction.dart';
import 'package:p5_expense/model/category.dart';
import '../fixtures/category_test_data.dart';

void main() {
  group('Transaction Analysis and Utilities', () {
    late List<Transaction> testTransactions;
    late List<Category> testCategories;

    setUp(() {
      testCategories = [
        CategoryTestData.createTestCategory(title: 'Food', id: 'food'),
        CategoryTestData.createTestCategory(
            title: 'Transport', id: 'transport'),
        CategoryTestData.createTestCategory(
            title: 'Entertainment', id: 'entertainment'),
      ];

      testTransactions = [
        Transaction(
          id: '1',
          title: 'Lunch',
          amount: 25.50,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Taxi',
          amount: 12.00,
          date: DateTime(2024, 1, 16),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Movie',
          amount: 15.00,
          date: DateTime(2024, 1, 17),
          categoryId: 'entertainment',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '4',
          title: 'Groceries',
          amount: 85.75,
          date: DateTime(2024, 1, 18),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '5',
          title: 'Gas',
          amount: 40.00,
          date: DateTime(2024, 1, 19),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
      ];
    });

    testWidgets('Calculate total spending across all transactions',
        (WidgetTester tester) async {
      final total = testTransactions.fold<double>(
          0, (sum, transaction) => sum + transaction.amount);

      expect(total, equals(178.25));
    });

    testWidgets('Calculate average spending per transaction',
        (WidgetTester tester) async {
      final total = testTransactions.fold<double>(
          0, (sum, transaction) => sum + transaction.amount);
      final average =
          testTransactions.isEmpty ? 0 : total / testTransactions.length;

      expect(average, equals(35.65));
    });

    testWidgets('Find highest spending transaction',
        (WidgetTester tester) async {
      if (testTransactions.isEmpty) {
        expect(true, isTrue);
        return;
      }

      final highest = testTransactions.reduce(
          (current, next) => current.amount > next.amount ? current : next);

      expect(highest.title, equals('Groceries'));
      expect(highest.amount, equals(85.75));
    });

    testWidgets('Find lowest spending transaction',
        (WidgetTester tester) async {
      if (testTransactions.isEmpty) {
        expect(true, isTrue);
        return;
      }

      final lowest = testTransactions.reduce(
          (current, next) => current.amount < next.amount ? current : next);

      expect(lowest.title, equals('Taxi'));
      expect(lowest.amount, equals(12.00));
    });

    testWidgets('Calculate spending by category with totals',
        (WidgetTester tester) async {
      final categorySpending = <String, double>{};

      for (var transaction in testTransactions) {
        categorySpending[transaction.categoryId] =
            (categorySpending[transaction.categoryId] ?? 0) +
                transaction.amount;
      }

      expect(categorySpending['food'], equals(111.25));
      expect(categorySpending['transport'], equals(52.00));
      expect(categorySpending['entertainment'], equals(15.00));
    });

    testWidgets('Get transactions for specific date',
        (WidgetTester tester) async {
      final targetDate = DateTime(2024, 1, 15);
      final filtered = testTransactions
          .where((tx) =>
              tx.date.year == targetDate.year &&
              tx.date.month == targetDate.month &&
              tx.date.day == targetDate.day)
          .toList();

      expect(filtered.length, equals(1));
      expect(filtered[0].title, equals('Lunch'));
    });

    testWidgets('Get transactions for date range', (WidgetTester tester) async {
      final startDate = DateTime(2024, 1, 16);
      final endDate = DateTime(2024, 1, 18);

      final filtered = testTransactions
          .where((tx) =>
              (tx.date.isAfter(startDate) ||
                  tx.date.isAtSameMomentAs(startDate)) &&
              (tx.date.isBefore(endDate) || tx.date.isAtSameMomentAs(endDate)))
          .toList();

      expect(filtered.length, equals(3));
    });

    testWidgets('Calculate monthly spending', (WidgetTester tester) async {
      final monthlyTotals = <String, double>{};

      for (var tx in testTransactions) {
        final monthKey =
            '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}';
        monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + tx.amount;
      }

      expect(monthlyTotals.containsKey('2024-01'), isTrue);
      expect(monthlyTotals['2024-01'], equals(178.25));
    });

    testWidgets('Find most frequent category', (WidgetTester tester) async {
      final categoryCount = <String, int>{};

      for (var tx in testTransactions) {
        categoryCount[tx.categoryId] = (categoryCount[tx.categoryId] ?? 0) + 1;
      }

      final mostFrequent = categoryCount.entries.reduce(
          (current, next) => current.value > next.value ? current : next);

      // Either 'food' or 'transport' is most frequent (both appear twice)
      expect(
          [mostFrequent.key], anyOf(contains('food'), contains('transport')));
      expect(mostFrequent.value, equals(2));
    });

    testWidgets('Check if any transactions exceed threshold',
        (WidgetTester tester) async {
      final threshold = 80.0;
      final exceeding =
          testTransactions.where((tx) => tx.amount > threshold).toList();

      expect(exceeding.length, equals(1));
      expect(exceeding.any((tx) => tx.title == 'Groceries'), isTrue);
    });

    testWidgets('Get sorted transactions by amount (descending)',
        (WidgetTester tester) async {
      final sorted = List<Transaction>.from(testTransactions)
        ..sort((a, b) => b.amount.compareTo(a.amount));

      expect(sorted[0].amount, equals(85.75));
      expect(sorted[sorted.length - 1].amount, equals(12.00));
    });

    testWidgets('Get sorted transactions by date (newest first)',
        (WidgetTester tester) async {
      final sorted = List<Transaction>.from(testTransactions)
        ..sort((a, b) => b.date.compareTo(a.date));

      expect(sorted[0].date.day, equals(19));
      expect(sorted[sorted.length - 1].date.day, equals(15));
    });

    testWidgets('Calculate percentage of spending by category',
        (WidgetTester tester) async {
      final total = testTransactions.fold<double>(
          0, (sum, transaction) => sum + transaction.amount);

      final categorySpending = <String, double>{};
      for (var transaction in testTransactions) {
        categorySpending[transaction.categoryId] =
            (categorySpending[transaction.categoryId] ?? 0) +
                transaction.amount;
      }

      final foodPercentage = (categorySpending['food']! / total) * 100;

      expect(foodPercentage, closeTo(62.5, 0.1));
    });

    testWidgets('Find transactions matching multiple criteria',
        (WidgetTester tester) async {
      final filtered = testTransactions
          .where((tx) =>
              tx.categoryId == 'food' && tx.amount > 20.0 && tx.date.month == 1)
          .toList();

      expect(filtered.length, equals(2));
      expect(filtered.every((tx) => tx.categoryId == 'food'), isTrue);
    });

    testWidgets('Check if list contains duplicate IDs',
        (WidgetTester tester) async {
      final ids = testTransactions.map((tx) => tx.id).toList();
      final uniqueIds = ids.toSet();

      expect(ids.length, equals(uniqueIds.length));
    });

    testWidgets('Get distinct categories from transactions',
        (WidgetTester tester) async {
      final categories =
          testTransactions.map((tx) => tx.categoryId).toSet().toList();

      expect(categories.length, equals(3));
      expect(categories.contains('food'), isTrue);
      expect(categories.contains('transport'), isTrue);
    });

    testWidgets('Calculate running total (cumulative)',
        (WidgetTester tester) async {
      final sorted = List<Transaction>.from(testTransactions)
        ..sort((a, b) => a.date.compareTo(b.date));

      final cumulativeTotal = <int, double>{};
      double runningTotal = 0;

      for (int i = 0; i < sorted.length; i++) {
        runningTotal += sorted[i].amount;
        cumulativeTotal[i] = runningTotal;
      }

      expect(cumulativeTotal[0], equals(25.50));
      expect(cumulativeTotal[cumulativeTotal.length - 1], equals(178.25));
    });
  });
}
