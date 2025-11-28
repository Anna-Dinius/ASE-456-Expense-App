# Integration Tests for Personal Expense App

## Overview

This directory contains **4 categories of tests** with **49 total test cases** for the Personal Expense App:

1. **Widget Smoke Tests** (13 tests) - Individual widget rendering and interaction
2. **Data Model Tests** (11 tests) - Business logic and data operations
3. **Transaction Analysis Tests** (17 tests) - Statistical calculations and analysis
4. **User Workflow Integration Tests** (8 tests) - Complete user workflows and scenarios

**Status**: All 49 tests passing ✅ (~6 seconds total execution time)

---

## Quick Start

### Run All Tests

```bash
cd root
flutter test test/integration/
```

### Run Specific Test File

```bash
flutter test test/integration/widget_smoke_tests.dart
flutter test test/integration/data_model_tests.dart
flutter test test/integration/transaction_analysis_tests.dart
flutter test test/integration/user_workflow_integration_tests.dart
```

### Run with Verbose Output

```bash
flutter test test/integration/ -v
```

### Run with Coverage Report

```bash
flutter test test/integration/ --coverage
```

---

## Test Files

### 1. Widget Smoke Tests (`widget_smoke_tests.dart`)

**Purpose**: Verify core UI widgets render correctly and respond to user interactions.

**13 Tests**:

- NewTransaction widget renders without crashing
- TransactionList widget renders with transactions
- TransactionList widget renders empty state
- Chart widget renders with transactions
- Chart widget renders empty state
- ChartBar widget renders without crashing
- Can add transaction via callback
- Can delete transaction via callback
- Transaction list displays multiple transactions
- Transaction amounts display correctly
- Categories properly handled in transaction list
- Chart calculates totals correctly
- NewTransaction form handles user input

**Key Features**:

- ✅ No Firebase dependency
- ✅ Fast execution (~1 second)
- ✅ Tests widget rendering and callbacks
- ✅ Verifies data display accuracy

---

### 2. Data Model Tests (`data_model_tests.dart`)

**Purpose**: Verify Transaction and Category models work correctly.

**11 Tests**:

- Transaction model creation with all fields
- Category model creation with all fields
- Total calculation from multiple transactions
- Filter transactions by category
- Filter transactions by date range
- Search transactions by title
- Category copyWith creates new instance
- Transaction recurring flag functionality
- Group transactions by category
- Calculate spending by category
- Handle empty transaction lists

**Key Features**:

- ✅ Pure Dart operations (no widgets)
- ✅ Tests CRUD operations
- ✅ Verifies filtering and grouping
- ✅ Tests data transformations

---

### 3. Transaction Analysis Tests (`transaction_analysis_tests.dart`)

**Purpose**: Verify statistical and analytical operations work correctly.

**17 Tests**:

- Calculate total spending across transactions
- Calculate average spending per transaction
- Find highest spending transaction
- Find lowest spending transaction
- Calculate spending by category
- Get transactions for specific date
- Get transactions for date range
- Calculate monthly spending
- Find most frequent category
- Check if transactions exceed threshold
- Sort transactions by amount (descending)
- Sort transactions by date (newest first)
- Calculate percentage of spending by category
- Find transactions matching multiple criteria
- Check for duplicate IDs
- Get distinct categories from transactions
- Calculate running total (cumulative)

**Key Features**:

- ✅ Tests calculations and aggregations
- ✅ Verifies sorting operations
- ✅ Tests complex filtering
- ✅ Validates statistics accuracy

---

### 4. User Workflow Integration Tests (`user_workflow_integration_tests.dart`)

**Purpose**: Test complete user workflows involving multiple widgets and operations.

**8 Integration Tests**:

**Workflow 1**: User adds a food transaction and sees it in the list

- Tests: NewTransaction widget + TransactionList widget
- Verifies: Transaction appears immediately after creation

**Workflow 2**: User adds multiple transactions and views chart summary

- Tests: Multiple transactions + Chart widget
- Verifies: Chart renders and total calculation is correct

**Workflow 3**: User filters transactions by category and views filtered list

- Tests: Category filter + TransactionList widget
- Verifies: Filtering works, correct transactions displayed

**Workflow 4**: User deletes a transaction and list updates immediately

- Tests: Delete operation + list state update
- Verifies: Transaction removed from UI and data

**Workflow 5**: User views spending summary and sees category breakdown

- Tests: Multi-widget view with summary and chart
- Verifies: Category totals calculated correctly

**Workflow 6**: User searches for transaction by title

- Tests: Search functionality + list filtering
- Verifies: Search finds matching transactions

**Workflow 7**: User views transactions for specific date range

- Tests: Date range filtering
- Verifies: Correct transactions within date range

**Workflow 8**: User adds recurring transaction and reviews payments

- Tests: Recurring transaction creation
- Verifies: Transaction flags and intervals set correctly

**Key Features**:

- ✅ Tests multi-widget interactions
- ✅ Verifies complete user journeys
- ✅ Tests state management
- ✅ Validates data flow between components

---

## Test Statistics

| Aspect               | Count      |
| -------------------- | ---------- |
| Total Test Files     | 4          |
| Total Tests          | 49         |
| Widget Tests         | 13         |
| Data Model Tests     | 11         |
| Analysis Tests       | 17         |
| Integration Tests    | 8          |
| Pass Rate            | 100% ✅    |
| Total Execution Time | ~6 seconds |

---

## Test Data & Fixtures

### CategoryTestData Fixture

```dart
// Located in: test/fixtures/category_test_data.dart
final category = CategoryTestData.createTestCategory(
  title: 'Food',
  id: 'food',
);
```

### Sample Test Data

