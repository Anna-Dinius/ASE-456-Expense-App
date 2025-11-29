# Acceptance Tests for Personal Expense App

## Overview

This directory contains **User Acceptance Tests (UAT)** that validate core user workflows and business requirements from a user's perspective. These tests focus on **what users can accomplish** - not implementation details - through business logic verification and data calculations.

**Total Tests:** 10  
**Status:** ✅ All passing  
**Framework:** Dart testing (`test` package)  
**Execution Time:** ~1-2 seconds

---

## Quick Start

### Run All Acceptance Tests

```bash
cd root
flutter test test/acceptance/
```

### Run Specific Test File

```bash
flutter test test/acceptance/user_acceptance_test.dart
```

### Run with Verbose Output

```bash
flutter test test/acceptance/user_acceptance_test.dart -v
```

### Run Specific Test Case

```bash
flutter test test/acceptance/user_acceptance_test.dart -p vm \
  --plain-name "UAT-1"
```

### Run with Coverage

```bash
flutter test test/acceptance/user_acceptance_test.dart --coverage
```

---

## Test Scenarios

### UAT-1: User can add a new transaction to their list

**User Story:** "As a user, I want to add a new transaction so that I can track my expenses"

**What's Tested:**

- Transaction creation with all required fields
- Data is preserved correctly
- Transaction can be retrieved from the list

**Business Value:**

- Core feature for expense tracking
- Validates basic CRUD functionality
- Ensures data is stored accurately

**Test Logic:**

```dart
// Empty list starts empty
expect(transactions.isEmpty, isTrue);

// Add transaction
transactions.add(newTransaction);

// Verify it's there with correct data
expect(transactions.first.title, equals('Coffee at Cafe'));
expect(transactions.first.amount, equals(5.50));
```

---

### UAT-2: User can view their spending by category in a chart summary

**User Story:** "As a user, I want to see my spending summarized by category so I can understand where my money goes"

**What's Tested:**

- Category spending calculations
- Aggregation of multiple transactions
- Total spending accuracy

**Business Value:**

- Provides visual summary of expenses
- Helps users understand spending patterns
- Validates calculation accuracy

**Test Data:**

- Food: $127.50 (85 + 42.50)
- Transport: $35.00
- Entertainment: $15.00
- **Total: $177.50**

**Test Logic:**

```dart
// Calculate by category
spendingByCategory['food'] = 127.50;

// Verify totals
expect(spendingByCategory['food'], equals(127.50));
expect(totalSpending, equals(177.50));
```

---

### UAT-3: User can delete a transaction and have it removed from list

**User Story:** "As a user, I want to delete incorrect transactions so that my records stay accurate"

**What's Tested:**

- Transaction removal from list
- Other transactions remain intact
- Count decreases correctly

**Business Value:**

- Users can correct mistakes
- Maintains accurate expense records
- Validates data mutation

**Test Logic:**

```dart
// Start with 2 transactions
expect(transactions.length, equals(2));

// Delete one
transactions.removeWhere((tx) => tx.id == '1');

// Verify deletion
expect(transactions.length, equals(1));
expect(find.text('Unwanted Expense'), findsNothing);
```

---

### UAT-4: User can view transaction history with accurate dates and amounts

**User Story:** "As a user, I want to view my complete transaction history with accurate dates and amounts"

**What's Tested:**

- Transaction titles are preserved
- Amounts are accurate
- Dates are correct
- Data integrity is maintained

**Business Value:**

- Users have complete audit trail
- Financial accuracy is maintained
- Historical analysis is possible

**Test Data:**

- January 5: Coffee $4.50
- January 10: Lunch $15.75
- February 15: Dinner $32.00

---

### UAT-5: User can track spending in specific categories

**User Story:** "As a user, I want to track how much I spend in specific categories"

**What's Tested:**

- Filtering transactions by category
- Category total calculations
- Grouping accuracy

**Business Value:**

- Users understand where money is spent
- Budget planning by category becomes possible
- Spending patterns are identifiable

**Test Data:**

- Food: $100.50 (65 + 35.50)
- Transport: $50.00 (5 + 45)

---

### UAT-6: User can add a recurring transaction for automatic tracking

**User Story:** "As a user, I want to add recurring transactions for subscriptions so I don't have to re-enter them each month"

