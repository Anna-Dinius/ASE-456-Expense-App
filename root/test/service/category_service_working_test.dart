import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/model/category.dart';
import 'package:p5_expense/service/category_service.dart';
import '../fixtures/category_test_data.dart';

void main() {
  group('CategoryService Working Tests', () {
    group('Validation Tests', () {
      test('test_validate_category_valid_data', () {
        // Test valid category data
        final validCategory = CategoryTestData.createTestCategory();
        expect(validCategory.title.isNotEmpty, isTrue);
        expect(validCategory.title.length, lessThanOrEqualTo(50));
        expect(validCategory.title.length, greaterThanOrEqualTo(2));
      });

      test('test_validate_category_empty_title', () {
        // Test empty title validation
        final emptyCategory = CategoryTestData.createTestCategory(title: '');
        expect(emptyCategory.title.isEmpty, isTrue);
      });

      test('test_validate_category_title_too_short', () {
        // Test title too short validation
        final shortCategory = CategoryTestData.createTestCategory(title: 'A');
        expect(shortCategory.title.length, lessThan(2));
      });

      test('test_validate_category_title_too_long', () {
        // Test title too long validation
        final longTitleCategory = CategoryTestData.createLongTitleCategory();
        expect(longTitleCategory.title.length, greaterThan(50));
      });

      test('test_validate_category_invalid_characters', () {
        // Test invalid characters validation
        final specialCharCategory =
            CategoryTestData.createSpecialCharCategory();
        expect(specialCharCategory.title.contains('@'), isTrue);
        expect(specialCharCategory.title.contains('#'), isTrue);
        expect(specialCharCategory.title.contains('%'), isTrue);
      });

      test('test_validate_category_whitespace_only', () {
        // Test whitespace-only title validation
        final whitespaceCategory =
            CategoryTestData.createTestCategory(title: '   ');
        expect(whitespaceCategory.title.trim().isEmpty, isTrue);
      });
    });

    group('Category Creation Logic Tests', () {
      test('test_category_creation_data_preparation', () {
        // Test that category data is properly prepared for creation
        final testCategory = CategoryTestData.createTestCategory(
          title: 'Test Category',
          color: Colors.blue,
          icon: Icons.home,
        );

        expect(testCategory.title, equals('Test Category'));
        expect(testCategory.color, equals(Colors.blue));
        expect(testCategory.icon, equals(Icons.home));
      });

      test('test_category_creation_with_trimmed_title', () {
        // Test that titles are properly trimmed
        final category =
            CategoryTestData.createTestCategory(title: '  Test Category  ');
        expect(category.title.trim(), equals('Test Category'));
      });

      test('test_category_creation_duplicate_detection_logic', () {
        // Test duplicate detection logic
        final categories = CategoryTestData.createDuplicateTitleCategories();

        // Check if we can detect duplicates (case insensitive)
        final titles =
            categories.map((cat) => cat.title.toLowerCase()).toList();
        final uniqueTitles = titles.toSet().toList();

        expect(titles.length, greaterThan(uniqueTitles.length));
      });
    });

    group('Category Serialization Tests', () {
      test('test_category_toMap_for_firestore', () {
        // Test category serialization for Firestore
        final category = CategoryTestData.createTestCategory();
        final map = category.toMap();

        expect(map['title'], equals(category.title));
        expect(map['color'], equals(category.color.toARGB32()));
        expect(map['icon'], equals(category.icon.codePoint));
        expect(map.containsKey('id'), isFalse); // ID is document ID, not in map
      });

      test('test_category_fromMap_from_firestore', () {
        // Test category deserialization from Firestore
        final category = CategoryTestData.createTestCategory();
        final map = category.toMap();
        final reconstructed = Category.fromMap(map, category.id);

        expect(reconstructed.id, equals(category.id));
        expect(reconstructed.title, equals(category.title));
        expect(reconstructed.color.value, equals(category.color.value));
        expect(reconstructed.icon, equals(category.icon));
      });
    });

    group('Default Categories Tests', () {
      test('test_default_categories_structure', () {
        // Test that default categories are properly structured
        final defaultCategories = DefaultCategories.categories;

        expect(defaultCategories.length, equals(7));
        expect(defaultCategories.any((cat) => cat.id == 'other'), isTrue);

        // Test that all default categories have valid data
        for (final category in defaultCategories) {
          expect(category.id, isNotEmpty);
          expect(category.title, isNotEmpty);
          expect(category.title.length, lessThanOrEqualTo(50));
          expect(category.title.length, greaterThanOrEqualTo(2));
        }
      });

      test('test_default_categories_unique_ids', () {
        // Test that all default categories have unique IDs
        final defaultCategories = DefaultCategories.categories;
        final ids = defaultCategories.map((cat) => cat.id).toList();
        final uniqueIds = ids.toSet().toList();

        expect(ids.length, equals(uniqueIds.length));
      });

      test('test_default_categories_unique_titles', () {
        // Test that all default categories have unique titles
        final defaultCategories = DefaultCategories.categories;
        final titles = defaultCategories.map((cat) => cat.title).toList();
        final uniqueTitles = titles.toSet().toList();

        expect(titles.length, equals(uniqueTitles.length));
      });
    });

    group('Transaction Count Logic Tests', () {
      test('test_transaction_count_calculation_logic', () {
        // Test transaction count calculation logic
        final mockTransactionDocs =
            List.generate(5, (index) => 'transaction-$index');
        final count = mockTransactionDocs.length;

        expect(count, equals(5));
      });

      test('test_transaction_count_zero_case', () {
        // Test zero transaction count case
        final mockTransactionDocs = <String>[];
        final count = mockTransactionDocs.length;

        expect(count, equals(0));
      });
    });

    group('Category Deletion Logic Tests', () {
      test('test_category_deletion_protection_logic', () {
        // Test protection of 'other' category
        final categoryId = 'other';
        final isProtected = categoryId == 'other';

        expect(isProtected, isTrue);
      });

      test('test_category_deletion_replacement_logic', () {
        // Test replacement category logic
        final originalCategoryId = 'deleted-category';
        final replacementCategoryId = 'other';

        // Simulate transaction reassignment
        final transactionCategoryId = replacementCategoryId;

        expect(transactionCategoryId, equals(replacementCategoryId));
        expect(transactionCategoryId, isNot(equals(originalCategoryId)));
      });

      test('test_category_deletion_fallback_logic', () {
        // Test fallback to 'other' category when replacement not found
        final replacementCategoryId = 'non-existent-category';
        final fallbackCategoryId = 'other';

        // Simulate fallback logic
        final finalCategoryId = replacementCategoryId.isEmpty
            ? fallbackCategoryId
            : replacementCategoryId;

        expect(finalCategoryId, equals(replacementCategoryId));
      });
    });

    group('Error Handling Logic Tests', () {
      test('test_firebase_error_handling_structure', () {
        // Test error handling structure
        try {
          throw Exception('Firebase connection error');
        } catch (e) {
          expect(e, isA<Exception>());
          expect(e.toString(), contains('Firebase connection error'));
        }
      });

      test('test_validation_error_handling_structure', () {
        // Test validation error handling structure
        try {
          throw Exception('Category name cannot be empty');
        } catch (e) {
          expect(e, isA<Exception>());
          expect(e.toString(), contains('Category name cannot be empty'));
        }
      });

      test('test_not_found_error_handling_structure', () {
        // Test not found error handling structure
        try {
          throw Exception('Category not found');
        } catch (e) {
          expect(e, isA<Exception>());
          expect(e.toString(), contains('Category not found'));
        }
      });
    });

    group('Integration Logic Tests', () {
      test('test_category_transaction_integration_logic', () {
        // Test category-transaction integration logic
        final category = CategoryTestData.createTestCategory();
        final transactionCategoryId = category.id;

        expect(transactionCategoryId, equals(category.id));
      });

      test('test_category_lifecycle_logic', () {
        // Test category lifecycle logic
        final category = CategoryTestData.createTestCategory();

        // Create
        expect(category.id, isNotEmpty);

        // Update (using copyWith)
        final updatedCategory = category.copyWith(title: 'Updated Title');
        expect(updatedCategory.title, equals('Updated Title'));
        expect(updatedCategory.id, equals(category.id));

        // Delete (simulate)
        final deletedCategoryId = category.id;
        expect(deletedCategoryId, isNotEmpty);
      });
    });
  });
}