```dart
final transaction = Transaction(
  id: '1',
  title: 'Lunch',
  amount: 12.50,
  date: DateTime.now(),
  categoryId: 'food',
  recurring: false,
  interval: '',
);
```

---

## Test Patterns

### Widget Test Pattern

```dart
testWidgets('test name', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: WidgetUnderTest(...),
      ),
    ),
  );

  expect(find.byType(WidgetUnderTest), findsOneWidget);
});
```

### Data Model Test Pattern

```dart
test('model operation', () {
  final transaction = Transaction(...);
  final result = transaction.performOperation();
  expect(result, expectedValue);
});
```

### Filtering Pattern

```dart
final filtered = transactions
    .where((tx) => tx.categoryId == 'food' && tx.amount > 10)
    .toList();
expect(filtered.length, equals(2));
```

### Aggregation Pattern

```dart
final categorySpending = <String, double>{};
for (var tx in transactions) {
  categorySpending[tx.categoryId] =
    (categorySpending[tx.categoryId] ?? 0) + tx.amount;
}
```

---

## Running Specific Tests

### Run Single Test File

```bash
flutter test test/integration/widget_smoke_tests.dart
```

### Run Specific Test Case

```bash
flutter test test/integration/widget_smoke_tests.dart \
  -n "NewTransaction widget renders"
```

### Run with JSON Report

```bash
flutter test test/integration/ --reporter json > results.json
```

### Run in Watch Mode (during development)

```bash
flutter test test/integration/ --watch
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v1
      - run: cd root && flutter test test/integration/ --coverage
      - uses: codecov/codecov-action@v2
        with:
          files: ./coverage/lcov.info
```

---

## Advantages of Current Test Suite

✅ **No External Dependencies** - Tests don't require Firebase or backend services  
✅ **Fast Execution** - All 49 tests run in ~6 seconds  
✅ **Independent Tests** - Each test can run in any order  
✅ **Clear Names** - Test names describe exactly what's being tested  
✅ **Easy to Debug** - Failures are clear and actionable  
✅ **Maintainable** - Consistent patterns across all tests  
✅ **Comprehensive Coverage** - Widget, logic, and workflow testing  
✅ **No Firebase Setup** - Works in any environment immediately

---

## Limitations & Future Work

### Current Limitations

- ❌ No Firebase/Firestore testing
- ❌ No multi-screen navigation testing
- ❌ No real-time data synchronization
- ❌ No authentication flow testing
- ❌ No network error scenarios

### Planned Integration Tests (When Infrastructure Available)

1. **Full App Integration** - Complete app testing with Firebase
2. **Multi-Screen Workflows** - Navigation between screens
3. **Data Persistence** - Firestore read/write operations
4. **Authentication** - Sign up, login, logout flows
5. **Real-time Updates** - Multi-user synchronization
6. **Error Handling** - Network failures, validation errors

### How to Add Full Integration Tests

```dart
void main() {
  setUpAll(() async {
    // Initialize Firebase for testing
    await Firebase.initializeApp();
  });

  testWidgets('Complete user workflow with persistence',
    (WidgetTester tester) async {
    // Test full app with Firebase
    await tester.pumpWidget(MyApp());

    // Add transaction through UI
    await tester.tap(find.byIcon(Icons.add));
    await tester.enterText(find.byType(TextField), 'Lunch');

    // Verify data persists in Firestore
    final docSnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .doc('docId')
        .get();

    expect(docSnapshot.exists, isTrue);
  });
}
```

---

## Troubleshooting

### Tests Won't Run

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter test test/integration/
```

### Widget Not Found

- Ensure widget is pumped into MaterialApp
- Use `pumpAndSettle()` to wait for animations
- Check widget exists in the file being tested

### Assertion Fails

- Review test output for expected vs. actual values
- Verify test data matches expectations
- Check callbacks are being called

### Timeout Error

- Use `pumpAndSettle()` instead of `pump()`
- Check for infinite loops in widget code
- Increase timeout if needed

---

## Adding New Tests

### 1. Create New Test File

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/model/transaction.dart';
import '../fixtures/category_test_data.dart';

void main() {
  group('New Feature Tests', () {
    // Add tests here
    testWidgets('new test', (WidgetTester tester) async {
      // Test implementation
    });
  });
}
```

### 2. Naming Conventions

- File: `feature_name_tests.dart`
- Group: `'Feature Name Tests'`
- Test: `'User can [action]'` or `'[Widget] [behavior]'`

### 3. Use Test Fixtures

```dart
import '../fixtures/category_test_data.dart';

setUp(() {
  categories = [
    CategoryTestData.createTestCategory(title: 'Food'),
  ];
});
```

### 4. Keep Tests Isolated

- Independent - don't depend on other tests
- Use setUp() for fresh data
- Don't share state between tests
- Clean up in tearDown() if needed

---

## File Structure

```
root/test/integration/
├── README.md (this file)
├── UPDATED_TESTS_SUMMARY.md (test summary with statistics)
├── widget_smoke_tests.dart (13 widget tests)
├── data_model_tests.dart (11 data model tests)
├── transaction_analysis_tests.dart (17 analysis tests)
├── user_workflow_integration_tests.dart (8 integration tests)
└── ../fixtures/
    └── category_test_data.dart (test data factory)
```

---

## Support & Contact

For questions or issues with tests:

1. Check test names - they describe expected behavior
2. Review comments in test code
3. Look at similar passing tests for patterns
4. Check the main app code for implementation details

---

**Last Updated**: November 28, 2025  
**Test Suite Version**: 2.0  
**Total Tests**: 49  
**Pass Rate**: 100% ✅  
**Execution Time**: ~6 seconds
