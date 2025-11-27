import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransactionService {
  final FirebaseFirestore firestore;

  TransactionService({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> updateRecurringTransactions(String userId) async {
    final today = DateTime.now();
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final pastPayments = (data['pastPayments'] as List<dynamic>? ?? [])
            .map((e) => (e as Timestamp).toDate())
            .toList();
        final futurePayments = (data['futurePayments'] as List<dynamic>? ?? [])
            .map((e) => (e as Timestamp).toDate())
            .toList();

        final duePayments = futurePayments
            .where((p) => _isSameDay(p, today) || p.isBefore(today))
            .toList();

        if (duePayments.isNotEmpty) {
          final latestDue = duePayments.last;
          final updatedPast = [...pastPayments, ...duePayments];
          final updatedFuture =
              futurePayments.where((p) => !duePayments.contains(p)).toList();

          await doc.reference.update({
            'date': latestDue,
            'pastPayments': updatedPast,
            'futurePayments': updatedFuture,
          });
        }
      }
    } catch (e) {
      debugPrint('Error updating recurring transactions: $e');
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
