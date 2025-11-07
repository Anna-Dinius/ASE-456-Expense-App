import 'package:flutter/material.dart';
import 'package:p5_expense/model/savings_goal.dart';

class SavingsGoalsList extends StatelessWidget {
  final List<SavingsGoal> savingsGoals;
  final void Function(SavingsGoal)? onDelete;
  final void Function(SavingsGoal)? onEdit;
  final void Function(SavingsGoal)? onContribute;

  const SavingsGoalsList(
    this.savingsGoals, {
    super.key,
    this.onDelete,
    this.onEdit,
    this.onContribute,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: savingsGoals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final goal = savingsGoals[index];
        final isCompleted = goal.completed || goal.progress >= 1.0;
        final percent = isCompleted ? 100 : (goal.progress * 100).round();
        return Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text('Completed'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$percent%'),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Edit',
                          onPressed: (onEdit == null || isCompleted) 
                              ? null 
                              : () => onEdit!(goal),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          tooltip: 'Contribute',
                          onPressed: (onContribute == null || isCompleted)
                              ? null
                              : () => onContribute!(goal),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete',
                          onPressed: onDelete == null ? null : () => onDelete!(goal),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${goal.currentAmount.toStringAsFixed(2)} / \$${goal.targetAmount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    if (goal.targetDate != null)
                      Text(
                        '${goal.targetDate!.year}-${goal.targetDate!.month.toString().padLeft(2, '0')}-${goal.targetDate!.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                  ],
                ),
                if (goal.description != null && goal.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    goal.description!,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}