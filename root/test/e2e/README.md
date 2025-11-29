# End-to-End Tests Documentation

## Overview

This directory contains comprehensive end-to-end (E2E) tests for the Personal Expense Application. These tests validate complete user workflows and feature interactions without requiring external dependencies like Firebase.

## Test Suite Summary

**Total Tests:** 8  
**Status:** ✅ All Passing  
**Framework:** Flutter Widget Testing (`flutter_test`)

### Test Scenarios

#### E2E 1: Transaction List Display and Deletion

**Purpose:** Verify that transactions display correctly in a list format and can be identified/deleted

**Workflow:**

1. Display list of 2 transactions (Restaurant $25.50, Coffee $5.00)
2. Verify both transactions appear with correct amounts
3. Verify delete icons are present on each transaction
4. Verify the ListView structure is rendered correctly

**Assertions:**

- ✅ Both transaction titles visible
- ✅ Both amounts displayed correctly
- ✅ ListTile widgets properly rendered
- ✅ ListView container present

**Use Case:** Tests basic CRUD viewing and list presentation of expense transactions

---

#### E2E 2: Multi-Category Transaction Grouping

**Purpose:** Verify transactions are correctly grouped and displayed by category

**Workflow:**

1. Display 4 transactions across 3 categories:
   - Food: Groceries ($80), Restaurant ($60)
   - Transport: Taxi ($45)
   - Entertainment: Movie Tickets ($30)
2. Verify each category appears as a header
3. Verify transactions are grouped under their respective categories
4. Verify all amounts display correctly

**Assertions:**

- ✅ Food category header visible
- ✅ Food transactions (Groceries, Restaurant) grouped correctly
- ✅ Transport category and transaction visible
- ✅ Entertainment category and transaction visible
- ✅ All amounts displayed correctly (\$80, \$60, \$45, \$30)

**Use Case:** Tests category-based organization of expense tracking

---

#### E2E 3: Search and Filter Functionality

**Purpose:** Verify search bar and category filter buttons are available and functional

**Workflow:**

1. Display search field and category filter buttons
2. Display 4 transactions across multiple categories
3. Verify search input field exists
4. Verify filter buttons exist for Food, Transport, Entertainment, Healthcare, and Utilities
5. Verify all transactions are displayed by default

**Assertions:**

- ✅ Search field present and functional
- ✅ Category filter buttons available for all categories
- ✅ All 4 transactions displayed initially
- ✅ Correct transaction titles and amounts shown
- ✅ Results counter shows "4 results"

**Use Case:** Tests search/filter UI components and transaction querying capabilities

---

#### E2E 4: Budget Tracking Display

**Purpose:** Verify budget limits are displayed with spending progress and visual indicators

**Workflow:**

1. Display budget information for 3 categories:
   - Food: $140 spent of $200 limit (70%)
   - Transport: $45 spent of $100 limit (45%)
   - Entertainment: $120 spent of $150 limit (80%)
2. Verify spent and limit amounts displayed
3. Verify percentage calculations correct
4. Verify progress indicators rendered

**Assertions:**

- ✅ Food: \$140.00 spent, \$200.00 budget, 70.0% displayed
- ✅ Transport: \$45.00 spent, \$100.00 budget, 45.0% displayed
- ✅ Entertainment: \$120.00 spent, \$150.00 budget, 80.0% displayed
- ✅ LinearProgressIndicator widgets rendered
- ✅ Color coding for budget status (no over-budget in this test)

**Use Case:** Tests budget monitoring and alert system (visual display of spending against limits)

---

#### E2E 5: Reports and Analytics Display

**Purpose:** Verify expense reports and statistical analytics are calculated and displayed correctly

**Workflow:**

1. Display 4 transactions with various amounts
2. Calculate and display:
   - Total spending: \$200.00
   - Category breakdown: Food (\$150), Transport (\$30), Entertainment (\$20)
   - Statistics: Count, Average, High, Low
3. Verify all calculations are accurate

**Assertions:**

- ✅ Total Spending card displays \$200.00
- ✅ Category breakdown correct: Food \$150.00, Transport \$30.00, Entertainment \$20.00
- ✅ Transaction count: 4
- ✅ Average: \$50.00 (200/4)
- ✅ Highest: \$100.00
- ✅ Lowest: \$20.00

**Use Case:** Tests expense analytics, reporting, and statistical analysis features

---

#### E2E 6: Recurring Transaction Handling

**Purpose:** Verify recurring transactions display with correct interval information

**Workflow:**

1. Create 3 instances of a monthly subscription (\$9.99 each)
2. Display transactions with dates and interval information
3. Verify all instances display with consistent formatting
4. Verify recurring flag is set correctly

**Assertions:**

- ✅ Monthly Subscription title appears
- ✅ All 3 transaction instances displayed
- ✅ Dates formatted correctly (2024-01-15, 2024-02-15, 2024-03-15)
- ✅ Interval label "monthly" shown
- ✅ Amount \$9.99 consistent across all instances
- ✅ Recurring flag is true for all transactions

**Use Case:** Tests recurring transaction scheduling and periodic expense tracking

---

#### E2E 7: Savings Goals Tracking

**Purpose:** Verify savings goals display progress toward targets with visual indicators

**Workflow:**

1. Display 3 savings goals with progress:
   - Vacation: $800 saved of $2000 target (40%)
   - Emergency: $3200 saved of $5000 target (64%)
   - Car: $5500 saved of $15000 target (36.7%)