**What's Tested:**

- Recurring flag is stored
- Interval is preserved
- Data model supports recurring transactions

**Business Value:**

- Automatic tracking of subscriptions
- Reduces manual data entry
- Improves expense forecasting

**Test Data:**

- Transaction: Netflix
- Amount: $9.99
- Recurring: true
- Interval: monthly

---

### UAT-7: User can see total spending and spending statistics

**User Story:** "As a user, I want to see my total spending and key statistics like average, highest, and lowest"

**What's Tested:**

- Total spending calculation
- Average per transaction
- Highest transaction
- Lowest transaction
- Count of transactions

**Business Value:**

- Users understand overall spending patterns
- Budget planning is supported
- Financial analysis is enabled

**Test Data & Calculations:**

- Transactions: $8.50, $12.75, $28.50
- **Total:** $49.75
- **Average:** $16.58
- **Highest:** $28.50
- **Lowest:** $8.50

---

### UAT-8: User can view expenses organized by date

**User Story:** "As a user, I want to view and organize my expenses by date"

**What's Tested:**

- Date grouping logic
- Multiple transactions on same date
- Different dates are separated
- Transaction counts per date

**Business Value:**

- Daily expense review is possible
- Spending trends by day are visible
- Date-based filtering becomes possible

**Test Data:**

- January 15: 2 transactions (Morning Coffee, Lunch)
- January 16: 1 transaction (Groceries)

**Test Logic:**

```dart
// Group by date
groupedByDate[DateTime(2024, 1, 15)] = [tx1, tx2]
groupedByDate[DateTime(2024, 1, 16)] = [tx3]

// Verify grouping
expect(groupedByDate.length, equals(2));
expect(groupedByDate[DateTime(2024, 1, 15)]!.length, equals(2));
```

---

### UAT-9: User can manage budget and see warnings when approaching limits

**User Story:** "As a user, I want to set budget limits and see warnings when I approach them"

**What's Tested:**

- Budget limits can be tracked
- Spending calculation against budget
- Percentage calculations
- Warning detection (80%+ of budget)

**Business Value:**

- Users stay within financial limits
- Budget overages are visible
- Financial planning is supported

**Test Data:**

- Food Budget: $200 (Spent: $175 = 87.5%)
- Transport Budget: $100 (Spent: $90 = 90%)
- Entertainment Budget: $150 (Spent: $0 = 0%)

**Test Logic:**

```dart
// Calculate percentage
final percentage = (spent / limit) * 100;

// Check if approaching limit
expect(percentage >= 80, isTrue);  // Warning threshold
```

---

### UAT-10: User can search and filter transactions by category

**User Story:** "As a user, I want to filter my transactions by category to find specific expense types"

**What's Tested:**

- Category filtering logic
- Correct transactions returned
- Filter accuracy
- Result counts

**Business Value:**

- Quick access to specific expense types
- Financial analysis by category
- Reduces information overload

**Test Data:**

- 4 total transactions across categories
- Food: 2 transactions
- Transport: 1 transaction
- Entertainment: 1 transaction

**Test Logic:**

```dart
// Filter by category
final foodTransactions = transactions
    .where((tx) => tx.categoryId == 'food')
    .toList();

// Verify results
expect(foodTransactions.length, equals(2));
```

---

## Test Approach: Business Logic Focused

Unlike widget tests that verify UI rendering, these acceptance tests focus on **business logic and calculations** that users care about:

### ✅ TESTED:

- Data accuracy and calculations
- Business rule enforcement
- Transaction management operations
- Category and budget calculations
- Filtering and grouping logic
- Date handling and organization

### ❌ NOT TESTED HERE:

- UI widget rendering (covered by E2E tests)
- Form validation
- Navigation between screens
- Widget layout details
- Visual styling

---

## Test Statistics

| Aspect                 | Value                       |
| ---------------------- | --------------------------- |
| Total Test Files       | 1                           |
| Total Acceptance Tests | 10                          |
| Test Type              | Unit Tests (Business Logic) |
| Avg Test Duration      | ~0.1-0.2 seconds each       |
| Total Execution Time   | ~1-2 seconds                |
| Focus Area             | Data & Calculations         |
| External Dependencies  | None                        |
| Firebase Required      | No                          |

---

