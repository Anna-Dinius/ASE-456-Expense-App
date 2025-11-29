import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/model/transaction.dart';
import 'package:p5_expense/model/category.dart';
import '../fixtures/category_test_data.dart';

void main() {
  group('Regression Tests - Core Functionality', () {
    late List<Category> categories;
    late List<Transaction> transactions;

    setUp(() {
      categories = [
        CategoryTestData.createTestCategory(title: 'Food', id: 'food'),
        CategoryTestData.createTestCategory(
            title: 'Transport', id: 'transport'),
        CategoryTestData.createTestCategory(
            title: 'Entertainment', id: 'entertainment'),
        CategoryTestData.createTestCategory(
            title: 'Utilities', id: 'utilities'),
        CategoryTestData.createTestCategory(
            title: 'Healthcare', id: 'healthcare'),
      ];
      transactions = [];
    });

    group('RGN-1: Transaction CRUD Operations', () {
      test('RGN-1.1: Create transaction with all required fields', () {
        // Ensure transaction creation still works
        final transaction = Transaction(
          id: '1',
          title: 'Test Transaction',
          amount: 25.50,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        );

        expect(transaction.id, isNotEmpty);
        expect(transaction.title, isNotEmpty);
        expect(transaction.amount, greaterThan(0));
        expect(transaction.categoryId, isNotEmpty);
      });

      test('RGN-1.2: Read transaction from list', () {
        // Ensure transactions can be retrieved from list
        final transaction = Transaction(
          id: '1',
          title: 'Read Test',
          amount: 15.00,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        );
        transactions.add(transaction);

        final retrieved = transactions.firstWhere((tx) => tx.id == '1');
        expect(retrieved.title, equals('Read Test'));
        expect(retrieved.amount, equals(15.00));
      });

      test('RGN-1.3: Update transaction data', () {
        // Ensure transaction updates work
        var transaction = Transaction(
          id: '1',
          title: 'Original Title',
          amount: 20.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        );
        transactions.add(transaction);

        // Update by removing and re-adding
        transactions.removeWhere((tx) => tx.id == '1');
        final updated = Transaction(
          id: '1',
          title: 'Updated Title',
          amount: 25.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        );
        transactions.add(updated);

        expect(transactions.first.title, equals('Updated Title'));
        expect(transactions.first.amount, equals(25.00));
      });

      test('RGN-1.4: Delete transaction from list', () {
        // Ensure transaction deletion works
        final t1 = Transaction(
          id: '1',
          title: 'To Keep',
          amount: 10.00,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        );
        final t2 = Transaction(
          id: '2',
          title: 'To Delete',
          amount: 20.00,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        );
        transactions.addAll([t1, t2]);

        final initialCount = transactions.length;
        transactions.removeWhere((tx) => tx.id == '2');

        expect(transactions.length, equals(initialCount - 1));
        expect(transactions.any((tx) => tx.id == '2'), isFalse);
        expect(transactions.any((tx) => tx.id == '1'), isTrue);
      });
    });

    group('RGN-2: Transaction Calculations', () {
      test('RGN-2.1: Total spending calculation remains accurate', () {
        // Ensure sum calculation doesn't regress
        final txList = [
          Transaction(
            id: '1',
            title: 'T1',
            amount: 10.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
          Transaction(
            id: '2',
            title: 'T2',
            amount: 20.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
          Transaction(
            id: '3',
            title: 'T3',
            amount: 30.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
        ];

        final total = txList.fold<double>(0, (sum, tx) => sum + tx.amount);
        expect(total, equals(60.00));
      });

      test('RGN-2.2: Average calculation is correct', () {
        // Ensure average doesn't regress
        final txList = [
          Transaction(
            id: '1',
            title: 'T1',
            amount: 10.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
          Transaction(
            id: '2',
            title: 'T2',
            amount: 20.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
        ];

        final average = txList.fold<double>(0, (sum, tx) => sum + tx.amount) /
            txList.length;
        expect(average, equals(15.00));
      });

      test('RGN-2.3: Min/max calculations work correctly', () {
        // Ensure min/max don't regress
        final amounts = [5.00, 25.00, 15.00, 35.00, 10.00];
        final min = amounts.reduce((a, b) => a < b ? a : b);
        final max = amounts.reduce((a, b) => a > b ? a : b);

        expect(min, equals(5.00));
        expect(max, equals(35.00));
      });

      test('RGN-2.4: Percentage calculation maintains precision', () {
        // Ensure percentage calculations don't regress
        final spent = 175.00;
        final budget = 200.00;
        final percentage = (spent / budget) * 100;

        expect(percentage, closeTo(87.5, 0.01));
      });
    });

    group('RGN-3: Category Operations', () {
      test('RGN-3.1: Category creation with default values', () {
        // Ensure categories can be created
        final category = categories.first;
        expect(category.id, isNotEmpty);
        expect(category.title, isNotEmpty);
      });

      test('RGN-3.2: Finding category by ID', () {
        // Ensure category lookup works
        final found = categories.firstWhere((cat) => cat.id == 'food');
        expect(found.title, equals('Food'));
      });

      test('RGN-3.3: Filtering transactions by category', () {
        // Ensure category filtering works
        final txList = [
          Transaction(
            id: '1',
            title: 'Food Tx',
            amount: 10.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
          Transaction(
            id: '2',
            title: 'Transport Tx',
            amount: 20.00,
            date: DateTime.now(),
            categoryId: 'transport',
            recurring: false,
            interval: '',
          ),
        ];

        final foodTxs = txList.where((tx) => tx.categoryId == 'food').toList();
        expect(foodTxs.length, equals(1));
        expect(foodTxs.first.title, equals('Food Tx'));
      });

      test('RGN-3.4: Grouping transactions by category', () {
        // Ensure grouping logic works
        final txList = [
          Transaction(
            id: '1',
            title: 'Food1',
            amount: 10.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
          Transaction(
            id: '2',
            title: 'Food2',
            amount: 15.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
          Transaction(
            id: '3',
            title: 'Transport1',
            amount: 20.00,
            date: DateTime.now(),
            categoryId: 'transport',
            recurring: false,
            interval: '',
          ),
        ];

        final grouped = <String, List<Transaction>>{};
        for (final tx in txList) {
          grouped.putIfAbsent(tx.categoryId, () => []);
          grouped[tx.categoryId]!.add(tx);
        }

        expect(grouped['food']!.length, equals(2));
        expect(grouped['transport']!.length, equals(1));
      });

      test('RGN-3.5: Category spending totals are correct', () {
        // Ensure spending aggregation doesn't regress
        final txList = [
          Transaction(
            id: '1',
            title: 'Food1',
            amount: 25.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
          Transaction(
            id: '2',
            title: 'Food2',
            amount: 35.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
        ];

        final foodTotal = txList
            .where((tx) => tx.categoryId == 'food')
            .fold<double>(0, (sum, tx) => sum + tx.amount);

        expect(foodTotal, equals(60.00));
      });
    });

    group('RGN-4: Date Operations', () {
      test('RGN-4.1: Date comparison works correctly', () {
        // Ensure date comparisons don't regress
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 16);

        expect(date1.isBefore(date2), isTrue);
        expect(date2.isAfter(date1), isTrue);
        expect(date1.isAtSameMomentAs(date1), isTrue);
      });

      test('RGN-4.2: Date grouping (normalized) works', () {
        // Ensure date grouping without time works
        final txList = [
          Transaction(
            id: '1',
            title: 'TX1',
            amount: 10.00,
            date: DateTime(2024, 1, 15, 8, 30),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
          Transaction(
            id: '2',
            title: 'TX2',
            amount: 20.00,
            date: DateTime(2024, 1, 15, 14, 0),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
          Transaction(
            id: '3',
            title: 'TX3',
            amount: 30.00,
            date: DateTime(2024, 1, 16, 10, 0),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
        ];

        final grouped = <DateTime, List<Transaction>>{};
        for (final tx in txList) {
          final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
          grouped.putIfAbsent(dateKey, () => []);
          grouped[dateKey]!.add(tx);
        }

        expect(grouped.length, equals(2));
        expect(grouped[DateTime(2024, 1, 15)]!.length, equals(2));
        expect(grouped[DateTime(2024, 1, 16)]!.length, equals(1));
      });

      test('RGN-4.3: Date range filtering works', () {
        // Ensure date range filtering doesn't regress
        final startDate = DateTime(2024, 1, 10);
        final endDate = DateTime(2024, 1, 20);
        final txList = [
          Transaction(
            id: '1',
            title: 'Before',
            amount: 10.00,
            date: DateTime(2024, 1, 5),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
          Transaction(
            id: '2',
            title: 'In Range',
            amount: 20.00,
            date: DateTime(2024, 1, 15),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
          Transaction(
            id: '3',
            title: 'After',
            amount: 30.00,
            date: DateTime(2024, 1, 25),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
        ];

        final inRange = txList
            .where(
                (tx) => tx.date.isAfter(startDate) && tx.date.isBefore(endDate))
            .toList();

        expect(inRange.length, equals(1));
        expect(inRange.first.title, equals('In Range'));
      });

      test('RGN-4.4: Month extraction works correctly', () {
        // Ensure month extraction doesn't regress
        final txList = [
          Transaction(
            id: '1',
            title: 'Jan TX',
            amount: 10.00,
            date: DateTime(2024, 1, 15),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
          Transaction(
            id: '2',
            title: 'Feb TX',
            amount: 20.00,
            date: DateTime(2024, 2, 15),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
        ];

        final january = txList.where((tx) => tx.date.month == 1).toList();
        final february = txList.where((tx) => tx.date.month == 2).toList();

        expect(january.length, equals(1));
        expect(february.length, equals(1));
      });
    });

    group('RGN-5: Filtering and Search', () {
      test('RGN-5.1: Search by title (case insensitive)', () {
        // Ensure search doesn't regress
        final txList = [
          Transaction(
            id: '1',
            title: 'Coffee at Cafe',
            amount: 5.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
          Transaction(
            id: '2',
            title: 'Restaurant Dinner',
            amount: 30.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
        ];

        final results = txList
            .where((tx) => tx.title.toLowerCase().contains('coffee'))
            .toList();

        expect(results.length, equals(1));
        expect(results.first.title, equals('Coffee at Cafe'));
      });

      test('RGN-5.2: Filter by amount range', () {
        // Ensure amount range filtering works
        final txList = [
          Transaction(
            id: '1',
            title: 'Small',
            amount: 5.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
          Transaction(
            id: '2',
            title: 'Medium',
            amount: 25.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
          Transaction(
            id: '3',
            title: 'Large',
            amount: 100.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
        ];

        final inRange =
            txList.where((tx) => tx.amount >= 20 && tx.amount <= 50).toList();

        expect(inRange.length, equals(1));
        expect(inRange.first.title, equals('Medium'));
      });

      test('RGN-5.3: Filter by multiple criteria', () {
        // Ensure multi-criteria filtering works
        final txList = [
          Transaction(
            id: '1',
            title: 'Food1',
            amount: 10.00,
            date: DateTime(2024, 1, 15),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
          Transaction(
            id: '2',
            title: 'Transport1',
            amount: 20.00,
            date: DateTime(2024, 1, 15),
            categoryId: 'transport',
            recurring: false,
            interval: '',
          ),
          Transaction(
            id: '3',
            title: 'Food2',
            amount: 15.00,
            date: DateTime(2024, 1, 16),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
        ];

        final filtered = txList
            .where((tx) =>
                tx.categoryId == 'food' && tx.date.day == 15 && tx.amount < 15)
            .toList();

        expect(filtered.length, equals(1));
        expect(filtered.first.id, equals('1'));
      });
    });

    group('RGN-6: Recurring Transaction Logic', () {
      test('RGN-6.1: Recurring flag is preserved', () {
        // Ensure recurring transactions remain marked
        final tx = Transaction(
          id: '1',
          title: 'Monthly Subscription',
          amount: 9.99,
          date: DateTime(2024, 1, 15),
          categoryId: 'entertainment',
          recurring: true,
          interval: 'monthly',
        );

        expect(tx.recurring, isTrue);
        expect(tx.interval, equals('monthly'));
      });

      test('RGN-6.2: Non-recurring transactions work', () {
        // Ensure non-recurring transactions work correctly
        final tx = Transaction(
          id: '1',
          title: 'One-time expense',
          amount: 50.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        );

        expect(tx.recurring, isFalse);
        expect(tx.interval.isEmpty, isTrue);
      });

      test('RGN-6.3: Interval values are correct', () {
        // Ensure interval types are preserved
        final intervals = ['daily', 'weekly', 'monthly', 'yearly'];
        for (final interval in intervals) {
          final tx = Transaction(
            id: '1',
            title: 'Test',
            amount: 10.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: true,
            interval: interval,
          );

          expect(tx.interval, equals(interval));
        }
      });

      test('RGN-6.4: Filtering recurring transactions', () {
        // Ensure recurring transaction filtering works
        final txList = [
          Transaction(
            id: '1',
            title: 'Recurring',
            amount: 9.99,
            date: DateTime.now(),
            categoryId: 'entertainment',
            recurring: true,
            interval: 'monthly',
          ),
          Transaction(
            id: '2',
            title: 'One-time',
            amount: 50.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
        ];

        final recurring = txList.where((tx) => tx.recurring).toList();
        expect(recurring.length, equals(1));
        expect(recurring.first.title, equals('Recurring'));
      });
    });

    group('RGN-7: Edge Cases and Boundary Conditions', () {
      test('RGN-7.1: Empty transaction list handling', () {
        // Ensure empty lists are handled correctly
        expect(transactions.isEmpty, isTrue);
        expect(transactions.length, equals(0));

        final total =
            transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
        expect(total, equals(0.0));
      });

      test('RGN-7.2: Single transaction handling', () {
        // Ensure single transaction works
        final tx = Transaction(
          id: '1',
          title: 'Single',
          amount: 25.00,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        );
        transactions.add(tx);

        expect(transactions.length, equals(1));
        expect(transactions.first.id, equals('1'));
      });

      test('RGN-7.3: Large amount values', () {
        // Ensure large amounts are handled
        final largeAmount = 999999.99;
        final tx = Transaction(
          id: '1',
          title: 'Large',
          amount: largeAmount,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        );

        expect(tx.amount, equals(largeAmount));
      });

      test('RGN-7.4: Very small (fractional) amounts', () {
        // Ensure fractional amounts work
        final smallAmount = 0.01;
        final tx = Transaction(
          id: '1',
          title: 'Small',
          amount: smallAmount,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        );

        expect(tx.amount, equals(smallAmount));
      });

      test('RGN-7.5: Zero amount transactions', () {
        // Ensure zero amounts don't break logic
        final tx = Transaction(
          id: '1',
          title: 'Zero',
          amount: 0.0,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        );
        transactions.add(tx);

        expect(tx.amount, equals(0.0));
        final total = transactions.fold<double>(0, (sum, t) => sum + t.amount);
        expect(total, equals(0.0));
      });

      test('RGN-7.6: Null/empty string handling in fields', () {
        // Ensure empty strings are handled
        final tx = Transaction(
          id: '1',
          title: '',
          amount: 10.00,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        );

        expect(tx.title.isEmpty, isTrue);
        expect(tx.interval.isEmpty, isTrue);
      });
    });

    group('RGN-8: Data Integrity', () {
      test('RGN-8.1: Transaction ID uniqueness', () {
        // Ensure IDs can be unique
        final tx1 = Transaction(
          id: 'unique_1',
          title: 'TX1',
          amount: 10.00,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        );
        final tx2 = Transaction(
          id: 'unique_2',
          title: 'TX2',
          amount: 20.00,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        );
        transactions.addAll([tx1, tx2]);

        final ids = transactions.map((tx) => tx.id).toSet();
        expect(ids.length, equals(2));
      });

      test('RGN-8.2: Category ID references are valid', () {
        // Ensure category IDs are valid
        final tx = Transaction(
          id: '1',
          title: 'Test',
          amount: 10.00,
          date: DateTime.now(),
          categoryId: 'food',
          recurring: false,
          interval: '',
        );

        final validCategoryId =
            categories.any((cat) => cat.id == tx.categoryId);
        expect(validCategoryId, isTrue);
      });

      test('RGN-8.3: Data immutability in calculations', () {
        // Ensure calculations don't modify original data
        final txList = [
          Transaction(
            id: '1',
            title: 'TX1',
            amount: 10.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
          Transaction(
            id: '2',
            title: 'TX2',
            amount: 20.00,
            date: DateTime.now(),
            categoryId: 'food',
            recurring: false,
            interval: '',
          ),
        ];

        final originalTotal =
            txList.fold<double>(0, (sum, tx) => sum + tx.amount);
        // Calculate again - original data shouldn't change
        final total2 = txList.fold<double>(0, (sum, tx) => sum + tx.amount);

        expect(originalTotal, equals(total2));
        expect(txList.first.amount, equals(10.00));
      });

      test('RGN-8.4: List ordering is preserved', () {
        // Ensure list order is maintained
        final tx1 = Transaction(
          id: '1',
          title: 'First',
          amount: 10.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        );
        final tx2 = Transaction(
          id: '2',
          title: 'Second',
          amount: 20.00,
          date: DateTime(2024, 1, 16),
          categoryId: 'food',
          recurring: false,
          interval: '',
        );
        transactions.addAll([tx1, tx2]);

        expect(transactions[0].title, equals('First'));
        expect(transactions[1].title, equals('Second'));
      });
    });
  });
}
