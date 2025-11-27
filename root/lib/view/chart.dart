import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import './chart_bar.dart';
import 'package:p5_expense/model/transaction.dart';
import 'package:p5_expense/service/analytics_service.dart';

/// Chart widget for displaying spending trends over the last 7 days
/// Supports both AnalyticsService integration and legacy transaction list mode
class Chart extends StatelessWidget {
  /// Optional: List of transactions for legacy mode (backward compatibility)
  final List<Transaction>? recentTransactions;

  /// Optional: User ID for AnalyticsService integration
  final String? userId;

  /// Constructor for legacy mode (transactions list)
  const Chart(this.recentTransactions, {super.key}) : userId = null;

  /// Named constructor for AnalyticsService mode
  const Chart.withUserId(this.userId, {super.key}) : recentTransactions = null;

  /// Gets spending trends from AnalyticsService
  Future<Map<DateTime, double>> _getSpendingTrends() async {
    if (userId == null) return {};

    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 6)); // Last 7 days

    try {
      return await AnalyticsService.calculateSpendingTrends(
        userId: userId!,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      debugPrint('Error loading spending trends: $e');
      return {};
    }
  }

  /// Legacy method: Groups transactions by day (for backward compatibility)
  List<Map<String, Object>> _getGroupedTransactionValues() {
    if (recentTransactions == null) return [];

    return List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(
        Duration(days: index),
      );
      var totalSum = 0.0;

      for (var i = 0; i < recentTransactions!.length; i++) {
        if (recentTransactions![i].date.day == weekDay.day &&
            recentTransactions![i].date.month == weekDay.month &&
            recentTransactions![i].date.year == weekDay.year) {
          totalSum += recentTransactions![i].amount;
        }
      }

      return {
        'day': DateFormat.E().format(weekDay).substring(0, 1),
        'amount': totalSum,
      };
    }).reversed.toList();
  }

  /// Converts spending trends map to chart data format
  List<Map<String, Object>> _trendsToChartData(Map<DateTime, double> trends) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 6));

    // Generate chart data for last 7 days
    final chartData = <Map<String, Object>>[];
    for (int i = 0; i < 7; i++) {
      final weekDay = startDate.add(Duration(days: i));
      // Normalize date to match trends map keys (year, month, day only)
      final normalizedDate = DateTime(weekDay.year, weekDay.month, weekDay.day);
      final amount = trends[normalizedDate] ?? 0.0;

      chartData.add({
        'day': DateFormat.E().format(weekDay).substring(0, 1),
        'amount': amount,
      });
    }

    return chartData;
  }

  double _calculateTotalSpending(List<Map<String, Object>> data) {
    return data.fold(0.0, (sum, item) {
      return sum + (item['amount'] as double);
    });
  }

  @override
  Widget build(BuildContext context) {
    // If userId is provided, use AnalyticsService
    if (userId != null) {
      return FutureBuilder<Map<DateTime, double>>(
        future: _getSpendingTrends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Card(
              elevation: 6,
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (snapshot.hasError) {
            return Card(
              elevation: 6,
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Error loading chart data',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                  ),
                ),
              ),
            );
          }

          final trends = snapshot.data ?? {};
          final chartData = _trendsToChartData(trends);
          final totalSpending = _calculateTotalSpending(chartData);

          return _buildChartWidget(chartData, totalSpending);
        },
      );
    }

    // Legacy mode: Use transactions list
    final chartData = _getGroupedTransactionValues();
    final totalSpending = _calculateTotalSpending(chartData);
    return _buildChartWidget(chartData, totalSpending);
  }

  Widget _buildChartWidget(
      List<Map<String, Object>> chartData, double totalSpending) {
    if (chartData.isEmpty || totalSpending == 0) {
      return Card(
        elevation: 6,
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No spending data for the last 7 days',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: chartData.map((data) {
            return Flexible(
              fit: FlexFit.tight,
              child: ChartBar(
                (data['day'] as String),
                (data['amount'] as double),
                totalSpending == 0.0
                    ? 0.0
                    : (data['amount'] as double) / totalSpending,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
