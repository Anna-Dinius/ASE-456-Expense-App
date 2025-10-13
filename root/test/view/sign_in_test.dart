// SignInScreen Widget Tests
// Tests the sign-in form validation, UI elements, and user interactions

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/view/sign_in.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUp(() {
    TestHelpers.setupMockAuth();
  });

  Widget createWidget() {
    return TestHelpers.createTestApp(SignInScreen());
  }

  group('SignInScreen', () {
      group('UI Elements', () {
        testWidgets('shows all required form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
      });

      group('Form Validation', () {
        testWidgets('shows error for empty email', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

        testWidgets('shows error for empty password', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      await tester.enterText(find.byKey(Key('email-field')), TestHelpers.validEmail);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Password is required'), findsOneWidget);
    });

        testWidgets('shows error for invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      await tester.enterText(find.byKey(Key('email-field')), TestHelpers.invalidEmail);
      await tester.enterText(find.byKey(Key('password-field')), TestHelpers.validPassword);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });
      });

      group('Form Submission', () {
        testWidgets('submits valid form without validation errors', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      await tester.enterText(find.byKey(Key('email-field')), TestHelpers.validEmail);
      await tester.enterText(find.byKey(Key('password-field')), TestHelpers.validPassword);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Should not show validation errors
      expect(find.text('Enter a valid email'), findsNothing);
      expect(find.text('Password is required'), findsNothing);
    });

        testWidgets('handles form submission without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      await tester.enterText(find.byKey(Key('email-field')), TestHelpers.validEmail);
      await tester.enterText(find.byKey(Key('password-field')), TestHelpers.validPassword);
      
      // Just verify the button tap doesn't crash
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Test passed if no exception thrown
      expect(find.byType(Form), findsOneWidget);
    });

        testWidgets('accepts valid input without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      await tester.enterText(find.byKey(Key('email-field')), TestHelpers.validEmail);
      await tester.enterText(find.byKey(Key('password-field')), TestHelpers.validPassword);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Should complete without throwing an exception
      // The screen may have popped due to successful sign in, so just verify no errors
      expect(tester.takeException(), isNull);
    });
      });
  });
}