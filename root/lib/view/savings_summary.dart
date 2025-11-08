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
    if (user == null) return _EmptyPlaceholder();

    return StreamBuilder<List<SavingsGoal>>(
      stream: SavingsGoalService.streamGoals(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final goals = snapshot.data ?? [];
        if (goals.isEmpty) return _EmptyPlaceholder();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SavingsGoalsList(
            goals,
            onContribute: (goal) async {
              final amount = await _showContributeDialog(context);
              if (amount == null || !context.mounted) return;

              try {
                final remaining = (goal.targetAmount - goal.currentAmount).clamp(0.0, double.infinity);
                if (remaining <= 0) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Goal already completed')),
                  );
                  return;
                }

                final applied = amount > remaining ? remaining : amount;
                final newCurrent = goal.currentAmount + applied;
                
                // Create updated goal with new amount and completion status
                var updated = goal.copyWith(
                  currentAmount: newCurrent,
                  completed: newCurrent >= goal.targetAmount && goal.targetAmount > 0,
                );
                
                // Detect newly reached milestones
                final newMilestones = updated.detectNewMilestones(goal);
                
                // Update milestone flags
                updated = updated.updateMilestones();
                
                await SavingsGoalService.updateGoal(user.uid, updated);
                if (!context.mounted) return;
                
                // Show milestone notifications for each newly reached milestone
                for (final milestone in newMilestones) {
                  _showMilestoneNotification(context, goal.title, milestone);
                  // Small delay between multiple milestone notifications
                  await Future.delayed(const Duration(milliseconds: 300));
                }
                
                // Show contribution success message (unless 100% milestone was reached)
                if (!newMilestones.contains(100)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added \$${applied.toStringAsFixed(2)} to "${goal.title}"')),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to contribute: $e')),
                );
              }
            },
            onEdit: (goal) async {
              final updated = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EditSavingsGoalScreen(goal: goal)),
              );
              if (updated == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Goal updated')),
                );
              }
            },
            onDelete: (goal) async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete goal?'),
                  content: Text('Are you sure you want to delete "${goal.title}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm != true) return;

              try {
                await SavingsGoalService.deleteGoal(user.uid, goal.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted "${goal.title}"')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete: $e')),
                );
              }
            },
          ),
        );
      },
    );
  }
}

Future<double?> _showContributeDialog(BuildContext context) async {
  final controller = TextEditingController();
  final input = await showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Contribute to goal'),
      content: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Amount'),
        autofocus: true,
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
  
  final amount = double.tryParse(input ?? '');
  if (amount == null || amount <= 0) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a positive amount')),
      );
    }
    return null;
  }
  return amount;
}

/// Shows a celebratory notification when a milestone is reached
void _showMilestoneNotification(BuildContext context, String goalTitle, int milestone) {
  String emoji;
  String message;
  Color backgroundColor;
  
  switch (milestone) {
    case 50:
      emoji = '🎯';
      message = 'Halfway there! You\'ve reached 50% of "$goalTitle"!';
      backgroundColor = Colors.blue;
      break;
    case 75:
      emoji = '🌟';
      message = 'Amazing progress! You\'ve reached 75% of "$goalTitle"!';
      backgroundColor = Colors.orange;
      break;
    case 100:
      emoji = '🎉';
      message = 'Congratulations! You\'ve completed "$goalTitle"!';
      backgroundColor = Colors.green;
      break;
    default:
      return;
  }
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(16),
    ),
  );
}

class _EmptyPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
