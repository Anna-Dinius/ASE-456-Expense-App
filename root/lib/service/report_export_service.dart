import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:p5_expense/model/report.dart';
import 'package:p5_expense/model/category.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

/// Service for exporting reports to PDF and CSV formats
class ReportExportService {
  /// Exports a report to PDF format
  /// Returns the file path of the generated PDF
  /// Throws an exception if path_provider is not available (app needs rebuild)
  static Future<File> exportToPDF({
    required Report report,
    required List<Category> categories,
  }) async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('MMM d, yyyy');
      final currencyFormat = NumberFormat.currency(symbol: '\$');

      // Build PDF content
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Header
              _buildHeader(report, dateFormat),
              pw.SizedBox(height: 20),

              // Summary Section
              _buildSummarySection(report, currencyFormat),
              pw.SizedBox(height: 20),

              // Spending Metrics
              _buildSpendingMetrics(report, currencyFormat),
              pw.SizedBox(height: 20),

              // Budget Performance
              if (report.budgetPerformance.totalBudgetAmount > 0)
                _buildBudgetPerformance(report, currencyFormat),
              if (report.budgetPerformance.totalBudgetAmount > 0)
                pw.SizedBox(height: 20),

              // Category Breakdown
              if (report.categoryBreakdown.isNotEmpty)
                _buildCategoryBreakdown(report, categories, currencyFormat),
              if (report.categoryBreakdown.isNotEmpty) pw.SizedBox(height: 20),

              // Recurring Transactions
              if (report.recurringTransactionImpact.recurringTransactionCount >
                  0)
                _buildRecurringTransactions(report, currencyFormat),
              if (report.recurringTransactionImpact.recurringTransactionCount >
                  0)
                pw.SizedBox(height: 20),

