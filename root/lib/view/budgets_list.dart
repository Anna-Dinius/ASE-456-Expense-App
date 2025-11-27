import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:p5_expense/model/budget.dart';
import 'package:p5_expense/service/budget_service.dart';
import 'package:p5_expense/model/category.dart';
import 'package:p5_expense/view/new_budget.dart';
import 'package:p5_expense/view/edit_budget.dart';

/// Screen for displaying and managing budgets
/// Follows the pattern of SavingsGoalsList and TransactionList
class BudgetsListScreen extends StatefulWidget {
  final List<Category> categories;

  const BudgetsListScreen({super.key, required this.categories});

  @override
  State<BudgetsListScreen> createState() => _BudgetsListScreenState();
}

class _BudgetsListScreenState extends State<BudgetsListScreen> {
  List<Budget> _budgets = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _loading = true);
    try {
      final budgets = await BudgetService.getAllBudgets(user.uid);
      setState(() {
        _budgets = budgets;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load budgets: $e')),
        );
      }
    }
  }

  Future<void> _createBudget() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => NewBudgetScreen(categories: widget.categories),
      ),
    );

    if (result == true && mounted) {
      await _loadBudgets();
    }
  }

  Future<void> _editBudget(Budget budget) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => EditBudgetScreen(
          budget: budget,
          categories: widget.categories,
        ),
      ),
    );

    if (result == true && mounted) {
      await _loadBudgets();
    }
  }

  Future<void> _deleteBudget(Budget budget) async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete "${budget.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await BudgetService.deleteBudget(userId: user.uid, budgetId: budget.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Budget deleted successfully')),
          );
        }
        await _loadBudgets();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete budget: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createBudget,
            tooltip: 'Create Budget',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _budgets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No budgets yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a budget to track your spending',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _createBudget,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Budget'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBudgets,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _budgets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _BudgetCard(
                        budget: _budgets[index],
                        categories: widget.categories,
                        onEdit: _editBudget,
                        onDelete: _deleteBudget,
                      );
                    },
                  ),
                ),
    );
  }
}

/// Individual budget card widget with progress visualization
class _BudgetCard extends StatefulWidget {
  final Budget budget;
  final List<Category> categories;
  final void Function(Budget budget) onEdit;
  final void Function(Budget budget) onDelete;

  const _BudgetCard({
    required this.budget,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<_BudgetCard> {
  double _spentAmount = 0.0;
  bool _loadingMetrics = true;

  @override
  void initState() {
    super.initState();
    _loadBudgetMetrics();
  }

  Future<void> _loadBudgetMetrics() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loadingMetrics = false);
      return;
    }

    try {
      final spent =
          await BudgetService.calculateSpentAmount(user.uid, widget.budget);
      if (mounted) {
        setState(() {
          _spentAmount = spent;
          _loadingMetrics = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingMetrics = false);
      }
    }
  }

  Category? get _category {
    if (widget.budget.categoryId == null) return null;
    return widget.categories.firstWhere(
      (c) => c.id == widget.budget.categoryId,
      orElse: () => Category(
          id: 'unknown',
          title: 'Unknown',
          color: Colors.grey,
          icon: Icons.help),
    );
  }

  double get _utilization => widget.budget.amount > 0
      ? (_spentAmount / widget.budget.amount).clamp(0.0, 1.0)
      : 0.0;
  double get _remaining => widget.budget.amount - _spentAmount;

  Color get _statusColor {
    if (_utilization >= 1.0) return Colors.red;
    if (_utilization >= 0.9) return Colors.orange;
    if (_utilization >= 0.75) return Colors.amber;
    return Colors.green;
  }

  String get _statusText {
    if (_utilization >= 1.0) return 'Over Budget';
    if (_utilization >= 0.9) return 'Almost Limit';
    if (_utilization >= 0.75) return 'Getting Close';
    return 'On Track';
  }

  String get _budgetTypeText {
    switch (widget.budget.type) {
      case BudgetType.OVERALL:
        return 'Overall Budget';
      case BudgetType.CATEGORY:
        return _category?.title ?? 'Category Budget';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with name and actions
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.budget.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _budgetTypeText,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => widget.onEdit(widget.budget),
                      tooltip: 'Edit Budget',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => widget.onDelete(widget.budget),
                      tooltip: 'Delete Budget',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress indicator
            if (_loadingMetrics)
              const Center(child: CircularProgressIndicator())
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _utilization,
                  minHeight: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
                ),
              ),
              const SizedBox(height: 12),

              // Status badge
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: _statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(_utilization * 100).toStringAsFixed(1)}% used',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Amount details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget: \$${widget.budget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Spent: \$${_spentAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _remaining >= 0
                            ? 'Remaining: \$${_remaining.toStringAsFixed(2)}'
                            : 'Over by: \$${(-_remaining).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _remaining >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.budget.daysRemaining} days left',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Date range
              const SizedBox(height: 8),
              Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Start: ${widget.budget.startDate.year}-${widget.budget.startDate.month.toString().padLeft(2, '0')}-${widget.budget.startDate.day.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'End: ${widget.budget.endDate.year}-${widget.budget.endDate.month.toString().padLeft(2, '0')}-${widget.budget.endDate.day.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
