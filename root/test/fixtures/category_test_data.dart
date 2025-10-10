import 'package:flutter/material.dart';
import 'package:p5_expense/model/category.dart';

/// Test data fixtures for Category testing
/// Provides consistent test data across all test files
class CategoryTestData {
  // Test user IDs
  static const String testUserId = 'test-user-123';
  static const String testUserId2 = 'test-user-456';

  // Test category IDs
  static const String testCategoryId = 'test-category-123';
  static const String testCategoryId2 = 'test-category-456';

  /// Creates a basic test category
  static Category createTestCategory({
    String id = testCategoryId,
    String title = 'Test Category',
    Color color = Colors.blue,
    IconData icon = Icons.home,
  }) {
    return Category(
      id: id,
      title: title,
      color: color,
      icon: icon,
    );
  }

  /// Creates a food category for testing
  static Category createFoodCategory() {
    return Category(
      id: 'food',
      title: 'Food',
      color: Colors.orange,
      icon: Icons.restaurant,
    );
  }

  /// Creates a transport category for testing
  static Category createTransportCategory() {
    return Category(
      id: 'transport',
      title: 'Transport',
      color: Colors.blue,
      icon: Icons.directions_car,
    );
  }

  /// Creates an other category for testing
  static Category createOtherCategory() {
    return Category(
      id: 'other',
      title: 'Other',
      color: Colors.grey,
      icon: Icons.category,
    );
  }

  /// Creates a list of test categories
  static List<Category> createTestCategories() {
    return [
      createFoodCategory(),
      createTransportCategory(),
      createOtherCategory(),
      Category(
        id: 'bills',
        title: 'Bills',
        color: Colors.red,
        icon: Icons.receipt,
      ),
      Category(
        id: 'entertainment',
        title: 'Entertainment',
        color: Colors.purple,
        icon: Icons.movie,
      ),
    ];
  }

  /// Creates a test category with invalid data for testing validation
  static Category createInvalidCategory() {
    return Category(
      id: '',
      title: '', // Empty title should fail validation
      color: Colors.red,
      icon: Icons.home,
    );
  }

  /// Creates a test category with very long title for testing validation
  static Category createLongTitleCategory() {
    return Category(
      id: 'long-title',
      title: 'A' * 51, // 51 characters, should exceed limit
      color: Colors.green,
      icon: Icons.home,
    );
  }

  /// Creates a test category with special characters for testing validation
  static Category createSpecialCharCategory() {
    return Category(
      id: 'special-chars',
      title: 'Test@#\$%Category', // Contains invalid characters
      color: Colors.purple,
      icon: Icons.home,
    );
  }

  /// Creates Firestore data map for testing
  static Map<String, dynamic> createFirestoreData({
    String title = 'Test Category',
    Color color = Colors.blue,
    IconData icon = Icons.home,
  }) {
    return {
      'title': title,
      'color': color.toARGB32(),
      'icon': icon.codePoint,
    };
  }

  /// Creates JSON data for testing
  static Map<String, dynamic> createJsonData({
    String id = testCategoryId,
    String title = 'Test Category',
    Color color = Colors.blue,
    IconData icon = Icons.home,
  }) {
    return {
      'id': id,
      'title': title,
      'color': color.toARGB32(),
      'icon': icon.codePoint,
    };
  }

  /// Creates invalid JSON data for testing error handling
  static Map<String, dynamic> createInvalidJsonData() {
    return {
      'id': 'test-id',
      'title': 'Test Category',
      'color': 'invalid-color', // Should be int
      'icon': 'invalid-icon', // Should be int
    };
  }

  /// Creates incomplete JSON data for testing error handling
  static Map<String, dynamic> createIncompleteJsonData() {
    return {
      'id': 'test-id',
      'title': 'Test Category',
      // Missing color and icon
    };
  }

  /// Creates test categories with duplicate titles for testing validation
  static List<Category> createDuplicateTitleCategories() {
    return [
      Category(
        id: 'category1',
        title: 'Food',
        color: Colors.orange,
        icon: Icons.restaurant,
      ),
      Category(
        id: 'category2',
        title: 'food', // Same title, different case
        color: Colors.blue,
        icon: Icons.fastfood,
      ),
    ];
  }

  /// Creates test categories with same title for testing validation
  static List<Category> createSameTitleCategories() {
    return [
      Category(
        id: 'category1',
        title: 'Food',
        color: Colors.orange,
        icon: Icons.restaurant,
      ),
      Category(
        id: 'category2',
        title: 'Food', // Exact same title
        color: Colors.blue,
        icon: Icons.fastfood,
      ),
    ];
  }
}
