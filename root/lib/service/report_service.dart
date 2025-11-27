import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:p5_expense/model/report.dart';

/// Service class for managing reports in Firebase Firestore
/// Handles CRUD operations for financial reports
/// Reports are user-specific and stored under each user's subcollection
class ReportService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'reports';

  /// Saves a report to Firestore for a specific user
  /// Returns the saved report with the Firestore-generated ID
  static Future<Report> saveReport({
    required String userId,
    required Report report,
  }) async {
    try {
      // Save to Firestore under user's subcollection
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .add(report.toMap());

      // Return report with the Firestore-generated ID
      return Report(
        id: docRef.id,
        period: report.period,
        startDate: report.startDate,
        endDate: report.endDate,
        totalSpent: report.totalSpent,
        averageDailySpending: report.averageDailySpending,
        averageWeeklySpending: report.averageWeeklySpending,
        averageMonthlySpending: report.averageMonthlySpending,
        budgetPerformance: report.budgetPerformance,
        recurringTransactionImpact: report.recurringTransactionImpact,
        categoryBreakdown: report.categoryBreakdown,
        transactionCount: report.transactionCount,
        generatedAt: report.generatedAt,
        lastUpdatedAt: report.lastUpdatedAt,
      );
    } catch (e) {
      debugPrint('Error saving report: $e');
      rethrow;
    }
  }

  /// Gets all reports from Firestore for a specific user
  /// Returns a list of all reports, ordered by generatedAt descending (newest first)
  static Future<List<Report>> getAllReports(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .orderBy('generatedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Report.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting reports: $e');
      return [];
    }
  }

  /// Gets a specific report by ID for a specific user
  /// Returns null if the report doesn't exist
  static Future<Report?> getReportById(String userId, String reportId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(reportId)
          .get();
      if (doc.exists && doc.data() != null) {
        return Report.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting report by ID: $e');
      return null;
    }
  }

  /// Gets reports within a specific date range for a specific user
  /// Returns reports where the report period overlaps with the given range
  static Future<List<Report>> getReportsInDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get all reports and filter by date range
      final allReports = await getAllReports(userId);
      return allReports.where((report) {
        // Check if report period overlaps with the given range
        return report.startDate.isBefore(endDate) &&
            report.endDate.isAfter(startDate);
      }).toList();
    } catch (e) {
      debugPrint('Error getting reports in date range: $e');
      return [];
    }
  }

  /// Gets the most recent report for a specific user
  /// Returns null if no reports exist
  static Future<Report?> getMostRecentReport(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .orderBy('generatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return Report.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting most recent report: $e');
      return null;
    }
  }

  /// Updates an existing report in Firestore
  /// Updates the lastUpdatedAt timestamp automatically
  /// Returns the updated report or null if the report doesn't exist
  static Future<Report?> updateReport({
    required String userId,
    required String reportId,
    required Report report,
  }) async {
    try {
      // Check if report exists
      final existingReport = await getReportById(userId, reportId);
      if (existingReport == null) {
        throw Exception('Report not found');
      }

      // Update report with new lastUpdatedAt timestamp
      final updatedReport = Report(
        id: reportId,
        period: report.period,
        startDate: report.startDate,
        endDate: report.endDate,
        totalSpent: report.totalSpent,
        averageDailySpending: report.averageDailySpending,
        averageWeeklySpending: report.averageWeeklySpending,
        averageMonthlySpending: report.averageMonthlySpending,
        budgetPerformance: report.budgetPerformance,
        recurringTransactionImpact: report.recurringTransactionImpact,
        categoryBreakdown: report.categoryBreakdown,
        transactionCount: report.transactionCount,
        generatedAt:
            existingReport.generatedAt, // Keep original generation time
        lastUpdatedAt: DateTime.now(), // Update timestamp
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(reportId)
          .update(updatedReport.toMap());

      return updatedReport;
    } catch (e) {
      debugPrint('Error updating report: $e');
      rethrow;
    }
  }

  /// Deletes a report from Firestore for a specific user
  /// Returns true if deletion was successful
  static Future<bool> deleteReport({
    required String userId,
    required String reportId,
  }) async {
    try {
      // Check if report exists
      final existingReport = await getReportById(userId, reportId);
      if (existingReport == null) {
        throw Exception('Report not found');
      }

      // Delete the report from user's subcollection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(reportId)
          .delete();

      debugPrint('Successfully deleted report $reportId');
      return true;
    } catch (e) {
      debugPrint('Error deleting report: $e');
      rethrow;
    }
  }

  /// Gets a stream of reports for real-time updates
  /// Returns a stream that emits reports whenever they change
  static Stream<List<Report>> getReportsStream(String userId) {
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .orderBy('generatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Report.fromMap(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      debugPrint('Error getting reports stream: $e');
      return Stream.value([]);
    }
  }

  /// Gets the count of reports for a specific user
  /// Returns the number of reports
  static Future<int> getReportCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting report count: $e');
      return 0;
    }
  }
}
