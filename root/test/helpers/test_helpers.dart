import 'package:flutter/material.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:p5_expense/service/auth_service.dart';

/// Test helper utilities for view tests
class TestHelpers {
  /// Sets up mock Firebase Auth for testing
  static MockFirebaseAuth setupMockAuth() {
    final mockAuth = MockFirebaseAuth();
    AuthService.useAuth(mockAuth);
    return mockAuth;
  }

  /// Creates a MaterialApp widget wrapping the provided child for testing
  static Widget createTestApp(Widget child) {
    return MaterialApp(home: child);
  }

  /// Common constants for test validation
  static const String validEmail = 'test@example.com';
  static const String validPassword = 'password123';
  static const String validName = 'John Doe';
  static const String invalidEmail = 'invalid-email';
  static const String shortPassword = '12345';
}

/// Mock Navigator Observer for testing navigation
class MockNavigatorObserver extends NavigatorObserver {
  final VoidCallback onPop;

  MockNavigatorObserver({required this.onPop});

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPop();
  }
}