## Test Data & Fixtures

### Creating Test Transactions

```dart
final transaction = Transaction(
  id: '1',
  title: 'Coffee at Cafe',
  amount: 5.50,
  date: DateTime(2024, 1, 15),
  categoryId: 'food',
  recurring: false,
  interval: '',
);
```

### Calculating Statistics

```dart
// Total spending
final total = transactions
    .fold<double>(0, (sum, tx) => sum + tx.amount);

// Average per transaction
final average = total / transactions.length;

// Highest and lowest
final highest = transactions
    .map((tx) => tx.amount)
    .reduce((a, b) => a > b ? a : b);

final lowest = transactions
    .map((tx) => tx.amount)
    .reduce((a, b) => a < b ? a : b);
```

### Filtering by Category

```dart
final foodSpending = transactions
    .where((tx) => tx.categoryId == 'food')
    .fold<double>(0, (sum, tx) => sum + tx.amount);
```

### Grouping by Date

```dart
final groupedByDate = <DateTime, List<Transaction>>{};
for (final tx in transactions) {
  final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
  groupedByDate.putIfAbsent(dateKey, () => []);
  groupedByDate[dateKey]!.add(tx);
}
```

---

## Running Tests

### Run All Tests

```bash
flutter test test/acceptance/
```

### Run with Verbose Output

```bash
flutter test test/acceptance/ -v
```

### Run Specific Test

```bash
flutter test test/acceptance/user_acceptance_test.dart \
  -p vm --plain-name "UAT-1"
```

### Run and Generate Report

```bash
flutter test test/acceptance/ --reporter=json > results.json
```

### Watch Mode (Development)

```bash
flutter test test/acceptance/ --watch
```

---

## Comparison with Other Test Types

| Aspect                   | Acceptance | E2E  | Integration | Unit    |
| ------------------------ | ---------- | ---- | ----------- | ------- |
| **Focus**                | User Goals | UI   | Workflows   | Code    |
| **Test Type**            | Logic      | UI   | UI + Logic  | Code    |
| **Dependencies**         | None       | None | None        | None    |
| **Execution Time**       | Fast       | Slow | Medium      | Fastest |
| **Tests Per File**       | 5-20       | 5-8  | 20-50       | 100+    |
| **Business Value Focus** | ✅ Yes     | No   | Yes         | No      |
| **UI Widget Testing**    | No         | Yes  | Yes         | No      |
| **Data Testing**         | ✅ Yes     | No   | Yes         | Yes     |

---

## Best Practices

### 1. Focus on Business Value

Each test answers: "Why does this matter to the user?"

```dart
// ✅ GOOD: Clear business goal
test('User can track spending by category', () {
  final foodSpending = transactions
      .where((tx) => tx.categoryId == 'food')
      .fold(0, (sum, tx) => sum + tx.amount);
  expect(foodSpending, equals(100.50));
});

// ❌ AVOID: Testing implementation details
test('Where clause works correctly', () {
  // This tests the language, not the business logic
});
```

### 2. Use Clear Test Names

```dart
// ✅ GOOD: Describes user goal
'UAT-1: User can add a new transaction to their list'

// ❌ AVOID: Unclear naming
'test_add_transaction'
```

### 3. Keep Tests Independent

Each test should work alone without depending on other tests:

```dart
// ✅ GOOD: Self-contained
test('UAT-1', () {
  final transactions = <Transaction>[];
  // Complete test
});

// ❌ AVOID: Depends on state from previous test
test('UAT-2', () {
  // Assumes UAT-1 was run first
});
```

### 4. Use Meaningful Assertions

```dart
// ✅ GOOD: Clear reason and value
expect(foodSpending, equals(100.50),
    reason: 'Food spending should be 65 + 35.50');

// ❌ AVOID: Unclear what's being tested
expect(result, true);
```

### 5. Test Business Rules, Not Implementation

```dart
// ✅ GOOD: Tests the business requirement
final average = total / transactions.length;
expect(average, closeTo(16.583, 0.01));

// ❌ AVOID: Tests language feature
expect([1, 2, 3].where((x) => x > 1).length, equals(2));
```

---

## Troubleshooting

### Issue: Test fails on floating point comparison

**Cause:** Floating point precision issues  
**Solution:** Use `closeTo()` for double comparisons

