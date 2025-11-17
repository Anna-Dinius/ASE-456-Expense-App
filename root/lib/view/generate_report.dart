import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:p5_expense/service/analytics_service.dart';
import 'package:p5_expense/service/report_service.dart';
import 'package:p5_expense/model/report.dart';
import 'package:intl/intl.dart';

/// Screen for generating financial reports
/// Allows users to select date ranges and generate reports with analytics data
class GenerateReportScreen extends StatefulWidget {
  const GenerateReportScreen({super.key});

  @override
  State<GenerateReportScreen> createState() => _GenerateReportScreenState();
}

class _GenerateReportScreenState extends State<GenerateReportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  bool _isGenerating = false;
  String? _errorMessage;
  Report? _generatedReport;

  // Date range presets
  static const List<Map<String, dynamic>> _dateRangePresets = [
    {'label': 'Last 7 Days', 'days': 7},
    {'label': 'Last 30 Days', 'days': 30},
    {'label': 'This Month', 'days': null},
    {'label': 'Last 3 Months', 'days': 90},
  ];

  String get _dateRangeLabel {
    final startFormat = DateFormat('MMM d, yyyy');
    final endFormat = DateFormat('MMM d, yyyy');
    return '${startFormat.format(_startDate)} - ${endFormat.format(_endDate)}';
  }

  String get _periodLabel {
    final days = _endDate.difference(_startDate).inDays;
    if (days <= 7) {
      return 'Weekly';
    } else if (days <= 31) {
      return 'Monthly';
    } else {
      return 'Custom';
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
      _generatedReport = null; // Clear previous report
      _errorMessage = null;
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
      _generatedReport = null; // Clear previous report
      _errorMessage = null;
    });
  }

  Future<void> _generateReport() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Please sign in to generate reports';
      });
      return;
    }

    // Validate date range
    if (_startDate.isAfter(_endDate)) {
      setState(() {
        _errorMessage = 'Start date must be before end date';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generatedReport = null;
    });

    try {
      // Generate period label
      final period = _periodLabel == 'Custom' 
          ? _dateRangeLabel 
          : '$_periodLabel Report - ${DateFormat('MMM yyyy').format(_startDate)}';

      // Generate report using AnalyticsService
      final report = await AnalyticsService.generateReport(
        userId: user.uid,
        startDate: _startDate,
        endDate: _endDate,
        period: period,
      );

      if (mounted) {
        setState(() {
          _generatedReport = report;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error generating report: $e';
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _saveReport() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null || _generatedReport == null) return;

    try {
      setState(() {
        _isGenerating = true;
      });

      // Save report to Firestore
      final savedReport = await ReportService.saveReport(
        userId: user.uid,
        report: _generatedReport!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Update report with saved ID
        setState(() {
          _generatedReport = savedReport;
          _isGenerating = false;
        });

        // Navigate back to reports list after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate report was saved
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error saving report: $e';
          _isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Generate Report')),
        body: const Center(child: Text('Please sign in to generate reports')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Report'),
        actions: [
          if (_generatedReport != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isGenerating ? null : _saveReport,
              tooltip: 'Save Report',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date range selection
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date Range',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _dateRangeLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _selectCustomDateRange,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Select Custom Range'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Generate button
            ElevatedButton(
              onPressed: _isGenerating ? null : _generateReport,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isGenerating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Generate Report'),
            ),

            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Generated report preview
            if (_generatedReport != null) ...[
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Report Generated',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Icon(Icons.check_circle, color: Colors.green[600]),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildReportMetric(
                        'Period',
                        _generatedReport!.period,
                        Icons.calendar_today,
                      ),
                      const Divider(),
                      _buildReportMetric(
                        'Total Spent',
                        '\$${_generatedReport!.totalSpent.toStringAsFixed(2)}',
                        Icons.attach_money,
                      ),
                      const Divider(),
                      _buildReportMetric(
                        'Transactions',
                        _generatedReport!.transactionCount.toString(),
                        Icons.receipt,
                      ),
                      const Divider(),
                      _buildReportMetric(
                        'Average Daily',
                        '\$${_generatedReport!.averageDailySpending.toStringAsFixed(2)}',
                        Icons.trending_up,
                      ),
                      const Divider(),
                      _buildReportMetric(
                        'Budget Utilization',
                        '${(_generatedReport!.budgetPerformance.utilizationPercentage * 100).toStringAsFixed(1)}%',
                        Icons.pie_chart,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _saveReport,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Report'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
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

  Widget _buildReportMetric(String label, String value, IconData icon) {
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
}

