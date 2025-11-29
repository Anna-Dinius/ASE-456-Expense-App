import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/model/transaction.dart';
import '../fixtures/category_test_data.dart';

void main() {
  group('Transaction Data Models', () {
    testWidgets('Transaction model can be created with all fields',
        (WidgetTester tester) async {
      final date = DateTime(2024, 1, 15);
      final transaction = Transaction(
        id: 'tx1',
        title: 'Lunch',
        amount: 25.50,
        date: date,
        categoryId: 'food',
        recurring: false,
        interval: '',
      );

      expect(transaction.id, equals('tx1'));
      expect(transaction.title, equals('Lunch'));
      expect(transaction.amount, equals(25.50));
      expect(transaction.date, equals(date));
      expect(transaction.categoryId, equals('food'));
      expect(transaction.recurring, equals(false));
    });

    testWidgets('Category model can be created with all fields',
        (WidgetTester tester) async {
      final category = CategoryTestData.createTestCategory(
        title: 'Food',
      );

      expect(category.title, equals('Food'));
      expect(category.id, isNotNull);
      expect(category.color, isNotNull);
      expect(category.icon, isNotNull);
    });

    testWidgets('Transaction can calculate total from multiple items',
        (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: '1',
          title: 'Item 1',
          amount: 10.0,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Item 2',
          amount: 20.0,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Item 3',
          amount: 30.0,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
      ];

      final total = transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
      expect(total, equals(60.0));
    });

    testWidgets('Can filter transactions by category',
        (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: '1',
          title: 'Food',
          amount: 10.0,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Taxi',
          amount: 20.0,
          date: DateTime.now(),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Burger',
          amount: 15.0,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
      ];

      final foodTransactions =
          transactions.where((tx) => tx.categoryId == 'food').toList();
      expect(foodTransactions.length, equals(2));
      expect(foodTransactions[0].title, equals('Food'));
      expect(foodTransactions[1].title, equals('Burger'));
    });

    testWidgets('Can filter transactions by date range',
        (WidgetTester tester) async {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 31);

      final transactions = [
        Transaction(
          id: '1',
          title: 'Dec Transaction',
          amount: 10.0,
          date: DateTime(2023, 12, 31),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Jan Transaction',
          amount: 20.0,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Feb Transaction',
          amount: 15.0,
          date: DateTime(2024, 2, 1),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
      ];

      final filtered = transactions
          .where(
              (tx) => tx.date.isAfter(startDate) && tx.date.isBefore(endDate))
          .toList();

      expect(filtered.length, equals(1));
      expect(filtered[0].title, equals('Jan Transaction'));
    });

    testWidgets('Can search transactions by title',
        (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: '1',
          title: 'Lunch at restaurant',
          amount: 25.50,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Taxi ride home',
          amount: 12.00,
          date: DateTime.now(),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Movie ticket',
          amount: 15.00,
          date: DateTime.now(),
          categoryId: 'entertainment',
          recurring: false,
          interval: '',
        ),
      ];

      final searchQuery = 'lunch';
      final results = transactions
          .where((tx) =>
              tx.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();

      expect(results.length, equals(1));
      expect(results[0].title, equals('Lunch at restaurant'));
    });

    testWidgets('Category copyWith creates new instance with updated fields',
        (WidgetTester tester) async {
      final category1 = CategoryTestData.createTestCategory(title: 'Food');
      final category2 = category1.copyWith(title: 'Dining');

      expect(category1.title, equals('Food'));
      expect(category2.title, equals('Dining'));
      expect(category1.id, equals(category2.id));
    });

    testWidgets('Transaction recurring flag works correctly',
        (WidgetTester tester) async {
      final oneTime = Transaction(
        id: '1',
        title: 'One time expense',
        amount: 50.0,
        date: DateTime.now(),
        categoryId: 'food',
        recurring: false,
        interval: '',
      );

      final recurring = Transaction(
        id: '2',
        title: 'Monthly subscription',
        amount: 9.99,
        date: DateTime.now(),
        categoryId: 'entertainment',
        recurring: true,
        interval: 'monthly',
      );

      expect(oneTime.recurring, equals(false));
      expect(recurring.recurring, equals(true));
      expect(recurring.interval, equals('monthly'));
    });

    testWidgets('Can group transactions by category',
        (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: '1',
          title: 'Food 1',
          amount: 10.0,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Transport 1',
          amount: 20.0,
          date: DateTime.now(),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Food 2',
          amount: 15.0,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
      ];

      final groupedByCategory = <String, List<Transaction>>{};
      for (var tx in transactions) {
        if (!groupedByCategory.containsKey(tx.categoryId)) {
          groupedByCategory[tx.categoryId] = [];
        }
        groupedByCategory[tx.categoryId]!.add(tx);
      }

      expect(groupedByCategory['food']!.length, equals(2));
      expect(groupedByCategory['transport']!.length, equals(1));
    });

    testWidgets('Can calculate spending by category',
        (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: '1',
          title: 'Food 1',
          amount: 25.0,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Transport 1',
          amount: 30.0,
          date: DateTime.now(),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Food 2',
          amount: 20.0,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
      ];

      final spendingByCategory = <String, double>{};
      for (var tx in transactions) {
        spendingByCategory[tx.categoryId] =
            (spendingByCategory[tx.categoryId] ?? 0) + tx.amount;
      }

      expect(spendingByCategory['food'], equals(45.0));
      expect(spendingByCategory['transport'], equals(30.0));
    });

    testWidgets('Empty transaction list operations work correctly',
        (WidgetTester tester) async {
      final transactions = <Transaction>[];

      expect(transactions.isEmpty, equals(true));
      expect(transactions.length, equals(0));

      final total = transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
      expect(total, equals(0.0));
    });
  });
}