```dart
// ✅ CORRECT: Accounts for precision
expect(average, closeTo(16.583, 0.01));

// ❌ WRONG: May fail due to precision
expect(average, equals(16.583333333));
```

### Issue: Assertion fails on calculated values

**Cause:** Wrong calculation logic  
**Solution:** Break down calculation into steps and verify each

```dart
// Verify each step
final total = transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
expect(total, equals(49.75));

final average = total / transactions.length;
expect(average, closeTo(16.583, 0.01));
```

### Issue: Test data not set up correctly

**Cause:** Missing or incorrect test data  
**Solution:** Verify test data before running assertions

```dart
// Verify setup
expect(transactions.length, equals(3));
expect(transactions.first.title, equals('Breakfast'));

// Then test calculations
final total = transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
```

---

## Adding New Acceptance Tests

### 1. Identify User Goal

```
"As a user, I want to [action] so that [benefit]"
```

### 2. Create Test in `user_acceptance_test.dart`

```dart
test('UAT-#: User can [goal]', () {
  // GIVEN: Setup data
  final transactions = [/* test data */];

  // WHEN: Perform operation
  final result = transactions
      .where((tx) => tx.categoryId == 'food')
      .toList();

  // THEN: Verify business rule
  expect(result.length, equals(2));
});
```

### 3. Follow Naming Convention

- **File:** Must end with `_test.dart` for Flutter test discovery
- **Group:** `'User Acceptance Tests - [Feature Area]'`
- **Test:** `'UAT-#: User can [action]'`

### 4. Focus on User Goals

- Does this test validate a real user goal?
- Would a product manager care about this test?
- Does it ensure business requirements are met?

---

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Acceptance Tests
on: [push, pull_request]

jobs:
  acceptance-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v1
      - run: cd root && flutter test test/acceptance/
```

---

## Test Coverage

### User Workflows Covered

✅ **Transaction Management**

- Add transactions
- Delete transactions
- View transaction history
- Track by category

✅ **Financial Analysis**

- View spending summary
- Calculate statistics (average, high, low)
- Track by date

✅ **Budget Management**

- Set budget limits
- Track spending vs. budget
- View warning indicators

✅ **Advanced Features**

- Add recurring transactions
- Search and filter by category
- Organize by date

### Coverage Matrix

| Feature                  | UAT | Integration | E2E |
| ------------------------ | --- | ----------- | --- |
| Add Transaction          | ✅  | ✅          | ✅  |
| Delete Transaction       | ✅  | ✅          | ✅  |
| View Transaction History | ✅  | ✅          | ✅  |
| Track by Category        | ✅  | ✅          | ✅  |
| View Spending Summary    | ✅  | ✅          | ✅  |
| Budget Tracking          | ✅  | ✅          | ✅  |
| Recurring Transactions   | ✅  | ✅          | ✅  |
| Filtering & Searching    | ✅  | ✅          | ✅  |
| Date Organization        | ✅  | ✅          | ✅  |
| Statistics Calculations  | ✅  | ✅          | ✅  |

---

## File Structure

```
root/test/acceptance/
├── README.md (this file)
└── user_acceptance_test.dart (10 UAT scenarios)
```

---

## Related Test Files

- **E2E Tests:** `test/e2e/README.md` (8 UI validation tests)
- **Integration Tests:** `test/integration/README.md` (49 integration tests)
- **Service Tests:** `test/service/` (service layer tests)
- **Model Tests:** `test/model/` (data model tests)

---

## Acceptance Criteria Met

✅ **All 10 Core User Workflows Tested**

1. Add transactions
2. View spending by category
3. Delete transactions
4. View transaction history
5. Track category spending
6. Add recurring transactions
7. View spending statistics
8. View expenses by date
9. Manage budgets
10. Search and filter transactions

✅ **Fast Execution** (~1-2 seconds)
✅ **No External Dependencies** (No Firebase, etc.)
✅ **Clear Business Value** (Each test maps to user goal)
✅ **Easy to Maintain** (Consistent patterns)
✅ **Easy to Extend** (Simple test structure)

---

## Support & Contact

For questions about acceptance tests:

1. Review test names - they describe user goals
2. Check test data - understand what's being tested
3. Review test logic - see what calculation/filter is being verified
4. Check related tests for patterns

---

**Last Updated:** November 29, 2025  
**Test Suite Version:** 1.0  
**Total Acceptance Tests:** 10  
**Pass Rate:** ✅ All passing  
**Execution Time:** ~1-2 seconds

---

## Quick Start

### Run All Acceptance Tests

```bash
cd root
flutter test test/acceptance/
```

### Run Specific Test File

```bash
flutter test test/acceptance/user_acceptance_test.dart
```

### Run with Verbose Output

```bash
flutter test test/acceptance/user_acceptance_test.dart -v
```

### Run Specific Test Case

```bash
flutter test test/acceptance/user_acceptance_test.dart \
  -n "UAT-1: As a user"
