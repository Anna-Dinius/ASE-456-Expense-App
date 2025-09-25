import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:p5_expense/model/category.dart';

/// Service class for managing categories in Firebase Firestore
/// Handles CRUD operations, validation, and business logic for categories
/// Categories are user-specific and stored under each user's subcollection
class CategoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'categories';

  /// Gets all categories from Firestore for a specific user
  /// Returns a list of all available categories for the user
  static Future<List<Category>> getAllCategories(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .get();
      return snapshot.docs
          .map((doc) => Category.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  /// Gets a specific category by ID for a specific user
  /// Returns null if the category doesn't exist
  static Future<Category?> getCategoryById(
      String userId, String categoryId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(categoryId)
          .get();
      if (doc.exists && doc.data() != null) {
        return Category.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting category by ID: $e');
      return null;
    }
  }

  /// Creates a new category in Firestore for a specific user
  /// Validates the category data before saving
  /// Returns the created category or null if validation fails
  static Future<Category?> createCategory({
    required String userId,
    required String title,
    required Color color,
    required IconData icon,
  }) async {
    // Validate category data
    final validationResult = _validateCategory(title, color, icon);
    if (!validationResult.isValid) {
      throw Exception(validationResult.errorMessage);
    }

    try {
      // Check if category with same name already exists for this user
      final existingCategories = await getAllCategories(userId);
      if (existingCategories
          .any((cat) => cat.title.toLowerCase() == title.toLowerCase())) {
        throw Exception('A category with this name already exists');
      }

      // Create new category
      final category = Category(
        id: '', // Will be set by Firestore
        title: title.trim(),
        color: color,
        icon: icon,
      );

      // Save to Firestore under user's subcollection
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .add(category.toMap());

      // Return category with the Firestore-generated ID
      return Category(
        id: docRef.id,
        title: category.title,
        color: category.color,
        icon: category.icon,
      );
    } catch (e) {
      print('Error creating category: $e');
      rethrow;
    }
  }

  /// Updates an existing category for a specific user
  /// Validates the updated data before saving
  /// Returns the updated category or null if validation fails
  static Future<Category?> updateCategory({
    required String userId,
    required String categoryId,
    required String title,
    required Color color,
    required IconData icon,
  }) async {
    // Validate category data
    final validationResult = _validateCategory(title, color, icon);
    if (!validationResult.isValid) {
      throw Exception(validationResult.errorMessage);
    }

    try {
      // Check if category exists for this user
      final existingCategory = await getCategoryById(userId, categoryId);
      if (existingCategory == null) {
        throw Exception('Category not found');
      }

      // Check if another category with same name already exists for this user (excluding current one)
      final existingCategories = await getAllCategories(userId);
      if (existingCategories.any((cat) =>
          cat.id != categoryId &&
          cat.title.toLowerCase() == title.toLowerCase())) {
        throw Exception('A category with this name already exists');
      }

      // Update category
      final updatedCategory = Category(
        id: categoryId,
        title: title.trim(),
        color: color,
        icon: icon,
      );

      // Save to Firestore under user's subcollection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(categoryId)
          .update(updatedCategory.toMap());

      return updatedCategory;
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  /// Deletes a category and reassigns affected transactions for a specific user
  /// Prompts user to choose a replacement category for affected transactions
  /// Returns true if deletion was successful
  static Future<bool> deleteCategory({
    required String userId,
    required String categoryId,
    required String replacementCategoryId,
  }) async {
    try {
      // Prevent deletion of the 'other' category as it's a system category
      if (categoryId == 'other') {
        throw Exception(
            'Cannot delete the "Other" category as it is a system category');
      }

      // Check if category exists for this user
      final existingCategory = await getCategoryById(userId, categoryId);
      if (existingCategory == null) {
        throw Exception('Category not found');
      }

      // Check if replacement category exists for this user
      final replacementCategory =
          await getCategoryById(userId, replacementCategoryId);
      if (replacementCategory == null) {
        // If replacement category doesn't exist, try to find 'other' category as fallback
        final otherCategory = await getCategoryById(userId, 'other');
        if (otherCategory == null) {
          throw Exception(
              'Replacement category not found and no fallback "other" category available');
        }
        // Use 'other' as replacement instead
        replacementCategoryId = 'other';
      }

      // Find all transactions using this category for this user
      final transactionsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      // Update all affected transactions to use the replacement category
      final batch = _firestore.batch();
      for (final doc in transactionsSnapshot.docs) {
        batch.update(doc.reference, {'categoryId': replacementCategoryId});
      }

      // Delete the category from user's subcollection
      batch.delete(_firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(categoryId));

      // Commit all changes
      await batch.commit();

      print(
          'Deleted category $categoryId and reassigned ${transactionsSnapshot.docs.length} transactions to $replacementCategoryId');
      return true;
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  /// Forces reseeding of default categories (useful for fixing corrupted data)
  /// This will clear existing categories and create fresh ones with proper IDs
  static Future<void> forceReseedDefaultCategories(String userId) async {
    try {
      // Clear all existing categories for this user
      final existingCategories = await getAllCategories(userId);
      if (existingCategories.isNotEmpty) {
        final batch = _firestore.batch();
        for (final category in existingCategories) {
          batch.delete(_firestore
              .collection('users')
              .doc(userId)
              .collection(_collection)
              .doc(category.id));
        }
        await batch.commit();
      }

      // Create default categories for this user with preserved IDs
      final batch = _firestore.batch();
      for (final category in DefaultCategories.categories) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection(_collection)
            .doc(category.id); // Use the predefined ID from DefaultCategories
        batch.set(docRef, category.toMap());
      }

      await batch.commit();
    } catch (e) {
      print('Error force-reseeding default categories: $e');
      rethrow;
    }
  }

  /// Seeds the database with default categories if none exist for a specific user
  /// This is called on first app launch to ensure users have categories to work with
  static Future<void> seedDefaultCategories(String userId) async {
    try {
      // Check if categories already exist for this user
      final existingCategories = await getAllCategories(userId);

      // Check if we have the required default categories with proper IDs
      bool hasOtherCategory =
          existingCategories.any((cat) => cat.id == 'other');
      bool hasAllDefaults = DefaultCategories.categories.every((defaultCat) =>
          existingCategories
              .any((existingCat) => existingCat.id == defaultCat.id));

      if (hasOtherCategory && hasAllDefaults) {
        return;
      }

      if (existingCategories.isNotEmpty) {
        await forceReseedDefaultCategories(userId);
        return;
      }

      // Create default categories for this user with preserved IDs
      final batch = _firestore.batch();
      for (final category in DefaultCategories.categories) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection(_collection)
            .doc(category.id); // Use the predefined ID from DefaultCategories
        batch.set(docRef, category.toMap());
      }

      await batch.commit();
    } catch (e) {
      print('Error seeding default categories: $e');
      rethrow;
    }
  }

  /// Migrates legacy transactions to have a categoryId for a specific user
  /// Assigns 'other' categoryId to transactions that don't have one
  static Future<void> migrateLegacyTransactions(String userId) async {
    try {
      // Find all transactions without a categoryId for this user
      final transactionsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('categoryId', isNull: true)
          .get();

      if (transactionsSnapshot.docs.isEmpty) {
        print('No legacy transactions found to migrate');
        return;
      }

      // Update all transactions to have 'other' categoryId
      final batch = _firestore.batch();
      for (final doc in transactionsSnapshot.docs) {
        batch.update(doc.reference, {'categoryId': 'other'});
      }

      await batch.commit();
      print(
          'Successfully migrated ${transactionsSnapshot.docs.length} legacy transactions');
    } catch (e) {
      print('Error migrating legacy transactions: $e');
      rethrow;
    }
  }

  /// Validates category data
  /// Returns validation result with error message if invalid
  static CategoryValidationResult _validateCategory(
      String title, Color color, IconData icon) {
    // Check title is not empty
    if (title.trim().isEmpty) {
      return CategoryValidationResult(false, 'Category name cannot be empty');
    }

    // Check title length
    if (title.trim().length > 50) {
      return CategoryValidationResult(
          false, 'Category name must be 50 characters or less');
    }

    // Check title is not only emoji/special characters
    final titleText = title.trim();
    if (titleText.length < 2) {
      return CategoryValidationResult(
          false, 'Category name must be at least 2 characters long');
    }

    // Check for valid characters (letters, numbers, spaces, and common punctuation)
    final validTitlePattern = RegExp(r'^[a-zA-Z0-9\s\-_&]+$');
    if (!validTitlePattern.hasMatch(titleText)) {
      return CategoryValidationResult(
          false, 'Category name contains invalid characters');
    }

    return CategoryValidationResult(true, '');
  }

  /// Gets the number of transactions using a specific category for a specific user
  /// Useful for showing usage before deletion
  static Future<int> getTransactionCountForCategory(
      String userId, String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('categoryId', isEqualTo: categoryId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting transaction count for category: $e');
      return 0;
    }
  }
}

/// Validation result class for category validation
class CategoryValidationResult {
  final bool isValid;
  final String errorMessage;

  CategoryValidationResult(this.isValid, this.errorMessage);
}
