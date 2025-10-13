// ProfileCreationScreen Widget Tests  
// Tests the profile creation form validation, UI elements, and user registration flow

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/view/profile_creation.dart';
import 'package:p5_expense/view/sign_in.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUp(() {
    TestHelpers.setupMockAuth();
  });

  Widget createWidget() {
    return TestHelpers.createTestApp(ProfileCreationScreen());
  }

  group('ProfileCreationScreen', () {
    testWidgets('shows all form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Already have an account? Sign in'), findsOneWidget);
    });

    testWidgets('validates empty name', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('validates empty email', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      // Fill in name but leave email empty
      await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), TestHelpers.validName);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('validates invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), TestHelpers.validName);
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), TestHelpers.invalidEmail);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('validates short password', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), TestHelpers.validName);
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), TestHelpers.validEmail);
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), TestHelpers.shortPassword);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Min 6 characters'), findsOneWidget);
    });

    testWidgets('validates password confirmation mismatch', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), TestHelpers.validName);
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), TestHelpers.validEmail);
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), TestHelpers.validPassword);
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'different');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('submits valid form without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), TestHelpers.validName);
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), TestHelpers.validEmail);
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), TestHelpers.validPassword);
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), TestHelpers.validPassword);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Should not show validation errors
      expect(find.text('Name is required'), findsNothing);
      expect(find.text('Enter a valid email'), findsNothing);
      expect(find.text('Min 6 characters'), findsNothing);
      expect(find.text('Passwords do not match'), findsNothing);
    });

    testWidgets('navigates to sign in screen', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      await tester.tap(find.text('Already have an account? Sign in'));
      await tester.pumpAndSettle();

      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('handles form submission', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), TestHelpers.validName);
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), TestHelpers.validEmail);
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), TestHelpers.validPassword);
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), TestHelpers.validPassword);
      
      // Just verify the button tap doesn't crash
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Test passed if no exception thrown
      expect(find.byType(Form), findsOneWidget);
    });
  });
}