```

### Run with Coverage

```bash
flutter test test/acceptance/user_acceptance_test.dart --coverage
```

---

## Test Scenarios

### UAT-1: Add Transaction and View in List

**User Story:** "As a user, I can add a new transaction and see it in my list"

**What's Being Tested:**

- User can open the transaction form
- User can enter transaction title
- User can enter transaction amount
- New transaction appears in the transaction list
- Transaction data is persisted correctly

**Business Value:**

- Core feature for expense tracking
- Validates basic CRUD functionality
- Ensures data flows correctly between form and list

**Test Steps:**

1. Display empty transaction list
2. User enters "Coffee at Cafe" in title field
3. User enters "5.50" in amount field
4. Transaction is added to the list
5. Transaction appears with correct title and amount

**Expected Result:** ✅ New transaction visible in list with correct data

---

### UAT-2: View Spending by Category in Chart

**User Story:** "As a user, I can view my spending by category in a chart"

**What's Being Tested:**

- Chart widget displays correctly
- Total spending is calculated accurately
- Multiple transactions are summed correctly
- Chart renders without errors

**Business Value:**

- Provides visual summary of expenses
- Helps users understand spending patterns
- Validates calculation accuracy

**Test Setup:**

- 4 transactions across 3 categories:
  - Food: $85 (Groceries) + $42.50 (Restaurant) = $127.50
  - Transport: $35 (Taxi) = $35.00
  - Entertainment: $15 (Movie) = $15.00
- **Total: $177.50**

**Expected Result:** ✅ Chart renders, total calculated as $177.50

---

### UAT-3: Delete Transaction from List

**User Story:** "As a user, I can delete a transaction and have it removed from my list"

**What's Being Tested:**

- Delete function removes correct transaction
- Other transactions remain intact
- List updates after deletion
- Deletion is permanent

**Business Value:**

- Users can correct mistakes
- Maintains accurate expense records
- Validates data mutation

**Test Steps:**

1. Display list with 2 transactions
2. Delete first transaction ("Unwanted Expense")
3. Verify deleted transaction is gone
4. Verify other transaction ("Keep This") remains

**Expected Result:** ✅ Deleted transaction removed, list has 1 remaining item

---

### UAT-4: View Transaction History with Dates and Amounts

**User Story:** "As a user, I can view my transaction history with accurate dates and amounts"

**What's Being Tested:**

- All transaction titles are displayed
- Amounts are formatted correctly
- Dates are preserved accurately
- Historical data is retrievable

**Business Value:**

- Users have complete audit trail
- Financial accuracy is maintained
- Historical analysis is possible

**Test Data:**

- January 5: Coffee $4.50
- January 10: Lunch $15.75
- February 15: Dinner $32.00

**Expected Result:** ✅ All transactions visible with correct dates and amounts

---

### UAT-5: Track Spending in Specific Categories

**User Story:** "As a user, I can track spending in specific categories"

**What's Being Tested:**

- Transactions are grouped by category
- Category totals are calculated correctly
- Multiple categories can coexist
- Category filtering logic works

**Business Value:**

- Users understand where money is spent
- Budget planning by category becomes possible
- Spending patterns are identifiable

**Test Data:**

- Food: $65 (Groceries) + $35.50 (Restaurant) = $100.50
- Transport: $5 (Bus) + $45 (Gas) = $50.00

**Expected Result:** ✅ Category totals calculated: Food $100.50, Transport $50.00

---

### UAT-6: Add Recurring Transaction

**User Story:** "As a user, I can add a recurring transaction for automatic tracking"

**What's Being Tested:**

- Recurring flag can be set
- Interval value is stored
- Form accepts recurring parameters
- Recurring transactions display correctly

**Business Value:**

- Automatic tracking of subscriptions
- Reduces manual data entry
- Improves expense forecasting

**Expected Result:** ✅ Recurring transaction form renders and accepts input

---

### UAT-7: View Total Spending and Statistics

**User Story:** "As a user, I can see total spending and spending statistics"

**What's Being Tested:**

- Total spending is calculated correctly
- Average per transaction is accurate
- Highest transaction is identified
- Lowest transaction is identified
- Statistics display correctly

**Business Value:**

- Users understand overall spending patterns
- Budget planning is supported
- Financial analysis is enabled

**Test Data:**

- Transaction 1: $8.50
- Transaction 2: $12.75
- Transaction 3: $28.50
- **Total: $49.75**
- **Average: $16.58**
- **Highest: $28.50**
- **Lowest: $8.50**

**Expected Result:** ✅ All statistics calculated accurately and displayed

---

### UAT-8: View Expenses Organized by Date

**User Story:** "As a user, I can view my expenses organized by date"

**What's Being Tested:**

- Transactions can be grouped by date
- Date grouping logic works correctly
- Multiple transactions on same date are grouped
- Different dates are separated

**Business Value:**

- Daily expense review is possible
- Spending trends by day are visible
- Date-based filtering becomes possible

**Test Data:**

- January 15: 2 transactions (Morning Coffee, Lunch)
- January 16: 1 transaction (Groceries)

**Expected Result:** ✅ Transactions grouped correctly: 2 on Jan 15, 1 on Jan 16

---

### UAT-9: Manage Budget and See Warnings

**User Story:** "As a user, I can manage my budget and see warnings when approaching limits"

**What's Being Tested:**

- Budget limits can be set per category
- Spending is tracked against budget
- Usage percentage is calculated
- Progress indicators display
- Warnings appear when approaching limits

**Business Value:**

- Users stay within financial limits
- Budget overages are visible
- Financial planning is supported

**Test Data:**

- Food Budget: $200 (Spent: $175 = 87.5%)
- Transport Budget: $100 (Spent: $90 = 90%)
- Entertainment Budget: $150 (Spent: $0 = 0%)

**Expected Result:** ✅ Budget tracking displays correctly, percentages calculated

---

### UAT-10: Search and Filter Transactions by Category

**User Story:** "As a user, I can search and filter my transactions by category"

**What's Being Tested:**

- Filter buttons exist for all categories
- Filtering shows only selected category
- "All" filter shows all transactions
- Result count updates
- Transaction list updates dynamically

**Business Value:**

- Quick access to specific expense types
- Financial analysis by category
- Reduces information overload

**Test Data:**

- 4 total transactions across categories
- Food: 2 transactions
- Transport: 1 transaction
- Entertainment: 1 transaction

**Expected Result:** ✅ Filters work, result count updates, correct transactions shown

---

## Test Statistics

| Aspect                 | Value                         |
| ---------------------- | ----------------------------- |
| Total Test Files       | 1                             |
| Total Acceptance Tests | 10                            |
| Test Categories        | User Workflows & Requirements |
| Avg Test Duration      | ~0.8-1.0 seconds per test     |
| Total Execution Time   | ~8-10 seconds                 |
| Focus Area             | Business Requirements         |
| Dependencies           | None (no Firebase, etc.)      |

---

## Test Design Principles

### 1. User-Centric Language

Tests use "As a user..." format to clearly state the business value:

```dart
testWidgets(
    'UAT-1: As a user, I can add a new transaction and see it in my list',
    (WidgetTester tester) async {
      // Test implementation
    });
