import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/models/campaign.dart';

void main() {
  group('GoalType enum', () {
    test('has four values: days, hours, sessions, custom', () {
      expect(GoalType.values.length, 4);
      expect(GoalType.values, contains(GoalType.days));
      expect(GoalType.values, contains(GoalType.hours));
      expect(GoalType.values, contains(GoalType.sessions));
      expect(GoalType.values, contains(GoalType.custom));
    });
  });

  group('Campaign.unitLabel', () {
    test('returns DAYS for GoalType.days', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Test',
        totalDays: 30,
        currentDay: 0,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.days,
      );
      expect(campaign.unitLabel, 'DAYS');
    });

    test('returns HRS for GoalType.hours', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Test',
        totalDays: 100,
        currentDay: 0,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.hours,
      );
      expect(campaign.unitLabel, 'HRS');
    });

    test('returns SESSIONS for GoalType.sessions', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Test',
        totalDays: 20,
        currentDay: 0,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.sessions,
      );
      expect(campaign.unitLabel, 'SESSIONS');
    });

    test('returns uppercase metricName for GoalType.custom with non-empty metricName',
        () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Test',
        totalDays: 100,
        currentDay: 0,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.custom,
        metricName: 'Pages read',
      );
      expect(campaign.unitLabel, 'PAGES READ');
    });

    test('returns UNITS for GoalType.custom with empty metricName', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Test',
        totalDays: 50,
        currentDay: 0,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.custom,
        metricName: '',
      );
      expect(campaign.unitLabel, 'UNITS');
    });

    test('handles edge case: metricName with mixed case', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Test',
        totalDays: 50,
        currentDay: 0,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.custom,
        metricName: 'MiLeS rUn',
      );
      expect(campaign.unitLabel, 'MILES RUN');
    });
  });

  group('Campaign.checkInLabel', () {
    test('returns CHECK IN TODAY for GoalType.days', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Test',
        totalDays: 30,
        currentDay: 0,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.days,
      );
      expect(campaign.checkInLabel, 'CHECK IN TODAY');
    });

    test('returns LOG HOURS for GoalType.hours', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Test',
        totalDays: 100,
        currentDay: 0,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.hours,
      );
      expect(campaign.checkInLabel, 'LOG HOURS');
    });

    test('returns LOG SESSION for GoalType.sessions', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Test',
        totalDays: 20,
        currentDay: 0,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.sessions,
      );
      expect(campaign.checkInLabel, 'LOG SESSION');
    });

    test('returns LOG <METRIC> for GoalType.custom with non-empty metricName',
        () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Test',
        totalDays: 100,
        currentDay: 0,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.custom,
        metricName: 'Pages read',
      );
      expect(campaign.checkInLabel, 'LOG PAGES READ');
    });

    test('returns LOG PROGRESS for GoalType.custom with empty metricName',
        () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Test',
        totalDays: 50,
        currentDay: 0,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.custom,
        metricName: '',
      );
      expect(campaign.checkInLabel, 'LOG PROGRESS');
    });
  });

  group('Campaign goalType defaults', () {
    test('defaults to GoalType.days when not specified', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Test',
        totalDays: 30,
        currentDay: 0,
        isActive: true,
        dayHistory: const [],
      );
      expect(campaign.goalType, GoalType.days);
    });

    test('defaults to empty metricName when not specified', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Test',
        totalDays: 30,
        currentDay: 0,
        isActive: true,
        dayHistory: const [],
      );
      expect(campaign.metricName, '');
    });

    test('accepts explicit goalType and metricName', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Test',
        totalDays: 100,
        currentDay: 0,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.custom,
        metricName: 'Books read',
      );
      expect(campaign.goalType, GoalType.custom);
      expect(campaign.metricName, 'Books read');
    });
  });

  group('Campaign model backward compatibility', () {
    test('creating campaign with only required fields works', () {
      final campaign = Campaign(
        id: 'id123',
        name: 'Old Campaign',
        goal: 'Old Campaign',
        totalDays: 30,
        currentDay: 5,
        isActive: true,
        dayHistory: const [true, true, true, true, true],
      );
      expect(campaign.id, 'id123');
      expect(campaign.name, 'Old Campaign');
      expect(campaign.totalDays, 30);
      expect(campaign.currentDay, 5);
      expect(campaign.goalType, GoalType.days); // defaults to days
      expect(campaign.metricName, ''); // defaults to empty
      expect(campaign.colorHex, '4C6EAD'); // defaults to blue
      expect(campaign.iconName, 'fitness_center'); // defaults to fitness
    });
  });

  group('Campaign progress with different goal types', () {
    test('progressPercent works correctly regardless of goal type', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Test',
        totalDays: 100,
        currentDay: 50,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.hours,
      );
      expect(campaign.progressPercent, 0.5);
    });

    test('completedDays works correctly with custom goal types', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Test',
        totalDays: 20,
        currentDay: 8,
        isActive: true,
        dayHistory: const [true, true, true, false, true, true, true, true],
        goalType: GoalType.sessions,
      );
      expect(campaign.completedDays, 7);
    });

    test('currentStreak works correctly with custom goal types', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Test',
        totalDays: 20,
        currentDay: 5,
        isActive: true,
        dayHistory: const [true, true, true, true, false, true, true, true],
        goalType: GoalType.custom,
        metricName: 'Pages',
      );
      expect(campaign.currentStreak, 3);
    });
  });
}