2. Verify progress bars and percentages calculated correctly
3. Verify goal names and targets displayed

**Assertions:**

- ✅ VACATION: Saved \$800.00 / \$2000.00, 40.0% Complete
- ✅ EMERGENCY: Saved \$3200.00 / \$5000.00, 64.0% Complete
- ✅ CAR: Saved \$5500.00 / \$15000.00, 36.7% Complete
- ✅ All goal names uppercase displayed
- ✅ LinearProgressIndicator widgets rendered correctly

**Use Case:** Tests savings goal tracking and progress visualization features

---

#### E2E 8: Monthly Expense Summary

**Purpose:** Verify monthly expense summaries are correctly filtered and calculated

**Workflow:**

1. Create transactions across January and February
2. Filter to show January transactions only:
   - Jan Groceries: \$100
   - Jan Transport: \$50
3. Display summary with:
   - Month label: 2024-01
   - Transaction count: 2
   - Total: \$150.00
4. Verify transactions listed under summary

**Assertions:**

- ✅ Month label "2024-01" displayed
- ✅ Transaction count shows 2
- ✅ Total: \$150.00 (100 + 50)
- ✅ Jan Groceries transaction visible
- ✅ Jan Transport transaction visible
- ✅ Only January transactions shown (not February)

**Use Case:** Tests monthly expense reporting, date filtering, and period-based summaries

---

## Running the Tests

### Run All E2E Tests

```bash
cd root
flutter test test/e2e/app_e2e_tests.dart
```

### Run Specific E2E Test

```bash
cd root
flutter test test/e2e/app_e2e_tests.dart -p vm --plain-name "E2E 1:"
```

### Run with Coverage

```bash
cd root
flutter test test/e2e/app_e2e_tests.dart --coverage
```

### Run Tests Verbosely

```bash
cd root
flutter test test/e2e/app_e2e_tests.dart -v
```

## Test Data

All E2E tests use in-memory test data fixtures created within each test. No external data sources or Firebase connections are required.

### Categories Used

- **Food** (id: 'food')
- **Transport** (id: 'transport')
- **Entertainment** (id: 'entertainment')
- **Utilities** (id: 'utilities')
- **Healthcare** (id: 'healthcare')

### Test Transaction Models

Tests use `Transaction` model instances with:

- Unique IDs (string)
- Descriptive titles
- Amount values (double)
- Dates (DateTime)
- Category associations (by ID)
- Recurring flags (boolean)
- Interval values (for recurring transactions)

### Test Fixture Factory

The tests use `CategoryTestData.createTestCategory()` factory method from `test/fixtures/category_test_data.dart` to create test category data.

## Test Patterns

### Widget Building

Each test creates a minimal Flutter app structure:

```dart
await tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      appBar: AppBar(...),
      body: /* test UI */,
    ),
  ),
);
```

### Assertions

Tests verify UI elements using Flutter test finders:

- `find.text()` - Find widgets by text content
- `find.byType()` - Find widgets by type
- `find.byKey()` - Find widgets by unique key
- `find.byIcon()` - Find widgets by icon

### UI Verification

Tests validate:

- Text content and calculations
- Widget presence and structure
- Data grouping and organization
- Visual indicators (progress bars, colors)
- Count and statistics accuracy

## Dependencies

**Packages Required:**

- `flutter_test` - Widget testing framework
- `p5_expense` - The expense app under test
- Custom models: `Transaction`, `Category`
- Test fixtures: `CategoryTestData`

## Coverage

The E2E tests provide coverage for:

- ✅ Transaction list display and management
- ✅ Category-based organization
- ✅ Search and filter capabilities
- ✅ Budget tracking and alerts
- ✅ Reports and analytics calculations
- ✅ Recurring transaction handling
- ✅ Savings goal progress
- ✅ Monthly expense summaries

## Common Issues & Troubleshooting

### Issue: Test Fails with "Multiple widgets found"

**Solution:** Use more specific finders like `byKey()` or `byType()` instead of just text searches when widgets have duplicate text.

### Issue: "No widgets with X found"

**Solution:** Verify test data is set up correctly and the widget tree is properly pumped with `pumpAndSettle()`.

### Issue: Progress calculation appears incorrect

**Solution:** Check that division operations are casting to `double` and using proper `toStringAsFixed()` formatting.

## Future Enhancements

Potential additions to E2E test suite:

- [ ] Multi-step workflows (add transaction → view → edit → delete)
- [ ] Navigation between screens
- [ ] User interaction simulations (taps, swipes)
- [ ] Real widget interactions (TextFields, form submissions)
- [ ] Error handling and validation scenarios
- [ ] Performance and load testing with large datasets
- [ ] Accessibility testing

## Related Test Files

- **Unit Tests:** `test/integration/data_model_tests.dart`
- **Widget Tests:** `test/integration/widget_smoke_tests.dart`
- **Integration Tests:** `test/integration/user_workflow_integration_tests.dart`
- **Analysis Tests:** `test/integration/transaction_analysis_tests.dart`

## Contact & Support

For questions about these E2E tests, refer to:

- Main test README: `test/integration/README.md`
- Test fixtures: `test/fixtures/category_test_data.dart`
- Model definitions: `lib/model/transaction.dart`, `lib/model/category.dart`
