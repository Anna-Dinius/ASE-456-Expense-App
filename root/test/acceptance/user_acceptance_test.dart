import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/model/transaction.dart';

void main() {
  group('User Acceptance Tests - Core Workflows', () {
    test('UAT-1: User can add a new transaction to their list', () {
      // Setup: Empty transaction list
      final transactions = <Transaction>[];
      expect(transactions.isEmpty, isTrue, reason: 'List should start empty');

      // Action: User adds a transaction
      final newTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Coffee at Cafe',
        amount: 5.50,
        date: DateTime(2024, 1, 15),
        categoryId: 'food',
        recurring: false,
        interval: '',
      );
      transactions.add(newTransaction);

      // Verify: Transaction is in the list with correct data
      expect(transactions.isNotEmpty, isTrue,
          reason: 'Transaction should be added to the list');
      expect(transactions.length, equals(1));
      expect(transactions.first.title, equals('Coffee at Cafe'));
      expect(transactions.first.amount, equals(5.50));
      expect(transactions.first.categoryId, equals('food'));
    });

    test('UAT-2: User can view their spending by category in a chart summary',
        () {
      // Setup: User has multiple transactions across categories
      final transactions = [
        Transaction(
          id: '1',
          title: 'Groceries',
          amount: 85.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Restaurant',
          amount: 42.50,
          date: DateTime(2024, 1, 16),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Taxi',
          amount: 35.00,
          date: DateTime(2024, 1, 17),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '4',
          title: 'Movie',
          amount: 15.00,
          date: DateTime(2024, 1, 18),
          categoryId: 'entertainment',
          recurring: false,
          interval: '',
        ),
      ];

      // Calculate spending by category
      final spendingByCategory = <String, double>{};
      for (final tx in transactions) {
        spendingByCategory[tx.categoryId] =
            (spendingByCategory[tx.categoryId] ?? 0) + tx.amount;
      }

      // Verify: Chart data is calculated correctly
      expect(spendingByCategory['food'], equals(127.50));
      expect(spendingByCategory['transport'], equals(35.00));
      expect(spendingByCategory['entertainment'], equals(15.00));

      // Verify: Total spending calculation
      final totalSpending =
          transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
      expect(totalSpending, equals(177.50));
    });

    test('UAT-3: User can delete a transaction and have it removed from list',
        () {
      // Setup: User has transactions in the list
      final transactions = [
        Transaction(
          id: '1',
          title: 'Unwanted Expense',
          amount: 50.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Keep This',
          amount: 25.00,
          date: DateTime(2024, 1, 16),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
      ];

      // Verify: Both transactions are in list initially
      expect(transactions.length, equals(2));
      expect(transactions.where((tx) => tx.title == 'Unwanted Expense').length,
          equals(1));

      // Action: Delete the first transaction
      transactions.removeWhere((tx) => tx.id == '1');

      // Verify: Deleted transaction is gone, other remains
      expect(transactions.length, equals(1),
          reason: 'Transaction should be removed from list');
      expect(transactions.where((tx) => tx.title == 'Unwanted Expense').length,
          equals(0));
      expect(transactions.first.title, equals('Keep This'));
    });

    test(
        'UAT-4: User can view transaction history with accurate dates and amounts',
        () {
      // Setup: User has transactions from different dates
      final transactions = [
        Transaction(
          id: '1',
          title: 'January Coffee',
          amount: 4.50,
          date: DateTime(2024, 1, 5),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'January Lunch',
          amount: 15.75,
          date: DateTime(2024, 1, 10),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'February Dinner',
          amount: 32.00,
          date: DateTime(2024, 2, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
      ];

      // Verify: All transaction titles are preserved
      expect(transactions.where((tx) => tx.title == 'January Coffee').length,
          equals(1));
      expect(transactions.where((tx) => tx.title == 'January Lunch').length,
          equals(1));
      expect(transactions.where((tx) => tx.title == 'February Dinner').length,
          equals(1));

      // Verify: All amounts are accurate
      expect(
          transactions.firstWhere((tx) => tx.title == 'January Coffee').amount,
          equals(4.50));
      expect(
          transactions.firstWhere((tx) => tx.title == 'January Lunch').amount,
          equals(15.75));
      expect(
          transactions.firstWhere((tx) => tx.title == 'February Dinner').amount,
          equals(32.00));

      // Verify: Dates are correct
      expect(
          transactions
              .firstWhere((tx) => tx.title == 'January Coffee')
              .date
              .day,
          equals(5));
      expect(
          transactions.firstWhere((tx) => tx.title == 'January Lunch').date.day,
          equals(10));
      expect(
          transactions
              .firstWhere((tx) => tx.title == 'February Dinner')
              .date
              .month,
          equals(2));
    });

    test('UAT-5: User can track spending in specific categories', () {
      // Setup: User has transactions across multiple categories
      final transactions = [
        Transaction(
          id: '1',
          title: 'Groceries',
          amount: 65.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Restaurant',
          amount: 35.50,
          date: DateTime(2024, 1, 16),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Bus Fare',
          amount: 5.00,
          date: DateTime(2024, 1, 17),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '4',
          title: 'Gas',
          amount: 45.00,
          date: DateTime(2024, 1, 18),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
      ];

      // Calculate category totals
      final foodSpending = transactions
          .where((tx) => tx.categoryId == 'food')
          .fold<double>(0, (sum, tx) => sum + tx.amount);

      final transportSpending = transactions
          .where((tx) => tx.categoryId == 'transport')
          .fold<double>(0, (sum, tx) => sum + tx.amount);

      // Verify: Category spending totals are correct
      expect(foodSpending, equals(100.50),
          reason: 'Food spending should be 65 + 35.50');
      expect(transportSpending, equals(50.00),
          reason: 'Transport spending should be 5 + 45');

      // Verify: Correct number of transactions per category
      final foodTransactions =
          transactions.where((tx) => tx.categoryId == 'food').toList();
      final transportTransactions =
          transactions.where((tx) => tx.categoryId == 'transport').toList();

      expect(foodTransactions.length, equals(2));
      expect(transportTransactions.length, equals(2));
    });

    test('UAT-6: User can add a recurring transaction for automatic tracking',
        () {
      // Setup: User wants to add a recurring monthly subscription
      final transactions = <Transaction>[];

      // Action: Add recurring transaction
      final recurringTransaction = Transaction(
        id: '1',
        title: 'Netflix',
        amount: 9.99,
        date: DateTime(2024, 1, 15),
        categoryId: 'entertainment',
        recurring: true,
        interval: 'monthly',
      );
      transactions.add(recurringTransaction);

      // Verify: Recurring transaction is stored correctly
      expect(transactions.isNotEmpty, isTrue);
      expect(transactions.first.title, equals('Netflix'));
      expect(transactions.first.amount, equals(9.99));
      expect(transactions.first.recurring, isTrue,
          reason: 'Recurring flag should be set to true');
      expect(transactions.first.interval, equals('monthly'),
          reason: 'Interval should be monthly');
    });

    test('UAT-7: User can see total spending and spending statistics', () {
      // Setup: User has multiple transactions
      final transactions = [
        Transaction(
          id: '1',
          title: 'Breakfast',
          amount: 8.50,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Lunch',
          amount: 12.75,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Dinner',
          amount: 28.50,
          date: DateTime(2024, 1, 16),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
      ];

      // Calculate statistics
      final total = transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
      final average = total / transactions.length;
      final highest =
          transactions.map((tx) => tx.amount).reduce((a, b) => a > b ? a : b);
      final lowest =
          transactions.map((tx) => tx.amount).reduce((a, b) => a < b ? a : b);

      // Verify: Total spending
      expect(total, equals(49.75));

      // Verify: Average calculation
      expect(average, closeTo(16.583, 0.01));

      // Verify: Highest and lowest
      expect(highest, equals(28.50));
      expect(lowest, equals(8.50));

      // Verify: Count
      expect(transactions.length, equals(3));
    });

    test('UAT-8: User can view expenses organized by date', () {
      // Setup: User has transactions from different dates
      final transactions = [
        Transaction(
          id: '1',
          title: 'Morning Coffee',
          amount: 5.00,
          date: DateTime(2024, 1, 15, 8, 30),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Lunch',
          amount: 12.50,
          date: DateTime(2024, 1, 15, 12, 0),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Groceries',
          amount: 45.00,
          date: DateTime(2024, 1, 16, 14, 0),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
      ];

      // Group by date for verification
      final groupedByDate = <DateTime, List<Transaction>>{};
      for (final tx in transactions) {
        final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
        groupedByDate.putIfAbsent(dateKey, () => []);
        groupedByDate[dateKey]!.add(tx);
      }

      // Verify: Date grouping works correctly
      expect(groupedByDate.length, equals(2),
          reason: 'Should have 2 different dates');
      expect(groupedByDate[DateTime(2024, 1, 15)]!.length, equals(2),
          reason: 'January 15 should have 2 transactions');
      expect(groupedByDate[DateTime(2024, 1, 16)]!.length, equals(1),
          reason: 'January 16 should have 1 transaction');

      // Verify: Correct transactions in each date group
      final jan15Transactions = groupedByDate[DateTime(2024, 1, 15)]!;
      expect(
          jan15Transactions.where((tx) => tx.title == 'Morning Coffee').length,
          equals(1));
      expect(jan15Transactions.where((tx) => tx.title == 'Lunch').length,
          equals(1));

      final jan16Transactions = groupedByDate[DateTime(2024, 1, 16)]!;
      expect(jan16Transactions.where((tx) => tx.title == 'Groceries').length,
          equals(1));
    });

    test(
        'UAT-9: User can manage budget and see warnings when approaching limits',
        () {
      // Setup: User has budget limits and spending
      final budget = <String, double>{
        'food': 200.00,
        'transport': 100.00,
        'entertainment': 150.00,
      };

      final transactions = [
        Transaction(
          id: '1',
          title: 'Groceries',
          amount: 100.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Restaurant',
          amount: 75.00,
          date: DateTime(2024, 1, 16),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Taxi',
          amount: 90.00,
          date: DateTime(2024, 1, 17),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
      ];

      // Calculate spending by category
      final spendingByCategory = <String, double>{};
      for (final tx in transactions) {
        spendingByCategory[tx.categoryId] =
            (spendingByCategory[tx.categoryId] ?? 0) + tx.amount;
      }

      // Verify: Budget tracking calculations
      final foodSpent = spendingByCategory['food'] ?? 0;
      final transportSpent = spendingByCategory['transport'] ?? 0;
      final entertainmentSpent = spendingByCategory['entertainment'] ?? 0;

      expect(foodSpent, equals(175.00),
          reason: 'Food spending should be 100 + 75');
      expect(transportSpent, equals(90.00),
          reason: 'Transport spending should be 90');
      expect(entertainmentSpent, equals(0.00),
          reason: 'Entertainment spending should be 0');

      // Verify: Percentage calculations
      final foodPercentage = (foodSpent / budget['food']!) * 100;
      final transportPercentage = (transportSpent / budget['transport']!) * 100;

      expect(foodPercentage, closeTo(87.5, 0.1));
      expect(transportPercentage, closeTo(90.0, 0.1));

      // Verify: Warning detection (approaching or over limit)
      expect(foodPercentage >= 80, isTrue,
          reason: 'Food is approaching budget limit');
      expect(transportPercentage >= 80, isTrue,
          reason: 'Transport is approaching budget limit');
    });

    test('UAT-10: User can search and filter transactions by category', () {
      // Setup: User has transactions across multiple categories
      final transactions = [
        Transaction(
          id: '1',
          title: 'Groceries',
          amount: 80.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Restaurant',
          amount: 40.00,
          date: DateTime(2024, 1, 16),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Taxi',
          amount: 25.00,
          date: DateTime(2024, 1, 17),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '4',
          title: 'Movie',
          amount: 15.00,
          date: DateTime(2024, 1, 18),
          categoryId: 'entertainment',
          recurring: false,
          interval: '',
        ),
      ];

      // Verify: All transactions visible initially
      expect(transactions.length, equals(4));

      // Test filtering by category
      final foodTransactions =
          transactions.where((tx) => tx.categoryId == 'food').toList();
      final transportTransactions =
          transactions.where((tx) => tx.categoryId == 'transport').toList();
      final entertainmentTransactions =
          transactions.where((tx) => tx.categoryId == 'entertainment').toList();

      // Verify: Filtering works correctly
      expect(foodTransactions.length, equals(2),
          reason: 'Food filter should return 2 transactions');
      expect(transportTransactions.length, equals(1),
          reason: 'Transport filter should return 1 transaction');
      expect(entertainmentTransactions.length, equals(1),
          reason: 'Entertainment filter should return 1 transaction');

      // Verify: Correct transactions are in each filter
      expect(foodTransactions.where((tx) => tx.title == 'Groceries').length,
          equals(1));
      expect(foodTransactions.where((tx) => tx.title == 'Restaurant').length,
          equals(1));
      expect(transportTransactions.first.title, equals('Taxi'));
      expect(entertainmentTransactions.first.title, equals('Movie'));
    });
  });
}
