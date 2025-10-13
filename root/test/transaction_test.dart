import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:p5_expense/model/transaction.dart';

void main() {
  group('Transaction Model', () {
    final now = DateTime.now();

    test('toJson and fromJson should be symmetric', () {
      final txn = Transaction(
        id: 't1',
        title: 'Lunch',
        amount: 15.75,
        date: now,
        categoryId: 'food',
        recurring: true,
        interval: 'weekly',
        pastPayments: [now.subtract(Duration(days: 7))],
        futurePayments: [now.add(Duration(days: 7))],
      );

      final json = txn.toJson();
      final from = Transaction.fromJson(json);

      expect(from.id, txn.id);
      expect(from.title, txn.title);
      expect(from.amount, txn.amount);
      expect(from.date, txn.date);
      expect(from.categoryId, txn.categoryId);
      expect(from.recurring, txn.recurring);
      expect(from.interval, txn.interval);
      expect(from.pastPayments.first, txn.pastPayments.first);
      expect(from.futurePayments.first, txn.futurePayments.first);
    });

    test('copyWith should correctly replace fields', () {
      final txn = Transaction(
        id: 't1',
        title: 'Coffee',
        amount: 4.50,
        date: now,
        categoryId: 'beverages',
        recurring: false,
        interval: '',
      );

      final updated = txn.copyWith(amount: 5.00, recurring: true);

      expect(updated.amount, 5.00);
      expect(updated.recurring, true);
      expect(updated.title, txn.title); // unchanged
    });

    test('equality and hashCode should match for identical data', () {
      final txn1 = Transaction(
        id: '1',
        title: 'Dinner',
        amount: 20.0,
        date: now,
        categoryId: 'food',
        recurring: false,
        interval: '',
      );

      final txn2 = Transaction(
        id: '1',
        title: 'Dinner',
        amount: 20.0,
        date: now,
        categoryId: 'food',
        recurring: false,
        interval: '',
      );

      expect(txn1, txn2);
      expect(txn1.hashCode, txn2.hashCode);
    });

    test('toMap and fromMap should work correctly', () {
      final data = {
        'title': 'Gym',
        'amount': 50.0,
        'date': firestore.Timestamp.fromDate(now),
        'categoryId': 'fitness',
        'recurring': true,
        'interval': 'monthly',
        'pastPayments': [firestore.Timestamp.fromDate(now.subtract(Duration(days: 30)))],
        'futurePayments': [firestore.Timestamp.fromDate(now.add(Duration(days: 30)))],
      };

      final txn = Transaction.fromMap(data, 'doc123');

      expect(txn.id, 'doc123');
      expect(txn.title, 'Gym');
      expect(txn.amount, 50.0);
      expect(txn.categoryId, 'fitness');
      expect(txn.recurring, true);
      expect(txn.interval, 'monthly');

      final map = txn.toMap();
      expect(map['title'], 'Gym');
      expect(map['recurring'], true);
      expect(map['interval'], 'monthly');
    });
  });
}
