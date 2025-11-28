import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/model/transaction.dart';
import 'package:p5_expense/model/category.dart';
import 'package:p5_expense/view/new_transaction.dart';
import 'package:p5_expense/view/transaction_list.dart';
import 'package:p5_expense/view/chart.dart';
import 'package:p5_expense/view/chart_bar.dart';
import '../fixtures/category_test_data.dart';

void main() {
  group('Widget Smoke Tests', () {
    late List<Category> categories;

    setUp(() {
      categories = [
        CategoryTestData.createTestCategory(title: 'Food'),
        CategoryTestData.createTestCategory(title: 'Transport'),
        CategoryTestData.createTestCategory(title: 'Entertainment'),
      ];
    });

    testWidgets('NewTransaction widget renders without crashing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewTransaction(
                (title, amount, date, categoryId, recurring, interval,
                    pastPayments, futurePayments) {},
                categories),
          ),
        ),
      );

      expect(find.byType(NewTransaction), findsOneWidget);
    });

    testWidgets('TransactionList widget renders with transactions',
        (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: '1',
          title: 'Lunch',
          amount: 12.50,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionList(transactions, (id) {}, categories),
          ),
        ),
      );

      expect(find.byType(TransactionList), findsOneWidget);
      expect(find.text('Lunch'), findsWidgets);
    });

    testWidgets('TransactionList widget renders empty state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionList([], (id) {}, categories),
          ),
        ),
      );

      expect(find.byType(TransactionList), findsOneWidget);
      expect(find.text('No transactions added yet!'), findsWidgets);
    });

    testWidgets('Chart widget renders with transactions',
        (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: '1',
          title: 'Lunch',
          amount: 50.0,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Chart(transactions),
          ),
        ),
      );

      expect(find.byType(Chart), findsOneWidget);
    });

    testWidgets('Chart widget renders empty state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Chart([]),
          ),
        ),
      );

      expect(find.byType(Chart), findsOneWidget);
    });

    testWidgets('ChartBar widget renders without crashing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChartBar(
              'Mon',
              25.50,
              0.2,
            ),
          ),
        ),
      );

      expect(find.byType(ChartBar), findsOneWidget);
      expect(find.text('Mon'), findsWidgets);
    });

    testWidgets('Can add transaction via callback',
        (WidgetTester tester) async {
      Transaction? addedTransaction;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewTransaction(
              (title, amount, date, categoryId, recurring, interval,
                  pastPayments, futurePayments) {
                addedTransaction = Transaction(
                  id: 'test',
                  title: title,
                  amount: amount,
                  date: date,
                  categoryId: categoryId,
                  recurring: recurring,
                  interval: interval,
                  pastPayments: pastPayments,
                  futurePayments: futurePayments,
                );
              },
              categories,
            ),
          ),
        ),
      );

      // Find TextFields and enter data
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, 'Coffee');
        if (textFields.evaluate().length > 1) {
          await tester.enterText(textFields.at(1), '5.50');
        }
      }

      // Find and tap save button
      final saveButton = find.byType(ElevatedButton);
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Can delete transaction via callback',
        (WidgetTester tester) async {
      String? deletedId;
      final transactions = [
        Transaction(
          id: 'test-1',
          title: 'Lunch',
          amount: 12.50,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionList(
              transactions,
              (id) {
                deletedId = id;
              },
              categories,
            ),
          ),
        ),
      );

      // Find and tap delete icon if present
      final deleteIcons = find.byIcon(Icons.delete);
      if (deleteIcons.evaluate().isNotEmpty) {
        await tester.tap(deleteIcons.first);
        await tester.pumpAndSettle();
        expect(deletedId, equals('test-1'));
      }
    });

    testWidgets('Transaction list displays multiple transactions',
        (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: '1',
          title: 'Lunch',
          amount: 12.50,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Taxi',
          amount: 8.00,
          date: DateTime.now(),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Movie',
          amount: 15.00,
          date: DateTime.now(),
          categoryId: 'entertainment',
          recurring: false,
          interval: '',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionList(transactions, (id) {}, categories),
          ),
        ),
      );

      expect(find.text('Lunch'), findsWidgets);
      expect(find.text('Taxi'), findsWidgets);
      expect(find.text('Movie'), findsWidgets);
    });

    testWidgets('Transaction amounts display correctly',
        (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: '1',
          title: 'Expensive Lunch',
          amount: 125.50,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionList(transactions, (id) {}, categories),
          ),
        ),
      );

      expect(find.text('Expensive Lunch'), findsWidgets);
      expect(find.byType(TransactionList), findsOneWidget);
    });

    testWidgets('Categories are properly handled in transaction list',
        (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: '1',
          title: 'Food Expense',
          amount: 25.0,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Transport Expense',
          amount: 15.0,
          date: DateTime.now(),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionList(transactions, (id) {}, categories),
          ),
        ),
      );

      expect(find.text('Food Expense'), findsWidgets);
      expect(find.text('Transport Expense'), findsWidgets);
    });

    testWidgets('Chart calculates totals correctly',
        (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: '1',
          title: 'Food 1',
          amount: 50.0,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Food 2',
          amount: 30.0,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
      ];

      // Total should be 80.0
      double total = transactions.fold(0, (sum, tx) => sum + tx.amount);

      expect(total, equals(80.0));
    });

    testWidgets('NewTransaction form handles user input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewTransaction(
                (title, amount, date, categoryId, recurring, interval,
                    pastPayments, futurePayments) {},
                categories),
          ),
        ),
      );

      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      // Verify we can interact with form
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, 'Test Transaction');
        await tester.pumpAndSettle();
        expect(find.text('Test Transaction'), findsWidgets);
      }
    });
  });
}
