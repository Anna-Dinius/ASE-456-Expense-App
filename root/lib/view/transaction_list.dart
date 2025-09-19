import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:p5_expense/model/transaction.dart';
import 'package:p5_expense/model/category.dart'; // NEW: Import Category model to display category info

/// Widget that displays a list of all transactions
/// Shows each transaction with its category information and allows deletion
class TransactionList extends StatelessWidget {
  // List of transactions to display
  final List<Transaction> transactions;

  // Function to call when user wants to delete a transaction
  final Function deleteTx;

  // NEW: List of categories to look up category information for each transaction
  final List<Category> categories;

  TransactionList(this.transactions, this.deleteTx, this.categories);

  /// Helper method to find a category by its ID
  /// Returns null if no category with that ID is found
  Category? _getCategoryById(String categoryId) {
    try {
      // Find the first category that matches the given ID
      return categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      // If no category is found, return null
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      child: transactions.isEmpty
          ? Column(
              children: <Widget>[
                Text(
                  'No transactions added yet!',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                    height: 200,
                    child: Image.asset(
                      'assets/images/waiting.png',
                      fit: BoxFit.cover,
                    )),
              ],
            )
          : ListView.builder(
              itemBuilder: (ctx, index) {
                // Get the current transaction and its category
                final transaction = transactions[index];
                final category = _getCategoryById(transaction.categoryId);

                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 5,
                  ),
                  child: ListTile(
                    // NEW: Show category icon and color in the leading circle
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: category?.color ??
                          Colors
                              .grey, // Use category color or grey if not found
                      child: Icon(
                        category?.icon ??
                            Icons
                                .category, // Use category icon or default if not found
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      transaction.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show the transaction date
                        Text(
                          DateFormat.yMMMd().format(transaction.date),
                        ),
                        // NEW: Show category badge if category exists
                        if (category != null)
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              // Light background color matching the category
                              color: category.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              // Border with category color
                              border: Border.all(
                                  color: category.color.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              category.title,
                              style: TextStyle(
                                color: category.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Show the transaction amount prominently
                        Text(
                          '\$${transaction.amount.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                        ),
                        SizedBox(width: 8),
                        // Delete button
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Theme.of(context).colorScheme.error,
                          onPressed: () => deleteTx(transaction.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: transactions.length,
            ),
    );
  }
}
