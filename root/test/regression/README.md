# Regression Tests

## Overview

Regression tests ensure that existing functionality continues to work correctly and prevents breaking changes. These tests focus on core operations across the entire application, including transaction management, category operations, calculations, and data integrity.

**Test Status:** ✅ All tests passing  
**Total Tests:** 39  
**Execution Time:** ~2-3 seconds  
**Last Updated:** 2024

## Quick Start

Run all regression tests:

```bash
flutter test test/regression/
```

Run with verbose output:

```bash
flutter test test/regression/ -v
```

Run a specific test group:

```bash
flutter test test/regression/regression_test.dart -k "RGN-1"
```

Run with coverage:

```bash
flutter test test/regression/ --coverage
```

## Test Files

### regression_test.dart

**Purpose:** Comprehensive regression test suite covering core application functionality  
**Test Count:** 39 tests across 8 major categories  
**Duration:** ~2-3 seconds

**Test Categories:**

#### RGN-1: Transaction CRUD Operations (4 tests)

Validates that fundamental transaction management operations work as expected:

- Creating transactions with required fields
- Reading transactions from lists
- Updating transaction data
- Deleting transactions

**Business Value:** Ensures the core transaction lifecycle remains functional after code changes.

#### RGN-2: Transaction Calculations (4 tests)

Tests critical calculation and aggregation functions:

- Total spending calculations
- Average amount calculations
- Min/max value operations
- Percentage calculations

**Business Value:** Prevents regression in financial calculations that users depend on for budgeting.

#### RGN-3: Category Operations (5 tests)

Validates category management and related filtering:

- Creating categories with default values
- Finding categories by ID
- Filtering transactions by category
- Grouping transactions by category
- Category spending totals

**Business Value:** Ensures category functionality remains reliable for transaction organization.

#### RGN-4: Date Operations (4 tests)

Tests date handling and time-based filtering:

- Date comparison operations
- Date grouping (normalized without time)
- Date range filtering
- Month extraction

**Business Value:** Maintains accuracy of time-based transaction filtering and reports.

#### RGN-5: Filtering and Search (3 tests)

Validates filtering and search functionality:

- Case-insensitive title search
- Amount range filtering
- Multi-criteria filtering

**Business Value:** Ensures users can find transactions using various criteria.

#### RGN-6: Recurring Transaction Logic (4 tests)

Tests recurring transaction handling:

- Recurring flag preservation
- Non-recurring transaction handling
- Interval value preservation
- Recurring transaction filtering

**Business Value:** Ensures recurring expenses are handled correctly.

#### RGN-7: Edge Cases and Boundary Conditions (6 tests)

Tests application behavior with edge cases:

- Empty list handling
- Single transaction handling
- Large amount values
- Fractional amounts
- Zero amount transactions
- Empty string handling

**Business Value:** Prevents crashes and errors when dealing with edge cases.

#### RGN-8: Data Integrity (4 tests)

Validates data consistency and relationship integrity:

- Transaction ID uniqueness
- Category ID reference validity
- Data immutability in calculations
- List ordering preservation

**Business Value:** Ensures data relationships remain consistent and reliable.

## Key Features

✅ **Complete Core Coverage** - Tests all critical application paths  
✅ **CRUD Operations** - Validates Create, Read, Update, Delete workflows  
✅ **Calculation Validation** - Ensures financial math remains accurate  
✅ **Filtering & Search** - Tests user-facing search and filter features  
✅ **Date Operations** - Validates time-based functionality  
✅ **Recurring Transactions** - Ensures subscription/recurring logic works  
✅ **Edge Case Handling** - Tests boundary conditions and error states  
✅ **Data Integrity** - Validates data consistency and relationships  
✅ **Fast Execution** - Complete suite runs in ~2-3 seconds  
✅ **Clear Naming** - Test names clearly indicate what's being tested

## Test Statistics

| Category         | Count  | Purpose                         |
| ---------------- | ------ | ------------------------------- |
| CRUD Operations  | 4      | Transaction lifecycle           |
| Calculations     | 4      | Financial math & aggregations   |
| Category Ops     | 5      | Category management & filtering |
| Date Operations  | 4      | Time-based functionality        |
| Filtering/Search | 3      | User search capabilities        |
| Recurring Logic  | 4      | Subscription handling           |
| Edge Cases       | 6      | Boundary conditions             |
| Data Integrity   | 4      | Consistency & relationships     |
| **TOTAL**        | **39** | **Complete core functionality** |

## Test Patterns

### Basic CRUD Test Pattern

```dart
test('Create transaction with required fields', () {
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
  expect(transaction.amount, greaterThan(0));
});
```

### Calculation Test Pattern

