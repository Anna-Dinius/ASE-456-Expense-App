import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/model/category.dart';

void main() {
  group('Category Model Tests', () {
    late Category testCategory;

    setUp(() {
      testCategory = Category(
        id: 'test-id',
        title: 'Test Category',
        color: Colors.blue,
        icon: Icons.home,
      );
    });

    group('Constructor Tests', () {
      test('test_category_constructor_required_fields', () {
        expect(testCategory.id, equals('test-id'));
        expect(testCategory.title, equals('Test Category'));
        expect(testCategory.color, equals(Colors.blue));
        expect(testCategory.icon, equals(Icons.home));
      });

      test('test_category_constructor_null_handling', () {
        // Test that required fields are properly handled
        expect(
            () => Category(
                  id: '',
                  title: '',
                  color: Colors.red,
                  icon: Icons.home,
                ),
            returnsNormally);
      });

      test('test_category_constructor_default_values', () {
        final category = Category(
          id: 'food',
          title: 'Food',
          color: Colors.orange,
          icon: Icons.restaurant,
        );

        expect(category.id, equals('food'));
        expect(category.title, equals('Food'));
        expect(category.color, equals(Colors.orange));
        expect(category.icon, equals(Icons.restaurant));
      });
    });

    group('copyWith Method Tests', () {
      test('test_copyWith_no_parameters', () {
        final copiedCategory = testCategory.copyWith();

        expect(copiedCategory.id, equals(testCategory.id));
        expect(copiedCategory.title, equals(testCategory.title));
        expect(copiedCategory.color, equals(testCategory.color));
        expect(copiedCategory.icon, equals(testCategory.icon));
      });

      test('test_copyWith_partial_update', () {
        final copiedCategory = testCategory.copyWith(title: 'New Title');

        expect(copiedCategory.id, equals(testCategory.id));
        expect(copiedCategory.title, equals('New Title'));
        expect(copiedCategory.color, equals(testCategory.color));
        expect(copiedCategory.icon, equals(testCategory.icon));
      });

      test('test_copyWith_all_parameters', () {
        final copiedCategory = testCategory.copyWith(
          id: 'new-id',
          title: 'New Title',
          color: Colors.red,
          icon: Icons.home,
        );

        expect(copiedCategory.id, equals('new-id'));
        expect(copiedCategory.title, equals('New Title'));
        expect(copiedCategory.color, equals(Colors.red));
        expect(copiedCategory.icon, equals(Icons.home));
      });

      test('test_copyWith_null_parameters', () {
        final copiedCategory = testCategory.copyWith(
          id: null,
          title: null,
          color: null,
          icon: null,
        );

        expect(copiedCategory.id, equals(testCategory.id));
        expect(copiedCategory.title, equals(testCategory.title));
        expect(copiedCategory.color, equals(testCategory.color));
        expect(copiedCategory.icon, equals(testCategory.icon));
      });
    });

    group('JSON Serialization Tests', () {
      test('test_toJson_complete_data', () {
        final json = testCategory.toJson();

        expect(json['id'], equals('test-id'));
        expect(json['title'], equals('Test Category'));
        expect(json['color'], equals(Colors.blue.toARGB32()));
        expect(json['icon'], equals(Icons.home.codePoint));
      });

      test('test_fromJson_complete_data', () {
        final json = {
          'id': 'test-id',
          'title': 'Test Category',
          'color': Colors.blue.toARGB32(),
          'icon': Icons.home.codePoint,
        };

        final category = Category.fromJson(json);

        expect(category.id, equals('test-id'));
        expect(category.title, equals('Test Category'));
        expect(category.color.value, equals(Colors.blue.value));
        expect(category.icon, equals(Icons.home));
      });

      test('test_json_roundtrip', () {
        final json = testCategory.toJson();
        final reconstructedCategory = Category.fromJson(json);

        expect(reconstructedCategory.id, equals(testCategory.id));
        expect(reconstructedCategory.title, equals(testCategory.title));
        expect(reconstructedCategory.color.value,
            equals(testCategory.color.value));
        expect(reconstructedCategory.icon, equals(testCategory.icon));
      });

      test('test_fromJson_missing_fields', () {
        final json = {
          'id': 'test-id',
          'title': 'Test Category',
          // Missing color and icon
        };

        expect(() => Category.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('test_fromJson_invalid_data', () {
        final json = {
          'id': 'test-id',
          'title': 'Test Category',
          'color': 'invalid-color', // Should be int
          'icon': 'invalid-icon', // Should be int
        };

        expect(() => Category.fromJson(json), throwsA(isA<TypeError>()));
      });
    });

    group('Firestore Serialization Tests', () {
      test('test_toMap_complete_data', () {
        final map = testCategory.toMap();

        expect(map['title'], equals('Test Category'));
        expect(map['color'], equals(Colors.blue.toARGB32()));
        expect(map['icon'], equals(Icons.home.codePoint));
        // Note: id is not included in toMap() as it's the document ID
      });

      test('test_fromMap_complete_data', () {
        final data = {
          'title': 'Test Category',
          'color': Colors.blue.toARGB32(),
          'icon': Icons.home.codePoint,
        };
        const documentId = 'test-id';

        final category = Category.fromMap(data, documentId);

        expect(category.id, equals(documentId));
        expect(category.title, equals('Test Category'));
        expect(category.color.value, equals(Colors.blue.value));
        expect(category.icon, equals(Icons.home));
      });

      test('test_firestore_roundtrip', () {
        final map = testCategory.toMap();
        final reconstructedCategory = Category.fromMap(map, testCategory.id);

        expect(reconstructedCategory.id, equals(testCategory.id));
        expect(reconstructedCategory.title, equals(testCategory.title));
        expect(reconstructedCategory.color.value,
            equals(testCategory.color.value));
        expect(reconstructedCategory.icon, equals(testCategory.icon));
      });

      test('test_fromMap_documentId_handling', () {
        final data = {
          'title': 'Test Category',
          'color': Colors.blue.toARGB32(),
          'icon': Icons.home.codePoint,
        };
        const documentId = 'firestore-doc-id';

        final category = Category.fromMap(data, documentId);

        expect(category.id, equals(documentId));
      });
    });

    group('Equality and Hash Tests', () {
      test('test_equality_identical_objects', () {
        expect(testCategory == testCategory, isTrue);
      });

      test('test_equality_same_data', () {
        final sameCategory = Category(
          id: 'test-id',
          title: 'Test Category',
          color: Colors.blue,
          icon: Icons.home,
        );

        expect(testCategory == sameCategory, isTrue);
      });

      test('test_equality_different_data', () {
        final differentCategory = Category(
          id: 'different-id',
          title: 'Different Category',
          color: Colors.red,
          icon: Icons.home,
        );

        expect(testCategory == differentCategory, isFalse);
      });

      test('test_hashCode_consistency', () {
        final hashCode1 = testCategory.hashCode;
        final hashCode2 = testCategory.hashCode;

        expect(hashCode1, equals(hashCode2));
      });

      test('test_hashCode_equal_objects', () {
        final sameCategory = Category(
          id: 'test-id',
          title: 'Test Category',
          color: Colors.blue,
          icon: Icons.home,
        );

        expect(testCategory.hashCode, equals(sameCategory.hashCode));
      });
    });

    group('toString Tests', () {
      test('test_toString_format', () {
        final string = testCategory.toString();

        expect(string, contains('test-id'));
        expect(string, contains('Test Category'));
        expect(string, contains('MaterialColor')); // Colors.blue representation
        expect(string, contains('IconData'));
      });

      test('test_toString_readability', () {
        final string = testCategory.toString();

        expect(string, startsWith('Category('));
        expect(string, endsWith(')'));
        expect(string, contains('id:'));
        expect(string, contains('title:'));
        expect(string, contains('color:'));
        expect(string, contains('icon:'));
      });
    });
  });
}
