import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:p5_expense/model/category.dart';

/// Widget that displays a pie chart for category distribution
/// Uses native Flutter CustomPaint for rendering
class ChartPie extends StatelessWidget {
  final Map<String, Map<String, dynamic>> categoryAnalysis;
  final List<Category> categories;

  const ChartPie({
    super.key,
    required this.categoryAnalysis,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryAnalysis.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No data to display'),
        ),
      );
    }

    return SizedBox(
      height: 250,
      width: 250,
      child: CustomPaint(
        painter: _PieChartPainter(
          categoryAnalysis: categoryAnalysis,
          categories: categories,
        ),
      ),
    );
  }
}

/// Custom painter for drawing the pie chart
class _PieChartPainter extends CustomPainter {
  final Map<String, Map<String, dynamic>> categoryAnalysis;
  final List<Category> categories;

  _PieChartPainter({
    required this.categoryAnalysis,
    required this.categories,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Calculate total amount
    final totalAmount = categoryAnalysis.values.fold<double>(
      0.0,
      (sum, data) => sum + (data['amount'] as double),
    );

    if (totalAmount == 0) {
      // Draw empty circle
      final paint = Paint()
        ..color = Colors.grey[300]!
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    // Sort entries by amount (descending) for better visual order
    final sortedEntries = categoryAnalysis.entries.toList()
      ..sort((a, b) => (b.value['amount'] as double).compareTo(a.value['amount'] as double));

    double startAngle = -math.pi / 2; // Start from top

    for (final entry in sortedEntries) {
      final categoryId = entry.key;
      final amount = entry.value['amount'] as double;
      final sweepAngle = (amount / totalAmount) * 2 * math.pi;

      // Get category color
      final category = categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => Category(
          id: categoryId,
          title: categoryId,
          color: Colors.grey,
          icon: Icons.category,
        ),
      );

      // Draw pie slice
      final paint = Paint()
        ..color = category.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw separator line between slices (optional, for better visibility)
      if (sweepAngle > 0.1) {
        final separatorPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        
        final x1 = center.dx + radius * math.cos(startAngle);
        final y1 = center.dy + radius * math.sin(startAngle);
        canvas.drawLine(center, Offset(x1, y1), separatorPaint);
      }

      startAngle += sweepAngle;
    }

    // Draw center circle for donut chart effect (optional)
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.4, centerPaint);
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) {
    return categoryAnalysis != oldDelegate.categoryAnalysis ||
        categories != oldDelegate.categories;
  }
}

