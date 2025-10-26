import 'package:flutter/material.dart';
import 'package:p5_expense/model/savings_goal.dart';

class SavingsGoalsList extends StatelessWidget {
  final List<SavingsGoal> savingsGoals;
  final void Function(SavingsGoal goal)? onDelete;
  final void Function(SavingsGoal goal)? onEdit;
  final void Function(SavingsGoal goal)? onContribute;
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
        final g = savingsGoals[index];
        final isCompleted = g.completed || g.progress >= 1.0;
        final percent = isCompleted ? 100 : (g.progress * 100).round();
        return Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        g.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
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
                          tooltip: 'Edit goal',
                          onPressed: (onEdit == null || isCompleted)
                              ? null
                              : () => onEdit!(g),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          tooltip: 'Contribute',
                          onPressed: (onContribute == null || isCompleted)
                              ? null
                              : () => onContribute!(g),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete goal',
                          onPressed: onDelete == null ? null : () => onDelete!(g),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: g.progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${g.currentAmount.toStringAsFixed(2)} / \$${g.targetAmount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    if (g.targetDate != null)
                      Text(
                        '${g.targetDate!.year}-${g.targetDate!.month.toString().padLeft(2, '0')}-${g.targetDate!.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                  ],
                ),
                if (g.description != null && g.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    g.description!,
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