// ProfileEditingScreen Widget Tests
// Verifies UI elements and basic validation without real Firebase.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/view/profile_editing.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUp(() {
    // Use mocked auth (no user signed in) to avoid hitting Firestore in _load().
    TestHelpers.setupMockAuth();
  });

  Widget createWidget() {
    return TestHelpers.createTestApp(ProfileEditingScreen());
  }

  group('ProfileEditingScreen', () {
    testWidgets('shows all form fields and buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Three text fields: name, phone (optional), image url (optional)
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.widgetWithText(TextFormField, 'Full Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Phone Number (optional)'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Profile Image URL (optional)'), findsOneWidget);

      // Buttons
      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Delete Account'), findsOneWidget);
    });

    testWidgets('validates empty name on save', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();

      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('allows entering optional fields without error', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number (optional)'),
        '555-123-4567',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Profile Image URL (optional)'),
        'https://example.com/me.png',
      );

      // Tap save to trigger validation; still should show only the name error since name empty.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();

      expect(find.text('Name is required'), findsOneWidget);
    });
  });
}
