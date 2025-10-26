import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user's savings goal (e.g., "TV", "Vacation").
///
/// Stored under each user's collection in Firestore, so no userId field here.
class SavingsGoal {
	/// Unique identifier for this goal (Firestore document id)
	final String id;

	/// Short name of the goal (e.g., "New TV")
	final String title;

	/// How much the user wants to save in total
	final double targetAmount;

	/// How much has been saved so far
	final double currentAmount;

	/// Optional target date to reach the goal
	final DateTime? targetDate;

	/// Optional notes/description
	final String? description;

		/// Whether the goal has been completed (persisted for quick queries/UI)
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

	/// Convenience: progress between 0.0 and 1.0
	double get progress {
		if (targetAmount <= 0) return 0.0;
		final p = currentAmount / targetAmount;
		if (p < 0) return 0.0;
		if (p > 1) return 1.0;
		return p;
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

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'title': title,
			'targetAmount': targetAmount,
			'currentAmount': currentAmount,
			'targetDate': targetDate?.toIso8601String(),
			'description': description,
				'completed': completed,
		};
	}

	factory SavingsGoal.fromJson(Map<String, dynamic> json) {
		return SavingsGoal(
			id: json['id'] as String,
			title: json['title'] as String,
			targetAmount: (json['targetAmount'] as num).toDouble(),
			currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
			targetDate: json['targetDate'] != null
					? DateTime.parse(json['targetDate'] as String)
					: null,
			description: json['description'] as String?,
					completed: (json['completed'] as bool?) ?? false,
		);
	}

	/// Firestore helpers
	factory SavingsGoal.fromMap(Map<String, dynamic> data, String documentId) {
		return SavingsGoal(
			id: documentId,
			title: data['title'] as String,
			targetAmount: (data['targetAmount'] as num).toDouble(),
			currentAmount: (data['currentAmount'] as num?)?.toDouble() ?? 0.0,
			targetDate: (data['targetDate'] is Timestamp)
					? (data['targetDate'] as Timestamp).toDate()
					: data['targetDate'] is DateTime
							? data['targetDate'] as DateTime
							: null,
			description: data['description'] as String?,
				completed: (data['completed'] as bool?) ?? false,
		);
	}

	Map<String, dynamic> toMap() {
		return {
			'title': title,
			'targetAmount': targetAmount,
			'currentAmount': currentAmount,
			'targetDate': targetDate, // Firestore stores DateTime as Timestamp
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
	int get hashCode => id.hashCode ^
			title.hashCode ^
			targetAmount.hashCode ^
			currentAmount.hashCode ^
			targetDate.hashCode ^
		  (description?.hashCode ?? 0) ^
		  completed.hashCode;

	@override
	String toString() =>
		  'SavingsGoal(id: $id, title: $title, targetAmount: $targetAmount, currentAmount: $currentAmount, targetDate: $targetDate, completed: $completed)';
}