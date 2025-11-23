import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p5_expense/model/savings_goal.dart';

void main() {
  group('SavingsGoal', () {
    test('creates goal with required fields', () {
      final goal = SavingsGoal(
        id: 'goal_1',
        title: 'New Car',
        targetAmount: 10000,
      );

      expect(goal.id, 'goal_1');
      expect(goal.title, 'New Car');
      expect(goal.targetAmount, 10000);
      expect(goal.currentAmount, 0.0);
      expect(goal.targetDate, isNull);
      expect(goal.description, isNull);
      expect(goal.completed, false);
    });

    test('creates goal with all fields', () {
      final targetDate = DateTime(2025, 12, 31);
      final goal = SavingsGoal(
        id: 'goal_2',
        title: 'Vacation',
        targetAmount: 5000,
        currentAmount: 1500,
        targetDate: targetDate,
        description: 'Trip to Hawaii',
        completed: false,
      );

      expect(goal.id, 'goal_2');
      expect(goal.title, 'Vacation');
      expect(goal.targetAmount, 5000);
      expect(goal.currentAmount, 1500);
      expect(goal.targetDate, targetDate);
      expect(goal.description, 'Trip to Hawaii');
      expect(goal.completed, false);
    });

    group('progress getter', () {
      test('returns 0.0 when no progress made', () {
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 0,
        );
        expect(goal.progress, 0.0);
      });

      test('returns correct progress for partial completion', () {
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 250,
        );
        expect(goal.progress, 0.25);
      });

      test('returns 1.0 when goal is exactly met', () {
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 1000,
        );
        expect(goal.progress, 1.0);
      });

      test('returns 1.0 when goal is exceeded', () {
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 1500,
        );
        expect(goal.progress, 1.0);
      });

      test('returns 0.0 when target amount is 0', () {
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 0,
          currentAmount: 100,
        );
        expect(goal.progress, 0.0);
      });

      test('returns 0.0 when target amount is negative', () {
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: -100,
          currentAmount: 50,
        );
        expect(goal.progress, 0.0);
      });

      test('returns 0.0 when current amount is negative', () {
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: -50,
        );
        expect(goal.progress, 0.0);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = SavingsGoal(
          id: 'goal_1',
          title: 'Original',
          targetAmount: 1000,
          currentAmount: 100,
        );

        final updated = original.copyWith(
          title: 'Updated',
          currentAmount: 500,
        );

        expect(updated.id, 'goal_1');
        expect(updated.title, 'Updated');
        expect(updated.targetAmount, 1000);
        expect(updated.currentAmount, 500);
      });

      test('marks goal as completed', () {
        final original = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 900,
          completed: false,
        );

        final completed = original.copyWith(
          currentAmount: 1000,
          completed: true,
        );

        expect(completed.completed, true);
        expect(completed.currentAmount, 1000);
      });

      test('preserves unchanged fields', () {
        final targetDate = DateTime(2025, 12, 31);
        final original = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 500,
          targetDate: targetDate,
          description: 'Original description',
        );

        final updated = original.copyWith(currentAmount: 600);

        expect(updated.id, original.id);
        expect(updated.title, original.title);
        expect(updated.targetAmount, original.targetAmount);
        expect(updated.targetDate, original.targetDate);
        expect(updated.description, original.description);
        expect(updated.currentAmount, 600);
      });
    });

    group('toMap', () {
      test('converts goal to map correctly', () {
        final targetDate = DateTime(2025, 12, 31);
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test Goal',
          targetAmount: 1000,
          currentAmount: 250,
          targetDate: targetDate,
          description: 'Test description',
          completed: false,
        );

        final map = goal.toMap();

        expect(map['title'], 'Test Goal');
        expect(map['targetAmount'], 1000);
        expect(map['currentAmount'], 250);
        expect(map['targetDate'], targetDate);
        expect(map['description'], 'Test description');
        expect(map['completed'], false);
        expect(map.containsKey('id'), false); // id not included in toMap
      });

      test('handles null optional fields', () {
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
        );

        final map = goal.toMap();

        expect(map['targetDate'], isNull);
        expect(map['description'], isNull);
      });
    });

    group('fromMap', () {
      test('creates goal from map with all fields', () {
        final targetDate = DateTime(2025, 12, 31);
        final map = {
          'title': 'Test Goal',
          'targetAmount': 1000,
          'currentAmount': 250,
          'targetDate': Timestamp.fromDate(targetDate),
          'description': 'Test description',
          'completed': false,
        };

        final goal = SavingsGoal.fromMap(map, 'goal_1');

        expect(goal.id, 'goal_1');
        expect(goal.title, 'Test Goal');
        expect(goal.targetAmount, 1000);
        expect(goal.currentAmount, 250);
        expect(goal.targetDate, targetDate);
        expect(goal.description, 'Test description');
        expect(goal.completed, false);
      });

      test('handles missing optional fields', () {
        final map = {
          'title': 'Test',
          'targetAmount': 1000,
        };

        final goal = SavingsGoal.fromMap(map, 'goal_1');

        expect(goal.currentAmount, 0.0);
        expect(goal.targetDate, isNull);
        expect(goal.description, isNull);
        expect(goal.completed, false);
      });

      test('handles DateTime type for targetDate', () {
        final targetDate = DateTime(2025, 12, 31);
        final map = {
          'title': 'Test',
          'targetAmount': 1000,
          'targetDate': targetDate,
        };

        final goal = SavingsGoal.fromMap(map, 'goal_1');

        expect(goal.targetDate, targetDate);
      });

      test('handles integer amounts', () {
        final map = {
          'title': 'Test',
          'targetAmount': 1000,
          'currentAmount': 250,
        };

        final goal = SavingsGoal.fromMap(map, 'goal_1');

        expect(goal.targetAmount, 1000.0);
        expect(goal.currentAmount, 250.0);
      });
    });

    group('equality', () {
      test('equal goals are equal', () {
        final targetDate = DateTime(2025, 12, 31);
        final goal1 = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 500,
          targetDate: targetDate,
          description: 'Test',
          completed: false,
        );

        final goal2 = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 500,
          targetDate: targetDate,
          description: 'Test',
          completed: false,
        );

        expect(goal1, equals(goal2));
        expect(goal1.hashCode, equals(goal2.hashCode));
      });

      test('different goals are not equal', () {
        final goal1 = SavingsGoal(
          id: 'goal_1',
          title: 'Test 1',
          targetAmount: 1000,
        );

        final goal2 = SavingsGoal(
          id: 'goal_2',
          title: 'Test 2',
          targetAmount: 1000,
        );

        expect(goal1, isNot(equals(goal2)));
      });

      test('same reference is equal', () {
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
        );

        expect(goal, equals(goal));
      });
    });

    group('milestone detection', () {
      test('detectNewMilestones finds 50% milestone', () {
        final oldGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 400,
        );

        final newGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 500,
        );

        final milestones = newGoal.detectNewMilestones(oldGoal);
        expect(milestones, contains(50));
        expect(milestones.length, 1);
      });

      test('detectNewMilestones finds 75% milestone', () {
        final oldGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 700,
          milestone50Reached: true,
        );

        final newGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 750,
          milestone50Reached: true,
        );

        final milestones = newGoal.detectNewMilestones(oldGoal);
        expect(milestones, contains(75));
        expect(milestones.length, 1);
      });

      test('detectNewMilestones finds 100% milestone', () {
        final oldGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 950,
          milestone50Reached: true,
          milestone75Reached: true,
        );

        final newGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 1000,
          milestone50Reached: true,
          milestone75Reached: true,
        );

        final milestones = newGoal.detectNewMilestones(oldGoal);
        expect(milestones, contains(100));
        expect(milestones.length, 1);
      });

      test('detectNewMilestones finds multiple milestones at once', () {
        final oldGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 0,
        );

        final newGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 1000,
        );

        final milestones = newGoal.detectNewMilestones(oldGoal);
        expect(milestones, containsAll([50, 75, 100]));
        expect(milestones.length, 3);
      });

      test('detectNewMilestones ignores already reached milestones', () {
        final oldGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 600,
          milestone50Reached: true,
        );

        final newGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 800,
          milestone50Reached: true,
        );

        final milestones = newGoal.detectNewMilestones(oldGoal);
        expect(milestones, contains(75));
        expect(milestones, isNot(contains(50)));
      });

      test('updateMilestones sets flags correctly', () {
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 800,
        );

        final updated = goal.updateMilestones();
        expect(updated.milestone50Reached, true);
        expect(updated.milestone75Reached, true);
        expect(updated.milestone100Reached, false);
      });

      test('updateMilestones preserves already reached milestones', () {
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 400,
          milestone50Reached: true,
        );

        final updated = goal.updateMilestones();
        expect(updated.milestone50Reached, true);
      });

      test('detectNewMilestones returns empty list when no new milestones', () {
        final oldGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 400,
        );

        final newGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 450,
        );

        final milestones = newGoal.detectNewMilestones(oldGoal);
        expect(milestones, isEmpty);
      });

      test('detectNewMilestones with zero target amount returns empty', () {
        final oldGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 0,
          currentAmount: 0,
        );

        final newGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 0,
          currentAmount: 100,
        );

        final milestones = newGoal.detectNewMilestones(oldGoal);
        expect(milestones, isEmpty);
      });

      test('detectNewMilestones with decreased progress returns empty', () {
        final oldGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 600,
          milestone50Reached: true,
        );

        final newGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 400,
          milestone50Reached: true,
        );

        final milestones = newGoal.detectNewMilestones(oldGoal);
        expect(milestones, isEmpty);
      });

      test('updateMilestones with 100% completion sets all flags', () {
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 1000,
        );

        final updated = goal.updateMilestones();
        expect(updated.milestone50Reached, true);
        expect(updated.milestone75Reached, true);
        expect(updated.milestone100Reached, true);
      });

      test('updateMilestones with zero progress sets no flags', () {
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 0,
        );

        final updated = goal.updateMilestones();
        expect(updated.milestone50Reached, false);
        expect(updated.milestone75Reached, false);
        expect(updated.milestone100Reached, false);
      });

      test('detectNewMilestones at exact 50% boundary', () {
        final oldGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 100,
          currentAmount: 49,
        );

        final newGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 100,
          currentAmount: 50,
        );

        final milestones = newGoal.detectNewMilestones(oldGoal);
        expect(milestones, contains(50));
      });

      test('detectNewMilestones at exact 75% boundary', () {
        final oldGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 100,
          currentAmount: 74,
          milestone50Reached: true,
        );

        final newGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 100,
          currentAmount: 75,
          milestone50Reached: true,
        );

        final milestones = newGoal.detectNewMilestones(oldGoal);
        expect(milestones, contains(75));
      });

      test('detectNewMilestones skips intermediate milestones when jumping', () {
        final oldGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 600,
          milestone50Reached: true,
        );

        final newGoal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 1000,
          milestone50Reached: true,
        );

        final milestones = newGoal.detectNewMilestones(oldGoal);
        expect(milestones, containsAll([75, 100]));
        expect(milestones.length, 2);
      });
    });

    group('edge cases', () {
      test('progress handles very small amounts correctly', () {
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 0.01,
          currentAmount: 0.005,
        );
        expect(goal.progress, 0.5);
      });

      test('progress handles very large amounts correctly', () {
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000000000,
          currentAmount: 500000000,
        );
        expect(goal.progress, 0.5);
      });

      test('copyWith preserves description when not specified', () {
        final original = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          description: 'Original description',
        );

        final updated = original.copyWith(currentAmount: 100);
        expect(updated.description, 'Original description');
      });

      test('copyWith preserves targetDate when not specified', () {
        final original = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          targetDate: DateTime(2025, 12, 31),
        );

        final updated = original.copyWith(currentAmount: 100);
        expect(updated.targetDate, DateTime(2025, 12, 31));
      });

      test('toMap includes milestone flags', () {
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 800,
          milestone50Reached: true,
          milestone75Reached: true,
        );

        final map = goal.toMap();
        expect(map['milestone50Reached'], true);
        expect(map['milestone75Reached'], true);
        expect(map['milestone100Reached'], false);
      });

      test('fromMap handles missing milestone flags', () {
        final map = {
          'title': 'Test',
          'targetAmount': 1000,
          'currentAmount': 500,
        };

        final goal = SavingsGoal.fromMap(map, 'goal_1');
        expect(goal.milestone50Reached, false);
        expect(goal.milestone75Reached, false);
        expect(goal.milestone100Reached, false);
      });

      test('fromMap handles all milestone flags set to true', () {
        final map = {
          'title': 'Test',
          'targetAmount': 1000,
          'currentAmount': 1000,
          'milestone50Reached': true,
          'milestone75Reached': true,
          'milestone100Reached': true,
        };

        final goal = SavingsGoal.fromMap(map, 'goal_1');
        expect(goal.milestone50Reached, true);
        expect(goal.milestone75Reached, true);
        expect(goal.milestone100Reached, true);
      });

      test('equality considers milestone flags', () {
        final goal1 = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 500,
          milestone50Reached: true,
        );

        final goal2 = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 500,
          milestone50Reached: false,
        );

        expect(goal1, isNot(equals(goal2)));
      });

      test('copyWith can update all milestone flags', () {
        final original = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
        );

        final updated = original.copyWith(
          milestone50Reached: true,
          milestone75Reached: true,
          milestone100Reached: true,
        );

        expect(updated.milestone50Reached, true);
        expect(updated.milestone75Reached, true);
        expect(updated.milestone100Reached, true);
      });

      test('progress with floating point precision edge case', () {
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 3.0,
          currentAmount: 1.0,
        );
        expect(goal.progress, closeTo(0.333333, 0.00001));
      });

      test('completed goal with progress over 100%', () {
        final goal = SavingsGoal(
          id: 'goal_1',
          title: 'Test',
          targetAmount: 1000,
          currentAmount: 1500,
          completed: true,
        );
        expect(goal.progress, 1.0);
        expect(goal.completed, true);
      });
    });
  });
}
