import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:fl_chart/fl_chart.dart';
import 'package:p5_expense/model/savings_goal.dart';
import 'package:p5_expense/service/savings_goal_service.dart';

class SavingsDashboardScreen extends StatefulWidget {
  const SavingsDashboardScreen({super.key});

  @override
  State<SavingsDashboardScreen> createState() => _SavingsDashboardScreenState();
}

class _SavingsDashboardScreenState extends State<SavingsDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Savings Dashboard')),
        body: const Center(
          child: Text('You must be signed in to view the dashboard.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Dashboard')),
      body: StreamBuilder<List<SavingsGoal>>(
        stream: SavingsGoalService.streamGoals(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final goals = snapshot.data ?? [];

          if (goals.isEmpty) {
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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

          final totalTarget = goals.fold<double>(
              0.0, (sum, goal) => sum + goal.targetAmount);
          final totalSaved = goals.fold<double>(
              0.0, (sum, goal) => sum + goal.currentAmount);
          final totalRemaining =
              (totalTarget - totalSaved).clamp(0.0, double.infinity);
          final overallProgress = totalTarget > 0 ? totalSaved / totalTarget : 0.0;

          final activeGoals = goals
              .where((g) => !g.completed && g.progress < 1.0)
              .toList();
          final completedGoals = goals
              .where((g) => g.completed || g.progress >= 1.0)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overall Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _SummaryItem(
                              label: 'Total Saved',
                              value: '\$${totalSaved.toStringAsFixed(2)}',
                              color: Colors.green,
                            ),
                            _SummaryItem(
                              label: 'Total Target',
                              value: '\$${totalTarget.toStringAsFixed(2)}',
                              color: Colors.blue,
                            ),
                            _SummaryItem(
                              label: 'Remaining',
                              value: '\$${totalRemaining.toStringAsFixed(2)}',
                              color: Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: overallProgress,
                            minHeight: 12,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              overallProgress >= 1.0
                                  ? Colors.green
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(overallProgress * 100).toStringAsFixed(1)}% complete',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Goals Breakdown',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${activeGoals.length}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const Text('Active',
                                  style:
                                      TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${completedGoals.length}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const Text('Completed',
                                  style:
                                      TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (goals.isNotEmpty) ...[
                  const Text(
                    'Savings Distribution',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 250,
                        child: PieChart(
                          PieChartData(
                            sections: _buildPieChartSections(goals),
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPieChartLegend(goals),
                  const SizedBox(height: 24),
                ],
                if (goals.length > 1) ...[
                  const Text(
                    'Top Goals by Target Amount',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 300,
                        child: BarChart(
                          _buildBarChartData(goals),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'All Goals',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: goals.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    final isCompleted = goal.completed || goal.progress >= 1.0;
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (isCompleted)
                                  const Chip(
                                    label: Text('Completed'),
                                    visualDensity: VisualDensity.compact,
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
                            const SizedBox(height: 6),
                            Text(
                              '\$${goal.currentAmount.toStringAsFixed(2)} / \$${goal.targetAmount.toStringAsFixed(2)} (${(goal.progress * 100).toStringAsFixed(0)}%)',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
      List<SavingsGoal> goals) {
    const colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return List.generate(goals.length, (index) {
      final goal = goals[index];
      final percentage = goal.targetAmount > 0
          ? (goal.targetAmount /
              goals.fold<double>(0, (sum, g) => sum + g.targetAmount)) *
          100
          : 0;

      return PieChartSectionData(
        value: goal.targetAmount,
        title: '${percentage.toStringAsFixed(1)}%',
        color: colors[index % colors.length],
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildPieChartLegend(List<SavingsGoal> goals) {
    const colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(goals.length, (index) {
        final goal = goals[index];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                goal.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        );
      }),
    );
  }

  BarChartData _buildBarChartData(List<SavingsGoal> goals) {
    final topGoals = [...goals]
      ..sort((a, b) => b.targetAmount.compareTo(a.targetAmount));
    final displayGoals = topGoals.take(6).toList();

    final maxAmount = displayGoals.isNotEmpty
        ? displayGoals.map((g) => g.targetAmount).reduce((a, b) => a > b ? a : b)
        : 1000;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxAmount * 1.1,
      barTouchData: BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < displayGoals.length) {
                final title = displayGoals[index].title;
                final truncated =
                    title.length > 10 ? '${title.substring(0, 10)}...' : title;
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Text(
                    truncated,
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(
                '\$${(value / 1000).toStringAsFixed(1)}k',
                style: const TextStyle(fontSize: 10),
              );
            },
            reservedSize: 50,
          ),
        ),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(displayGoals.length, (index) {
        final goal = displayGoals[index];
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: goal.targetAmount,
              color: Colors.blue.shade300,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            BarChartRodData(
              toY: goal.currentAmount,
              color: Colors.green,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
          barsSpace: 4,
        );
      }),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
