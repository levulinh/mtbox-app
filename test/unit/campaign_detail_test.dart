import 'package:test/test.dart';
import 'package:mtbox_app/models/campaign.dart';

Campaign _makeCampaign({required List<bool> history, int? totalDays}) {
  return Campaign(
    id: 'test',
    name: 'Test',
    goal: 'Test goal',
    totalDays: totalDays ?? history.length.clamp(1, 999),
    currentDay: history.length,
    isActive: true,
    dayHistory: history,
  );
}

void main() {
  // ── completedDays ──────────────────────────────────────────────────────────

  group('Campaign.completedDays', () {
    test('empty history → 0', () {
      expect(_makeCampaign(history: []).completedDays, equals(0));
    });

    test('all done → equals history length', () {
      expect(
        _makeCampaign(history: [true, true, true]).completedDays,
        equals(3),
      );
    });

    test('all missed → 0', () {
      expect(
        _makeCampaign(history: [false, false, false]).completedDays,
        equals(0),
      );
    });

    test('mixed → counts only true entries', () {
      // [true, false, true, true, false] → 3
      expect(
        _makeCampaign(history: [true, false, true, true, false]).completedDays,
        equals(3),
      );
    });

    test('single done day → 1', () {
      expect(_makeCampaign(history: [true]).completedDays, equals(1));
    });

    test('single missed day → 0', () {
      expect(_makeCampaign(history: [false]).completedDays, equals(0));
    });
  });

  // ── currentStreak ──────────────────────────────────────────────────────────

  group('Campaign.currentStreak', () {
    test('empty history → 0', () {
      expect(_makeCampaign(history: []).currentStreak, equals(0));
    });

    test('all done → streak equals history length', () {
      expect(
        _makeCampaign(history: [true, true, true, true]).currentStreak,
        equals(4),
      );
    });

    test('all missed → 0', () {
      expect(
        _makeCampaign(history: [false, false, false]).currentStreak,
        equals(0),
      );
    });

    test('trailing streak counted correctly', () {
      // [false, true, true] → streak = 2 (last two)
      expect(
        _makeCampaign(history: [false, true, true]).currentStreak,
        equals(2),
      );
    });

    test('streak broken by last day → 0', () {
      // [true, true, false] → last day is missed, streak = 0
      expect(
        _makeCampaign(history: [true, true, false]).currentStreak,
        equals(0),
      );
    });

    test('alternating end → streak = 1', () {
      // [false, true, false, true] → last is done, then false → streak = 1
      expect(
        _makeCampaign(history: [false, true, false, true]).currentStreak,
        equals(1),
      );
    });

    test('single done day → 1', () {
      expect(_makeCampaign(history: [true]).currentStreak, equals(1));
    });

    test('single missed day → 0', () {
      expect(_makeCampaign(history: [false]).currentStreak, equals(0));
    });

    test('longer streak with gap before it', () {
      // [true, false, true, true, true] → streak = 3
      expect(
        _makeCampaign(history: [true, false, true, true, true]).currentStreak,
        equals(3),
      );
    });
  });

  // ── completedDays and currentStreak together ──────────────────────────────

  group('Campaign — completedDays and currentStreak combined', () {
    test('20-day campaign: 15 done with gaps', () {
      // history: alternating true/false for 15 days, then 5 missed
      final history = List.generate(15, (i) => i.isEven) + List.generate(5, (_) => false);
      final c = _makeCampaign(history: history, totalDays: 20);
      // Even indices (0,2,4,6,8,10,12,14) = 8 done
      expect(c.completedDays, equals(8));
      // Last 5 are false → streak = 0
      expect(c.currentStreak, equals(0));
    });

    test('30-day campaign: last 7 consecutive done', () {
      final history = List.generate(23, (_) => false) + List.generate(7, (_) => true);
      final c = _makeCampaign(history: history, totalDays: 30);
      expect(c.completedDays, equals(7));
      expect(c.currentStreak, equals(7));
    });
  });
}
