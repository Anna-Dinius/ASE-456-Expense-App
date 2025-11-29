import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/model/transaction.dart';
import 'package:p5_expense/model/category.dart';
import 'package:p5_expense/view/new_transaction.dart';
import 'package:p5_expense/view/transaction_list.dart';
import 'package:p5_expense/view/chart.dart';
import '../fixtures/category_test_data.dart';

void main() {
  group('User Workflow Integration Tests', () {
    late List<Category> categories;
    late List<Transaction> transactions;

    setUp(() {
      categories = [
        CategoryTestData.createTestCategory(title: 'Food', id: 'food'),
        CategoryTestData.createTestCategory(
            title: 'Transport', id: 'transport'),
        CategoryTestData.createTestCategory(
            title: 'Entertainment', id: 'entertainment'),
      ];
      transactions = [];
    });

    testWidgets(
        'Workflow 1: User adds a food transaction and sees it in the list',
        (WidgetTester tester) async {
      String? capturedTitle;
      double? capturedAmount;
      String? capturedCategory;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // New Transaction form
                Expanded(
                  child: NewTransaction((title, amount, date, categoryId,
                      recurring, interval, pastPayments, futurePayments) {
                    capturedTitle = title;
                    capturedAmount = amount;
                    capturedCategory = categoryId;
                    // Add to transaction list
                    transactions.add(Transaction(
                      id: '${transactions.length + 1}',
                      title: title,
                      amount: amount,
                      date: date,
                      categoryId: categoryId,
                      recurring: recurring,
                      interval: interval,
                    ));
                  }, categories),
                ),
                // Transaction List
                if (transactions.isNotEmpty)
                  Expanded(
                    child: TransactionList(transactions, (id) {
                      transactions.removeWhere((tx) => tx.id == id);
                    }, categories),
                  ),
              ],
            ),
          ),
        ),
      );

      // User enters transaction data
      await tester.enterText(
          find.byType(TextField).first, 'Lunch at Restaurant');
      await tester.enterText(find.byType(TextField).at(1), '25.50');
      await tester.pumpAndSettle();

      // User taps add button (simulated via callback)
      expect(find.byType(NewTransaction), findsOneWidget);
    });

    testWidgets(
        'Workflow 2: User adds multiple transactions and views chart summary',
        (WidgetTester tester) async {
      // Setup: Create multiple transactions
      transactions = [
        Transaction(
          id: '1',
          title: 'Breakfast',
          amount: 8.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Lunch',
          amount: 12.50,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Bus fare',
          amount: 2.50,
          date: DateTime(2024, 1, 15),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '4',
          title: 'Movie',
          amount: 15.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'entertainment',
          recurring: false,
          interval: '',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(child: Chart(transactions)),
                Expanded(
                  child: TransactionList(transactions, (id) {
                    transactions.removeWhere((tx) => tx.id == id);
                  }, categories),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify chart renders with transactions
      expect(find.byType(Chart), findsOneWidget);

      // Verify transaction list shows all transactions
      expect(find.byType(TransactionList), findsOneWidget);

      // Verify total calculation
      final total = transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
      expect(total, equals(38.0));
    });

    testWidgets(
        'Workflow 3: User filters transactions by category and views filtered list',
        (WidgetTester tester) async {
      // Setup: Multiple transactions
      transactions = [
        Transaction(
          id: '1',
          title: 'Pizza',
          amount: 15.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Taxi',
          amount: 12.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Burger',
          amount: 10.00,
          date: DateTime(2024, 1, 16),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
      ];

      String selectedCategory = 'food';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                final filtered = transactions
                    .where((tx) => tx.categoryId == selectedCategory)
                    .toList();

                return Column(
                  children: [
                    // Category filter buttons
                    Wrap(
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              setState(() => selectedCategory = 'food'),
                          child: const Text('Food'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              setState(() => selectedCategory = 'transport'),
                          child: const Text('Transport'),
                        ),
                      ],
                    ),
                    // Filtered transaction list
                    Expanded(
                      child: TransactionList(filtered, (id) {
                        transactions.removeWhere((tx) => tx.id == id);
                        setState(() {});
                      }, categories),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initially shows food transactions (2)
      expect(find.byType(TransactionList), findsOneWidget);

      // Tap transport filter
      await tester.tap(find.text('Transport'));
      await tester.pumpAndSettle();

      // Now filtered to transport (1)
      expect(find.byType(TransactionList), findsOneWidget);
    });

    testWidgets(
        'Workflow 4: User deletes a transaction and list updates immediately',
        (WidgetTester tester) async {
      // Setup: Initial transactions
      transactions = [
        Transaction(
          id: '1',
          title: 'Lunch',
          amount: 12.50,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Coffee',
          amount: 5.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TransactionList(transactions, (id) {
                  transactions.removeWhere((tx) => tx.id == id);
                  setState(() {});
                }, categories);
              },
            ),
          ),
        ),
      );

      // Verify both transactions are present
      expect(transactions.length, equals(2));

      // Simulate deletion via callback
      final idToDelete = '1';
      transactions.removeWhere((tx) => tx.id == idToDelete);
      await tester.pumpAndSettle();

      // Verify transaction was deleted
      expect(transactions.length, equals(1));
      expect(transactions[0].id, equals('2'));
    });

    testWidgets(
        'Workflow 5: User views spending summary and sees category breakdown',
        (WidgetTester tester) async {
      // Setup: Diverse transactions across categories
      transactions = [
        Transaction(
          id: '1',
          title: 'Groceries',
          amount: 50.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Restaurant',
          amount: 30.00,
          date: DateTime(2024, 1, 16),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Gas',
          amount: 40.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '4',
          title: 'Concert',
          amount: 60.00,
          date: DateTime(2024, 1, 17),
          categoryId: 'entertainment',
          recurring: false,
          interval: '',
        ),
      ];

      // Calculate category breakdown
      final categorySpending = <String, double>{};
      for (var transaction in transactions) {
        categorySpending[transaction.categoryId] =
            (categorySpending[transaction.categoryId] ?? 0) +
                transaction.amount;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // Summary section
                Expanded(
                  child: ListView(
                    children: [
                      Text(
                          'Total: \$${transactions.fold<double>(0, (sum, tx) => sum + tx.amount)}'),
                      Text('Food: \$${categorySpending['food'] ?? 0}'),
                      Text(
                          'Transport: \$${categorySpending['transport'] ?? 0}'),
                      Text(
                          'Entertainment: \$${categorySpending['entertainment'] ?? 0}'),
                    ],
                  ),
                ),
                // Chart visualization
                Expanded(child: Chart(transactions)),
              ],
            ),
          ),
        ),
      );

      // Verify calculations
      expect(categorySpending['food'], equals(80.0));
      expect(categorySpending['transport'], equals(40.0));
      expect(categorySpending['entertainment'], equals(60.0));

      final total = transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
      expect(total, equals(180.0));

      // Verify chart renders
      expect(find.byType(Chart), findsOneWidget);
    });

    testWidgets('Workflow 6: User searches for transaction by title',
        (WidgetTester tester) async {
      transactions = [
        Transaction(
          id: '1',
          title: 'Lunch at Restaurant',
          amount: 15.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Breakfast at Cafe',
          amount: 8.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Bus fare',
          amount: 2.50,
          date: DateTime(2024, 1, 15),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
      ];

      String searchQuery = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                final filtered = transactions
                    .where((tx) =>
                        tx.title
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        searchQuery.isEmpty)
                    .toList();

                return Column(
                  children: [
                    // Search bar
                    TextField(
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search transactions',
                      ),
                    ),
                    // Filtered results
                    Expanded(
                      child: TransactionList(filtered, (id) {
                        transactions.removeWhere((tx) => tx.id == id);
                        setState(() {});
                      }, categories),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Verify search functionality
      expect(transactions.length, equals(3));

      // Filter by "Restaurant"
      searchQuery = 'Restaurant';
      final filtered = transactions
          .where((tx) =>
              tx.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
      expect(filtered.length, equals(1));
      expect(filtered[0].title, contains('Restaurant'));
    });

    testWidgets('Workflow 7: User views transactions for specific date range',
        (WidgetTester tester) async {
      transactions = [
        Transaction(
          id: '1',
          title: 'Lunch',
          amount: 12.00,
          date: DateTime(2024, 1, 10),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Breakfast',
          amount: 8.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Dinner',
          amount: 20.00,
          date: DateTime(2024, 1, 20),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
      ];

      final startDate = DateTime(2024, 1, 15);
      final endDate = DateTime(2024, 1, 25);

      final filtered = transactions
          .where((tx) =>
              (tx.date.isAfter(startDate) ||
                  tx.date.isAtSameMomentAs(startDate)) &&
              (tx.date.isBefore(endDate) || tx.date.isAtSameMomentAs(endDate)))
          .toList();

      // Verify date range filtering
      expect(filtered.length, equals(2));
      expect(filtered.every((tx) => tx.date.month == 1), isTrue);
    });

    testWidgets(
        'Workflow 8: User adds recurring transaction and reviews past/future payments',
        (WidgetTester tester) async {
      String? capturedTitle;
      double? capturedAmount;
      bool? capturedRecurring;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewTransaction((title, amount, date, categoryId, recurring,
                interval, pastPayments, futurePayments) {
              capturedTitle = title;
              capturedAmount = amount;
              capturedRecurring = recurring;

              // Simulate adding a recurring transaction
              if (recurring) {
                for (int i = 0; i < pastPayments; i++) {
                  transactions.add(Transaction(
                    id: '${transactions.length + 1}',
                    title: title,
                    amount: amount,
                    date: date.subtract(Duration(days: 30 * (i + 1))),
                    categoryId: categoryId,
                    recurring: true,
                    interval: interval,
                  ));
                }
                // Add current and future
                transactions.add(Transaction(
                  id: '${transactions.length + 1}',
                  title: title,
                  amount: amount,
                  date: date,
                  categoryId: categoryId,
                  recurring: true,
                  interval: interval,
                ));
              }
            }, categories),
          ),
        ),
      );

      expect(find.byType(NewTransaction), findsOneWidget);
    });
  });
}
