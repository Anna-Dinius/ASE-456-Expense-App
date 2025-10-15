import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/model/category.dart';

void main() {
  group('DefaultCategories Tests', () {
    group('Default Categories Structure Tests', () {
      test('test_default_categories_not_empty', () {
        expect(DefaultCategories.categories.isNotEmpty, isTrue);
      });

      test('test_default_categories_count', () {
        expect(DefaultCategories.categories.length, equals(7));
      });

      test('test_default_categories_unique_ids', () {
        final ids = DefaultCategories.categories.map((cat) => cat.id).toList();
        final uniqueIds = ids.toSet().toList();

        expect(ids.length, equals(uniqueIds.length));
      });

      test('test_default_categories_unique_titles', () {
        final titles =
            DefaultCategories.categories.map((cat) => cat.title).toList();
        final uniqueTitles = titles.toSet().toList();

        expect(titles.length, equals(uniqueTitles.length));
      });

      test('test_default_categories_required_categories', () {
        final hasOtherCategory =
            DefaultCategories.categories.any((cat) => cat.id == 'other');

        expect(hasOtherCategory, isTrue);
      });
    });

    group('Default Categories Content Tests', () {
      test('test_food_category_properties', () {
        final foodCategory =
            DefaultCategories.categories.firstWhere((cat) => cat.id == 'food');

        expect(foodCategory.title, equals('Food'));
        expect(foodCategory.color, equals(Colors.orange));
        expect(foodCategory.icon, equals(Icons.restaurant));
      });

      test('test_transport_category_properties', () {
        final transportCategory = DefaultCategories.categories
            .firstWhere((cat) => cat.id == 'transport');

        expect(transportCategory.title, equals('Transport'));
        expect(transportCategory.color, equals(Colors.blue));
        expect(transportCategory.icon, equals(Icons.directions_car));
      });

      test('test_bills_category_properties', () {
        final billsCategory =
            DefaultCategories.categories.firstWhere((cat) => cat.id == 'bills');

        expect(billsCategory.title, equals('Bills'));
        expect(billsCategory.color, equals(Colors.red));
        expect(billsCategory.icon, equals(Icons.receipt));
      });

      test('test_entertainment_category_properties', () {
        final entertainmentCategory = DefaultCategories.categories
            .firstWhere((cat) => cat.id == 'entertainment');

        expect(entertainmentCategory.title, equals('Entertainment'));
        expect(entertainmentCategory.color, equals(Colors.purple));
        expect(entertainmentCategory.icon, equals(Icons.movie));
      });

      test('test_shopping_category_properties', () {
        final shoppingCategory = DefaultCategories.categories
            .firstWhere((cat) => cat.id == 'shopping');

        expect(shoppingCategory.title, equals('Shopping'));
        expect(shoppingCategory.color, equals(Colors.green));
        expect(shoppingCategory.icon, equals(Icons.shopping_bag));
      });

      test('test_health_category_properties', () {
        final healthCategory = DefaultCategories.categories
            .firstWhere((cat) => cat.id == 'health');

        expect(healthCategory.title, equals('Health'));
        expect(healthCategory.color, equals(Colors.teal));
        expect(healthCategory.icon, equals(Icons.local_hospital));
      });

      test('test_other_category_properties', () {
        final otherCategory =
            DefaultCategories.categories.firstWhere((cat) => cat.id == 'other');

        expect(otherCategory.title, equals('Other'));
        expect(otherCategory.color, equals(Colors.grey));
        expect(otherCategory.icon, equals(Icons.category));
      });
    });

    group('Default Categories Validation Tests', () {
      test('test_all_categories_valid_colors', () {
        for (final category in DefaultCategories.categories) {
          expect(category.color, isA<Color>());
          expect(category.color.value, isA<int>());
        }
      });

      test('test_all_categories_valid_icons', () {
        for (final category in DefaultCategories.categories) {
          expect(category.icon, isA<IconData>());
          expect(category.icon.codePoint, isA<int>());
          expect(category.icon.codePoint, greaterThan(0));
        }
      });

      test('test_all_categories_valid_titles', () {
        for (final category in DefaultCategories.categories) {
          expect(category.title, isA<String>());
          expect(category.title.isNotEmpty, isTrue);
          expect(category.title.trim().length, greaterThanOrEqualTo(2));
          expect(category.title.trim().length, lessThanOrEqualTo(50));
        }
      });
    });
  });
}
