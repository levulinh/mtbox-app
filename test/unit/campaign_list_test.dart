import 'package:test/test.dart';
import 'package:mtbox_app/models/campaign.dart';

Campaign makeCampaign({
  int currentDay = 0,
  int totalDays = 30,
  bool isActive = true,
  List<bool>? dayHistory,
}) {
  return Campaign(
    id: 'test',
    name: 'Test Campaign',
    goal: 'Some goal',
    totalDays: totalDays,
    currentDay: currentDay,
    isActive: isActive,
    dayHistory: dayHistory ?? [],
  );
}

void main() {
  group('Campaign.progressPercent', () {
    test('is 0.0 at day 0', () {
      final c = makeCampaign(currentDay: 0, totalDays: 30);
      expect(c.progressPercent, equals(0.0));
    });

    test('is correct mid-campaign (18 of 30 → 0.6)', () {
      final c = makeCampaign(currentDay: 18, totalDays: 30);
      expect(c.progressPercent, closeTo(0.6, 0.001));
    });

    test('is 1.0 when currentDay equals totalDays', () {
      final c = makeCampaign(currentDay: 21, totalDays: 21);
      expect(c.progressPercent, equals(1.0));
    });

    test('is 0.5 for exactly halfway through', () {
      final c = makeCampaign(currentDay: 7, totalDays: 14);
      expect(c.progressPercent, equals(0.5));
    });
  });

  group('Campaign fields', () {
    test('isActive flag is preserved', () {
      final active = makeCampaign(isActive: true);
      final completed = makeCampaign(isActive: false);
      expect(active.isActive, isTrue);
      expect(completed.isActive, isFalse);
    });

    test('dayHistory length can differ from currentDay', () {
      // Partial history is valid — future days are simply absent
      final c = makeCampaign(
        currentDay: 10,
        totalDays: 30,
        dayHistory: List.generate(7, (_) => true),
      );
      expect(c.dayHistory.length, equals(7));
      expect(c.currentDay, equals(10));
    });

    test('dayHistory entries are individually true or false', () {
      final history = [true, false, true, true, false];
      final c = makeCampaign(dayHistory: history);
      expect(c.dayHistory, equals(history));
    });
  });
}