```dart
test('Total spending calculation remains accurate', () {
  final txList = [
    Transaction(...amount: 10.00...),
    Transaction(...amount: 20.00...),
  ];

  final total = txList.fold<double>(0, (sum, tx) => sum + tx.amount);
  expect(total, equals(30.00));
});
```

### Filtering Test Pattern

```dart
test('Filter transactions by category', () {
  final filtered = txList
      .where((tx) => tx.categoryId == 'food')
      .toList();

  expect(filtered.length, equals(2));
});
```

### Date Operations Test Pattern

```dart
test('Date range filtering works', () {
  final startDate = DateTime(2024, 1, 10);
  final endDate = DateTime(2024, 1, 20);

  final inRange = txList
      .where((tx) => tx.date.isAfter(startDate) &&
                     tx.date.isBefore(endDate))
      .toList();

  expect(inRange.length, greaterThan(0));
});
```

## Running Specific Tests

### Run by Test Group

```bash
# Run only CRUD operation tests
flutter test test/regression/regression_test.dart -k "RGN-1"

# Run only calculation tests
flutter test test/regression/regression_test.dart -k "RGN-2"

# Run only category operation tests
flutter test test/regression/regression_test.dart -k "RGN-3"
```

### Run by Test Name

```bash
# Run a specific test
flutter test test/regression/regression_test.dart -k "Create transaction"

# Run tests matching a pattern
flutter test test/regression/regression_test.dart -k "calculation"
```

### Run with Different Reporters

```bash
# JSON reporter (for CI/CD)
flutter test test/regression/regression_test.dart --json --verbose

# Compact reporter (default)
flutter test test/regression/regression_test.dart

# Expanded reporter (more details)
flutter test test/regression/regression_test.dart --reporter expanded
```

## Troubleshooting

### Tests Not Running

- Ensure you're in the `root` directory of the Flutter project
- Check that `pubspec.yaml` contains `flutter_test` dependency
- Verify the test file is in the `test/` directory

### Import Errors

- Verify all imports match your actual project structure
- Check that `Transaction` and `Category` models exist
- Ensure `category_test_data.dart` is in the `test/fixtures/` directory

### Test Failures

- Run with `-v` (verbose) flag to see detailed output
- Check that transaction data fixtures are initialized correctly
- Verify date calculations account for timezone differences
- Ensure floating-point comparisons use `closeTo()` for precision

### Slow Execution

- Run specific test groups instead of all tests
- Use `-k` flag to run tests matching a pattern
- Check system resources; regression tests are lightweight

## File Structure

```txt
test/
├── regression/
│   ├── regression_test.dart          # Main regression test suite (39 tests)
│   └── README.md                      # This file
├── fixtures/
│   └── category_test_data.dart        # Test data helpers
├── acceptance/
│   ├── user_acceptance_test.dart
│   └── README.md
├── integration/
│   ├── widget_smoke_test.dart
│   └── README.md
├── service/
│   ├── category_service_test.dart
│   ├── budget_service_test.dart
│   └── ...
├── view/
│   ├── sign_in_test.dart
│   └── ...
└── e2e/
    └── app_e2e_test.dart
```

## Best Practices

### When to Add Regression Tests

- After fixing a critical bug (add test to prevent recurrence)
- When modifying core calculation logic
- When changing data filtering or search algorithms
- Before major refactoring of transaction/category logic

### Test Naming Convention

All regression tests use `RGN-X.Y` naming where:

- `X` = Category number (1-8)
- `Y` = Test number within category

Example: `RGN-2.4` = Category 2 (Calculations), Test 4

### Maintenance Guidelines

- Keep tests focused on one aspect of functionality
- Use descriptive test names that explain the scenario
- Update tests when changing business logic
- Run full suite before committing changes
- Add new tests when discovering regressions

## Integration with CI/CD

Regression tests are designed to run in continuous integration pipelines:

```bash
# Command for CI/CD
flutter test test/regression/ --coverage --reporter json --json-output coverage/regression-results.json
```

The test suite:

- Completes in ~2-3 seconds
- Requires no external services or mocks
- Provides clear pass/fail results
- Generates detailed JSON output for reporting

## Related Test Suites

- **Acceptance Tests** (`test/acceptance/`) - User-facing workflow validation
- **Integration Tests** (`test/integration/`) - Widget and service integration
- **Service Tests** (`test/service/`) - Individual service layer testing
- **View Tests** (`test/view/`) - Widget and UI component testing
- **E2E Tests** (`test/e2e/`) - Full application flow testing

## Contact & Support

For questions about regression tests:

- Review test documentation in comments
- Check test output for specific failure messages
- Refer to Flutter testing documentation: [https://flutter.dev/docs/testing](https://flutter.dev/docs/testing)
- Review transaction and category model definitions
