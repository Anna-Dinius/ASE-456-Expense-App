class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
  });

  factory Transaction.fromMap(Map<String, dynamic> data, String documentId) {
    return Transaction(
      id: documentId,
      title: data['title'],
      amount: (data['amount']),
      date: (data['date']).toDate()
    );
  }
}
