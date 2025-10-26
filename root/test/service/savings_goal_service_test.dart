import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/service/savings_goal_service.dart';

void main() {
  group('SavingsGoalService', () {
    test('add/list/update/delete goals', () async {
      final db = FakeFirebaseFirestore();
      const userId = 'user_123';

      // Add
      final g1 = await SavingsGoalService.addGoal(
        userId,
        title: 'TV',
        targetAmount: 500,
        db: db,
      );
      expect(g1.id, isNotEmpty);
      expect(g1.title, 'TV');
      expect(g1.targetAmount, 500);

      // List
      var all = await SavingsGoalService.getAllGoals(userId, db: db);
      expect(all.length, 1);
      expect(all.first.title, 'TV');

      // Update
      final updated = g1.copyWith(currentAmount: 125);
      await SavingsGoalService.updateGoal(userId, updated, db: db);
      final fetched = await SavingsGoalService.getGoal(userId, g1.id, db: db);
      expect(fetched!.currentAmount, 125);

      // Stream (sanity)
      final streamFuture = SavingsGoalService.streamGoals(userId, db: db).first;
      final streamed = await streamFuture;
      expect(streamed.length, 1);
      expect(streamed.first.id, g1.id);

      // Delete
      await SavingsGoalService.deleteGoal(userId, g1.id, db: db);
      all = await SavingsGoalService.getAllGoals(userId, db: db);
      expect(all, isEmpty);
    });
  });
}