              // Footer
              _buildFooter(report, dateFormat),
            ];
          },
        ),
      );

      // Save PDF to file
      final pdfBytes = await pdf.save();

      if (kIsWeb) {
        // Web platform: trigger browser download directly
        final dateFormat = DateFormat('yyyy-MM-dd');
        final fileName =
            'report_${report.period.replaceAll(' ', '_')}_${dateFormat.format(report.startDate)}.pdf';
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);

        // Web platform uses browser download, throw UnsupportedError
        throw UnsupportedError('Web platform uses browser download');
      } else {
        // Mobile/Desktop platform: save to file system
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            'report_${report.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes);
        return file;
      }
    } catch (e) {
      if (e.toString().contains('MissingPluginException') ||
          e.toString().contains('getApplicationDocumentsDirectory')) {
        throw Exception(
            'Plugin not registered. Please stop the app completely and rebuild it.\n'
            'Run: flutter clean && flutter pub get && flutter run');
      }
      rethrow;
    }
  }

  /// Exports a report to CSV format
  /// Returns the file path of the generated CSV
  /// Throws an exception if path_provider is not available (app needs rebuild)
  static Future<File> exportToCSV({
    required Report report,
    required List<Category> categories,
  }) async {
    try {
      final dateFormat = DateFormat('yyyy-MM-dd');
      final csv = StringBuffer();

      // Header
      csv.writeln('Expense Report - ${report.period}');
      csv.writeln('Generated: ${dateFormat.format(report.generatedAt)}');
      csv.writeln(
          'Period: ${dateFormat.format(report.startDate)} to ${dateFormat.format(report.endDate)}');
      csv.writeln('');

      // Summary
      csv.writeln('SUMMARY');
      csv.writeln('Total Spent,${report.totalSpent.toStringAsFixed(2)}');
      csv.writeln('Transactions,${report.transactionCount}');
      csv.writeln(
          'Average Daily,${report.averageDailySpending.toStringAsFixed(2)}');
      csv.writeln(
          'Average Weekly,${report.averageWeeklySpending.toStringAsFixed(2)}');
      csv.writeln(
          'Average Monthly,${report.averageMonthlySpending.toStringAsFixed(2)}');
      csv.writeln('');

      // Budget Performance
      if (report.budgetPerformance.totalBudgetAmount > 0) {
        csv.writeln('BUDGET PERFORMANCE');
        csv.writeln(
            'Total Budget,${report.budgetPerformance.totalBudgetAmount.toStringAsFixed(2)}');
        csv.writeln(
            'Total Spent,${report.budgetPerformance.totalSpentAgainstBudgets.toStringAsFixed(2)}');
        csv.writeln(
            'Utilization %,${(report.budgetPerformance.utilizationPercentage * 100).toStringAsFixed(1)}');
        csv.writeln(
            'Exceeded Budgets,${report.budgetPerformance.exceededBudgets}');
        csv.writeln('Met Budgets,${report.budgetPerformance.metBudgets}');
        csv.writeln(
            'On Track Budgets,${report.budgetPerformance.underUtilizedBudgets}');
        csv.writeln('');
      }

      // Category Breakdown
      if (report.categoryBreakdown.isNotEmpty) {
        csv.writeln('CATEGORY BREAKDOWN');
        csv.writeln('Category,Amount,Percentage');
        final sortedCategories = report.categoryBreakdown.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        for (final entry in sortedCategories) {
          final categoryId = entry.key;
          final amount = entry.value;
          final percentage =
              report.totalSpent > 0 ? (amount / report.totalSpent) * 100 : 0.0;

          final category = categories.firstWhere(
            (c) => c.id == categoryId,
            orElse: () => Category(
              id: categoryId,
              title: categoryId,
              color: const Color(0xFF9E9E9E), // Grey color
              icon: Icons.category,
            ),
          );

          csv.writeln(
              '${category.title},${amount.toStringAsFixed(2)},${percentage.toStringAsFixed(1)}%');
        }
        csv.writeln('');
      }

      // Recurring Transactions
      if (report.recurringTransactionImpact.recurringTransactionCount > 0) {
        csv.writeln('RECURRING TRANSACTIONS');
        csv.writeln(
            'Total Recurring,${report.recurringTransactionImpact.totalRecurringAmount.toStringAsFixed(2)}');
        csv.writeln(
            'Recurring Count,${report.recurringTransactionImpact.recurringTransactionCount}');
        csv.writeln(
            'Percentage of Total,${(report.recurringTransactionImpact.recurringPercentage * 100).toStringAsFixed(1)}%');
        csv.writeln('');
      }

      // Save CSV to file
      final csvContent = csv.toString();

      if (kIsWeb) {
        // Web platform: trigger browser download directly
        final dateFormat = DateFormat('yyyy-MM-dd');
        final fileName =
            'report_${report.period.replaceAll(' ', '_')}_${dateFormat.format(report.startDate)}.csv';
        final blob = html.Blob([csvContent]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);

        // Web platform uses browser download, throw UnsupportedError
        throw UnsupportedError('Web platform uses browser download');
      } else {
        // Mobile/Desktop platform: save to file system
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            'report_${report.id}_${DateTime.now().millisecondsSinceEpoch}.csv';
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsString(csvContent);
        return file;
      }
    } catch (e) {
      if (e.toString().contains('MissingPluginException') ||
          e.toString().contains('getApplicationDocumentsDirectory')) {
        throw Exception(
            'Plugin not registered. Please stop the app completely and rebuild it.\n'
            'Run: flutter clean && flutter pub get && flutter run');
      }
      rethrow;
    }
  }

  /// Shares a file using the platform's share functionality
  /// On web, this triggers a download instead
  static Future<void> shareFile(File file, String fileName) async {
    if (kIsWeb) {
      // On web, file download is already handled in exportToPDF/exportToCSV
      // This method is called but file doesn't exist on web
      return;
    } else {
      final xFile = XFile(file.path, name: fileName);
      await Share.shareXFiles([xFile], text: 'Expense Report: $fileName');
    }
  }

  /// Shares a PDF file and allows printing
  static Future<void> sharePDF(Report report, List<Category> categories) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMM d, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            _buildHeader(report, dateFormat),
            pw.SizedBox(height: 20),
            _buildSummarySection(report, currencyFormat),
            pw.SizedBox(height: 20),
            _buildSpendingMetrics(report, currencyFormat),
            pw.SizedBox(height: 20),
            if (report.budgetPerformance.totalBudgetAmount > 0)
              _buildBudgetPerformance(report, currencyFormat),
            if (report.budgetPerformance.totalBudgetAmount > 0)
              pw.SizedBox(height: 20),
            if (report.categoryBreakdown.isNotEmpty)
              _buildCategoryBreakdown(report, categories, currencyFormat),
            if (report.categoryBreakdown.isNotEmpty) pw.SizedBox(height: 20),
            if (report.recurringTransactionImpact.recurringTransactionCount > 0)
              _buildRecurringTransactions(report, currencyFormat),
            if (report.recurringTransactionImpact.recurringTransactionCount > 0)
              pw.SizedBox(height: 20),
            _buildFooter(report, dateFormat),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // PDF Building Helpers

  static pw.Widget _buildHeader(Report report, DateFormat dateFormat) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          report.period,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          '${dateFormat.format(report.startDate)} - ${dateFormat.format(report.endDate)}',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
      ],
    );
  }

  static pw.Widget _buildSummarySection(
      Report report, NumberFormat currencyFormat) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Total Spent',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  currencyFormat.format(report.totalSpent),
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
          pw.Container(
            width: 1,
            height: 40,
            color: PdfColors.grey300,
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Transactions',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  report.transactionCount.toString(),
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSpendingMetrics(
      Report report, NumberFormat currencyFormat) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Spending Averages',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Daily Average:'),
            pw.Text(currencyFormat.format(report.averageDailySpending)),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Weekly Average:'),
            pw.Text(currencyFormat.format(report.averageWeeklySpending)),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Monthly Average:'),
            pw.Text(currencyFormat.format(report.averageMonthlySpending)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildBudgetPerformance(
      Report report, NumberFormat currencyFormat) {
    final bp = report.budgetPerformance;
    final utilization = bp.utilizationPercentage;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Budget Performance',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total Budget:'),
            pw.Text(currencyFormat.format(bp.totalBudgetAmount)),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total Spent:'),
            pw.Text(currencyFormat.format(bp.totalSpentAgainstBudgets)),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Utilization:'),
            pw.Text('${(utilization * 100).toStringAsFixed(1)}%'),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            pw.Column(
              children: [
                pw.Text(
                  bp.exceededBudgets.toString(),
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('Exceeded', style: pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.Column(
              children: [
                pw.Text(
                  bp.metBudgets.toString(),
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('Met', style: pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.Column(
              children: [
                pw.Text(
                  bp.underUtilizedBudgets.toString(),
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('On Track', style: pw.TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildCategoryBreakdown(
    Report report,
    List<Category> categories,
    NumberFormat currencyFormat,
  ) {
    final sortedCategories = report.categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Category Breakdown',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Category',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Amount',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Percentage',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            ...sortedCategories.map((entry) {
              final categoryId = entry.key;
              final amount = entry.value;
              final percentage = report.totalSpent > 0
                  ? (amount / report.totalSpent) * 100
                  : 0.0;

              final category = categories.firstWhere(
                (c) => c.id == categoryId,
                orElse: () => Category(
                  id: categoryId,
                  title: categoryId,
                  color: const Color(0xFF9E9E9E), // Grey color
                  icon: Icons.category,
                ),
              );

              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(category.title),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(currencyFormat.format(amount)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('${percentage.toStringAsFixed(1)}%'),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildRecurringTransactions(
      Report report, NumberFormat currencyFormat) {
    final impact = report.recurringTransactionImpact;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Recurring Transactions',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total Recurring:'),
            pw.Text(currencyFormat.format(impact.totalRecurringAmount)),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Recurring Count:'),
            pw.Text(impact.recurringTransactionCount.toString()),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Percentage of Total:'),
            pw.Text(
                '${(impact.recurringPercentage * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(Report report, DateFormat dateFormat) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Report Information',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated: ${dateFormat.format(report.generatedAt)}',
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Last Updated: ${dateFormat.format(report.lastUpdatedAt)}',
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Period: ${report.daysInPeriod} days',
            style: pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
