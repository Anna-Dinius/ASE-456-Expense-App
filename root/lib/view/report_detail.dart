import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:p5_expense/model/report.dart';
import 'package:p5_expense/model/category.dart';
import 'package:p5_expense/model/transaction.dart';
import 'package:p5_expense/service/analytics_service.dart';
import 'package:p5_expense/service/category_service.dart';
import 'package:p5_expense/service/report_export_service.dart';
import 'package:p5_expense/view/charts_overview.dart';
import 'package:intl/intl.dart';

/// Screen for displaying detailed report information
/// Shows all metrics, charts, and visualizations for a specific report
class ReportDetailScreen extends StatefulWidget {
  final Report report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  List<Category> _categories = [];
  Map<DateTime, double> _spendingTrends = {};
  bool _loading = false;
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _loading = true;
    });

    try {
      // Load categories
      final categories = await CategoryService.getAllCategories(user.uid);

      // Load spending trends for charts
      final spendingTrends = await AnalyticsService.calculateSpendingTrends(
        userId: user.uid,
        startDate: widget.report.startDate,
        endDate: widget.report.endDate,
      );

      // Load transactions for highlights (biggest expense, etc.)
      final transactionsSnapshot = await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: widget.report.startDate)
          .where('date', isLessThanOrEqualTo: widget.report.endDate)
          .get();

      final transactions = transactionsSnapshot.docs
          .map((doc) => Transaction.fromMap(doc.data(), doc.id))
          .toList();

      setState(() {
        _categories = categories;
        _spendingTrends = spendingTrends;
        _transactions = transactions;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load chart data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Converts report's categoryBreakdown to categoryAnalysis format for charts
  Map<String, Map<String, dynamic>> _getCategoryAnalysis() {
    final analysis = <String, Map<String, dynamic>>{};
    final totalSpent = widget.report.totalSpent;

    for (final entry in widget.report.categoryBreakdown.entries) {
      final percentage = totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0.0;
      analysis[entry.key] = {
        'amount': entry.value,
        'percentage': percentage,
        'transactionCount': 0, // Report doesn't store transaction count per category
      };
    }

    return analysis;
  }

  /// Handles export actions (PDF, CSV, Print)
  Future<void> _handleExportAction(String action, BuildContext context) async {
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading categories... Please try again in a moment.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      switch (action) {
        case 'export_pdf':
          await _exportToPDF(context);
          break;
        case 'export_csv':
          await _exportToCSV(context);
          break;
        case 'print':
          await _printPDF(context);
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Exports report to PDF and shares it
  Future<void> _exportToPDF(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      dynamic file;
      try {
        file = await ReportExportService.exportToPDF(
          report: widget.report,
          categories: _categories,
        );
      } on UnsupportedError {
        // Web platform - download is handled by browser, no file returned
        file = null;
      }

      if (mounted) {
        Navigator.of(context).pop(); // Close loading indicator

        // On mobile/desktop, share the file
        if (file != null) {
          final dateFormat = DateFormat('yyyy-MM-dd');
          final fileName = 'report_${widget.report.period.replaceAll(' ', '_')}_${dateFormat.format(widget.report.startDate)}.pdf';
          await ReportExportService.shareFile(file, fileName);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Exports report to CSV and shares it
  Future<void> _exportToCSV(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      dynamic file;
      try {
        file = await ReportExportService.exportToCSV(
          report: widget.report,
          categories: _categories,
        );
      } on UnsupportedError {
        // Web platform - download is handled by browser, no file returned
        file = null;
      }

      if (mounted) {
        Navigator.of(context).pop(); // Close loading indicator

        // On mobile/desktop, share the file
        if (file != null) {
          final dateFormat = DateFormat('yyyy-MM-dd');
          final fileName = 'report_${widget.report.period.replaceAll(' ', '_')}_${dateFormat.format(widget.report.startDate)}.csv';
          await ReportExportService.shareFile(file, fileName);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Prints or shares PDF
  Future<void> _printPDF(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ReportExportService.sharePDF(
        widget.report,
        _categories,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close loading indicator
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report.period),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleExportAction(value, context),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, size: 20),
                    SizedBox(width: 8),
                    Text('Export as PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, size: 20),
                    SizedBox(width: 8),
                    Text('Export as CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print, size: 20),
                    SizedBox(width: 8),
                    Text('Print/Share PDF'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Report summary card
                    _buildSummaryCard(),

                    const SizedBox(height: 20),

                    // Report highlights
                    _buildHighlights(),

                    const SizedBox(height: 20),

                    // Spending metrics
                    _buildSpendingMetrics(),

                    const SizedBox(height: 20),

                    // Budget performance
                    if (widget.report.budgetPerformance.totalBudgetAmount > 0) ...[
                      _buildBudgetPerformance(),
                      const SizedBox(height: 20),
                    ],

                    // Category pie chart
                    if (widget.report.categoryBreakdown.isNotEmpty) ...[
                      CategoryPieChart(
                        categoryAnalysis: _getCategoryAnalysis(),
                        categories: _categories,
                        startDate: widget.report.startDate,
                        endDate: widget.report.endDate,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Spending trends chart
                    if (_spendingTrends.isNotEmpty) ...[
                      SpendingTrendsChart(
                        spendingTrends: _spendingTrends,
                        startDate: widget.report.startDate,
                        endDate: widget.report.endDate,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Budget progress chart (if budgets exist)
                    if (widget.report.budgetPerformance.totalBudgetAmount > 0)
                      FutureBuilder<List<Category>>(
                        future: CategoryService.getAllCategories(
                          fb_auth.FirebaseAuth.instance.currentUser?.uid ?? '',
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: [
                                BudgetProgressChart(
                                  budgetPerformance: widget.report.budgetPerformance,
                                  categories: snapshot.data!,
                                ),
                                const SizedBox(height: 20),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                    // Recurring transactions impact
                    if (widget.report.recurringTransactionImpact.recurringTransactionCount > 0) ...[
                      _buildRecurringImpact(),
                      const SizedBox(height: 20),
                    ],

                    // Category breakdown list
                    if (widget.report.categoryBreakdown.isNotEmpty) ...[
                      _buildCategoryBreakdown(),
                      const SizedBox(height: 20),
                    ],

                    // Report metadata
                    _buildReportMetadata(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHighlights() {
    // Find top category
    String? topCategoryId;
    double topCategoryAmount = 0.0;
    if (widget.report.categoryBreakdown.isNotEmpty) {
      final sortedCategories = widget.report.categoryBreakdown.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topCategoryId = sortedCategories.first.key;
      topCategoryAmount = sortedCategories.first.value;
    }
    Category? topCategory;
    if (topCategoryId != null) {
      try {
        topCategory = _categories.firstWhere((c) => c.id == topCategoryId);
      } catch (e) {
        topCategory = Category(
          id: topCategoryId,
          title: topCategoryId,
          color: Colors.grey,
          icon: Icons.category,
        );
      }
    }

    // Find biggest expense
    Transaction? biggestExpense;
    if (_transactions.isNotEmpty) {
      biggestExpense = _transactions.reduce(
        (a, b) => a.amount > b.amount ? a : b,
      );
    }

    // Note: Spending trend calculation can be added later if needed
    // It would require loading previous period transactions for comparison

    // Budget status
    final utilization = widget.report.budgetPerformance.utilizationPercentage;
    String budgetStatus;
    Color budgetStatusColor;
    if (utilization >= 1.0) {
      budgetStatus = 'Over Budget';
      budgetStatusColor = Colors.red;
    } else if (utilization >= 0.9) {
      budgetStatus = 'Almost Limit';
      budgetStatusColor = Colors.orange;
    } else if (utilization >= 0.75) {
      budgetStatus = 'Getting Close';
      budgetStatusColor = Colors.amber;
    } else {
      budgetStatus = 'On Track';
      budgetStatusColor = Colors.green;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stars, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Key Highlights',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // Top Category
                if (topCategory != null)
                  _buildHighlightCard(
                    icon: Icons.category,
                    iconColor: topCategory.color,
                    label: 'Top Category',
                    value: topCategory.title,
                    subtitle: '\$${topCategoryAmount.toStringAsFixed(2)}',
                  ),

                // Biggest Expense
                if (biggestExpense != null)
                  _buildHighlightCard(
                    icon: Icons.attach_money,
                    iconColor: Colors.red,
                    label: 'Biggest Expense',
                    value: biggestExpense.title,
                    subtitle: '\$${biggestExpense.amount.toStringAsFixed(2)}',
                  ),

                // Budget Status
                if (widget.report.budgetPerformance.totalBudgetAmount > 0)
                  _buildHighlightCard(
                    icon: Icons.pie_chart,
                    iconColor: budgetStatusColor,
                    label: 'Budget Status',
                    value: budgetStatus,
                    subtitle: '${(utilization * 100).toStringAsFixed(1)}% used',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: iconColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final dateFormat = DateFormat('MMM d, yyyy');
    final utilization = widget.report.budgetPerformance.utilizationPercentage;
    final utilizationColor = utilization >= 1.0
        ? Colors.red
        : utilization >= 0.9
            ? Colors.orange
            : utilization >= 0.75
                ? Colors.amber
                : Colors.green;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              '${dateFormat.format(widget.report.startDate)} - ${dateFormat.format(widget.report.endDate)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryMetric(
                    'Total Spent',
                    '\$${widget.report.totalSpent.toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryMetric(
                    'Transactions',
                    widget.report.transactionCount.toString(),
                    Icons.receipt,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.report.budgetPerformance.totalBudgetAmount > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: utilizationColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: utilizationColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.pie_chart, color: utilizationColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Budget Utilization: ${(utilization * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: utilizationColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingMetrics() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Averages',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              'Daily Average',
              '\$${widget.report.averageDailySpending.toStringAsFixed(2)}',
              Icons.today,
            ),
            const Divider(),
            _buildMetricRow(
              'Weekly Average',
              '\$${widget.report.averageWeeklySpending.toStringAsFixed(2)}',
              Icons.date_range,
            ),
            const Divider(),
            _buildMetricRow(
              'Monthly Average',
              '\$${widget.report.averageMonthlySpending.toStringAsFixed(2)}',
              Icons.calendar_month,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetPerformance() {
    final bp = widget.report.budgetPerformance;
    final utilization = bp.utilizationPercentage;
    final utilizationColor = utilization >= 1.0
        ? Colors.red
        : utilization >= 0.9
            ? Colors.orange
            : utilization >= 0.75
                ? Colors.amber
                : Colors.green;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Performance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: utilization.clamp(0.0, 1.0),
                minHeight: 16,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(utilizationColor),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget: \$${bp.totalBudgetAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Spent: \$${bp.totalSpentAgainstBudgets.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(utilization * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: utilizationColor,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBudgetStat('Exceeded', bp.exceededBudgets.toString(), Colors.red),
                _buildBudgetStat('Met', bp.metBudgets.toString(), Colors.orange),
                _buildBudgetStat('On Track', bp.underUtilizedBudgets.toString(), Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRecurringImpact() {
    final impact = widget.report.recurringTransactionImpact;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recurring Transactions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              'Total Recurring',
              '\$${impact.totalRecurringAmount.toStringAsFixed(2)}',
              Icons.repeat,
            ),
            const Divider(),
            _buildMetricRow(
              'Recurring Transactions',
              impact.recurringTransactionCount.toString(),
              Icons.receipt_long,
            ),
            const Divider(),
            _buildMetricRow(
              'Percentage of Total',
              '${impact.recurringPercentage.toStringAsFixed(1)}%',
              Icons.percent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final sortedCategories = widget.report.categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...sortedCategories.map((entry) {
              final categoryId = entry.key;
              final amount = entry.value;
              final percentage = widget.report.totalSpent > 0
                  ? (amount / widget.report.totalSpent) * 100
                  : 0.0;

              final category = _categories.firstWhere(
                (c) => c.id == categoryId,
                orElse: () => Category(
                  id: categoryId,
                  title: categoryId,
                  color: Colors.grey,
                  icon: Icons.category,
                ),
              );

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(category.icon, size: 24, color: category.color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.title,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              minHeight: 4,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(category.color),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportMetadata() {
    final dateFormat = DateFormat('MMM d, yyyy HH:mm');
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildMetadataRow(
              'Generated',
              dateFormat.format(widget.report.generatedAt),
              Icons.access_time,
            ),
            const SizedBox(height: 8),
            _buildMetadataRow(
              'Last Updated',
              dateFormat.format(widget.report.lastUpdatedAt),
              Icons.update,
            ),
            const SizedBox(height: 8),
            _buildMetadataRow(
              'Period',
              '${widget.report.daysInPeriod} days',
              Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

