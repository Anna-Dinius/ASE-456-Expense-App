import 'package:flutter/material.dart';
import 'package:p5_expense/model/category.dart';

/// A compact pill-style widget for displaying category information
/// Used in transaction lists and other places where space is limited
class CategoryBadge extends StatelessWidget {
  final Category category;
  final double? fontSize;
  final EdgeInsets? padding;
  final bool showIcon;

  const CategoryBadge({
    Key? key,
    required this.category,
    this.fontSize,
    this.padding,
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // Light background color matching the category
        color: category.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        // Border with category color
        border: Border.all(
          color: category.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              category.icon,
              color: category.color,
              size: fontSize != null ? fontSize! + 2 : 14,
            ),
            SizedBox(width: 4),
          ],
          Text(
            category.title,
            style: TextStyle(
              color: category.color,
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact category badge that shows only the icon
/// Useful for very tight spaces
class CategoryIconBadge extends StatelessWidget {
  final Category category;
  final double size;

  const CategoryIconBadge({
    Key? key,
    required this.category,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: category.color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Icon(
        category.icon,
        color: category.color,
        size: size * 0.6,
      ),
    );
  }
}