```

### 2. Given-When-Then Structure

Each test follows a clear workflow:

- **Given:** Setup (initial state)
- **When:** Action (user interaction)
- **Then:** Assertion (expected outcome)

```dart
// Given: Empty transaction list
expect(find.text('No transactions yet'), findsOneWidget);

// When: User enters transaction data
await tester.enterText(find.byType(TextField).first, 'Coffee at Cafe');

// Then: Transaction appears in list
expect(transactions.isNotEmpty, isTrue);
```

### 3. Business Value Focus

Each test answers: "Why does this matter to the user?"

- ✅ Validates core workflows
- ✅ Ensures business rules are followed
- ✅ Confirms user requirements are met
- ✅ Tests calculations are accurate

### 4. No Implementation Details

Tests focus on **what** users accomplish, not **how** widgets are implemented:

```dart
// ✅ GOOD: Focus on business outcome
expect(transactions.first.title, equals('Coffee at Cafe'));

// ❌ AVOID: Testing implementation details
expect(find.byType(DropdownButtonFormField), findsOneWidget);
```

---

## Test Data & Fixtures

### Creating Test Transactions

```dart
final transaction = Transaction(
  id: '1',
  title: 'Coffee at Cafe',
  amount: 5.50,
  date: DateTime(2024, 1, 15),
  categoryId: 'food',
  recurring: false,
  interval: '',
);
```

### Creating Test Categories

```dart
import '../fixtures/category_test_data.dart';

