import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:p5_expense/service/analytics_service.dart';
import 'package:p5_expense/service/category_service.dart';
import 'package:p5_expense/service/budget_service.dart';
import 'package:p5_expense/model/category.dart';
import 'package:p5_expense/model/budget.dart';
import 'package:p5_expense/model/report.dart';
import 'package:p5_expense/model/transaction.dart';
import 'package:p5_expense/view/chart_pie.dart';
import 'package:intl/intl.dart';

/// Screen for displaying comprehensive expense charts and visualizations
/// Integrates with AnalyticsService to provide dynamic, data-driven charts
class ChartsOverviewScreen extends StatefulWidget {
  const ChartsOverviewScreen({super.key});

  @override
  State<ChartsOverviewScreen> createState() => _ChartsOverviewScreenState();
}

class _ChartsOverviewScreenState extends State<ChartsOverviewScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  List<Category> _categories = [];
  String? _errorMessage;
  String? _selectedBudgetId; // For budget-specific filtering
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  // Date range presets
  static const List<Map<String, dynamic>> _dateRangePresets = [
    {'label': 'Last 7 Days', 'days': 7},
    {'label': 'Last 30 Days', 'days': 30},
    {'label': 'This Month', 'days': null},
    {'label': 'Last 3 Months', 'days': 90},
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final categories = await CategoryService.getAllCategories(user.uid);
      if (mounted) {
        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load categories: $e';
        });
      }
    }
  }

  void _selectDateRange(int presetIndex) {
    final preset = _dateRangePresets[presetIndex];
    final now = DateTime.now();
    
    setState(() {
      if (preset['days'] != null) {
        _startDate = now.subtract(Duration(days: preset['days'] as int));
        _endDate = now;
      } else {
        // "This Month" preset
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
      }
    });
  }

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();
    final startDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (startDate == null) return;

    final endDate = await showDatePicker(
      context: context,
      initialDate: _endDate.isAfter(startDate) ? _endDate : startDate,
      firstDate: startDate,
      lastDate: now,
    );
    if (endDate == null) return;

    setState(() {
      _startDate = startDate;
      _endDate = endDate;
    });
  }

  String get _dateRangeLabel {
    final startFormat = DateFormat('MMM d');
    final endFormat = DateFormat('MMM d, yyyy');
    return '${startFormat.format(_startDate)} - ${endFormat.format(_endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Charts')),
        body: const Center(child: Text('Please sign in to view charts')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Charts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectCustomDateRange,
            tooltip: 'Select Custom Date Range',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date range selector and budget filter
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date Range: $_dateRangeLabel',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    _dateRangePresets.length,
                    (index) => FilterChip(
                      label: Text(_dateRangePresets[index]['label'] as String),
                      selected: _isPresetSelected(index),
                      onSelected: (_) => _selectDateRange(index),
                    ),
                  ),
                ),
                // Budget Filter
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildBudgetFilter(user.uid),
                ),
              ],
            ),
          ),
          
          // Charts content
          Expanded(
            child: _buildChartsContent(user.uid),
          ),
        ],
      ),
    );
  }

  bool _isPresetSelected(int index) {
    final preset = _dateRangePresets[index];
    final now = DateTime.now();
    
    if (preset['days'] != null) {
      final expectedStart = now.subtract(Duration(days: preset['days'] as int));
      return _startDate.year == expectedStart.year &&
          _startDate.month == expectedStart.month &&
          _startDate.day == expectedStart.day &&
          _endDate.year == now.year &&
          _endDate.month == now.month &&
          _endDate.day == now.day;
    } else {
      // "This Month" preset
      final monthStart = DateTime(now.year, now.month, 1);
      return _startDate.year == monthStart.year &&
          _startDate.month == monthStart.month &&
          _startDate.day == monthStart.day &&
          _endDate.year == now.year &&
          _endDate.month == now.month &&
          _endDate.day == now.day;
    }
  }

  Widget _buildChartsContent(String userId) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => _errorMessage = null);
                _loadCategories();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Use StreamBuilder for real-time updates when transactions change
    // Stream listens to transaction changes and triggers chart data reload
    return StreamBuilder<firestore.QuerySnapshot>(
      stream: firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: _startDate)
          .where('date', isLessThanOrEqualTo: _endDate)
          .snapshots(),
      builder: (context, streamSnapshot) {
        // Create a unique key from stream data to force FutureBuilder reload when transactions change
        // This ensures charts update automatically when new transactions are added
        final transactionCount = streamSnapshot.hasData ? streamSnapshot.data!.docs.length : 0;
        final streamKey = '${_startDate.millisecondsSinceEpoch}_${_endDate.millisecondsSinceEpoch}_$transactionCount';
        
        // When transactions change, reload chart data
        return FutureBuilder<Map<String, dynamic>>(
          key: ValueKey(streamKey), // Key changes when stream updates, forcing reload
          future: _loadChartData(userId),
          builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading chart data: ${snapshot.error}',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        final data = snapshot.data!;
        final categoryAnalysis = data['categoryAnalysis'] as Map<String, Map<String, dynamic>>;
        final spendingTrends = data['spendingTrends'] as Map<DateTime, double>;
        final budgetPerformance = data['budgetPerformance'] as BudgetPerformance?;

        // Check if we have data
        if (categoryAnalysis.isEmpty && spendingTrends.isEmpty && budgetPerformance == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No transactions in this period',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add some transactions to see charts',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          key: _refreshKey,
          onRefresh: () async {
            // Reload categories and trigger data refresh
            await _loadCategories();
            setState(() {
              // Trigger rebuild to reload chart data
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Required for RefreshIndicator
            child: Column(
              children: [
                // Category Pie Chart
                if (categoryAnalysis.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CategoryPieChart(
                      categoryAnalysis: categoryAnalysis,
                      categories: _categories,
                      startDate: _startDate,
                      endDate: _endDate,
                    ),
                  ),

                // Spending Trends Bar Chart
                if (spendingTrends.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SpendingTrendsChart(
                      spendingTrends: spendingTrends,
                      startDate: _startDate,
                      endDate: _endDate,
                    ),
                  ),

                // Budget Progress Chart
                if (budgetPerformance != null && budgetPerformance.totalBudgetAmount > 0)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: BudgetProgressChart(
                      budgetPerformance: budgetPerformance,
                      categories: _categories,
                    ),
                  ),
              ],
            ),
          ),
        );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadChartData(String userId) async {
    try {
      // Apply budget filter if selected
      String? categoryFilter;
      if (_selectedBudgetId != null) {
        final budgets = await BudgetService.getAllBudgets(userId);
        final selectedBudget = budgets.firstWhere(
          (b) => b.id == _selectedBudgetId,
          orElse: () => budgets.first,
        );
        categoryFilter = selectedBudget.categoryId;
      }

      final categoryAnalysis = await AnalyticsService.calculateCategoryAnalysis(
        userId: userId,
        startDate: _startDate,
        endDate: _endDate,
      );

      // Filter category analysis if budget filter is applied
      final filteredCategoryAnalysis = categoryFilter != null
          ? {
              categoryFilter: categoryAnalysis[categoryFilter] ?? {
                'amount': 0.0,
                'percentage': 0.0,
                'transactionCount': 0,
              }
            }
          : categoryAnalysis;

      final spendingTrends = await AnalyticsService.calculateSpendingTrends(
        userId: userId,
        startDate: _startDate,
        endDate: _endDate,
        categoryId: categoryFilter,
      );

      // Load budget performance
      BudgetPerformance? budgetPerformance;
      try {
        final budgets = await BudgetService.getAllBudgets(userId);
        final activeBudgets = budgets.where((b) => b.isActive).toList();
        
        if (activeBudgets.isNotEmpty) {
          // Get transactions in period for budget calculation
          final transactions = await _getTransactionsInPeriod(userId);
          
          budgetPerformance = await AnalyticsService.calculateBudgetPerformance(
            userId: userId,
            budgets: activeBudgets,
            transactions: transactions,
            startDate: _startDate,
            endDate: _endDate,
          );
        }
      } catch (e) {
        print('Error loading budget performance: $e');
        // Continue without budget performance if there's an error
      }

      return {
        'categoryAnalysis': filteredCategoryAnalysis,
        'spendingTrends': spendingTrends,
        'budgetPerformance': budgetPerformance,
      };
    } catch (e) {
      throw Exception('Failed to load chart data: $e');
    }
  }

  /// Helper method to get transactions in period
  /// This duplicates logic from AnalyticsService but is needed for budget calculation
  Future<List<Transaction>> _getTransactionsInPeriod(String userId) async {
    try {
      final snapshot = await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: _startDate)
          .where('date', isLessThanOrEqualTo: _endDate)
          .get();

      return snapshot.docs
          .map((doc) => Transaction.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }


  /// Build budget filter widget
  Widget _buildBudgetFilter(String userId) {
    return FutureBuilder<List<Budget>>(
      future: BudgetService.getAllBudgets(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final budgets = snapshot.data!;
        final activeBudgets = budgets.where((b) => b.isActive).toList();

        if (activeBudgets.isEmpty && _selectedBudgetId == null) {
          return const SizedBox.shrink();
        }

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.filter_list, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Filter by Budget',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedBudgetId,
                  decoration: const InputDecoration(
                    labelText: 'Select Budget',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Budgets'),
                    ),
                    ...activeBudgets.map((budget) {
                      return DropdownMenuItem<String>(
                        value: budget.id,
                        child: Text(budget.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedBudgetId = value;
                    });
                  },
                ),
                if (_selectedBudgetId != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedBudgetId = null;
                      });
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear Filter'),
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

/// Widget for displaying category distribution as a pie chart
class CategoryPieChart extends StatelessWidget {
  final Map<String, Map<String, dynamic>> categoryAnalysis;
  final List<Category> categories;
  final DateTime startDate;
  final DateTime endDate;

  const CategoryPieChart({
    super.key,
    required this.categoryAnalysis,
    required this.categories,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Center the pie chart
            Center(
              child: ChartPie(
                categoryAnalysis: categoryAnalysis,
                categories: categories,
              ),
            ),
            const SizedBox(height: 16),
            // Category legend
            _buildCategoryLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryLegend() {
    final sortedEntries = categoryAnalysis.entries.toList()
      ..sort((a, b) => (b.value['amount'] as double).compareTo(a.value['amount'] as double));

    if (sortedEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: sortedEntries.map((entry) {
        final categoryId = entry.key;
        final data = entry.value;
        final amount = data['amount'] as double;
        final percentage = data['percentage'] as double;
        final category = categories.firstWhere(
          (c) => c.id == categoryId,
          orElse: () => Category(
            id: categoryId,
            title: categoryId,
            color: Colors.grey,
            icon: Icons.category,
          ),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: category.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
              const SizedBox(width: 10),
              Icon(category.icon, size: 20, color: category.color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  category.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Widget for displaying spending trends over time as a bar chart
class SpendingTrendsChart extends StatelessWidget {
  final Map<DateTime, double> spendingTrends;
  final DateTime startDate;
  final DateTime endDate;

  const SpendingTrendsChart({
    super.key,
    required this.spendingTrends,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    // Sort trends by date
    final sortedTrends = spendingTrends.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (sortedTrends.isEmpty) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No spending trends',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add transactions to see spending patterns',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final maxAmount = sortedTrends.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final totalSpending = sortedTrends.map((e) => e.value).fold(0.0, (a, b) => a + b);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Trends',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Total: \$${totalSpending.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                // Make chart responsive - adjust height based on available space
                final chartHeight = constraints.maxHeight > 0 
                    ? math.min(constraints.maxHeight - 100.0, 250.0)
                    : 200.0;
                
                return SizedBox(
                  height: chartHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: sortedTrends.map((entry) {
                  final heightFactor = maxAmount > 0 ? entry.value / maxAmount : 0.0;
                  final dateFormat = DateFormat('MMM d');
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '\$${entry.value.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: FractionallySizedBox(
                              heightFactor: heightFactor,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormat.format(entry.key),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying budget performance and progress
class BudgetProgressChart extends StatelessWidget {
  final BudgetPerformance budgetPerformance;
  final List<Category> categories;

  const BudgetProgressChart({
    super.key,
    required this.budgetPerformance,
    required this.categories,
  });

  Color _getUtilizationColor(double utilization) {
    if (utilization >= 1.0) return Colors.red;
    if (utilization >= 0.9) return Colors.orange;
    if (utilization >= 0.75) return Colors.amber;
    return Colors.green;
  }

  String _getUtilizationStatus(double utilization) {
    if (utilization >= 1.0) return 'Exceeded';
    if (utilization >= 0.9) return 'Almost Limit';
    if (utilization >= 0.75) return 'Getting Close';
    return 'On Track';
  }

  @override
  Widget build(BuildContext context) {
    final utilization = budgetPerformance.utilizationPercentage;
    final utilizationColor = _getUtilizationColor(utilization);
    final status = _getUtilizationStatus(utilization);
    final remaining = budgetPerformance.totalBudgetAmount - budgetPerformance.totalSpentAgainstBudgets;

    return Card(
      elevation: 4,
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

            // Overall Budget Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Budget',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: utilizationColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: utilizationColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: utilizationColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: utilization.clamp(0.0, 1.0),
                    minHeight: 16,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(utilizationColor),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget: \$${budgetPerformance.totalBudgetAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Spent: \$${budgetPerformance.totalSpentAgainstBudgets.toStringAsFixed(2)}',
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
                          remaining >= 0
                              ? 'Remaining: \$${remaining.toStringAsFixed(2)}'
                              : 'Over by: \$${(-remaining).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: remaining >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(utilization * 100).toStringAsFixed(1)}% used',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // Budget Summary
            if (budgetPerformance.exceededBudgets > 0 ||
                budgetPerformance.metBudgets > 0 ||
                budgetPerformance.underUtilizedBudgets > 0) ...[
              const SizedBox(height: 24),
              Divider(height: 1),
              const SizedBox(height: 16),
              Text(
                'Budget Summary',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Exceeded',
                    budgetPerformance.exceededBudgets.toString(),
                    Colors.red,
                  ),
                  _buildSummaryItem(
                    'Met',
                    budgetPerformance.metBudgets.toString(),
                    Colors.orange,
                  ),
                  _buildSummaryItem(
                    'On Track',
                    budgetPerformance.underUtilizedBudgets.toString(),
                    Colors.green,
                  ),
                ],
              ),
            ],

            // Category Performance
            if (budgetPerformance.categoryPerformance.isNotEmpty) ...[
              const SizedBox(height: 24),
              Divider(height: 1),
              const SizedBox(height: 16),
              Text(
                'Category Budgets',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...budgetPerformance.categoryPerformance.entries.map((entry) {
                final categoryId = entry.key;
                final categoryUtilization = entry.value;
                final category = categories.firstWhere(
                  (c) => c.id == categoryId,
                  orElse: () => Category(
                    id: categoryId,
                    title: categoryId,
                    color: Colors.grey,
                    icon: Icons.category,
                  ),
                );
                final catColor = _getUtilizationColor(categoryUtilization);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(category.icon, size: 20, color: category.color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              category.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${(categoryUtilization * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: catColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: categoryUtilization.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(catColor),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
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
}

