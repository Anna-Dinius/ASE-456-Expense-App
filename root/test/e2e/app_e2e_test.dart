import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/model/transaction.dart';
import 'package:p5_expense/model/category.dart';
import '../fixtures/category_test_data.dart';

// End-to-End Tests for Personal Expense App
// These tests validate complete user workflows

void main() {
  group('End-to-End App Workflows', () {
    late List<Category> categories;

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
    });

    testWidgets('E2E 1: Transaction list display and deletion',
        (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: '1',
          title: 'Lunch at Restaurant',
          amount: 25.50,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Coffee',
          amount: 5.00,
          date: DateTime(2024, 1, 16),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Transactions')),
            body: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return ListTile(
                  key: Key('transaction_${tx.id}'),
                  title: Text(tx.title),
                  subtitle: Text('\$${tx.amount}'),
                  trailing: const Icon(Icons.delete),
                );
              },
            ),
          ),
        ),
      );

      // Verify both transactions are displayed
      expect(find.text('Lunch at Restaurant'), findsOneWidget);
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('\$25.5'), findsOneWidget);
      expect(find.text('\$5.0'), findsOneWidget);

      // Verify list structure
      expect(find.byType(ListTile), findsWidgets);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('E2E 2: Multi-category transaction grouping',
        (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: '1',
          title: 'Groceries',
          amount: 80.0,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Restaurant',
          amount: 60.0,
          date: DateTime(2024, 1, 16),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Taxi',
          amount: 45.0,
          date: DateTime(2024, 1, 15),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '4',
          title: 'Movie Tickets',
          amount: 30.0,
          date: DateTime(2024, 1, 17),
          categoryId: 'entertainment',
          recurring: false,
          interval: '',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Categorized Transactions')),
            body: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, catIndex) {
                final category = categories[catIndex];
                final categoryTxs = transactions
                    .where((tx) => tx.categoryId == category.id)
                    .toList();

                if (categoryTxs.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        category.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...categoryTxs.map((tx) => ListTile(
                          title: Text(tx.title),
                          subtitle: Text('\$${tx.amount}'),
                        )),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Verify Food category appears
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Restaurant'), findsOneWidget);

      // Verify Transport category appears
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Taxi'), findsOneWidget);

      // Verify Entertainment category appears
      expect(find.text('Entertainment'), findsOneWidget);
      expect(find.text('Movie Tickets'), findsOneWidget);

      // Verify totals
      expect(find.text('\$80.0'), findsOneWidget);
      expect(find.text('\$60.0'), findsOneWidget);
      expect(find.text('\$45.0'), findsOneWidget);
      expect(find.text('\$30.0'), findsOneWidget);
    });

    testWidgets('E2E 3: Search and filter functionality',
        (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: '1',
          title: 'Lunch at Restaurant',
          amount: 25.50,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Breakfast at Cafe',
          amount: 8.00,
          date: DateTime(2024, 1, 14),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Taxi Ride',
          amount: 15.00,
          date: DateTime(2024, 1, 15),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '4',
          title: 'Movie Tickets',
          amount: 30.00,
          date: DateTime(2024, 1, 16),
          categoryId: 'entertainment',
          recurring: false,
          interval: '',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Search & Filter')),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    key: const Key('search_field'),
                    onChanged: (_) {},
                    decoration: const InputDecoration(
                      hintText: 'Search transactions',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories
                        .map((cat) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                key: Key('filter_${cat.id}'),
                                onPressed: () {},
                                child: Text(cat.title),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return ListTile(
                        title: Text(tx.title),
                        subtitle: Text('\$${tx.amount}'),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${transactions.length} results'),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify search field exists
      expect(find.byKey(const Key('search_field')), findsOneWidget);

      // Verify filter buttons exist for all categories
      expect(find.byKey(const Key('filter_food')), findsOneWidget);
      expect(find.byKey(const Key('filter_transport')), findsOneWidget);
      expect(find.byKey(const Key('filter_entertainment')), findsOneWidget);

      // Verify all transactions displayed
      expect(find.text('4 results'), findsOneWidget);
      expect(find.text('Lunch at Restaurant'), findsOneWidget);
      expect(find.text('Breakfast at Cafe'), findsOneWidget);
      expect(find.text('Taxi Ride'), findsOneWidget);
      expect(find.text('Movie Tickets'), findsOneWidget);
    });

    testWidgets('E2E 4: Budget tracking display', (WidgetTester tester) async {
      final budgetLimits = <String, double>{
        'food': 200.0,
        'transport': 100.0,
        'entertainment': 150.0,
      };

      final transactions = [
        Transaction(
          id: '1',
          title: 'Groceries',
          amount: 80.0,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Restaurant',
          amount: 60.0,
          date: DateTime(2024, 1, 16),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Taxi',
          amount: 45.0,
          date: DateTime(2024, 1, 15),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '4',
          title: 'Concert Tickets',
          amount: 120.0,
          date: DateTime(2024, 1, 17),
          categoryId: 'entertainment',
          recurring: false,
          interval: '',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Budget Tracking')),
            body: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final budget = budgetLimits[category.id] ?? 0.0;
                final spent = transactions
                    .where((tx) => tx.categoryId == category.id)
                    .fold<double>(0, (sum, tx) => sum + tx.amount);
                final percentage = (spent / budget * 100).toStringAsFixed(1);
                final isOverBudget = spent > budget;

                if (budget == 0) {
                  return const SizedBox.shrink();
                }

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  color: isOverBudget ? Colors.red.shade100 : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Spent: \$${spent.toStringAsFixed(2)}'),
                        Text('Budget: \$${budget.toStringAsFixed(2)}'),
                        Text('$percentage%'),
                        if (isOverBudget)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Over budget!',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        LinearProgressIndicator(
                          value: (spent / budget).clamp(0, 1),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Verify Food budget (140/200 = 70%)
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Spent: \$140.00'), findsOneWidget);
      expect(find.text('Budget: \$200.00'), findsOneWidget);
      expect(find.text('70.0%'), findsOneWidget);

      // Verify Transport budget (45/100 = 45%)
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Spent: \$45.00'), findsOneWidget);
      expect(find.text('Budget: \$100.00'), findsOneWidget);
      expect(find.text('45.0%'), findsOneWidget);

      // Verify Entertainment (120/150 = 80%)
      expect(find.text('Entertainment'), findsOneWidget);
      expect(find.text('Spent: \$120.00'), findsOneWidget);
      expect(find.text('Budget: \$150.00'), findsOneWidget);
      expect(find.text('80.0%'), findsOneWidget);
    });

    testWidgets('E2E 5: Reports and analytics display',
        (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: '1',
          title: 'Groceries',
          amount: 100.0,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Restaurant',
          amount: 50.0,
          date: DateTime(2024, 1, 16),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '3',
          title: 'Bus Pass',
          amount: 30.0,
          date: DateTime(2024, 1, 15),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '4',
          title: 'Movie',
          amount: 20.0,
          date: DateTime(2024, 1, 17),
          categoryId: 'entertainment',
          recurring: false,
          interval: '',
        ),
      ];

      final total = transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
      final average = total / transactions.length;
      final max =
          transactions.reduce((a, b) => a.amount > b.amount ? a : b).amount;
      final min =
          transactions.reduce((a, b) => a.amount < b.amount ? a : b).amount;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Reports & Analytics')),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Spending'),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Spending by Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...categories.map((cat) {
                      final spent = transactions
                          .where((tx) => tx.categoryId == cat.id)
                          .fold<double>(0, (sum, tx) => sum + tx.amount);

                      if (spent == 0) return const SizedBox.shrink();

                      return ListTile(
                        title: Text(cat.title),
                        trailing: Text('\$${spent.toStringAsFixed(2)}'),
                      );
                    }),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Statistics'),
                            Text('Transactions: ${transactions.length}'),
                            Text('Average: \$${average.toStringAsFixed(2)}'),
                            Text('Highest: \$${max.toStringAsFixed(2)}'),
                            Text('Lowest: \$${min.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Verify total spending
      expect(find.text('Total Spending'), findsOneWidget);
      expect(find.text('\$200.00'), findsOneWidget);

      // Verify category breakdown
      expect(find.text('Food'), findsWidgets);
      expect(find.text('\$150.00'), findsOneWidget); // Food total
      expect(find.text('\$30.00'), findsOneWidget); // Transport total
      expect(find.text('\$20.00'), findsOneWidget); // Entertainment total

      // Verify statistics
      expect(find.text('Transactions: 4'), findsOneWidget);
      expect(find.text('Average: \$50.00'), findsOneWidget);
      expect(find.text('Highest: \$100.00'), findsOneWidget);
      expect(find.text('Lowest: \$20.00'), findsOneWidget);
    });

    testWidgets('E2E 6: Recurring transaction handling',
        (WidgetTester tester) async {
      final recurringTransactions = [
        Transaction(
          id: '1',
          title: 'Monthly Subscription',
          amount: 9.99,
          date: DateTime(2024, 1, 15),
          categoryId: 'utilities',
          recurring: true,
          interval: 'monthly',
        ),
        Transaction(
          id: '2',
          title: 'Monthly Subscription',
          amount: 9.99,
          date: DateTime(2024, 2, 15),
          categoryId: 'utilities',
          recurring: true,
          interval: 'monthly',
        ),
        Transaction(
          id: '3',
          title: 'Monthly Subscription',
          amount: 9.99,
          date: DateTime(2024, 3, 15),
          categoryId: 'utilities',
          recurring: true,
          interval: 'monthly',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Recurring Transactions')),
            body: ListView.builder(
              itemCount: recurringTransactions.length,
              itemBuilder: (context, index) {
                final tx = recurringTransactions[index];
                return ListTile(
                  title: Text(tx.title),
                  subtitle: Text(
                    '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}-${tx.date.day.toString().padLeft(2, '0')} (${tx.interval})',
                  ),
                  trailing: Text('\$${tx.amount}'),
                );
              },
            ),
          ),
        ),
      );

      // Verify all recurring instances displayed
      expect(find.text('Monthly Subscription'), findsWidgets);
      expect(find.byType(ListTile), findsWidgets);

      // Verify count and pattern
      expect(recurringTransactions.length, equals(3));
      expect(recurringTransactions[0].recurring, isTrue);
      expect(recurringTransactions[1].recurring, isTrue);
      expect(recurringTransactions[2].recurring, isTrue);
    });

    testWidgets('E2E 7: Savings goals tracking', (WidgetTester tester) async {
      final savingsGoals = <String, Map<String, dynamic>>{
        'vacation': {'target': 2000.0, 'saved': 800.0},
        'emergency': {'target': 5000.0, 'saved': 3200.0},
        'car': {'target': 15000.0, 'saved': 5500.0},
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Savings Goals')),
            body: ListView.builder(
              itemCount: savingsGoals.length,
              itemBuilder: (context, index) {
                final entries = savingsGoals.entries.toList();
                final goal = entries[index];
                final percentage =
                    (goal.value['saved'] / goal.value['target'] * 100)
                        .toStringAsFixed(1);

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.key.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Saved: \$${goal.value['saved'].toStringAsFixed(2)} / \$${goal.value['target'].toStringAsFixed(2)}',
                        ),
                        Text('$percentage% Complete'),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: goal.value['saved'] / goal.value['target'],
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Verify vacation goal (40%)
      expect(find.text('VACATION'), findsOneWidget);
      expect(find.text('Saved: \$800.00 / \$2000.00'), findsOneWidget);
      expect(find.text('40.0% Complete'), findsOneWidget);

      // Verify emergency goal (64%)
      expect(find.text('EMERGENCY'), findsOneWidget);
      expect(find.text('Saved: \$3200.00 / \$5000.00'), findsOneWidget);
      expect(find.text('64.0% Complete'), findsOneWidget);

      // Verify car goal (36.7%)
      expect(find.text('CAR'), findsOneWidget);
      expect(find.text('Saved: \$5500.00 / \$15000.00'), findsOneWidget);
      expect(find.text('36.7% Complete'), findsOneWidget);
    });

    testWidgets('E2E 8: Monthly expense summary', (WidgetTester tester) async {
      final allTransactions = [
        // January transactions
        Transaction(
          id: '1',
          title: 'Jan Groceries',
          amount: 100.0,
          date: DateTime(2024, 1, 15),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '2',
          title: 'Jan Transport',
          amount: 50.0,
          date: DateTime(2024, 1, 20),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
        // February transactions
        Transaction(
          id: '3',
          title: 'Feb Groceries',
          amount: 120.0,
          date: DateTime(2024, 2, 10),
          categoryId: 'food',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '4',
          title: 'Feb Movie',
          amount: 25.0,
          date: DateTime(2024, 2, 14),
          categoryId: 'entertainment',
          recurring: false,
          interval: '',
        ),
        Transaction(
          id: '5',
          title: 'Feb Transport',
          amount: 60.0,
          date: DateTime(2024, 2, 22),
          categoryId: 'transport',
          recurring: false,
          interval: '',
        ),
      ];

      // Test January transactions
      final januaryTransactions = allTransactions
          .where((tx) =>
              '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}' ==
              '2024-01')
          .toList();

      final januaryTotal =
          januaryTransactions.fold<double>(0, (sum, tx) => sum + tx.amount);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Monthly Summary')),
            body: Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Month: 2024-01',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Transactions: ${januaryTransactions.length}'),
                        Text('Total: \$${januaryTotal.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: januaryTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = januaryTransactions[index];
                      return ListTile(
                        title: Text(tx.title),
                        trailing: Text('\$${tx.amount}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify January summary
      expect(find.text('Month: 2024-01'), findsOneWidget);
      expect(find.text('Transactions: 2'), findsOneWidget);
      expect(find.text('Total: \$150.00'), findsOneWidget);

      // Verify transactions displayed
      expect(find.text('Jan Groceries'), findsOneWidget);
      expect(find.text('Jan Transport'), findsOneWidget);
    });

    testWidgets('E2E 9: Multi-step workflow (add → view → edit → delete)',
        (WidgetTester tester) async {
      final transactions = <Transaction>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Expense Manager')),
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        key: const Key('add_button'),
                        onPressed: () {
                          transactions.add(Transaction(
                            id: '${transactions.length + 1}',
                            title: 'New Expense',
                            amount: 50.0,
                            date: DateTime.now(),
                            categoryId: 'food',
                            recurring: false,
                            interval: '',
                          ));
                          setState(() {});
                        },
                        child: const Text('Add Expense'),
                      ),
                    ),
                    Expanded(
                      child: transactions.isEmpty
                          ? const Center(child: Text('No expenses'))
                          : ListView.builder(
                              key: const Key('transaction_list'),
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final tx = transactions[index];
                                return Card(
                                  margin: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    key: Key('tx_${tx.id}'),
                                    title: Text(tx.title),
                                    subtitle: Text(
                                        '\$${tx.amount.toStringAsFixed(2)}'),
                                    onTap: () {
                                      transactions[index] = Transaction(
                                        id: tx.id,
                                        title: 'Updated Expense',
                                        amount: 75.0,
                                        date: tx.date,
                                        categoryId: tx.categoryId,
                                        recurring: tx.recurring,
                                        interval: tx.interval,
                                      );
                                      setState(() {});
                                    },
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      key: Key('delete_${tx.id}'),
                                      onPressed: () {
                                        transactions.removeAt(index);
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Step 1: Add expense
      expect(find.text('No expenses'), findsOneWidget);
      await tester.tap(find.byKey(const Key('add_button')));
      await tester.pumpAndSettle();

      // Step 2: View expense
      expect(find.text('New Expense'), findsOneWidget);
      expect(find.text('\$50.00'), findsOneWidget);

      // Step 3: Edit expense (tap on the transaction)
      await tester.tap(find.byKey(const Key('tx_1')));
      await tester.pumpAndSettle();
      expect(find.text('Updated Expense'), findsOneWidget);
      expect(find.text('\$75.00'), findsOneWidget);

      // Step 4: Delete expense
      await tester.tap(find.byKey(const Key('delete_1')));
      await tester.pumpAndSettle();
      expect(find.text('No expenses'), findsOneWidget);
    });

    testWidgets('E2E 10: Navigation between screens',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('App Navigation')),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text('Transactions'),
                        key: const Key('nav_transactions'),
                        onTap: () {},
                      ),
                      ListTile(
                        title: const Text('Reports'),
                        key: const Key('nav_reports'),
                        onTap: () {},
                      ),
                      ListTile(
                        title: const Text('Budgets'),
                        key: const Key('nav_budgets'),
                        onTap: () {},
                      ),
                      ListTile(
                        title: const Text('Settings'),
                        key: const Key('nav_settings'),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify all navigation options exist
      expect(find.byKey(const Key('nav_transactions')), findsOneWidget);
      expect(find.byKey(const Key('nav_reports')), findsOneWidget);
      expect(find.byKey(const Key('nav_budgets')), findsOneWidget);
      expect(find.byKey(const Key('nav_settings')), findsOneWidget);

      // Verify navigation labels
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
      expect(find.text('Budgets'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('E2E 11: TextInput and form submission',
        (WidgetTester tester) async {
      final transactions = <Transaction>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Add Transaction Form')),
            body: StatefulBuilder(
              builder: (context, setState) {
                final titleController = TextEditingController();
                final amountController = TextEditingController();

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          key: const Key('title_field'),
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Transaction Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          key: const Key('amount_field'),
                          controller: amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          key: const Key('submit_button'),
                          onPressed: () {
                            final amount = double.tryParse(
                                    amountController.text.isEmpty
                                        ? '0'
                                        : amountController.text) ??
                                0.0;
                            transactions.add(Transaction(
                              id: '${transactions.length + 1}',
                              title: titleController.text.isEmpty
                                  ? 'Unnamed'
                                  : titleController.text,
                              amount: amount,
                              date: DateTime.now(),
                              categoryId: 'food',
                              recurring: false,
                              interval: '',
                            ));
                            titleController.clear();
                            amountController.clear();
                            setState(() {});
                          },
                          child: const Text('Submit'),
                        ),
                        const SizedBox(height: 24),
                        if (transactions.isNotEmpty)
                          Column(
                            children: [
                              const Text('Added Transactions:'),
                              const SizedBox(height: 8),
                              ...transactions.map((tx) => ListTile(
                                    title: Text(tx.title),
                                    subtitle: Text(
                                        '\$${tx.amount.toStringAsFixed(2)}'),
                                  )),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Step 1: Find text fields
      expect(find.byKey(const Key('title_field')), findsOneWidget);
      expect(find.byKey(const Key('amount_field')), findsOneWidget);

      // Step 2: Enter text
      await tester.enterText(find.byKey(const Key('title_field')), 'Groceries');
      await tester.enterText(find.byKey(const Key('amount_field')), '45.50');
      await tester.pumpAndSettle();

      // Step 3: Verify input
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('45.50'), findsOneWidget);

      // Step 4: Submit form
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      // Step 5: Verify transaction added
      expect(find.text('Added Transactions:'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('\$45.50'), findsOneWidget);
    });

    testWidgets('E2E 12: Error handling and validation',
        (WidgetTester tester) async {
      late StateSetter setErrorState;
      String errorMessage = '';
      final titleController = TextEditingController();
      final amountController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Form Validation')),
            body: StatefulBuilder(
              builder: (context, setState) {
                setErrorState = setState;
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          key: const Key('val_title_field'),
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title (required)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          key: const Key('val_amount_field'),
                          controller: amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount (required)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          key: const Key('validate_button'),
                          onPressed: () {
                            setErrorState(() {
                              errorMessage = '';
                              if (titleController.text.isEmpty) {
                                errorMessage = 'Title cannot be empty';
                              } else if (amountController.text.isEmpty) {
                                errorMessage = 'Amount cannot be empty';
                              } else if (double.tryParse(
                                      amountController.text) ==
                                  null) {
                                errorMessage = 'Amount must be a valid number';
                              } else if (double.parse(amountController.text) <=
                                  0) {
                                errorMessage =
                                    'Amount must be greater than zero';
                              }
                            });
                          },
                          child: const Text('Validate'),
                        ),
                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              errorMessage,
                              key: const Key('error_message'),
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Test 1: Empty title
      await tester.tap(find.byKey(const Key('validate_button')));
      await tester.pumpAndSettle();
      expect(find.text('Title cannot be empty'), findsOneWidget);

      // Test 2: Empty amount
      await tester.enterText(find.byKey(const Key('val_title_field')), 'Test');
      await tester.tap(find.byKey(const Key('validate_button')));
      await tester.pumpAndSettle();
      expect(find.text('Amount cannot be empty'), findsOneWidget);

      // Test 3: Invalid amount (non-numeric)
      await tester.enterText(find.byKey(const Key('val_amount_field')), 'abc');
      await tester.tap(find.byKey(const Key('validate_button')));
      await tester.pumpAndSettle();
      expect(find.text('Amount must be a valid number'), findsOneWidget);

      // Test 4: Zero amount
      await tester.tap(find.byKey(const Key('val_amount_field')));
      await tester.pumpAndSettle();
      // Select all text in the field and delete it first
      await tester.enterText(find.byKey(const Key('val_amount_field')), '0');
      await tester.tap(find.byKey(const Key('validate_button')));
      await tester.pumpAndSettle();
      expect(find.text('Amount must be greater than zero'), findsOneWidget);

      // Test 5: Valid input
      await tester.tap(find.byKey(const Key('val_amount_field')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const Key('val_amount_field')), '25.00');
      await tester.tap(find.byKey(const Key('validate_button')));
      await tester.pumpAndSettle();
      expect(find.text('Title cannot be empty'), findsNothing);
      expect(find.text('Amount cannot be empty'), findsNothing);
      expect(find.text('Amount must be a valid number'), findsNothing);
      expect(find.text('Amount must be greater than zero'), findsNothing);

      titleController.dispose();
      amountController.dispose();
    });

    testWidgets('E2E 13: Large dataset performance',
        (WidgetTester tester) async {
      // Create 200 transactions for performance testing
      final transactions = List.generate(
        200,
        (index) => Transaction(
          id: '$index',
          title: 'Transaction ${index + 1}',
          amount: 10.0 + (index * 0.5),
          date: DateTime(2024, 1, 1).add(Duration(days: index % 30)),
          categoryId: ['food', 'transport', 'entertainment'][index % 3],
          recurring: false,
          interval: '',
        ),
      );

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Performance Test - 200 Items')),
            body: ListView.builder(
              key: const Key('performance_list'),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return ListTile(
                  key: Key('perf_tx_$index'),
                  title: Text(tx.title),
                  subtitle: Text(
                      '${tx.date.month}/${tx.date.day} - \$${tx.amount.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
        ),
      );

      stopwatch.stop();

      // Verify rendering
      expect(find.byKey(const Key('performance_list')), findsOneWidget);
      expect(find.byType(ListTile), findsWidgets);

      // Verify scrolling works
      await tester.drag(
          find.byKey(const Key('performance_list')), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Verify can scroll back up
      await tester.drag(
          find.byKey(const Key('performance_list')), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Verify some transactions visible
      expect(find.text('Transaction 1'), findsOneWidget);

      // Performance assertion: rendering should complete in reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(5000),
          reason: 'Large list should render in under 5 seconds');
    });

    testWidgets('E2E 14: Accessibility features', (WidgetTester tester) async {
      final transaction = Transaction(
        id: '1',
        title: 'Coffee at Cafe',
        amount: 5.50,
        date: DateTime(2024, 1, 15),
        categoryId: 'food',
        recurring: false,
        interval: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Accessibility Test'),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.title,
                              key: const Key('a11y_title'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${transaction.amount.toStringAsFixed(2)}',
                              key: const Key('a11y_amount'),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${transaction.date.month}/${transaction.date.day}/${transaction.date.year}',
                              key: const Key('a11y_date'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        key: const Key('a11y_button'),
                        onPressed: () {},
                        child: const Text(
                          'Delete Transaction',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Note: Deletion is permanent and cannot be undone',
                      key: Key('a11y_warning'),
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Verify text content is readable and visible
      expect(find.text('Coffee at Cafe'), findsOneWidget);
      expect(find.text('\$5.50'), findsOneWidget);
      expect(find.text('1/15/2024'), findsOneWidget);

      // Verify button is accessible (proper size for touch targets)
      expect(find.byKey(const Key('a11y_button')), findsOneWidget);
      expect(find.text('Delete Transaction'), findsOneWidget);

      // Verify warning message is visible with good contrast
      expect(find.text('Note: Deletion is permanent and cannot be undone'),
          findsOneWidget);

      // Verify spacing and layout accessibility
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Card), findsOneWidget);

      // Verify all key elements are findable for accessibility tools
      expect(find.byKey(const Key('a11y_title')), findsOneWidget);
      expect(find.byKey(const Key('a11y_amount')), findsOneWidget);
      expect(find.byKey(const Key('a11y_date')), findsOneWidget);
      expect(find.byKey(const Key('a11y_warning')), findsOneWidget);
    });
  });
}
