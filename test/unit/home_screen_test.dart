import 'package:test/test.dart';
import 'package:mtbox_app/models/campaign.dart';

void main() {
  // ── Home Screen Stats Calculation ────────────────────────────────────────

  group('Home Screen Stats Calculation', () {
    group('Active Campaigns Count', () {
      test('returns 0 when no campaigns exist', () {
        final campaigns = <Campaign>[];
        final active = campaigns.where((c) => c.isActive).toList();
        expect(active.length, 0);
      });

      test('counts only active campaigns', () {
        final campaigns = [
          Campaign(
            id: '1',
            name: 'Run',
            goal: 'Run 30 days',
            totalDays: 30,
            currentDay: 5,
            isActive: true,
            dayHistory: List.generate(5, (_) => true),
          ),
          Campaign(
            id: '2',
            name: 'Read',
            goal: 'Read 10 books',
            totalDays: 10,
            currentDay: 3,
            isActive: false,
            dayHistory: List.generate(3, (_) => true),
          ),
          Campaign(
            id: '3',
            name: 'Code',
            goal: 'Code 30 days',
            totalDays: 30,
            currentDay: 10,
            isActive: true,
            dayHistory: List.generate(10, (_) => true),
          ),
        ];
        final active = campaigns.where((c) => c.isActive).toList();
        expect(active.length, 2);
      });

      test('returns 0 when all campaigns are inactive', () {
        final campaigns = [
          Campaign(
            id: '1',
            name: 'Run',
            goal: 'Run 30 days',
            totalDays: 30,
            currentDay: 30,
            isActive: false,
            dayHistory: List.generate(30, (_) => true),
          ),
          Campaign(
            id: '2',
            name: 'Read',
            goal: 'Read 10 books',
            totalDays: 10,
            currentDay: 10,
            isActive: false,
            dayHistory: List.generate(10, (_) => true),
          ),
        ];
        final active = campaigns.where((c) => c.isActive).toList();
        expect(active.length, 0);
      });
    });

    group('Done Today Count', () {
      test('returns 0 when no campaigns checked in today', () {
        final campaigns = [
          Campaign(
            id: '1',
            name: 'Run',
            goal: 'Run 30 days',
            totalDays: 30,
            currentDay: 5,
            isActive: true,
            dayHistory: List.generate(5, (_) => true),
            lastCheckInDate: null,
          ),
          Campaign(
            id: '2',
            name: 'Code',
            goal: 'Code 30 days',
            totalDays: 30,
            currentDay: 8,
            isActive: true,
            dayHistory: List.generate(8, (_) => true),
            lastCheckInDate: null,
          ),
        ];
        final active = campaigns.where((c) => c.isActive).toList();
        final doneToday = active.where((c) => c.checkedInToday).length;
        expect(doneToday, 0);
      });

      test('counts only active campaigns that checked in today', () {
        final now = DateTime.now();
        final today =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

        final campaigns = [
          Campaign(
            id: '1',
            name: 'Run',
            goal: 'Run 30 days',
            totalDays: 30,
            currentDay: 5,
            isActive: true,
            dayHistory: List.generate(5, (_) => true),
            lastCheckInDate: today,
          ),
          Campaign(
            id: '2',
            name: 'Read',
            goal: 'Read 10 books',
            totalDays: 10,
            currentDay: 3,
            isActive: false,
            dayHistory: List.generate(3, (_) => true),
            lastCheckInDate: today,
          ),
          Campaign(
            id: '3',
            name: 'Code',
            goal: 'Code 30 days',
            totalDays: 30,
            currentDay: 10,
            isActive: true,
            dayHistory: List.generate(10, (_) => true),
            lastCheckInDate: today,
          ),
        ];
        final active = campaigns.where((c) => c.isActive).toList();
        final doneToday = active.where((c) => c.checkedInToday).length;
        expect(doneToday, 2); // Only the 2 active campaigns
      });

      test('excludes active campaigns that checked in yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final yesterdayStr =
            '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

        final campaigns = [
          Campaign(
            id: '1',
            name: 'Run',
            goal: 'Run 30 days',
            totalDays: 30,
            currentDay: 5,
            isActive: true,
            dayHistory: List.generate(5, (_) => true),
            lastCheckInDate: yesterdayStr,
          ),
        ];
        final active = campaigns.where((c) => c.isActive).toList();
        final doneToday = active.where((c) => c.checkedInToday).length;
        expect(doneToday, 0);
      });
    });

    group('Best Streak Calculation', () {
      test('returns 0 when campaigns list is empty', () {
        final campaigns = <Campaign>[];
        final bestStreak = campaigns.isEmpty
            ? 0
            : campaigns.map((c) => c.currentStreak).reduce((a, b) => a > b ? a : b);
        expect(bestStreak, 0);
      });

      test('returns the maximum streak across all campaigns', () {
        final campaigns = [
          Campaign(
            id: '1',
            name: 'Run',
            goal: 'Run 30 days',
            totalDays: 30,
            currentDay: 10,
            isActive: true,
            dayHistory: [true, true, true, true, true, false, true, true, true, true],
          ),
          Campaign(
            id: '2',
            name: 'Read',
            goal: 'Read 10 books',
            totalDays: 10,
            currentDay: 7,
            isActive: true,
            dayHistory: [true, true, true, true, true, true, true],
          ),
          Campaign(
            id: '3',
            name: 'Code',
            goal: 'Code 30 days',
            totalDays: 30,
            currentDay: 5,
            isActive: true,
            dayHistory: [true, true, true, true, true],
          ),
        ];
        final bestStreak = campaigns.isEmpty
            ? 0
            : campaigns.map((c) => c.currentStreak).reduce((a, b) => a > b ? a : b);
        expect(bestStreak, 7); // The second campaign has 7 consecutive days
      });

      test('handles campaigns with no completed days', () {
        final campaigns = [
          Campaign(
            id: '1',
            name: 'Run',
            goal: 'Run 30 days',
            totalDays: 30,
            currentDay: 0,
            isActive: true,
            dayHistory: [],
          ),
          Campaign(
            id: '2',
            name: 'Read',
            goal: 'Read 10 books',
            totalDays: 10,
            currentDay: 3,
            isActive: true,
            dayHistory: [true, true, true],
          ),
        ];
        final bestStreak = campaigns.isEmpty
            ? 0
            : campaigns.map((c) => c.currentStreak).reduce((a, b) => a > b ? a : b);
        expect(bestStreak, 3);
      });

      test('returns the first highest streak when multiple campaigns tie', () {
        final campaigns = [
          Campaign(
            id: '1',
            name: 'Run',
            goal: 'Run 30 days',
            totalDays: 30,
            currentDay: 5,
            isActive: true,
            dayHistory: [true, true, true, true, true],
          ),
          Campaign(
            id: '2',
            name: 'Read',
            goal: 'Read 10 books',
            totalDays: 10,
            currentDay: 5,
            isActive: true,
            dayHistory: [true, true, true, true, true],
          ),
        ];
        final bestStreak = campaigns.isEmpty
            ? 0
            : campaigns.map((c) => c.currentStreak).reduce((a, b) => a > b ? a : b);
        expect(bestStreak, 5);
      });
    });

    group('Progress Calculations on Campaign Cards', () {
      test('calculates progressPercent correctly', () {
        final c = Campaign(
          id: '1',
          name: 'Run',
          goal: 'Run 30 days',
          totalDays: 30,
          currentDay: 15,
          isActive: true,
          dayHistory: List.generate(15, (_) => true),
        );
        expect(c.progressPercent, 0.5);
      });

      test('formats day progress label correctly', () {
        final c = Campaign(
          id: '1',
          name: 'Run',
          goal: 'Run 30 days',
          totalDays: 30,
          currentDay: 10,
          isActive: true,
          dayHistory: List.generate(10, (_) => true),
        );
        final pct = (c.progressPercent * 100).round();
        expect(pct, 33); // 10/30 ≈ 0.333... → rounds to 33%
      });

      test('handles edge case: day 0 of 30 days', () {
        final c = Campaign(
          id: '1',
          name: 'Run',
          goal: 'Run 30 days',
          totalDays: 30,
          currentDay: 0,
          isActive: true,
          dayHistory: [],
        );
        expect(c.progressPercent, 0.0);
      });

      test('handles edge case: final day completed', () {
        final c = Campaign(
          id: '1',
          name: 'Run',
          goal: 'Run 30 days',
          totalDays: 30,
          currentDay: 30,
          isActive: false,
          dayHistory: List.generate(30, (_) => true),
        );
        expect(c.progressPercent, 1.0);
      });
    });
  });
}
