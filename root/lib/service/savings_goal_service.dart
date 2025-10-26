import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:p5_expense/model/savings_goal.dart';

/// Service responsible for CRUD operations on a user's savings goals.
///
/// Collection layout:
/// users/{uid}/savings_goals/{goalId}
class SavingsGoalService {
  static const String collectionName = 'savings_goals';

  static firestore.CollectionReference<Map<String, dynamic>> _collection(
    String userId, {
    firestore.FirebaseFirestore? db,
  }) {
    final instance = db ?? firestore.FirebaseFirestore.instance;
    return instance
        .collection('users')
        .doc(userId)
        .collection(collectionName);
  }

  /// Create a new goal with an auto-generated id.
  static Future<SavingsGoal> addGoal(
    String userId, {
    required String title,
    required double targetAmount,
    double currentAmount = 0.0,
    DateTime? targetDate,
    String? description,
    firestore.FirebaseFirestore? db,
  }) async {
    final col = _collection(userId, db: db);
    final docRef = col.doc();
    final goal = SavingsGoal(
      id: docRef.id,
      title: title,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      targetDate: targetDate,
      description: description,
    );
    await docRef.set(goal.toMap());
    return goal;
  }

  /// Upsert a goal with a specified id (useful if you already created the id in UI).
  static Future<void> setGoal(
    String userId,
    SavingsGoal goal, {
    firestore.FirebaseFirestore? db,
  }) async {
    final col = _collection(userId, db: db);
    await col.doc(goal.id).set(goal.toMap());
  }

  static Future<void> updateGoal(
    String userId,
    SavingsGoal goal, {
    firestore.FirebaseFirestore? db,
  }) async {
    final col = _collection(userId, db: db);
    await col.doc(goal.id).update(goal.toMap());
  }

  static Future<void> deleteGoal(
    String userId,
    String goalId, {
    firestore.FirebaseFirestore? db,
  }) async {
    final col = _collection(userId, db: db);
    await col.doc(goalId).delete();
  }

  static Future<SavingsGoal?> getGoal(
    String userId,
    String goalId, {
    firestore.FirebaseFirestore? db,
  }) async {
    final col = _collection(userId, db: db);
    final snap = await col.doc(goalId).get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;
    return SavingsGoal.fromMap(data, snap.id);
  }

  static Future<List<SavingsGoal>> getAllGoals(
    String userId, {
    firestore.FirebaseFirestore? db,
  }) async {
    final query = await _collection(userId, db: db).get();
    return query.docs
        .map((d) => SavingsGoal.fromMap(d.data(), d.id))
        .toList();
  }

  static Stream<List<SavingsGoal>> streamGoals(
    String userId, {
    firestore.FirebaseFirestore? db,
  }) {
    return _collection(userId, db: db)
        .orderBy('targetDate', descending: false)
        .snapshots()
        .map((qs) =>
            qs.docs.map((d) => SavingsGoal.fromMap(d.data(), d.id)).toList());
  }
}
