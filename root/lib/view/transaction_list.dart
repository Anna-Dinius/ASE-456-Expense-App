import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:p5_expense/model/transaction.dart';
import 'package:p5_expense/model/category.dart'; // Import Category model to display category info
import 'package:p5_expense/view/widgets/category_badge.dart'; // Import CategoryBadge widget

/// Widget that displays a list of all transactions
/// Shows each transaction with its category information and allows deletion
class TransactionList extends StatelessWidget {
  // List of transactions to display
  final List<Transaction> transactions;

  // Function to call when user wants to delete a transaction
  final Function deleteTx;

  // List of categories to look up category information for each transaction
  final List<Category> categories;

  const TransactionList(this.transactions, this.deleteTx, this.categories,
      {super.key});

  /// Helper method to find a category by its ID
  /// Returns a fallback category if no category with that ID is found
  Category _getCategoryById(String categoryId) {
    try {
      // Find the first category that matches the given ID
      return categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      // If no category is found, return a fallback category
      return Category(
        id: 'other',
        title: 'Other',
        color: Colors.grey,
        icon: Icons.category,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return transactions.isEmpty
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
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
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
                  // Show category icon and color in the leading circle
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: category.color.withValues(alpha: 0.2),
                    child: Icon(
                      category.icon,
                      color: category.color,
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
                      // Show category badge using CategoryBadge widget
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        child: CategoryBadge(
                          category: category,
                          fontSize: 12,
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          );
  }
}
