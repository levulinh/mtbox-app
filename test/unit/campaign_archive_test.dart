import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/models/campaign.dart';

void main() {
  group('Campaign.bestStreak', () {
    test('returns 0 for empty dayHistory', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Goal',
        totalDays: 10,
        currentDay: 0,
        isActive: true,
        dayHistory: [],
      );
      expect(campaign.bestStreak, 0);
    });

    test('returns length when all days are true', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Goal',
        totalDays: 5,
        currentDay: 5,
        isActive: false,
        dayHistory: [true, true, true, true, true],
      );
      expect(campaign.bestStreak, 5);
    });

    test('returns 0 when all days are false', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Goal',
        totalDays: 5,
        currentDay: 0,
        isActive: true,
        dayHistory: [false, false, false, false, false],
      );
      expect(campaign.bestStreak, 0);
    });

    test('identifies longest streak in middle of gaps', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Goal',
        totalDays: 10,
        currentDay: 8,
        isActive: true,
        dayHistory: [
          true, true, false, true, true, true, true, false, true, true
        ],
      );
      expect(campaign.bestStreak, 4); // days 3-6 are 4 consecutive trues
    });

    test('handles streak at start', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Goal',
        totalDays: 8,
        currentDay: 3,
        isActive: true,
        dayHistory: [true, true, true, true, false, false, false, false],
      );
      expect(campaign.bestStreak, 4);
    });

    test('handles streak at end', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Goal',
        totalDays: 8,
        currentDay: 8,
        isActive: true,
        dayHistory: [false, false, false, false, true, true, true, true],
      );
      expect(campaign.bestStreak, 4);
    });

    test('single true day', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Goal',
        totalDays: 5,
        currentDay: 2,
        isActive: true,
        dayHistory: [false, true, false, false, false],
      );
      expect(campaign.bestStreak, 1);
    });
  });

  group('Campaign archive filtering', () {
    test('completed campaigns have isActive = false', () {
      final completed = Campaign(
        id: '1',
        name: 'Completed Campaign',
        goal: 'Goal',
        totalDays: 30,
        currentDay: 30,
        isActive: false,
        dayHistory: List.filled(30, true),
      );
      expect(completed.isActive, false);
    });

    test('active campaigns have isActive = true', () {
      final active = Campaign(
        id: '2',
        name: 'Active Campaign',
        goal: 'Goal',
        totalDays: 30,
        currentDay: 15,
        isActive: true,
        dayHistory: List.filled(15, true) + List.filled(15, false),
      );
      expect(active.isActive, true);
    });

    test('filter logic separates active from completed', () {
      final campaigns = [
        Campaign(
          id: '1',
          name: 'Active 1',
          goal: 'Goal',
          totalDays: 10,
          currentDay: 5,
          isActive: true,
          dayHistory: List.filled(5, true) + List.filled(5, false),
        ),
        Campaign(
          id: '2',
          name: 'Completed 1',
          goal: 'Goal',
          totalDays: 30,
          currentDay: 30,
          isActive: false,
          dayHistory: List.filled(30, true),
        ),
        Campaign(
          id: '3',
          name: 'Active 2',
          goal: 'Goal',
          totalDays: 20,
          currentDay: 10,
          isActive: true,
          dayHistory: List.filled(10, true) + List.filled(10, false),
        ),
        Campaign(
          id: '4',
          name: 'Completed 2',
          goal: 'Goal',
          totalDays: 21,
          currentDay: 21,
          isActive: false,
          dayHistory: List.filled(21, true),
        ),
      ];

      final completed = campaigns.where((c) => !c.isActive).toList();
      expect(completed.length, 2);
      expect(completed[0].id, '2');
      expect(completed[1].id, '4');
    });
  });

  group('Archive card date range calculation', () {
    test('formats date correctly', () {
      // This mirrors _dateRange() and _fmt() logic from the screen
      final lastCheckIn = '2026-03-31';
      final parts = lastCheckIn.split('-');
      final end = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      expect(end.year, 2026);
      expect(end.month, 3);
      expect(end.day, 31);
    });

    test('calculates start date from totalDays', () {
      final lastCheckIn = '2026-03-31';
      final totalDays = 30;
      final parts = lastCheckIn.split('-');
      final end = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final start = end.subtract(Duration(days: totalDays - 1));

      expect(start.day, 2);
      expect(start.month, 3);
      expect(start.year, 2026);
    });

    test('handles campaign with no lastCheckInDate', () {
      const campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Goal',
        totalDays: 10,
        currentDay: 0,
        isActive: true,
        dayHistory: [],
        lastCheckInDate: null,
      );
      expect(campaign.lastCheckInDate, null);
    });
  });

  group('Campaign progress for completed campaigns', () {
    test('completed campaign has all days checked', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Goal',
        totalDays: 30,
        currentDay: 30,
        isActive: false,
        dayHistory: List.filled(30, true),
      );
      expect(campaign.completedDays, 30);
      expect(campaign.completedDays, campaign.totalDays);
    });

    test('calculates completedDays correctly from dayHistory', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Goal',
        totalDays: 10,
        currentDay: 8,
        isActive: true,
        dayHistory: [
          true, true, true, false, true, true, false, true, false, false
        ],
      );
      expect(campaign.completedDays, 6);
    });
  });
}
