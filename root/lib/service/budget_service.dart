import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p5_expense/model/budget.dart';
import 'package:p5_expense/service/category_service.dart';

/// Service class for managing budgets in Firebase Firestore
/// Handles CRUD operations, validation, and business logic for budgets
/// Budgets are user-specific and stored under each user's subcollection
class BudgetService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'budgets';

  /// Gets all budgets from Firestore for a specific user
  /// Returns a list of all available budgets for the user
  static Future<List<Budget>> getAllBudgets(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .get();
      return snapshot.docs
          .map((doc) => Budget.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting budgets: $e');
      return [];
    }
  }

  /// Gets a specific budget by ID for a specific user
  /// Returns null if the budget doesn't exist
  static Future<Budget?> getBudgetById(String userId, String budgetId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(budgetId)
          .get();
      if (doc.exists && doc.data() != null) {
        return Budget.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting budget by ID: $e');
      return null;
    }
  }

  /// Gets all active budgets for a specific user
  /// Returns only budgets that are currently active (within date range and isActive = true)
  static Future<List<Budget>> getActiveBudgets(String userId) async {
    try {
      final allBudgets = await getAllBudgets(userId);
      return allBudgets.where((budget) => budget.isCurrentlyActive).toList();
    } catch (e) {
      print('Error getting active budgets: $e');
      return [];
    }
  }

  /// Gets budgets for a specific category
  /// Returns budgets that are either overall budgets or category-specific budgets
  static Future<List<Budget>> getBudgetsForCategory(String userId, String categoryId) async {
    try {
      final allBudgets = await getAllBudgets(userId);
      return allBudgets.where((budget) => 
        budget.categoryId == categoryId || budget.type == BudgetType.OVERALL
      ).toList();
    } catch (e) {
      print('Error getting budgets for category: $e');
      return [];
    }
  }

  /// Creates a new budget in Firestore for a specific user
  /// Validates the budget data before saving
  /// Returns the created budget or null if validation fails
  static Future<Budget?> createBudget({
    required String userId,
    required String name,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
    String? categoryId,
    required BudgetType type,
    required BudgetPeriod period,
    List<double> alertThresholds = const [0.5, 0.75, 0.9],
  }) async {
    // Validate budget data
    final validationResult = _validateBudget(
      name, amount, startDate, endDate, categoryId, type, alertThresholds
    );
    if (!validationResult.isValid) {
      throw Exception(validationResult.errorMessage);
    }

    try {
      // Check if category exists for category-specific budgets
      if (type == BudgetType.CATEGORY && categoryId != null) {
        final category = await CategoryService.getCategoryById(userId, categoryId);
        if (category == null) {
          throw Exception('Category not found');
        }
      }

      // Check for overlapping budgets of the same type and category
      final overlappingBudgets = await _findOverlappingBudgets(
        userId, startDate, endDate, type, categoryId
      );
      if (overlappingBudgets.isNotEmpty) {
        final budgetNames = overlappingBudgets.map((b) => b.name).join(', ');
        throw Exception('Budget overlaps with existing budget(s): $budgetNames. Please adjust the date range or deactivate the overlapping budget(s).');
      }

      // Create new budget
      final now = DateTime.now();
      final budget = Budget(
        id: '', // Will be set by Firestore
        name: name.trim(),
        amount: amount,
        startDate: startDate,
        endDate: endDate,
        categoryId: categoryId,
        type: type,
        period: period,
        isActive: true,
        alertThresholds: alertThresholds,
        createdAt: now,
        lastUpdatedAt: now,
      );

      // Save to Firestore under user's subcollection
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .add(budget.toMap());

      // Return budget with the Firestore-generated ID
      return Budget(
        id: docRef.id,
        name: budget.name,
        amount: budget.amount,
        startDate: budget.startDate,
        endDate: budget.endDate,
        categoryId: budget.categoryId,
        type: budget.type,
        period: budget.period,
        isActive: budget.isActive,
        alertThresholds: budget.alertThresholds,
        createdAt: budget.createdAt,
        lastUpdatedAt: budget.lastUpdatedAt,
      );
    } catch (e) {
      print('Error creating budget: $e');
      rethrow;
    }
  }

  /// Updates an existing budget for a specific user
  /// Validates the updated data before saving
  /// Returns the updated budget or null if validation fails
  static Future<Budget?> updateBudget({
    required String userId,
    required String budgetId,
    required String name,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
    String? categoryId,
    required BudgetType type,
    required BudgetPeriod period,
    required bool isActive,
    List<double> alertThresholds = const [0.5, 0.75, 0.9],
  }) async {
    // Validate budget data
    final validationResult = _validateBudget(
      name, amount, startDate, endDate, categoryId, type, alertThresholds
    );
    if (!validationResult.isValid) {
      throw Exception(validationResult.errorMessage);
    }

    try {
      // Check if budget exists for this user
      final existingBudget = await getBudgetById(userId, budgetId);
      if (existingBudget == null) {
        throw Exception('Budget not found');
      }

      // Check if category exists for category-specific budgets
      if (type == BudgetType.CATEGORY && categoryId != null) {
        final category = await CategoryService.getCategoryById(userId, categoryId);
        if (category == null) {
          throw Exception('Category not found');
        }
      }

      // Check for overlapping budgets (excluding current budget)
      final overlappingBudgets = await _findOverlappingBudgets(
        userId, startDate, endDate, type, categoryId, excludeBudgetId: budgetId
      );
      if (overlappingBudgets.isNotEmpty) {
        final budgetNames = overlappingBudgets.map((b) => b.name).join(', ');
        throw Exception('Budget overlaps with existing budget(s): $budgetNames. Please adjust the date range or deactivate the overlapping budget(s).');
      }

      // Update budget
      final updatedBudget = Budget(
        id: budgetId,
        name: name.trim(),
        amount: amount,
        startDate: startDate,
        endDate: endDate,
        categoryId: categoryId,
        type: type,
        period: period,
        isActive: isActive,
        alertThresholds: alertThresholds,
        createdAt: existingBudget.createdAt,
        lastUpdatedAt: DateTime.now(),
      );

      // Save to Firestore under user's subcollection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(budgetId)
          .update(updatedBudget.toMap());

      return updatedBudget;
    } catch (e) {
      print('Error updating budget: $e');
      rethrow;
    }
  }

  /// Deletes a budget for a specific user
  /// Returns true if deletion was successful
  static Future<bool> deleteBudget({
    required String userId,
    required String budgetId,
  }) async {
    try {
      // Check if budget exists for this user
      final existingBudget = await getBudgetById(userId, budgetId);
      if (existingBudget == null) {
        throw Exception('Budget not found');
      }

      // Delete the budget from user's subcollection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(budgetId)
          .delete();

      print('Successfully deleted budget $budgetId');
      return true;
    } catch (e) {
      print('Error deleting budget: $e');
      rethrow;
    }
  }

  /// Seeds the database with default budgets if none exist for a specific user
  /// This is called on first app launch to ensure users have budgets to work with
  static Future<void> seedDefaultBudgets(String userId) async {
    try {
      // Check if budgets already exist for this user
      final existingBudgets = await getAllBudgets(userId);

      if (existingBudgets.isNotEmpty) {
        print('Budgets already exist for user $userId');
        return;
      }

      // Create default budgets for this user
      final batch = _firestore.batch();
      for (final budget in DefaultBudgets.budgets) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection(_collection)
            .doc(budget.id);
        batch.set(docRef, budget.toMap());
      }

      await batch.commit();
      print('Successfully seeded default budgets for user $userId');
    } catch (e) {
      print('Error seeding default budgets: $e');
      rethrow;
    }
  }

  /// Calculates the total spent amount for a specific budget
  /// This includes all transactions within the budget period that match the budget criteria
  static Future<double> calculateSpentAmount(String userId, Budget budget) async {
    if (!budget.isActive) return 0.0; // Do not sum for inactive budgets
    try {
      // Get all transactions for the user
      final transactionsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();

      double totalSpent = 0.0;

      for (final doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final transactionDate = (data['date'] as Timestamp).toDate();
        final amount = (data['amount'] as num).toDouble();
        final categoryId = data['categoryId'] as String?;

        // Check if transaction is within budget period
        if (transactionDate.isAfter(budget.startDate.subtract(Duration(days: 1))) &&
            transactionDate.isBefore(budget.endDate.add(Duration(days: 1)))) {
          
          // Check if transaction matches budget criteria
          if (budget.type == BudgetType.OVERALL) {
            // Overall budget includes all transactions
            totalSpent += amount;
          } else if (budget.type == BudgetType.CATEGORY && 
                     budget.categoryId == categoryId) {
            // Category-specific budget includes only transactions in that category
            totalSpent += amount;
          }
        }
      }

      return totalSpent;
    } catch (e) {
      print('Error calculating spent amount: $e');
      return 0.0;
    }
  }

  /// Calculates the remaining budget amount
  /// Returns the amount left in the budget (can be negative if over budget)
  static Future<double> calculateRemainingAmount(String userId, Budget budget) async {
    if (!budget.isActive) return budget.amount; // Inactive: nothing spent
    try {
      final spentAmount = await calculateSpentAmount(userId, budget);
      return budget.amount - spentAmount;
    } catch (e) {
      print('Error calculating remaining amount: $e');
      return budget.amount;
    }
  }

  /// Calculates the budget utilization percentage
  /// Returns a value between 0.0 and 1.0 (can exceed 1.0 if over budget)
  static Future<double> calculateUtilizationPercentage(String userId, Budget budget) async {
    if (!budget.isActive) return 0.0; // Inactive: always 0%
    try {
      final spentAmount = await calculateSpentAmount(userId, budget);
      return spentAmount / budget.amount;
    } catch (e) {
      print('Error calculating utilization percentage: $e');
      return 0.0;
    }
  }

  /// Gets budgets that are approaching or have exceeded their limits
  /// Returns budgets that have reached any of their alert thresholds
  static Future<List<Budget>> getBudgetsNeedingAttention(String userId) async {
    try {
      final activeBudgets = await getActiveBudgets(userId);
      final budgetsNeedingAttention = <Budget>[];

      for (final budget in activeBudgets) {
        final utilization = await calculateUtilizationPercentage(userId, budget);
        
        // Check if budget has reached any alert threshold
        for (final threshold in budget.alertThresholds) {
          if (utilization >= threshold) {
            budgetsNeedingAttention.add(budget);
            break;
          }
        }
      }

      return budgetsNeedingAttention;
    } catch (e) {
      print('Error getting budgets needing attention: $e');
      return [];
    }
  }

  /// Finds overlapping budgets for the given criteria
  static Future<List<Budget>> _findOverlappingBudgets(
    String userId,
    DateTime startDate,
    DateTime endDate,
    BudgetType type,
    String? categoryId, {
    String? excludeBudgetId,
  }) async {
    try {
      final allBudgets = await getAllBudgets(userId);
      final overlappingBudgets = <Budget>[];

      for (final budget in allBudgets) {
        // Skip the budget we're excluding (for updates)
        if (excludeBudgetId != null && budget.id == excludeBudgetId) {
          continue;
        }

        // Skip inactive budgets
        if (!budget.isActive) {
          continue;
        }

        // Check if budgets are of the same type and category
        if (budget.type != type) {
          continue;
        }

        if (type == BudgetType.CATEGORY && budget.categoryId != categoryId) {
          continue;
        }

        // Check for date overlap
        if (startDate.isBefore(budget.endDate) && endDate.isAfter(budget.startDate)) {
          overlappingBudgets.add(budget);
        }
      }

      return overlappingBudgets;
    } catch (e) {
      print('Error finding overlapping budgets: $e');
      return [];
    }
  }

  /// Validates budget data
  /// Returns validation result with error message if invalid
  static BudgetValidationResult _validateBudget(
    String name,
    double amount,
    DateTime startDate,
    DateTime endDate,
    String? categoryId,
    BudgetType type,
    List<double> alertThresholds,
  ) {
    // Check name is not empty
    if (name.trim().isEmpty) {
      return BudgetValidationResult(false, 'Budget name cannot be empty');
    }

    // Check name length
    if (name.trim().length > 100) {
      return BudgetValidationResult(false, 'Budget name must be 100 characters or less');
    }

    // Check amount is positive
    if (amount <= 0) {
      return BudgetValidationResult(false, 'Budget amount must be greater than 0');
    }

    // Check amount is reasonable (not too large)
    if (amount > 1000000) {
      return BudgetValidationResult(false, 'Budget amount cannot exceed \$1,000,000');
    }

    // Check date range is valid
    if (startDate.isAfter(endDate)) {
      return BudgetValidationResult(false, 'Start date must be before end date');
    }

    // Check date range is not too long (max 5 years)
    if (endDate.difference(startDate).inDays > 1825) {
      return BudgetValidationResult(false, 'Budget period cannot exceed 5 years');
    }

    // Check category ID is provided for category-specific budgets
    if (type == BudgetType.CATEGORY && (categoryId == null || categoryId.isEmpty)) {
      return BudgetValidationResult(false, 'Category must be specified for category-specific budgets');
    }

    // Check alert thresholds are valid
    for (final threshold in alertThresholds) {
      if (threshold < 0 || threshold > 1) {
        return BudgetValidationResult(false, 'Alert thresholds must be between 0 and 1');
      }
    }

    // Check alert thresholds are in ascending order
    for (int i = 1; i < alertThresholds.length; i++) {
      if (alertThresholds[i] <= alertThresholds[i - 1]) {
        return BudgetValidationResult(false, 'Alert thresholds must be in ascending order');
      }
    }

    return BudgetValidationResult(true, '');
  }

  /// Gets the number of transactions using a specific budget
  /// Useful for showing usage before deletion
  static Future<int> getTransactionCountForBudget(String userId, String budgetId) async {
    try {
      final budget = await getBudgetById(userId, budgetId);
      if (budget == null) return 0;

      final transactionsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();

      int count = 0;
      for (final doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final transactionDate = (data['date'] as Timestamp).toDate();
        final categoryId = data['categoryId'] as String?;

        // Check if transaction is within budget period
        if (transactionDate.isAfter(budget.startDate.subtract(Duration(days: 1))) &&
            transactionDate.isBefore(budget.endDate.add(Duration(days: 1)))) {
          
          // Check if transaction matches budget criteria
          if (budget.type == BudgetType.OVERALL) {
            count++;
          } else if (budget.type == BudgetType.CATEGORY && 
                     budget.categoryId == categoryId) {
            count++;
          }
        }
      }

      return count;
    } catch (e) {
      print('Error getting transaction count for budget: $e');
      return 0;
    }
  }
}

/// Validation result class for budget validation
class BudgetValidationResult {
  final bool isValid;
  final String errorMessage;

  BudgetValidationResult(this.isValid, this.errorMessage);
}
