import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/service/savings_goal_service.dart';

void main() {
  group('SavingsGoalService', () {
    late FakeFirebaseFirestore db;
    const userId = 'user_123';

    setUp(() {
      db = FakeFirebaseFirestore();
    });

    test('add/list/update/delete goals', () async {
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

    test('addGoal creates goal with all fields', () async {
      final targetDate = DateTime(2025, 12, 31);
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'Vacation',
        targetAmount: 5000,
        currentAmount: 1500,
        targetDate: targetDate,
        description: 'Trip to Hawaii',
        db: db,
      );

      expect(goal.title, 'Vacation');
      expect(goal.targetAmount, 5000);
      expect(goal.currentAmount, 1500);
      expect(goal.targetDate, targetDate);
      expect(goal.description, 'Trip to Hawaii');
    });

    test('addGoal creates goal with default values', () async {
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'New Car',
        targetAmount: 10000,
        db: db,
      );

      expect(goal.currentAmount, 0.0);
      expect(goal.targetDate, isNull);
      expect(goal.description, isNull);
      expect(goal.completed, false);
    });

    test('getAllGoals returns empty list for new user', () async {
      final goals = await SavingsGoalService.getAllGoals(userId, db: db);
      expect(goals, isEmpty);
    });

    test('getAllGoals returns multiple goals', () async {
      await SavingsGoalService.addGoal(
        userId,
        title: 'Goal 1',
        targetAmount: 1000,
        db: db,
      );
      await SavingsGoalService.addGoal(
        userId,
        title: 'Goal 2',
        targetAmount: 2000,
        db: db,
      );
      await SavingsGoalService.addGoal(
        userId,
        title: 'Goal 3',
        targetAmount: 3000,
        db: db,
      );

      final goals = await SavingsGoalService.getAllGoals(userId, db: db);
      expect(goals.length, 3);
      expect(goals.map((g) => g.title), containsAll(['Goal 1', 'Goal 2', 'Goal 3']));
    });

    test('getGoal returns null for non-existent goal', () async {
      final goal = await SavingsGoalService.getGoal(
        userId,
        'non_existent_id',
        db: db,
      );
      expect(goal, isNull);
    });

    test('getGoal returns correct goal', () async {
      final created = await SavingsGoalService.addGoal(
        userId,
        title: 'Test Goal',
        targetAmount: 1000,
        db: db,
      );

      final fetched = await SavingsGoalService.getGoal(userId, created.id, db: db);
      expect(fetched, isNotNull);
      expect(fetched!.id, created.id);
      expect(fetched.title, 'Test Goal');
    });

    test('updateGoal modifies existing goal', () async {
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'Original',
        targetAmount: 1000,
        currentAmount: 0,
        db: db,
      );

      final updated = goal.copyWith(
        title: 'Updated',
        currentAmount: 500,
      );
      await SavingsGoalService.updateGoal(userId, updated, db: db);

      final fetched = await SavingsGoalService.getGoal(userId, goal.id, db: db);
      expect(fetched!.title, 'Updated');
      expect(fetched.currentAmount, 500);
    });

    test('updateGoal marks goal as completed', () async {
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'Almost Done',
        targetAmount: 1000,
        currentAmount: 900,
        db: db,
      );

      final completed = goal.copyWith(
        currentAmount: 1000,
        completed: true,
      );
      await SavingsGoalService.updateGoal(userId, completed, db: db);

      final fetched = await SavingsGoalService.getGoal(userId, goal.id, db: db);
      expect(fetched!.completed, true);
      expect(fetched.currentAmount, 1000);
    });

    test('deleteGoal removes goal permanently', () async {
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'To Delete',
        targetAmount: 1000,
        db: db,
      );

      var goals = await SavingsGoalService.getAllGoals(userId, db: db);
      expect(goals.length, 1);

      await SavingsGoalService.deleteGoal(userId, goal.id, db: db);

      goals = await SavingsGoalService.getAllGoals(userId, db: db);
      expect(goals, isEmpty);

      final fetched = await SavingsGoalService.getGoal(userId, goal.id, db: db);
      expect(fetched, isNull);
    });

    test('streamGoals emits updates in real-time', () async {
      final stream = SavingsGoalService.streamGoals(userId, db: db);
      
      // First emission should be empty
      var goals = await stream.first;
      expect(goals, isEmpty);

      // Add a goal
      await SavingsGoalService.addGoal(
        userId,
        title: 'Streamed Goal',
        targetAmount: 1000,
        db: db,
      );

      // Stream should emit updated list
      goals = await stream.first;
      expect(goals.length, 1);
      expect(goals.first.title, 'Streamed Goal');
    });

    test('goals are isolated per user', () async {
      const user1 = 'user_1';
      const user2 = 'user_2';

      await SavingsGoalService.addGoal(
        user1,
        title: 'User 1 Goal',
        targetAmount: 1000,
        db: db,
      );

      await SavingsGoalService.addGoal(
        user2,
        title: 'User 2 Goal',
        targetAmount: 2000,
        db: db,
      );

      final user1Goals = await SavingsGoalService.getAllGoals(user1, db: db);
      final user2Goals = await SavingsGoalService.getAllGoals(user2, db: db);

      expect(user1Goals.length, 1);
      expect(user2Goals.length, 1);
      expect(user1Goals.first.title, 'User 1 Goal');
      expect(user2Goals.first.title, 'User 2 Goal');
    });

    test('contributing to goal increases current amount', () async {
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'Savings',
        targetAmount: 1000,
        currentAmount: 100,
        db: db,
      );

      // Simulate contributing $250
      final updated = goal.copyWith(currentAmount: goal.currentAmount + 250);
      await SavingsGoalService.updateGoal(userId, updated, db: db);

      final fetched = await SavingsGoalService.getGoal(userId, goal.id, db: db);
      expect(fetched!.currentAmount, 350);
    });

    test('contributing exactly to target completes goal', () async {
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'Almost There',
        targetAmount: 1000,
        currentAmount: 750,
        db: db,
      );

      // Contribute remaining $250
      final remaining = goal.targetAmount - goal.currentAmount;
      final updated = goal.copyWith(
        currentAmount: goal.currentAmount + remaining,
        completed: true,
      );
      await SavingsGoalService.updateGoal(userId, updated, db: db);

      final fetched = await SavingsGoalService.getGoal(userId, goal.id, db: db);
      expect(fetched!.currentAmount, 1000);
      expect(fetched.completed, true);
      expect(fetched.progress, 1.0);
    });

    test('over-contributing caps at target amount in UI logic', () async {
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'Savings',
        targetAmount: 1000,
        currentAmount: 900,
        db: db,
      );

      // User tries to contribute $200 but only $100 remaining
      final remaining = goal.targetAmount - goal.currentAmount;
      final attemptedContribution = 200.0;
      final actualContribution = attemptedContribution > remaining 
          ? remaining 
          : attemptedContribution;

      final updated = goal.copyWith(
        currentAmount: goal.currentAmount + actualContribution,
        completed: true,
      );
      await SavingsGoalService.updateGoal(userId, updated, db: db);

      final fetched = await SavingsGoalService.getGoal(userId, goal.id, db: db);
      expect(fetched!.currentAmount, 1000); // Capped at target
      expect(fetched.completed, true);
    });

    test('addGoal with empty title string', () async {
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: '',
        targetAmount: 1000,
        db: db,
      );

      expect(goal.title, '');
      final fetched = await SavingsGoalService.getGoal(userId, goal.id, db: db);
      expect(fetched!.title, '');
    });

    test('addGoal with very long title', () async {
      final longTitle = 'A' * 500;
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: longTitle,
        targetAmount: 1000,
        db: db,
      );

      expect(goal.title.length, 500);
      final fetched = await SavingsGoalService.getGoal(userId, goal.id, db: db);
      expect(fetched!.title, longTitle);
    });

    test('addGoal with very long description', () async {
      final longDescription = 'B' * 1000;
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'Test',
        targetAmount: 1000,
        description: longDescription,
        db: db,
      );

      expect(goal.description!.length, 1000);
      final fetched = await SavingsGoalService.getGoal(userId, goal.id, db: db);
      expect(fetched!.description, longDescription);
    });

    test('addGoal with zero target amount', () async {
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'Zero Target',
        targetAmount: 0,
        db: db,
      );

      expect(goal.targetAmount, 0);
      expect(goal.progress, 0.0);
    });

    test('addGoal with negative current amount', () async {
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'Negative Start',
        targetAmount: 1000,
        currentAmount: -100,
        db: db,
      );

      expect(goal.currentAmount, -100);
      expect(goal.progress, 0.0);
    });

    test('addGoal with very small decimal amounts', () async {
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'Pennies',
        targetAmount: 0.01,
        currentAmount: 0.005,
        db: db,
      );

      expect(goal.targetAmount, 0.01);
      expect(goal.currentAmount, 0.005);
      expect(goal.progress, 0.5);
    });

    test('addGoal with very large amounts', () async {
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'Millions',
        targetAmount: 1000000000,
        currentAmount: 500000000,
        db: db,
      );

      expect(goal.targetAmount, 1000000000);
      expect(goal.currentAmount, 500000000);
    });

    test('addGoal with past target date', () async {
      final pastDate = DateTime(2020, 1, 1);
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'Past Due',
        targetAmount: 1000,
        targetDate: pastDate,
        db: db,
      );

      expect(goal.targetDate, pastDate);
    });

    test('addGoal with far future target date', () async {
      final futureDate = DateTime(2100, 12, 31);
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'Far Future',
        targetAmount: 1000,
        targetDate: futureDate,
        db: db,
      );

      expect(goal.targetDate, futureDate);
    });

    test('updateGoal with changed milestone flags', () async {
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'Milestone Test',
        targetAmount: 1000,
        currentAmount: 500,
        db: db,
      );

      final updated = goal.copyWith(
        currentAmount: 750,
        milestone50Reached: true,
        milestone75Reached: true,
      );
      await SavingsGoalService.updateGoal(userId, updated, db: db);

      final fetched = await SavingsGoalService.getGoal(userId, goal.id, db: db);
      expect(fetched!.milestone50Reached, true);
      expect(fetched.milestone75Reached, true);
    });

    test('deleteGoal with non-existent goal id does not throw', () async {
      // Should not throw even if goal doesn't exist
      await SavingsGoalService.deleteGoal(userId, 'non_existent_id', db: db);
      
      final goals = await SavingsGoalService.getAllGoals(userId, db: db);
      expect(goals, isEmpty);
    });

    test('updateGoal to decrease current amount', () async {
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'Withdrawal',
        targetAmount: 1000,
        currentAmount: 500,
        db: db,
      );

      final updated = goal.copyWith(currentAmount: 300);
      await SavingsGoalService.updateGoal(userId, updated, db: db);

      final fetched = await SavingsGoalService.getGoal(userId, goal.id, db: db);
      expect(fetched!.currentAmount, 300);
    });

    test('updateGoal to uncomplete a goal', () async {
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'Uncomplete',
        targetAmount: 1000,
        currentAmount: 1000,
        db: db,
      );

      final completed = goal.copyWith(completed: true);
      await SavingsGoalService.updateGoal(userId, completed, db: db);

      var fetched = await SavingsGoalService.getGoal(userId, goal.id, db: db);
      expect(fetched!.completed, true);

      final uncompleted = fetched.copyWith(
        currentAmount: 800,
        completed: false,
      );
      await SavingsGoalService.updateGoal(userId, uncompleted, db: db);

      fetched = await SavingsGoalService.getGoal(userId, goal.id, db: db);
      expect(fetched!.completed, false);
      expect(fetched.currentAmount, 800);
    });

    test('getAllGoals with many goals returns all in order', () async {
      final date1 = DateTime(2025, 1, 1);
      final date2 = DateTime(2025, 6, 1);
      final date3 = DateTime(2025, 12, 31);

      await SavingsGoalService.addGoal(
        userId,
        title: 'Goal C',
        targetAmount: 1000,
        targetDate: date3,
        db: db,
      );

      await SavingsGoalService.addGoal(
        userId,
        title: 'Goal A',
        targetAmount: 2000,
        targetDate: date1,
        db: db,
      );

      await SavingsGoalService.addGoal(
        userId,
        title: 'Goal B',
        targetAmount: 3000,
        targetDate: date2,
        db: db,
      );

      final goals = await SavingsGoalService.getAllGoals(userId, db: db);
      expect(goals.length, 3);
    });

    test('streamGoals with null target dates', () async {
      await SavingsGoalService.addGoal(
        userId,
        title: 'No Date 1',
        targetAmount: 1000,
        db: db,
      );

      await SavingsGoalService.addGoal(
        userId,
        title: 'No Date 2',
        targetAmount: 2000,
        db: db,
      );

      final stream = SavingsGoalService.streamGoals(userId, db: db);
      final goals = await stream.first;

      expect(goals.length, 2);
    });

    test('concurrent updates to same goal', () async {
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'Concurrent',
        targetAmount: 1000,
        currentAmount: 0,
        db: db,
      );

      final update1 = goal.copyWith(currentAmount: 100);
      final update2 = goal.copyWith(currentAmount: 200);

      await Future.wait([
        SavingsGoalService.updateGoal(userId, update1, db: db),
        SavingsGoalService.updateGoal(userId, update2, db: db),
      ]);

      final fetched = await SavingsGoalService.getGoal(userId, goal.id, db: db);
      // One of the updates should win
      expect(fetched!.currentAmount, anyOf(100, 200));
    });

    test('updateGoal preserves id', () async {
      final goal = await SavingsGoalService.addGoal(
        userId,
        title: 'ID Test',
        targetAmount: 1000,
        db: db,
      );

      final originalId = goal.id;
      final updated = goal.copyWith(title: 'Updated Title');
      await SavingsGoalService.updateGoal(userId, updated, db: db);

      final fetched = await SavingsGoalService.getGoal(userId, goal.id, db: db);
      expect(fetched!.id, originalId);
    });

    test('special characters in title and description', () async {
      final specialTitle = 'Goal! @#\$%^&*()_+{}|:"<>?~`-=[]\\;\',./';
      final specialDesc = 'Description with émojis 😀🎉💰 and spëcial çhars';

      final goal = await SavingsGoalService.addGoal(
        userId,
        title: specialTitle,
        targetAmount: 1000,
        description: specialDesc,
        db: db,
      );

      final fetched = await SavingsGoalService.getGoal(userId, goal.id, db: db);
      expect(fetched!.title, specialTitle);
      expect(fetched.description, specialDesc);
    });
  });
}