final categories = [
  CategoryTestData.createTestCategory(
    title: 'Food',
    id: 'food',
  ),
  CategoryTestData.createTestCategory(
    title: 'Transport',
    id: 'transport',
  ),
];
```

### Calculating Statistics

```dart
// Total spending
final total = transactions
    .fold<double>(0, (sum, tx) => sum + tx.amount);

// Average per transaction
final average = total / transactions.length;

// Highest and lowest
final highest = transactions
    .map((tx) => tx.amount)
    .reduce((a, b) => a > b ? a : b);

final lowest = transactions
    .map((tx) => tx.amount)
    .reduce((a, b) => a < b ? a : b);
```

---

## Running Tests

### Run All Tests

```bash
flutter test test/acceptance/
```

### Run with Verbose Output

```bash
flutter test test/acceptance/ -v
```

### Run Specific Test

```bash
flutter test test/acceptance/user_acceptance_test.dart \
  -n "UAT-1"
```

### Run with Reporter

```bash
flutter test test/acceptance/ --reporter=json > results.json
```

### Watch Mode (Development)

```bash
flutter test test/acceptance/ --watch
```

---

## Comparison with Other Test Types

| Aspect              | Acceptance | Integration | Unit  | E2E  |
| ------------------- | ---------- | ----------- | ----- | ---- |
| **Focus**           | User Goals | Workflows   | Logic | UI   |
| **Tests Per File**  | 5-20       | 20-50       | 100+  | 5-8  |
| **Duration**        | Medium     | Medium      | Fast  | Slow |
| **Scope**           | Business   | Features    | Code  | Full |
| **UI Testing**      | Yes        | Yes         | No    | Yes  |
| **Data Testing**    | Yes        | Yes         | Yes   | No   |
| **Firebase Needed** | No         | No          | No    | No   |

---

## Best Practices

### 1. Keep Tests Independent

Each test should work alone:

```dart
// ✅ GOOD: Test is self-contained
testWidgets('UAT-1: Add transaction', (WidgetTester tester) async {
  final transactions = <Transaction>[];
  // Complete test setup and execution
});

// ❌ AVOID: Depending on previous test results
testWidgets('UAT-2: Delete transaction', (WidgetTester tester) async {
  // Assumes UAT-1 was run first
});
```

### 2. Use Clear Assertions

State what you're testing:

```dart
// ✅ GOOD: Clear reason
expect(transactions.isNotEmpty, isTrue,
    reason: 'Transaction should be added to the list');

// ❌ AVOID: Unclear assertions
expect(transactions.length > 0, true);
```

### 3. Test Business Rules, Not Implementation

```dart
// ✅ GOOD: Tests business requirement
final foodSpending = transactions
    .where((tx) => tx.categoryId == 'food')
    .fold<double>(0, (sum, tx) => sum + tx.amount);
expect(foodSpending, equals(100.50));

// ❌ AVOID: Tests implementation detail
expect(find.byType(ListView), findsOneWidget);
```

### 4. Use Meaningful Test Names

```dart
// ✅ GOOD: Describes user goal
'UAT-1: As a user, I can add a new transaction and see it in my list'

