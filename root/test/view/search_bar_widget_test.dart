import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/model/category.dart';
import 'package:p5_expense/model/transaction.dart';
import 'package:p5_expense/view/search_bar_widget.dart';

void main() {
  // ---------- SETUP TEST DATA ----------
  final testCategories = [
    Category(id: 'food', title: 'Food', color: Colors.red, icon: Icons.fastfood),
    Category(id: 'travel', title: 'Travel', color: Colors.blue, icon: Icons.flight),
  ];

  final testTransactions = [
    Transaction(
      id: 't1',
      title: 'Burger',
      amount: 10.0,
      date: DateTime(2024, 6, 1),
      categoryId: 'food',
      recurring: false,
      interval: '',
    ),
    Transaction(
      id: 't2',
      title: 'Bus Ticket',
      amount: 5.0,
      date: DateTime(2024, 6, 2),
      categoryId: 'travel',
      recurring: false,
      interval: '',
    ),
    Transaction(
      id: 't3',
      title: 'Pizza',
      amount: 15.0,
      date: DateTime(2024, 6, 3),
      categoryId: 'food',
      recurring: false,
      interval: '',
    ),
  ];

  // A mock delete function
  void mockDelete(String id) {}

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: SearchBarWidget(
          transactions: testTransactions,
          deleteTx: mockDelete,
          categories: testCategories,
        ),
      ),
    );
  }

  // ---------- TESTS ----------

  testWidgets('renders search bar and dropdowns', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Check search field
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);

    // Check dropdowns
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Ascend'), findsOneWidget);

    // Find all ChoiceChips
    final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));

    // Extract the chip labels (Text widgets)
    final chipLabels = chips
        .map((chip) => (chip.label as Text).data)
        .toList();

    // Verify expected category titles appear exactly once each
    expect(chipLabels, containsAll(['Food', 'Travel']));
    expect(chipLabels.where((label) => label == 'Food').length, 1);
    expect(chipLabels.where((label) => label == 'Travel').length, 1);
  });


  testWidgets('filters transactions by search query', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Initially, all transactions are shown
    expect(find.byType(ListTile), findsNWidgets(3));

    // Type "Pizza" into search field (triggers real-time filtering)
    await tester.enterText(find.byType(TextField), 'Pizza');
    await tester.pumpAndSettle();

    // Check the search bar itself has the text
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller!.text, equals('Pizza'));

    // Filtered list should now contain only one transaction tile
    final listTiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect(listTiles.length, 1);

    // Verify the visible transaction title matches "Pizza"
    final titleText = (listTiles.first.title as Text).data;
    expect(titleText, equals('Pizza'));
});

  testWidgets('filters transactions by category chip', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
      // Find all ChoiceChips
    final chips = find.byType(ChoiceChip);

    // Use `widgetList` to locate the one with label "Travel"
    final travelChip = tester.widgetList<ChoiceChip>(chips).firstWhere(
      (chip) => (chip.label as Text).data == 'Travel',
    );

    // Get the finder for this specific ChoiceChip
    final travelFinder = find.byWidget(travelChip);

    // Tap the "Travel" chip
    await tester.tap(travelFinder);
    await tester.pumpAndSettle();

    // Only "Bus Ticket" should remain
    expect(find.text('Bus Ticket'), findsOneWidget);
    expect(find.text('Burger'), findsNothing);
    expect(find.text('Pizza'), findsNothing);
  });

  testWidgets('sorts transactions by amount descending', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Find all DropdownButtons in the widget tree
    final dropdowns = find.byType(DropdownButton<String>);

    // The widget defines:
    //   - first DropdownButton: Sort By ('Date' / 'Amount')
    //   - second DropdownButton: Order ('Ascend' / 'Descend')

    // Select the first dropdown (Sort By)
    final sortByDropdown = dropdowns.at(0);
    await tester.tap(sortByDropdown);
    await tester.pumpAndSettle();

    // Select the "Amount" item from the opened menu
    await tester.tap(find.text('Amount').last);
    await tester.pumpAndSettle();

    // Now select the second dropdown (Order)
    final orderDropdown = dropdowns.at(1);
    await tester.tap(orderDropdown);
    await tester.pumpAndSettle();

    // Select the "Descend" item from the opened menu
    await tester.tap(find.text('Descend').last);
    await tester.pumpAndSettle();

    // Verify sorting order: "Pizza" (15.0) should appear before "Burger" (10.0)
    final listTiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect((listTiles.first.title as Text).data, equals('Pizza'));
  });


  testWidgets('updates transactions when parent widget changes', (WidgetTester tester) async {
    // Initial load
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Burger'), findsOneWidget);

    // Rebuild with new transaction list
    final newTransactions = [
      Transaction(
        id: 't4',
        title: 'New Expense',
        amount: 50,
        date: DateTime.now(),
        categoryId: 'food',
        recurring: false,
        interval: '',
      ),
    ];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SearchBarWidget(
          transactions: newTransactions,
          deleteTx: mockDelete,
          categories: testCategories,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('New Expense'), findsOneWidget);
    expect(find.text('Burger'), findsNothing);
  });
  testWidgets('filters by category then sorts by amount descending', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // --------- SELECT CATEGORY "Food" ----------
    final chips = find.byType(ChoiceChip);

    final foodChip = tester.widgetList<ChoiceChip>(chips).firstWhere(
      (chip) => (chip.label as Text).data == 'Food',
    );

    final foodFinder = find.byWidget(foodChip);

    await tester.tap(foodFinder);
    await tester.pumpAndSettle();

    // Only Burger (10) and Pizza (15) remain
    expect(find.text('Bus Ticket'), findsNothing);

    // --------- SORT BY "Amount" ----------
    final dropdowns = find.byType(DropdownButton<String>);

    // Dropdown 0 = Sort By
    await tester.tap(dropdowns.at(0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Amount').last);
    await tester.pumpAndSettle();

    // --------- SORT ORDER = Descend ----------
    await tester.tap(dropdowns.at(1));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Descend').last);
    await tester.pumpAndSettle();

    // Order inside Food should now be Pizza (15) before Burger (10)
    final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    final firstTitle = (tiles.first.title as Text).data;

    expect(firstTitle, equals('Pizza'));
  });
}