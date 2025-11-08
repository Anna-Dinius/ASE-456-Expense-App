import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String? description;
  final bool completed;
  
  // Milestone tracking - tracks which milestones have been reached
  final bool milestone50Reached;
  final bool milestone75Reached;
  final bool milestone100Reached;

  const SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.targetDate,
    this.description,
    this.completed = false,
    this.milestone50Reached = false,
    this.milestone75Reached = false,
    this.milestone100Reached = false,
  });

  double get progress {
    if (targetAmount <= 0) return 0.0;
    final p = currentAmount / targetAmount;
    return p.clamp(0.0, 1.0);
  }

  /// Detects which new milestones have been reached
  /// Returns a list of milestone percentages that were newly achieved
  List<int> detectNewMilestones(SavingsGoal oldGoal) {
    final newMilestones = <int>[];
    
    // Check 50% milestone
    if (!oldGoal.milestone50Reached && progress >= 0.5) {
      newMilestones.add(50);
    }
    
    // Check 75% milestone
    if (!oldGoal.milestone75Reached && progress >= 0.75) {
      newMilestones.add(75);
    }
    
    // Check 100% milestone
    if (!oldGoal.milestone100Reached && progress >= 1.0) {
      newMilestones.add(100);
    }
    
    return newMilestones;
  }

  /// Updates milestone flags based on current progress
  SavingsGoal updateMilestones() {
    return copyWith(
      milestone50Reached: milestone50Reached || progress >= 0.5,
      milestone75Reached: milestone75Reached || progress >= 0.75,
      milestone100Reached: milestone100Reached || progress >= 1.0,
    );
  }

  SavingsGoal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? description,
    bool? completed,
    bool? milestone50Reached,
    bool? milestone75Reached,
    bool? milestone100Reached,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      milestone50Reached: milestone50Reached ?? this.milestone50Reached,
      milestone75Reached: milestone75Reached ?? this.milestone75Reached,
      milestone100Reached: milestone100Reached ?? this.milestone100Reached,
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
      milestone50Reached: (data['milestone50Reached'] as bool?) ?? false,
      milestone75Reached: (data['milestone75Reached'] as bool?) ?? false,
      milestone100Reached: (data['milestone100Reached'] as bool?) ?? false,
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
      'milestone50Reached': milestone50Reached,
      'milestone75Reached': milestone75Reached,
      'milestone100Reached': milestone100Reached,
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
        other.completed == completed &&
        other.milestone50Reached == milestone50Reached &&
        other.milestone75Reached == milestone75Reached &&
        other.milestone100Reached == milestone100Reached;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      targetAmount.hashCode ^
      currentAmount.hashCode ^
      targetDate.hashCode ^
      (description?.hashCode ?? 0) ^
      completed.hashCode ^
      milestone50Reached.hashCode ^
      milestone75Reached.hashCode ^
      milestone100Reached.hashCode;
}