// ❌ AVOID: Unclear naming
'test_add_transaction'
```

---

## Troubleshooting

### Issue: "No widgets with X found"

**Cause:** Widget setup is incomplete or doesn't exist
**Solution:** Verify widget hierarchy and ensure all necessary widgets are pumped

```dart
await tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: YourWidget(),
    ),
  ),
);
```

### Issue: Text not found in multiple locations

**Cause:** Test uses `findsOneWidget` but widget appears multiple times
**Solution:** Use `findsWidgets` or be more specific with finder

```dart
// ✅ If multiple widgets with same text expected
expect(find.text('\$5.50'), findsWidgets);

// ❌ Don't use if multiple exist
expect(find.text('\$5.50'), findsOneWidget);
```

### Issue: Data not updating after action

**Cause:** Widget tree not rebuilt
**Solution:** Use `pumpAndSettle()` to rebuild UI

```dart
await tester.enterText(find.byType(TextField), 'text');
await tester.pumpAndSettle(); // Wait for rebuild
expect(find.text('text'), findsOneWidget);
```

### Issue: Assertion fails on calculated values

**Cause:** Floating point precision issues
**Solution:** Use `closeTo()` for double comparisons

```dart
// ✅ GOOD: Accounts for floating point precision
expect(average, closeTo(16.583, 0.01));

// ❌ AVOID: Exact comparison on doubles
expect(average, equals(16.583333...));
```

---

## Adding New Acceptance Tests

### 1. Identify User Goal

```
"As a user, I want to [action] so that [benefit]"
```

### 2. Create Test File

Add to `test/acceptance/user_acceptance_test.dart`

### 3. Define Test Structure

```dart
testWidgets(
    'UAT-#: As a user, I can [user goal]',
    (WidgetTester tester) async {
  // GIVEN: Setup initial state

  // WHEN: User performs action

  // THEN: Verify outcome
});
```

### 4. Follow Naming Convention

- **File:** Ends with `_test.dart`
- **Group:** `'User Acceptance Tests - [Feature Area]'`
- **Test:** `'UAT-#: As a user, I can...'`

### 5. Focus on Business Value

- Does this test validate a real user goal?
- Would a product manager care about this test?
- Does it ensure business requirements are met?

---

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Acceptance Tests
on: [push, pull_request]

jobs:
  acceptance-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v1
      - run: cd root && flutter test test/acceptance/
      - uses: codecov/codecov-action@v2
        with:
          files: ./coverage/lcov.info
```

---

## Test Coverage

### User Workflows Covered

✅ **Transaction Management**

- Add transactions
- Delete transactions
- View transaction history
- Track by category

✅ **Financial Analysis**

- View spending summary
- Calculate statistics (average, high, low)
- Track by date

✅ **Budget Management**

- Set budget limits
- Track spending vs. budget
- View warning indicators

✅ **Advanced Features**

- Add recurring transactions
- Search and filter
- Organize by category

### Not Covered (See E2E Tests)

❌ Navigation between screens
❌ Form validation
❌ UI/UX details
❌ Widget-specific features
❌ Error handling

---

## File Structure

```
root/test/acceptance/
├── README.md (this file)
└── user_acceptance_test.dart (10 UAT scenarios)
```

---

## Related Test Files

- **Integration Tests:** `test/integration/README.md` (49 tests)
- **E2E Tests:** `test/e2e/README.md` (8 tests)
- **Unit Tests:** Individual test files for specific classes
- **Test Fixtures:** `test/fixtures/category_test_data.dart`

---

## Acceptance Criteria Met

✅ **All 10 Core User Workflows Tested**

1. Add and view transactions
2. View spending by category
3. Delete transactions
4. View transaction history
5. Track category spending
6. Add recurring transactions
7. View spending statistics
8. View expenses by date
9. Manage budgets
10. Search and filter transactions

✅ **No External Dependencies**

- No Firebase required
- No backend services needed
- Runs locally instantly

✅ **Clear Traceability**

- Each test maps to user story
- Business value documented
- Expected results specified

✅ **Easy to Maintain**

- Consistent test patterns
- Clear naming conventions
- Well-organized structure

---

## Support & Contact

For questions about acceptance tests:

1. Review test names - they describe user goals
2. Check test data - understand what's being tested
3. Review assertions - see what's being verified
4. Check related tests for patterns

---

**Last Updated:** November 29, 2025
**Test Suite Version:** 1.0
**Total Acceptance Tests:** 10
**Pass Rate:** ✅ All scenarios validated
**Execution Time:** ~8-10 seconds
