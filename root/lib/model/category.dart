import 'package:flutter/material.dart';

/// Represents an expense category with visual properties
/// This class stores information about different types of expenses (like Food, Bills, etc.)
class Category {
  // Unique identifier for the category (e.g., "food", "bills")
  final String id;

  // Human-readable name of the category (e.g., "Food", "Bills")
  final String title;

  // Color used to visually represent this category in the UI
  final Color color;

  // Icon used to visually represent this category in the UI
  final IconData icon;

  /// Constructor for creating a new category
  /// All parameters are required to ensure every category has complete information
  Category({
    required this.id,
    required this.title,
    required this.color,
    required this.icon,
  });

  /// Creates a copy of this category with some fields updated
  /// This is useful when editing a category - you can change only some properties
  /// while keeping the others the same
  ///
  /// Example: category.copyWith(title: "New Title") keeps everything the same
  /// except the title
  Category copyWith({
    String? id,
    String? title,
    Color? color,
    IconData? icon,
  }) {
    return Category(
      // If a new value is provided, use it; otherwise keep the original value
      id: id ?? this.id,
      title: title ?? this.title,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  /// Converts this category to a JSON format for saving to storage
  /// JSON is a text format that can be easily saved to files or databases
  ///
  /// Note: We convert the Color to a number and IconData to a code point
  /// because JSON can't directly store these complex objects
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'color': color.toARGB32(), // Convert color to a number
      'icon': icon.codePoint, // Convert icon to a number
    };
  }

  /// Creates a Category object from JSON data
  /// This is the opposite of toJson() - it takes saved data and recreates the object
  ///
  /// factory constructor: A special type of constructor that can return different
  /// types of objects or create objects in different ways
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      title: json['title'],
      color: Color(json['color']), // Convert number back to Color
      icon: IconData(json['icon'],
          fontFamily: 'MaterialIcons'), // Convert number back to IconData
    );
  }

  /// Checks if two categories are the same
  /// This is important for comparing categories and removing duplicates
  @override
  bool operator ==(Object other) {
    // If it's the exact same object in memory, they're equal
    if (identical(this, other)) return true;

    // Check if the other object is a Category and all properties match
    return other is Category &&
        other.id == id &&
        other.title == title &&
        other.color == color &&
        other.icon == icon;
  }

  /// Generates a unique number for this category
  /// This is used by Dart's internal systems for efficient storage and comparison
  @override
  int get hashCode {
    // Combine all the hash codes using XOR (^) operator
    return id.hashCode ^ title.hashCode ^ color.hashCode ^ icon.hashCode;
  }

  /// Returns a string representation of this category
  /// Useful for debugging - shows all the category's properties
  @override
  String toString() {
    return 'Category(id: $id, title: $title, color: $color, icon: $icon)';
  }
}

/// Contains a list of predefined categories that users can start with
/// These are common expense categories that most people will find useful
///
/// static: This means the list belongs to the class itself, not to individual objects
/// final: This means the list can't be changed after it's created
class DefaultCategories {
  static final List<Category> categories = [
    // Food and dining expenses
    Category(
      id: 'food',
      title: 'Food',
      color: Colors.orange, // Orange color for food
      icon: Icons.restaurant, // Restaurant icon
    ),

    // Transportation expenses (gas, public transport, etc.)
    Category(
      id: 'transport',
      title: 'Transport',
      color: Colors.blue, // Blue color for transport
      icon: Icons.directions_car, // Car icon
    ),

    // Bills and utilities
    Category(
      id: 'bills',
      title: 'Bills',
      color: Colors.red, // Red color for bills (urgent/important)
      icon: Icons.receipt, // Receipt icon
    ),

    // Entertainment and leisure
    Category(
      id: 'entertainment',
      title: 'Entertainment',
      color: Colors.purple, // Purple color for fun activities
      icon: Icons.movie, // Movie icon
    ),

    // Shopping and retail
    Category(
      id: 'shopping',
      title: 'Shopping',
      color: Colors.green, // Green color for shopping
      icon: Icons.shopping_bag, // Shopping bag icon
    ),

    // Health and medical expenses
    Category(
      id: 'health',
      title: 'Health',
      color: Colors.teal, // Teal color for health
      icon: Icons.local_hospital, // Hospital icon
    ),

    // Catch-all category for expenses that don't fit elsewhere
    Category(
      id: 'other',
      title: 'Other',
      color: Colors.grey, // Grey color for miscellaneous
      icon: Icons.category, // Generic category icon
    ),
  ];
}
