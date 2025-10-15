import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/model/category.dart';
import 'package:p5_expense/view/widgets/category_badge.dart';
import '../../fixtures/category_test_data.dart';

void main() {
  group('CategoryBadge Widget Tests', () {
    late Category testCategory;

    setUp(() {
      testCategory = CategoryTestData.createTestCategory();
    });

    group('Widget Rendering Tests', () {
      testWidgets('test_category_badge_renders', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryBadge(category: testCategory),
            ),
          ),
        );

        expect(find.byType(CategoryBadge), findsOneWidget);
        expect(find.text(testCategory.title), findsOneWidget);
      });

      testWidgets('test_category_badge_with_icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryBadge(
                category: testCategory,
                showIcon: true,
              ),
            ),
          ),
        );

        expect(find.byType(Icon), findsOneWidget);
        expect(find.byIcon(testCategory.icon), findsOneWidget);
      });

      testWidgets('test_category_badge_without_icon',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryBadge(
                category: testCategory,
                showIcon: false,
              ),
            ),
          ),
        );

        expect(find.byType(Icon), findsNothing);
        expect(find.text(testCategory.title), findsOneWidget);
      });

      testWidgets('test_category_badge_custom_font_size',
          (WidgetTester tester) async {
        const customFontSize = 16.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryBadge(
                category: testCategory,
                fontSize: customFontSize,
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.text(testCategory.title));
        expect(textWidget.style?.fontSize, equals(customFontSize));
      });

      testWidgets('test_category_badge_custom_padding',
          (WidgetTester tester) async {
        const customPadding = EdgeInsets.all(12.0);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryBadge(
                category: testCategory,
                padding: customPadding,
              ),
            ),
          ),
        );

        final containerWidget =
            tester.widget<Container>(find.byType(Container));
        expect(containerWidget.padding, equals(customPadding));
      });
    });

    group('Visual Properties Tests', () {
      testWidgets('test_category_badge_color_scheme',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryBadge(category: testCategory),
            ),
          ),
        );

        final containerWidget =
            tester.widget<Container>(find.byType(Container));
        final decoration = containerWidget.decoration as BoxDecoration;

        expect(decoration.color, isA<Color>());
      });

      testWidgets('test_category_badge_icon_color',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryBadge(
                category: testCategory,
                showIcon: true,
              ),
            ),
          ),
        );

        final iconWidget = tester.widget<Icon>(find.byIcon(testCategory.icon));
        expect(iconWidget.color, equals(testCategory.color));
      });

      testWidgets('test_category_badge_text_color',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryBadge(category: testCategory),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.text(testCategory.title));
        expect(textWidget.style?.color, equals(testCategory.color));
      });

      testWidgets('test_category_badge_background_color',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryBadge(category: testCategory),
            ),
          ),
        );

        final containerWidget =
            tester.widget<Container>(find.byType(Container));
        final decoration = containerWidget.decoration as BoxDecoration;

        expect(decoration.color, isA<Color>());
        // The background color should have alpha transparency
        expect(decoration.color?.alpha, lessThan(255));
      });
    });

    group('CategoryIconBadge Tests', () {
      testWidgets('test_category_icon_badge_renders',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryIconBadge(category: testCategory),
            ),
          ),
        );

        expect(find.byType(CategoryIconBadge), findsOneWidget);
        expect(find.byType(Icon), findsOneWidget);
      });

      testWidgets('test_category_icon_badge_custom_size',
          (WidgetTester tester) async {
        const customSize = 32.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryIconBadge(
                category: testCategory,
                size: customSize,
              ),
            ),
          ),
        );

        final containerWidget =
            tester.widget<Container>(find.byType(Container));
        expect(containerWidget.constraints?.maxWidth, equals(customSize));
        expect(containerWidget.constraints?.maxHeight, equals(customSize));
      });

      testWidgets('test_category_icon_badge_circular_shape',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryIconBadge(category: testCategory),
            ),
          ),
        );

        final containerWidget =
            tester.widget<Container>(find.byType(Container));
        final decoration = containerWidget.decoration as BoxDecoration;

        expect(decoration.borderRadius, isA<BorderRadius>());
      });

      testWidgets('test_category_icon_badge_icon_sizing',
          (WidgetTester tester) async {
        const customSize = 40.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryIconBadge(
                category: testCategory,
                size: customSize,
              ),
            ),
          ),
        );

        final iconWidget = tester.widget<Icon>(find.byIcon(testCategory.icon));
        final expectedIconSize = customSize * 0.6; // 60% of badge size
        expect(iconWidget.size, equals(expectedIconSize));
      });
    });

    group('Integration Tests', () {
      testWidgets('test_category_badge_with_different_categories',
          (WidgetTester tester) async {
        final categories = CategoryTestData.createTestCategories();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: categories
                    .map(
                      (category) => Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CategoryBadge(category: category),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );

        // Verify all categories are displayed
        for (final category in categories) {
          expect(find.text(category.title), findsOneWidget);
          expect(find.byIcon(category.icon), findsOneWidget);
        }
      });

      testWidgets('test_category_badge_tap_interaction',
          (WidgetTester tester) async {
        bool wasTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GestureDetector(
                onTap: () => wasTapped = true,
                child: CategoryBadge(category: testCategory),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        expect(wasTapped, isTrue);
      });
    });

    group('Edge Cases Tests', () {
      testWidgets('test_category_badge_with_long_title',
          (WidgetTester tester) async {
        final longTitleCategory = CategoryTestData.createLongTitleCategory();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryBadge(category: longTitleCategory),
            ),
          ),
        );

        expect(find.text(longTitleCategory.title), findsOneWidget);
      });

      testWidgets('test_category_badge_with_special_characters',
          (WidgetTester tester) async {
        final specialCharCategory =
            CategoryTestData.createSpecialCharCategory();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryBadge(category: specialCharCategory),
            ),
          ),
        );

        expect(find.text(specialCharCategory.title), findsOneWidget);
      });

      testWidgets('test_category_badge_with_extreme_colors',
          (WidgetTester tester) async {
        final extremeColorCategory = CategoryTestData.createTestCategory(
          color: Colors.black,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryBadge(category: extremeColorCategory),
            ),
          ),
        );

        expect(find.byType(CategoryBadge), findsOneWidget);
        expect(find.text(extremeColorCategory.title), findsOneWidget);
      });
    });
  });
}
