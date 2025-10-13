import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart' as FakeFirestore;
import 'package:p5_expense/service/update_transaction_service.dart'; // adjust import path to include updateRecurringTransactions

void main() {
  group('TransactionService.updateRecurringTransactions', () {
    late FakeFirestore.FakeFirebaseFirestore firestore;
    late TransactionService service;
    late String userId;

    setUp(() async {
      firestore = FakeFirestore.FakeFirebaseFirestore();
      service = TransactionService(firestore: firestore);
      userId = 'user_1';

      final now = DateTime.now();
      final pastDue = now.subtract(const Duration(days: 1));
      final upcoming = now.add(const Duration(days: 5));

      await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .add({
        'title': 'Netflix',
        'amount': 15.0,
        'date': Timestamp.fromDate(now),
        'recurring': true,
        'interval': 'monthly',
        'pastPayments': [],
        'futurePayments': [
          Timestamp.fromDate(pastDue),
          Timestamp.fromDate(upcoming)
        ],
      });
    });

    test('moves due future payments to pastPayments', () async {
      await service.updateRecurringTransactions(userId);

      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();
      final data = snapshot.docs.first.data();

      final pastPayments = (data['pastPayments'] as List)
          .map((e) => (e as Timestamp).toDate())
          .toList();
      final futurePayments = (data['futurePayments'] as List)
          .map((e) => (e as Timestamp).toDate())
          .toList();

      expect(pastPayments.length, 1);
      expect(futurePayments.length, 1);
    });
  });
}
