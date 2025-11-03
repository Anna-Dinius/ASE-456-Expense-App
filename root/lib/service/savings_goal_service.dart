import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:p5_expense/model/savings_goal.dart';

class SavingsGoalService {
  static const String _collectionName = 'savings_goals';

  static firestore.CollectionReference<Map<String, dynamic>> _collection(
    String userId, {
    firestore.FirebaseFirestore? db,
  }) {
    final instance = db ?? firestore.FirebaseFirestore.instance;
    return instance.collection('users').doc(userId).collection(_collectionName);
  }

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

  static Future<void> updateGoal(
    String userId,
    SavingsGoal goal, {
    firestore.FirebaseFirestore? db,
  }) async {
    await _collection(userId, db: db).doc(goal.id).update(goal.toMap());
  }

  static Future<void> deleteGoal(
    String userId,
    String goalId, {
    firestore.FirebaseFirestore? db,
  }) async {
    await _collection(userId, db: db).doc(goalId).delete();
  }

  static Future<SavingsGoal?> getGoal(
    String userId,
    String goalId, {
    firestore.FirebaseFirestore? db,
  }) async {
    final snap = await _collection(userId, db: db).doc(goalId).get();
    if (!snap.exists || snap.data() == null) return null;
    return SavingsGoal.fromMap(snap.data()!, snap.id);
  }

  static Future<List<SavingsGoal>> getAllGoals(
    String userId, {
    firestore.FirebaseFirestore? db,
  }) async {
    final query = await _collection(userId, db: db).get();
    return query.docs.map((d) => SavingsGoal.fromMap(d.data(), d.id)).toList();
  }

  static Stream<List<SavingsGoal>> streamGoals(
    String userId, {
    firestore.FirebaseFirestore? db,
  }) {
    return _collection(userId, db: db)
        .orderBy('targetDate', descending: false)
        .snapshots()
        .map((qs) => qs.docs.map((d) => SavingsGoal.fromMap(d.data(), d.id)).toList());
  }
}
