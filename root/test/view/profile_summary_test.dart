// ProfileSummaryScreen Widget Tests
// Focus on UI structure and navigation to edit screen without real Firebase.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/view/profile_summary.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUp(() {
    // Use mocked auth with no user -> screen should show Not signed in
    TestHelpers.setupMockAuth();
  });

  Widget createWidget(Widget child) {
    return TestHelpers.createTestApp(child);
  }

  group('ProfileSummaryScreen', () {
    testWidgets('shows not signed in when no user', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(ProfileSummaryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Not signed in'), findsOneWidget);
    });

    // Note: Additional tests that require a signed-in user and Firestore stream
    // would need fake_cloud_firestore and a MockUser. That can be added later
    // if desired, but this basic presence test ensures the widget renders.
  });
}
