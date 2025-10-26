import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:p5_expense/model/savings_goal.dart';
import 'package:p5_expense/service/savings_goal_service.dart';
import 'package:p5_expense/view/new_savings_goal.dart';
import 'package:p5_expense/view/edit_savings_goal.dart';
import 'package:p5_expense/view/savings_goals_list.dart';

class SavingsSummaryScreen extends StatelessWidget {
  const SavingsSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add goal',
            onPressed: () async {
              final created = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NewSavingsGoalScreen(),
                ),
              );
              if (created == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Savings goal added successfully')),
                );
              }
            },
          ),
        ],
      ),
      body: _GoalsBody(),
    );
  }
}

class _GoalsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _EmptyPlaceholder();
    }
    return StreamBuilder<List<SavingsGoal>>(
      stream: SavingsGoalService.streamGoals(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading goals: ${snapshot.error}'));
        }
        final goals = snapshot.data ?? const [];
        if (goals.isEmpty) {
          return _EmptyPlaceholder();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SavingsGoalsList(
            goals,
            onContribute: (g) async {
              final controller = TextEditingController();
              final input = await showDialog<String>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Contribute to goal'),
                  content: TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              );
              final amount = double.tryParse((input ?? '').trim());
              if (amount == null || amount <= 0) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a positive amount')),
                  );
                }
                return;
              }
              try {
                final remaining = (g.targetAmount - g.currentAmount).clamp(0, double.infinity) as double;
                if (remaining <= 0) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Goal already completed')),
                    );
                  }
                  return;
                }
                var applied = amount;
                if (amount > remaining) {
                  applied = remaining;
                }
                final newCurrent = g.currentAmount + applied;
                final completed = newCurrent >= g.targetAmount && g.targetAmount > 0;
                final updated = g.copyWith(
                  currentAmount: newCurrent,
                  completed: completed,
                );
                await SavingsGoalService.updateGoal(user.uid, updated);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added ${applied.toStringAsFixed(2)} to "${g.title}"')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to contribute: $e')),
                  );
                }
              }
            },
            onEdit: (g) async {
              final updated = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditSavingsGoalScreen(goal: g),
                ),
              );
              if (updated == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Savings goal updated')),
                );
              }
            },
            onDelete: (g) async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete goal?'),
                  content: Text('Are you sure you want to delete "${g.title}"? This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm != true) return;

              try {
                await SavingsGoalService.deleteGoal(user.uid, g.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted "${g.title}"')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: $e')),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.savings_outlined,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'No savings goals yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a goal to start tracking your savings.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
