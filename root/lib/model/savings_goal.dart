import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String? description;
  final bool completed;

  const SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.targetDate,
    this.description,
    this.completed = false,
  });

  double get progress {
    if (targetAmount <= 0) return 0.0;
    final p = currentAmount / targetAmount;
    return p.clamp(0.0, 1.0);
  }

  SavingsGoal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? description,
    bool? completed,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      description: description ?? this.description,
      completed: completed ?? this.completed,
    );
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> data, String documentId) {
    return SavingsGoal(
      id: documentId,
      title: data['title'] as String,
      targetAmount: (data['targetAmount'] as num).toDouble(),
      currentAmount: (data['currentAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: data['targetDate'] is Timestamp
          ? (data['targetDate'] as Timestamp).toDate()
          : data['targetDate'] as DateTime?,
      description: data['description'] as String?,
      completed: (data['completed'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate,
      'description': description,
      'completed': completed,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavingsGoal &&
        other.id == id &&
        other.title == title &&
        other.targetAmount == targetAmount &&
        other.currentAmount == currentAmount &&
        other.targetDate == targetDate &&
        other.description == description &&
        other.completed == completed;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      targetAmount.hashCode ^
      currentAmount.hashCode ^
      targetDate.hashCode ^
      (description?.hashCode ?? 0) ^
      completed.hashCode;
}